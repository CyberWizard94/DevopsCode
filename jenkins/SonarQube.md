OVERVIEW:
***********

SonarQube (formerly Sonar) is a open-source platform developed by SonarSource for continuous inspection of code quality to perform automatic reviews with static analysis of code to decect bugs and code smells on 29 programming laungauges.

SonarQube offers reports on duplicated code, coding standards, unit tests, code coverage, code complexity, comments, bugs, and security recommendations.

Also, SonarQube provides fully automated analysis and integration with Maven, Ant, Gradle, MSbuild and continuous integration tools(Atlassian Bamboo, Jenkins, Hudson, etc)

Sonarqube-architecture(https://scm.thm.de/sonar/documentation/architecture/architecture-integration/)

Deploying SonarQube:
********************

```
helm upgrade --install dev-sonarqube sonarqube --version 8.0.0+463 -n <namespace> -v ./values.yaml
```


Verify Deployment:
******************

Once the chart has been deployed, check that the Dask scheduler and workers are up and running

```
kubectl get pods -n <sonar-namespace>
```

Expose Sonarqube:

Create virtual service to access Sonarqube.

kubectl get svc -n <sonar-namespace>

Virtual service YAML:

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

kubectl apply -f expose-sonarqube.yaml -n <sonar-namespace>

We can access the virtual service URL, and login using default Login/Password is admin/admin

Jenkins Integration:
**********************

The sonarqube scanner plugin is the easiest way to integrate jenkins with SonarQube

Generate SonarQube authentication token:
***************************************

Browse to your SonarQube URL, then Administration/Security/User/Tokens and generate the token used for jenkins authentication.

Install SonarQube scanner Plugin to Jenkins:
********************************************

Browse to your Jenkins URL, then Plugin Manager and install SonarQube Scanner plugin

Add SonarQube to Jenkins:
**************************

Browse to your Jenkins URL, then Manage Jenkins/Configure system and add SonarQube installation along with checking Environment variables.

SonarQube server:
* Environment variables

Name: SonarQube
Server Url: <virtual service URL>
Server authentication token: Sonar Qube token


Add SonarQube Scanner to jenkins:
**********************************

Browse to your jenkins URL, then Manage Jenkins/Global Tool configuration and SonarQube Scanner installation

```
SonarQube Scanner:
Name: Sonarqubescanner
* Install automatically
```

Create Jenkins Pipeline job:
**********************************
browse to your Jenkins URL, then create pipeline job for the respective build tools.

SonarScanner:
**********************************

```
node{
    stage('SCM') {
        git 'https://github.com/SonarSource/sonar-scanning-example.git'
    }
    stage('SonarQube analysis') {
        def scannerHome = tool 'SonarQubeScanner';
        withSonarQubeEnv(credentialsId: 'SonarQubeToken', installationName: 'SonarQube') {
            sh "cd sonarqube-scanner && ${scannerHome}/bin/soanr-scanner"
        }
    }
}
```

SonarScanner for Gradle: 

```
node{
    stage('SCM') {
        git 'https://github.com/foo/bar.git'
    }
    stage('SonarQube analysis') {
        def scannerHome = tool 'SonarQubeScanner';
        withSonarQubeEnv()  { // Will pick the global server connection you have configured
            sh "./gradlew sonarqube"
        }
    }
}
```

SonarScanner for Maven: 

```
node{
    stage('SCM') {
        git 'https://github.com/foo/bar.git'
    }
    stage('SonarQube analysis') {
        def scannerHome = tool 'SonarQubeScanner';
        withSonarQubeEnv(credentialsId: 'SonarQubeToken', installationName: 'SonarQube')  { 
            connection you have configured
            sh "mvn org.sonarsource.scanner.mavem:sonar-maven-plugin:3.7.0.1746;sonar"
        }
    }
}
```

SonarScanner for Ant:

```
node{
    stage('SCM') {
        git 'https://github.com/foo/bar.git'
    }
    stage('SonarQube analysis') {
        def scannerHome = tool 'SonarQubeScanner';
        withSonarQubeEnv(credentialsId: 'SonarQubeToken', installationName: 'SonarQube')  {
            connection you have configured
            sh "ant sonar"
        }
    }
}
```

SonarScanner for .NET:
 
```
node{
    stage('SCM') {
        git 'https://github.com/foo/bar.git'
    }
    stage('Build + SonarQube analysis') {
        def sqScannerMsBuildHome = tool 'Scanner for MSBuild 4.6'
        def scannerHome = tool 'SonarQubeScanner';
        withSonarQubeEnv(credentialsId: 'SonarQubeToken', installationName: 'SonarQube')  { 
            bat "${sqScannerMsBuildHome}\\SonarQube.Scanner.MSBuild.exe begin /k:myKey"
            bat "MSBuild.exe /t:Rebuild"
            bat "${sqScannerMsBuildHome}\\SonarQube.MSBuild.exe end"
        }
    }
}
```


trigger jenkins job and go to sonarqube Url to check the results.