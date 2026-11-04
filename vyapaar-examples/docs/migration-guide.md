# `vyapaar-examples` — Subagent Migration & DDD Refactoring Guide

> **Tier**: Tier 6D
> **Source**: `/home/pmallapp/Devel/Finance/honba-workspace/honba-examples`
> **Target**: `/home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-examples`

---

## 1. Migration & DDD Refactoring Steps
1. **Fix `pyproject.toml`**:
   - Remove invalid `"rust_decimal>=1.0.0"` from `vyapaar-examples/pyproject.toml`.
2. **Port Shared Library, Examples & Tests**:
   - Copy `honba-workspace/honba-examples/src/honba_examples/*` into `vyapaar-labs/vyapaar-examples/vyapaar_examples/`.
   - Copy `honba-workspace/honba-examples/examples/*` into `vyapaar-labs/vyapaar-examples/examples/`.
   - Copy `honba-workspace/honba-examples/tests/*` into `vyapaar-labs/vyapaar-examples/tests/`.
   - Replace `honba_examples` → `vyapaar_examples` and `honba` → `vyapaar` across all scripts and docstrings.

## 2. Verification Commands
```bash
cd /home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-examples
pytest -q
ruff check .
```
