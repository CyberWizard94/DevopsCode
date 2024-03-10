OVERVIEW:
*********
In some cases, we keep on getting pd alerts and several pods are evicting continuously.

Steps:
******

-> Find Node(s) on which the pods are evicting continuously.
-> Check the host and node utilization from vsphere
-> If the host utilization reaches its threshold, then perform vmotion for the node to land onto other healthy host
-> If the node utilization reaches its threshold, then perform node replace and make sure that all the PX volume of the node having minimum 2 repl.

k drain --ignore-daemonsets <<Node_name>>
k delete node <<NODE_NAME>>
k delete machine <<NODE_NAME>>
