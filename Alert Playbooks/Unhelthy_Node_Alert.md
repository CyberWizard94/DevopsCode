OVERVIEW:
**********

Unhealthy Nodes: one or more of the nodes are failing the health check

Cause: The node status is unhealthy

The following condition are indications that a node is unhealthy

```
-> The node condition NotReady is true for approximately 10 minutes
-> The machine state is Unavailable for approximately 10 minutes after sucessful creation
-> The machine state is not available for approximately 30 minutes after VM creation
-> There is no node object(nodeRef is nil) corresponding to a machine in the Available state for approximately 10 minutes.
-> The node condition DiskPressure is true for approximately 30 minutes
```

Resolution:

The node manual repair will delete and re-create the node.

Set the kubeconfig to the respective cluster.

```
export KUBECONFIG=<<CLuster_kubeconfig_path>>
```

Run the below command to delete the machine.

```
kubectl get machine
kubectl annotate machine <MACHINE_NAME> onprem.cluster.gke.io/repair-machine=true
kubectl delete machine <<MACHINE_NAME>>
```