#!/usr/bin/env bash
# ==============================================================================
# scripts/create-remote-repos.sh
# 
# Provision all remote GitHub repositories under the org: vyapaar-labs
# using GitHub CLI (gh).
#
# Prerequisite:
#   The GitHub Organization 'vyapaar-labs' must first be created via GitHub Web:
#   https://github.com/account/organizations/new
#
# Usage:
#   ./scripts/create-remote-repos.sh [--dry-run] [--public|--private]
# ==============================================================================

set -euo pipefail

ORG="vyapaar-labs"
VISIBILITY="public"
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --public)
            VISIBILITY="public"
            ;;
        --private)
            VISIBILITY="private"
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--public|--private]"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

echo "=================================================================="
echo "Vyapaar Labs — Remote Repository Provisioner"
echo "Target Organization: $ORG"
echo "Repository Visibility: $VISIBILITY"
echo "Dry Run Mode: $DRY_RUN"
echo "=================================================================="

# Check if gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "ERROR: GitHub CLI (gh) is not authenticated. Run 'gh auth login' first."
    exit 1
fi

# Verify organization exists
if ! gh api "orgs/$ORG" >/dev/null 2>&1; then
    echo ""
    echo "❌ ERROR: Organization '$ORG' does not exist on GitHub yet or you lack access."
    echo ""
    echo "GitHub does not allow organization creation via CLI or REST API."
    echo "Please create the organization first in your browser:"
    echo "👉 https://github.com/account/organizations/new"
    echo ""
    echo "Once created, re-run this script: $0 $@"
    exit 1
fi

echo "✓ Organization '$ORG' verified on GitHub."

# Repository definition list: NAME|DESCRIPTION
REPOS=(
    "vyapaar-labs|Vyapaar Labs superproject workspace: autonomous, high-throughput, AI-native algorithmic trading platform for Indian markets (NSE/BSE)"
    "vyapaar-core|Shared Kernel: Canonical Decimal value objects (Price, Quantity, Money), InstrumentId, Order, Decision, OpenAPI schemas"
    "vyapaar-ledger|Domain Heart: Order Management System (OMS), FIFO tax-lot tracking, double-entry general ledger"
    "vyapaar-risk|Regulatory Risk Gate: Sub-15 µs pre-trade risk engine (SEBI algo ID, OTR circuit breakers, price bands, freeze limits)"
    "vyapaar-market|Market Data: Multi-broker binary WebSockets, tick coalescing, 100+ indicators, Parquet Lakehouse"
    "vyapaar-exec|Execution Gateway: Broker executors, headless TOTP auth, freeze slicer, Smart Order Router (SOR)"
    "vyapaar-runtime|Central Runtime & Automation: Tokio actor pipeline, backtester, strategy enhancer, Axum REST/WS API"
    "vyapaar-agent|AI Agent Engine: LLM providers, trader loop, prompt replay, genetic synthesizer, MCP server"
    "vyapaar-ffi|Python FFI Bridge: Apache Arrow zero-copy memory bridge, PyO3 bindings for vyapaar wheel"
    "vyapaar-ui|Unified Workstations: WASM Strategy Studio, openalgo-charts, Ratatui TUI, CLI binary"
    "vyapaar-strategies|Production Strategies: Institutional trading strategies (Quoting, Arbitrage, TWAP/VWAP, Turtle, Risk Parity)"
    "vyapaar-adapters|Broker SDK: Python community broker connectors (Dhan, Zerodha, Upstox, Angel One, Fyers, Kotak)"
    "vyapaar-data|Data Lakehouse: Point-in-time corporate actions, splits, dividends, coverage ledgers, DuckDB/Parquet catalog"
    "vyapaar-examples|Learning Path: Runnable Python reference scripts for Indian equities, options, and factor models"
    "vyapaar-fe|Web Desktop UI: Dockview modular workspace, trading terminal, real-time depth, screener"
    "vyapaar-docs|Documentation: Comprehensive architecture, API references, tutorials, and user guides"
    ".github|Organization health files, profile README, and shared GitHub Actions workflows"
)

TOTAL=${#REPOS[@]}
COUNT=0

echo ""
echo "Provisioning $TOTAL repositories under '$ORG'..."
echo ""

for entry in "${REPOS[@]}"; do
    NAME="${entry%%|*}"
    DESC="${entry#*|}"
    FULL_NAME="$ORG/$NAME"
    COUNT=$((COUNT + 1))

    echo "[$COUNT/$TOTAL] Checking $FULL_NAME..."

    # Check if repo already exists
    if gh repo view "$FULL_NAME" >/dev/null 2>&1; then
        echo "  ↳ Exists already. Skipping creation."
    else
        CMD=(gh repo create "$FULL_NAME" "--$VISIBILITY" --description "$DESC")
        if [ "$DRY_RUN" = true ]; then
            echo "  ↳ [DRY-RUN] Would run: ${CMD[*]}"
        else
            echo "  ↳ Creating $FULL_NAME ($VISIBILITY)..."
            "${CMD[@]}"
            echo "  ✓ Created $FULL_NAME"
        fi
    fi
done

echo ""
echo "=================================================================="
echo "Repository provisioning completed!"
echo "=================================================================="
