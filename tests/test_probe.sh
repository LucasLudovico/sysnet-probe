#!/usr/bin/env bash

# Localiza o diretorio base do script e a raiz do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CLI="${PROJECT_ROOT}/sysnet-probe.sh"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    shift
    ((TOTAL_TESTS++))
    echo -n "Running: ${test_name}... "

    local output
    output=$("$@" 2>&1)
    local exit_code=$?

    return "${exit_code}"
}

assert_success() {
    local test_name="$1"
    shift
    ((TOTAL_TESTS++))
    echo -n "Test: ${test_name}... "

    local output
    output=$("$@" 2>&1)
    local exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        echo "PASS"
        ((PASSED_TESTS++))
    else
        echo "FAIL (Expected 0, got ${exit_code})"
        echo "  Output: ${output}"
        ((FAILED_TESTS++))
    fi
}

assert_failure() {
    local test_name="$1"
    shift
    ((TOTAL_TESTS++))
    echo -n "Test: ${test_name}... "

    local output
    output=$("$@" 2>&1)
    local exit_code=$?

    if [[ ${exit_code} -ne 0 ]]; then
        echo "PASS (Expected non-zero, got ${exit_code})"
        ((PASSED_TESTS++))
    else
        echo "FAIL (Expected failure, but succeeded)"
        echo "  Output: ${output}"
        ((FAILED_TESTS++))
    fi
}

assert_output_contains() {
    local test_name="$1"
    local expected_pattern="$2"
    shift 2
    ((TOTAL_TESTS++))
    echo -n "Test: ${test_name}... "

    local output
    output=$("$@" 2>&1)

    if echo "${output}" | grep -q "${expected_pattern}"; then
        echo "PASS"
        ((PASSED_TESTS++))
    else
        echo "FAIL (Pattern '${expected_pattern}' not found)"
        echo "  Output: ${output}"
        ((FAILED_TESTS++))
    fi
}

echo "=========================================="
echo "      RUNNING SYSNET-PROBE TEST SUITE     "
echo "=========================================="

# Testes de Interface de Linha de Comando (CLI)
assert_failure "CLI with no arguments exits with error" "${CLI}"
assert_success "CLI --help displays help message" "${CLI}" --help
assert_output_contains "CLI --help output contains Usage" "Usage:" "${CLI}" --help

# Testes de Metricas do Sistema
assert_success "CLI --system collects system metrics" "${CLI}" --system
assert_output_contains "CLI --system includes CPU and Memory labels" "CPU Usage" "${CLI}" --system

# Testes de Inspecao de Processos
assert_failure "CLI --process without argument fails" "${CLI}" --process
assert_success "CLI --process bash locates active bash process" "${CLI}" --process bash
assert_failure "CLI --process nonexistent process fails" "${CLI}" --process "nonexistent_proc_xyz_999"

# Testes de Rede e DNS
assert_failure "CLI --network without argument fails" "${CLI}" --network
assert_success "CLI --network localhost checks connectivity" "${CLI}" --network "github.com"
assert_output_contains "CLI --network output contains Status" "Status" "${CLI}" --network "github.com"

# Testes de Varredura de Portas
assert_failure "CLI --ports without argument fails" "${CLI}" --ports
assert_success "CLI --ports localhost scans common ports" "${CLI}" --ports "127.0.0.1"

echo "=========================================="
echo "              TEST SUMMARY                "
echo "=========================================="
echo "Total Tests  : ${TOTAL_TESTS}"
echo "Passed Tests : ${PASSED_TESTS}"
echo "Failed Tests : ${FAILED_TESTS}"
echo "=========================================="

if [[ ${FAILED_TESTS} -eq 0 ]]; then
    echo "All tests passed successfully!"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
