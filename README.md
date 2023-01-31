# O11y Endless

This repo contains the needed files to deploy the multiclusterobservability at a RHACM hub level to be the central point for both metrics and logs. This is done through an opinated stack using a combination of Thanos/Loki/Grafana to provide a single-pane-of-glass experience with correlated metrics and logs.

## Prerequisites

* OpenShift 4.x Cluster

* Red Hat Advanced Cluster Management

* Red Hat OpenShift Data Foundation


## RHACM Policy Installation Option (Preferred)

### Create rhacm-policies namespace

```
oc new-project rhacm-policies
```

### Apply RHACM Policies

04_spoke-log-forwarding-policy.yaml will fail due to non-exist openshift-logging namespace, ignore this.

```
oc apply -f rhacm-policies/
```

Once the policies have been applied and enforced, openshift-logging should now exist. Apply the last policy for the spoke-clusters.

```
oc apply -f rhacm-policies/04_spoke-log-forwarding-policy.yaml
```


## Manual Installation Option (Alternative)

### Git clone repo

```
git clone https://github.com/CastawayEGR/o11y-endless.git
cd o11y-endless/
```

### Install MultiClusterObservability

```
oc apply -f 01-multiclusterobservability/
```

### Install Logging Stack

#### Scale workers if needed for Loki deployment

```
oc scale --replicas=5 machineset $(oc get machinesets -n openshift-machine-api -o jsonpath={.items[].metadata.name}) -n openshift-machine-api
```

```
oc apply -f 02-logging-deployment/00-namespace.yaml
oc apply -f 02-logging-deployment/01-logging-operators.yaml
oc apply -f 02-logging-deployment/02-object-bucket-claim.yaml
oc apply -f 02-logging-deployment/03-loki-storage-secret-sa.yaml
oc apply -f 02-logging-deployment/04-loki-storage-secret-cronjob.yaml
```

Machines must be provisioned and operator deployment finished to continue.

```
oc apply -f 02-logging-deployment/05-loki-stack.yaml
oc apply -f 02-logging-deployment/06-cluster-logging.yaml
```

### Deploying Grafana for the Single Pane of Glass experience

```
oc apply -f 03-grafana-deployment/00-namespace.yaml
oc apply -f 03-grafana-deployment/01-grafana-operator.yaml
```

Once the operator has completed installtion you may proceed.

```
oc apply -f 03-grafana-deployment/02-deploy-grafana.yaml
oc apply -f 03-grafana-deployment/03-grafana-sa.yaml
oc apply -f 03-grafana-deployment/04-observatorium-datastore-cronjob.yaml
oc apply -f 03-grafana-deployment/05-loki-datasource.yaml
oc apply -f 03-grafana-deployment/06-k8s-namespace-pod-compute.yaml
oc apply -f 03-grafana-deployment/07-k8s-workload-compute.yaml
oc apply -f 03-grafana-deployment/08-k8s-pod-compute.yaml
```

### Spoke cluster log forwarding

Run the following scripts to generate manifests for spokes.

```
cd 04-spoke-log-forwarding
./generate-log-gateway-token.sh
./generate-log-forward.sh
```

Now login to the spoke cluster and run the following.

```
oc login -u kubeadmin https://api.ocp4.opentlc.com:6443/
oc apply -f 00-namespace.yaml
oc apply -f 01-logging-operators.yaml
oc apply -f 03-log-gateway-token.yaml
```

Once the operator is successfully installed run the following.

```
oc apply -f 04-cluster-logging.yaml
oc apply -f 05-log-forwarding.yaml
```
