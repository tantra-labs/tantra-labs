# `vyapaar-fe` — Subagent Migration & DDD Refactoring Guide

> **Tier**: Tier 5B
> **Source**: `/home/pmallapp/Devel/Finance/honba-workspace/honba-fe`
> **Target**: `/home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-fe`

---

## 1. File-by-File Migration Steps
1. Copy `package.json`, `tsconfig*.json`, `vite.config.*`, `index.html`, `src/`, `public/`, and `tests/` from `honba-workspace/honba-fe` to `vyapaar-labs/vyapaar-fe` (excluding `node_modules/` and `dist/`).
2. Update `package.json` `"name": "vyapaar-fe"` and replace `honba` / `Honba` references in `src/` with `vyapaar` / `Vyapaar`.
3. Ensure tests reside in `tests/` (or parallel test directories configured in `vitest.config.ts`).

## 2. Verification Commands
```bash
cd /home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-fe
npm run build
```
