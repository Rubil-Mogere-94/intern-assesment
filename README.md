# SRE / DevOps Intern Assessment

This repository contains my solutions for the SRE roles Intern Technical.

## Repository Structure

- `test-1-monitoring/`: Monitoring stack setup using Prometheus, Loki, Promtail, and Grafana on a local Kubernetes cluster.
- `test-2-automation/`: Infrastructure as Code using Vagrant and Ansible to provision and configure a local gateway and application server environment.
- `test-3-troubleshooting/`: Written answers to the Kubernetes connectivity troubleshooting scenario.

## Highlights

- **Local-First Implementation**: All tests are fully executable on a local machine using standard open-source tools (Kubernetes/Kind, Vagrant, Ansible).
- **IaC Principles**: Used declarative configuration for both infrastructure (Vagrant) and application setup (Ansible/Helm).
- **Security-Minded**: Simulated real-world cloud security groups using local firewall rules (iptables).

## How to Navigate

Each directory contains its own `README.md` with detailed instructions on how to run the setup and the rationale behind tool selections.
