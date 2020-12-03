# Continous Deployment

[This repository](https://github.com/operate-first/continuous-deployment) contains an opinionated reference architecture to setup, manage and operate a continous deployment pipeline.

### Prerequisites
* Kustomize 3.8.1+
* SOPS 3.4.0+
* KSOPS 2.1.2+

Find more information on how to install the pre-requisites [here](docs/manage_your_app_secrets.md).

Ensure you have the key to decrypt secrets. Open an issue in this [repository](https://github.com/operate-first/continuous-deployment/issues) requesting access.

### GPG Key access

This repo encrypts secrets using a dev test key, you can find the test key in [examples/key.asc](https://github.com/oindrillac/continuous-deployment/blob/master/examples/key.asc) folder.

```
$ base64 -d < examples/key.asc | gpg --import
```

You will need to import this key to be able to decrypt the contents of the secrets using sops.

Do NOT use this gpg key for prod purposes.


### Howtos

See [how-to index](docs/) for various various procedures and how-tos when interacting with ArgoCD.
