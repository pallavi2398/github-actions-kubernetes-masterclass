#!/usr/bin/env bash

set -euo pipefail

# Local Kubernetes settings.
# You can change these values if your cluster, namespace, or image names are different.
CLUSTER="${CLUSTER:-skillpulse}"
NAMESPACE="${NAMESPACE:-skillpulse}"
BACKEND_IMAGE="${BACKEND_IMAGE:-pallavi2398/skillpulse-backend:k8s}"
FRONTEND_IMAGE="${FRONTEND_IMAGE:-pallavi2398/skillpulse-frontend:k8s}"

echo "Starting local Kubernetes deployment..."
echo "Cluster:  ${CLUSTER}"
echo "Namespace: ${NAMESPACE}"
echo

echo "Checking required tools..."
command -v docker >/dev/null 2>&1 || { echo "docker is required but not installed."; exit 1; }
command -v kind >/dev/null 2>&1 || { echo "kind is required but not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed."; exit 1; }

echo "Building Docker images..."
docker build -t "${BACKEND_IMAGE}" ./backend
docker build -t "${FRONTEND_IMAGE}" ./frontend

echo "Checking kind cluster..."
if kind get clusters | grep -qx "${CLUSTER}"; then
  echo "Cluster '${CLUSTER}' already exists."
else
  echo "Cluster '${CLUSTER}' does not exist. Creating it now..."
  kind create cluster --config k8s/kind-config.yaml --name "${CLUSTER}"
fi

echo "Switching kubectl context..."
kubectl config use-context "kind-${CLUSTER}"

echo "Loading images into kind..."
kind load docker-image "${BACKEND_IMAGE}" --name "${CLUSTER}"
kind load docker-image "${FRONTEND_IMAGE}" --name "${CLUSTER}"

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/00-namespace.yaml \
  -f k8s/10-mysql.yaml \
  -f k8s/20-backend.yaml \
  -f k8s/30-frontend.yaml

echo "Restarting application deployments..."
kubectl rollout restart deployment/backend deployment/frontend -n "${NAMESPACE}"

echo "Waiting for workloads to become ready..."
kubectl rollout status statefulset/mysql -n "${NAMESPACE}" --timeout=180s
kubectl rollout status deployment/backend -n "${NAMESPACE}" --timeout=120s
kubectl rollout status deployment/frontend -n "${NAMESPACE}" --timeout=90s

echo
echo "Deployment completed."
echo
kubectl get pods,svc -n "${NAMESPACE}"
echo
echo "Open the app at: http://localhost:8888"
