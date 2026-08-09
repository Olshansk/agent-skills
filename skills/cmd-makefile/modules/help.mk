# help.mk — GENERATED `make help`. Never hand-maintain a help block.
#
# Include it LAST, after colors.mk and every other include:
#
#   include ./makefiles/colors.mk
#   include ./makefiles/env.mk        # 📦 Environment
#   include ./makefiles/dev.mk        # 🛠️ Development
#   include ./makefiles/help.mk       # ❓ Help  <- last, so it renders last
#
# Sections render in include order, so including this first would put the Help
# section above your project's real targets.
#
# Requires: colors.mk (BOLD/DIM/BLUE/CYAN/YELLOW/RESET) and SHELL := /bin/bash.
#
# ============================================================================
# How it works
# ============================================================================
# Two kinds of comment drive the entire output:
#
#   ##@ 🐘 Database & Migrations   declares a section (emoji lives HERE, only here)
#   db-migrate: ## Apply migrations   documents a target under the current section
#
# Because it reads the makefiles themselves, help can never drift from the real
# targets — which is exactly what a hand-written help block cannot promise.
#
# ============================================================================
# Rules
# ============================================================================
# 1. Emoji go on SECTION HEADERS, never on target lines. Per-target emoji have
#    inconsistent display widths — ⬆️ ♻️ 🖥️ render 1 cell, 🐘 🚀 📦 render 2 —
#    so the description column jitters line to line and the list stops scanning.
# 2. Sections render in FILE ORDER, files in INCLUDE ORDER. The include list in
#    the root Makefile IS the help ordering. No alphabetical sort.
# 3. Every .mk declares its own ##@ section before its targets — the section
#    resets at each file boundary. `make help-unclassified` catches misses.
# 4. Mark genuinely destructive/prod targets with a trailing "(⚠️ …)" in the
#    description; it renders yellow. Three per project, not thirty — sparing use
#    is the only thing that keeps the marker meaningful.
# 5. Wrap literals in `backticks` — commands, files, paths, tool names, target
#    names, env vars. They render green and the backticks are stripped:
#      env-install: ## Install all deps (`uv sync --all-extras`)
#      api-export-spec: ## Export OpenAPI spec to `openapi.json`
#    Leave prose plain ("needs db + redis", "prod-like, guarded"). Marking up
#    everything is the same as marking up nothing.
# 6. Color tiers, standard 16-color ANSI so light and dark themes both work:
#    BOLD+BLUE headers, CYAN target names, default-fg descriptions, GREEN
#    literals, YELLOW danger. Headers and target names must never share a hue.
#
# ============================================================================
# Tunables — set these BEFORE including this file
# ============================================================================
# Keep emoji OUT of HELP_TITLE (they are 2 cells wide but 1 character, which
# throws off the banner padding). Use HELP_ICON for the emoji instead.
HELP_TITLE   ?= $(notdir $(CURDIR)) — Make Targets
HELP_ICON    ?= 🛠️
HELP_TAGLINE ?=
HELP_WIDTH   ?= 46
HELP_PAD     ?= 24

# Make vars referenced inside `## ` descriptions, e.g. `## Run on port $(PORT)`.
# awk reads raw file text, so make never expands them; this substitutes real
# values at render time. Falls back to `cat` when there is nothing to expand.
#   HELP_VARS := API_PORT DATASETTE_PORT
HELP_VARS ?=
HELP_SED   = $(if $(HELP_VARS),sed $(foreach v,$(HELP_VARS),-e 's|[$$]($(v))|$($(v))|g'),cat)

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
			gsub(/\(⚠️[^)]*\)/, "$(YELLOW)&$(RESET)", desc); \
			w = pad - length(name); if (w < 1) w = 1; \
			found = 1; printf "  $(CYAN)%s$(RESET)%*s%s\n", name, w, "", desc \
		} \
		END { if (!found) printf "  $(DIM)(none — every documented target has a section)$(RESET)\n" } \
		' $(MAKEFILE_LIST)
	@printf "\n"
