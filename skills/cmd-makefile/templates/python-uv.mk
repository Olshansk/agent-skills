# Python Makefile Template (using uv)
# Copy this file to your project root as 'Makefile'
#
# Prerequisites:
#   - uv installed (https://github.com/astral-sh/uv)
#   - pyproject.toml + uv.lock

.DEFAULT_GOAL := help

# ============================================================================
# Configuration
# ============================================================================
-include .env
.EXPORT_ALL_VARIABLES:

# Optionally-included files are NOT build targets. Without these empty rules,
# `-include .env` makes `.env` a goal, the catch-all at the bottom claims it,
# and every `make` run in a fresh clone opens with: ✗ Unknown target '.env'
.env .env.prod .template.env: ;

FIX ?= false

# ============================================================================
# Colors & Symbols
# ============================================================================
# Standard 16 colors only — readable on both light and dark terminal themes.
GREEN  := \033[0;32m
YELLOW := \033[1;33m
RED    := \033[0;31m
CYAN   := \033[0;36m
BLUE   := \033[0;34m
BOLD   := \033[1m
DIM    := \033[2m
RESET  := \033[0m

CHECK := ✓
CROSS := ✗

# NO_COLOR=1 strips escapes so piped output stays clean (https://no-color.org).
ifdef NO_COLOR
GREEN  :=
YELLOW :=
RED    :=
CYAN   :=
BLUE   :=
BOLD   :=
DIM    :=
RESET  :=
endif

# ============================================================================
# Help configuration
# ============================================================================
# `make help` is GENERATED from the comments below — never hand-maintained, so
# it cannot drift from the real targets. Two kinds of comment drive it:
#
#   ##@ 🐍 Section Title      declares a section (emoji lives HERE, only here)
#   target: ## description    documents a target under the current section
#
# Rules:
#   1. Emoji go on section headers, NEVER on target lines. Per-target emoji have
#      inconsistent display widths (⬆️ ♻️ 🖥️ are 1 cell, 🐍 🚀 📦 are 2), which
#      makes the description column jitter and the list stop scanning.
#   2. Sections render in file order — reorder the blocks below to reorder help.
#   3. Mark destructive targets with a trailing "(⚠️ …)"; it renders yellow.
#   4. Wrap literals in `backticks` — commands, files, paths, tool names, target
#      names, env vars. They render green and the backticks are stripped:
#        env-install: ## Install dependencies (`uv sync`)
#      Leave prose plain; marking up everything is the same as marking up nothing.
#   5. Color tiers: BOLD+BLUE headers, CYAN names, default-fg descriptions,
#      GREEN literals, YELLOW danger.
# Keep emoji out of HELP_TITLE (2 cells wide, 1 char — it breaks box padding).
HELP_TITLE   ?= Python Project — Make Targets
HELP_ICON    ?= 🐍
HELP_TAGLINE ?= Every command runs via uv.
HELP_WIDTH   ?= 46
HELP_PAD     ?= 24
# Make vars referenced inside `## ` descriptions, e.g. `## Serve on port $(PORT)`.
HELP_VARS ?=
HELP_SED   = $(if $(HELP_VARS),sed $(foreach v,$(HELP_VARS),-e 's|[$$]($(v))|$($(v))|g'),cat)

# ============================================================================
# Print Helpers
# ============================================================================
define print_success
	@printf "$(GREEN)$(BOLD) $(CHECK) %s$(RESET)\n" "$(1)"
endef

define print_warning
	@printf "$(YELLOW) %s$(RESET)\n" "$(1)"
endef

define print_section
	@printf "\n$(CYAN)$(BOLD)%s$(RESET)\n" "$(1)"
endef

# ============================================================================
# Environment
# ============================================================================
##@ 🐍 Environment

.PHONY: env-install env-sync clean-env

env-install: ## Install dependencies (`uv sync --all-extras`)
	$(call print_section,Installing dependencies)
	@command -v uv >/dev/null 2>&1 || { printf "$(RED)$(CROSS) uv not installed$(RESET)\n"; exit 1; }
	uv sync --all-extras
	$(call print_success,Dependencies installed)

env-sync: ## Sync dependencies from `uv.lock` (`uv sync`)
	$(call print_section,Syncing dependencies)
	uv sync
	$(call print_success,Dependencies synced)

clean-env: ## Remove the `.venv` virtual environment (⚠️ DESTRUCTIVE)
	$(call print_warning,Removing virtual environment)
	rm -rf .venv venv
	$(call print_success,Virtual environment removed)

# ============================================================================
# Development
# ============================================================================
##@ 🛠️ Development

.PHONY: dev-run dev-check dev-format dev-test

dev-run: ## Run the application (`main.py`)
	$(call print_section,Running application)
	uv run python main.py  # <- Adjust to your entry point

dev-check: ## Lint + type-check (`ruff check` + `mypy`) — add `FIX=true` to auto-fix
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

dev-format: ## Check formatting (`ruff format`) — add `FIX=true` to apply fixes
	$(call print_section,Formatting code)
ifeq ($(FIX),true)
	uv run ruff check --fix src/ tests/
	uv run ruff format src/ tests/
else
	uv run ruff check src/ tests/
	uv run ruff format --check src/ tests/
endif
	$(call print_success,Formatting complete)

dev-test: ## Run tests (`pytest tests/`)
	$(call print_section,Running tests)
	uv run pytest tests/ -v
	$(call print_success,Tests passed)

# ============================================================================
# Cleaning
# ============================================================================
##@ 🧹 Cleaning

.PHONY: clean clean-all

clean: ## Remove `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`
	$(call print_warning,Cleaning Python cache)
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	$(call print_success,Cleaned)

clean-all: clean clean-env ## `clean` + remove `.venv` (⚠️ DESTRUCTIVE)

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
# MUST stay last (a match-anything rule shadows later pattern rules), and every
# `-include <file>` needs an empty `<file>: ;` rule (see the top of this file).
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
