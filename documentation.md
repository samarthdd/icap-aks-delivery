AKS-DEPLOYMENT-DOCUMENTATION


Instructions
1. Pre-requisites
terraform 14.4+
kubectx
kubectl
argocd
Microsoft account
Azure login and subsctiption, Service principal.
Argocd CLI tool
ArgoCD setup
1.1 Installation of Pre-requisites
Terraform install
--MacOS
Install terraform by running
brew install terraform
Confirm version
terraform -version
 
--Windows
1.   	Download the terraform package from portal either 32/64 bit version.
2.         	Make a folder in C drive in program files if its 32 bit package you have to create folder inside on programs(x86) folder or else inside programs(64 bit) folder.
3.         	Extract a downloaded file in this location or copy terraform.exe file into this folder. copy this path location like C:\Programfile\terraform\
4.         	Then got to Control Panel -> System -> System settings -> Environment Variables
Open system variables, select the path > edit > new > place the terraform.exe file location like > C:\Programfile\terraform\           and Save it.
5.         	Open new terminal and now check the terraform.
 
•    	--With Chocolatey run
     	choco install terraform
 
--Linux
1.   	Copy and paste the following command:
     	$ sudo tall -y yum-utils
     	$ sudo yum-config-manager --add-repo      	https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
     	$ sudo yum -y install terraform
 
2.   	Confirm installation was successful by verifying its version .
     	$ terraform --version
     	Terraform v0.14.3
 
Kubectx install
--MacOS
Copy and paste the following command
brew install kubectx
 
--Windows
To install kubectx in windows you will need Chocolatey (this link shows how to install it)
after installation of chocolatey run
     	choco install kubectx
 
--Linux
Copy and paste the following command
sudo apt install kubectx
 
Kubectl install
--MacOS
Copy and paste the following command
brew install kubectl
 
--Windows
1.   	To install kubectl on Windows you can use Chocolatey package manager 
     	choco install kubernetes-cli
2.   	Test to ensure the version you installed is up-to-date:
     	kubectl version --client
3.   	Navigate to your home directory:
           	# If you're using cmd.exe, run: cd %USERPROFILE%
     	cd ~
4.   	Create the .kube directory:
     	mkdir .kube
5.   	Change to the .kube directory you just created:
     	cd .kube
6.   	Configure kubectl to use a remote Kubernetes cluster:
            	New-Item config -type file
--Linux
1.   	Download the latest release with the command
     	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
 
2.   	Install kubectl
     	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
3.   	Confirm the version is up to date
     	kubectl version –client
 
ArgoCD CLI install
 You can interact with ArgoCD through the CLI or the GUI. To install the cli tool, follow the below instructions
--MacOS
Copy and paste the following command
brew install argocd
 
--Windows
Download With Powershell: Invoke-WebRequest. Run the following command to grab the version:
$version = (Invoke-RestMethod https://api.github.com/repos/argoproj/argo-cd/releases/latest).tag_name
 
Replace $version in the command below with the version of Argo CD you would like to download:
$url = "https://github.com/argoproj/argo-cd/releases/download/" + $version + "/argocd-windows-amd64.exe"
$output = "argocd.exe"
 
Invoke-WebRequest -Uri $url -OutFile $output
Also please note you will probably need to move the file into your PATH.
After finishing the instructions above, you should now be able to run argocd commands
 
--Linux
1.   	Set up an environment variable to assign the most recent version number
     	VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
2.   	Next use curl to download the most recent Linux version:
     	curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
3.   	Lastly make the argocld CLI executable:
     	chmod +x /usr/local/bin/argocd
2. Usage
2.1 Clone Repo
   git clone https://github.com/filetrust/icap-aks-delivery.git
   git submodule init
   git submodule update
 
2.2 Add Terraform Backend Key to Environment
Get the access to keyvault gw-tfstate-Vault
Follow the below commands to get the backend key for Terraform from the Azure Keyvault
Log into the Azure cli:
az login -u name@domain.com -p VerySecret
or by running the login command
az login
open a browser page at https://aka.ms/devicelogin and enter the authorization code displayed in your terminal.
 

#Check you have access to keyvault using below command
az keyvault secret show --name terraform-backend-key --vault-name gw-tfstate-Vault --query value -o tsv
Next export the environment variable "ARM_ACCESS_KEY" to be able to initialise terraform
# export as ARM_ACCESS_KEY
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name gw-tfstate-Vault --query value -o tsv)
 
# now check to see if you can access it through variable
echo $ARM_ACCESS_KEY
2.3 File Modifications
Currently below needs modifications
main.tf key = "test1.upwork.terraform.tfstate"
modules/clusters/aks01/variables.tf
Change "default" field in resource_group , cluster_name
modules/clusters/argocd-cluster/variables.tf
Change "default" field in resource_group , cluster_name
modules/clusters/keyvaults/keyvault-ukw/variables.tf
Change "default" field in resource_group , kv_name
modules/clusters/storage-accounts/storage-accounts-ukw/variables.tf
Change "default" field in resource_group_name
scripts/az-secret-script/create-az-secret.sh
change UKW_VAULT to kv_name default value
scripts\k8s_scripts\create-ns-docker-secret-uks.sh
RESOURCE_GROUP= resource group in storage-account
VAULT_NAME= kv_name default valu
scripts\argocd-scripts\argocd-app-deloy.sh
UKW_RESOURCE_GROUP -  resource_group of aks
UKW_CONTEXT - cluster_name of aks
3. Deployment
3.1 Setup and Initialise Terraform
Next you'll need to use the following:
terraform init
Next run terraform validate/refresh to check for changes within the state, and also to make sure there aren't any issues.
terraform validate
Success! The configuration is valid.
terraform refresh
terraform plan
Now you're ready to run apply and it should give you the following output
 
terraform apply 
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.
Enter a value: 
Enter "yes"
 3.2 Guide to Setup ArgoCD
ArgoCD can be used through your CLI or a GUI - it is currently set up to manually sync new changes from the "main" branches of all the repos that contain the charts for each service.
The future aim would be to have a "staging" environment and a "production" environment. Changes would be automatically deployed to "staging" as this would be a mirror copy of "production" - then if all was well with the upgrade on "staging" then we merge the changes to "main" branch, which is turn upgrades that cluster automatically too.
ArgoCD is very easy to install and set up - if you want to get it working on your current machine, follow the details below.
Install ArgoCD
Installation of ArgoCD only needs to be done on a fresh cluster - this does not apply to any current clusters running ArgoCD already.
Requirements
Installed kubectl cli tool
Have kubeconfig files set up (default location is ~/.kube/config)
The config is easily populated using a command like below:
az aks get-credentials --name <cluster name> --resource-group <cluster resource group>
Next to install the required services you would use the following commands:
kubectl create namespace argocd
 
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
 
Accessing the Argo CD API Server
In order to access the Argo CD API Server you use the following command to expose the external IP address. For future iterations of ArgoCD we can look to utilise SSO and SSL as extra layers of security. For now, we are using basic http and manually adjusting passwords.
So to access you would need to use following command to change the argo-server service type to "LoadBalancer":
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
Now run the following to get the public IP:
kubectl get svc -n argocd argocd-server
 
NAME        	TYPE       	CLUSTER-IP   EXTERNAL-IP	PORT(S)                      AGE
argocd-server   LoadBalancer   x.x.x.xxx   xxx.xx.xxx.xx   80:32117/TCP,443:30284/TCP   4d1h
Then if you go to the public IP you will be met by the login screen for ArgoCD
Login Using CLI or GUI
CLI Login
The password that is autogenerated to be the pod name of the Argo CD API Server. You can find this out with the following command:
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
Using the username "admin" and the password above, login using the public IP of ArgoCD
argocd login <public IP>
Once logged in you will need to change the password
argocd account update-password
Once you're logged in you have full access to all the Argocd CLI commands and can deploy new charts or sync existing charts.
GUI Login
Pretty simple - go to the public IP and use the username "admin" and the password from the below command:
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
Register a Cluster to Deploy apps to
This is required if you want to deploy to external clusters using ArgoCD. Follow the below to add clusters:
argocd cluster add
Choose a context name from the list and supply it to the following command:
argocd cluster add <context name>
The above command installs a ServiceAccount (argocd-manager), into the kube-system namespace of that kubectl context, and binds the service account to an admin-level ClusterRole. Argo CD uses this service account token to perform its management tasks (i.e. deploy/monitoring).
3.3 Verify Context 
Check you are in new created cluster
kubectx
#if new cluster is not highlighted, switch to your cluster using
kubectx <cluster_name>
 
 
Now you have the cluster added you can get the cluster server address using the below command:
kubectl cluster-info
Kubernetes master is running at https://gw-icap-k8s-f17703a9.hcp.uksouth.azmk8s.io:443
CoreDNS is running at https://gw-icap-k8s-f17703a9.hcp.uksouth.azmk8s.io:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://gw-icap-k8s-f17703a9.hcp.uksouth.azmk8s.io:443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
 
To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
if you want to check the status of an ArgoCD app you would use the following:
argocd app list
 
#it should be empty at this point
3.4 Copy keyvalt secrets from "gw-tfstate-Vault" to your keyvault
First we need to make file executable by running
chmod +x ./scripts/az-secret-script/create-az-secret.sh
 
·Then run the following
./scripts/az-secret-script/create-az-secret.sh
3.5 Create a Self Signed Certificate
openssl req -newkey rsa:2048 -nodes -keyout tls.key -x509 -days 365 -out certificate.crt
 
mkdir certs/icap-cert
mkdir certs/mgmt-cert
 
cp tls.key certs/icap-cert/tls.key
cp tls.key certs/mgmt-cert/tls.key
cp certificate.crt certs/icap-cert/certificate.crt
cp certificate.crt certs/mgmt-cert/certificate.crt
 
3.6 Create Namespaces in aks Resource Groups from https://github.com/filetrust/icap-infrastructure (same as 3.3)
chmod +x ./scripts/k8s_scripts/create-ns-docker-secret-uks.sh
 
./scripts/k8s_scripts/create-ns-docker-secret-uks.sh
3.7 How to Deploy Using ArgoCD
Before deploying confirm you are on the right context (server)
argocd context
if the right context is not selected switch to the right one running
argocd context <name of the server>
Deploy ArgoCD
run: chmod +x ./scripts/argocd-scripts/argocd-app-deloy.sh
run: ./scripts/argocd-scripts/argocd-app-deloy.sh
 
4. Sync an ArgoCD App
4.1 Sync From cli
Get Repo information from
    	argocd app list
 
Sync each Repo using command
    	argocd app sync <REPO>
4.2 Sync From UI
Access argocd UI using argocd public
    	kubectl get svc -n argocd argocd-server
 
Login to argocd UI
You can deploy each service from argoCD UI in the following this order
--RabbitMQ Operator 
--Cert Manager 
the rest can follow in any order
 












