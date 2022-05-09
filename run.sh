#!/bin/bash

VAULT_BIN_URL="https://releases.hashicorp.com/vault/1.10.2/vault_1.10.2_linux_amd64.zip"

set -x
wget -O vault.zip "$VAULT_BIN_URL"
unzip vault.zip

echo "$VCAP_SERVICES"
VAULT_ADDR="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.address')"
VAULT_TOKEN="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.auth.token')"
SERVICE_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends.generic[0]')"
APPLICATION_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends_shared.application')"
SPACE_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends_shared.space')"
ORGANIZATION_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends_shared.organization')"
./vault login -address="$VAULT_ADDR" "$VAULT_TOKEN"

while true; do
  ./vault token renew
  echo "SERVICE:      $(./vault read -address="$VAULT_ADDR" "${SERVICE_ENGINE}/secret" -field=SECRET_TYPE)"
  echo "APPLICATION:  $(./vault read -address="$VAULT_ADDR" "${APPLICATION_ENGINE}/secret" -field=SECRET_TYPE)"
  echo "SPACE:        $(./vault read -address="$VAULT_ADDR" "${SPACE_ENGINE}/secret" -field=SECRET_TYPE)"
  echo "ORGANIZATION: $(./vault read -address="$VAULT_ADDR" "${ORGANIZATION_ENGINE}/secret" -field=SECRET_TYPE)"
  echo ''
  sleep 10
done