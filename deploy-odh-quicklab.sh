API=upi-0.mptest.lab.upshift.rdu2.redhat.com:6443

EMP="\e[1;4m"
NORMAL="\e[0m"

echo -e "${EMP}Checking that the ODH operator is present in the Marketplace${NORMAL}"
if ! oc get packagemanifests/opendatahub-operator -n openshift-marketplace >/dev/null; then
  echo -e "${EMP}ODH is missing in the operator manifests --> aborting${NORMAL}"
  exit 1
fi

# collects projects/namespaces to be created
for proj in $(grep -h 'namespace:' examples/odh-* | sed -e 's/\snamespace:\s//' | sort -u); do
  echo "creating project: ${proj}"
  oc new-project $proj
done

oc apply -f examples/argocd-cluster-binding.yaml

oc patch secret dev-cluster-spec -n aicoe-argocd-dev --type='json' -p="[{'op': 'replace', 'path': '/data/namespaces', 'value':''}]"

oc project aicoe-argocd-dev
for manifest in examples/odh-*; do
  oc apply -f $manifest
done

# wait for routes for jupyterhub, superset and other ODH components to appear
oc get -w routes -n odh-deployment
