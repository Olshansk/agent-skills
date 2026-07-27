# FastAPI Makefile Template (using uv)
# Copy this file to your project root as 'Makefile'
#
# For database targets (PostgreSQL + Alembic), also copy templates/postgres.mk
# or include it: include postgres.mk
#
# For modular projects (5+ files), extract colors/helpers into:
#   makefiles/colors.mk and makefiles/common.mk
#
# Companion files (from templates/):
#   - python-fastapi-env/.template.env -> .template.env (committed)
#   - python-fastapi-scripts/export_openapi_spec.py -> scripts/export_openapi_spec.py
#
# Prerequisites:
#   - uv installed (https://github.com/astral-sh/uv)
#   - pyproject.toml with FastAPI, uvicorn
#   - `.template.env` at repo root; `.env` gitignored

.DEFAULT_GOAL := help

# ============================================================================
# Configuration (adjust these for your project)
# ============================================================================
APP_MODULE  ?= app.main:app
HOST        ?= 0.0.0.0
PORT        ?= 8000
# Health path — versioned APIs often live under /v1/health etc.
HEALTH_PATH ?= /health

# ============================================================================
# Help configuration
# ============================================================================
# `make help` is GENERATED from the comments below — never hand-maintained, so
# it cannot drift from the real targets. Two kinds of comment drive it:
#
#   ##@ 🚀 Section Title      declares a section (emoji lives HERE, only here)
#   target: ## description    documents a target under the current section
#
# Rules:
#   1. Emoji go on section headers, NEVER on target lines. Per-target emoji have
#      inconsistent display widths (⬆️ ♻️ 🖥️ are 1 cell, 🚀 🐍 📦 are 2), which
#      makes the description column jitter and the list stop scanning.
#   2. Sections render in file order — reorder the blocks below to reorder help.
#   3. Mark destructive/prod targets with a trailing "(⚠️ …)"; it renders yellow.
#   4. Wrap literals in `backticks` — commands, files, paths, tool names, target
#      names, env vars. They render green and the backticks are stripped:
#        api-export-spec: ## Export OpenAPI spec to `openapi.json`
#      Leave prose plain; marking up everything is the same as marking up nothing.
#   5. Color tiers: BOLD+BLUE headers, CYAN names, default-fg descriptions,
#      GREEN literals, YELLOW danger.
# Keep emoji out of HELP_TITLE (2 cells wide, 1 char — it breaks box padding).
HELP_TITLE   ?= FastAPI Project — Make Targets
HELP_ICON    ?= 🚀
HELP_TAGLINE ?= Every command runs via uv.
HELP_WIDTH   ?= 46
HELP_PAD     ?= 24
# Make vars referenced inside `## ` descriptions — awk reads raw file text, so
# make never expands them; this substitutes real values at render time.
HELP_VARS ?= PORT HEALTH_PATH
HELP_SED   = $(if $(HELP_VARS),sed $(foreach v,$(HELP_VARS),-e 's|[$$]($(v))|$($(v))|g'),cat)

# ============================================================================
# Test granularity
# ============================================================================
# This template ships BOTH patterns. Delete the one you don't want when
# scaffolding:
#
#   - Single target `dev-test`: best for small/medium projects. Runs all tests.
#   - Split `test-unit` / `test-integration` / `test-e2e`: best for larger
#     projects where unit tests are cheap and e2e hits real infra.
#
# If you keep the split pattern, ensure tests/ is laid out as:
#   tests/unit/  tests/integration/  tests/e2e/

# ============================================================================
# Colors & Symbols
# ============================================================================
# Standard 16 colors only — readable on both light and dark terminal themes.
GREEN   := \033[0;32m
YELLOW  := \033[1;33m
RED     := \033[0;31m
CYAN    := \033[0;36m
BLUE    := \033[0;34m
MAGENTA := \033[0;35m
BOLD    := \033[1m
DIM     := \033[2m
RESET   := \033[0m

# NO_COLOR=1 strips escapes so piped output stays clean (https://no-color.org).
ifdef NO_COLOR
GREEN   :=
YELLOW  :=
RED     :=
CYAN    :=
BLUE    :=
MAGENTA :=
BOLD    :=
DIM     :=
RESET   :=
endif

CHECK := ✓
CROSS := ✗
WARN  := ⚠️
INFO  := ℹ️

# ============================================================================
# Print Helpers
# ============================================================================
define print_success
	@printf "$(GREEN)$(BOLD) $(CHECK) %s$(RESET)\n" "$(1)"
endef

define print_warning
	@printf "$(YELLOW)$(WARN) %s$(RESET)\n" "$(1)"
endef

define print_info
	@printf "$(CYAN)$(INFO) %s$(RESET)\n" "$(1)"
endef

define print_section
	@printf "\n$(CYAN)$(BOLD)%s$(RESET)\n" "$(1)"
endef

# Check that the server is running; fails fast with a helpful message.
# Usage: $(call check_server) at the top of any target that requires a live server.
define check_server
	@curl -sf http://$(HOST):$(PORT)$(HEALTH_PATH) > /dev/null 2>&1 || { \
		printf "$(RED)$(CROSS) Server not running on port $(PORT). Start it first: make run-api-local$(RESET)\n"; \
		exit 1; \
	}
endef

# Kill any process occupying LIVERELOAD_PORT (e.g., a background watchfiles/livereload process).
# Usage: $(call kill_livereload) before starting a new live-reload session.
LIVERELOAD_PORT ?= 35729
define kill_livereload
	@-lsof -ti :$(LIVERELOAD_PORT) | xargs kill 2>/dev/null || true
endef

# ============================================================================
# Preflight
# ============================================================================
.PHONY: _check-env _check-env-prod

_check-env:
	@if [ ! -f .env ]; then \
		printf "$(RED)$(CROSS) .env not found$(RESET)\n"; \
		printf "$(YELLOW)$(INFO) Run 'make env-template' or 'cp .template.env .env'$(RESET)\n"; \
		exit 1; \
	fi

_check-env-prod:
	@if [ ! -f .env.prod ]; then \
		printf "$(RED)$(CROSS) .env.prod not found$(RESET)\n"; \
		printf "$(YELLOW)Create it locally with the prod DATABASE_URL (MUST be gitignored)$(RESET)\n"; \
		exit 1; \
	fi

# ============================================================================
# Quick Start
# ============================================================================
# NOTE: `help` is generated and lives at the END of this file (sections render
# in file order, so the ❓ Help section belongs last).
##@ 🚀 Quick Start

.PHONY: quickstart-dev
quickstart-dev: ## Interactive developer setup guide
	@printf "\n$(BOLD)$(GREEN)🚀 Developer Quick Start$(RESET)\n\n"
	@printf "$(BOLD)Step 1:$(RESET) Install dependencies\n"
	@$(MAKE) env-install
	@printf "\n$(BOLD)Step 2:$(RESET) Create .env\n"
	@$(MAKE) env-template
	@printf "\n$(BOLD)Step 3:$(RESET) Start the API\n"
	@printf "   $(CYAN)make run-api-local$(RESET)\n\n"
	@printf "$(BOLD)$(GREEN)$(CHECK) Setup complete$(RESET)\n"
	@printf "   API docs: $(CYAN)http://localhost:$(PORT)/docs$(RESET)\n\n"

# ============================================================================
# Env bootstrap
# ============================================================================
.PHONY: env-template

env-template: ## Create `.env` from `.template.env` (safe: never overwrites)
	@if [ -f .env ]; then \
		printf "$(YELLOW)$(INFO) .env already exists — leaving it alone$(RESET)\n"; \
	elif [ ! -f .template.env ]; then \
		printf "$(RED)$(CROSS) .template.env not found$(RESET)\n"; \
		exit 1; \
	else \
		cp .template.env .env; \
		printf "$(GREEN)$(CHECK) Created .env from .template.env — fill in real values$(RESET)\n"; \
	fi

# ============================================================================
# Environment
# ============================================================================
##@ 🐍 Environment

.PHONY: env-install env-install-prod env-sync clean-env

env-install: ## Install development dependencies (`uv sync --all-extras`)
	$(call print_section,Installing dependencies)
	@command -v uv >/dev/null 2>&1 || { printf "$(RED)Missing: uv$(RESET)\n"; exit 1; }
	uv sync
	$(call print_success,Dependencies installed)

env-install-prod: ## Install production dependencies (`uv sync --no-dev`)
	$(call print_section,Installing production dependencies)
	@command -v uv >/dev/null 2>&1 || { printf "$(RED)Missing: uv$(RESET)\n"; exit 1; }
	uv sync --no-dev
	$(call print_success,Production dependencies installed)

env-sync: ## Sync dependencies with `uv.lock`
	$(call print_section,Syncing dependencies)
	uv sync
	$(call print_success,Dependencies synced)

clean-env: ## Remove the `.venv` virtual environment (⚠️ DESTRUCTIVE)
	$(call print_warning,Removing virtual environment)
	rm -rf .venv venv
	$(call print_success,Virtual environment removed)

# ============================================================================
# API Server
# ============================================================================
##@ 🌐 API Operations

.PHONY: run-api-local run-api-prod api-health api-export-spec

run-api-local: _check-env ## Run API against local DB (`.env`, `--reload`, port `$(PORT)`)
	$(call print_section,Starting API (local))
	@printf "$(BOLD)Endpoints:$(RESET) $(CYAN)http://localhost:$(PORT)$(RESET)\n"
	@printf "$(BOLD)Docs:$(RESET)      $(CYAN)http://localhost:$(PORT)/docs$(RESET)\n"
	@set -a && . ./.env && set +a && uv run uvicorn $(APP_MODULE) --host $(HOST) --port $(PORT) --reload

run-api-prod: _check-env-prod ## Run API against REMOTE prod DB (`.env.prod`, no reload) (⚠️ PROD)
	@printf "$(RED)$(BOLD)$(WARN)  LOCAL UVICORN -> REMOTE PRODUCTION DB$(RESET)\n"
	@printf "$(YELLOW)Writes hit PRODUCTION. Ctrl-C within 3s to abort.$(RESET)\n"
	@sleep 3
	$(call print_section,Starting API (prod DB))
	@printf "$(BOLD)Endpoints:$(RESET) $(CYAN)http://localhost:$(PORT)$(RESET)\n"
	@set -a && . ./.env.prod && set +a && uv run uvicorn $(APP_MODULE) --host $(HOST) --port $(PORT)

api-health: ## Check API health at `$(HEALTH_PATH)` — override with `HEALTH_PATH=`
	$(call print_info,Checking API health at $(HEALTH_PATH))
	@curl -s http://localhost:$(PORT)$(HEALTH_PATH)
	@printf "\n"

api-export-spec: ## Export OpenAPI spec to `openapi.json`
	$(call print_section,Exporting OpenAPI spec)
	uv run python scripts/export_openapi_spec.py
	$(call print_success,OpenAPI spec written to openapi.json)

# ============================================================================
# Live Reload (optional — uvicorn --reload is usually enough; use this pattern
# when you have a separate background process like browser-sync or livereload)
# ============================================================================
# .PHONY: run-local-live
#
# run-local-live: ## Start server with a side-car livereload process (PORT=8000)
# 	$(call kill_livereload)
# 	$(call print_section,Starting API + livereload on port $(PORT))
# 	@uv run livereload & \
# 	LIVERELOAD_PID=$$!; \
# 	trap "kill $$LIVERELOAD_PID 2>/dev/null" EXIT; \
# 	uv run uvicorn $(APP_MODULE) --host $(HOST) --port $(PORT) --reload

# ============================================================================
# Seed Data (optional — add seed-* targets for datasets your app needs)
# ============================================================================
# Pattern: create a timestamped resource, then activate it via a POST endpoint.
# Requires a running server (check_server guard) and a sample data directory.
#
# .PHONY: seed-example
#
# seed-example: ## Create example-{timestamp} dataset from example_sample/
# 	$(call check_server)
# 	$(eval DATASET := example-$(shell date +%s))
# 	$(call print_section,Creating dataset: $(DATASET))
# 	@mkdir -p datasets/$(DATASET)/raw
# 	@cp example_sample/* datasets/$(DATASET)/raw/
# 	$(call print_success,Files copied)
# 	@curl -sf -X POST http://$(HOST):$(PORT)/set-dataset \
# 		-H 'Content-Type: application/json' \
# 		-d '{"dataset":"$(DATASET)"}' > /dev/null \
# 		&& printf "  Dataset active: $(DATASET)\n" \
# 		|| { printf "$(RED)  Failed to activate dataset$(RESET)\n"; exit 1; }
# 	$(call print_success,Dataset $(DATASET) ready)

# ============================================================================
# Testing
# ============================================================================
##@ 🧪 Testing

.PHONY: dev-test test-unit test-integration test-e2e

# --- Single-target pattern (small/medium projects) --------------------------
dev-test: ## Run all tests (`pytest tests/`)
	$(call print_section,Running tests)
	uv run pytest
	$(call print_success,Tests passed)

# --- Split pattern (larger projects) ---------------------------------------
test-unit: ## Run unit tests (`tests/unit`)
	$(call print_section,Running unit tests)
	uv run pytest tests/unit/ -v
	$(call print_success,Unit tests passed)

test-integration: ## Run integration tests (`tests/integration`, requires db)
	$(call print_section,Running integration tests)
	@printf "$(YELLOW)$(WARN) Requires Postgres (make db-start)$(RESET)\n"
	uv run pytest tests/integration/ -v
	$(call print_success,Integration tests passed)

test-e2e: _check-env ## Run E2E tests (`tests/e2e`, sources `.env`)
	$(call print_section,Running E2E tests)
	@printf "$(YELLOW)$(WARN) This may use real resources$(RESET)\n"
	@set -a && . ./.env && set +a && uv run pytest tests/e2e/ -v
	$(call print_success,E2E tests passed)

# ============================================================================
# Development
# ============================================================================
##@ 🛠️ Development

.PHONY: dev-format dev-check validate dev-todo

dev-format: ## Auto-fix and format code (`ruff check --fix` + `ruff format`)
	$(call print_section,Formatting code)
	uv run ruff check --fix .
	uv run ruff format .
	$(call print_success,Formatting complete)

dev-check: ## Lint + test (`ruff check` + `pytest`)
	$(call print_section,Running checks)
	uv run ruff check .
	uv run ruff format --check .
	uv run pytest
	$(call print_success,All checks passed)

validate: dev-check ## Alias for `dev-check`
	@:

dev-todo: ## Find `TODO`/`FIXME`/`HACK`/`NOTE` comments
	$(call print_section,Searching for TODOs)
	@grep -rn --color=always \
		--exclude-dir={.venv,__pycache__,.pytest_cache,.mypy_cache,.git} \
		--exclude={"*.pyc","uv.lock"} \
		-E "(TODO|FIXME|XXX|HACK|NOTE):" . || printf "$(GREEN)No TODOs found!$(RESET)\n"

# ============================================================================
# Cleaning
# ============================================================================
##@ 🧹 Cleaning

.PHONY: clean clean-all

clean: ## Remove `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`
	$(call print_warning,Cleaning cache)
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	$(call print_success,Cleaned)

clean-all: clean clean-env ## `clean` + remove `.venv` (⚠️ DESTRUCTIVE)
	$(call print_success,All cleanup complete)

# ============================================================================
# Help (keep near end, before catch-all)
# ============================================================================
# Generated from the ##@ sections and ## comments above — add a target with a
# `## description` under a ##@ header and it shows up here automatically.
# Nothing below needs editing when targets change.
##@ ❓ Help

.PHONY: help help-unclassified

help: ## Show categorized help (default)
	@t="$(HELP_TITLE)"; w=$(HELP_WIDTH); p=$$(( w - 6 - $${#t} )); \
		if [ $$p -lt 1 ]; then p=1; fi; \
		bar=$$(printf '═%.0s' $$(seq 1 $$w)); \
		printf "\n$(BOLD)$(CYAN)╔%s╗$(RESET)\n" "$$bar"; \
		printf "$(BOLD)$(CYAN)║$(RESET)  $(BOLD)%s$(RESET)%*s$(HELP_ICON)  $(BOLD)$(CYAN)║$(RESET)\n" "$$t" "$$p" ""; \
		printf "$(BOLD)$(CYAN)╚%s╝$(RESET)\n" "$$bar"
	$(if $(HELP_TAGLINE),@printf "$(DIM)$(HELP_TAGLINE)$(RESET)\n",@true)
	@# Single pass in file order: ##@ prints a section header, documented targets
	@# print under it. Padding is emitted OUTSIDE the color span via %*s so the
	@# gap between name and description carries no color.
	@awk -v pad=$(HELP_PAD) ' \
		FNR == 1 { section = "" } \
		/^##@ / { \
			section = substr($$0, 5); gsub(/[ \t]+$$/, "", section); \
			printf "\n$(BOLD)$(BLUE)═══ %s ═══$(RESET)\n\n", section; next \
		} \
		/^[a-zA-Z0-9_-]+:.*## / && section != "" { \
			name = $$0; sub(/:.*/, "", name); \
			desc = $$0; sub(/^[^:]*:.*## /, "", desc); gsub(/[ \t]+$$/, "", desc); \
			while (match(desc, /`[^`]*`/)) { \
				desc = substr(desc, 1, RSTART - 1) "$(GREEN)" \
					substr(desc, RSTART + 1, RLENGTH - 2) "$(RESET)" \
					substr(desc, RSTART + RLENGTH) \
			} \
			gsub(/\(⚠️[^)]*\)/, "$(YELLOW)&$(RESET)", desc); \
			w = pad - length(name); if (w < 1) w = 1; \
			printf "  $(CYAN)%s$(RESET)%*s%s\n", name, w, "", desc \
		}' $(MAKEFILE_LIST) | $(HELP_SED)
	@printf "\n"

help-unclassified: ## List documented targets with no `##@` section above them
	@printf "\n$(BOLD)$(BLUE)═══ 🔎 Unclassified targets ═══$(RESET)\n\n"
	@awk -v pad=$(HELP_PAD) ' \
		FNR == 1 { section = "" } \
		/^##@ / { section = substr($$0, 5); next } \
		/^[a-zA-Z0-9_-]+:.*## / && section == "" { \
			name = $$0; sub(/:.*/, "", name); \
			desc = $$0; sub(/^[^:]*:.*## /, "", desc); gsub(/[ \t]+$$/, "", desc); \
			while (match(desc, /`[^`]*`/)) { \
				desc = substr(desc, 1, RSTART - 1) "$(GREEN)" \
					substr(desc, RSTART + 1, RLENGTH - 2) "$(RESET)" \
					substr(desc, RSTART + RLENGTH) \
			} \
			w = pad - length(name); if (w < 1) w = 1; \
			found = 1; printf "  $(CYAN)%s$(RESET)%*s%s\n", name, w, "", desc \
		} \
		END { if (!found) printf "  $(DIM)(none — every documented target has a section)$(RESET)\n" } \
		' $(MAKEFILE_LIST)
	@printf "\n"

# ============================================================================
# Error Handling (keep at end)
# ============================================================================
# Unknown goals error loudly and suggest the closest documented targets.
#
# The ignore-list exists for bare ARGUMENTS passed as extra goals — `make
# send-tx 0xabc…`, a URL, a number, a domain, a TICKER. It must never match
# something that looks like a target name: the previous version ended in
# `[a-z]+([-][a-z]+)*`, which matched nearly every lowercase name, so `make
# dev-tes` was silently ignored and exited 0 instead of flagging the typo.
#
# MUST stay last — a match-anything rule shadows any pattern rule defined after
# it. Every `-include <file>` also needs an empty `<file>: ;` rule, or this
# catch-all tries to "build" it on every run.
%:
	@TARGET="$@"; \
	if echo "$$TARGET" | grep -qE '^(https?://\S+|0x[a-fA-F0-9]{40}|[0-9]+\.?[0-9]*|[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?|[A-Z]{2,10})$$'; then \
		: ; \
	else \
		printf "\n$(RED)$(CROSS) Unknown target '$$TARGET'$(RESET)\n"; \
		targets=$$(awk -F: '/^[a-zA-Z0-9_-]+:.*## /{print $$1}' $(MAKEFILE_LIST) | sort -u); \
		near=$$(printf '%s\n' "$$targets" | grep -i -- "$$(printf '%s' "$$TARGET" | cut -c1-4)" | head -5 || true); \
		if [ -n "$$near" ]; then \
			printf "$(DIM)Did you mean:$(RESET)\n"; \
			printf "  $(CYAN)%s$(RESET)\n" $$near; \
		fi; \
		printf "$(DIM)Run '$(RESET)$(CYAN)make help$(RESET)$(DIM)' for all targets.$(RESET)\n\n"; \
		exit 1; \
	fi
