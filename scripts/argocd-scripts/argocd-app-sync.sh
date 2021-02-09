#!/bin/sh
#list of apps

# App Name
ADAPTATION_SERVICE="icap-adaptation-service"
ADMINISTRATION_SERVICE="icap-administration-service"
NCFS_SERVICE="icap-ncfs-service"
RABBITMQ_OPERATOR="rabbitmq-operator"
MONITORING_SERVICE="monitoring"
CERT_MANAGER="cert-manager"

argocd app sync $RABBITMQ_OPERATOR-ukw-develop

argocd app sync $CERT_MANAGER-ukw-develop

app_list=$(argocd app list --output name)

for item in $app_list
do
  echo $item
  argocd app sync $item
done


#argocd app sync $RABBITMQ_OPERATOR
#argocd app sync $ADAPTATION_SERVICE
#argocd app sync $ADMINISTRATION_SERVICE
#argocd app sync $NCFS_SERVICE
#argocd app sync $MONITORING_SERVICE
#argocd app sync $MONITORING_SERVICE_GRAFANA
#argocd app sync $CERT_MANAGER




