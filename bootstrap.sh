#!/bin/bash

set -e

if ! kind get clusters | grep -q "^kind$"; then
    kind create cluster --config cluster.yml
fi

kubectl get nodes --show-labels

MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$MYSQL_NODE" ]; then
    kubectl taint nodes "$MYSQL_NODE" app=mysql:NoSchedule --overwrite
fi

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

helm dependency update ./helm-chart/todoapp/

helm upgrade --install todoapp-release ./helm-chart/todoapp/

sleep 15

kubectl get all,cm,secret,ing -A > output.log