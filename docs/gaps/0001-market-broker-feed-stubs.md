# 0001 — Real broker WS feed crates for `tantra-market`

**Status**: open — **feature tracker, 2 of 5 shipped 2026-11-13 (T3.3)**.

**Provider repo**: `tantra-market`

## What's real

Two broker adapters are real `MarketDataFeed` implementations on
`tantra-market-core`'s `WsClient`/`SymbolMapper`/`ReconnectionManager`, each with
golden-byte-tested wire decoders (see `tantra-market/docs/gaps/0003`):

- `tantra-market-dhan` — DhanHQ v2 Live Market Feed (JSON requests, little-endian
  binary packets), commit `fb82571`.
- `tantra-market-zerodha` — Kite Connect 3 ticker (JSON requests, binary frames),
  commit `ad79205`.

Both convert every price/quantity to exact `Decimal` before entering a canonical
`Tick`. Live verification against real credentials is a manual follow-on for each.

## What remains

The following crates are **not** present in the workspace and are re-added only
as real crates with actual wire protocols implemented (per gap-tracking §4,
re-adding an empty stub is forbidden):

- `tantra-market-upstox` — binary WebSocket feed; protocol at upstox.com docs.
- `tantra-market-fyers` — v3 Data Socket is JSON-text (responses documented; the
  raw subscribe request must be captured from the official `fyers_apiv3` SDK).
- `tantra-market-angelone` — SmartAPI 2.0 WebSocket; protocol at
  smartapi.angelbroking.com.

## Verification

`cargo check --workspace --profile prod` passes with the two real crates; no
other workspace declares a path dependency on the remaining three.
