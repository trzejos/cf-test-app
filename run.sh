#!/bin/bash

VAULT_BIN_URL="https://releases.hashicorp.com/vault/1.10.2/vault_1.10.2_linux_amd64.zip"
JQ_BIN_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"

wget -O jq "$JQ_BIN_URL"
wget -O vault.zip "$VAULT_BIN_URL"
unzip vault.zip
chmod +x vault jq

export VAULT_NAMESPACE=admin
export VAULT_ADDR="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.address' | tr -d '"')"
VAULT_TOKEN="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.auth.token' | tr -d '"')"
SERVICE_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends.generic[0]' | tr -d '"')"
APPLICATION_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends_shared.application' | tr -d '"')"
SPACE_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends_shared.space' | tr -d '"')"
ORGANIZATION_ENGINE="$(echo "$VCAP_SERVICES" | ./jq '."hashicorp-vault"[0].credentials.backends_shared.organization' | tr -d '"')"
./vault login "$VAULT_TOKEN"

while true; do
  ./vault token renew
  echo "SERVICE:      $(./vault read "${SERVICE_ENGINE}/secret" -field=SECRET_TYPE)"
  echo "APPLICATION:  $(./vault read "${APPLICATION_ENGINE}/secret" -field=SECRET_TYPE)"
  echo "SPACE:        $(./vault read "${SPACE_ENGINE}/secret" -field=SECRET_TYPE)"
  echo "ORGANIZATION: $(./vault read "${ORGANIZATION_ENGINE}/secret" -field=SECRET_TYPE)"
  echo ''
  sleep 10
done