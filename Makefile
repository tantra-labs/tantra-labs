REPOS := vyapaar-core vyapaar-risk vyapaar-ledger vyapaar-market vyapaar-exec vyapaar-runtime vyapaar-brain vyapaar-ffi vyapaar-ui

.PHONY: default build build-dev build-prod build-release prod release dev check test fmt clippy clean push

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

check:
	@for r in $(REPOS); do echo "==> checking $$r"; (cd $$r && $(MAKE) check); done

test:
	@for r in $(REPOS); do echo "==> testing $$r"; (cd $$r && $(MAKE) test); done

fmt:
	@for r in $(REPOS); do (cd $$r && $(MAKE) fmt); done

clippy:
	@for r in $(REPOS); do (cd $$r && $(MAKE) clippy); done

clean:
	@for r in $(REPOS); do echo "==> cleaning $$r"; (cd $$r && $(MAKE) clean); done
	@find . -type d -name target -prune -exec rm -rf {} +

push:
	@for r in $(REPOS); do \
	  echo "==> pushing $$r"; \
	  (cd $$r && git push) || echo "!! push failed: $$r"; \
	done
