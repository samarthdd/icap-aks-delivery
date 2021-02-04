#!/bin/bash

#terraform destroy -auto-approve
terraform destroy

@deletes keyvault
az keyvault delete --name $VAULT_NAME --resource-group $RESOURCE_GROUP_NAME

#deletes container
az storage container delete --account-key $ACCOUNT_KEY --account-name $STORAGE_ACCOUNT_NAME --name $CONTAINER_NAME

#deletes storage account
az storage account delete -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME

#deletes resource
az group delete -n $RESOURCE_GROUP_NAME

#deletes service priniple
az ad sp delete --id $appID