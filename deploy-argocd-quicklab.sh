KUBEPASS=rSszg-hYQnn-h9zsi-aAoEb

if [ "$#" -ne 3 ]; then
  echo "Usage: deploy-argocd-quicklab.sh API_ADDRESS KUBEPASSWORD quicklab_htpassword"
  exit 1
fi

API=$1
KUBEPASS=$2
QLPASS=$3

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

echo -e "${EMP}Checking for GPG key${NORMAL}"
gpg --list-keys john@doe.com || base64 -d < examples/key.asc | gpg --import

oc login -u quicklab -p $QLPASS

oc login -u kubeadmin -p $KUBEPASS $API
oc adm policy add-cluster-role-to-user cluster-admin quicklab

oc login -u quicklab -p $QLPASS
oc new-project argocd-test
oc new-project aicoe-argocd-dev

echo -e "${EMP}Deploying cluster objects using customize${NORMAL}"
$kustomize build manifests/crds --enable_alpha_plugins | oc apply -f -

echo -e "${EMP}Deploying non-cluster objects using customize${NORMAL}"
# dealing with a message getting printed to the stdout
$kustomize build manifests/overlays/dev --enable_alpha_plugins | grep -v 'Attempting plugin load' | oc apply -f -

echo -e "${EMP}Configuring ArgoCD access to projects${NORMAL}"
examples/configure_development.sh
