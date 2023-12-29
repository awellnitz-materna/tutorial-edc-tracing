## Setup

```bash
# firstly go to the folder containing the config files
cd <path/of/deployment>
kind create cluster -n tracing-tut --config kind.config.yaml
# the next step is specific to KinD and will be different for other Kubernetes runtimes!
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# wait until the ingress controller is ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
terraform init
terraform apply
# type "yes" and press enter when prompted to do so 
```