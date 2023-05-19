#/bin/bash

set -e


export CTX_CLUSTER1=eks-foo-cluster
export CTX_CLUSTER2=eks-bar-cluster

kubectl config use-context $CTX_CLUSTER1
(cd istio ; ./deploy-istio-foo.sh)

kubectl config use-context $CTX_CLUSTER2
(cd istio ; ./deploy-istio-bar.sh)


# Change with your cluster names and API Endpoints
istioctl x create-remote-secret --context="${CTX_CLUSTER1}" --name=eks-foo-cluster --server=<your-eks-foo-cluster-api-endpoint> | kubectl apply -f - --context="${CTX_CLUSTER2}"

istioctl x create-remote-secret --context="${CTX_CLUSTER2}" --name=eks-bar-cluster --server=<your-eks-bar-cluster-api-endpoint> | kubectl apply -f - --context="${CTX_CLUSTER1}"
