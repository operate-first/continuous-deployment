API=upi-0.mptest.lab.upshift.rdu2.redhat.com:6443

echo -e "${EMP}Checking that the ODH operator is present in the Marketplace${NORMAL}"
if ! oc get packagemanifests/opendatahub-operator -n openshift-marketplace >/dev/null; then
  echo -e "${EMP}ODH is missing in the operator manifests --> aborting${NORMAL}"
  exit 1
fi

oc new-project odh-operator
oc new-project odh-deployment

oc apply -f examples/argocd-cluster-binding.yaml

oc patch secret dev-cluster-spec -n aicoe-argocd-dev --type='json' -p="[{'op': 'replace', 'path': '/data/namespaces', 'value':''}]"

sed -e "1,\$s/https:\\/\\/api.crc.testing:6443/$API/" < examples/odh-operator-app.yaml   | oc apply -f -
sed -e "1,\$s/https:\\/\\/api.crc.testing:6443/$API/" < examples/odh-deployment-app.yaml | oc apply -f -

# wait for routes for jupyterhub, superset and other ODH components to appear
oc get -w routes -n odh-deployment
