API=upi-0.mptest.lab.upshift.rdu2.redhat.com:6443
KUBEPASS=rSszg-hYQnn-h9zsi-aAoEb

EMP="\e[1;4m"
NORMAL="\e[0m"

if which kustomize >/dev/null; then
  kustomize=kustomize
else
  kustomize="toolbox run --container of-toolbox-v0.1.0 kustomize"
fi

if ! $kustomize --help > /dev/null; then
  echo -e "${EMP}kustomize is not available --> aborting${NORMAL}"
  exit 1
fi

# oc login -u kubeadmin -p rSszg-hYQnn-h9zsi-aAoEb upi-0.mptest.lab.upshift.rdu2.redhat.com:6443
oc login -u kubeadmin -p $KUBEPASS $API

echo -e "${EMP}Creating admin user 'myadmin'${NORMAL}"
htpasswd -nb myadmin foobar68 > /tmp/oc.htpasswd
oc create secret generic htpass-secret --from-file=htpasswd=/tmp/oc.htpasswd -n openshift-config
cat <<EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: my_htpasswd_provider
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
EOF

oc adm policy add-cluster-role-to-user cluster-admin myadmin

oc login -u myadmin -p foobar68

oc new-project argocd-test
oc new-project aicoe-argocd-dev

echo -e "${EMP}Deploying cluster objects using customize${NORMAL}"
$kustomize build manifests/crds --enable_alpha_plugins | oc apply -f -

echo -e "${EMP}Deploying non-cluster objects using customize${NORMAL}"
# dealing with a message getting printed to the stdout
$kustomize build manifests/overlays/dev --enable_alpha_plugins | grep -v 'Attempting plugin load' | oc apply -f -

echo -e "${EMP}Configuring ArgoCD access to projects${NORMAL}"
examples/configure_development.sh
