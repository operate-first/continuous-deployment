# Add namespace to cluster

## Prerequisites

* sops 3.6+
* sops access

## Instructions

Namespaces are added to ArgoCD by altering the corresponding cluster spec. Cluster specs are defined within the `/manifests/overlays/<env>/secrets/clusters` folder.

Open the file in the sops editor, for example if updating the cluster spec `dev.cluster.example.enc.yaml` in `dev` you would execute:

```bash
# From repo root
$ target_env=dev
$ cd manifests/overlays/$target_env/secrets/clusters
$ sops dev.cluster.example.enc.yaml
```

This should open the decrypted form of the cluster spec. Update the namespace field by appending your namespace (comma-separated, no spaces, if there are multiple namespaces).

```yaml
...
 10 stringData:
 11     name: dev-cluster-spec
 12     config: ...
 14     namespaces: namespace-1,namespace-2 # Update this field by appending the new namespace, no whitespaces between commas
 15     server: ...
```

# Resources
More info on cluster configuration can be found [here](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#clusters).
