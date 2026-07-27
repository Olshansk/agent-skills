# Base Makefile Template
# Copy this file to your project root as 'Makefile'
# Customize the targets section for your project needs

.DEFAULT_GOAL := help

# ============================================================================
# Configuration
# ============================================================================
# Env loading: `-include .env` is convenient but LOSES to already-exported
# shell vars (e.g. `export DATABASE_URL=...` in ~/.zshrc wins silently).
# For any recipe that depends on a specific .env value, inline-source instead:
#   recipe:
#       @set -a && . ./.env && set +a && <command>
# Also ship a committed `.template.env` and a `make env-template` bootstrap
# that copies it to `.env` (see SKILL.md "`.env` / `.template.env` Bootstrap").
-include .env
.EXPORT_ALL_VARIABLES:

# Optionally-included files are NOT build targets. Without these empty rules,
# `-include .env` makes `.env` a goal, the catch-all at the bottom claims it,
# and every single `make` run in a fresh clone opens with:
#     ✗ Unknown target '.env'
# An explicit rule beats a match-anything rule, so this silences it for good.
.env .env.prod .template.env: ;

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
#   ##@ 🚀 Section Title      declares a section (emoji lives HERE, only here)
#   target: ## description    documents a target under the current section
#
# Rules:
#   1. Emoji go on section headers, NEVER on target lines. Per-target emoji have
#      inconsistent display widths (⬆️ ♻️ 🖥️ are 1 cell, 🚀 🐘 📦 are 2), which
#      makes the description column jitter and the list stop scanning.
#   2. Sections render in file order — reorder the blocks below to reorder help.
#   3. Mark destructive targets with a trailing "(⚠️ …)"; it renders yellow.
#      A few per project, not a few dozen.
#   4. Wrap literals in `backticks` — commands, files, paths, tool names, target
#      names, env vars. They render green and the backticks are stripped:
#        setup: ## Install dependencies (`uv sync --all-extras`)
#      Leave prose plain; marking up everything is the same as marking up nothing.
#   5. Color tiers: BOLD+BLUE headers, CYAN names, default-fg descriptions,
#      GREEN literals, YELLOW danger. Headers and names never share a hue.
# Keep emoji out of HELP_TITLE (2 cells wide, 1 char — it breaks box padding).
HELP_TITLE   ?= Project Name — Make Targets
HELP_ICON    ?= ✨
HELP_TAGLINE ?=
HELP_WIDTH   ?= 46
HELP_PAD     ?= 24
# Make vars referenced inside `## ` descriptions, e.g. `## Serve on port $(PORT)`.
# awk reads raw file text, so make never expands them; this substitutes at render
# time. Falls back to `cat` when there is nothing to expand.
HELP_VARS ?=
HELP_SED   = $(if $(HELP_VARS),sed $(foreach v,$(HELP_VARS),-e 's|[$$]($(v))|$($(v))|g'),cat)

# ============================================================================
# Your Targets Here
# ============================================================================
# Add your project-specific targets below
# Use the pattern: target: ## Description, under a ##@ section header.

.PHONY: setup run test clean

##@ 🚀 Quick Start

setup: ## First-time project setup (installs deps)
	@printf "$(CYAN)Setting up project...$(RESET)\n"
	# Add your setup commands here
	@printf "$(GREEN)$(CHECK) Setup complete$(RESET)\n"

run: ## Run the application
	@printf "$(CYAN)Starting application...$(RESET)\n"
	# Add your run command here

##@ 🧪 Testing

test: ## Run the test suite
	@printf "$(CYAN)Running tests...$(RESET)\n"
	# Add your test command here (e.g., pytest, npm test, go test)

##@ 🧹 Maintenance

clean: ## Remove generated files and caches
	@printf "$(YELLOW)Cleaning...$(RESET)\n"
	# Add your clean commands here
	@printf "$(GREEN)$(CHECK) Cleaned$(RESET)\n"

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
# Two rules for maintaining this:
#   1. It MUST stay last. A match-anything rule shadows any pattern rule defined
#      after it, so new pattern rules go ABOVE this block.
#   2. Every `-include <file>` needs an empty `<file>: ;` rule (see the top of
#      this file) or this catch-all tries to "build" it on every run.
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
