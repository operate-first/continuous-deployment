# Get ArgoCD to manage your Application

When migrating an application's deployment to be managed by ArgoCD use the following checklist to verify your process.

- Ensure your application manifests can be built using Kustomize.
- If using secrets, make sure to include the .sops.yaml file in your repository.
    - See [here](manage_your_app_secrets.md) for more info.
- Create the role granting access to namespace.
    - See [here](give_argocd_access_to_your_project.md) for more info.
    - This role should be tracked in your application manifest repository.

The following items require a PR:

- Ensure the application repository is added in the `repository` file in `/manifests/overlays/<target_env>/configs/argo_cm/repositories`.
- Ensure that all OCP resources that will be managed by ArgoCD on this cluster are included in the `inclusions` list in `/manifests/overlays/<target_env>/configs/argo_cm/resource.inclusions`.
    - See [here](inclusions_explained.md) for more info.
- Create the ArgoCD Application manifest
    - See [here](create_argocd_application_manifest.md) for more info.

The following items require a PR with sops access:

- Ensure your namespace exists in your cluster's spec see [here](admin/add_new_cluster_spec.md) for details.
- If you are switching between ArgoCD managed namespaces, and that namespace was deleted in OCP, then ensure it's also removed from your cluster's credentials found here `/manifests/overlays/<target_env>/secrets/clusters`.
