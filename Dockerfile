ARG ARGO_CD_VERSION="v2.1.3"
# Always match Argo CD Dockerfile's Go version!
# https://github.com/argoproj/argo-cd/blob/master/Dockerfile
ARG KSOPS_VERSION="v3.0.1"
#--------------------------------------------#
#--------Build KSOPS and Kustomize-----------#
#--------------------------------------------#

FROM quay.io/viaductoss/ksops:$KSOPS_VERSION as ksops-builder

#--------------------------------------------#
#--------Build Custom Argo Image-------------#
#--------------------------------------------#

FROM quay.io/argoproj/argocd:$ARGO_CD_VERSION

# Switch to root for the ability to perform install
USER root

# Set the kustomize home directory
ENV XDG_DATA_HOME=/home/argocd/.local/share
ENV XDG_CACHE_HOME=/home/argocd/.cache
ENV XDG_CONFIG_HOME=/home/argocd/.config
ENV KUSTOMIZE_PLUGIN_PATH=$XDG_CONFIG_HOME/kustomize/plugin/
ARG SOPS_VERSION="v3.7.1"
ARG HELM_SECRETS_VERSION="3.6.0"
ARG PKG_NAME=ksops

# Override the default kustomize executable with the Go built version
COPY --from=ksops-builder /go/bin/kustomize /usr/local/bin/kustomize

# Copy the plugin to kustomize plugin path
COPY --from=ksops-builder /go/src/github.com/viaduct-ai/kustomize-sops/*  \
    $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/${PKG_NAME}/

# Install helm secrets and sops
RUN apt-get update && \
    apt-get install -y \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x /usr/local/bin/sops && \
    mkdir -p $XDG_DATA_HOME/helm/plugins && \
    helm plugin install https://github.com/jkroepke/helm-secrets --version=$HELM_SECRETS_VERSION && \
    chgrp -R 0 $XDG_DATA_HOME/helm/plugins/helm-secrets/ && \
    chmod -R g+rwX $XDG_DATA_HOME/helm/plugins/helm-secrets/ && \
    mkdir -p $KUSTOMIZE_PLUGIN_PATH/pcjun97/v1/hashannotator && \
    curl -L https://github.com/pcjun97/kustomize-hash-annotator/releases/download/1.0.1/HashAnnotator_1.0.1_Linux_x86_64.tar.gz | tar -xzf - -C $KUSTOMIZE_PLUGIN_PATH/pcjun97/v1/hashannotator/

# Switch back to non-root user
USER argocd
