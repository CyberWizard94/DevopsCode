Deploying Jenkins
******************

jenkins chart: https://github.com/jenkinsci/helm-charts


components of jenkins:
***********************

This chart installs a jenkins server which spawns agents on kubernetes utilizing the jenkins kubernetes plugin(https://plugins.jenkins.io/kubernetes/)

Jenkins Sever or Master node holds all key configurations like jenkins jobs, plugins, user, Global Security, Nodes/Cloud configurations. All the configurations for the above-mentioned components will be present as a config file in jenkins master node.

jenkins agent are the workers for the job configured in jenkins server. when you trigger a jenkins job from the master, the actual execution happens on the agent. Agents are dynamically created as a kubernetes pod and stops it after each build.

Deploying Jenkins:
******************

helm upgrade --install kubernetes-jenkins <helm-repo>/jenkins --values ../values.yaml --version 4.3.2 -n <namespace> 

You need to update some of the values from default jenkins helm chart values:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Master:

controller.image
controller.tag
controller.imagePullSecretName
controller.adminPassword
controller.installplugins(image already has pre-installed plugins. if any extra plugins required that can be passed here)

Agent:

agent.image
agent.tag
agent.imagePullSecrectName
agent.customJenkinsLabels

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Verify Deployment:
********************

kubectl get pods -n <namespace>

Verify that the volume is created:

kubectl get pvc -n <namespace>


Accesing Jenkins UI:
***********************

1. Using Kubeforwarding 

kubectl -n <namespace> port-forward svc/<servicename> 8080:8080

2. Exposing service:

we can access jenkins by creating virtual service

kubectl get svc -n <namespace>

Virtual service yaml file:
****************************

```
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: <name>-vs
  namespace: <>
spec:
  gateways:                         # we specify the gateway like istio
  - istio-system/default-gateway
  hosts:                            # we need to specify url
  - <name>.<something>.com
  http:                             # path after url
  - match:
    - uri:
        prefix: /
    route:
    - destination:                  # service where the traffic comes from
        host: <service name>
        port:
          number: <service port>
```

kubectl apply -f expose-jenkins.yaml -n <namespace>

Adding New plugins through values file:
*******************************************
Master image already has some plugins pre-installed. In case if you require additional plugins to be installed during jenkins deployment this can be done by passing it in values.yaml file like below

```
controller:
  installPlugins:
    - email-ext:2.83
    - ant:1.11
```

Configuring the AD authentication:
***************************************
AD authentication can be configured by passing parameters in values file as below. To configure AD authentication, you should have credentials(binduser and bindpassword) to authenticate the AD server with a AD service account.

we can add the AD server(ldap.ad.shared:636) certificate to JDK_TRUSTSTORE of jenkins master by building custom image.

Below are the steps:

1. create kubernetes secrect with data for AD username, password and AD group that needs access for jenkins.

```
kubectl create secrect generic jenkins-ad-bind-auth --from-literal=bindpasswd=<password> --from-literal=binduser=<User Name> --from-literal=adgroup=<AD_GROUP> -n <namespace> -o yaml --dry-run=client > jenkins-ad-bind-auth-secrect.yaml

kubectl apply -f jenkins-ad-bind-auth-secrect.yaml -n <namespace>

kubectl get secrect jenkins-ad-bind-auth -n <namespace>
```

2. update values.yaml file to use secrect created in earlier step in configscript for AD server configuration and Project Matrix Based authorization Streategy(plugins.jenkins.io/matrix-auth/#documentation).

```
controller:
  additionalExistingSecrets:
      - name: jenkins-ad-bind-auth
        keyName: binduser
      - name: jenkins-ad-bind-auth
        keyName: bindpasswd
      - name: jenkins-ad-bind-auth
        keyName: adgroup
  JCasC:
      configScripts:
        ad-settings: |
          securityrealm:
          activeDirectory:
          domains:
          - name: "ad.shared"
            server: "ldap.ad.shared:636"
            bindName: "${jenkins-ad-bind-auth-binduser}"
            bindPassword: "${jenkins-ad-bind-auth-bindpassword}"
            tlsConfiguration: JDK_TRUSTSTORE
          groupLookupStreategy: RECURSIVE
          removeIrrelevantGroups: false
          customDomain: true
          startTls: true
          requireTLS: true
      ad-configure-auth:
        jenkins:
          authorizationStreategy:
            projectMatrix:
              permissions:
                - "overall/Administer:${jenkins-ad-bind-auth-adgroup}"
                - "Job/Discover:authenticated"
                - "Job/Read:anonymous"
                - "job/Read:authenticated"
                - "Overall/Read:authenticated"
                - "View/Read:anonymous"
```

Create Sample Pipeline Job:
****************************

Artifactory login credentials should be base64 encoded.

```
echo -n "<username@ad.shared>:<password>" | base64

# generate docker auth secrect which is required push the image to private registery. kaniko uses this credentials

cat artifactory-config
{
    "auths" : {
        "https://<artifactory url>:<port>" : {
            "auth": "Base64 encoded <username@ad.shared>:<password>",
            "email": "email"
        }
    }
}

# create kubernetes secrect

kubectl create secret generic artifact-jenkins-config --from-file=config.json=artifact-config -n <namespace> -o yaml --dry-run=client > artifact-jenkins-config-secrect.yaml

kubectl apply -f artifact-config-secrect.yaml -n <namespace>
```

Create credentialID to use in pipeline for Git functionality:
*************************************************************

Navigate to manage jenkins -> Manage Credentials -> Jenkins -> Global Credentials -> Add credentials

scope: Global
Username: 
Password:
ID:
Descreption:

JenkinsFile:

Below jenkinsFile uses kaniko(github.com/GoogleContainerTools/kaniko) to build the image and push the image to artifactory. Artifactory credentials are passed as a secrect to kaniko container.
The workspace volume for agent should be used as dynamic PVC as by default reclaim policy is set to Delete.

```
pipeline{
    agent {
        kubernetes {
            inheritFrom 'default'
            workspaceVolume dynamicPVC(storageClassName: 'px-jobs', requestSize: "1Gi", accessMode: 'ReadWriteOnce')
            yaml """
              kind: pod
              spec:
                securityContext:
                  runAsUser: 1000
                  fsGroup: 1000
              containers:
              - name: kaniko
                image: <artifactory>:<port>/kaniko-project/executor:debug
                imagePullPolicy: Always
                command:
                - sleep
                args:
                - 99999
                volumeMounts:
                  - name: artifact-jenkins-config
                    mountPath: /kaniko/.docker
                resources:
                  limits:
                    cpu: 500m
                    memory: 500Mi
                  requests:
                    cpu: 100m
                    memory: 100Mi
              volumes:
                - name: artifact-jenkins-config
                  secret:
                    secretname: artifact-jenkins-config
        }
    }
}

stages {
    stage ('Git Checkout') {
        steps {
            checkout changelog: false, poll: false,
            scm: [$class: 'GitSCM',
            branches: [[name: 'develop']],
            extensions: [],
            userRemoteConfigs: [[credentialsId: '<CREDENTIALS_ID>', url: '<APPLICATION_REPOSITORY>']]]
        }
    }
    stage('Build with kaniko') {
        steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
                sh """
                     /kaniko/executor  --dockerfile `pwd` /Dockerfile --context `pwd` --destination=<ARTIFACTORY LOCATION>
                 """
            }
        }
    }
}
```

Bitbucket Server Integration:
*************************************************************
The Bitbucket server integration plugin is the easiest way to connect jenkins to Bitbucket server


Install Bitbucket Plugin
*************************

Install both the Bitbucket and Bitbucket branch source Plugin

Configure Bitbucket Plugin
***************************

Create jenkins credentials with a service account with access to the Bitbucket projects and/or repositories()

Input the WD Bitbucket Endpoint configuration in jenkins

Select Manage hooks, set the credentials created earlier and leave the defaults foee the rest of the Manage hooks settings

```
Bitbucket Endpoints

Bitbucket Server

Name: <name>
Server URL: https://bitbucket.rs.com
Server Version: 
* call can merge
* call changes api
* Manage hooks
credentials:
Custom Jenkins hook URL:
Webhook Implementation to use: Plugin
```

Configure Jenkins Job
**********************

Add a Bitbucket source to your jenkins job

Select the Bitbucket server created above, set the credentials to the same as above and enter the owner.

The Owner is the shorthand project name that can be found in the Bitbucket URL and case does not matter

Jenkins will then discover all repositories within the project and select the appropriate repository.

Branch Sources
```
Bitbucket

Server: VD(https://bitbucket.as.com)
Credentials:
owner: vinod
Repository Name: <repository name>
```

Trigger the Job:
*****************

A jenkins build will now trigger on a push to remote and pull Request(PR) creation.
The Jenkins job will post job status to the post hook create by jenkins in the repository
This can be viewed on the branch and PR

Email Notification Configuration:
*********************************
In order to be able to send E-mail notification, make sure plugin mailer(plugins.jenkins.io/mailer/) is installed. Mail server configuration must be updated in the Manage Jenkins page, 

Configure System > E-mail Notification section

Below are the details:

```
SMTP server: asrelay.as.com
Default user e-mail suffix: @as.com
```


We can use multiple containers for multiple stages:

```
podTemplate(containers: [
    containerTemplate(name: 'maven', image: 'maven:3.8.1-jdk-8', command: 'sleep', args: '99d'),
    containerTemplate(name: 'golang', image: 'golang:1.16.5', command: 'sleep', args: '99d')
  ]) {

    node(POD_LABEL) {
        stage('Get a Maven project') {
            git 'https://github.com/jenkinsci/kubernetes-plugin.git'
            container('maven') {
                stage('Build a Maven project') {
                    sh 'mvn -B -ntp clean install'
                }
            }
        }

        stage('Get a Golang project') {
            git url: 'https://github.com/hashicorp/terraform.git', branch: 'main'
            container('golang') {
                stage('Build a Go project') {
                    sh '''
                    mkdir -p /go/src/github.com/hashicorp
                    ln -s `pwd` /go/src/github.com/hashicorp/terraform
                    cd /go/src/github.com/hashicorp/terraform && make
                    '''
                }
            }
        }

    }
}
```