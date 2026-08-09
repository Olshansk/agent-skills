########################
### Makefile Helpers ###
########################

BOLD := \033[1m
BLUE := \033[34m
CYAN := \033[36m
DIM := \033[2m
GREEN := \033[32m
RED := \033[31m
RESET := \033[0m

.DEFAULT_GOAL := help

REPO_SKILLS := $(CURDIR)/skills
REPO_AGENTS := $(CURDIR)/agents
THIRDPARTY_SKILLS := $(HOME)/.agents/skills
SKILL_LOCKFILE := $(HOME)/.agents/.skill-lock.json
REPO_SOURCE := olshansk/agent-skills
SHARE_TARGETS := $(HOME)/.gemini/antigravity/skills $(HOME)/.codex/skills
CONFIGS_DIR ?= $(HOME)/workspace/configs
PROFILE ?= personal
HOST ?= $(shell scutil --get LocalHostName 2>/dev/null || hostname -s)
TOOLS ?= all
DRY_RUN ?= 0

########################
### Skills           ###
########################

##@ 🧠 Skills

ALL_TARGETS := $(HOME)/.claude/skills $(SHARE_TARGETS)

.PHONY: link-skills
link-skills: ## Symlink repo + third-party skills into Claude, Gemini, and Codex
	@echo "=== Cleaning stale installed repo skills ==="; \
	if [ -f "$(SKILL_LOCKFILE)" ] && command -v jq >/dev/null 2>&1 && [ -d "$(THIRDPARTY_SKILLS)" ]; then \
		jq -r --arg source "$(REPO_SOURCE)" '.skills | to_entries[] | select(.value.source == $$source) | .key' "$(SKILL_LOCKFILE)" | while IFS= read -r name; do \
			[ -n "$$name" ] || continue; \
			case "$$name" in */*) continue ;; esac; \
			[ -d "$(REPO_SKILLS)/$$name" ] && continue; \
			installed="$(THIRDPARTY_SKILLS)/$$name"; \
			[ -e "$$installed" ] || [ -L "$$installed" ] || continue; \
			rm -rf "$$installed"; \
			echo "  - $$name (stale repo install)"; \
		done; \
	else \
		echo "  Skipped: jq or skill lockfile unavailable"; \
	fi
	@for target_dir in $(ALL_TARGETS); do \
		mkdir -p "$$target_dir"; \
		echo "=== $$target_dir ==="; \
		if [ -d "$(THIRDPARTY_SKILLS)" ]; then \
			for skill in $(THIRDPARTY_SKILLS)/*/; do \
				name=$$(basename "$$skill"); \
				link="$$target_dir/$$name"; \
				if [ -L "$$link" ]; then \
					current=$$(readlink "$$link"); \
					if [ "$$current" != "$$skill" ]; then \
						rm "$$link"; \
						ln -s "$$skill" "$$link"; \
						echo "  ~ $$name (3rd-party, repointed)"; \
					fi; \
				elif [ -d "$$link" ]; then \
					rm -rf "$$link"; \
					ln -s "$$skill" "$$link"; \
					echo "  ~ $$name (3rd-party, replaced real dir)"; \
				else \
					ln -s "$$skill" "$$link"; \
					echo "  + $$name (3rd-party)"; \
				fi; \
			done; \
		fi; \
		for skill in $(REPO_SKILLS)/*/; do \
			name=$$(basename "$$skill"); \
			link="$$target_dir/$$name"; \
			if [ -L "$$link" ]; then \
				current=$$(readlink "$$link"); \
				if [ "$$current" != "$$skill" ]; then \
					rm "$$link"; \
					ln -s "$$skill" "$$link"; \
					echo "  ~ $$name (repo, repointed)"; \
				fi; \
			elif [ -d "$$link" ]; then \
				rm -rf "$$link"; \
				ln -s "$$skill" "$$link"; \
				echo "  ~ $$name (repo, replaced real dir)"; \
			else \
				ln -s "$$skill" "$$link"; \
				echo "  + $$name (repo)"; \
			fi; \
		done; \
		for link in "$$target_dir"/*; do \
			[ -L "$$link" ] || continue; \
			readlink "$$link" | grep -q -e "$(REPO_SKILLS)" -e "$(THIRDPARTY_SKILLS)" || continue; \
			[ -e "$$link" ] || { echo "  - $$(basename $$link) (stale)"; rm -f "$$link"; }; \
		done; \
	done
	@echo ""
	@echo "=== Agent instructions ==="
	@for pair in "$(HOME)/.claude/CLAUDE.md:$(REPO_AGENTS)/AGENTS.md" \
	             "$(HOME)/.codex/AGENTS.md:$(REPO_AGENTS)/AGENTS.md" \
	             "$(HOME)/.gemini/GEMINI.md:$(REPO_AGENTS)/MEMORIES.md"; do \
		link="$${pair%%:*}"; \
		target="$${pair##*:}"; \
		dir=$$(dirname "$$link"); \
		mkdir -p "$$dir"; \
		if [ -L "$$link" ]; then \
			current=$$(readlink "$$link"); \
			if [ "$$current" != "$$target" ]; then \
				rm "$$link"; \
				ln -s "$$target" "$$link"; \
				echo "  ~ $$(basename $$link) → $$target (repointed)"; \
			else \
				echo "  ✓ $$(basename $$link) (ok)"; \
			fi; \
		else \
			[ -f "$$link" ] && rm "$$link"; \
			ln -s "$$target" "$$link"; \
			echo "  + $$(basename $$link) → $$target"; \
		fi; \
	done
	@echo "Done"

.PHONY: list-skills
list-skills: ## List all skills with descriptions
	@echo ""
	@echo "$(BOLD)$(CYAN)Published Skills$(RESET)"
	@echo ""
	@for skill in $(REPO_SKILLS)/*/SKILL.md; do \
		name=$$(grep "^name:" "$$skill" | sed 's/name: *//'); \
		desc=$$(grep "^description:" "$$skill" | sed 's/description: *//; s/^"//; s/"$$//'); \
		printf "  $(CYAN)%-35s$(RESET) %s\n" "$$name" "$$desc"; \
	done
	@echo ""

#############################
### Configuration         ###
#############################

##@ ⚙️ Configuration

CONFIG_ARGS = PROFILE="$(PROFILE)" HOST="$(HOST)" TOOLS="$(TOOLS)" DRY_RUN="$(DRY_RUN)" AGENT_SKILLS_DIR="$(CURDIR)"

.PHONY: _check-configs
_check-configs:
	@test -x "$(CONFIGS_DIR)/scripts/config-sync.sh" || { \
		echo "Missing config sync implementation: $(CONFIGS_DIR)/scripts/config-sync.sh"; \
		echo "Set CONFIGS_DIR=/path/to/configs or install the configs workflow."; \
		exit 1; \
	}

.PHONY: config-review
config-review: _check-configs ## Review workstation configuration drift without changing files
	@$(MAKE) -C "$(CONFIGS_DIR)" review $(CONFIG_ARGS)

.PHONY: config-secrets-check
config-secrets-check: _check-configs ## Scan tracked workstation configuration for literal secrets
	@$(MAKE) -C "$(CONFIGS_DIR)" secrets-check $(CONFIG_ARGS)

.PHONY: config-backup
config-backup: _check-configs ## Back up managed workstation configuration
	@$(MAKE) -C "$(CONFIGS_DIR)" backup $(CONFIG_ARGS)

.PHONY: config-snapshot
config-snapshot: _check-configs ## Snapshot selected live configuration outside the repository
	@$(MAKE) -C "$(CONFIGS_DIR)" snapshot $(CONFIG_ARGS)

.PHONY: config-setup
config-setup: _check-configs ## Back up and install canonical workstation configuration
	@$(MAKE) -C "$(CONFIGS_DIR)" setup $(CONFIG_ARGS)

.PHONY: setup
setup: config-setup link-skills ## Set up workstation configuration and agent skills

.PHONY: sync
sync: config-snapshot ## Deprecated alias for an explicit external snapshot
	@echo "sync is deprecated; use config-review, config-backup, config-snapshot, or config-setup"

.PHONY: publish
publish: ## Install all skills globally via npx (for skills.sh telemetry), then restore local symlinks
	@echo "Installing all skills globally via npx..."
	@cd ~ && npx skills add olshansk/agent-skills --all -g -y
	@echo ""
	@echo "Restoring local symlinks..."
	@$(MAKE) link-skills

########################
### Testing          ###
########################

##@ 🧪 Testing

STRESS_SKILL ?= cmd-pr-conflict-resolver
STRESS_COUNT ?= 50

.PHONY: stress-install
stress-install: ## Reinstall a single skill N times (testing only)
	@echo "Stress-testing: installing '$(STRESS_SKILL)' $(STRESS_COUNT) times..."
	@for i in $$(seq 1 $(STRESS_COUNT)); do \
		echo "=== Run $$i/$(STRESS_COUNT) ==="; \
		cd ~ && npx skills add olshansk/agent-skills --skill $(STRESS_SKILL) -g -a '*' -y; \
	done
	@echo ""
	@echo "Restoring local symlinks..."
	@$(MAKE) link-skills
	@echo "Done — $(STRESS_COUNT) installs completed"

########################
### Info             ###
########################

##@ 📋 Repository Info

.PHONY: status
status: ## Show repository status
	@echo "Repository Status:"
	@echo "  Skills:  $$(find skills -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ') skills"
	@echo "  Claude:  $$(find personal/configs/claude -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ') config files"
	@echo "  Gemini:  $$(find personal/configs/gemini -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ') config files"
	@echo "  Codex:   $$(find personal/configs/codex -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ') config files"

.PHONY: test
test: ## Validate skill frontmatter and repo consistency
	@echo "Running checks..."
	@errors=0; \
	for skill in $(REPO_SKILLS)/*/SKILL.md; do \
		name=$$(grep "^name:" "$$skill" | sed 's/name: *//'); \
		desc=$$(grep "^description:" "$$skill" | sed 's/description: *//'); \
		dir_name=$$(basename $$(dirname "$$skill")); \
		if [ -z "$$name" ]; then \
			echo "  FAIL $$dir_name: missing 'name' in frontmatter"; errors=$$((errors+1)); \
		elif [ "$$name" != "$$dir_name" ]; then \
			echo "  FAIL $$dir_name: name '$$name' doesn't match directory"; errors=$$((errors+1)); \
		fi; \
		if [ -z "$$desc" ]; then \
			echo "  FAIL $$dir_name: missing 'description' in frontmatter"; errors=$$((errors+1)); \
		fi; \
	done; \
	skill_count=$$(find skills -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' '); \
	skillmd_count=$$(find skills -name SKILL.md | wc -l | tr -d ' '); \
	if [ "$$skill_count" != "$$skillmd_count" ]; then \
		echo "  FAIL skill dir count ($$skill_count) != SKILL.md count ($$skillmd_count)"; errors=$$((errors+1)); \
	fi; \
	echo "  $$skill_count skills checked"; \
	if [ $$errors -gt 0 ]; then \
		echo "FAILED: $$errors error(s)"; exit 1; \
	else \
		echo "All checks passed"; \
	fi

HELP_TITLE ?= Agent Skills — Make Targets
HELP_ICON ?= 🧠
HELP_TAGLINE ?= Skills, configuration, testing, and repository information.
HELP_WIDTH ?= 46
HELP_PAD ?= 24
include skills/cmd-makefile/modules/help.mk
