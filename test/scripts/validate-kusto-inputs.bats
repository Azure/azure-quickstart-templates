#!/usr/bin/env bats
# Tests for .github/scripts/validate-kusto-inputs.sh
#
# Covers every shape of input the security review flagged for the original
# inline implementation in ValidateSampleDeployments.yml (MSRC 117973):
#   * RFC 4122 GUID acceptance and the various ways an injection payload can
#     try to slip through (embedded quote, KQL operator, whitespace, empty,
#     short, long, non-hex).
#   * ARM deployment-name grammar: ^[a-zA-Z0-9._()-]{1,64}$ and the explicit
#     "must not end with '.'" rule.

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  SCRIPT="${REPO_ROOT}/.github/scripts/validate-kusto-inputs.sh"
  [[ -f "${SCRIPT}" ]] || { echo "validator script not found at ${SCRIPT}" >&2; return 1; }

  VALID_CID="12345678-1234-1234-1234-1234567890ab"
  VALID_DN="my.deploy_01-foo(bar)"
}

# ── Sourced-function mode ────────────────────────────────────────────────────

@test "sourced: accepts a valid GUID and a valid deployment name" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" "${VALID_DN}" "unit-test"
  [ "${status}" -eq 0 ]
}

@test "sourced: rejects an injection payload in correlationId" {
  source "${SCRIPT}"
  run validate_kusto_inputs 'x" or true or "x' "${VALID_DN}" "unit-test"
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"not a valid GUID"* ]]
}

@test "sourced: rejects an empty correlationId" {
  source "${SCRIPT}"
  run validate_kusto_inputs "" "${VALID_DN}" "unit-test"
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"not a valid GUID"* ]]
}

@test "sourced: rejects a short correlationId" {
  source "${SCRIPT}"
  run validate_kusto_inputs "12345678-1234-1234-1234-1234567890a" "${VALID_DN}" "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: rejects a non-hex correlationId" {
  source "${SCRIPT}"
  run validate_kusto_inputs "ZZZZZZZZ-1234-1234-1234-1234567890ab" "${VALID_DN}" "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: rejects whitespace-padded correlationId" {
  source "${SCRIPT}"
  run validate_kusto_inputs " ${VALID_CID} " "${VALID_DN}" "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: accepts uppercase hex in correlationId" {
  source "${SCRIPT}"
  run validate_kusto_inputs "12345678-ABCD-EF12-3456-1234567890AB" "${VALID_DN}" "unit-test"
  [ "${status}" -eq 0 ]
}

@test "sourced: rejects a semicolon in deploymentName" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" "foo;bar" "unit-test"
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"does not match ARM deployment-name grammar"* ]]
}

@test "sourced: rejects a pipe in deploymentName" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" "foo|bar" "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: rejects a double-quote in deploymentName" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" 'foo"bar' "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: rejects a backslash in deploymentName" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" 'foo\bar' "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: rejects a space in deploymentName" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" "foo bar" "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: rejects an empty deploymentName" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" "" "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: accepts a 64-char deploymentName" {
  source "${SCRIPT}"
  dn=$(printf 'a%.0s' {1..64})
  run validate_kusto_inputs "${VALID_CID}" "${dn}" "unit-test"
  [ "${status}" -eq 0 ]
}

@test "sourced: rejects a 65-char deploymentName" {
  source "${SCRIPT}"
  dn=$(printf 'a%.0s' {1..65})
  run validate_kusto_inputs "${VALID_CID}" "${dn}" "unit-test"
  [ "${status}" -eq 1 ]
}

@test "sourced: rejects a trailing-dot deploymentName even when regex matches" {
  source "${SCRIPT}"
  run validate_kusto_inputs "${VALID_CID}" "foo." "unit-test"
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"does not match ARM deployment-name grammar"* ]]
}

@test "sourced: error message includes the supplied label" {
  source "${SCRIPT}"
  run validate_kusto_inputs "bad-guid" "${VALID_DN}" "prereqs 1/3 (prereqs/main.bicep)"
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"prereqs 1/3 (prereqs/main.bicep)"* ]]
}

# ── Standalone (env-var) mode ────────────────────────────────────────────────

@test "standalone: accepts valid CID + DN via env vars" {
  run env CID="${VALID_CID}" DN="${VALID_DN}" LABEL="unit-test" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "standalone: rejects malformed CID via env vars (exit 1)" {
  run env CID="not-a-guid" DN="${VALID_DN}" LABEL="unit-test" bash "${SCRIPT}"
  [ "${status}" -eq 1 ]
}

@test "standalone: missing CID env var exits 2" {
  run env -u CID DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 2 ]
}

@test "standalone: missing DN env var exits 2" {
  run env -u DN CID="${VALID_CID}" bash "${SCRIPT}"
  [ "${status}" -eq 2 ]
}
