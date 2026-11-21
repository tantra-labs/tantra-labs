#!/usr/bin/env bash
# ==============================================================================
# Usage: start-llm.sh [start|stop|status|logs] [options]
#
# Start the local LLM server that tantra.jsonc points at
# (http://127.0.0.1:8080/v1, model "qwen3-30b-a3b"). `start` (the default) runs it
# in the background and returns once the model is loaded.
#
#   start     start the server (does nothing if it is already running)
#   stop      stop the server this script started
#   status    show whether it is running and which model it serves
#   logs      follow the server log
#
# Options:
#   --backend llama|vllm   llama (default): llama.cpp on a GGUF, CPU-only — works on
#                          this laptop. vllm: for a machine with an NVIDIA/ROCm GPU.
#   --model M              llama: .gguf path (default: models/Qwen3-30B-A3B-Instruct-2507-Q4_K_M.gguf)
#                          vllm:  HF repo id or dir (default: Qwen/Qwen3-30B-A3B-Instruct-2507)
#   --alias NAME           served model name (default: qwen3-30b-a3b, matches tantra.jsonc)
#   --port N               port (default: 8080)
#   --host H               bind address (default: 127.0.0.1; the server has NO auth)
#   --ctx N                context length (default: 16384)
#   --threads N            llama: CPU threads (default: 8)
#   --gpu-mem F            vllm: GPU memory fraction (default: 0.90)
#   --tp N                 vllm: tensor-parallel size (default: 1)
#   --venv DIR             vllm: venv dir (default: ~/.cache/tantra/vllm-venv)
#   --install              vllm: install vllm into the venv if missing
#   --foreground           run attached (Ctrl+C stops it) instead of in the background
#   --timeout S            seconds to wait for the model to load (llama 600, vllm 1800)
#   --force                skip the free-RAM / GPU checks
#   -h, --help             show this help
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tantra"
PID_FILE="$STATE_DIR/llm-server.pid"
LOG_FILE="$STATE_DIR/llm-server.log"

ACTION="start"
BACKEND="llama"
MODEL=""
ALIAS="qwen3-30b-a3b"
PORT="8080"
HOST="127.0.0.1"
CTX="16384"
THREADS="8"
GPU_MEM="0.90"
TP="1"
VENV="$HOME/.cache/tantra/vllm-venv"
INSTALL=0
FOREGROUND=0
TIMEOUT=""
FORCE=0

die() { echo "start-llm: $*" >&2; exit 1; }
info() { echo "start-llm: $*"; }
usage() { sed -n '3,/^# =====/p' "${BASH_SOURCE[0]}" | sed '$d; s/^# \{0,1\}//'; }

need_arg() { [[ $# -ge 2 && -n "$2" ]] || die "$1 needs a value"; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        start|stop|status|logs) ACTION="$1" ;;
        --backend) need_arg "$@"; BACKEND="$2"; shift ;;
        --model) need_arg "$@"; MODEL="$2"; shift ;;
        --alias) need_arg "$@"; ALIAS="$2"; shift ;;
        --port) need_arg "$@"; PORT="$2"; shift ;;
        --host) need_arg "$@"; HOST="$2"; shift ;;
        --ctx) need_arg "$@"; CTX="$2"; shift ;;
        --threads) need_arg "$@"; THREADS="$2"; shift ;;
        --gpu-mem) need_arg "$@"; GPU_MEM="$2"; shift ;;
        --tp) need_arg "$@"; TP="$2"; shift ;;
        --venv) need_arg "$@"; VENV="$2"; shift ;;
        --install) INSTALL=1 ;;
        --foreground) FOREGROUND=1 ;;
        --timeout) need_arg "$@"; TIMEOUT="$2"; shift ;;
        --force) FORCE=1 ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown argument: $1 (see --help)" ;;
    esac
    shift
done

for n in "$PORT" "$CTX" "$THREADS" "$TP"; do
    [[ "$n" =~ ^[0-9]+$ ]] || die "expected an integer, got '$n'"
done

BASE_URL="http://127.0.0.1:${PORT}/v1"

endpoint_up() { curl -fsS --max-time 3 "${BASE_URL}/models" >/dev/null 2>&1; }

running_pid() {
    [[ -f "$PID_FILE" ]] || return 1
    local pid
    pid="$(cat "$PID_FILE")"
    [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null && { echo "$pid"; return 0; }
    return 1
}

# Model ids the endpoint serves, comma-separated (OpenAI `/v1/models` `data[].id`).
served_models() {
    curl -fsS --max-time 3 "${BASE_URL}/models" 2>/dev/null \
        | grep -oE '"id"[[:space:]]*:[[:space:]]*"[^"]+"' | sed -E 's/.*"([^"]+)"$/\1/' \
        | sort -u | paste -sd, -
}

# Who listens on $PORT: "pid N (started by this script)" or "pid N (<name>, started elsewhere)".
port_owner() {
    local pid name
    if pid="$(running_pid)"; then
        echo "pid $pid, started by this script"
        return
    fi
    pid="$(ss -ltnpH "sport = :${PORT}" 2>/dev/null | grep -oE 'pid=[0-9]+' | head -n1 | cut -d= -f2)"
    if [[ -n "$pid" ]]; then
        name="$(ps -o comm= -p "$pid" 2>/dev/null || true)"
        echo "pid $pid${name:+ ($name)}, started outside this script"
    else
        echo "started outside this script"
    fi
}

report_running() {
    local models
    models="$(served_models)"
    info "LLM server is running and ready"
    echo "  endpoint: ${BASE_URL}"
    echo "  models:   ${models:-unknown}"
    echo "  process:  $(port_owner)"
}

case "$ACTION" in
    status)
        if endpoint_up; then
            report_running
        else
            info "no LLM server is answering at ${BASE_URL}"
            exit 1
        fi
        exit 0 ;;
    logs)
        [[ -f "$LOG_FILE" ]] || die "no log yet at $LOG_FILE"
        exec tail -n 100 -f "$LOG_FILE" ;;
    stop)
        if pid="$(running_pid)"; then
            info "stopping LLM server (pid $pid)"
            kill "$pid"
            for _ in $(seq 1 30); do kill -0 "$pid" 2>/dev/null || break; sleep 1; done
            kill -0 "$pid" 2>/dev/null && { info "still alive, sending SIGKILL"; kill -9 "$pid"; }
            rm -f "$PID_FILE"
        elif endpoint_up; then
            info "an LLM server answers at ${BASE_URL}, but this script did not start it ($(port_owner)); stop that process yourself"
            exit 1
        else
            info "no LLM server is running on port ${PORT}"
        fi
        exit 0 ;;
esac

# ---------------------------------------------------------------- start
if endpoint_up; then
    report_running
    echo "  nothing to do. To restart with other options: $0 stop, then start again."
    if ! running_pid >/dev/null; then
        echo "  (it was not started by this script, so '$0 stop' cannot stop it)"
    fi
    exit 0
fi
if [[ "$HOST" != "127.0.0.1" && "$HOST" != "localhost" ]]; then
    info "WARNING: binding $HOST exposes an unauthenticated LLM endpoint to the network"
fi

mem_available_gb() { awk '/MemAvailable/ { printf "%d", $2 / 1048576 }' /proc/meminfo; }

declare -a CMD
case "$BACKEND" in
    llama)
        command -v llama-server >/dev/null || die "llama-server not found (install llama.cpp)"
        MODEL="${MODEL:-$REPO_ROOT/models/Qwen3-30B-A3B-Instruct-2507-Q4_K_M.gguf}"
        [[ -f "$MODEL" ]] || die "model file not found: $MODEL"
        TIMEOUT="${TIMEOUT:-600}"
        if [[ $FORCE -eq 0 ]]; then
            need_gb=$(( $(stat -c %s "$MODEL") / 1073741824 + 3 ))
            have_gb="$(mem_available_gb)"
            if (( have_gb < need_gb )); then
                die "only ${have_gb} GiB RAM available, model needs ~${need_gb} GiB (it will swap and crawl). Close apps or pass --force"
            fi
        fi
        # --device none: CPU-only (Vulkan on the Radeon 680M hits ErrorDeviceLost).
        # --jinja: use the model's chat template so tool calls work.
        CMD=(llama-server -m "$MODEL" --jinja -c "$CTX" --device none -t "$THREADS"
             --host "$HOST" --port "$PORT" --alias "$ALIAS")
        ;;
    vllm)
        MODEL="${MODEL:-Qwen/Qwen3-30B-A3B-Instruct-2507}"
        TIMEOUT="${TIMEOUT:-1800}"
        if [[ $FORCE -eq 0 ]]; then
            if ! command -v nvidia-smi >/dev/null && ! command -v rocminfo >/dev/null; then
                die "no NVIDIA (nvidia-smi) or ROCm (rocminfo) GPU stack found — vLLM needs a supported GPU; use --backend llama here, or --force"
            fi
        fi
        if [[ ! -x "$VENV/bin/vllm" ]]; then
            [[ $INSTALL -eq 1 ]] || die "vllm not installed in $VENV — rerun with --install"
            command -v uv >/dev/null || die "uv not found (needed to create the vLLM venv)"
            info "creating $VENV (Python 3.12) and installing vllm — this takes a while"
            uv venv --python 3.12 "$VENV"
            uv pip install --python "$VENV/bin/python" vllm
        fi
        # hermes tool parser is vLLM's documented parser for Qwen3 function calling.
        CMD=("$VENV/bin/vllm" serve "$MODEL" --host "$HOST" --port "$PORT"
             --served-model-name "$ALIAS" --max-model-len "$CTX"
             --gpu-memory-utilization "$GPU_MEM" --tensor-parallel-size "$TP"
             --enable-auto-tool-choice --tool-call-parser hermes)
        ;;
    *) die "unknown backend '$BACKEND' (llama|vllm)" ;;
esac

info "backend=$BACKEND model=$MODEL alias=$ALIAS endpoint=${BASE_URL}"
if [[ $FOREGROUND -eq 1 ]]; then
    exec "${CMD[@]}"
fi

if pid="$(running_pid)"; then
    die "a server started by this script is already running (pid $pid) but not answering yet — see: $0 logs"
fi
mkdir -p "$STATE_DIR"
: > "$LOG_FILE"
nohup "${CMD[@]}" >>"$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
pid="$(cat "$PID_FILE")"
info "started pid $pid, log $LOG_FILE — waiting up to ${TIMEOUT}s for the model to load"

for _ in $(seq 1 "$TIMEOUT"); do
    if endpoint_up; then
        info "ready at ${BASE_URL} (model '$ALIAS')"
        exit 0
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$PID_FILE"
        echo "--- last log lines ---" >&2
        tail -n 25 "$LOG_FILE" >&2
        die "server exited during startup"
    fi
    sleep 1
done
die "not ready after ${TIMEOUT}s (still loading?) — check: $0 logs"
