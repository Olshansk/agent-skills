# colors.mk - ANSI colors and print helpers
# Include this in complex projects: include ./makefiles/colors.mk

# ============================================================================
# ANSI Color Codes
# ============================================================================
# Standard 16 colors only, so output stays readable on both light and dark
# terminal themes. Do not pin 256-color values — they are tuned to one theme.
GREEN     := \033[0;32m
YELLOW    := \033[1;33m
BLUE      := \033[0;34m
CYAN      := \033[0;36m
RED       := \033[0;31m
MAGENTA   := \033[0;35m
BLACK     := \033[0;30m
BOLD      := \033[1m
DIM       := \033[2m
RESET     := \033[0m
BG_YELLOW := \033[43m
BG_BLUE   := \033[44m

# ============================================================================
# `make help` color tiers (see help.mk)
# ============================================================================
#   BOLD+BLUE  section headers      ═══ 🐘 Database & Migrations ═══
#   CYAN       target names         db-migrate
#   (default)  descriptions         Apply migrations (alembic upgrade head)
#   DIM        secondary detail     # uv sync --all-extras
#   YELLOW     inline (⚠️ …) danger  (⚠️ DESTRUCTIVE)
# Headers and target names must never share a hue — that flattens the hierarchy
# into an unscannable wall. Three visibly distinct tiers, no more.

# ============================================================================
# NO_COLOR support (https://no-color.org)
# ============================================================================
# Strips every escape so piped/redirected output stays clean.
# TTY auto-detection is deliberately not attempted: $(shell test -t 1) always
# reports false (subshell stdout is a pipe), and MAKE_TERMOUT needs GNU make >= 4,
# which macOS does not ship.
ifdef NO_COLOR
GREEN     :=
YELLOW    :=
BLUE      :=
CYAN      :=
RED       :=
MAGENTA   :=
BLACK     :=
BOLD      :=
DIM       :=
RESET     :=
BG_YELLOW :=
BG_BLUE   :=
endif

# ============================================================================
# Status Symbols
# ============================================================================
CHECK := ✓
CROSS := ✗
WARN  := ⚠️
INFO  := ℹ️
ARROW := →

# ============================================================================
# Print Helpers
# Usage: $(call print_success,Your message here)
# ============================================================================
define print_success
	@printf "$(GREEN)$(BOLD) $(CHECK) %s$(RESET)\n" "$(1)"
endef

define print_error
	@printf "$(RED)$(BOLD) $(CROSS) %s$(RESET)\n" "$(1)"
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

# Alias for backward compatibility
define print_info_section
	@printf "\n$(CYAN)$(BOLD)%s$(RESET)\n" "$(1)"
endef

# Horizontal rule separator
define print_hr
	@printf "$(DIM)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
endef

# Phase banner: horizontal rule + emoji + title + horizontal rule
# Usage: $(call print_phase,🔑,ENV → LOCAL)
define print_phase
	@printf "\n$(DIM)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n"
	@printf "$(BOLD)$(CYAN) $(1)  $(2)$(RESET)\n"
	@printf "$(DIM)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)\n\n"
endef

# Triple-⚠️ critical warning for irreversible / real-money actions
# Usage: $(call print_critical_warning,MAINNET — REAL MONEY)
define print_critical_warning
	@printf "\n$(RED)$(BOLD)⚠️⚠️⚠️  $(1)  ⚠️⚠️⚠️$(RESET)\n"
endef
