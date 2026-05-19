#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# upsert-check-run.sh
#
# Idempotently creates or updates a GitHub Check Run on a given commit SHA.
# If a check run with the same name + app already exists for the SHA, it is
# patched; otherwise a new one is created. This avoids duplicate check runs
# from repeated /validate comments on the same head SHA.
#
# Required environment:
#   GH_TOKEN     - token with `checks: write` on the target repo
#   GH_REPO      - "owner/repo" (defaults to $GITHUB_REPOSITORY)
#   CHECK_NAME   - name of the check run (e.g. "adx-deployment-validation")
#   HEAD_SHA     - commit SHA to attach the check run to
#   STATUS       - "queued" | "in_progress" | "completed"
#
# Required when STATUS=completed:
#   CONCLUSION   - "success" | "failure" | "neutral" | "cancelled" |
#                  "skipped" | "timed_out" | "action_required"
#
# Optional:
#   TITLE        - short headline shown in the Checks UI
#   SUMMARY      - markdown summary body
#   DETAILS_URL  - URL the "Details" link points to
#   APP_ID       - integration id used to filter existing runs (default 15368
#                  = "GitHub Actions"; matches checks created by GITHUB_TOKEN)
#
# Exit codes:
#   0 - check run created or updated
#   2 - missing required environment
#   3 - GitHub API call failed
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${CHECK_NAME:?CHECK_NAME is required}"
: "${HEAD_SHA:?HEAD_SHA is required}"
: "${STATUS:?STATUS is required (queued|in_progress|completed)}"

REPO="${GH_REPO:-${GITHUB_REPOSITORY:-}}"
if [[ -z "${REPO}" ]]; then
  echo "ERROR: GH_REPO or GITHUB_REPOSITORY must be set" >&2
  exit 2
fi

APP_ID="${APP_ID:-15368}"
TITLE="${TITLE:-${CHECK_NAME}}"
SUMMARY="${SUMMARY:-}"
DETAILS_URL="${DETAILS_URL:-}"

if [[ "${STATUS}" == "completed" && -z "${CONCLUSION:-}" ]]; then
  echo "ERROR: CONCLUSION is required when STATUS=completed" >&2
  exit 2
fi

# Build the request body via jq so strings are JSON-escaped safely.
build_body() {
  local op="$1"   # "create" or "update"
  jq -n \
    --arg name        "${CHECK_NAME}" \
    --arg head_sha    "${HEAD_SHA}" \
    --arg status      "${STATUS}" \
    --arg conclusion  "${CONCLUSION:-}" \
    --arg title       "${TITLE}" \
    --arg summary     "${SUMMARY}" \
    --arg details_url "${DETAILS_URL}" \
    --arg op          "${op}" \
    '
    {
      name:   $name,
      status: $status,
      output: { title: $title, summary: $summary }
    }
    + (if $op == "create" then { head_sha: $head_sha } else {} end)
    + (if $status == "completed" and ($conclusion | length) > 0
         then { conclusion: $conclusion }
         else {} end)
    + (if ($details_url | length) > 0 then { details_url: $details_url } else {} end)
    '
}

# Find an existing check run with the same name + app on this SHA, if any.
existing_id=""
if list_json=$(gh api \
      -H "Accept: application/vnd.github+json" \
      "/repos/${REPO}/commits/${HEAD_SHA}/check-runs?check_name=${CHECK_NAME}&app_id=${APP_ID}&per_page=100" \
      2>/dev/null); then
  existing_id=$(printf '%s' "${list_json}" | jq -r '.check_runs[0].id // empty')
fi

if [[ -n "${existing_id}" ]]; then
  echo "Updating existing check run ${existing_id} (name='${CHECK_NAME}', sha=${HEAD_SHA})"
  body=$(build_body update)
  printf '%s' "${body}" | gh api \
    --method PATCH \
    -H "Accept: application/vnd.github+json" \
    "/repos/${REPO}/check-runs/${existing_id}" \
    --input - >/dev/null
else
  echo "Creating new check run (name='${CHECK_NAME}', sha=${HEAD_SHA})"
  body=$(build_body create)
  printf '%s' "${body}" | gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "/repos/${REPO}/check-runs" \
    --input - >/dev/null
fi

echo "✅ Check run upserted: status=${STATUS} conclusion=${CONCLUSION:-<n/a>}"
