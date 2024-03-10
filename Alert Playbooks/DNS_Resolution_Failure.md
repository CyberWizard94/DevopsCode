To debug DNS failure from pods, we need to create a dnsutils pod.

kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml

Pod/dnsutils created

Once that pod is running, you can exec nslookup in that environment. If you see something like the following, DNS is working correctly

kubectl exec -it dnsutils -- nslookup kubernetes.default

Server:
Address:

Name:        kubernetes.defaults
Adress 1:    10.0.0.1

if the nslookup command fails, check the following

Check the local DNS Configuration first:
******************************************

Take a look inside resolv.conf file

kubectl exec -it dnsutils -- cat /etc/resolv.conf

Vrify that the search path and nameserver are set up like the following(it can vary depending on org)

search default.svc.cluster.local svc.cluster.local ...
nameserver 10.0.0.10


check if DNS Pods are running.
******************************************

kubectl get pods --namespace=kube-system -l k8s-app=kube-dns


If the pods are not running, restart te pods.

Check for error in the DNS pod:
********************************

kubectl logs --namespace=kube-system -l k8s-app=kube-dns


Are DNS queries being received/Processed?
******************************************
You can verify if queries are being received by CoreDNS by ading the log plugin to the CoreDNS configuration(aka Corefile). The CoreDNS corefile is held in a config map name coredns.

kubectl -n kube-system edit configmap coredns

Then add log in the corefile section per the example below:

apiVersion: v1
kind: Configmap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        log
        errors
        health
        ..
    }

After changing it will take some time to be applied.

Make some quiries and caheck in logs whats the error


Does CoreDNS have sufficient Permissions?
******************************************

CoreDNS must be able to list service and endpoint related resources to properly resolve service name.

check clusterrole of system:coredns.

Restart anetd and kubedns pods if you are using kube-dns:

kubectl rollout restart daemonset anetd -n kubesystem
kubectl rollout restart deployment kube-dns -n kubesystem
