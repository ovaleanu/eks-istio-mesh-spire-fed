#/bin/bash

export CTX_CLUSTER1=eks-foo-cluster
export CTX_CLUSTER2=eks-bar-cluster

kubectl delete --context="${CTX_CLUSTER1}" deployment helloworld-v1 -n helloworld
kubectl delete --context="${CTX_CLUSTER2}" deployment helloworld-v2 -n helloworld

kubectl delete --context="${CTX_CLUSTER1}" deployment sleep -n sleep
kubectl delete --context="${CTX_CLUSTER2}" deployment sleep -n sleep

sleep 7

kubectl delete --context="${CTX_CLUSTER1}" namespace sleep
kubectl delete --context="${CTX_CLUSTER1}" namespace helloworld
kubectl delete --context="${CTX_CLUSTER2}" namespace sleep
kubectl delete --context="${CTX_CLUSTER2}" namespace helloworld
