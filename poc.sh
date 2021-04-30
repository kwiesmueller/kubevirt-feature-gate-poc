#!/bin/bash

function print_features() {
    kubectl get featuregates.poc.kubevirt.io featuregates -ojson | jq .spec.config.features
}

function print_feature_definitions() {
    kubectl get crd featuregates.poc.kubevirt.io -ojson | jq .spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.config.properties.features
}

echo "apply the initial version of the CRD this contains an alpha, beta and a GA gate"
kubectl apply -f featureGate-crd.1.yaml > /dev/null

print_feature_definitions

echo "then send our first CR which enables the alpha gate and still specifies the GA gate"
kubectl apply -f featureGate-cr.1.yaml > /dev/null

echo "let's have a look at the resulting CR"
print_features
echo '''as we see, all three gates are in there and true even the one not specified, only featureD does not show as it is alpha and not specified.
This is caused by the defaults we provide'''

echo "now let's upgrade our CRD to the next release which removes the GA gate we deprecated"
kubectl apply -f featureGate-crd.2.yaml > /dev/null
print_feature_definitions

echo "first let's check what gates are returned after the output should not have changed as we keep everything in the features field around"
print_features

echo "now let's roll back that upgrade real quick and make sure all fields are still there"
kubectl apply -f featureGate-crd.1.yaml > /dev/null
print_features
echo "and upgrade again, expectations confirmed, yay"
kubectl apply -f featureGate-crd.2.yaml > /dev/null

echo "now let us remove the removed GA field from our CR, this should also remove it from the live config in-cluster"
kubectl apply -f featureGate-cr.2.yaml > /dev/null
print_features

echo "should we downgrade now, everything should still be fine"
kubectl apply -f featureGate-crd.1.yaml > /dev/null
print_feature_definitions
print_features

echo "cleanup"
kubectl delete -f featureGate-crd.1.yaml
