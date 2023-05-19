#!/bin/bash

set -e

# Create the k8s-workload-registrar crd, configmap and associated role bindingsspace
kubectl apply \
  -f spire-ns.yaml \
  -f spiffeid.spiffe.io_spiffeids.yaml \
  -f k8s-workload-registrar-crd-cluster-role.yaml \
  -f k8s-workload-registrar-crd-configmap-foo.yaml

# Deploy spire server foo domain
kubectl apply -f spire-server-foo.yaml

# Deploy spire agents foo domain
kubectl apply -f spire-agent-foo.yaml

# Applying SPIFFE CSI Driver configuration
kubectl apply -f spiffe-csi-driver.yaml
