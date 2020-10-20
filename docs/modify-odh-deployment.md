# Modify your ODH deployment

Below are the steps to modify your ODH deployment. Add components, content or anything else.

## Fork repo

Fork the repo https://github.com/operate-first/odh on GitHub.

## Replace repo reference in the ArgoCD app

Modify your `odh-deployment` Application resource in ArgoCD to point to your own fork.

![Edit repo in odh-deployment Application resource](./assets/images/argocd-app-edit-repo.png)

## Use GIT to modify your deployment

Clone, edit, ... use your favourite tools to work with your fork of the repo.

ArgoCD will synchronize the changes automatically or you can use the "Synchronize" button, based on the settings of the `odh-deployment` Application.
