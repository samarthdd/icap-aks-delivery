# ArgoCD Installation Guide

## Table of Contents
- [ArgoCD Installation Guide](#argocd-installation-guide)
  - [Table of Contents](#table-of-contents)
    - [Install ArgoCD onto the cluster](#install-argocd-onto-the-cluster)
    - [Install ArgoCD CLI tool](#install-argocd-cli-tool)
      - [Linux](#linux)
      - [Mac](#mac)
      - [Windows](#windows)

### Install ArgoCD onto the cluster

You will use Helm to install ArgoCD, follow the commands below to get it installed.

Firstly make sure you're using the correct context, this will be the context of the cluster you want to deploy to:

```bash
kubectl config use-context <name of cluster>
```

Next you want to install the chart using helm

```bash
helm install ./charts/icap-infrastructure/argocd --generate-name
```

### Install ArgoCD CLI tool

You can interact with ArgoCD through the CLI or the gui. To install the cli tool, follow the below instructions:

#### Linux

Set up an environment variable to assign the most recent version number

```bash
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
```

Next use curl to download the most recent Linux version:

```bash
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
```

Lastly make the argocd CLI executable:

```bash
chmod +x /usr/local/bin/argocd
```
#### Mac

Use homebrew to install:

```bash
brew install argocd
```

#### Windows

If you are using Chocolatey, then install using command below:

```powershell
choco install argocd
```

Otherwise use the manual install below:

Download With Powershell: Invoke-WebRequest¶
You can view the latest version of Argo CD at the link above or run the following command to grab the version:

```powershell
$version = (Invoke-RestMethod https://api.github.com/repos/argoproj/argo-cd/releases/latest).tag_name
Replace $version in the command below with the version of Argo CD you would like to download:
```

```powershell
$url = "https://github.com/argoproj/argo-cd/releases/download/" + $version + "/argocd-windows-amd64.exe"
$output = "argocd.exe"

Invoke-WebRequest -Uri $url -OutFile $output
```
Also please note you will probably need to move the file into your PATH.

After finishing the instructions above, you should now be able to run argocd commands