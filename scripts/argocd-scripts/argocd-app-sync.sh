#!/bin/sh
#list of apps
app_list=$(argocd app list --output name)

for item in $app_list
do
  echo $item
  argocd app sync $item
done


#argocd app sync RABBITMQ_OPERATOR
#argocd app sync ADAPTATION_SERVICE
#argocd app sync ADMINISTRATION_SERVICE
#argocd app sync NCFS_SERVICE
#argocd app sync MONITORING_SERVICE
#argocd app sync MONITORING_SERVICE_GRAFANA
#argocd app sync CERT_MANAGER




