TEAM MONITERING
******************

Overview
******************

The environment offers a full self-service tenant-level prometheus, Alertmanager, and Grafana stack to provide visibility into application & container metrics. This page provides information regarding the Team Monitering setup and configurations.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

URLS:

Grafana: grafana-<tenant>-<cluater>.as.com
prometheus: prometheus-<tenant>-<cluater>.as.com
Alertmanager: alertmanager-<tenant>-<cluater>.as.com
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Deploying Team Monitering:
****************************

The installation of Team Monitering consists of two helm charts. They're usually deployed on a one team per cluster basis. For example if your team has more than one namespace on a single cluster, you only need to install Team Monitering once in each cluster, you will then configure the Team Monitering helm charts to get access to all your namespaces. The parameter defaultRules.appNamespacesTarget value on kube-prometheus-stack chart and appNamespacestarget in anthos-team-monitering. In addition the anthos-team-monitering chart will need to have the additional namespaces listed under parameter global.namespaces

For example, if helm charts were to be installed in the namespace team-dev and you also need to moniter namespaces team-tst and team-stg

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#kube-prometheus-stack
[...]
defaultRules:
  appNamespaceTarget: 'team-(dev|tst|stg)'
[...]
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#anthos-team-monetering
[...]
global:
  namespaces:
    - team-tst
    - team-stg
[...]
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

kube-prometheus-stack
*************************

The helm chart installs the core prometheus and Alertmanager applications

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
helm install team-dev-kube-prometheus-stack  kube-prometheus-stack  --version 44.2.1 -n <namespace> -f ./values.yaml --skip-crds
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Customized Values:
********************

we can have some customized values for kube-prometheus-stack . 

defaultRules.appNamespaceTarget               Tenent namespace Regex             team-(tet|dev)
alertmanager.alertmanagerSpec.externalUrl     Alertmanager url                    https://alertmanager-teams-test-as.com
prometheus.prometheusSpec.externalUrl         prometheusurl                       https://prometheus-edge-test.as.com


team-monitoring
*****************

This helmchart installs the RBAC integration Grafana and default dashboards, custom Prometheus rules and all Virtualservice Objects

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
helm install team-dev-monitering team-monitering  --version 0.0.3 -n <namespace> -f ./values.yaml
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Customized values:
*****************

The values file customizes the Helm Chart. These values are specific to Alertmanager and Prometheus

global.ingressgateway                  Ingress Gateway                          isyio-system/default-gateway
global.namespaces                      List of addditional namespaces           []
appNamespacestarget                    Tenant Namespace regex                   team-(tst|dev|stg|prd)


Prometheus:
*****************

it is in prometheus where you're going to view any active PrometheusRule, PodMoniter and ServiceMoniter objects.

Alerts:
*****************

default alerts are configured

Rules:
*****************

This are alertmanager.rules when alert manager can moniter

Targets:
*****************

Service Moniter targets


Creating a custom PrometheusRule:
**********************************

By default, Team Monitering comes with the following Prometheus rules enabled:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
kubectl get prometheusRule

NAME                                               AGE
team-dev-kube-prometheus-stack-alertmanager.rules   20d
team-dev-kube-prometheus-stack-k8s.rules            20d
team-dev-kube-prometheus-stack-general.rules        20d
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Notice that each PrometheusRule name prefix corresponds to the helm chart that installed the PrometheusRule.

All Custom PrometheusRules must have the app: kube-prometheus-stack label:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
apiversion: monitering.coreos.com/v1
kind: prometheusRule
metadata:
  name: team-monitering-test-alert
  namespace: <namespace>
  labels:
    app: kube-prometheus-stack
spec:
  [...]
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Once the custom PrometheusRule has beem created, it will apperar on prometheus UIS.

Additional links on creating Prometheus alerting and recording rules:
**********************************

https://www.prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
https://www.prometheus.io/docs/prometheus/latest/configuration/recording_rules/#recording-rules
https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRuleSpec

Updating default PrometheusRules:
**********************************

All default PrometheusRules can be updated usong HelmPostrender

1) completed Helm Post Render Prerequisites
2) setup kustomize Overlay Layout
|-- chart
    |__ values.yaml
|__ overlays
    |__ uls-stg01
        |__ kustomization.yaml
        |__ patch.yaml

3) kustomize.yaml file
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
resources:
  - all.uyaml
  patches:
    - target:
        kind: PrometheusRule
        name: team-monetering-quota
      patch: patch.yaml
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
4) create patch.yaml file
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
- op: replace
  patch: "/spec/groups/0/rules/0/expr"
  value: |-
         kube_resourcesquota{job="kube-state-metrics", type="used", namespace=~"team-(tst|dev)"}
           / ignoring(instance, job, type)
         (kube_resourcequota{job="kube-state-metrics", type="hard", namespace=~"team-(tst|dev)"} > 0)
           > 0.999999 < 1
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

5) chenge to directory containing kustomize overlay file for a specific deployment

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
helm upgrade --install team-dev-monitering team-monitering  --version 0.0.3 -n <namespace> -f ./values.yaml --post-render=./helm-post.sh
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

To see the default rule:

you can go to prometheus UI and check under rules.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
kubectl get PrometheusRule team-monitering-auota -o jsonpath="{.spec}" | jq
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Creating a custom PodMoniter and ServiceMoniter:
**************************************************

Question: when should I use a PodMoniter or a serviceMoniter?

Answer: Technically both achive the same goal of having Prometheus Scrape custom Metrics. However for simplicity, we only encourage using PodMoniter

we'll walk through creating a custom PodMonitor and ServiceMonitor using a simple Ngnix Deployment. The Ngnix Deployment has two containers, the actual Ngnix app container with the stub_status(https://ngnix.org/en/docs/http/ngx_http_stub_status_module.html) module enabled which grants accesss ti the built-in server status information, and second container is the Prometheus ngnix-Prometheus-exporter which publishes the metrics scraped from stub_status module.


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---
apiVersion: v1
king: ConfigMap
metadata:
  name: ngnix-default-conf
  labels:
data:
  default.conf: |
    server {
        listen       80;
        listen   [::]:80;
        server_name   localhost;
        location /metrics {
            stub_status  on;
            access_log   on;
            allow_all;
        }
        error_page  404         /404.html;
        error_page  500 502 503 504  /50x.html;
        location = /50x.html {
            root    /usr/share/ngnix/html;
        }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
  name: ngnix-example
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ngnix-example
  template:
    metadata:
      labels:
        app: ngnix-example
    spec:
      containers:
      - image: ngnix:latest
        name: ngnix
        ports:
          - name: web
            conatinerPort: 80
        resources:
          limits:
            cpu: 500m
            memory: 128Mi
        volumeMounts:
        - name: ngnix-default-conf
        mountPath: /etc/ngnix/conf.d/default.conf
        subPath: default.conf
      - image: ngnix/ngnix-prometheus-exporter:0.9.0
        name: ngnix-prometheus-exporter
        args:
          - ngnix.scrape-uri=http://localhost/metrics
        ports:
          - name: metrics
            containerPort: 9113
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
    volumes:
    - name: ngnix-default-conf
      configMap:
        name: ngnix-default-conf
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Verify deployment:

NGNIX_POD=$(kubectl get pods -l app=ngnix-example -o jsonpath='{.items[0].metadata.name}')
kubectl exec $NGNIX_POD -c ngnix -- curl -Ss http://localhost:9113/metrics

PODMONITER:
**********************************

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---
apiVersion: monitering.coreos.com/v1
kind: PodMonitor
metadata:
  name: ngnix-example-podmonitor
  labels:
Spec:
  namespaceSelector:
    matchNames:
      - team-dev
    selector:
      matchLabels:
        app: ngnix-example
    podMetricsEndpoints:
    - port: metrics
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

after podMoniter object is created, it will appear within the "Targets" and "Service Discovery" Pages in the Prometheus UI:

ServiceMoniter:
**********************************

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---
apiVersion: v1
kind: service
metadata:
  name: ngnix-example
  labels:
    app: ngnix-example
spec:
  type: ClusterIP
  ports:
  - port: 80
    name: web
  - port: 9113
    name: metrics
  # These are the pod labels
  selector:
    app: ngnix-example
---
apiVersion: monitering.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ngnix-example
  labels:
    app: ngnix-example
Spec:
  # Namespace where ngnix Deploymwnt was deployed
  namespaceSelector:
    matchNames:
      - team-dev
    #Service exposed exporter
    endpoints:
      - patch: "/metrics"
        port: metrics
    # these are the labels of the service object
    selector:
      matchLabels:
        app: ngnix-example
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
After the Service monitor object has been created, it will appear within the "Targets" and "service Discovery" pages in the Prometheus UI.

Alert Manager:
**********************************


Creating Custom Alertmanager config:
**********************************

Alertmanager is configured using the Alertmanagerconfig object. The AlertmanagerConfig object is defined on a per namespace basis. For example, if your team has two active namespaces on a cluster, and you want to create an alerting config for them, you will have created an AlertmanagerConfig on each namespace.

 The following example Alertmanagerconfig uses SMTP for notification:
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 apiVersion: monitering.coreos.com/v1alpha1
 kind: AlertmanagerConfig
 metadata:
   name: config-example
   namespace; <namespace>
   labels:
Spec:
  route:
    groupBy: ['job']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 2h
    receiver: 'smtp'
  receivers:
  - name: 'smtp'
    emailConfigs:
    - smarthost: mailrelay.as.com:25
    requireTLS: true
    from: vinod@gmail.com
    to: 'team-dl'
    tlsConfig:
      insecureSkipVerify: true
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 this will apper alertmanagerconfig object is created in status section of Alertmanager

 Grafana:
**********************************

 All Grafana dashboard objects are imported from ConfigMap objects. Grafana comes with the following dashboard enabled.

 kubectl get comfigmaps -l grafana_dashboard=1

 Creating Custom dashboards:
**********************************

in order to for grafana to load dashboard the configMap must be saved in the same namespace where the grafana Deployment is running. Also the configmap manifest must have the following label:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
labels:
  grafana_dashboard: "1"
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

The name of the json file in the Configmap must be unique across all Grafana dashboards. otherwise Grafana will overwrite any dashboard that has the same json file name. For example in the following configMap, Grafana will be using the file name "ngnix-dashboard.json" to import the dashboard

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    grafana_dashboard: "1"
  name: monitoring-ngnix-dashboard
data:
  ngnix-dashboard.json: |-
    {
        [...]
    }
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Apply above yaml file

Advanced Usage:

Alertmanager MS-Teams integration:

1) create incoming Webhook
Go to MS Teams --> apps --> serch for incoming webhook --> create it

2)  create config.ini file and copy the webhook token to it.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[HTTP Server]
Host:  0.0.0.0
port: 8089

[Microsoft teams]
ms-teams: <MS-TEAMS-WEBHOOK-TOKEN>

[Group Alerts]
Feild: name
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

3) create a secret named "prom2teams-config" using the config.ini file.

kubectl create secrect generic prom2teams-config  --from-file=config.ini

4) Deploy prom2teams  Deployment and service

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: prom2teams
   name: prom2teams
spec:
  replicas: 2
  selector:
    matchlabels:
      app: prom2teams
  strategy: {}
  template:
    metadata:
      labels:
        app: prom2teams
  spec:
    containers:
    - image: idealista/prom2teams:latest
      name: prom2teams
      ports:
        - name: web
          conatainerPort: 8089
      resources:
        limits:
          cpu: 200m
          memory: 128Mi
      env:
      - name: PROM2TEAMS_PROMETHEUS_METRICS
        value: "true"
      - name: PROM2TEAMS_HOST
        value: "0.0.0.0"
      - name: PROM2TEAMS_PORT
        value: "8089"
      volumeMounts:
      - name: config
        mountPath: /opt/prom2teams/config.ini
        subPath: config.ini
    volumes:
    - name: config
      secrect:
        secrectName: prom2teams-config
---
apiVersion: v1
kind: service
metadata:
  name: prom2teams
  labels:
    app: prom2teams
spec:
  type: ClusterIP
  ports:
  - port: 8089
    name: http
  # These are the pod labels
  selector:
    app: prom2teams
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

5) Deploy AlermanagerConfig
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
apiVersion: monitering.coreos.com/v1alpha1
 kind: AlertmanagerConfig
 metadata:
   name: config-example-teams
   labels:
Spec:
  route:
    groupBy: ['job']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 2h
    receiver: 'teams'
  receivers:
  - name: 'smtp'
    webhookConfigs:
    - url: http://prom2teams:8089/v2/ms-teams
      sendResolved: true
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++