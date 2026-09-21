#!/usr/bin/env bash

# Localiza o diretorio base do script para importacoes seguras
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carrega os modulos de suporte
source "${SCRIPT_DIR}/lib/system.sh"

show_usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --system              Inspect CPU, memory usage, and load averages"
    echo "  --process <name>      Inspect running metrics for a specific process"
    echo "  --help                Display this help message"
}

# Valida presenca de argumentos
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

case "$1" in
    --system)
        inspect_system
        ;;
    --process)
        if [[ -z "$2" ]]; then
            echo "Error: Flag --process requires a process name argument." >&2
            exit 1
        fi
        inspect_process "$2"
        ;;
    --help)
        show_usage
        exit 0
        ;;
    *)
        echo "Error: Unknown option '$1'" >&2
        show_usage
        exit 1
        ;;
esac
