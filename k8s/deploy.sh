#!/bin/bash

set -e

NAMESPACE="lm-app"

echo "Apply ConfigMap"
kubectl apply -f k8s/configmap.yaml
kubectl get configmap -n lm-app

echo "Deploying services..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/redis.yaml

echo "Waiting for deployment to complete..."
kubectl rollout status deployment/backend -n $NAMESPACE
kubectl rollout status deployment/auth -n $NAMESPACE
kubectl rollout status deployment/frontend -n $NAMESPACE

if [ $? -ne 0 ]; then
  echo "Deployment failed, rolling back..."
  kubectl rollout undo deployment/backend -n $NAMESPACE
  kubectl rollout undo deployment/auth -n $NAMESPACE
  kubectl rollout undo deployment/frontend -n $NAMESPACE
  exit 1
fi

echo "Apply Ingress Configuration"
kubectl apply -f k8s/ingress.yaml

echo "Deployment completed successfully!"