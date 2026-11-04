# `vyapaar-fe` — DDD Architecture & Web Desktop UI Bounded Context

## 1. Bounded Context & Responsibility
`vyapaar-fe` (Tier 5B, ported from `honba-fe`) is the **TypeScript Dockview Modular Web Desktop** providing multi-window workspace docking, real-time order book depth, institutional screener, strategy studio, and portfolio blotters connected to `vyapaar-runtime-api-rest`.

## 2. Frontend Domain Invariants
* **String-Encoded Decimal Wire Contract**: All prices, quantities, and PnL values received over REST/WebSocket are parsed using exact decimal representations (never naive float addition for order sizing).
* **Feature-Sliced Modular Architecture**: Strictly separated `features/` (`screener`, `terminal`, `portfolio`, `studio`, `risk`), `services/` (typed OpenAPI REST + `/ws/live` client), and `components/` (design system atoms).
