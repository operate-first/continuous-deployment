# ArgoCD Custom Image

This repo contains the Operate-First ArgoCD custom Image. The image is used by the Operate-First ArgoCD repo-server deployment. Below is a list of the tools packed into this image. See the `Dockerfile` for more info.

### Tools included in the Image

We use the following tools with corresponding versions.

ArgoCD: 2.1.3

KSOPs: 3.0.1

Kustomize: 4.3.0

SOPS: 3.7.1

Helm: 3.6.0

Helm-Secrets: 3.6.0

The KSOPS and Kustomize versions refer to the ones provisioned with ArgoCD.

Kustomize versions can be adjusted manually using [customized versions](https://argoproj.github.io/argo-cd/user-guide/kustomize/#custom-kustomize-versions).
