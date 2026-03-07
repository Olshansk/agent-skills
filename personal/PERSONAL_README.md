# Agent Skills <!-- omit in toc -->

Reusable skills for Claude Code, Gemini, and Codex.

- [Architecture](#architecture)
- [Local Development](#local-development)
- [Makefile Targets](#makefile-targets)

## Architecture

Three repos and one third-party directory work together:

| Location | What it holds | Role |
|----------|--------------|------|
| `~/workspace/agent-skills/` (this repo) | `skills/` — 19 reusable skills | **SoT for skills** |
| `~/workspace/configs/agents/` | `AGENTS.md`, `MEMORIES.md` | **SoT for agent instructions** |
| `~/.agents/skills/` | Third-party skills (find-skills, vercel-*, etc.) | Managed by `skills.sh` |
| `~/workspace/agent-skills/configs/` | Snapshots of tool configs | Read-only reference (not SoT) |

### Skills — symlink flow

Every agent tool directory symlinks directly to this repo (single hop):

```
~/workspace/agent-skills/skills/cmd-foo/SKILL.md     ← source of truth
    ↑
    ├── ~/.claude/skills/cmd-foo
    ├── ~/.gemini/antigravity/skills/cmd-foo
    └── ~/.codex/skills/cmd-foo
```

Third-party skills symlink separately to `~/.agents/skills/` — this repo doesn't manage those.

### Agent instructions — symlink flow

Agent instruction files live in a separate repo and are already symlinked:

```
~/workspace/configs/agents/AGENTS.md    ← source of truth
    ↑
    ├── ~/.claude/CLAUDE.md
    └── ~/.codex/AGENTS.md

~/workspace/configs/agents/MEMORIES.md  ← source of truth
    ↑
    └── ~/.gemini/GEMINI.md
```

### Configs snapshots

`configs/` in this repo contains read-only copies of tool configs, synced via `make sync-all`. These are for reference and git history — not the live SoT. See [`configs/README.md`](configs/README.md).

## Local Development

Manage symlinks to your agents (Claude, Gemini, Codex) from this single source of truth:

```bash
# Link all skills to Claude only
make link-skills

# Share across all agents (Gemini, Codex, Claude)
make setup
```

## Makefile Targets

| Target              | Description                                                           |
| ------------------- | --------------------------------------------------------------------- |
| `make setup`        | First-time setup: replace real dirs with repo symlinks for all agents |
| `make link-skills`  | Symlink repo skills into `~/.claude/skills/`                          |
| `make share-skills` | Symlink repo skills into Gemini and Codex                             |
| `make list-skills`  | List all skills with descriptions                                     |
| `make sync-all`     | Sync all tool configs into `personal/configs/`                        |
| `make test`         | Validate skill frontmatter and repo consistency                       |
| `make status`       | Show repository status                                                |
