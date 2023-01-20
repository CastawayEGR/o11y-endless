#!/bin/bash
export token=$(oc get secret $(oc describe sa logcollector -n openshift-logging | grep Tokens | awk '{print $2}') -n openshift-logging -o go-template='{{.data.token}}')

envsubst < 03-log-gateway-token.yaml.template > 03-log-gateway-token.yaml 
