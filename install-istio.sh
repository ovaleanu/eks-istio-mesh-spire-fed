#/bin/bash

set -e


export CTX_CLUSTER1=eks-foo-cluster
export CTX_CLUSTER2=eks-bar-cluster

kubectl config use-context $CTX_CLUSTER1
(cd istio ; ./deploy-istio-foo.sh)

kubectl config use-context $CTX_CLUSTER2
(cd istio ; ./deploy-istio-bar.sh)


# Change with your cluster names and API Endpoints
istioctl x create-remote-secret --context="${CTX_CLUSTER1}" --name=eks-foo-cluster --server=https://903782AF976B9C40A13B6B42A05C2941.gr7.eu-west-2.eks.amazonaws.com | kubectl apply -f - --context="${CTX_CLUSTER2}"

istioctl x create-remote-secret --context="${CTX_CLUSTER2}" --name=eks-bar-cluster --server=https://ED16C30970D50FFD76357847E3E60D20.gr7.eu-west-2.eks.amazonaws.com | kubectl apply -f - --context="${CTX_CLUSTER1}"
