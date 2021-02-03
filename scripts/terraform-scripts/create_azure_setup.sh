#!/bin/bash
# Script adapted from https://docs.microsoft.com/en-us/azure/terraform/terraform-backend.
# We cannot create this storage account and blob container using Terraform itself since
# we are creating the remote state storage for Terraform and Terraform needs this storage in terraform init phase.

LOCATION=<Location>
RESOURCE_GROUP_NAME=<RG Name>
STORAGE_ACCOUNT_NAME=<Storage Name>$RANDOM
CONTAINER_NAME=<Container name>
TAGS='createdby='
LOCATION=“westeurope”
VAULT_NAME=“<vault-name>”

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags $TAGS

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --tags $TAGS

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

az keyvault create --name $VAULT_NAME --resource-group $RESOURCE_GROUP_NAME --location $LOCATION

az keyvault secret set --vault-name $VAULT_NAME --name “terraform-backend-key” --value ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
echo "keyVault": $VAULT_NAME

