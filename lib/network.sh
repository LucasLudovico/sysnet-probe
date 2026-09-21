#!/usr/bin/env bash

# REQ-3.1: Conectividade ICMP e Metricas de Latencia
check_connectivity() {
    local host="$1"

    if [[ -z "${host}" ]]; then
        echo "Error: Host or IP address is required." >&2
        return 1
    fi

    echo "=========================================="
    echo "       SYSNET-PROBE: NETWORK METRICS      "
    echo "=========================================="
    echo "Target Host : ${host}"
    echo "Testing ICMP connectivity (4 packets)..."

    local ping_output
    ping_output=$(ping -c 4 -W 2 "${host}" 2>&1)

    if [[ $? -ne 0 ]]; then
        echo "Status      : Host unreachable or blocking ICMP"
        echo "=========================================="
        return 1
    fi

    # Extrai packet loss e rtt avg (latencia media)
    local packet_loss
    local avg_latency
    packet_loss=$(echo "${ping_output}" | grep -oP '\d+(?=% packet loss)')
    avg_latency=$(echo "${ping_output}" | awk -F'/' '/rtt|round-trip/ {print $5}')

    echo "Status      : Connected"
    echo "Packet Loss : ${packet_loss}%"
    echo "Avg Latency : ${avg_latency:-N/A} ms"
    echo "=========================================="
}

# REQ-3.1: Resolucao de Nomes DNS
resolve_dns() {
    local domain="$1"

    if [[ -z "${domain}" ]]; then
        echo "Error: Domain name is required." >&2
        return 1
    fi

    echo "=========================================="
    echo "       SYSNET-PROBE: DNS RESOLUTION       "
    echo "=========================================="
    echo "Target Domain: ${domain}"

    # Consulta registros A via dig
    local resolved_ips
    resolved_ips=$(dig +short A "${domain}")

    if [[ -z "${resolved_ips}" ]]; then
        echo "Status       : Resolution failed (No A records found)"
        echo "=========================================="
        return 1
    fi

    echo "Status       : Resolved"
    echo "Resolved IPs :"
    while IFS= read -r ip; do
        echo "  - ${ip}"
    done <<< "${resolved_ips}"
    echo "=========================================="
}

# REQ-3.2: Varredura Basica de Portas TCP
scan_ports() {
    local host="$1"

    if [[ -z "${host}" ]]; then
        echo "Error: Host or IP address is required for port scan." >&2
        return 1
    fi

    local ports=(22 80 443)

    echo "=========================================="
    echo "       SYSNET-PROBE: PORT SCAN (TCP)      "
    echo "=========================================="
    echo "Target Host : ${host}"
    echo "------------------------------------------"
    printf "%-8s %-12s %-10s\n" "PORT" "SERVICE" "STATUS"

    for port in "${ports[@]}"; do
        local service="UNKNOWN"
        case "${port}" in
            22)  service="SSH" ;;
            80)  service="HTTP" ;;
            443) service="HTTPS" ;;
        esac

        # Testa abertura via pseudo-dispositivo /dev/tcp com timeout de 1s
        if timeout 1 bash -c "true > /dev/tcp/${host}/${port}" 2>/dev/null; then
            printf "%-8s %-12s %-10s\n" "${port}" "${service}" "OPEN"
        else
            printf "%-8s %-12s %-10s\n" "${port}" "${service}" "CLOSED"
        fi
    done
    echo "=========================================="
}
