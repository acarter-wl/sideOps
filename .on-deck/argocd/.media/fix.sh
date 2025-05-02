#!/bin/bash
# Script to fix immutable resources

echo "=== Fixing Immutable Resources ==="

# 1. Backup current data (optional but recommended)
echo "Creating backup of current configuration..."
kubectl get statefulset loki -n monitoring -o yaml > loki-backup.yaml
kubectl get service loki-headless -n monitoring -o yaml > loki-headless-backup.yaml
kubectl get pvc nfs-pvc-loki -n monitoring -o yaml > nfs-pvc-loki-backup.yaml

# 2. Delete resources (in specific order to avoid issues)
echo "Deleting StatefulSet..."
kubectl delete statefulset loki -n monitoring --cascade=orphan

echo "Deleting Services..."
kubectl delete service loki-headless -n monitoring
kubectl delete service loki -n monitoring
kubectl delete service loki-memberlist -n monitoring

# Note: We don't delete the PVC to preserve data
# If you need to recreate PVC, backup your data first!

# 3. Apply the new configuration
echo "Applying new configuration..."
kubectl apply -f loki-complete-config.yaml

# 4. Wait for resources to be ready
echo "Waiting for Loki to be ready..."
kubectl wait --for=condition=ready pod -l app=loki -n monitoring --timeout=300s

echo "=== Fix Complete ==="
