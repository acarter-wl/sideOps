# Project Brief: Home SideOps Platform

## Overview

A self-hosted Kubernetes infrastructure platform built using Talos Linux, providing a GitOps-driven media server, monitoring, and cloud services for home use. The platform leverages Argo CD for deployment orchestration and provides integrated monitoring through Grafana and VictoriaMetrics.

## Core Requirements

1. Highly available Kubernetes cluster with 3+ control plane nodes
2. Secure remote access with Cloudflare Tunnel and proper TLS termination
3. Comprehensive media server environment with automated content management
4. Centralized monitoring and observability stack
5. Robust storage solution using Rook-Ceph for persistent data

## Goals

1. Implement fully automated and declarative infrastructure management through GitOps workflows
2. Maintain security best practices including secret management with SOPS and least privilege principles
3. Provide reliable media streaming and content management services
4. Enable robust monitoring and alerting for system health
5. Support easy backup/restore operations and disaster recovery via Velero

## Infrastructure Details

-   **Cluster Type**: Bare-metal Kubernetes deployed with Talos Linux
-   **Node Configuration**: 3 control plane nodes + 3 worker nodes
-   **Networking**: Cilium CNI with ingress via NGINX and Cloudflare tunnels
-   **Storage**: Rook-Ceph distributed storage system
-   **GitOps Engine**: Argo CD for declarative application deployment
-   **Secret Management**: SOPS for encrypted secrets in Git

## Key Applications

-   **Media Stack**: Jellyfin, Sonarr, Radarr, Prowlarr, SABnzbd, qBittorrent
-   **Monitoring**: Kube Prometheus Stack, VictoriaMetrics, Grafana, Tempo
-   **Networking**: Cloudflared, External-DNS, Ingress-NGINX

## Continuous Improvement

-   Automated dependency updates via Renovate
-   Integration with GitHub Actions for workflow automation
-   Comprehensive documentation and dashboards
