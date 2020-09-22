# Deployment on CRC

These is how to deploy ArgoCD on [CRC](https://developers.redhat.com/products/codeready-containers/overview).

## Instalation Steps

 * Setup CRC https://developers.redhat.com/products/codeready-containers/overview
   * Do not forget to install the corresponding version of `oc` tool or some commands might fail.
   * add more memory to CRC : \
   `crc delete` \
   `crc config set memory 16384` \
   `crc start`

 * Get `kustomize` and KSOPS using steps in [manage_your_app_secrets.md](../manage_your_app_secrets.md)

   * If you hit:\
``` unrecognized import path "vbom.ml/util": https fetch: Get "https://vbom.ml/util?go-get=1": dial tcp ```\
fix it with https://github.com/viaduct-ai/kustomize-sops/issues/60

* As an alternative to installing the prerequisites locally, you can use Toolbox: https://github.com/containers/toolbox \
   `toolbox create --image quay.io/aicoe/of-toolbox:v0.1.0` \
   `toolbox enter --container of-toolbox-v0.1.0` \
   Then you have all the tools needed running in a separate container.

 * Fork https://github.com/operate-first/continuous-deployment

 * Import GPG key that is used by kustomize to encrypt the secrets.\
	```base64 -d < examples/key.asc | gpg --import ```

 * Proceed with [setup_argocd_dev_environment.md](../setup_argocd_dev_environment.md)

Your ArgoCD instance will be running at https://argocd-server-aicoe-argocd-dev.apps-crc.testing/

![ArgoCD](../assets/images/crc/argocd-initial.png)
