"""Generate TODO.md — an index of prefixed TODO comments found in the code.

Run with: `make todo` (uv run python scripts/gen_todo.py).
Check staleness in CI with: `make todo-check`.

Why generated, not hand-written:
    A hand-maintained TODO list is "the one document to rule them all" — it goes
    stale the moment someone fixes something without updating it. Here the CODE
    is the source of truth and this file is only a view, so the list cannot lie
    for longer than it takes to re-run `make todo`.
    See: https://olshansky.substack.com/p/move-fast-and-document-things

How:
    1. Enumerate candidate files via `git ls-files` (falls back to a filesystem
       walk outside a git repo), skipping binaries and EXCLUDED_PATHS.
    2. Match `PREFIX:` / `PREFIX(#123, @handle):` but ONLY when the text before
       the marker on that line contains a comment opener — so prose and doc
       tables that merely mention a prefix are not indexed as real work.
    3. Absorb continuation lines (the rest of the comment block), because a good
       TODO states what/why/how and does not fit on one line.
    4. Group hits by prefix, ordered by the urgency ranking in TAXONOMY.
    5. Render a summary table plus one section per prefix, and write TODO.md.

Notes:
    - `NOTE:` is deliberately NOT tracked. It marks an explanation, not work;
      mixing it in turns the list into noise.
    - Annotation syntax `TODO_XXX(#123, @olshansk):` records an issue and/or an
      owner without the overhead of filing a ticket.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_PATH = REPO_ROOT / "TODO.md"

# Files that talk ABOUT the convention, or are themselves generated from it.
# Their prefix mentions are documentation, not work items. Extend per project
# with TODO_EXCLUDE="docs/conventions.md,notes/backlog.md".
EXCLUDED_PATHS = {
    "TODO.md",
    "scripts/gen_todo.py",
    "tests/unit/test_gen_todo.py",
    "makefiles/todo.mk",
    ".agents/AGENTS.md",
} | {p.strip() for p in os.environ.get("TODO_EXCLUDE", "").split(",") if p.strip()}

# Comment openers, by language family. A prefix only counts as a real TODO when
# one of these appears before it on the same line.
COMMENT_OPENERS = ("#", "//", "/*", "*", "<!--", "--", ";")

SKIP_SUFFIXES = {".lock", ".sqlite", ".png", ".jpg", ".jpeg", ".gif", ".pdf", ".ico"}

# A TODO that explains itself spans several comment lines; absorb at most this
# many so one sprawling block cannot swamp the index.
MAX_CONTINUATION_LINES = 6

# Rendered entries are a pointer, not the full text — `file:line` is the link.
MAX_SUMMARY_CHARS = 220


@dataclass(frozen=True)
class Prefix:
    """One TODO prefix and how urgently it should be read."""

    name: str
    severity: str
    meaning: str
    act_when: str


# Ordered most-urgent first; this ordering drives TODO.md section order.
TAXONOMY: tuple[Prefix, ...] = (
    Prefix("FIXME", "🔴", "Known bug", "Now — it is broken today"),
    Prefix("TODO_IN_THIS_PR", "🔴", "Must land in the current PR", "Before merge"),
    Prefix("HACK", "🟠", "Temporary workaround", "Before it bites someone"),
    Prefix("TODO_REMOVE_LATER", "🟠", "Temporary code with an exit condition", "When its condition is met"),
    Prefix("TODO_TECHDEBT", "🟡", "Technical debt", "Next scheduled cleanup"),
    Prefix("TODO_BETA", "🟡", "Required before beta", "Beta gate"),
    Prefix("TODO_PROD", "🟡", "Required before production", "Production gate"),
    Prefix("TODO_OPTIMIZE", "🟡", "Performance improvement", "When a measurement justifies it"),
    Prefix("TODO_IMPROVE", "🟢", "Code quality / refactor", "Opportunistically"),
    Prefix("TODO_CONSIDERATION", "🟢", "Design decision to revisit", "Next design pass"),
    Prefix("TODO_FUTURE", "🟢", "Deferred work, no date", "Someday — convert when touched"),
    Prefix("TODO_IDEA", "🟢", "Speculative enhancement", "Someday, maybe never"),
    Prefix("TODO", "🟢", "General future work", "Someday"),
)

# Longest names first so TODO_TECHDEBT is not matched as bare TODO.
_NAMES = sorted((p.name for p in TAXONOMY), key=len, reverse=True)
MARKER_RE = re.compile(
    r"(?P<prefix>" + "|".join(_NAMES) + r")"
    r"(?:\((?P<annotation>[^)]*)\))?"
    r":\s*(?P<text>.*)"
)


@dataclass(frozen=True)
class Hit:
    """One TODO comment found in the codebase."""

    prefix: str
    path: str
    line: int
    text: str
    issue: str | None
    owner: str | None


def _candidate_files() -> list[Path]:
    """List files to scan, preferring git's index so caches are skipped.

    How:
        1. Ask git for tracked AND untracked-but-not-ignored files. Plain
           `git ls-files` would silently skip a brand-new file, so a TODO in it
           stayed invisible until someone committed — and `--check` passed on an
           incomplete index.
        2. Fall back to a filesystem walk when git is unavailable.
        3. Drop excluded paths and known-binary suffixes.
    """
    try:
        out = subprocess.run(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
        ).stdout
        names = [line for line in out.splitlines() if line]
    except (OSError, subprocess.CalledProcessError):
        names = [
            str(p.relative_to(REPO_ROOT))
            for p in REPO_ROOT.rglob("*")
            if p.is_file() and ".venv" not in p.parts and ".git" not in p.parts
        ]

    files: list[Path] = []
    for name in sorted(names):
        if name in EXCLUDED_PATHS or Path(name).suffix in SKIP_SUFFIXES:
            continue
        path = REPO_ROOT / name
        if path.is_file():
            files.append(path)
    return files


def _is_comment(before: str) -> bool:
    """Return True if the text preceding a marker looks like a comment opener."""
    return any(opener in before for opener in COMMENT_OPENERS)


def _strip_comment_syntax(line: str) -> str | None:
    """Return a comment line's payload, or None if the line is not a continuation.

    A continuation is a comment line that carries text and does not begin a new
    marker — anything else (code, a blank line, a bare `#`) ends the block.
    """
    stripped = line.strip()
    for opener in ("#", "//", "*", "--", ";"):
        if stripped.startswith(opener):
            payload = stripped[len(opener) :].strip()
            payload = re.sub(r"(-->|\*/)\s*$", "", payload).strip()
            if not payload or MARKER_RE.search(payload):
                return None
            return payload
    return None


def _absorb_continuation(lines: list[str], start: int) -> str:
    """Join the comment lines following ``start`` into one string."""
    parts: list[str] = []
    for line in lines[start : start + MAX_CONTINUATION_LINES]:
        payload = _strip_comment_syntax(line)
        if payload is None:
            break
        parts.append(payload)
    return " ".join(parts)


def _parse_annotation(annotation: str | None) -> tuple[str | None, str | None]:
    """Split `#123, @olshansk` into (issue, owner); either may be absent."""
    if not annotation:
        return None, None
    issue = owner = None
    for part in annotation.split(","):
        part = part.strip()
        if part.startswith("#"):
            issue = part
        elif part.startswith("@"):
            owner = part
    return issue, owner


def collect_hits() -> list[Hit]:
    """Scan every candidate file and return the TODO comments it contains."""
    hits: list[Hit] = []
    for path in _candidate_files():
        try:
            content = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        rel = str(path.relative_to(REPO_ROOT))
        file_lines = content.splitlines()
        for lineno, line in enumerate(file_lines, start=1):
            match = MARKER_RE.search(line)
            if match is None or not _is_comment(line[: match.start()]):
                continue
            issue, owner = _parse_annotation(match.group("annotation"))
            head = re.sub(r"(-->|\*/)\s*$", "", match.group("text")).strip()
            rest = _absorb_continuation(file_lines, lineno)
            text = " ".join(part for part in (head, rest) if part) or "(no description)"
            text = re.sub(r"\s+", " ", text)
            if len(text) > MAX_SUMMARY_CHARS:
                text = text[:MAX_SUMMARY_CHARS].rstrip() + "…"
            hits.append(
                Hit(
                    prefix=match.group("prefix"),
                    path=rel,
                    line=lineno,
                    text=text,
                    issue=issue,
                    owner=owner,
                )
            )
    return hits


def render(hits: list[Hit]) -> str:
    """Render the TODO.md body: summary table, then one section per prefix."""
    by_prefix: dict[str, list[Hit]] = {}
    for hit in hits:
        by_prefix.setdefault(hit.prefix, []).append(hit)

    lines: list[str] = [
        "# TODO <!-- omit in toc -->",
        "",
        "> 🤖 Generated by `make todo` — **do not edit by hand.**",
        "> The code is the source of truth; this file is only a view over it.",
        "> Rationale: [Move Fast & Document Things]"
        "(https://olshansky.substack.com/p/move-fast-and-document-things).",
        "",
        f"**{len(hits)} open item(s)** across {len({h.path for h in hits})} file(s).",
        "",
        "## Summary",
        "",
        "| # | Severity | Prefix | Count | Meaning | Act when |",
        "| --- | --- | --- | --- | --- | --- |",
    ]

    row = 0
    for prefix in TAXONOMY:
        found = by_prefix.get(prefix.name, [])
        if not found:
            continue
        row += 1
        anchor = prefix.name.lower().replace("_", "-")
        lines.append(
            f"| {row} | {prefix.severity} | [`{prefix.name}`](#{anchor}) "
            f"| {len(found)} | {prefix.meaning} | {prefix.act_when} |"
        )

    if row == 0:
        lines += ["| 1 | 🟢 | — | 0 | Nothing tracked | No action needed |"]

    lines += ["", "## Items", ""]

    if not hits:
        lines += ["🟢 No open TODOs. Add one next to the code it concerns.", ""]

    for prefix in TAXONOMY:
        found = sorted(by_prefix.get(prefix.name, []), key=lambda h: (h.path, h.line))
        if not found:
            continue
        lines += [f"### {prefix.severity} {prefix.name} ({len(found)})", ""]
        for hit in found:
            suffix = ""
            if hit.issue or hit.owner:
                tags = " ".join(t for t in (hit.issue, hit.owner) if t)
                suffix = f" — _{tags}_"
            lines.append(f"- `{hit.path}:{hit.line}` — {hit.text}{suffix}")
        lines.append("")

    lines += [
        "## Adding a TODO",
        "",
        "- Put it **next to the code it concerns**, never only here.",
        "- Syntax: `PREFIX: what and why` — optionally `PREFIX(#123, @handle): ...`.",
        "- Say what to do and why it is deferred; a bare `TODO: fix this` helps nobody.",
        "- Filing a TODO is cheaper than filing a ticket — that is the point.",
        "- `NOTE:` is not tracked here; it marks an explanation, not work.",
        "",
        "```bash",
        "make todo          # regenerate this file",
        "make todo-check    # fail if this file is stale (CI)",
        'grep -rn "TODO_PROD" .   # ad-hoc filtering, no tooling required',
        "```",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    """Write TODO.md, or verify it is current when called with --check."""
    parser = argparse.ArgumentParser(description="Generate TODO.md from code comments.")
    parser.add_argument(
        "--check",
        action="store_true",
        help="exit non-zero if TODO.md differs from what would be generated",
    )
    args = parser.parse_args()

    hits = collect_hits()
    rendered = render(hits)

    if args.check:
        current = OUTPUT_PATH.read_text(encoding="utf-8") if OUTPUT_PATH.exists() else ""
        if current != rendered:
            print("🚨 TODO.md is stale — run 'make todo' and commit the result.")
            return 1
        print(f"✅ TODO.md is current ({len(hits)} item(s)).")
        return 0

    OUTPUT_PATH.write_text(rendered, encoding="utf-8")
    print(f"✅ Wrote {OUTPUT_PATH.relative_to(REPO_ROOT)} — {len(hits)} item(s).")
    for prefix in TAXONOMY:
        count = sum(1 for hit in hits if hit.prefix == prefix.name)
        if count:
            print(f"   {prefix.severity} {prefix.name}: {count}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
