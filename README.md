# Continous Deployment

This repository contains an opinionated reference architecture to setup, manage and operate a continous deployment pipeline.

### Prerequisites
Kustomize 3.8.1+
SOPS 3.4.0+
KSOPS 2.1.2+

Ensure you have the key to decrypt secrets. Reach out to members of the Data Hub team for access.

### GPG Key access

This repo encrypts secrets using a dev test key, you can find the test key in examples/key.asc folder.

```
$ base64 -d < examples/key.asc | gpg --import
```

You will need to import this key to be able to decrypt the contents of the secrets using sops.

Do NOT use this gpg key for prod purposes.
