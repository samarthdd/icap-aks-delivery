#!/bin/sh

# Cluster Resource Group Variables
UKW_RESOURCE_GROUP="gw-icap-aks-delivery"

# Cluster FQDN Variables
UKW_CLUSTER_FQDN=$(az aks list -g $UKW_RESOURCE_GROUP --query "[].fqdn" | awk 'FNR == 2' | tr -d '",\040')

# App Name
ADAPTATION_SERVICE="icap-adaptation-service"
ADMINISTRATION_SERVICE="icap-administration-service"
NCFS_SERVICE="icap-ncfs-service"
RABBITMQ_OPERATOR="rabbitmq-operator"
MONITORING_SERVICE="monitoring"
CERT_MANAGER="cert-manager"

# Cluster Context
UKW_CONTEXT="gw-icap-aks-delivery-ukw"

# App Paths
PATH_ADAPTATION="adaptation"
PATH_ADMINISTRATION="administration"
PATH_NCFS="ncfs"
PATH_CERT="cert-manager-chart"
PATH_RABBITMQ="rabbitmq-operator"
PATH_PROMETHEUS="helm-charts/prometheus/"
PATH_GRAFANA="helm-charts/grafana/"

# Namespaces
NS_ADAPTATION="icap-adaptation"
NS_ADMINISTRATION="icap-administration"
NS_NCFS="icap-ncfs"
NS_RABBIT="icap-rabbit-operator"
NS_MONITORING="icap-central-monitoring"

# Revisions
REV_MAIN="main"
REV_DEVELOP="develop"

# Parameters
PARAM_REMOVE_SECRETS="secrets=null"

# Github repo
ICAP_REPO="https://github.com/filetrust/icap-infrastructure"

# Add Cluster
argocd cluster add $UKW_CONTEXT

# Create QA-UKS Cluster Apps
argocd app create $RABBITMQ_OPERATOR-qa-main --repo $ICAP_REPO --path $PATH_RABBITMQ --dest-server https://$UKW_CLUSTER_FQDN:443 --dest-namespace $NS_RABBIT --revision $REV_DEVELOP --parameter $PARAM_REMOVE_SECRETS

argocd app create $ADAPTATION_SERVICE-qa-main --repo $ICAP_REPO --path $PATH_ADAPTATION --dest-server https://$UKW_CLUSTER_FQDN:443 --dest-namespace $NS_ADAPTATION --revision $REV_DEVELOP --parameter $PARAM_REMOVE_SECRETS

argocd app create $ADMINISTRATION_SERVICE-qa-main --repo $ICAP_REPO --path $PATH_ADMINISTRATION --dest-server https://$UKW_CLUSTER_FQDN:443 --dest-namespace $NS_ADMINISTRATION --revision $REV_DEVELOP --parameter $PARAM_REMOVE_SECRETS

argocd app create $PATH_NCFS-qa-main --repo $ICAP_REPO --path $PATH_NCFS --dest-server https://$UKW_CLUSTER_FQDN:443 --dest-namespace $NS_NCFS --revision $REV_DEVELOP --parameter $PARAM_REMOVE_SECRETS

argocd app create $CERT_MANAGER-qa-main --repo $ICAP_REPO --path $PATH_CERT --dest-server https://$UKW_CLUSTER_FQDN:443 --dest-namespace default --revision $REV_DEVELOP

argocd app create $MONITORING_SERVICE --repo $ICAP_REPO --path $PATH_PROMETHEUS --dest-server https://$UKW_CLUSTER_FQDN:443 --dest-namespace $NS_MONITORING --revision $REV_DEVELOP --parameter $PARAM_REMOVE_SECRETS

argocd app create $MONITORING_SERVICE-ukw --repo $ICAP_REPO --path $PATH_GRAFANA --dest-server https://$UKW_CLUSTER_FQDN:443 --dest-namespace $NS_MONITORING --revision $REV_DEVELOP --parameter $PARAM_REMOVE_SECRETS