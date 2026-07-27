# todo.mk — TODO tracking. TODO.md is a VIEW over the code, never a backlog file.
# Include it like any other module: include ./makefiles/todo.mk
#
# Why generated: a hand-maintained TODO list is "the one document to rule them
# all" — it goes stale the moment someone fixes something without updating it.
# Keep the TODO next to the code it concerns, then regenerate.
# See: https://olshansky.substack.com/p/move-fast-and-document-things
#
# Two tiers, pick per project:
#   todo-list  zero dependencies, works in any language — counts per prefix.
#   todo       richer TODO.md (multi-line TODOs, `(#123, @handle)` annotations)
#              via modules/todo-scripts/gen_todo.py — needs Python. Copy that
#              script to scripts/gen_todo.py when scaffolding a Python project.
#
# Prefix taxonomy (most urgent first). Say what to do AND why it is deferred —
# a bare `TODO: fix this` helps nobody.
#   FIXME               🔴 known bug — it is broken today
#   TODO_IN_THIS_PR     🔴 must land before this PR merges
#   HACK                🟠 temporary workaround
#   TODO_REMOVE_LATER   🟠 temporary code with an explicit exit condition
#   TODO_TECHDEBT       🟡 debt, next scheduled cleanup
#   TODO_BETA           🟡 required before beta
#   TODO_PROD           🟡 required before production
#   TODO_OPTIMIZE       🟡 performance, once a measurement justifies it
#   TODO_IMPROVE        🟢 code quality / refactor
#   TODO_CONSIDERATION  🟢 design decision to revisit
#   TODO_FUTURE         🟢 deferred work, no date
#   TODO_IDEA           🟢 speculative
#   TODO                🟢 general
# NOTE: is deliberately NOT tracked — it marks an explanation, not work.

TODO_PREFIXES ?= FIXME TODO_IN_THIS_PR HACK TODO_REMOVE_LATER TODO_TECHDEBT \
	TODO_BETA TODO_PROD TODO_OPTIMIZE TODO_IMPROVE TODO_CONSIDERATION \
	TODO_FUTURE TODO_IDEA TODO
TODO_SCRIPT ?= scripts/gen_todo.py

# NOTE: -I (skip binary files) and the build-artifact exclusions are
# load-bearing. Compiled output (.pyc, bundles, minified JS) embeds source
# string literals, so without them a grep count reports TODOs that no human
# ever wrote. Keep this list in sync with EXCLUDED_PATHS in the generator.
#
# -E is also load-bearing: an annotated TODO reads `TODO_PROD(#123, @you):`, so
# a literal "PREFIX:" search silently misses every annotated item.
TODO_GREP_FLAGS ?= -rnIE --exclude-dir=.git --exclude-dir=.venv \
	--exclude-dir=node_modules --exclude-dir=__pycache__ --exclude-dir=dist \
	--exclude-dir=build --exclude-dir=target --exclude-dir=.next \
	--exclude=TODO.md --exclude=gen_todo.py --exclude=todo.mk

##@ 📋 TODOs

.PHONY: todo todo-check todo-list

# NOTE: descriptions below name `scripts/gen_todo.py` literally rather than
# `$(TODO_SCRIPT)` — a var in a `## ` comment only expands if you add its name
# to HELP_VARS (see help.mk).
todo: ## Regenerate `TODO.md` from prefixed code comments (needs `scripts/gen_todo.py`)
	@if [ ! -f "$(TODO_SCRIPT)" ]; then \
		printf "$(YELLOW)$(TODO_SCRIPT) not found.$(RESET)\n"; \
		printf "$(DIM)Copy it from the cmd-makefile skill:$(RESET)\n"; \
		printf "  $(CYAN)cp <skill>/modules/todo-scripts/gen_todo.py $(TODO_SCRIPT)$(RESET)\n"; \
		printf "$(DIM)Or use '$(RESET)$(CYAN)make todo-list$(RESET)$(DIM)', which needs nothing.$(RESET)\n"; \
		exit 1; \
	fi
	@python3 $(TODO_SCRIPT)

todo-check: ## Fail if `TODO.md` is stale — wire into CI
	@python3 $(TODO_SCRIPT) --check

todo-list: ## Count TODOs by prefix (`make todo-list p=TODO_PROD` to list one)
	@if [ -n "$(p)" ]; then \
		grep $(TODO_GREP_FLAGS) -- "$(p)(\(.*\))?:" . || printf "$(DIM)No $(p) items.$(RESET)\n"; \
	else \
		total=0; \
		for prefix in $(TODO_PREFIXES); do \
			n=$$(grep $(TODO_GREP_FLAGS) -- "$$prefix(\(.*\))?:" . 2>/dev/null | wc -l | tr -d ' '); \
			if [ "$$n" != "0" ]; then \
				printf "  $(CYAN)%-22s$(RESET) %s\n" "$$prefix" "$$n"; \
				total=$$((total + n)); \
			fi; \
		done; \
		if [ "$$total" = "0" ]; then printf "  $(GREEN)No open TODOs.$(RESET)\n"; fi; \
	fi
