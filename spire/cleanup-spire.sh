#!/bin/bash


export CTX_CLUSTER1=foo-eks-cluster
export CTX_CLUSTER2=bar-eks-cluster

kubectl delete -f ./foo-spire.yaml --context="${CTX_CLUSTER1}"

kubectl delete -f ./bar-spire.yaml --context="${CTX_CLUSTER2}" 
