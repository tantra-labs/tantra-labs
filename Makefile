REPOS := vyapaar-core vyapaar-risk vyapaar-ledger vyapaar-market vyapaar-exec vyapaar-runtime vyapaar-agent vyapaar-ffi vyapaar-ui

.PHONY: default build build-dev build-prod build-release build-debug dev prod release debug check check-dev check-prod test fmt clippy clean

# Default build is 'prod' (no debug build unless asked for specifically)
default: prod
build: prod

prod: build-prod
build-prod:
	@for r in $(REPOS); do echo "==> $$r (prod)"; (cd $$r && $(MAKE) prod); done

release: build-release
build-release:
	@for r in $(REPOS); do echo "==> $$r (release)"; (cd $$r && $(MAKE) release); done

dev: build-dev
build-dev:
	@for r in $(REPOS); do echo "==> $$r (dev)"; (cd $$r && $(MAKE) dev); done

# Debug build is explicit and not run unless asked
debug: build-debug
build-debug:
	@for r in $(REPOS); do echo "==> $$r (debug)"; (cd $$r && $(MAKE) debug); done

check: check-prod
check-prod:
	@for r in $(REPOS); do echo "==> checking $$r (prod)"; (cd $$r && $(MAKE) check-prod); done

check-dev:
	@for r in $(REPOS); do echo "==> checking $$r (dev)"; (cd $$r && $(MAKE) check-dev); done

test:
	@for r in $(REPOS); do echo "==> test $$r"; (cd $$r && $(MAKE) test); done

fmt:
	@for r in $(REPOS); do (cd $$r && $(MAKE) fmt); done

clippy:
	@for r in $(REPOS); do (cd $$r && $(MAKE) clippy); done

clean:
	@for r in $(REPOS); do echo "==> cleaning $$r"; (cd $$r && $(MAKE) clean); done
	@find . -type d -name target -prune -exec rm -rf {} +

# ---- frontends & ui -------------------------------------------------------
# `dev-ui` starts dev mode on vyapaar-ui (WASM Studio / CLI / TUI).
# `dev-fe` starts dev mode on vyapaar-fe (React/Vite desktop UI when present).
.PHONY: build-ui dev-ui dev-fe build-kao dev-kao

build-ui:
	@if [ -f vyapaar-ui/Trunk.toml ]; then \
	  if command -v trunk >/dev/null 2>&1; then \
	    echo "==> vyapaar-ui (trunk)"; \
	    (cd vyapaar-ui && trunk build --release); \
	  else \
	    echo "skip vyapaar-ui: install trunk with 'cargo install --locked trunk'"; \
	  fi; \
	else \
	  echo "==> vyapaar-ui (prod)"; \
	  (cd vyapaar-ui && $(MAKE) prod); \
	fi

dev-ui:
	@if [ -f vyapaar-ui/Trunk.toml ]; then \
	  if command -v trunk >/dev/null 2>&1; then \
	    (cd vyapaar-ui && $(MAKE) serve); \
	  else \
	    echo "trunk not installed"; exit 1; \
	  fi; \
	else \
	  (cd vyapaar-ui && $(MAKE) dev); \
	fi

dev-fe:
	@if [ -d vyapaar-fe ]; then \
	  (cd vyapaar-fe && $(MAKE) dev); \
	else \
	  echo "vyapaar-fe directory not found"; exit 1; \
	fi

# Backward-compatible aliases for honba migration muscle memory
build-kao: build-ui
dev-kao: dev-ui

# ---- documentation --------------------------------------------------------
.PHONY: docs docs-build docs-serve docs-clean

docs: docs-build
docs-build:
	(cd vyapaar-docs && $(MAKE) build)

docs-serve:
	(cd vyapaar-docs && $(MAKE) serve)

docs-clean:
	(cd vyapaar-docs && $(MAKE) clean)

# ---- ssh agent + push all repos ------------------------------------------
.PHONY: push

SSH_DEV_KEY := $(HOME)/.ssh/remotes/github.com-dev/id_ed25519_dev_pmallapp_github_gmail
ALL_REPOS := $(shell find . -maxdepth 2 -name .git -printf '%h\n' | sed 's#^\./##' | sort)

# Adds the dev github key to an ssh-agent and pushes every repo in the
# workspace. If no agent is already reachable via $SSH_AUTH_SOCK, a
# throwaway one is started just for this run and killed on exit.
push:
	@ssh-add -l >/dev/null 2>&1; rc=$$?; \
	if [ $$rc -eq 2 ]; then \
	  echo "starting a throwaway ssh-agent for this run"; \
	  eval "$$(ssh-agent -s)" >/dev/null; \
	  trap 'ssh-agent -k >/dev/null 2>&1' EXIT; \
	fi; \
	if [ -f "$(SSH_DEV_KEY)" ]; then \
	  ssh-add $(SSH_DEV_KEY); \
	fi; \
	for r in $(ALL_REPOS); do \
	  echo "==> pushing $$r"; \
	  (cd $$r && git push) || echo "!! push failed: $$r"; \
	done
