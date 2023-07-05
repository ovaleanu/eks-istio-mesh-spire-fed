# README

Istio Service Mesh with Spire Federation between EKS clusters

## Steps

### Create clusters

#### Create `eks-foo-cluster`

```bash
cd eks-spire-foo
terraform init
terraform apply --auto-approve
```

#### Create `eks-bar-cluster`

```bash
cd eks-spire-bar
terraform init
terraform apply --auto-approve
```

**Note**: To be added later in TF: Create the VPC peering between the clusters. Add an inbopund rule in the security group of the clusters ndoes allowing TCP traffic from the other VPC.

The root CA is a self-signed certificate. Configure the root CA on each cluster

```bash
export CTX_CLUSTER1=eks-foo-cluster
export CTX_CLUSTER2=eks-bar-cluster

kubectl apply \
  -f ./cert-manager/self-signed-ca.yaml \
  -f ./cert-manager/istio-cert.yaml --context="${CTX_CLUSTER1}"

kubectl apply \
  -f ./cert-manager/self-signed-ca.yaml \
  -f ./cert-manager/istio-cert.yaml --context="${CTX_CLUSTER2}"
```

### Install Spire on the clusters with federation

**Note**: Change the name of the node in `spire-server-*.yaml` with the node labeled to run only spire server

```bash
./install-spire.sh
```

### Install Istio on the clusters

**Note**: Modify the API endpoints

`istioctl` needs to be in the PATH

```bash
./install-istio.sh
```

### Deploy `helloworld` on both clusters and check federation

```bash
./helloworld/deploy.sh
```

Curl `helloworld` endpoint to see if they are up. It should respond from both clusters

```bash
kubectl exec --context="${CTX_CLUSTER1}" -n sleep -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sleep -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- sh -c "while true; do curl -sS helloworld.helloworld:5000/hello; done"
```

Create a Gateway and a Virtual Service for `helloworld` on `eks-bar-cluster`

```bash
kubectl apply --context="${CTX_CLUSTER2}" \
    -f ./helloworld/helloworld-gateway.yaml -n helloworld

export INGRESS_NAME=istio-ingressgateway
export INGRESS_NS=istio-system

GATEWAY_URL=$(kubectl -n "$INGRESS_NS" --context="${CTX_CLUSTER2}" get service "$INGRESS_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Check the service by calling the Virtual Service from the foo cluster

```bash
kubectl exec --context="${CTX_CLUSTER1}" -n sleep -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sleep -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- sh -c "while true; do curl -s http://$GATEWAY_URL/hello; done"
```

### Deploy bookinfo app

```bash
./istio/deploy-bookinfo.sh
```

### View the certificate trust chain for the productpage pod

```bash
istioctl proxy-config secret deployment/productpage-v1 -o json | jq -r '.dynamicActiveSecrets[0].secret.tlsCertificate.certificateChain.inlineBytes' | base64 --decode > chain.pem
```

Open the `chain.pem` file with a text editor, and you will see two certificates. Save the two certificates in separate files and use the openssl command `openssl x509 -noout -text -in $FILE` to parse the certificate contents.

### Setting up Automatic Certificate Rotation

Modify the rotation period for istiod certificates from 60 days (1440 hours) to 30 days (720 hours), run the following command:

```bash
kubectl -f ./cert-manager/cert-rotation.yaml --context $CTX_CLUSTER1
```

Check `istiod` logs

```bash
kubectl logs -l app=istiod -n istio-system -f
```
