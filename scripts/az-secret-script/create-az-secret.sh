#!/bin/bash

# Vault Variables
UKW_VAULT="aks-delivery-keyvault-01"

# Secret Name Variables
SECRET_NAME01="DH-SA-USERNAME"
SECRET_NAME02="DH-SA-PASSWORD"
SECRET_NAME03="token-username"
SECRET_NAME04="token-password"
SECRET_NAME05="token-secret"
SECRET_NAME06="encryption-secret"
SECRET_NAME07="manage-endpoint"
SMTP_SECRET01="SmtpHost"
SMTP_SECRET02="SmtpPort"
SMTP_SECRET03="SmtpUser"
SMTP_SECRET04="SmtpPass"
SMTP_SECRET05="SmtpSecureSocketOptions"

# Secret Values Variables
MANAGEMENT_ENDPOINT=$(az keyvault secret show --name manage-endpoint --vault-name gw-tfstate-Vault --query value -o tsv)
DOCKER_USERNAME=$(az keyvault secret show --name DH-SA-USERNAME --vault-name gw-tfstate-Vault --query value -o tsv)
DOCKER_PASSWORD=$(az keyvault secret show --name DH-SA-PASSWORD --vault-name gw-tfstate-Vault --query value -o tsv)
TOKEN_USERNAME=$(az keyvault secret show --name token-username --vault-name gw-tfstate-Vault --query value -o tsv)
TOKEN_PASSWORD=$(head /dev/urandom | base64 | head -c32)
TOKEN_SECRET=$(head /dev/urandom | base64 | head -c32)
ENCRYPTION_SECRET=$(head /dev/urandom | base64 | head -c32)
SMTPHOST="smtp.office365.com"
SMTPPORT="587"
SMTPUSER=$(az keyvault secret show --name SmtpUser --vault-name gw-tfstate-Vault --query value -o tsv)
SMTPPASS=$(az keyvault secret show --name SmtpPass --vault-name gw-tfstate-Vault --query value -o tsv)
SMTPSECURESOCKETOPTIONS="StartTls"

# AZ Command to set Secrets
az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME01 --value $DOCKER_USERNAME

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME02 --value $DOCKER_PASSWORD

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME03 --value $TOKEN_USERNAME

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME04 --value $TOKEN_PASSWORD

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME05 --value $TOKEN_SECRET

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME06 --value $ENCRYPTION_SECRET

az keyvault secret set --vault-name $UKW_VAULT --name $SECRET_NAME07 --value $MANAGEMENT_ENDPOINT

az keyvault secret set --vault-name $UKW_VAULT --name $SMTP_SECRET01 --value $SMTPHOST

az keyvault secret set --vault-name $UKW_VAULT --name $SMTP_SECRET02 --value $SMTPPORT

az keyvault secret set --vault-name $UKW_VAULT --name $SMTP_SECRET03 --value $SMTPUSER

az keyvault secret set --vault-name $UKW_VAULT --name $SMTP_SECRET04 --value $SMTPPASS

az keyvault secret set --vault-name $UKW_VAULT --name $SMTP_SECRET05 --value $SMTPSECURESOCKETOPTIONS
