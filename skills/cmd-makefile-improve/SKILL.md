---
name: cmd-makefile-improve
description: "Review a repository's Makefile foundation and propose approval-gated improvements to its helpers, templates, tests, and documentation. Use when iterating on Makefile conventions or the cmd-makefile skill itself."
---

# Makefile Foundation Review

Review the current repository's Makefile foundation, then recommend a small, high-quality next iteration. This is a review-and-proposal skill: do not modify files, commit, install dependencies, or publish anything until the user explicitly approves the proposed changes.

When invoked in `/Users/olshansky/workspace/agent-skills`, the primary implementation target is `skills/cmd-makefile/` and its templates/modules. In any other repository, target that repository's Makefile, helper directory, templates, tests, and documentation instead.

## Operating contract

1. Inspect first; infer nothing from filenames alone.
2. Ask one concise batch of questions after discovery when choices materially affect the recommendation.
3. Report evidence, proposed changes, and tradeoffs before editing.
4. Wait for explicit approval. “Looks good” or “go ahead” approves the presented scope; new or materially broader work needs a new proposal.
5. After approval, make only the approved changes and verify them. If approval is not given, leave the worktree unchanged.

Do not treat a clean worktree as permission to edit. Do not automatically update generated dashboards, symlinks, installed skills, remote repositories, or unrelated files.

## Discovery pass

Use the repository's documented workflow first. Read `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, and any tool-specific instruction files that apply. Check `make help` before suggesting raw commands when a Makefile exists.

Capture these four evidence groups:

### 1. Current worktree

- `git status --short --branch`
- `git diff --` for unstaged tracked changes
- `git diff --cached --` for staged changes
- Contents of relevant untracked files, without broadening beyond the repository

Describe what is already in progress and preserve unrelated changes.

### 2. Recent history

Read the last one or two commits with `git log -2 --stat --oneline` and inspect relevant patches with `git show`. Look for patterns the repository has recently adopted or intentionally removed. Do not propose reverting a recent decision without explaining the evidence.

### 3. Makefile foundation

Locate and read:

- Root `Makefile` and included `makefiles/*.mk` or equivalent helper files.
- Template directories and shared modules.
- Scripts invoked by Make targets.
- Tests, CI workflows, and docs that treat Make targets as a command contract.
- Relevant history for Makefile/helper paths, not only the latest repository commits.

Trace public targets to their recipes and dependencies. Check for duplicated logic, hidden write paths, stale docs, inconsistent naming, unsafe shell behavior, missing preflight checks, environment precedence bugs, poor help output, and verification gaps.

For this repository specifically, also inspect `skills/cmd-makefile/SKILL.md`, `skills/cmd-makefile/reference.md`, `skills/cmd-makefile/modules/`, and every applicable file under `skills/cmd-makefile/templates/` before suggesting changes to the skill foundation.

### 4. Repository-specific best practices

Identify the stack from actual files and commands: for example Swift/Xcode, FastAPI/uv, Node, Go, Flutter, Electron, a static site, or a database-backed service. Read the repository's own conventions before applying generic advice.

When local evidence is insufficient or the recommendation depends on a changing toolchain, consult authoritative current documentation for that stack. Prefer official documentation and primary sources. State which guidance is a local convention, which is official guidance, and which is an informed recommendation.

## Questions

Ask only questions whose answers would change the proposal. Ask them in one batch after discovery, normally no more than five:

- Is the intended scope the current repository only, the reusable `cmd-makefile` foundation, or both?
- Should the next iteration prioritize code structure, helpers/tools, regression testing, docs/references, or Makefile helpers?
- Should compatibility aliases remain, or may obsolete targets and templates be removed?
- Is modularization appropriate for this repository's current size and expected growth?
- Are there constraints on supported platforms, shells, CI, or external tools?

Skip questions answered by the repository or by the user's request. If no answer is needed, proceed with clearly labeled assumptions.

## Proposal format

Lead with the recommendation. Then provide:

1. **Evidence** — worktree state, recent commits, relevant helper/template paths, and stack-specific guidance.
2. **Foundation assessment** — what is strong, what is duplicated, what is missing, and what should remain untouched.
3. **Proposed file plan** — one row per file, with action (`add`, `edit`, `remove`, or `split`), exact responsibility, and reason. Keep the user's long-term categories in separate files:
   - code structure
   - helpers and tools
   - regression testing and verification
   - docs and references
   - Makefile helpers
4. **Prioritized changes** — use `🔴`, `🟠`, `🟡`, `🟢`, or `✅` severity/status and distinguish required, recommended, and optional work.
5. **Risks and compatibility** — target renames, callers, CI, generated artifacts, shell/platform assumptions, and migration steps.
6. **Verification plan** — exact project-native checks, including dry runs and focused tests where appropriate.
7. **Approval request** — ask the user to approve the exact scope, or identify which proposal rows to apply.

Do not present an unverified claim as a fact. If a check could not run, say why and mark the resulting uncertainty.

## Approval and implementation

Only after explicit approval:

- Edit the smallest set of files that implements the approved proposal.
- Preserve unrelated worktree changes and inspect the diff before any generated-file update.
- Carry forward all Makefile write paths, prerequisites, environment handling, and compatibility behavior unless removal was approved.
- Keep reusable templates and helper modules in separate files with one clear responsibility each.
- Update README/catalog metadata when a skill or public template changes, as required by the repository's instructions.
- Run `git diff --check`, the project's documented checks, and focused Makefile validation such as `make help`, `make help-unclassified`, and relevant `make -n` dry runs.
- Report exactly what changed, what passed, what was not run, and any remaining review item.

Never commit or push as part of this skill unless the user separately asks for that after implementation.
