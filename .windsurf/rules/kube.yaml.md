---
trigger: glob
description:
globs: *.yaml,kubernetes/**/**/*.yaml
---
description: Kubernetes Manifest Troubleshooting and Creation Guidelines
globs:
  - '*.yaml'
  - '*.yml'
  - './kubernetes/**/**/*.yaml'
---

# Kubernetes Manifest Troubleshooting & Creation Guidelines

## Core Principles (Code Quality Inspired)
1. **Verify Information**: Cross-check all API versions and field specifications against the target Kubernetes version
2. **File-by-File Changes**: Modify one manifest at a time with complete context
3. **No Assumptions**: Never invent fields or values not explicitly documented in Kubernetes API references
4. **Preserve Structure**: Maintain existing indentation, comments, and organization in manifests

## Manifest Creation Standards

### Required Fields
```yaml
apiVersion: apps/v1  # Always specify complete API group/version
kind: Deployment     # Exact resource type
metadata:
  name: meaningful-name  # DNS-1123 subdomain compliant
  labels:                # Minimum recommended labels
    app.kubernetes.io/name: my-app
    app.kubernetes.io/instance: my-app-prod
spec:                   # Always include complete spec section
  ...

Troubleshooting Patterns
Common Issues & Fixes

1. CrashLoopBackOff
  # Before
containers:
- name: app
  image: my-app:latest

# After (with probes)
containers:
- name: app
  image: my-app:v1.2.3  # Pinned version
  livenessProbe:
    httpGet:
      path: /healthz
      port: 8080
    initialDelaySeconds: 5
    periodSeconds: 10
  readinessProbe:
```

2. ImagePullBackOff
```
# Before
image: private-registry.example.com/app:latest

# After (with imagePullSecrets)
spec:
  template:
    spec:
      imagePullSecrets:
      - name: regcred
      containers:
      - image: private-registry.example.com/app@sha256:abc123  # Digest
```

3. Pod Scheduling Failures
```
Validation Workflow
Dry-run:

bash
kubectl apply -f manifest.yaml --dry-run=server --validate=true
Diff (for updates):

bash
kubectl diff -f manifest.yaml
Schema Check:

bash
kubeval --strict manifest.yaml
Best Practices
Immutable Tags: Never use :latest, prefer @sha256: digests

Declarative Updates: Always provide complete manifest state (no partial updates)

ArgoCD Compatibility: Ensure all fields are declarative and GitOps-friendly

RBAC Minimum Privilege: Include minimal required permissions in Role definitions

Example Template (Deployment)
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: nginx
    app.kubernetes.io/version: "1.25.3"
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: nginx
        app.kubernetes.io/version: "1.25.3"
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: nginx
        image: nginx:1.25.3@sha256:abc123
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        livenessProbe:
          httpGet:
            path: /
            port: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
```

Error Reference
Error	Diagnostic Steps	Fix Pattern
ImagePullBackOff	1. Check image exists
2. Verify pull secret
3. Check registry access	Use image digest, add imagePullSecrets
CrashLoopBackOff	1. Check container logs
2. Verify probes
3. Check resources	Add proper probes, adjust resources
CreateContainerConfigError	1. Check secret/configmap exists
2. Verify volume mounts	Ensure dependencies exist in namespace

