#/bin/bash

set -e


export CTX_CLUSTER1=foo-eks-cluster
export CTX_CLUSTER2=bar-eks-cluster

istioctl install -f ./foo-istio-conf.yaml --context="${CTX_CLUSTER1}" --skip-confirmation
kubectl apply -f ./auth.yaml --context="${CTX_CLUSTER1}"
kubectl apply -f ./istio-ew-gw.yaml --context="${CTX_CLUSTER1}"

istioctl install -f ./bar-istio-conf.yaml --context="${CTX_CLUSTER2}" --skip-confirmation
kubectl apply -f ./auth.yaml --context="${CTX_CLUSTER2}"
kubectl apply -f ./istio-ew-gw.yaml --context="${CTX_CLUSTER2}"


istioctl x create-remote-secret --context="${CTX_CLUSTER1}" --name=foo-eks-cluster \
  --server=https://5275E4E10BBA439AFD2C339684B79682.sk1.eu-west-2.eks.amazonaws.com \
  | kubectl apply -f - --context="${CTX_CLUSTER2}"

istioctl x create-remote-secret --context="${CTX_CLUSTER2}" --name=bar-eks-cluster \
  --server=https://08D255F39154311DBF12C9E2A0488B0E.gr7.eu-west-2.eks.amazonaws.com \
  | kubectl apply -f - --context="${CTX_CLUSTER1}"
