# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- `task init` - Initialize configuration files from samples
- `task configure` - Render and validate all configuration templates
- `task reconcile` - Force Argo to sync repository changes
- `task bootstrap:talos` - Deploy Talos to cluster nodes
- `task bootstrap:apps` - Install core Kubernetes applications
- `task talos:reset` - Reset cluster nodes to maintenance mode
- `task template:validate-kubernetes-config` - Validate Kubernetes manifests
- `task template:validate-talos-config` - Validate Talos configuration
- `task talos:apply-node IP=<ip> MODE=<mode>` - Apply config to node

## Style Guidelines
- Use YAML for configuration files with 2-space indentation
- Follow [Helm best practices](https://helm.sh/docs/chart_best_practices/) for Helm charts
- Validate YAML with schemas via yaml-language-server 
- Keep secrets encrypted using SOPS
- Follow Kubernetes naming conventions for resources
- Use kustomize for managing Kubernetes manifests
- Use Jinja2 templating for configuration files with custom delimiters
- Adhere to ArgoCD GitOps workflow for all cluster changes