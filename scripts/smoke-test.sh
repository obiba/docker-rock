#!/bin/bash
#
# Smoke test of a running Rock container: checks the REST endpoints that rely on
# Rock's native image hints, which only fail at runtime.
#
# Usage: ROCK_URL=http://localhost:8085 ROCK_USER=administrator ROCK_PASSWORD=password scripts/smoke-test.sh
#

set -e

url=${ROCK_URL:-http://localhost:8085}
auth="${ROCK_USER:-administrator}:${ROCK_PASSWORD:-password}"

call() {
  curl -sSf -u "$auth" "$@"
}

expect() {
  if [[ "$2" != *"$3"* ]]; then
    echo "FAIL $1: expected '$3' in: $2"
    exit 1
  fi
  echo "OK   $1"
}

echo "Waiting for $url ..."
for i in $(seq 60); do
  curl -sf "$url/_check" > /dev/null && break
  [ $i -eq 60 ] && { echo "FAIL rock did not start"; exit 1; }
  sleep 1
done

expect "service info" "$(call "$url/_info")" '"id"'
expect "R server status" "$(call "$url/rserver")" '"running":true'
expect "R version" "$(call -H 'Accept: application/octet-stream' "$url/rserver/_version" | tr -d '\0')" 'R version'
# .datashieldFind.R classpath resource
call -H 'Accept: application/json' "$url/rserver/packages/_datashield" > /dev/null
echo "OK   DataSHIELD packages"

session=$(call -X POST "$url/r/sessions")
id=$(echo "$session" | sed -E 's/.*"id":"([^"]+)".*/\1/')
expect "session created" "$session" "\"id\":\"$id\""
expect "eval JSON" "$(call -X POST -H 'Content-Type: application/x-rscript' -H 'Accept: application/json' -d '1+1' "$url/r/session/$id/_eval")" '2'
# RServeCommand binding: script field of async commands
expect "async command" "$(call -X POST -H 'Content-Type: application/x-rscript' -H 'Accept: application/json' -d 'Sys.sleep(1)' "$url/r/session/$id/_eval?async=true")" '"script":"Sys.sleep(1)"'
call -X DELETE "$url/r/session/$id"
echo "OK   session deleted"

# package installs should use prebuilt binaries from Posit Package Manager
call -X POST "$url/rserver/packages?name=praise"
expect "package installed" "$(call -H 'Accept: application/json' "$url/rserver/package/praise")" 'praise'
expect "package was a binary" "$(call -H 'Accept: text/plain' "$url/rserver/_log?limit=100")" 'installing *binary* package ‘praise’'

echo "All checks passed"
