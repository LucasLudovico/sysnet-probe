#!/usr/bin/env bash

# REQ-2.1: Inspecao de Memoria e Recursos do Sistema
inspect_system() {
    echo "=========================================="
    echo "       SYSNET-PROBE: SYSTEM METRICS       "
    echo "=========================================="

    local mem_total
    local mem_used
    local mem_free
    mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    mem_free=$(free -h | awk '/^Mem:/ {print $4}')

    echo "[MEMORY]"
    echo "  Total: ${mem_total}"
    echo "  Used : ${mem_used}"
    echo "  Free : ${mem_free}"

    local cpu_usage
    local load_avg
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

    echo "[CPU & LOAD]"
    echo "  CPU Usage   : ${cpu_usage}%"
    echo "  Load Average: ${load_avg} (1m, 5m, 15m)"
    echo "=========================================="
}

# REQ-2.2: Inspecao de Processos Ativos
inspect_process() {
    local target_process="$1"

    if [[ -z "${target_process}" ]]; then
        echo "Error: No process name provided." >&2
        return 1
    fi

    # Localiza PIDs associados ao nome exato do processo
    local pids
    pids=$(pgrep -d ',' -x "${target_process}")

    if [[ -z "${pids}" ]]; then
        echo "Process '${target_process}' not found."
        return 1
    fi

    echo "=========================================="
    echo "       SYSNET-PROBE: PROCESS METRICS      "
    echo "=========================================="
    echo "Target: ${target_process}"
    echo "------------------------------------------"
    printf "%-8s %-12s %-8s %-10s\n" "PID" "USER" "%MEM" "ELAPSED"
    
    ps -p "${pids}" -o pid,user,%mem,etime -h | awk '{printf "%-8s %-12s %-8s %-10s\n", $1, $2, $3, $4}'
    echo "=========================================="
}
