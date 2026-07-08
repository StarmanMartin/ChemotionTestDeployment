#!/bin/bash

PACKAGE_JSON="/chemotion/chem/package.json"
CLIENT_DEPS="/chemotion/client_dependencies.json"

tmp=$(mktemp)

jq --slurpfile deps "$CLIENT_DEPS" \
   '.dependencies = (.dependencies // {}) * $deps[0]' \
   "$PACKAGE_JSON" > "$tmp"

mv "$tmp" "$PACKAGE_JSON"