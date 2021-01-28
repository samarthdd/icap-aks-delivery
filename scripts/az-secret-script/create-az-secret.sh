#!/bin/bash

# Vault Variables
UKW_VAULT="aks-delivery-keyvault"

# Secret Name Variables
SECRET_NAME01="DH-SA-USERNAME"
SECRET_NAME02="DH-SA-PASSWORD"
SECRET_NAME03="token-username"
SECRET_NAME04="token-password"
SECRET_NAME05="token-secret"
SECRET_NAME06="encryption-secret"
SECRET_NAME07="manage-endpoint"

# Secret Values Variables
MANAGEMENT_ENDPOINT=$(az keyvault secret show --name manage-endpoint --vault-name gw-tfstate-Vault --query value -o tsv)
DOCKER_USERNAME=$(az keyvault secret show --name DH-SA-USERNAME --vault-name gw-tfstate-Vault --query value -o tsv)
DOCKER_PASSWORD=$(az keyvault secret show --name DH-SA-PASSWORD --vault-name gw-tfstate-Vault --query value -o tsv)
TOKEN_USERNAME=$(az keyvault secret show --name token-username --vault-name gw-tfstate-Vault --query value -o tsv)
TOKEN_PASSWORD=$(tr -dc 'A-Za-z0-9!' </dev/urandom | head -c 20  ; echo)
TOKEN_SECRET=$(tr -dc 'A-Za-z0-9!' </dev/urandom | head -c 30  ; echo)
ENCRYPTION_SECRET=$(tr -dc 'A-Za-z0-9!' </dev/urandom | head -c 32  ; echo)

# AZ Command to set Secrets
az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME01 --value $DOCKER_USERNAME

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME02 --value $DOCKER_PASSWORD

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME03 --value $TOKEN_USERNAME

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME04 --value $TOKEN_PASSWORD

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME05 --value $TOKEN_SECRET

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME06 --value $ENCRYPTION_SECRET

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME07 --value $MANAGEMENT_ENDPOINT
