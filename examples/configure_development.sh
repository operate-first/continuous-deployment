#!/usr/bin/env bash
# Retrieve the ArgoCD route and update the configmap.
ARGOCD_ROUTE=https://$(oc get route argocd-server -n aicoe-argocd-dev -o jsonpath='{.spec.host}')
oc -n aicoe-argocd-dev get configmap argocd-cm -o yaml | sed "s#ARGOCD_ROUTE#${ARGOCD_ROUTE}#g" | oc replace -f -

# Add service account token to ArgoCD cluster spec
ARGOCD_MANAGER_TOKEN="$(echo -e "$(oc sa get-token argocd-manager -n aicoe-argocd-dev)" | tr -d '[:space:]')"
CLUSTER_SPEC_CONFIG=$(echo -n "{\"bearerToken\":\"${ARGOCD_MANAGER_TOKEN}\",\"tlsClientConfig\":{\"insecure\":true}}" | base64 | tr -d '[:space:]')
oc patch secret dev-cluster-spec -n aicoe-argocd-dev --type='json' -p="[{'op': 'add', 'path': '/data/config', 'value':'${CLUSTER_SPEC_CONFIG}'}]"

# The default application that's created belongs to the dev project which
# is only accessible by the dev group. So we add you to the group here:
oc adm groups new dev-group
oc adm groups add-users dev-group $(oc whoami)
