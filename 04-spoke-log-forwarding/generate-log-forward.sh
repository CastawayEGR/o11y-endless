#!/bin/bash
export URL=$(oc get route logging-loki -n openshift-logging -o jsonpath='{.spec.host}')
envsubst < 05-log-forwarding.yaml.template > 05-log-forwarding.yaml 
