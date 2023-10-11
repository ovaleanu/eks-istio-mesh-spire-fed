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
  --server="${EKS_API_FOO}" \
  | kubectl apply -f - --context="${CTX_CLUSTER2}"

istioctl x create-remote-secret --context="${CTX_CLUSTER2}" --name=bar-eks-cluster \
  --server="{EKS_API_BAR}" \
  | kubectl apply -f - --context="${CTX_CLUSTER1}"
