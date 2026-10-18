#!/usr/bin/env bash
# Fetch the live OpenAPI spec and open (or update) a pull request when it differs from openapi/openapi.en.json.
# Never merges. Needs GH_TOKEN with contents:write and pull-requests:write.
set -euo pipefail

SPEC_URL="${SPEC_URL:-https://railnow.runvia.app/api/docs/en/json}"
SPEC_FILE="openapi/openapi.en.json"
BRANCH="automation/openapi-sync"
BASE_BRANCH="${BASE_BRANCH:-main}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl -fsS --retry 3 --retry-delay 10 --max-time 60 \
  -A "railnow-api-openapi-sync (+https://github.com/hongjunna/railnow-api)" \
  -o "$work/live.json" "$SPEC_URL"

# Refuse anything that is not an OpenAPI document (an error page, an empty body, a truncated response).
if ! jq -e '(.openapi | type == "string") and (.info.version | type == "string") and (.paths | type == "object" and length > 0)' \
  "$work/live.json" > /dev/null; then
  echo "::error::$SPEC_URL did not return a valid OpenAPI document"
  exit 1
fi

cp "$SPEC_FILE" "$work/old.json"
jq . "$work/live.json" > "$SPEC_FILE"

if git diff --quiet -- "$SPEC_FILE"; then
  echo "OpenAPI spec is up to date."
  exit 0
fi

old_version="$(jq -r '.info.version' "$work/old.json")"
new_version="$(jq -r '.info.version' "$SPEC_FILE")"
# shellcheck disable=SC2016 # jq expression, not shell
operations='[.paths | to_entries[] | .key as $p | .value | keys[] | select(test("^(get|put|post|delete|patch|head|options)$")) | "\(ascii_upcase) \($p)"]'
added="$(jq -rn --slurpfile o "$work/old.json" --slurpfile n "$SPEC_FILE" \
  "(\$n[0] | $operations) - (\$o[0] | $operations) | .[] | \"- \`\" + . + \"\`\"")"
removed="$(jq -rn --slurpfile o "$work/old.json" --slurpfile n "$SPEC_FILE" \
  "(\$o[0] | $operations) - (\$n[0] | $operations) | .[] | \"- \`\" + . + \"\`\"")"
stat="$(git diff --stat -- "$SPEC_FILE" | tail -1)"

{
  echo "The live OpenAPI spec at $SPEC_URL differs from \`$SPEC_FILE\`."
  echo
  echo "| | Version |"
  echo "|---|---|"
  echo "| Current | \`$old_version\` |"
  echo "| Live | \`$new_version\` |"
  echo
  echo "**Added operations**"
  echo
  echo "${added:-None}"
  echo
  echo "**Removed operations**"
  echo
  echo "${removed:-None}"
  echo
  echo "Diff: $stat"
  echo
  echo "Review the diff before merging. If the README describes any changed endpoint, parameter or limit, update README.md and README.ko.md in this PR."
  echo
  echo "_Opened automatically by the OpenAPI sync workflow. It is never merged automatically._"
} > "$work/body.md"

git config user.name "github-actions[bot]"
git config user.email "41898797+github-actions[bot]@users.noreply.github.com"
git switch -C "$BRANCH"
git add -- "$SPEC_FILE"
git commit -m "chore(openapi): sync spec to $new_version"
git push --force origin "$BRANCH"

title="chore(openapi): sync spec to $new_version"
pr="$(gh pr list --head "$BRANCH" --base "$BASE_BRANCH" --state open --json number --jq '.[0].number // empty')"
if [ -n "$pr" ]; then
  gh pr edit "$pr" --title "$title" --body-file "$work/body.md"
  echo "Updated pull request #$pr."
else
  gh pr create --base "$BASE_BRANCH" --head "$BRANCH" --title "$title" --body-file "$work/body.md"
fi
