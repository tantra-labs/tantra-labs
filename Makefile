REPOS := tantra-core tantra-risk tantra-ledger tantra-market tantra-exec tantra-runtime tantra-agent tantra-ffi tantra-ui

# Default to the user's persistent agent socket if SSH_AUTH_SOCK is not set in environment
SSH_SOCK := $(if $(XDG_RUNTIME_DIR),$(XDG_RUNTIME_DIR),/run/user/$(shell id -u))/ssh-agent.sock
export SSH_AUTH_SOCK ?= $(SSH_SOCK)

.PHONY: default build build-dev build-prod build-release build-debug dev prod release debug check check-dev check-prod test fmt clippy clean prepare api-gate

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

# Root design 0006 R4 CI gate: clients, examples and docs call only canonical /api/v2 paths,
# and the generated API reference matches the runtime's openapi.v2.json.
api-gate:
	@scripts/check-api-paths.sh
	@python3 tantra-docs/scripts/gen_api_reference.py --check && echo "api reference: OK (matches openapi.v2.json)"

fmt:
	@for r in $(REPOS); do (cd $$r && $(MAKE) fmt); done

clippy:
	@for r in $(REPOS); do (cd $$r && $(MAKE) clippy); done

clean:
	@for r in $(REPOS); do echo "==> cleaning $$r"; (cd $$r && $(MAKE) clean); done
	@find . -type d -name target -prune -exec rm -rf {} +

# ---- single Python venv ---------------------------------------------------
# One workspace venv lives at the repo root (.venv); every Python sub-repo
# symlinks its own .venv here (git-ignored) so `make`/`pytest`/`ruff`/`mkdocs`
# resolve to the same interpreter everywhere. `make prepare` builds it.
.PHONY: prepare venv-link

# Python sub-repos that get a `.venv` symlink -> ../.venv
PY_REPOS := tantra-ffi tantra-adapters tantra-data tantra-strategies tantra-examples tantra-docs

prepare:
	@echo "==> preparing single workspace venv at .venv"
	@test -d .venv || python3 -m venv .venv
	@.venv/bin/python -m ensurepip --upgrade >/dev/null 2>&1 || true
	@.venv/bin/python -m pip install --quiet --upgrade pip
	@echo "==> [1/5] tooling (maturin pytest ruff mypy hypothesis pyarrow pydantic polars duckdb)"
	@.venv/bin/python -m pip install --quiet maturin pytest ruff mypy hypothesis pyarrow pydantic polars duckdb httpx
	@echo "==> [2/5] .venv symlinks in $(PY_REPOS) (before wheel build so maturin targets the shared venv)"
	@for r in $(PY_REPOS); do \
	  rm -rf "$$r/.venv"; \
	  ln -s ../.venv "$$r/.venv"; \
	  echo "    $$r/.venv -> ../.venv"; \
	done
	@echo "==> [3/5] tantra wheel (maturin develop)"
	@cd tantra-ffi && ../.venv/bin/maturin develop --profile prod
	@echo "==> [4/5] editable packages (adapters, data, strategies, examples)"
	@cd tantra-adapters && ../.venv/bin/python -m pip install --quiet --editable .
	@cd tantra-data && ../.venv/bin/python -m pip install --quiet --editable .
	@cd tantra-strategies && ../.venv/bin/python -m pip install --quiet --editable .
	@cd tantra-examples && ../.venv/bin/python -m pip install --quiet --editable .
	@echo "==> [5/5] docs deps (mkdocs-material)"
	@cd tantra-docs && ../.venv/bin/python -m pip install --quiet -r requirements.txt
	@echo "prepare complete: source .venv/bin/activate"

# Re-create the per-repo `.venv` symlinks without reinstalling packages.
venv-link:
	@for r in $(PY_REPOS); do \
	  rm -rf "$$r/.venv"; \
	  ln -s ../.venv "$$r/.venv"; \
	  echo "    $$r/.venv -> ../.venv"; \
	done

# ---- frontends & ui -------------------------------------------------------
# `dev-ui` starts dev mode on tantra-ui (WASM Studio / CLI / TUI).
# `dev-fe` starts dev mode on tantra-fe (React/Vite desktop UI when present).
.PHONY: build-ui dev-ui dev-fe build-kao dev-kao

build-ui:
	@if [ -f tantra-ui/Trunk.toml ]; then \
	  if command -v trunk >/dev/null 2>&1; then \
	    echo "==> tantra-ui (trunk)"; \
	    (cd tantra-ui && trunk build --release --cargo-profile prod); \
	  else \
	    echo "skip tantra-ui: install trunk with 'cargo install --locked trunk'"; \
	  fi; \
	else \
	  echo "==> tantra-ui (prod)"; \
	  (cd tantra-ui && $(MAKE) prod); \
	fi

dev-ui:
	@if [ -f tantra-ui/Trunk.toml ]; then \
	  if command -v trunk >/dev/null 2>&1; then \
	    (cd tantra-ui && $(MAKE) serve); \
	  else \
	    echo "trunk not installed"; exit 1; \
	  fi; \
	else \
	  (cd tantra-ui && $(MAKE) dev); \
	fi

dev-fe:
	@if [ -d tantra-fe ]; then \
	  (cd tantra-fe && $(MAKE) dev); \
	else \
	  echo "tantra-fe directory not found"; exit 1; \
	fi

# Backward-compatible aliases for honba migration muscle memory
build-kao: build-ui
dev-kao: dev-ui

# ---- documentation --------------------------------------------------------
.PHONY: docs docs-build docs-serve docs-clean

docs: docs-build
docs-build:
	(cd tantra-docs && $(MAKE) build)

docs-serve:
	(cd tantra-docs && $(MAKE) serve)

docs-clean:
	(cd tantra-docs && $(MAKE) clean)

# ---- ssh agent + push all repos ------------------------------------------
.PHONY: ssh-agent agent push

SSH_DEV_KEY := $(HOME)/.ssh/remotes/github.com-dev/id_ed25519_dev_pmallapp_github_gmail
ALL_REPOS := $(shell find . -maxdepth 2 -name .git -printf '%h\n' | sed 's#^\./##' | sort)

# Starts persistent ssh-agent if not already running, and loads the dev key
ssh-agent agent:
	@SOCK="$${SSH_AUTH_SOCK:-$(SSH_SOCK)}"; \
	ssh-add -l >/dev/null 2>&1; rc=$$?; \
	if [ $$rc -eq 2 ]; then \
	  echo "==> Starting persistent ssh-agent at $$SOCK"; \
	  rm -f "$$SOCK"; \
	  eval "$$(ssh-agent -a "$$SOCK")" >/dev/null; \
	  if [ -f "$(SSH_DEV_KEY)" ]; then \
	    ssh-add "$(SSH_DEV_KEY)"; \
	  fi; \
	elif [ $$rc -eq 1 ]; then \
	  echo "==> ssh-agent running at $$SOCK (loading key)"; \
	  if [ -f "$(SSH_DEV_KEY)" ]; then \
	    ssh-add "$(SSH_DEV_KEY)"; \
	  fi; \
	else \
	  if [ -f "$(SSH_DEV_KEY)" ]; then \
	    FP="$$(ssh-keygen -lf "$(SSH_DEV_KEY)" 2>/dev/null | awk '{print $$2}')"; \
	    if ! ssh-add -l 2>/dev/null | grep -q "$$FP"; then \
	      echo "==> Loading $(SSH_DEV_KEY) into running agent"; \
	      ssh-add "$(SSH_DEV_KEY)"; \
	    else \
	      echo "==> ssh-agent running at $$SOCK with dev key loaded"; \
	    fi; \
	  else \
	    echo "==> ssh-agent running at $$SOCK"; \
	  fi; \
	fi

# Pushes every repo in the workspace, ensuring ssh-agent is running with the dev key
push: ssh-agent
	@for r in $(ALL_REPOS); do \
	  echo "==> pushing $$r"; \
	  (cd $$r && git push) || echo "!! push failed: $$r"; \
	done

# Pushes every repo in the workspace, ensuring ssh-agent is running with the dev key
pull: ssh-agent
	@for r in $(ALL_REPOS); do \
	  echo "==> pulling $$r"; \
	  (cd $$r && git pull) || echo "!! pull failed: $$r"; \
	done
