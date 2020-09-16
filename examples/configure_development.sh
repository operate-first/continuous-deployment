#!/usr/bin/env bash
# Configure Auth

# Retrieve the ArgoCD route, api rest server url, and configure the redirect uri.
ARGOCD_ROUTE=https://$(oc get route argocd-server -n aicoe-argocd-dev -o jsonpath='{.spec.host}')
API_SERVER=$(oc whoami --show-server)

# Set up the issuer secret for the dex config:
OAUTH_TOKEN="$(echo -e "$(oc sa get-token argocd-dex-server -n aicoe-argocd-dev | base64)" | tr -d '[:space:]')"
oc patch secret argocd-secret -n aicoe-argocd-dev --type='json' -p="[{'op': 'add', 'path': '/data/dex.serviceaccount.clientSecret', 'value':'${OAUTH_TOKEN}'}]"

# Update Issuer and ArgoCD URL in dex config:
oc -n aicoe-argocd-dev get configmap argocd-cm -o yaml | sed "s#API_SERVER#${API_SERVER}#g" | sed "s#ARGOCD_ROUTE#${ARGOCD_ROUTE}#g" | oc replace -f -

# Once we create the argocd-manager and its rbac, we need to update our cluster
# spec. The Cluster Spec contains information about your dev cluster, here we
# add the argocd-manager's token information allowing ArgoCD to deploy to this
# cluster.
ARGOCD_MANAGER_TOKEN="$(echo -e "$(oc sa get-token argocd-manager -n aicoe-argocd-dev)" | tr -d '[:space:]')"
CLUSTER_SPEC_CONFIG=$(echo -n "{\"bearerToken\":\"${ARGOCD_MANAGER_TOKEN}\",\"tlsClientConfig\":{\"insecure\":true}}" | base64 | tr -d '[:space:]')
oc patch secret dev-cluster-spec -n aicoe-argocd-dev --type='json' -p="[{'op': 'add', 'path': '/data/config', 'value':'${CLUSTER_SPEC_CONFIG}'}]"

# We also need to provide the cluster spec with the location of this server.
API_SERVER_ENCODED=$(echo -ne ${API_SERVER} | base64 | tr -d '[:space:]')
oc patch secret dev-cluster-spec -n aicoe-argocd-dev --type='json' -p="[{'op': 'add', 'path': '/data/server', 'value':'${API_SERVER_ENCODED}'}]"

# Update the example dev application to point to the dev cluster
oc -n aicoe-argocd-dev get applications dev-app -o yaml | sed "s#API_SERVER#${API_SERVER}#g" | oc replace -f -

# The default application that's created belongs to the dev-team project which
# is only accessible by the dev group. So we add you to the group here:
oc adm groups new dev-group
oc adm groups add-users dev-group $(oc whoami)
