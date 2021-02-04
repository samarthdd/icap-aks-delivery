#!/bin/bash

#terraform destroy -auto-approve
terraform destroy

az keyvault delete --name $VAULT_NAME --resource-group $RESOURCE_GROUP_NAME

az storage container delete --account-key $ACCOUNT_KEY --account-name $STORAGE_ACCOUNT_NAME --name $CONTAINER_NAME

az storage account delete -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME

az group delete -n $RESOURCE_GROUP_NAME