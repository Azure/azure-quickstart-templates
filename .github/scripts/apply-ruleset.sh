#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# apply-ruleset.sh
#
# One-time admin script that applies the GitHub Repository Ruleset declared in
# `.github/rulesets/master.json` to this repository.
#
# This is NOT a workflow. GitHub does not natively read in-repo ruleset files,
# so an admin must run this script whenever the manifest changes.
#
# Usage:
#     bash .github/scripts/apply-ruleset.sh           # apply
#     bash .github/scripts/apply-ruleset.sh --dry-run # print body, no changes
#
# Requirements:
#   - gh CLI authenticated as a user with `admin:repo` scope on the target
#     repo (`gh auth login`, then `gh auth status` to verify).
#   - jq installed.
#   - GH_REPO env var, or run from inside a clone of the target repo so that
#     `gh repo view --json nameWithOwner` resolves it.
#
# Behavior:
#   - Looks up an existing ruleset with the same `name` as in the manifest.
#   - If found  → PUT  /repos/{owner}/{repo}/rulesets/{id}    (update in place)
#   - If absent → POST /repos/{owner}/{repo}/rulesets         (create new)
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${SCRIPT_DIR}/../rulesets/master.json"
if [[ ! -f "${MANIFEST}" ]]; then
  echo "ERROR: manifest not found at ${MANIFEST}" >&2
  exit 2
fi

REPO="${GH_REPO:-}"
if [[ -z "${REPO}" ]]; then
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
fi
if [[ -z "${REPO}" ]]; then
  echo "ERROR: GH_REPO env var is not set and 'gh repo view' could not resolve the repo." >&2
  echo "       Run from inside a clone, or export GH_REPO=owner/repo." >&2
  exit 2
fi
echo "Target repo: ${REPO}"

# Strip the documentation-only "_comment" key before sending to the API.
BODY=$(jq 'del(._comment)' "${MANIFEST}")

NAME=$(printf '%s' "${BODY}" | jq -r '.name')
if [[ -z "${NAME}" || "${NAME}" == "null" ]]; then
  echo "ERROR: manifest has no .name field" >&2
  exit 2
fi
echo "Ruleset name: ${NAME}"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "── Dry-run: request body that would be sent ──"
  printf '%s\n' "${BODY}"
  exit 0
fi

EXISTING_ID=$(gh api \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/rulesets" \
  --jq ".[] | select(.name == \"${NAME}\") | .id" \
  2>/dev/null | head -n1 || true)

if [[ -n "${EXISTING_ID}" ]]; then
  echo "Updating existing ruleset id=${EXISTING_ID}"
  printf '%s' "${BODY}" | gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/${REPO}/rulesets/${EXISTING_ID}" \
    --input - >/dev/null
  echo "✅ Updated ruleset '${NAME}' (id=${EXISTING_ID})"
else
  echo "Creating new ruleset"
  printf '%s' "${BODY}" | gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "/repos/${REPO}/rulesets" \
    --input - >/dev/null
  echo "✅ Created ruleset '${NAME}'"
fi
