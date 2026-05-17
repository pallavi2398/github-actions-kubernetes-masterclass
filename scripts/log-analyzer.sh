#!/bin/bash

NAMESPACE="skillpulse"

echo "Showing recent Kubernetes events..."
kubectl get events -n $NAMESPACE --sort-by=.lastTimestamp

echo
echo "Showing backend logs..."
kubectl logs -n $NAMESPACE -l app=backend --tail=50

echo
echo "Showing frontend logs..."
kubectl logs -n $NAMESPACE -l app=frontend --tail=50

echo
echo "Showing MySQL logs..."
kubectl logs -n $NAMESPACE -l app=mysql --tail=50

echo
echo "Searching for common error words..."
kubectl logs -n $NAMESPACE -l app=backend --tail=100 | grep -iE "error|failed|panic|crash|refused|timeout|unhealthy|denied"
kubectl logs -n $NAMESPACE -l app=frontend --tail=100 | grep -iE "error|failed|panic|crash|refused|timeout|unhealthy|denied"
kubectl logs -n $NAMESPACE -l app=mysql --tail=100 | grep -iE "error|failed|panic|crash|refused|timeout|unhealthy|denied"

echo
echo "Log analysis completed."
