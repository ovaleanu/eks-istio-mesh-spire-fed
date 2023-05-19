#!/bin/bash

set -e

# Create the k8s-workload-registrar crd, configmap and associated role bindingsspace
kubectl apply \
  -f spire-ns.yaml \
  -f spiffeid.spiffe.io_spiffeids.yaml \
  -f k8s-workload-registrar-crd-cluster-role.yaml \
  -f k8s-workload-registrar-crd-configmap-bar.yaml

# Deploy spire server bar domain
kubectl apply -f spire-server-bar.yaml

# Deploy spire agents bar domain
kubectl apply -f spire-agent-bar.yaml

# Applying SPIFFE CSI Driver configuration
kubectl apply -f spiffe-csi-driver.yaml
