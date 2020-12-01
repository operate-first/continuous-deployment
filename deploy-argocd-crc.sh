EMP="\e[1;4m"
NORMAL="\e[0m"

if which kustomize >/dev/null; then
  kustomize=kustomize
else
  kustomize="toolbox run --container of-toolbox-v0.1.0 kustomize"
fi

echo -e "${EMP}Checking if CRC is running...${NORMAL}"
if crc status 2>&1 | grep -E '(Stopped|does not exist)' > /dev/null; then
  echo -e "${EMP}CRC is not running ---> aborting${NORMAL}"
  exit 1
fi
echo -e "\tOK"

if ! $kustomize --help > /dev/null; then
  echo -e "${EMP}kustomize is not available --> aborting${NORMAL}"
  exit 1
fi
echo -e "\tOK"

if ! which oc > /dev/null; then
  echo -e "${EMP}oc is not available --> aborting${NORMAL}"
  exit 1
fi
echo -e "\tOK"

echo -e "${EMP}Checking for GPG key${NORMAL}"
gpg --list-keys john@doe.com || base64 -d < examples/key.asc | gpg --import

echo -e "${EMP}Logging to CRC${NORMAL}"
login_command=$(crc console --credentials | grep admin | cut -d "'" -f 2)
$login_command

echo -e "${EMP}Creating a user and logging in${NORMAL}"
examples/crc-create-myadmin.sh

echo 'sleeping 10s'

i=1
while ! oc login -u myadmin -p foobar68 https://api.crc.testing:6443; do
  i=$(( $i + 1 ))
  if [ $i -ge 10 ]; then
    exit 1
  fi
  echo "Cannot login as newly created 'myadmin'. Waiting 10s for the $i time."
  sleep 10
done

echo -e "${EMP}Creating projects ${NORMAL}"
oc new-project argocd-test
oc new-project aicoe-argocd-dev

echo -e "${EMP}Deploying cluster objects using customize${NORMAL}"
$kustomize build manifests/crds --enable_alpha_plugins | oc apply -f -

echo -e "${EMP}Deploying non-cluster objects using customize${NORMAL}"
# dealing with a message getting printed to the stdout
$kustomize build manifests/overlays/dev --enable_alpha_plugins | grep -v 'Attempting plugin load' | oc apply -f -

echo -e "${EMP}Configuring ArgoCD access to projects${NORMAL}"
./examples/configure_development.sh
