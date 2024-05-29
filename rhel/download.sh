#!/usr/bin/env bash

eval "$(cat sbin/logging.sh)"
eval "$(cat sbin/formatting.env)"

export RHEL_DOWNLOAD_URL=https://access.cdn.redhat.com/content/origin/files/sha256/d3/d362e72518a2d7415d850b8177c814f6fd87f42ca1640bda17e98855e1d6baad/rhel-9.4-x86_64-kvm.qcow2
export OFFLINE_API_TOKEN
export AUTHORIZATION_TOKEN

test -f .secrets/offline-token || {
  err "rhel: No offline token found at .secrets/offline-token! Visit https://access.redhat.com/management/api to generate a new token."
  exit
}

## Authenticating with the Assisted Installer REST API
OFFLINE_API_TOKEN="$(cat "$(pwd)/.secrets/offline-token")"
AUTHORIZATION_TOKEN="$( \
  curl \
  --silent \
  --header "Accept: application/json" \
  --header "Authorization: Bearer ${OFFLINE_API_TOKEN}" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=refresh_token" \
  --data-urlencode "client_id=rhsm-api" \
  --data-urlencode "refresh_token=${OFFLINE_API_TOKEN}" \
  "https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token" \
  | jq --raw-output ".access_token" \
)"

if [ -z "$OFFLINE_API_TOKEN" ]; then
  err "rhel: Failed to obtain RHEL access offline token value (Null value)!"
  exit
fi
if [ -z "$AUTHORIZATION_TOKEN" ]; then
  err "rhel: Failed to obtain RHEL access authorization token value (Null value)!"
  exit
fi

# download the file
log "rhel: Downloading ISO from $RHEL_DOWNLOAD_URL"
curl \
    --silent \
    --header "Accept: application/json" \
    --header "Authorization: Bearer ${AUTHORIZATION_TOKEN}" \
    "$RHEL_DOWNLOAD_URL" -vvvv