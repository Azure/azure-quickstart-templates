#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# build-adx-query-body.sh
#
# Emits the JSON request body for the ADX /v1/rest/query endpoint that
# ValidateSampleDeployments.yml uses to verify a deployment landed.
#
# The body uses Kusto query parameters (declare query_parameters +
# properties.Parameters) so the PR-controlled values for `correlationId` and
# `deploymentName` are NEVER embedded in the query text — they are bound by
# the Kusto engine as typed parameters. This is the primary mitigation for
# the KQL injection vulnerability MSRC 117973 / ICM 31000000613310.
#
# Callers MUST run validate-kusto-inputs.sh on CID/DN before invoking this
# script, as a defense-in-depth check.
#
# Required environment:
#   DATABASE  - target Kusto database name
#   CID       - correlationId (already validated as GUID)
#   DN        - deploymentName (already validated against ARM grammar)
#
# Stdout:
#   A single JSON object: { db, csl, properties: { Parameters: { cid, dn } } }
#
# Exit codes:
#   0 - body emitted on stdout
#   2 - missing required environment
#   3 - jq not on PATH
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# The KQL query is held in a single constant so tests can pin its exact text.
# Do NOT add any string interpolation here — all PR-controlled values must
# flow through the Parameters block, not through the query text.
readonly ADX_DEPLOYMENT_QUERY='declare query_parameters(cid:string, dn:string); Deployments | where correlationId == cid | where deploymentName == dn | project timestamp=TIMESTAMP, deploymentName, executionStatus, templateHash, generatorName, generatorVersion | top 1 by timestamp desc'

if [[ -z "${DATABASE-}" || -z "${CID-}" || -z "${DN-}" ]]; then
  echo "ERROR: DATABASE, CID, and DN environment variables are required" >&2
  echo "  Usage: DATABASE=<db> CID=<guid> DN=<deployment-name> $0" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: 'jq' is required but not found on PATH" >&2
  exit 3
fi

jq -n \
  --arg db  "${DATABASE}" \
  --arg cid "${CID}" \
  --arg dn  "${DN}" \
  --arg csl "${ADX_DEPLOYMENT_QUERY}" \
  '{
     db: $db,
     csl: $csl,
     properties: { Parameters: { cid: $cid, dn: $dn } }
   }'
