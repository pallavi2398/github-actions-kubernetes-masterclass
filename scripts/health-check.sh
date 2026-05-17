#!/bin/bash

NAMESPACE="skillpulse"
APP_URL="http://localhost:8888"

echo "Checking pods..."
kubectl get pods -n $NAMESPACE

echo
echo "Checking services..."
kubectl get svc -n $NAMESPACE

echo
echo "Checking endpoints..."
kubectl get endpoints -n $NAMESPACE

echo
echo "Checking frontend..."
curl -I $APP_URL

echo
echo "Checking backend health..."
curl $APP_URL/health

echo
echo "Checking backend readiness..."
curl $APP_URL/ready

echo
echo "Health check completed."
