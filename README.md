# agent-skills <!-- omit in toc -->

[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-00A67E)](#)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-D27656)](#)
[![Gemini CLI](https://img.shields.io/badge/Gemini%20CLI-678AE3)](#)
[![OpenCode](https://img.shields.io/badge/OpenCode-3B82F6)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)

Multi-skill catalog for agentic CLIs by [Daniel Olshansky](https://olshansky.info).

- Follows the [Agent Skills](https://agentskills.io/home) pattern for cross-tool skill distribution
- Inspired by [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)

## Table of Contents <!-- omit in toc -->

- [Quickstart](#quickstart)
- [Available Skills](#available-skills)
  - [Session Commit](#session-commit)
- [Skills Dashboard](#skills-dashboard)
- [Star History](#star-history)

## Quickstart

```bash
npx skills add olshansk/agent-skills
```

Then ask your agent to run any installed skill (e.g., "close the loop", "generate skills dashboard").

## Available Skills

### Polished Skills

Official distribution skills for public use.

| Skill | What it does | Trigger examples |
| --- | --- | --- |
| [`session-commit`](skills/session-commit/SKILL.md) | Captures session learnings and updates `AGENTS.md` safely | "run session commit", "close the loop", "update AGENTS.md" |
| [`skills-dashboard`](skills/skills-dashboard/SKILL.md) | Scrapes skills.sh and generates an interactive HTML dashboard | "generate skills dashboard", "show skills ecosystem" |

### Personal Skills (`cmd-*`)

Personal productivity skills, mostly for use as slash commands. These are not intended for public distribution but are consolidated here for easy management.

| Skill | Description |
|-------|-------------|
| `cmd-chain-halt-code-reviewer` | Review protocol code for chain halt risks and non-determinism |
| `cmd-clean-code` | Improve code readability using idiomatic best practices |
| `cmd-code-cleanup` | Remove dead code and duplication pragmatically |
| `cmd-code-review-sweep` | Review changes for test gaps and naming consistency |
| `cmd-gh-issue` | Create GitHub issues from conversation context |
| `cmd-idiot-proof-docs` | Simplify documentation for clarity and scannability |
| `cmd-mermaid-diagram` | Generate and edit Mermaid flowcharts and diagrams |
| `cmd-pr-build-context` | Build high-signal PR context for review |
| `cmd-pr-conflict-resolver` | Resolve merge conflicts systematically |
| `cmd-pr-description` | Generate concise PR descriptions from diffs |
| `cmd-pr-review-prepare` | Prepare branch for code review |
| `cmd-pr-test-plan` | Generate manual test plans for PR changes |
| `cmd-productionize` | Transform applications into production-ready deployments |
| `cmd-python-stylizer` | Analyze and improve Python code style |
| `cmd-rfc-review` | Review RFCs using the SCQA framework |
| `cmd-rss-feed-generator` | Generate Python RSS feed scrapers |
| `cmd-scope-sweep` | Final pass for missed items before closing scope |
| `debug-timeouts` | Analyze and debug timeout hierarchies |
| `makefile` | Create or improve Makefiles with templates |

## Local Development

Manage symlinks to your agents (Claude, Gemini, Codex) from this single source of truth:

```bash
# Link all skills to Claude only
make link-skills

# Share across all agents (Gemini, Codex, Claude)
make setup
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make setup` | First-time setup: replace real dirs with repo symlinks for all agents |
| `make link-skills` | Symlink repo skills into `~/.claude/skills/` |
| `make share-skills` | Symlink repo skills into Gemini and Codex |
| `make list-skills` | List all skills with descriptions |
| `make sync-all` | Sync all tool configs into `personal/configs/` |
| `make test` | Validate skill frontmatter and repo consistency |
| `make status` | Show repository status |

### Session Commit

> [!TIP]
> Start with [`session-commit`](skills/session-commit/SKILL.md) — it turns every coding session into durable knowledge by extracting patterns, decisions, and gotchas into your `AGENTS.md`. Future sessions (and future agents) pick up right where you left off.

## Skills Dashboard

A live dashboard of the skills.sh ecosystem is available at **[skills-dashboard.olshansky.info](https://skills-dashboard.olshansky.info/)**.

It shows publisher distribution, install counts, top skills, and the long-tail power law of adoption. Regenerate it yourself with the `skills-dashboard` skill.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=olshansk/agent-skills&type=date&legend=top-left)](https://www.star-history.com/#olshansk/agent-skills&type=date&legend=top-left)
