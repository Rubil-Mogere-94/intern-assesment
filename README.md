# SRE Intern Assessment – Monitoring, Automation & Troubleshooting

This repository contains my solution for the SRE / DevOps Intern take‑home assessment.  
All three tests are organised in separate folders as requested.

## What’s inside

- **test-1-monitoring/** – Logging and metrics stack (Prometheus + Loki + Grafana) deployed on a local Kubernetes cluster (kind).
- **test-2-automation/** – Infrastructure as Code (Terraform for Azure) + configuration management (Ansible) to provision two Ubuntu VMs with nginx.
- **test-3-troubleshooting/** – Written answer for the AKS unreachable application scenario.

## How to use

Each folder contains its own `README.md` with detailed instructions.  
No secrets are committed – all sensitive values are handled via environment variables or placeholders.

## Assumptions

- The monitoring stack is deployed on a local kind cluster to demonstrate functionality. In production, it would run on AKS.
- For automation, I used Azure because it’s the preferred cloud. If the reviewer doesn’t have Azure access, the Terraform code can be adapted to another provider.
