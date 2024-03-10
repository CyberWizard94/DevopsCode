OVERVIEW:
*********

CiliumConnectivityCheck: One or more Cilium agent are unable to communicate with another agent

Cause: The Neighbour Table is Not Properly Updated
***************************************************

Cilium dosent update ARP(Address Resolution Protocol) address in the neighbour table on the nodes. The clean up of old entries also doesn't work cleanly. This leads to stale entries when a new node uses an IP that a previous node had been using

Resolution:
************
check the health of cilium for the node, endpoints, and connectivity to other nodes reporting the problem. Attempt to identify which node it is unable to communicate with.

kubectl exec <anetd-pod> -n <system> -- cilium status --verbose

conduct a Cilium Restart to attempt to fix the issue