#/bin/bash

set -e

export CTX_CLUSTER1=eks-foo-cluster
export CTX_CLUSTER2=eks-bar-cluster

# Install Spire on foo cluster
kubectl config use-context ${CTX_CLUSTER1}

(cd spire ; ./deploy-spire-foo-domain.sh)

kubectl -n spire rollout status statefulset spire-server
kubectl -n spire rollout status daemonset spire-agent

foo_bundle=$(kubectl exec --stdin spire-server-0 -c spire-server -n spire  -- /opt/spire/bin/spire-server bundle show -format spiffe -socketPath /run/spire/sockets/server.sock)

# Install Spire on bar cluster
kubectl config use-context ${CTX_CLUSTER2}

(cd spire ; ./deploy-spire-bar-domain.sh)

kubectl -n spire rollout status statefulset spire-server
kubectl -n spire rollout status daemonset spire-agent

bar_bundle=$(kubectl exec --stdin spire-server-0 -c spire-server -n spire  -- /opt/spire/bin/spire-server bundle show -format spiffe -socketPath /run/spire/sockets/server.sock)

# Set foo.com bundle to bar.com SPIRE bundle endpoint
kubectl exec --stdin spire-server-0 -c spire-server -n spire -- /opt/spire/bin/spire-server  bundle set -format spiffe -id spiffe://foo.com -socketPath /run/spire/sockets/server.sock <<< "$foo_bundle"

### move to cluster 1
kubectl config use-context ${CTX_CLUSTER1}

# Set bar.com bundle to foo.com SPIRE bundle endpoint
kubectl exec --stdin spire-server-0 -c spire-server -n spire -- /opt/spire/bin/spire-server  bundle set -format spiffe -id spiffe://bar.com -socketPath /run/spire/sockets/server.sock <<< "$bar_bundle"