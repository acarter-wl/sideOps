#!/bin/bash

# Script to verify Loki deployment
set -e

echo "1. Verifying MinIO is running..."
kubectl get pod -n storage -l app=minio

echo "2. Creating Loki buckets in MinIO if they don't exist..."
kubectl delete job -n storage minio-loki-buckets --ignore-not-found
kubectl apply -f /Users/acarter/code/home/sideOps/kubernetes/apps/storage/minio/loki-buckets.yaml

echo "3. Waiting for bucket creation job to complete..."
kubectl wait --for=condition=complete --timeout=60s job -n storage minio-loki-buckets || echo "Job did not complete in 60s, but may still be running"

echo "4. Updating and applying Loki configuration..."
kubectl apply -f /Users/acarter/code/home/sideOps/kubernetes/argo/apps/monitoring/loki.yaml

echo "5. Waiting for Loki pods to be ready..."
echo "Current Loki pods:"
kubectl get pods -n monitoring -l app.kubernetes.io/name=loki

echo "Now wait for Argo CD to sync the changes. Then verify logs with:"
echo "kubectl logs -n monitoring -l app.kubernetes.io/name=loki --tail=50"

echo "If you need to restart the Loki deployment manually, run:"
echo "kubectl rollout restart statefulset -n monitoring loki-singleBinary"