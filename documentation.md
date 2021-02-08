# Instructions

## 1. Pre-requisites
- Terraform 14.4+
- Kubectl
- Argocd
- Openssl
- Microsoft account
- AZ CLI - with permissions to create resources within your chosen subscription
- Bash terminal or terminal able to execute bash scripts
- Jq

### 1.1 Installation of Pre-requisites
### Terraform install

**MacOS**

- Install terraform by running

    ```
    brew install terraform
    ```

- Confirm version

    ```
    terraform -version
    ```
 
**Windows**

1. Download the terraform package from portal either 32/64 bit version.
2. Make a folder in C drive in program files if its 32 bit package you have to create folder inside on programs(x86) folder or else inside programs(64 bit) folder.
3. Extract a downloaded file in this location or copy terraform.exe file into this folder. copy this path location like C:\Programfile\terraform\
4. Then goto 
    ```
    
    Control Panel -> System -> System settings -> Environment Variables
    Open system variables, select the path > edit > new > place the terraform.exe file location like > C:\Programfile\terraform\ and Save it.
    
    ```
5. Open new terminal and now check the terraform.
 
    ```   
        --With Chocolatey run
         choco install terraform
    ```

**Linux**

1. Copy and paste the following command:
    ```
            $ sudo tall -y yum-utils
            $ sudo yum-config-manager --add-repo      	https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
            $ sudo yum -y install terraform
     ```
2. Confirm installation was successful by verifying its version .
    ```
            $ terraform --version
            Terraform v0.14.3
    ```
 
### Kubectl install
**MacOS**

- Copy and paste the following command
    ```
     brew install kubectl 
    ```
 
**Windows**

1. To install kubectl on Windows you can use Chocolatey package manager 
    ```
    choco install kubernetes-cli
    ```
2. Test to ensure the version you installed is up-to-date:
    
    ```
    kubectl version --client
    ```
3. Navigate to your home directory:

    ```
    # If you're using cmd.exe, run: cd %USERPROFILE%
    cd ~
    ```
4. Create the .kube directory:
    ```
     mkdir .kube
    ```
5. Change to the .kube directory you just created:
    ```
    cd .kube
    ```
6. Configure kubectl to use a remote Kubernetes cluster:

     `New-Item config -type file`
     
**Linux**

1. Download the latest release with the command
    ```
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ```
 
2. Install kubectl
    ```
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```
3. Confirm the version is up to date
    ```
    kubectl version –client
    ```
 
### Open SSL 

**MacOs**  

```
brew info openssl

#check version
openssl version -a
```
**Windows**

Follow the instructions [here](https://www.xolphin.com/support/OpenSSL/OpenSSL_-_Installation_under_Windows)

**Linux**

OpenSSL has been installed from source on Linux Ubuntu and CentOS

### jq

**mac**
```
brew install jq

```
**windows**

```
chocolatey install jq
```

**Linux**
```
sudo apt-get install jq
```

## 2. Usage

### 2.1 Clone Repo

```
git clone https://github.com/filetrust/icap-aks-delivery.git
cd icap-aks-delivery
git submodule init
git submodule update

```
   
## 2.2 Firstly make sure you're logged in and using the correct subscription.

```bash

az login

az account list --output table

az account set -s <subscription ID>

```

### 2.3 Create azure initial setup

- Give a any meaningfull vaule to below varibles and run it in terminal
```
    export LOCATION=uksouth
    export RESOURCE_GROUP_NAME=
    export STORAGE_ACCOUNT_NAME=
    export CONTAINER_NAME=
    export TAGS='createdby='
    export VAULT_NAME=

```

- Run below script

```
        #!/bin/bash
        # Script adapted from https://docs.microsoft.com/en-us/azure/terraform/terraform-backend.
        # We cannot create this storage account and blob container using Terraform itself since
        # we are creating the remote state storage for Terraform and Terraform needs this storage in terraform init phase.
        
        
        # Create resource group
        az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags $TAGS
        
        # Create storage account
        az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --tags $TAGS
        
        # Get storage account key
        ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)
        
        # Create blob container
        az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY
        
        az keyvault create --name $VAULT_NAME --resource-group $RESOURCE_GROUP_NAME --location $LOCATION
        
        az keyvault secret set --vault-name $VAULT_NAME --name "terraform-backend-key" --value $ACCOUNT_KEY
        
        echo "respurce_group":$RESOURCE_GROUP_NAME
        echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
        echo "container_name: $CONTAINER_NAME"
        echo "access_key: $ACCOUNT_KEY"
        echo "keyVault": $VAULT_NAME

```

- Get account_key value and run below
```
    export ACCOUNT_KEY=<account_key>

```
### 2.4 Create terraform service principle

**PLEASE NOTE THIS ONLY NEEDS TO BE DONE ONCE FOR A SINGLE SUBSCRIPTION**

This next part will create a service principle, with the least amount of privileges, to perform the AKS Deployment.

```

 chmod +x ./scripts/terraform-scripts/createTerraormServicePrinciple.sh
./scripts/terraform-scripts/createTerraormServicePrinciple.sh

```

- When prompted `The provider.tf file exists.  Do you want to overwrite? ` , Enter `Y`

- The output will be similar to this. Note down <client id> and <client secret>

{
  "appId": "xyz",
  "displayName": "xyz",
  "name": "xyz",
  "password": "xyz",
  "tenant": "xyz"
}
subscription_id = "xyz"
client_id       = "xyz"
client_secret   = "xyz"
tenant_id       = "xyz"

### 2.5 Add Secrets to main KeyVault

- Get vaule for below varibles

token-username       =    "policy-management"
spusername           =    < client id >
sppassword           =    < client secret >
TF-VAR-client-id     =    < client id >
TF-VAR-client-secret =    < client secret >
DH-SA-USERNAME       =    < dockerhub username >
DH-SA-PASSWORD       =    < dockerhub password  >
SmtpUser             =    
SmtpPass             =
manage-endpoint      =

- Run below commands with proper values to save secrets in keyVault
( You can also do this in Azure portal.Login to azure account and  search <KEY_VAULT_NAME>,Go to secrets and add the above secrets. )

```
az keyvault secret set --vault-name $VAULT_NAME  --name "token-username" --value <token-username>

az keyvault secret set --vault-name $VAULT_NAME --name spusername --value <CLIENT_ID>

az keyvault secret set --vault-name $VAULT_NAME --name sppassword --value <CLIENT_SECRET>

az keyvault secret set --vault-name $VAULT_NAME --name "TF-VAR-client-id" --value <CLIENT_ID>

az keyvault secret set --vault-name $VAULT_NAME  --name "TF-VAR-client-secret" --value <CLIENT_SECRET>

az keyvault secret set --vault-name $VAULT_NAME  --name DH-SA-USERNAME--value <CLIENT_SECRET>

az keyvault secret set --vault-name $VAULT_NAME  --name DH-SA-PASSWORD --value <CLIENT_SECRET>

az keyvault secret set --vault-name $VAULT_NAME  --name SmtpUser --value <CLIENT_SECRET>

az keyvault secret set --vault-name $VAULT_NAME  --name SmtpPass --value <CLIENT_SECRET>

az keyvault secret set --vault-name $VAULT_NAME  --name manage-endpoint --value <CLIENT_SECRET>

```

### 2.6 Add Terraform Backend Key to Environment

- Check you have access to keyvault using below command
```
az keyvault secret show --name terraform-backend-key --vault-name $VAULT_NAME --query value -o tsv
```
- Next export the environment variable "ARM_ACCESS_KEY" to be able to initialise terraform

```
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name $VAULT_NAME --query value -o tsv)
```
 
- Now check to see if you can access it through variable
```
echo $ARM_ACCESS_KEY
```
### 2.7 File Modifications

- Currently below needs modifications

```
main.tf key = "test1.upwork.terraform.tfstate"
```

- modules/clusters/aks01/variables.tf
```
Change "default" field in location, resource_group , cluster_name

```
- modules/clusters/argocd-cluster/variables.tf
```
Change "default" field in location,resource_group , cluster_name

```

- modules/clusters/keyvaults/keyvault-ukw/variables.tf

```
Change "default" field in location, resource_group , kv_name
```

- modules/clusters/storage-accounts/storage-accounts-ukw/variables.tf
```
Change "default" field in location, resource_group_name
```

- scripts/az-secret-script/create-az-secret.sh
```
change UKW_VAULT to kv_name default value
```
- scripts\k8s_scripts\create-ns-docker-secret-uks.sh
```
Context used in kubectl config use-context to aks cluster
RESOURCE_GROUP= resource group in storage-account
VAULT_NAME= kv_name default vault
```

- scripts\argocd-scripts\argocd-app-deloy.sh
```
Context used in kubectl config use-context to argocd cluster
UKW_RESOURCE_GROUP -  resource_group of aks
UKW_CONTEXT - cluster_name of aks
```

## 3. Deployment
### 3.1 Setup and Initialise Terraform

- Next you'll need to use the following:
```
terraform init
```
- Next run terraform validate/refresh to check for changes within the state, and also to make sure there aren't any issues.
```
terraform validate
#Success! The configuration is valid.

terraform refresh
terraform plan
```

- Now you're ready to run apply and it should give you the following output
``` 
terraform apply 

Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.
Enter a value: 
Enter "yes"

```
### 3.2 Guide to Setup ArgoCD

Next we will deploy the services using either Helm or Argocd. Both of the Readme's for each can be found below:

- [ArgoCD Installation guide Readme](/argocd/installation-guide/README.md)
- [ArgoCD deployment guide Readme](/argocd/deployment-guide/README.md)
- [ArgoCD user guide Readme](/argocd/user-guide/README.md)

### 3.3 Verify Context 

- Check you are in newly created cluster
```
kubectl config get-contexts
```
- if new cluster is not highlighted, switch to your cluster using
```
kubectl config use-context <cluster_name>
```
 
- Now you have the cluster added you can get the cluster server address using the below command:
```
kubectl cluster-info

Kubernetes master is running at https://gw-icap-k8s-f17703a9.hcp.uksouth.azmk8s.io:443
CoreDNS is running at https://gw-icap-k8s-f17703a9.hcp.uksouth.azmk8s.io:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://gw-icap-k8s-f17703a9.hcp.uksouth.azmk8s.io:443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
 ```
- To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
- if you want to check the status of an ArgoCD app you would use the following:
```
argocd app list

#it should be empty at this point before deployment

```

### 3.4 Loading Secrets into key vault.

- First we need to make file executable by running

```
chmod +x ./scripts/az-secret-script/create-az-secret.sh
```
- Then run the following
```
./scripts/az-secret-script/create-az-secret.sh
```

### 3.5 Creating SSL Certs

- Firstly you will need to create a ```certs/``` folder:

```bash
mkdir certs/ 

mkdir certs/icap-cert

mkdir certs/mgmt-cert
```

- Now the directories for the certs have been created, you can now create the certs using the following scripts:

```bash
./scripts/gen-certs/icap-cert/icap-gen-certs.sh icap-client.ukwest.cloudapp.azure.com
```

- Management-UI
```bash
./scripts/gen-certs/mgmt-cert/mgmt-gen-certs.sh management-ui.ukwest.cloudapp.azure.com
```
 
### 3.6 Create Namespaces & Secrets.
```
chmod +x ./scripts/k8s_scripts/create-ns-docker-secret-uks.sh
 
./scripts/k8s_scripts/create-ns-docker-secret-uks.sh

```

### 3.7 Deploy Using ArgoCD

- Before deploying confirm you are on the right context (server)
```
argocd context
```

- if the right context is not selected switch to the right one running

```
argocd context <name of the server>
```
- Deploy ArgoCD
```
chmod +x ./scripts/argocd-scripts/argocd-app-deloy.sh
./scripts/argocd-scripts/argocd-app-deloy.sh
```
 
## 4. Sync an ArgoCD App
### 4.1 Sync From cli
Get Repo information from
    	```
    	argocd app list
    	```
 
### Sync each Repo using command
```
    	argocd app sync <REPO>
```
### 4.2 Sync From UI
- Access argocd UI using argocd public
```
   kubectl get svc -n argocd argocd-server

```
 
- Login to argocd UI

You can deploy and sync each service from argoCD UI in the following order 1-RabbitMQ Operator, 2-Cert Manager, the rest can follow in any order
 
 
## 5. Testing the solution.

### 5.1 Healthcheck

- Make sure all the applications are healty and synced from argocd UI

### 5.2 Testing rebuild 

- Download C-ICAP (https://zoomadmin.com/HowToInstall/UbuntuPackage/c-icap)

- Run below command

```
/usr/bin/c-icap-client -i <IP>  -p 1344 -tls -tls-no-verify -s gw_rebuild -f sample.pdf -o rebuilt.pdf -v

```

- The output should be similar to this

```
ICAP HEADERS:
	ICAP/1.0 200 OK
	Server: C-ICAP/0.5.7
	Connection: keep-alive
	ISTag: CI0001-2.1.1
	Encapsulated: res-hdr=0, res-body=263

RESPMOD HEADERS:
	HTTP/1.0 200 OK
	Date: Fri Feb  5 09:55:38 2021
	Last-Modified: Fri Feb  5 09:55:38 2021
	Content-Length: 611191
	X-Adaptation-File-Id: 
	Via: ICAP/1.0 icap-service-76b96ff545-vf9ht (C-ICAP/0.5.7 Glasswall Rebuild service )

```

### 6 Uninstall AKS-Solution. 

#### **Only if you want to uninstall AKS solution completely from your system, then proceed**

- Run below script to destroy all cluster ,resources, keyvaults,storage containers and service principle. 

```

#!/bin/bash

#terraform destroy -auto-approve
terraform destroy

#deletes keyvault
az keyvault delete --name $VAULT_NAME --resource-group $RESOURCE_GROUP_NAME

#deletes container
az storage container delete --account-key $ACCOUNT_KEY --account-name $STORAGE_ACCOUNT_NAME --name $CONTAINER_NAME

#deletes storage account
az storage account delete -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME

#deletes resource
az group delete -n $RESOURCE_GROUP_NAME

#deletes service priniple
az ad sp delete --id $appID


```
