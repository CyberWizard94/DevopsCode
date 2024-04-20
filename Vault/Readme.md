Vault Installation:
********************

OVERVIEW:
*********

Install the Vault Helm Chart:
*****************************

Recommendation to run Vault on Kubernetes via Helm Chart

Add the HarshiCorp Helm repository:
************************************

helm repo add hashicorp https://helm.release.hashicorp.com

Update all the repositories to ensure helm is aware of the latest version.

helm repo update

Search for all the vault Helm chart versions:

helm search repo vault --version

The vault Helm chart contains all the necessary componenets to run in several different modes.

Default behaviour: by default, it launches Vault on a single pod in standalone mode with a file storage backend. Enabling high-availability with Raft Integrated Storage requires that you override these defaults.

Install the latest version of the vault Helm chart in HA mode with integrated storage

Prerequisites:

Install consul Helm chart for HA mode (PROD grade setup)

```
helm install consul ../consul --set global.name=consul --debug
```

```
kubectl get pods
consul-client-56ju88
consul-client-56ju88
consul-client-56ju88
consul-client-56ju88
consul-server-0
consul-server-1
consul-server-2
```

Create KMS key manually fot Auto-unseal feature.

Update the KMS Key details in helm chart:

```
config: |
  ui = true

  listener "tcp" {
    tls_disable = 1
    address = "[::]:8200"
    cluster_address = "[::]:8201"
  }

  seal "awskms" {
    region = "us-west-2"  #"KMS_REGION_HERE"
    kms_key_id = #"KMS_KEY_ID_HERE"
  }

  storage "consul" {
    address = "consul-server:8500"   #"HOST_IP:8500"
    path = "vault/"
  }
```

Vault Installation:

helm install vault vault ../vault \
    --set='server.ha.enabled=true' \
    --post-render ./helm-post.sh --debug

the vault pods and Vault Agent injector pod are deployed in the default namespace.

Get all the pods within the default namespace.
```
kubectl get pods

consul-client-58mlk
consul-client-58mlk
consul-client-58mlk
consul-client-58mlk
consul-server-0
consul-server-1
consul-server-2
vault-0                                    0/1
vault-1                                    0/1
vault-2                                    0/1
vault-agent-injector-75896fbb7c-9t2vp      1/1
```

The vault-0, vault-1, vault-2 pods deployed run a vault server and report that they are running but they are not ready(0/1). This is because the status check defined in a redinessProbe return a non-zero exit code

The vault-agent-injector pod deployed is a kubernetes Mutation Webhook Controller. The controller intercepts pod events and applies mutation to the pod if specific annotations exist within the request.

Retrive the status of Vault on the vault-o pod:
```
kubectl exec vault-0 --vault status
key                        Value
---                        -----
Seal Type                  shamir
Initialized                true
Sealed                     true
Total Shares               1
Threshold                  1
Unseal Progress            0/1
Unseal Nonce               n/a
Version                    1.10.3
Storage Type               raft
HA Enabled                 true
command terminated with exit code 2
```

The status command (exit code 2 means the vault is sealed). For Vault to authenticate with kubernetes and manage secrects requires that it is initialized and unsealed.

Initialize and unseal one vault pod
************************************

Vault starts uninitialized and in the sealed state. prior to initialization the integrated storage backend is not prepared to receive data.

Initialize vault with one key share and one key threshould

--key-share - Number of key shares to split the generated master key into. This is the number of "unseal keys" to generate.
--key-threshold - Number of key shares required to reconstruct the root key. This must be less than or equal to -key-shares.

```
kubectl exec vault-0 -- vault operator init
```
Note: Please note down the root token for test

The Vault server is initialized and auto-unsealed(As auto-unseal is enabled using AWS KMS)

Get all pods within the namespace.

```
kubectl get pods

consul-client-58mlk
consul-client-58mlk
consul-client-58mlk
consul-client-58mlk
consul-server-0
consul-server-1
consul-server-2
vault-0                                    1/1
vault-1                                    1/1
vault-2                                    1/1
vault-agent-injector-75896fbb7c-9t2vp      1/1
```

vault pods are ready after unseal.

Auto-unseal test: Delete any of the vault pods and it has to start the instance as unsealed

Set a Secrect in Vault:
************************

First, start an interactive shell session on the vault-0 pod.

```
kubectl exec --stdin=true  --tty=true vault-0 -- /bin/sh
/ $ vault login
    Token (will be hidden): # input the root token noted earlier
```

Enable kv-v2 secrects at the path secrect

```
vault secrect enable -path=secrect kv-v2
Sucess! Enable the kv-v2 secrects engine at: secrect/
```

Create a secrect at path secrect/app/config with a username and password

```
vault kv put secrect/app/config username='eng' password='123'
=========== Secrect Path =================
secrect/app/config 

=========== Metadata =================

Key                      value
created_time
custom_metadata
deletion_time
destroyed
version
```

verify that the secrect is defined at the path secrect/app/config

```
vault kv get secrect/app/config

=========== Secrect Path =================
secrect/app/config 

=========== Metadata =================

Key                      value
created_time
custom_metadata
deletion_time
destroyed
version

========= Data ===========
key               value
password
username
```

Configure Kubernetes authentication
*************************************

First start an interactive shell session on the vault-0 pod.

```
kubectl exec --stdin=true --tty=true  vault-0 -- /bin/sh
```

Enable the kubernetes authentication method

```
vault auth enable kubernetes
Sucess! Enabled kubernetes auth method at: kubernetes/
```

Vault backup and restore:

How to backup Harshicorp Vault with Raft storage on kubernetes(michaelin.me/backup-vault-with-raft-storage-on-kubernetes)
Vault with Disaster Recovery Replication enabled(developer.hashicorp.com/vault/tutorials/standard-procedures/sop-backup)






