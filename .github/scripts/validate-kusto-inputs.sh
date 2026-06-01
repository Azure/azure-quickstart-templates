#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# validate-kusto-inputs.sh
#
# Defense-in-depth format validator for the two metadata.json fields that
# ValidateSampleDeployments.yml binds into a Kusto (ADX) query:
#
#   * correlationId  — must be an RFC 4122 dashed GUID
#   * deploymentName — must match the ARM deployment-name grammar
#                      (1-64 chars from [a-zA-Z0-9._()-], must not end with '.')
#                      Ref: https://learn.microsoft.com/azure/azure-resource-manager/templates/deploy-cli#deployment-name
#
# The downstream ADX query uses Kusto query parameters (so values are never
# embedded in the query text), but this validator is run BEFORE that query
# fires so that malformed metadata fails fast with a clear error and a future
# refactor cannot reintroduce a KQL injection sink.
#
# Security context: MSRC 117973 / ICM 31000000613310.
#
# Two usage modes:
#
#   1. Standalone (env-var driven — matches .github/scripts/upsert-check-run.sh):
#        CID=... DN=... LABEL=... .github/scripts/validate-kusto-inputs.sh
#
#   2. Sourced (callable as a function — used by bats tests):
#        source .github/scripts/validate-kusto-inputs.sh
#        validate_kusto_inputs "<cid>" "<dn>" "<label>"
#
# Required environment (standalone mode):
#   CID    - correlationId value to validate
#   DN     - deploymentName value to validate
#
# Optional:
#   LABEL  - free-text label prepended to error messages (default: "deployment entry")
#
# Exit codes:
#   0  - both values pass validation
#   1  - one or more values failed validation (error written to stderr)
#   2  - missing required environment in standalone mode
# ──────────────────────────────────────────────────────────────────────────────

# Regexes are exported as readonly module-level constants so callers (and tests)
# can refer to them without copy-pasting.
readonly KUSTO_INPUTS_GUID_RE='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
readonly KUSTO_INPUTS_NAME_RE='^[a-zA-Z0-9._()-]{1,64}$'

validate_kusto_inputs () {
  local cid="${1-}" dn="${2-}" label="${3:-deployment entry}"

  if [[ ! "${cid}" =~ ${KUSTO_INPUTS_GUID_RE} ]]; then
    echo "ERROR: ${label}: 'correlationId' is not a valid GUID: '${cid}'" >&2
    echo "  Expected RFC 4122 dashed form, e.g. 12345678-1234-1234-1234-1234567890ab" >&2
    return 1
  fi

  if [[ ! "${dn}" =~ ${KUSTO_INPUTS_NAME_RE} ]] || [[ "${dn}" == *. ]]; then
    echo "ERROR: ${label}: 'deploymentName' does not match ARM deployment-name grammar: '${dn}'" >&2
    echo "  Allowed: 1-64 chars from [a-zA-Z0-9._()-], must not end with '.'" >&2
    return 1
  fi

  return 0
}

# Only run the standalone entry point if the script is executed directly (not
# sourced). Detected by comparing $0 to ${BASH_SOURCE[0]}.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail

  if [[ -z "${CID-}" || -z "${DN-}" ]]; then
    echo "ERROR: CID and DN environment variables are required" >&2
    echo "  Usage: CID=<guid> DN=<deployment-name> [LABEL=<text>] $0" >&2
    exit 2
  fi

  validate_kusto_inputs "${CID}" "${DN}" "${LABEL:-deployment entry}"
fi
