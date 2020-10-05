# Set up on-cluster PersistentVolumes storage using NFS on local node

Bare Openshift cluster installations, like for example Quicklab's Openshift 4 UPI clusters may lack persistent volume setup. This guide will help you set it up.

Please verify that your cluster really lacks `pv`s:

1. Login as a cluster admin
2. Lookup available `PersistentVolume` resources:

   ```bash
   \$ oc get pv
   No resources found
   ```

If there are no `PersistentVolume`s available please continue and follow this guide. We're gonna set up NFS server on the cluster node and show Openshift how to connect to it.

## Manual steps

See automated Ansible playbook bellow for easier-to-use provisioning

### Prepare remote host

1. SSH to the Quicklab node, and become superuser:

   ```sh
   curl https://gitlab.cee.redhat.com/cee_ops/quicklab/raw/master/docs/quicklab.key --output ~/.ssh/quicklab.key
   chmod 600 ~/.ssh/quicklab.key
   ssh -i ~/.ssh/quicklab.key -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" quicklab@HOST

   # On HOST
   sudo su -
   ```

2. Install `nfs-utils` package

   ```sh
   yum install nfs-utils
   ```

3. Create exported directories (for example in `/mnt/nfs`)

   ```sh
   mkdir -p /mnt/nfs/A ...
   ```

4. Populate `/etc/exports` file referencing directories from previous step to be accessible from your nodes as read,write:

   ```txt
    /mnt/nfs/A node1(rw) node2(rw) ...
    ...
   ```

5. Allow NFS in firewall

   ```sh
   firewall-cmd --permanent --add-service moun
   firewall-cmd --permanent --add-service rpc-bind
   firewall-cmd --permanent --add-service nfs
   firewall-cmd --reload
   ```

6. Start and enable NFS service

   ```sh
   systemctl enable --now nfs-serv
   ```

### Add PersistentVolumes to Openshift cluster

Login as a cluster admin and create a `PersistentVolume` resource for each network share using this manifest:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: NAME # Unique name
spec:
  capacity:
    storage: CAPACITY # Keep in mind the total max size, the Quicklab host has a disk size of 20Gi total (usually ~15Gi of available and usable space)
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /mnt/nfs/A # Path to the NFS share on the server
    server: HOST_IP # Not a hostname
  persistentVolumeReclaimPolicy: Recycle
```

## Using Ansible

To avoid all the hustle with manual setup, we can use an Ansible playbook [`playbook.yaml`](playbook.yaml).

### Setup

Please install Ansible and some additional collections from Ansible Galaxy needed by this playbook: [ansible.posix](https://galaxy.ansible.com/ansible/posix) for `firewalld` module and [community.kubernetes](https://galaxy.ansible.com/community/kubernetes) for `k8s` module.

```bash
$ ansible-galaxy collection install ansible.posix
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'ansible.posix:1.1.1' to '/home/tcoufal/.ansible/collections/ansible_collections/ansible/posix'
Downloading https://galaxy.ansible.com/download/ansible-posix-1.1.1.tar.gz to /home/tcoufal/.ansible/tmp/ansible-local-43567u9ge76rl/tmpyttcjmul
ansible.posix (1.1.1) was installed successfully

$ ansible-galaxy collection install community.kubernetes
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'community.kubernetes:1.0.0' to '/home/tcoufal/.ansible/collections/ansible_collections/community/kubernetes'
Downloading https://galaxy.ansible.com/download/community-kubernetes-1.0.0.tar.gz to /home/tcoufal/.ansible/tmp/ansible-local-29431yk2zoutk/tmpwgl4xsnb
community.kubernetes (1.0.0) was installed successfully
```

### Configuration

Please view and modify the `env.yaml` file (or create additional variable files, and select it before executing playbook via `vars_file` variable)

Example environment file:

```yaml
quicklab_host: "upi-0.tcoufaldev.lab.upshift.rdu2.redhat.com"

pv_count_per_size:
  1Gi: 6
  2Gi: 2
  5Gi: 1
```

- `quicklab_host` - Points to one of the "Hosts" from your Quicklab Cluster info tab
- `pv_count_per_size` - Defines PV counts in relation to maximal allocable sizes map:
  - Use the target PV size as a key (follow GO/Kubernetes notation)
  - Use volume count for that key "size" as the value
  - Keep in mind the total size sum(key\*value for key,value in pv_count_per_size.items()) < Disk size of the Quicklab instance (usually ~15Gi of available space)

### Run the playbook

Run the `playbook.yaml` (if you created a new environment file and you'd like to use other than default `env.yaml`, please specify the file via `-e vars_file=any-filename.yaml`)

```bash
$ ansible-playbook playbook.yaml
PLAY [Dynamically create Quicklab host in Ansible] **********************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************
ok: [localhost]

TASK [include_vars] *****************************************************************************************************************************************************************
ok: [localhost]

TASK [set_fact] *********************************************************************************************************************************************************************
ok: [localhost]

TASK [Fetch Quicklab certificate] ***************************************************************************************************************************************************
ok: [localhost]

TASK [Adding host] ******************************************************************************************************************************************************************
changed: [localhost]

PLAY [Setup NFS on Openshift host] **************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************
ok: [quicklab]

TASK [Install the NFS server] *******************************************************************************************************************************************************
ok: [quicklab]

TASK [Create export dirs] ***********************************************************************************************************************************************************
ok: [quicklab] => (item=['1Gi', 0])
ok: [quicklab] => (item=['1Gi', 1])
ok: [quicklab] => (item=['1Gi', 2])
ok: [quicklab] => (item=['1Gi', 3])
ok: [quicklab] => (item=['1Gi', 4])
ok: [quicklab] => (item=['1Gi', 5])
ok: [quicklab] => (item=['2Gi', 0])
ok: [quicklab] => (item=['2Gi', 1])
ok: [quicklab] => (item=['5Gi', 0])

TASK [Populate /etc/exports file] ***************************************************************************************************************************************************
ok: [quicklab]

TASK [Allow services in firewall] ***************************************************************************************************************************************************
ok: [quicklab] => (item=nfs)
ok: [quicklab] => (item=rpc-bind)
ok: [quicklab] => (item=mountd)

TASK [Reload firewall] **************************************************************************************************************************************************************
changed: [quicklab]

TASK [Enable and start NFS server] **************************************************************************************************************************************************
changed: [quicklab]

PLAY [Create PersistentVolumes in OpenShift] ****************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************
ok: [localhost]

TASK [Find IPv4 of the host] ********************************************************************************************************************************************************
ok: [localhost]

TASK [Create PersistentVolume resource] *********************************************************************************************************************************************
ok: [localhost] => (item=['1Gi', 0])
ok: [localhost] => (item=['1Gi', 1])
ok: [localhost] => (item=['1Gi', 2])
ok: [localhost] => (item=['1Gi', 3])
ok: [localhost] => (item=['1Gi', 4])
ok: [localhost] => (item=['1Gi', 5])
ok: [localhost] => (item=['2Gi', 0])
ok: [localhost] => (item=['2Gi', 1])
ok: [localhost] => (item=['5Gi', 0])

PLAY RECAP **************************************************************************************************************************************************************************
localhost                  : ok=8    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
quicklab                   : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
