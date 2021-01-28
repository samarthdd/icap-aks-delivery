### Create Storage and blog container

Firstly make sure you're logged in and using the correct subscription.

```bash

az login

az account list --output table

az account set -s <subscription ID>
```

Next please use the below script to create the following resources:

- Resource group
- Storage account
- Blob container

```bash
#!/bin/bash

# Script adapted from https://docs.microsoft.com/en-us/azure/terraform/terraform-backend.
# We cannot create this storage account and blob container using Terraform itself since
# we are creating the remote state storage for Terraform and Terraform needs this storage in terraform init phase.

LOCATION=<Location>
RESOURCE_GROUP_NAME=<RG Name>
STORAGE_ACCOUNT_NAME=<Storage Name>$RANDOM
CONTAINER_NAME=<Container name>
TAGS='createdby='

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags $TAGS

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --tags $TAGS

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
```

Take note of the outputs of the "storage account name" etc as you will need this later on.

### Create Azure Key Vault

Follow the below commands to create the Azure key vault

Create an azure key vault in the resource group you created previously

```bash
az keyvault create --name “<vault-name>” --resource-group “<resource group>” --location “westeurope”
```

Create a new secret name "terraform-backend-key" in the key vault and add the value of the storage access key created previously

```bash
az keyvault secret set --vault-name “<vault name>” --name “terraform-backend-key” --value <the value of the access_key key>
```

Now verify you can read the value of the created secret

```bash
az keyvault secret show --name terraform-backend-key --vault-name <vault name> --query value -o tsv
```

Next export the environment variable "ARM_ACCESS_KEY" to be able to initialise terraform

```bash
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name <vault name> --query value -o tsv)

# now check to see if you can access it through variable

echo $ARM_ACCESS_KEY
```

### Create terraform service principle

*PLEASE NOTE THIS ONLY NEEDS TO BE DONE ONCE FOR A SINGLE SUBSCRIPTION*

This next part will create a service principle, with the least amount of privileges, to perform the AKS Deployment.

The script below will perform the following:

- Create the service principal (or resets the credentials if it already exists)

- Prompts to choose either a populated or empty provider.tf azurerm provider block

- Exports the environment variables if you selected an empty block (and display the commands)

- Display the az login command to log in as the service principal

```bash
#!/bin/bash

error()
{
  if [[ -n "$@" ]]
  then
    tput setaf 1
    echo "ERROR: $@" >&2
    tput sgr0
  fi

  exit 1
}

yellow() { tput setaf 3; cat - ; tput sgr0; return; }
cyan()   { tput setaf 6; cat - ; tput sgr0; return; }


# Grab the Azure subscription ID
subId=$(az account show --output tsv --query id)
[[ -z "$subId" ]] && error "Not logged into Azure as expected."

# Check for existing provider.tf
if [[ -f provider.tf ]]
then
  echo -n "The provider.tf file exists.  Do you want to overwrite? [Y/n]: "
  read ans
  [[ "${ans:-Y}" != [Yy] ]] && exit 0
fi

sname="terraform-${subId}-sp"
name="http://${sname}"

# Create the service principal
echo "az ad sp create-for-rbac --name \"$name\"" | yellow
spout=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subId" --name "$sname" --output json)

# If the service principal has been created then offer to reset credentials
if [[ "$?" -ne 0 ]]
then
  echo -n "Service Principal already exists. Do you want to reset credentials? [Y/n]: "
  read ans
  if [[ "${ans:-Y}" = [Yy] ]]
  then spout=$(az ad sp credential reset --name "$name" --output json)
  else exit 1
  fi
fi

[[ -z "$spout" ]] && error "Failed to create / reset the service principal $name"

# Echo the json output
echo "$spout" | yellow

# Derive the required variables
clientId=$(jq -r .appId <<< $spout)
clientSecret=$(jq -r .password <<< $spout)
tenantId=$(jq -r .tenant <<< $spout)

echo -e "\nWill now create a provider.tf file.  Choose output type."
PS3='Choose provider block type: '
options=("Populated azurerm block" "Empty azurerm block with environment variables" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Populated azurerm block")
      cat > provider.tf <<-END-OF-STANZA
	provider "azurerm" {
	  subscription_id = "$subId"
	  client_id       = "$clientId"
	  client_secret   = "$clientSecret"
	  tenant_id       = "$tenantId"
	}
	END-OF-STANZA

      echo -e "\nPopulated provider.tf:"
      cat provider.tf | yellow
      echo
      break
      ;;
    "Empty azurerm block with environment variables")
      echo "provider \"azurerm\" {}" > provider.tf
      echo -e "\nEmpty provider.tf:"
      cat provider.tf | yellow
      echo >&2

      export ARM_SUBSCRIPTION_ID="$subId"
      export ARM_CLIENT_ID="$clientId"
      export ARM_CLIENT_SECRET="$clientSecret"
      export ARM_TENANT_ID="$tenantId"

      echo "Copy the following environment variable exports and paste into your .bashrc file:"
      cat <<-END-OF-ENVVARS | cyan
	export ARM_SUBSCRIPTION_ID="$subId"
	export ARM_CLIENT_ID="$clientId"
	export ARM_CLIENT_SECRET="$clientSecret"
	export ARM_TENANT_ID="$tenantId"
	END-OF-ENVVARS
      break
      ;;
    "Quit")
      exit 0
      ;;
    *) echo "invalid option $REPLY";;
  esac
done

echo "To log in as the Service Principal then run the following command:"
echo "az login --service-principal --username \"$clientId\" --password \"$clientSecret\" --tenant \"$tenantId\"" | cyan

exit 0
```
The output will be similar to this:

```
{
"appId": "xyzxyzxyzxyzxyzxyzxyzxyzxyzxyz",
"displayName":"terraform-xyzxyzxyzxyzxyzxyzxyzxyzxyzx",
"name": "http://terraform-xyzxyzxyzxyzxyzxyzxyzxyzxyzxyz",
"password": "xyzxyzxyzxyzxyzxyzxyzxyzxyzxyz",
"tenant": "xyzxyzxyzxyzxyzxyzxyzxyzxyzxyz"
}
```

Next add the ClientID and ClientSecret to the Azure Keyvault you created earlier. Keep the names in the command below as they are referenced in the Terraform code:

```bash
az keyvault secret set --vault-name gw-tfstate-Vault --name sppassword --value <Client-Secret>

az keyvault secret set --vault-name gw-tfstate-Vault --name spusername --value <ClientID>
```

```bash
export TF_VAR_client_id=xyzxyzxyzxyzxyzxyzxyzxyzxyzxyz
export TF_VAR_client_secret=xyzxyzxyzxyzxyzxyzxyzxyzxyzxyz
```

Do not forget to add the client id and secret to the azure key vault we created earlier#

```bash
az keyvault secret set --vault-name "aceme-aks-key-vault" --name "TF-VAR-client-id" --value xyz

az keyvault secret set --vault-name "aceme-aks-key-vault" --name "TF-VAR-client-secret" --value xyz
```