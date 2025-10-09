#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  PATH="${REPO_ROOT}/tests/bin:${PATH}"
  export PATH
  export CORTEX_API_TOKEN="test-token"
  OUTPUT_FILE="${BATS_TMPDIR}/output.csv"
  unset CORTEX_OWNER_TAG
}

teardown() {
  rm -f "${OUTPUT_FILE:-}"
  unset CURL_STUB_FAIL_ON_PAGE
  unset CORTEX_OWNER_TAG
}

@test "shows usage help" {
  run "${REPO_ROOT}/list-cortex-repositories" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "fails when owner tag is missing" {
  run "${REPO_ROOT}/list-cortex-repositories" \
    -u "https://example.test/catalog" \
    -f "$OUTPUT_FILE" \
    -q

  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: owner tag is required."* ]]
}

@test "exports repositories to csv using fixtures" {
  run "${REPO_ROOT}/list-cortex-repositories" \
    -o sample-team \
    -u "https://example.test/catalog" \
    -f "$OUTPUT_FILE" \
    -q

  [ "$status" -eq 0 ]
  [[ "$output" == *"Success: Wrote"* ]]

  expected="${REPO_ROOT}/tests/fixtures/expected.csv"
  if ! cmp -s "$expected" "$OUTPUT_FILE"; then
    diff -u "$expected" "$OUTPUT_FILE" >&2 || true
    echo "CSV output did not match expected fixture" >&2
    return 1
  fi
}

@test "uses environment owner tag when option is omitted" {
  export CORTEX_OWNER_TAG="sample-team"

  run "${REPO_ROOT}/list-cortex-repositories" \
    -u "https://example.test/catalog" \
    -f "$OUTPUT_FILE" \
    -q

  [ "$status" -eq 0 ]
  [[ "$output" == *"Success: Wrote"* ]]
}

@test "fails when an option argument is missing" {
  run "${REPO_ROOT}/list-cortex-repositories" -o
  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: Option -o requires an argument."* ]]
}

@test "surfaces curl failures" {
  export CURL_STUB_FAIL_ON_PAGE=1
  run "${REPO_ROOT}/list-cortex-repositories" \
    -o sample-team \
    -u "https://example.test/catalog" \
    -f "$OUTPUT_FILE" \
    -q

  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: Failed to fetch page 1 from Cortex API."* ]]
}
