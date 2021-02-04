# ArgoCD Services deployment guide

## Table of Contents

### Adding apps to ArgoCD

***Please note that all scripts need to be run in the root directory***

In order to add apps to ArgoCD you need to create them and add them to the server.

Firstly make sure you're using the correct ArgoCD context, if this is the first time using ArgoCD then you will only have one context and can skip this step.

```bash
argocd context <name of context>
```

Next you will need to run the following script to create all the apps. An example of a general create command would be the following:

```bash
argocd app create $APP_NAME --repo $GITHUB_REPO --path $GITHUB_PATH --dest-server $CLUSTER_FQDM --dest-namespace $NAMESPACE_ON_CLUSTER --revision $REVISION_OR_BRANCH
```

For ease we will be using the following script to install the apps onto the server:

```bash
./scripts/argocd-scripts/argocd-app-deploy.sh
```

Once this has completed, you can run the following command to see all the app present on the server:

```bash
argocd app list
```

***TIP - you can use ```argocd app list -o name``` which will output only the names of the apps. Sometimes the full list of apps can get a bit busy***

You're now ready to sync the apps onto the ICAP cluster but before you do that make sure you've installed all the secrets onto the server, otherwise you will run into errors deploying.