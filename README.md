# icap-aks-delivery

Deployment for I-CAP Azure resources and AKS Deployment using Terraform

## Table of contents

- [icap-aks-delivery](#icap-aks-delivery)
  - [Table of contents](#table-of-contents)
  - [Pre-requisites](#pre-requisites)
  - [Terraform Deployment](#terraform-deployment)
    - [Logging into Azure CLI](#logging-into-azure-cli)
    - [Setup and initialise Terraform](#setup-and-initialise-terraform)
    - [Loading Secrets into key vault](#loading-secrets-into-key-vault)
    - [Get contexts for the clusters](#get-contexts-for-the-clusters)
    - [Creating SSL Certs](#creating-ssl-certs)
    - [Create Namespaces & Secrets](#create-namespaces--secrets)
    - [Install ArgoCD & Deploy Apps using ArgoCD](#install-argocd--deploy-apps-using-argocd)

## Pre-requisites 

In order to follow along with this guide you will need the following:

- Helm
- Terraform 
- Kubectl
- AZ CLI - with permissions to create resources within your chosen subscription
- OpenSSL
- Bash terminal or terminal able to execute bash scripts

## Terraform Deployment

Once you've cloned down the repo you will need to run the following.

### Logging into Azure CLI

For Terraform to use your subscription to deploy to, you will need to log into the Azure CLI:

```bash
az login

# This will take you to your browser, follow the steps and when you return to the cli it will log you in and output the subscriptions you have access to
```

You will also need to make sure you're using the correct subscription, oncey you've logged in.

```bash
az account set --subscription <subscription ID>
```
Once logged in and using the correct subscription terraform will take care of the rest by using the Azurerm provider.

### Setup and initialise Terraform

Next you'll need to use the following:

```
terraform init
```

Next run terraform validate/refresh to check for changes within the state, and also to make sure there aren't any issues.

```
terraform validate
Success! The configuration is valid.

terraform refresh
```

Now you're ready to run apply and it should give you the following output and you need to enter "yes"

```
terraform apply

Plan: 1 to add, 2 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

Once this completes you should see all the infrastructure for the AKS deployed and working.

### Loading Secrets into key vault

This step requires you to run a script to load the secrest needed for the K8 services into the newly deployed key vault. 

All this requires is for you to make sure that the variable with the key vault name, matches the name of the key vault you just deployed.

Then you run the following script:

```bash
./scripts/az-secret-script/create-az-secret.sh
```

### Get contexts for the clusters

Before running the script you will need to create certificates for the Management UI and the ICAP-Client. Follow the commands below to do this:

The following script will allow you to get the contexts for the two clusters you've just deployed. 

All this requires is to make sure the variable with the cluster names, matches the name of the clusters you just deployed.

```bash
./scripts/get-kube-context/get-kube-context.sh
```

### Creating SSL Certs

Firstly you will need to create a ```certs/``` folder:

```bash
mkdir certs/ 

mkdir certs/icap-cert

mkdir certs/mgmt-cert
```

Now the directories for the certs have been created, you can now create the certs using the following scripts:

ICAP-Client
```bash
./scripts/gen-certs/icap-cert/icap-gen-certs.sh icap-client.ukwest.cloudapp.azure.com
```

Management-UI
```bash
./scripts/gen-certs/mgmt-cert/mgmt-gen-certs.sh managemen-ui.ukwest.cloudapp.azure.com
```

### Create Namespaces & Secrets

This next step will create the namespaces on the cluster and load the secrets on the cluster as well.

All this requires is to make sure the variables at the top of the script matches the names of the clusters and resource groups you just deployed.

```bash
./scripts/k8_scripts/create-ns-docker-secret-ukw.sh
```

### Install ArgoCD & Deploy Apps using ArgoCD

Next we will deploy the services using either Helm or Argocd. Both of the Readme's for each can be found below:

- [ArgoCD Installation guide Readme](/argocd/installation-guide/README.md)
- [ArgoCD deployment guide Readme](/argocd/deployment-guide/README.md)
- [ArgoCD user guide Readme](/argocd/user-guide/README.md)

***All commands need to be run from the root directory for the paths to be correct***