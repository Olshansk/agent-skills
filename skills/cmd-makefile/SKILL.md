---
name: cmd-makefile
description: "Create or improve Makefiles with minimal complexity. Templates available: base, python-uv, python-fastapi, postgres, nodejs, go, chrome-extension, flutter, electron, static-site."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Makefile Helper

Create Makefiles that are simple, discoverable, and maintainable.

## Core Principles

1. **Default to rich help** - Use categorized help with emoji headers unless user requests minimal
2. **Default Chrome extensions to modular** - Use the modular `makefiles/*.mk` layout with shared colors/help for Chrome extension projects unless the repo is truly tiny
3. **Ask about structure upfront** - For new Makefiles, ask: "Flat or modular? Rich help or minimal?"
4. **Follow existing conventions** - Match the project's style if Makefile already exists
5. **Don't over-engineer** - Solve the immediate need, not hypothetical futures
6. **Use `uv run`** - Always run Python commands via `uv run` for venv context
7. **Explain decisions** - If choosing flat/minimal, explain why before generating

## When to Use This Skill

- Creating a new Makefile for a project
- Adding specific targets to an existing Makefile
- Improving/refactoring an existing Makefile
- Setting up CI/CD make targets
- Distributing pre-built binaries via GitHub Releases

## Quick Start

For new projects, use the appropriate template:

| Project Type | Template | Complexity | Asks upfront |
|-------------|----------|------------|------|
| Any project | `templates/base.mk` | Minimal | — |
| Python with uv | `templates/python-uv.mk` | Standard | — |
| Python FastAPI | `templates/python-fastapi.mk` | Full-featured | test split? prod target? `HEALTH_PATH`? |
| PostgreSQL + Alembic | `templates/postgres.mk` | Standard | `PG_PORT` (5433 default)? soft vs HARD reset? |
| Node.js | `templates/nodejs.mk` | Standard | — |
| Go | `templates/go.mk` | Standard | — |
| Chrome Extension | `templates/chrome-extension.mk` | Modular | — |
| Flutter App | `templates/flutter.mk` | Modular | — |
| Electron App | `templates/electron.mk` | Modular | — |
| Static Site (HTML/CSS/JS) | `templates/static-site.mk` | Standard | `DEPLOY_MODE` (rsync/gh-pages/netlify/vercel/none)? |

For templates in the "Asks upfront" column, run the Phase 2 interactive questions in §"Interaction Pattern" before scaffolding. Companion files:

- `templates/python-fastapi-env/.template.env` → project's `.template.env`
- `templates/python-fastapi-scripts/export_openapi_spec.py` → `scripts/export_openapi_spec.py`
- `templates/postgres-env/.template.env` → merge into project's `.template.env` (don't ship two)

### Chrome Extension Structure

The chrome extension template uses a modular structure:

```
Makefile                              # Main file with help + includes
makefiles/
  colors.mk                           # ANSI colors & print helpers
  common.mk                           # Shell flags, VERBOSE mode, guards
  build.mk                            # Build zip, version bump, releases
  dev.mk                              # Lint, clean, install
  test.mk                             # Unit tests, E2E tests, coverage
  env.mk                              # Environment setup, dependency checks
```

Copy from `templates/chrome-extension-modules/` to your project's `makefiles/` directory.

**Key features:**
- Use `makefiles/colors.mk` for ANSI color output and header helpers.
- Use `makefiles/common.mk` for shell flags, guard rails, and shared variables.
- Use `makefiles/env.mk` for environment checks and dependency sanity.
- Use `makefiles/build.mk` for build/package/release targets.
- Use `makefiles/dev.mk` for install, watch, clean, and other local workflows.
- Use `makefiles/test.mk` for typecheck, unit, and E2E targets when present.
- `build-release` - Version bump menu (major/minor/patch) + zip for Chrome Web Store
- `build-beta` - (Optional) GitHub releases with `gh` CLI
- `test-unit` / `test-e2e` - Vitest + Playwright testing
- `test-unit-<module>` / `test-e2e-<module>` - Per-module test targets
- `VERBOSE=1 make <target>` - Show commands for debugging

### Flutter App Structure

```
Makefile                    # Main file with help + includes
makefiles/
  colors.mk                # ANSI colors & print helpers
  common.mk                # Shell flags, VERBOSE mode, guards
  dev.mk                   # Setup, run simulator/device, devices, clean
  build.mk                 # iOS/Android builds (IPA, APK, AAB)
  deploy.mk                # TestFlight upload
  lint.mk                  # Dart analyze & format
```

Copy from `templates/flutter-modules/` to your project's `makefiles/` directory.

**Key features:**
- `flutter-run-ios` auto-boots simulator and waits for it
- `flutter-run-android` auto-launches emulator and waits for it
- `flutter-run-device` auto-detects or uses `FLUTTER_IOS_DEVICE` / `FLUTTER_ANDROID_DEVICE`
- `flutter-build-ipa` + `flutter-export-ipa` + `flutter-deploy-testflight` full iOS release workflow
- `flutter-export-ipa` re-exports IPA from existing archive without rebuilding
- `_check-asc-app` pre-flight App Store Connect validation (with ASC_API_KEY/ASC_API_ISSUER)
- `flutter-lint FIX=true` Dart formatting with FIX pattern
- `VERBOSE=1 make <target>` show commands for debugging

### Electron App Structure

```
Makefile                    # Main file with help + includes
makefiles/
  colors.mk                # ANSI colors & print helpers
  common.mk                # Shell flags, VERBOSE mode, guards
  dev.mk                   # Setup, dev server, debug, clean
  build.mk                 # Pack-check, dist (mac/win/linux), publish
  lint.mk                  # ESLint, Prettier, TypeScript, tests
```

Copy from `templates/electron-modules/` to your project's `makefiles/` directory.

**Key features:**
- `electron-dev` starts dev mode with hot-reload
- `electron-debug` launches with DevTools open
- `electron-clean` single target that removes artifacts, node_modules, and lock file
- `electron-pack-check` smoke-tests that the app loads without errors
- `electron-dist-mac` / `electron-dist-win` / `electron-dist-linux` cross-platform builds
- `electron-dist-all` builds for all platforms in one shot
- `electron-publish` publishes to GitHub Releases (requires `GH_TOKEN`)
- `electron-lint FIX=true` ESLint + Prettier with auto-fix pattern
- `electron-typecheck` TypeScript type checking
- `VERBOSE=1 make <target>` show commands for debugging

### Static Site (HTML/CSS/JS)

Plain static sites — landing pages, marketing pages, docs — with no bundler or SSR. Uses `npx --yes` for tooling so contributors don't need a local `package.json` or `node_modules`.

Copy `templates/static-site.mk` to your project root as `Makefile`.

Targets use `site-*` and `dev-*` prefixes (per §"Naming Conventions"). The template is deliberately slim — lint/link-check/image-optimization targets were cut because they're rarely run locally on a marketing page and collapse under the "too many granular `dev-*` quality targets" pitfall. Add them back only if a specific project needs them.

**Key features:**
- `site-serve` - local HTTP server via `python3 -m http.server` (falls back to `npx serve`). Override with `make site-serve PORT=9000 HOST=0.0.0.0`.
- `site-open` - open `$(ENTRY)` (default `index.html`) in the default browser (macOS `open` / Linux `xdg-open`).
- `site-status` - print site dir, entry, detected HTML pages, and tooling availability.
- `dev-format` - prettier `--write` across HTML/CSS/JS via `npx --yes`. No global install required, no `FIX=true` gate — always writes (formatting check-only is CI's job, not a local ergonomic).
- `dev-asset-report` - top 20 largest files (finds accidentally-committed hero images, uncompressed GIFs).
- `dev-build` - copies site into `$(BUILD_DIR)` (default `dist/`) via rsync with sensible excludes, then optionally minifies HTML/CSS/JS via `html-minifier-terser` (silently skipped if unavailable).
- `dev-deploy` - depends on `dev-build`; dispatches on `DEPLOY_MODE` (`rsync` | `gh-pages` | `netlify` | `vercel` | `none`). Fails fast with install hint if the selected tool is missing.
- `dev-clean` - removes `$(BUILD_DIR)/`.

**Config knobs (`?=` — override on command line):** `SITE_DIR`, `PORT`, `HOST`, `ENTRY`, `BUILD_DIR`, `DEPLOY_MODE`, `RSYNC_DEST`.

### PostgreSQL + Alembic

Standalone template for database operations. Use alongside `python-fastapi.mk` for a full stack, or independently for any Python project with PostgreSQL.

Copy `templates/postgres.mk` to your project root (or `include` it from your main Makefile).

**Key features:**
- `db-start` / `db-stop` / `db-clean` via plain `docker run` (default) with health-check wait loop. Docker Compose variant is commented at the bottom of the template for multi-service setups.
- `db-init` composite target (start + migrate).
- `db-reset` has two flavors via `HARD` flag:
  - `HARD=false` (default): kill connections → DROP DATABASE → CREATE → migrate. Fast, preserves container+volume.
  - `HARD=true`: `docker rm -f` container + `docker volume rm -f` + re-init. Use when container/volume itself is in a broken state.
- `db-migrate` / `db-revision` Alembic migrations via `uv run alembic`; **all Alembic recipes inline-source `.env`** (via `_check-env` guard) so a stale shell `DATABASE_URL` can't override the configured value.
- `db-migration-current` / `db-migration-history` / `db-migration-check` introspection.
- `db-shell` (psql) / `db-pgcli` / `db-pgweb` shell access.
- `db-pgcli` strips the SQLAlchemy `+psycopg` dialect marker before handing the URL to pgcli (pgcli doesn't understand dialect markers).
- `env-template` bootstrap target that copies `.template.env` → `.env` without overwriting.
- `db-logs` / `db-seed` utilities.
- All config via `?=` variables (`PG_CONTAINER`, `PG_DB`, `PG_USER`, `PG_PASSWORD`, `PG_PORT=5433`, `PG_IMAGE`).
- **Port 5433 by default** to dodge host Homebrew Postgres on 5432. Override with `make db-start PG_PORT=5432` if your machine is clean.
- **Driver**: template targets `psycopg[binary]>=3` (psycopg3). SQLAlchemy needs the `postgresql+psycopg://` dialect marker; add a pydantic-settings validator that normalizes `postgres://` / `postgresql://` → `postgresql+psycopg://` so Render's managed DB URL works verbatim.

## Interaction Pattern (Phased)

Run these phases top-to-bottom on any Makefile scaffolding / refactor request. Do **Phase 2 (Interactive questions) BEFORE writing any file** — the answers drive which template variants to emit.

### Phase 1 — Discovery

1. Is there already a Makefile? Read it first — match its conventions.
2. What stack / language? (Python+uv, FastAPI+Postgres, Node, Go, …)
3. What's the deployment target? (Render, Fly, Vercel, self-hosted, …) — affects `run-api-prod`.
4. How big is the project today, and how big will it reasonably grow? (≥5 targets expected → modular.)

### Phase 2 — Interactive questions (ask in ONE batch via `AskUserQuestion`)

Ask up front rather than iterating. Typical questions:

- **Structure**: flat single file or modular (`makefiles/*.mk`)?
- **Help style**: rich categorized help with emoji headers, or minimal?
- **Postgres port** (if Postgres used): `5433` (default, dodges host Homebrew Postgres on 5432) or `5432`?
- **Test granularity**: single `dev-test` (small/medium projects) or split `test-unit` / `test-integration` / `test-e2e` (larger projects)?
- **Prod runtime**: need a `run-api-prod` target against a remote DB (Render/Fly/etc.)?
- **OpenAPI spec export** (FastAPI): always include `api-export-spec` unless user declines — enables client SDK generation and spec-diff in CI.

Skip questions whose answer is already implied by an existing Makefile or strong project signal.

### Phase 3 — Scaffold

Emit (in this order):

1. `Makefile` + `makefiles/*.mk` (if modular).
2. `.template.env` at repo root (committed).
3. `.env` is **NOT** created — leave that to `make env-template`. Add `.env` to `.gitignore` if not already there.
4. `.env.prod` — if `run-api-prod` was requested, confirm `.env.prod` is in `.gitignore` (it MUST be — production credentials).
5. `scripts/export_openapi_spec.py` (if FastAPI + api-export-spec).

### Phase 4 — Verify

- `make help` — clean categorized output.
- `make help-unclassified` — should be empty or minimal.
- `make -n run-api-local db-migrate api-export-spec` — dry-run the critical paths.
- Grep for any `_check-env` / `_check-postgres` guards you added to confirm they fire when expected.

## Naming Conventions

Use **kebab-case** with consistent prefix-based grouping:

```makefile
# Good - consistent prefixes (hyphens, not underscores)
build-release, build-zip, build-clean    # Build tasks
dev-run, dev-clean                       # Development tasks
db-start, db-stop, db-migrate            # Database tasks
env-local, env-prod, env-show            # Environment tasks

# Internal targets - prefix with underscore to hide from help
_build-zip-internal, _prompt-version     # Not shown in make help

# Bad - inconsistent
run-dev, localEnv, test_net
build_release, dev_test                  # Underscores - don't use
```

**Exception — universal unprefixed names.** A handful of names are so de-facto standard across ecosystems (npm, cargo, go, make itself) that prefixing them with `dev-` adds noise without adding signal. Keep these unprefixed:

- `test` (not `dev-test`)
- `build` (not `dev-build`) — **only if** the project has no competing `build-*` group
- `run` (not `dev-run`) — same caveat
- `format` / `lint` — same caveat; if you have `dev-format` already, stay consistent within the project

Rule of thumb: if the unprefixed name would collide with a prefix group you already have (e.g., already have `build-release`, `build-zip`), keep the `dev-` prefix for consistency. Otherwise, drop it.

**Name targets after the action, not the tool:**
```makefile
# Good - describes what it does
remove-bg          # Removes background from image
format-code        # Formats code
lint-check         # Runs linting

# Bad - names the tool
rembg              # What does this do?
prettier           # Is this running prettier or configuring it?
eslint             # Unclear
```

## Key Patterns

### Binary Distribution

For projects distributed as pre-built binaries via GitHub Releases:

```makefile
GITHUB_REPO ?= owner/repo
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

.PHONY: install-cli
install-cli: ## Download and install CLI from latest GitHub release
	@RELEASE=$$(curl -fsSL https://api.github.com/repos/$(GITHUB_REPO)/releases/latest | grep tag_name | cut -d'"' -f4); \
	echo "Installing $$RELEASE for $(OS)/$(ARCH)..."; \
	curl -fsSL -o ~/.local/bin/cli \
		"https://github.com/$(GITHUB_REPO)/releases/download/$$RELEASE/cli-$(OS)-$(ARCH)"; \
	chmod +x ~/.local/bin/cli
```

**Key considerations:**
- Detect OS and architecture automatically
- Download from GitHub Releases (no Python/uv required)
- Install to `~/.local/bin` (user-writable, in PATH)
- Preserve existing config files during updates

### Always Use `uv run` for Python

```makefile
# Good - uses uv run with ruff (modern tooling)
dev-check:
	uv run ruff check src/ tests/
	uv run ruff format --check src/ tests/
	uv run mypy src/

dev-format:
	uv run ruff check --fix src/ tests/
	uv run ruff format src/ tests/

# Bad - relies on manual venv activation
dev-format:
	ruff format .
```

### Use `uv sync` (not pip install)

For Python projects, treat `pyproject.toml` and `uv.lock` as the source of truth.
Do not add `pip install` or `requirements.txt` fallback guidance to uv-based templates.

```makefile
env-install:
	uv sync  # Uses pyproject.toml + lock file
```

### Categorized Help (for 5+ targets)

Help is **generated**, never hand-written. Declare a section with `##@`, document
targets with `##`, and the renderer does the rest — see [Help System](#help-system).

```makefile
##@ 🚀 API

api-run: ## Start server on port `$(PORT)` (`uvicorn --reload`)
api-run-prod: ## Start without reload, binds `0.0.0.0` (⚠️ PROD)
```

**Makefile ordering rule - help targets go LAST, just before catch-all:**

1. Configuration (`?=` variables)
2. `HELP_*` configuration (`HELP_TITLE`, `HELP_ICON`, `HELP_VARS`, …)
3. Imports (`include ./makefiles/*.mk`) — **include order IS help section order**
4. Main targets (grouped by function, each group under a `##@` header)
5. `help:` and `help-unclassified:` targets (or `include ./makefiles/help.mk`)
6. Catch-all `%:` rule (absolute last)

### Preflight Checks

```makefile
_check-docker:
	@docker info >/dev/null 2>&1 || { echo "Docker not running"; exit 1; }

db-start: _check-docker  # Runs check first
	docker compose up -d
```

### External Tool Dependencies

When a target requires an external tool (not a system service):

- **Don't create public install targets** (no `make install-foo`)
- **Use internal check as dependency** (prefix with `_`, no `##` comment)
- **Show install command on failure** - tell user what to run, don't do it for them

```makefile
# Internal check - hidden from help (no ##)
_check-rembg:
	@command -v rembg >/dev/null 2>&1 || { \
		printf "$(RED)$(CROSS) rembg not installed$(RESET)\n"; \
		printf "$(YELLOW)Run: uv tool install \"rembg[cli]\"$(RESET)\n"; \
		exit 1; \
	}

# Public target - uses check as dependency
.PHONY: remove-bg
remove-bg: _check-rembg ## Remove background from image
	rembg i "$(IN)" "$(OUT)"
```

**Key points:**
- Name target after the action (`remove-bg`), not the tool (`rembg`)
- Check runs automatically - user just runs `make remove-bg`
- If tool missing, user sees exactly what command to run

### Env File Loading

**Primary recommendation: inline-source per recipe.** This is the only pattern that *overrides* stale shell-exported vars, which is the pitfall you'll actually hit in practice.

```makefile
# Inline-source: recipe's DATABASE_URL comes from .env, not the user's shell
db-upgrade:
	@set -a && . ./.env && set +a && uv run python -m alembic upgrade head

run-api-local:
	@set -a && . ./.env && set +a && uv run uvicorn app.main:app --reload
```

Per-target override (e.g., test env, prod env):

```makefile
# Allow: E2E_ENV=.test.env make test-e2e
test-e2e:
	@set -a && . "$${E2E_ENV:-.env}" && set +a && uv run pytest tests/e2e/
```

**Secondary (simpler but weaker): top-of-Makefile load.** Fine for projects where no one exports the same vars in their shell. Does **not** override an already-exported shell var — so don't use this for DB URLs or anything that commonly lives in shell profiles.

```makefile
# At top of Makefile, after .DEFAULT_GOAL
-include .env
.EXPORT_ALL_VARIABLES:
```

> ⚠️ **Shell-override footgun.** If a user has `export DATABASE_URL=...` in their `.zshrc` (or manually in the current shell), the `-include` form silently loses: their shell env wins over `.env`. Alembic/uvicorn will hit the wrong DB with zero warning. Use the inline-source pattern for any recipe that depends on a specific `.env` value.

### `.env` / `.template.env` Bootstrap

**Always ship a `.template.env`. Never ship a `.env`.**

- `.template.env` is committed to git. It tracks the *schema* of env vars the project expects — every new env var in code gets a placeholder here in the same PR.
- `.env` is gitignored. Each developer fills in real values locally.
- Every recipe that sources `.env` should preflight-check its existence and print a friendly "run `make env-template`" if missing.
- Ship a `make env-template` target that copies `.template.env` → `.env` but **never overwrites** an existing `.env`.

```makefile
_check-env:
	@if [ ! -f .env ]; then \
		printf "$(RED)$(CROSS) .env not found$(RESET)\n"; \
		printf "$(YELLOW)$(INFO) Run 'make env-template' or 'cp .template.env .env'$(RESET)\n"; \
		exit 1; \
	fi

env-template: ## Create .env from .template.env (safe: never overwrites)
	@if [ -f .env ]; then \
		printf "$(YELLOW)$(INFO) .env already exists — leaving it alone$(RESET)\n"; \
	elif [ ! -f .template.env ]; then \
		printf "$(RED)$(CROSS) .template.env not found$(RESET)\n"; exit 1; \
	else \
		cp .template.env .env; \
		printf "$(GREEN)$(CHECK) Created .env from .template.env — fill in real values$(RESET)\n"; \
	fi

run-api-local: _check-env
	@set -a && . ./.env && set +a && uv run uvicorn app.main:app --reload
```

**Why not just `-include .env` at the top of the Makefile?** See §"Env File Loading" above — `-include` silently loses to already-exported shell vars. The `.template.env` + `_check-env` + inline-source pattern is robust against that footgun AND gives new contributors a one-command bootstrap.

### OpenAPI Spec Export (FastAPI)

Ship a standard `api-export-spec` target whenever you scaffold a FastAPI project. Benefits:

- Enables spec-diff in CI (catch accidental breaking API changes in PRs).
- Unblocks typed client generation (`openapi-typescript`, `datamodel-code-generator`, etc.).
- Gives external consumers a stable URL-less artifact to pin against.

Pair it with `templates/python-fastapi-scripts/export_openapi_spec.py`:

```makefile
api-export-spec: ## Export OpenAPI spec to openapi.json
	uv run python scripts/export_openapi_spec.py
```

```python
# scripts/export_openapi_spec.py
from app.main import app
import json
from pathlib import Path

(Path(__file__).parents[1] / "openapi.json").write_text(
    json.dumps(app.openapi(), indent=2) + "\n"
)
```

### Local vs Prod DB Runs

Apps often need to run the same server against two DBs: local Docker for development, remote prod for debugging/one-off migrations. Split into two explicit targets; never let one be the ambient default.

```makefile
.PHONY: run-api-local run-api-prod

run-api-local: ## Run API against local DB (loads .env, --reload)
	@set -a && . ./.env && set +a && uv run uvicorn app.main:app --reload

run-api-prod: ## Run API against REMOTE prod DB (loads .env.prod)
	@if [ ! -f .env.prod ]; then \
		printf "$(RED)$(CROSS) .env.prod not found$(RESET)\n"; \
		printf "$(YELLOW)Create it locally with the prod DATABASE_URL (gitignored)$(RESET)\n"; \
		exit 1; \
	fi
	@printf "$(RED)$(BOLD)$(WARN)  LOCAL APP -> REMOTE PRODUCTION DB$(RESET)\n"
	@printf "$(YELLOW)Writes hit prod. Ctrl-C within 3s to abort.$(RESET)\n"
	@sleep 3
	@set -a && . ./.env.prod && set +a && uv run uvicorn app.main:app
```

**Rules:**
- `.env.prod` **MUST be gitignored** (production credentials). Add it to `.gitignore` before creating the file.
- Prod target: **no `--reload`** (code changes auto-reloading against prod is a footgun), visible red warning, 3-second sleep so it isn't silent when fired by reflex.
- Preflight: fail fast if `.env.prod` is missing rather than silently falling back to `.env`.
- Same pattern works for `run-worker-local`/`run-worker-prod`, `db-shell-prod` (connect local psql to remote), etc.

### FIX Variable for Check/Format Targets

Use a `FIX` variable to toggle between check-only and auto-fix modes:

```makefile
FIX ?= false

dev-check: ## Run linting and type checks (FIX=false: check only)
	$(call print_section,Running checks)
ifeq ($(FIX),true)
	uv run ruff check --fix src/ tests/
	uv run ruff format src/ tests/
else
	uv run ruff check src/ tests/
	uv run ruff format --check src/ tests/
endif
	uv run mypy src/
	$(call print_success,All checks passed)
```

In help output, show usage:

```makefile
@printf "$(CYAN)%-25s$(RESET) %s\n" "dev-check" "Run linting (FIX=false: check only)"
@printf "%-25s $(GREEN)make dev-check FIX=true$(RESET)  <- auto-fix issues\n" ""
```

### Per-Module Test Targets

For projects with multiple modules or platform adapters, create per-module test targets using tool-specific filtering:

```makefile
# Unit tests - filter by test file
.PHONY: test-unit-auth
test-unit-auth: ## Run auth module unit tests
	$(call print_section,Running auth unit tests)
	$(Q)$(NPM) exec vitest -- run tests/auth.test.js

# E2E tests - filter by grep pattern
.PHONY: test-e2e-checkout
test-e2e-checkout: ## Run checkout E2E tests
	$(call print_section,Running checkout E2E tests)
	$(Q)$(NPM) exec playwright -- test --grep "checkout"
```

**Key points:**
- Use `$(NPM) exec` (not bare `npx`) for consistency with the `$(NPM)` variable
- Unit tests filter by file path, E2E tests filter by `--grep` pattern
- Keep the generic `test-unit` and `test-e2e` targets for running everything
- Put per-module targets in `test.mk`, not `dev.mk`

## When to Modularize

**Default to modular** for any new Makefile with 5+ targets.

**Use flat file only when:**
- Simple scripts or single-purpose tools
- User explicitly requests it
- < 5 targets with no expected growth

Standard modular structure:
```
Makefile              # Config, imports, help, catch-all
makefiles/
  colors.mk          # ANSI colors & print helpers
  common.mk          # Shell flags, VERBOSE, guards
  <domain>.mk        # Actual targets (build.mk, dev.mk, etc.)
```

## Legacy Compatibility

**Default: NO legacy aliases.** Only add when:
- User explicitly requests backwards compatibility
- Existing CI/scripts depend on old names (verify with `rg "make old-name"`)

When legacy IS needed, put them in a clearly marked section AFTER main targets but BEFORE help:

```makefile
############################
### Legacy Target Aliases ##
############################

.PHONY: old-name
old-name: new_name ## (Legacy) Description
```

## Key Rules

- **Always read existing Makefile before changes**
- **Search codebase before renaming targets** (`rg "make old-target"`)
- **Test with `make help` and `make -n target`**
- **Update docs after Makefile changes** - When adding new targets:
  1. Add to `make help` output (in the appropriate section)
  2. Update `CLAUDE.md` if the project has one (document new targets)
  3. Update any other relevant docs (README.md, Agents.md, etc.)
- **Never add targets without clear purpose**
- **No line-specific references** - Avoid patterns like "Makefile:44" in docs/comments; use target names instead
- **Single source of truth** - Config vars defined once in root Makefile, not duplicated in modules
- **Root Makefile = help + imports + catch-all only** - Recipe bodies live in `makefiles/*.mk`. When a recipe leaks into the root file, other contributors copy that pattern and the modular structure drifts back to flat. If `setup`/`status`/whatever lives in root, move it to the most relevant module (e.g., `env.mk`).
- **Help coverage audit** - All targets with `##` must appear in either `make help` or `make help-unclassified`

## Help System

**Help is GENERATED from the makefiles, never hand-maintained.** A hand-written
help block authors every target twice — once as a rule, once as a `printf` — and
the two drift apart the first time someone is in a hurry. Copy
`modules/help.mk` (or the inline block in `templates/base.mk`) and never write a
`printf` per target again.

Two kinds of comment drive the entire output:

```makefile
##@ 🐘 Database & Migrations        # declares a section (emoji lives HERE, only here)

db-migrate: ## Apply migrations (alembic upgrade head)
db-reset: ## Destroy volume, recreate, migrate (⚠️ DESTRUCTIVE)
```

Renders as:

```text
═══ 🐘 Database & Migrations ═══

  db-migrate              Apply migrations (alembic upgrade head)
  db-reset                Destroy volume, recreate, migrate (⚠️ DESTRUCTIVE)
```

### The four rules

1. **Emoji on section headers, NEVER on target lines.** Per-target emoji have
   inconsistent display widths — `⬆️ ♻️ 🖥️ ☁️` (variation-selector emoji) render
   1 cell, `🐘 🚀 📦` render 2 — so the description column jitters line to line
   and the list stops being scannable. One emoji per section can't misalign
   anything below it. This is the single highest-impact readability rule here.
2. **Sections render in file order, files in include order.** The include list in
   the root Makefile IS the help ordering — no alphabetical sort, so `quickstart`
   can actually be first. Include `help.mk` LAST so ❓ Help renders last.
3. **Every `.mk` declares its own `##@` before its targets** (the section resets
   at each file boundary). `make help-unclassified` catches the ones that forgot.
4. **Three color tiers, standard 16-color ANSI** (theme-adaptive — the same file
   must read correctly on light and dark terminals; never pin 256-color values):

   | Tier | Color | Example |
   |---|---|---|
   | Section header | `$(BOLD)$(BLUE)` | `═══ 🐘 Database & Migrations ═══` |
   | Target name | `$(CYAN)` | `db-migrate` |
   | Description prose | default fg | `Apply migrations`, `(needs db + redis)` |
   | Inline literal | `$(GREEN)` | `` `alembic upgrade head` ``, `` `openapi.json` `` |
   | Secondary detail | `$(DIM)` | `# uv sync --all-extras` |
   | Inline danger | `$(YELLOW)` | `(⚠️ DESTRUCTIVE)` |

   **Headers and target names must never share a hue.** Two hierarchy levels in
   one apparent color flattens the list into an unscannable wall — this is the
   most common failure mode in real Makefiles. Avoid `$(BOLD)$(MAGENTA)` (reads
   purple, clashes with most themes); bold-with-no-color gets lost entirely.

### Banner

**ASCII box title with a project-branded emoji on the right.** The box anchors the top of `make help`; the right-side emoji gives the project a glanceable identity (leaf/herb for Grove, rocket for an SDK, lock for a security tool, etc.). Keep the emoji on the right — left-side placement crowds the title text.

The renderer computes the box from `HELP_TITLE` / `HELP_ICON` / `HELP_WIDTH`, so
it stays square when the project is renamed:

```makefile
HELP_TITLE   ?= Grove App — Make Targets   # text only, no emoji (see below)
HELP_ICON    ?= 🌿
HELP_TAGLINE ?= Every command runs via uv.
HELP_WIDTH   ?= 46
```

> ⚠️ **Emoji width gotcha.** Most emojis render as 2 terminal columns but count as 1 char, so padding computed from string length comes out short. The renderer budgets exactly 2 cells for `HELP_ICON` — keep emoji OUT of `HELP_TITLE` or the right `║` will not line up.

### Expanding make vars in descriptions

`awk` reads raw file text, so make never expands `$(PORT)` inside a `## ` comment
— help would print the literal `$(PORT)`. List such vars in `HELP_VARS` and they
are substituted at render time:

```makefile
HELP_VARS ?= PORT HEALTH_PATH

api-health: ## Check API health endpoint ($(HEALTH_PATH))   # renders: (/health)
```

### NO_COLOR

Guard the palette with `ifdef NO_COLOR` so `make help > FILE` doesn't embed raw
escapes. Do **not** try to auto-detect a TTY: `$(shell test -t 1)` always reports
false (subshell stdout is a pipe), and `MAKE_TERMOUT` needs GNU make ≥ 4, which
macOS doesn't ship.

**Emoji vocabulary for help sections** (pick from this list; reuse the same emoji for the same concept across projects so the visual language transfers):

| Section concept                          | Emoji | Notes                                           |
| ---------------------------------------- | ----- | ----------------------------------------------- |
| Quick Start / Getting started            | 🚀    | Primary entry point for new contributors        |
| Run / dev server / start service         | 🏃    | Short-running ergonomic entry points            |
| Build / compile / package                | 🏗️    | `dev-build`, artifact creation                  |
| Development / lint / format / typecheck  | 🛠️    | Quality gate targets                            |
| Tests                                    | 🧪    | `test`, `test-e2e`, coverage                    |
| Database                                 | 🗄️    | `db-start`, `db-migrate`, `db-reset`            |
| Environment / config                     | 🌐    | `env-setup`, `env-status`, `env-show`           |
| Secrets / auth / keys                    | 🔑    | `env-pull-*`, credential management             |
| Deploy / release                         | 🛫    | `deploy`, `release`, `publish`                  |
| Cleanup / reset                          | 🧹    | `clean-*` family                                |
| Help / reference                         | ❓    | `help`, `help-unclassified`                     |

Emoji here go on the `##@` header only — a variation-selector emoji (🛠️, 🗄️, 🏗️) may consume an extra column, which is harmless in a header and would wreck a target line.

**Quick Start is a 2-step instruction list, not a target list.** If the real entry point is a short sequence (`make env-setup && make run-prod`), make `quickstart` a target that prints numbered instructions — do NOT list the same targets under both Quick Start and their "real" section (Environment Utilities, Run, etc.). Duplication doubles the help height and dilutes signal.

```makefile
# Good - one quickstart target printing an ordered sequence
##@ 🚀 Quick Start

quickstart: ## Print ordered first-run steps
	@printf "  $(GREEN)1.$(RESET) make env-install   $(DIM)# uv sync --all-extras$(RESET)\n"
	@printf "  $(GREEN)2.$(RESET) make run-local\n"

# Bad - the same targets listed under Quick Start AND their real section
```

**Key help patterns:**
- `help` - Main categorized help, generated from `##@` + `##`
- `help-unclassified` - Documented targets with no `##@` section above them (audit)
- Hidden targets: prefix with `_` and give them NO `##` comment (e.g., `_check-docker`)
- Legacy targets: label with `## (Legacy)` and park them under a `##@ 🗄️ Legacy` section

**Always give `help` and `help-unclassified` their own section** — put `##@ ❓ Help`
directly above them, otherwise the two most basic targets are missing from help
and clutter `help-unclassified` instead. `modules/help.mk` already does this.

**`help-unclassified` needs no exclusion list.** The old prefix-regex approach
(`grep -v -E '^(env-|dev-|clean|help)'`) fell out of sync every time a prefix was
added. The generated version asks a structural question instead — "is there a
`##@` above this target?" — which stays correct forever:

```makefile
help-unclassified: ## List documented targets with no ##@ section above them
	@awk 'FNR == 1 { section = "" } \
		/^##@ / { section = substr($$0, 5); next } \
		/^[a-zA-Z0-9_-]+:.*## / && section == "" { print "  " $$0 }' $(MAKEFILE_LIST)
```

**Description format — one plain-text line, in the `##` comment:**

```makefile
# Good - one line, says what it affects, args shown inline
scrape: ## Fetch posts into SQLite (make scrape SUBREDDITS=python LIMIT=10)
dev-check: ## Lint + type-check — add FIX=true to auto-fix
clean-build: ## Remove the .next build directory
run-local: ## Run API against local DB (localhost:$(PORT))

# Bad - a paragraph in a help line
setup: ## Install Python dependencies using uv. Run this once after cloning. Creates .venv/ and installs from pyproject.toml.
```

**Help description rules:**
- **One line max** — it shares a row with the target name; anything longer wraps and breaks the column.
- **Include what it affects** — "creates .venv", "exports to CSV", "destroys the volume".
- **No raw ANSI** — `$(YELLOW)` inside a `##` comment prints as the literal string `$(YELLOW)`. Use backticks (below) for emphasis; only names listed in `HELP_VARS` are expanded.
- **Fold the example into the line** — `(make foo ARG=val)` or `— add FIX=true` rather than a second printf line. The generated renderer emits one row per target by design.
- **Skip examples for simple targets** — if there are no parameters, no example is needed.

**Wrap literals in backticks.** The renderer colors the contents green and strips
the delimiters, so the tokens a reader actually reaches for — commands, files,
paths, tool names, target names, env vars — pop out of the prose:

```makefile
env-install: ## Install all deps incl extras (`uv sync --all-extras`)
api-export-spec: ## Export OpenAPI spec to `openapi.json`
db-shell: ## Open `psql` in the Postgres container
test: ## Run unit tests (alias of `test-unit`)
```

Renders as `Install all deps incl extras (`**`uv sync --all-extras`**`)` with the
backticked span in green. Leave prose parentheticals plain — `(needs db + redis)`,
`(prod-like, guarded)`. Marking up everything is the same as marking up nothing.

Note this is markup, not detection: a "color whatever is in parens" rule would
miss `openapi.json` (not in parens) and wrongly color `(needs db + redis)`.

**Danger annotations are the other styled element.** A trailing `(⚠️ …)` renders in
yellow. Use it for targets that destroy data or touch production, and nothing
else — three per project keeps the marker meaningful, thirty makes it wallpaper:

```makefile
db-reset: ## Destroy volume, recreate, and migrate (⚠️ DESTRUCTIVE)
run-api-prod: ## Run API against REMOTE prod DB, no reload (⚠️ PROD)
clean-all: clean ## Clean caches and remove .venv (⚠️ DESTRUCTIVE)
```

**URL-in-parens formula for `run-*` targets.** When a run target has a canonical destination (localhost port, API URL), append it in parens at the end of the description — denser than a separate info line, and it matches how contributors actually scan help. Use `HELP_VARS` so the port is the real one:

```makefile
HELP_VARS ?= PORT

run-local: ## Local API + testnet chains (localhost:$(PORT))
run-testnet: ## Testnet API + testnet chains (api.testnet.grove.city)
run-mainnet: ## Production API + mainnet chains (api.grove.city) (⚠️ PROD)
```

### Catch-all for unknown targets

Suggest the closest documented targets instead of dumping the whole help page —
a typo is usually one character off, and reprinting 40 targets buries the fix:

```makefile
%:
	@printf "$(RED)$(CROSS) Unknown target '$@'$(RESET)\n"
	@targets=$$(awk -F: '/^[a-zA-Z0-9_-]+:.*## /{print $$1}' $(MAKEFILE_LIST) | sort -u); \
	near=$$(printf '%s\n' "$$targets" | grep -i -- "$$(printf '%s' '$@' | cut -c1-4)" | head -5 || true); \
	if [ -n "$$near" ]; then \
		printf "$(DIM)Did you mean:$(RESET)\n"; \
		printf "  $(CYAN)%s$(RESET)\n" $$near; \
	fi; \
	printf "$(DIM)Run '$(RESET)$(CYAN)make help$(RESET)$(DIM)' for all targets.$(RESET)\n"; \
	exit 1
```

Three rules, each learned from a real failure:

| # | Rule | Failure it prevents |
|---|---|---|
| 1 | Keep it **last** in the file | A match-anything rule shadows every pattern rule defined after it |
| 2 | Give every `-include <file>` an empty `<file>: ;` rule | `-include .env` makes `.env` a goal, the catch-all claims it, and a fresh clone greets you with `✗ Unknown target '.env'` on every run |
| 3 | Never let an ignore-regex match target-shaped names | An ignore-list ending in `[a-z]+([-][a-z]+)*` swallows every typo — `make dev-tes` exits 0 and CI goes green on a target that does not exist |

Rule 2 in practice, at the top of the file:

```makefile
-include .env
# Optionally-included files are NOT build targets. An explicit rule beats a
# match-anything rule, so this silences the catch-all for good.
.env .env.prod .template.env: ;
```

An ignore-list is only for bare **arguments** passed as extra goals (`make send-tx 0xabc…`,
a URL, a number, a TICKER) — never for anything that could be a mistyped target.

## TODO Tracking

`TODO.md` is a **generated view over the code**, never a hand-maintained backlog.
Include `modules/todo.mk` and copy `modules/todo-scripts/gen_todo.py` to
`scripts/gen_todo.py`. Rationale:
[Move Fast & Document Things](https://olshansky.substack.com/p/move-fast-and-document-things).

- A hand-written list is "the one document to rule them all" — it goes stale the
  moment someone fixes something without updating it.
- The TODO lives **next to the code it concerns**; the index is regenerated.
- Filing a TODO is cheaper than filing a ticket. That is the point.
- `make todo-check` fails when `TODO.md` is stale — wire it into CI.
- `make todo-list` needs no Python and works in any language.

```makefile
# TODO_TECHDEBT: drop these casts if redis-py restores a typed client.
# Blocked on upstream: redis-py 8 removed Generic[_StrType], so `Redis[str]`
# raises at runtime. Re-check on the next major bump.
```

| # | Severity | Prefix | Act when |
|---|---|---|---|
| 1 | 🔴 | `FIXME` | Now — it is broken today |
| 2 | 🔴 | `TODO_IN_THIS_PR` | Before merge |
| 3 | 🟠 | `HACK` | Before it bites someone |
| 4 | 🟠 | `TODO_REMOVE_LATER` | When its stated exit condition is met |
| 5 | 🟡 | `TODO_TECHDEBT` / `TODO_BETA` / `TODO_PROD` / `TODO_OPTIMIZE` | Next cleanup, or at the named gate |
| 6 | 🟢 | `TODO_IMPROVE` / `TODO_CONSIDERATION` / `TODO_FUTURE` / `TODO_IDEA` / `TODO` | Opportunistically |

- Annotate with `TODO_PROD(#123, @olshansk):` to record an issue and/or owner.
- Always say **what to do and why it is deferred** — a bare `TODO: fix this` helps nobody.
- `NOTE:` is not tracked; it marks an explanation, not work.

## Runtime Output for Long-Running Targets

Help output is one concern; *runtime output* from `run-*` / `dev-*` / `db-*` targets that activate config and then hand off to a long-running subprocess (`next dev`, `uvicorn`, `docker compose up`) is a second concern. Without structure, the output from "env activation → warning → config summary → subprocess banner → subprocess logs" interleaves into one undifferentiated wall of ℹ️ / ✓ / ⚠️ lines, and the developer has to read everything to find what matters. The patterns below break that into visually distinct phases.

### Phase Banners

Bracket each logical phase with a horizontal rule + emoji + title + horizontal rule. Add two small reusable macros to `colors.mk`:

```makefile
# Horizontal rule separator
define print_hr
	@printf "$(DIM)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
endef

# Phase banner: horizontal rule + emoji + title + horizontal rule
# Usage: $(call print_phase,🔑,ENV → LOCAL + MAINNET)
define print_phase
	@printf "\n$(DIM)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@printf "$(BOLD)$(CYAN) $(1)  $(2)$(RESET)\n"
	@printf "$(DIM)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n\n"
endef
```

**Suggested phase-emoji vocabulary** (use consistently across a project so the reader learns the shorthand):

| Phase | Emoji | Use when |
|-------|-------|----------|
| Env / setup / secrets | 🔑 | Activating `.env`, loading secrets, switching config |
| Config / URLs / network | 🌐 | Showing resolved config, API endpoints, RPC URLs |
| App / server / service starting | 🚀 | Right before handing off to `next dev` / `uvicorn` / etc. |
| Database | 🗄️ | `db-start`, `db-migrate`, `db-reset` |
| Build | 📦 | `build`, `dev-build`, packaging |
| Tests | 🧪 | Before `pytest` / `vitest` / `playwright` output |
| Deploy | 🛫 | Before `render deploy` / `fly deploy` / `vercel` |

### Critical-Action Warnings (Triple-Emoji Pattern)

For irreversible actions — real-money mainnet runs, production DB writes, force pushes, anything with "you probably can't undo this" — use a standalone triple-emoji line that sits between phases, not inside one. The triple flanking is visually louder than any single-line warning and the isolation ensures it isn't scanned past as ambient info.

```makefile
# In colors.mk
define print_mainnet_warning
	@printf "\n$(RED)$(BOLD)⚠️⚠️⚠️  MAINNET — REAL MONEY. DOUBLE-CHECK BEFORE TX.  ⚠️⚠️⚠️$(RESET)\n"
endef

define print_prod_db_warning
	@printf "\n$(RED)$(BOLD)⚠️⚠️⚠️  WRITES HIT PRODUCTION DATABASE — CTRL-C IN 3s TO ABORT  ⚠️⚠️⚠️$(RESET)\n"
endef
```

**Rules:**
- Reserve the triple-⚠️ pattern for genuinely irreversible / costly actions. If you use it on every soft warning, it loses all signal.
- Single ⚠️ (or 🟡) for soft warnings ("secrets file missing, OAuth won't work"); triple ⚠️⚠️⚠️ for hard ones ("real money", "prod DB", "about to overwrite remote").
- Always render in `$(RED)$(BOLD)` and on its own line with blank lines around it — a boxed or inlined version loses punch.

### "Subprocess Logs Below" Divider

Right before handing off to a long-running subprocess (`npm run dev`, `uvicorn`, `docker compose up`), print a muted divider line that names whose logs are about to appear. Tells the user the Makefile's own output has ended, and anything below is coming from a child process with its own formatting conventions.

```makefile
.PHONY: dev-run
dev-run:
	$(call print_phase,🚀,APP)
	# ... URLs, Ctrl+C hint, etc ...
	@printf "\n$(DIM)─────────── Next.js logs below ───────────$(RESET)\n\n"
	$(Q)npm run dev
```

Name the subprocess explicitly (`Next.js logs`, `uvicorn logs`, `Postgres logs`) — a generic "logs below" is less useful because the reader still has to guess whose formatting conventions to expect.

### Actionable-Control Hint Before Hand-Off

Print one line right before the subprocess divider that tells the user what their keyboard controls are and what to expect. Compact, one line, bold the key combo:

```makefile
@printf "\n$(CYAN)$(INFO) Auto-reload enabled · Press $(BOLD)Ctrl+C$(RESET)$(CYAN) to stop$(RESET)\n"
```

Bad alternative: a multi-line "Server running. Press Ctrl+C to stop. Changes auto-reload." block — same information, 3× the vertical space, no denser.

### Parsed Key-Value Grid Over Raw `grep` Dumps

For `env-show` / `status` / `db-info` / any target whose job is to show "the current state of things," parse the underlying file and print a compact key-value grid rather than dumping raw `KEY=value` lines from `grep`. The parsed version is scannable; the raw dump is a wall of `NEXT_PUBLIC_FOO=bar` prefixes that the eye has to filter.

```makefile
# Bad - raw grep dump, 3 subsections, 8 lines
env-show:
	@printf "\n$(BOLD)Configuration:$(RESET)\n"
	@grep "^NEXT_PUBLIC_ENV=" .env.local | sed 's/^/  /'
	@grep "^NEXT_PUBLIC_CHAIN_ENV=" .env.local | sed 's/^/  /'
	@printf "\n$(BOLD)API Endpoints:$(RESET)\n"
	@grep "NEXT_PUBLIC_.*_URL=" .env.local | sed 's/^/  /'
	@printf "\n$(BOLD)Services:$(RESET)\n"
	@grep "^NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=" .env.local | sed 's/^/  /'

# Good - parsed grid under a phase banner, 4 lines, aligned columns
env-show:
	$(call print_phase,🌐,CONFIG)
	@ENV=$$(grep "^NEXT_PUBLIC_ENV=" .env.local | cut -d= -f2); \
	 GROVE=$$(grep "^NEXT_PUBLIC_GROVE_API_BASE_URL=" .env.local | cut -d= -f2); \
	 BASE=$$(grep "^NEXT_PUBLIC_BASE_RPC_URL=" .env.local | cut -d= -f2 | sed 's|https://||'); \
	 SOL=$$(grep "^NEXT_PUBLIC_SOLANA_RPC_URL=" .env.local | cut -d= -f2 | sed 's|https://||'); \
	 printf "  $(BOLD)%-8s$(RESET) $(YELLOW)%s$(RESET)\n" "Env" "$$ENV"; \
	 printf "  $(BOLD)%-8s$(RESET) $(YELLOW)%s$(RESET)\n" "API" "$$GROVE"; \
	 printf "  $(BOLD)%-8s$(RESET) $(YELLOW)%s$(RESET) · $(YELLOW)%s$(RESET)\n" "RPC" "$$BASE" "$$SOL"
```

**Rules:**
- Fixed-width label column (`%-8s` / `%-10s`) so values align vertically.
- Values colored `$(YELLOW)` (same convention as help-description paths/URLs).
- Strip noise (e.g. `https://` prefixes on RPC URLs) when the protocol doesn't add information.
- Mask secrets (`WALLETCONNECT_SECRET=***hidden***`).
- If a value is missing or placeholder, print `$(RED)✗ not configured$(RESET)` — don't silently omit the row.

### Full-Flow Example

Applying all five patterns to a `run-mainnet` target produces:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🔑  ENV → MAINNET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓  envs/mainnet.env + envs/.mainnet.secrets → .env.local

⚠️⚠️⚠️  MAINNET — REAL MONEY. DOUBLE-CHECK BEFORE TX.  ⚠️⚠️⚠️

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🌐  CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Env      MAINNET (Base Mainnet · Solana Mainnet)
  API      https://api.grove.city
  RPC      mainnet.base.org · api.mainnet-beta.solana.com
  Wallet   WalletConnect a06ebd2a…

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🚀  APP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 URLs:
   http://localhost:3000         (local)
   http://192.168.1.15:3000      (LAN / mobile — cross-network? make run-ngrok)

ℹ️ Auto-reload enabled · Press Ctrl+C to stop

─────────── Next.js logs below ───────────

▲ Next.js 16.2.1 (Turbopack) · Ready in 400ms
```

## Common Pitfalls

| Issue | Fix |
|-------|-----|
| `$var` in shell loops | Use `$$var` to escape for make |
| Catch-all `%:` shows error | Redirect to `@$(MAKE) help` instead |
| Config vars scattered | Put all `?=` overridable defaults at TOP of root Makefile |
| `HELP_PATTERNS` mismatch | Must match grep patterns in help target exactly |
| Duplicate defs in modules | Define once in root, reference in modules |
| Trailing whitespace in vars | Causes path splitting bugs - trim all variable definitions |
| `.PHONY` on file targets | Only use `.PHONY` for non-file targets |
| Too many public targets | Don't expose `install-X` or `check-X` - use internal `_check-X` dependencies |
| `$(DIM)` for usage text | Appears grey/unreadable - use `$(GREEN)` instead |
| Color codes inside `%s` | ANSI codes in `%s` args print as literals - put colors in format string |
| Section header same color as title/targets | Use a distinct color (default `$(BOLD)$(BLUE)` — avoid `$(MAGENTA)`/purple, clashes with most terminal themes) + `\n\n` after the header. `$(BOLD)` alone renders as terminal-default and gets lost. |
| Section headers have no emoji | Every section gets a leading emoji (🚀 Quick Start, 🏃 Run, 🛠️ Development, 🌐 Environment, 🧹 Cleanup, 🧪 Tests). Emojis give the reader a glanceable landmark so they can skip to the section they want without parsing words. See "Emoji vocabulary" table in the Help System section. |
| Title box has no project emoji | The `make help` title box should carry a project-branded emoji on the right (🌿 for Grove, 🚀 for SDKs, 🔒 for security tools, etc.). Right-side placement; left-side crowds the title. |
| Runtime output is a wall of ℹ️/⚠️/✓ with no structure | Wrap each logical phase (env activation, config summary, subprocess hand-off) in a `print_phase` banner — see §"Runtime Output for Long-Running Targets". |
| `env-show` / `status` dumps raw `KEY=value` grep output | Parse the values in shell and print a compact aligned key-value grid (`Env` / `API` / `RPC` / `Wallet`) — scannable instead of a wall of `NEXT_PUBLIC_FOO=bar`. |
| ⚠️ used on every warning, so no warning stands out | Reserve triple-`⚠️⚠️⚠️` `$(RED)$(BOLD)` for irreversible / costly actions (prod writes, real money, force push). Single `⚠️` for soft warnings. |
| Target named after tool | Name after the action: `remove-bg` not `rembg` |
| Too many granular `dev-*` quality targets | Collapse `dev-lint` + `dev-typecheck` + `dev-format` + `dev-check` into one `dev-format` (runs all three — prettier+eslint+tsc usually <5s for Node projects). Split only if CI parallelizes them. Same for `dev-test` + `dev-test-e2e` → one `test`. |
| `run-*-all` / "Full Stack" Cartesian section | Projects with a `docs/` sibling grow `run-testnet-all` / `run-mainnet-all` / `run-local-all` / `run-local-mainnet-all` that just background the docs site. These are almost never used — users open a second terminal. Keep one `run-docs` target in the "Run" section and drop the Cartesian matrix. |
| Quick Start repeats targets | If Quick Start lists `setup` and `status`, and Environment Utilities lists `setup` and `status` again, you're doubling help height. Make Quick Start a numbered instruction list (`1. make env-setup`, `2. make run-prod`) and let targets live once in their real section. |
| `help-unclassified` shows filename | Use `sed 's/^[^:]*://'` to strip `Makefile:` prefix |
| No `.env` export | Inline-source in the recipe: `@set -a && . ./.env && set +a && $(CMD)` (or `-include .env` for weaker cases — see Env File Loading) |
| Stale shell `DATABASE_URL` silently overrides `.env` | Use inline `set -a && . ./.env && set +a` in any recipe that depends on a specific `.env` value. `-include` alone loses to already-exported shell vars. |
| Secret committed to git | Add gitignored file (e.g. `.env.prod`), verify with `git check-ignore`, grep staged diff for a secret fragment before `git add`: `git diff --cached \| grep -c "$FRAGMENT"` |
| Single-service `docker-compose.yml` | For one Postgres container, a plain `docker run` in `db-start` is lighter than a compose file. Compose pays off only when you have 2+ services. |
| Dockerized Postgres on port 5432 clashes with host Homebrew Postgres | Default dev container to `PG_PORT ?= 5433` (and update `DATABASE_URL` accordingly). 5432 is nearly always claimed on macOS dev machines. |
| `pgcli` rejects `postgresql+psycopg://...` URL | pgcli doesn't understand SQLAlchemy dialect markers. Strip before use: `PGCLI_URL=$$(echo "$$DATABASE_URL" \| sed 's/+psycopg//') && pgcli "$$PGCLI_URL"`. |
| FastAPI `api-export-spec` hardcodes model import | The export script imports `app.main:app`. Parameterize via the `APP_MODULE` make variable if your entrypoint differs. |

## Cleanup Makefile Workflow

When user says "cleanup my makefiles":

**IMPORTANT: Build a plan first and explain it to the user before implementing anything.**

### Phase 1: Audit (no changes yet)

```bash
make help                    # See categorized targets
make help-unclassified       # Find orphaned targets
cat Makefile                 # Read structure
ls makefiles/*.mk 2>/dev/null # Check if modular
rg "make " --type md         # Find external dependencies
grep -E '\s+$' Makefile makefiles/*.mk  # Trailing whitespace
```

### Phase 2: Build & Present Plan

Create a checklist of proposed changes:

- [ ] **Structure** - Convert flat → modular (if 5+ targets) or vice versa
- [ ] **Legacy removal** - List specific targets to delete (with dependency check)
- [ ] **Duplicates** - List targets to consolidate
- [ ] **Renames** - List `old_name` → `new-name` changes
- [ ] **Description rewrites** - List vague descriptions to improve
- [ ] **Missing targets** - Suggest targets that should exist (e.g., `help-unclassified`)
- [ ] **Ordering fixes** - Config → imports → targets → help → catch-all

**Ask user to approve the plan before proceeding.**

### Phase 3: Implement (after approval)

1. **Restructure** (if needed) - Create `makefiles/` directory, split into modules
2. **Remove legacy** - Delete approved targets
3. **Consolidate duplicates** - Merge into single targets
4. **Rename targets** - Apply hyphen convention, add `_` prefix for internal
5. **Rewrite descriptions** - Make each `##` explain the purpose
6. **Fix formatting**
   - Usage examples in yellow: `$(YELLOW)make foo$(RESET)`
   - Remove trailing whitespace
   - `.PHONY` only on non-file targets
7. **Add missing pieces** - `help-unclassified`, catch-all `%:`, etc.

### Phase 4: Verify

```bash
make help          # Clean output?
make help-unclassified  # Should be empty or minimal
make -n <target>   # Dry-run key targets
```

### What NOT to do without asking:

- Rename targets that CI/scripts depend on
- Remove targets that look unused
- Change structure (flat ↔ modular) without approval

## Files in This Skill

- `reference.md` - Detailed patterns, categorized help, error handling
- `templates/` - Full copy-paste Makefiles for each stack
- `modules/` - Reusable pieces for complex projects
  - `modules/help.mk` - **Generated `make help`** (`##@` sections). Include LAST.
  - `modules/colors.mk` - ANSI palette, color tiers, `NO_COLOR` guard
  - `modules/common.mk` - Shell settings, guards, preflight checks
  - `modules/todo.mk` - **Generated `TODO.md`** from prefixed code comments
  - `modules/todo-scripts/gen_todo.py` - companion for `make todo`

> 🚧 **Generated-help migration status.** `base.mk`, `python-uv.mk`, and
> `python-fastapi.mk` use the generated `##@` renderer. The six templates still
> hand-writing their help block carry a `TODO_FUTURE` at the top of the file —
> find them with `grep -rn "TODO_FUTURE" templates/` (currently `go.mk`,
> `nodejs.mk`, `flutter.mk`, `electron.mk`, `chrome-extension.mk`,
> `static-site.mk`). Convert one whenever you touch it for another reason.

## Example: Adding a Target

User: "Add a target to run my tests"

```makefile
.PHONY: test
test: ## Run tests
	$(call print_section,Running tests)
	uv run pytest tests/ -v
	$(call print_success,Tests passed)
```

User: "Add database targets"

```makefile
.PHONY: db-start db-stop db-migrate

db-start: _check-docker ## Start database
	docker compose up -d postgres

db-stop: ## Stop database
	docker compose down

db-migrate: _check-postgres ## Run migrations
	uv run alembic upgrade head
```
