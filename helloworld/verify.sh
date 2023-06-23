#/bin/bash

export CTX_CLUSTER1=eks-foo-cluster
export CTX_CLUSTER2=eks-bar-cluster

echo ">>> curl helloworld end point to see if they are up. It should respond from both clusters"
sleep 2

kubectl exec --context="${CTX_CLUSTER1}" -n sleep -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sleep -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- sh -c "end_time=$((SECONDS+10)); while [ $SECONDS -lt $end_time ]; do curl -sS helloworld.helloworld:5000/hello; done"

sleep 2
echo ">> create a gateway and virtual service for helloworld"

kubectl apply --context="${CTX_CLUSTER1}" \
    -f helloworld-gateway.yaml -n helloworld

sleep 4

echo ">>access the gateway_url. It should respond forom both clusters"

while true; do curl -s "http://$GATEWAY_URL/hello"; done