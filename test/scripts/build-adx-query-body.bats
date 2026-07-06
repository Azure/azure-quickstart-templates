#!/usr/bin/env bats
# Tests for .github/scripts/build-adx-query-body.sh
#
# These tests pin the exact shape of the ADX REST query body so that any
# future change which (a) reintroduces string interpolation of CID/DN into
# the query text, or (b) drops the Parameters binding, will fail loudly.
# Security context: MSRC 117973 / ICM 31000000613310.

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  SCRIPT="${REPO_ROOT}/.github/scripts/build-adx-query-body.sh"
  [[ -f "${SCRIPT}" ]] || { echo "builder script not found at ${SCRIPT}" >&2; return 1; }

  VALID_CID="12345678-1234-1234-1234-1234567890ab"
  VALID_DN="my.deploy_01"
  VALID_DB="ARMDeploymentsDB"
}

@test "emits valid JSON" {
  run env DATABASE="${VALID_DB}" CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  echo "${output}" | jq -e . >/dev/null
}

@test "top-level db field is the supplied DATABASE" {
  run env DATABASE="${VALID_DB}" CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  db=$(echo "${output}" | jq -r '.db')
  [ "${db}" = "${VALID_DB}" ]
}

@test "csl field declares the query parameters (no string interpolation)" {
  run env DATABASE="${VALID_DB}" CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  csl=$(echo "${output}" | jq -r '.csl')
  [[ "${csl}" == "declare query_parameters(cid:string, dn:string);"* ]]
  [[ "${csl}" == *"where correlationId == cid"* ]]
  [[ "${csl}" == *"where deploymentName == dn"* ]]
}

@test "csl field NEVER contains the literal CID value" {
  run env DATABASE="${VALID_DB}" CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  csl=$(echo "${output}" | jq -r '.csl')
  # The actual GUID value must only appear in properties.Parameters.cid,
  # never embedded in the query text. This guards against accidental
  # reintroduction of string interpolation.
  [[ "${csl}" != *"${VALID_CID}"* ]]
}

@test "csl field NEVER contains the literal DN value" {
  run env DATABASE="${VALID_DB}" CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  csl=$(echo "${output}" | jq -r '.csl')
  [[ "${csl}" != *"${VALID_DN}"* ]]
}

@test "properties.Parameters.cid is the supplied CID" {
  run env DATABASE="${VALID_DB}" CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  cid=$(echo "${output}" | jq -r '.properties.Parameters.cid')
  [ "${cid}" = "${VALID_CID}" ]
}

@test "properties.Parameters.dn is the supplied DN" {
  run env DATABASE="${VALID_DB}" CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  dn=$(echo "${output}" | jq -r '.properties.Parameters.dn')
  [ "${dn}" = "${VALID_DN}" ]
}

@test "an injection-payload-shaped CID is safely JSON-encoded into Parameters.cid (no query-text leak)" {
  # The builder does not validate format (that's validate-kusto-inputs.sh's job).
  # What we verify here is that even if a bad value were to reach this layer,
  # it lands in the Parameters block where Kusto treats it as a typed value,
  # and never in the query text.
  payload='x" or true or "x'
  run env DATABASE="${VALID_DB}" CID="${payload}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
  csl=$(echo "${output}" | jq -r '.csl')
  [[ "${csl}" != *"${payload}"* ]]
  pcid=$(echo "${output}" | jq -r '.properties.Parameters.cid')
  [ "${pcid}" = "${payload}" ]
}

@test "missing DATABASE env var exits 2" {
  run env -u DATABASE CID="${VALID_CID}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 2 ]
}

@test "missing CID env var exits 2" {
  run env -u CID DATABASE="${VALID_DB}" DN="${VALID_DN}" bash "${SCRIPT}"
  [ "${status}" -eq 2 ]
}

@test "missing DN env var exits 2" {
  run env -u DN DATABASE="${VALID_DB}" CID="${VALID_CID}" bash "${SCRIPT}"
  [ "${status}" -eq 2 ]
}
