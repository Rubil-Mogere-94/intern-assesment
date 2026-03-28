# Test 2 – Infrastructure Automation

## Tool Choice & Justification

For this assessment, I chose **Vagrant** as the primary Infrastructure as Code (IaC) tool and **Ansible** for configuration management.

- **Vagrant (IaC)**: Used to provision two Ubuntu 22.04 virtual machines locally (VirtualBox provider). 
  - **Reasoning**: While Terraform is standard for cloud-native resources, I opted for Vagrant to ensure the entire solution remains **fully executable and testable in a local environment** without requiring an Azure subscription (which often necessitates a credit card for setup). This demonstrates the core principles of IaC—reproducibility and automation—using local-first tooling.
- **Ansible (Configuration)**: Handles all post-provisioning tasks on the gateway VM, including network security hardening and service installation.

## Secret Handling

In this local-first environment (Vagrant), SSH keys are automatically generated and managed by the Vagrant provider, so no manual secret injection was required. However, for production/cloud-native scenarios, my approach to secrets is:
1.  **Ansible Vault**: To encrypt sensitive variables (like database passwords or API tokens) within the repository.
2.  **Terraform Sensitive Variables**: Marking variables as `sensitive = true` to prevent them from appearing in plan outputs.
3.  **Managed Secrets**: In a real Azure environment, I would leverage **Azure Key Vault** to store and retrieve credentials dynamically at runtime.

## Infrastructure

The `Vagrantfile` creates:

- **vm-public (gateway)**: 
  - IP: `192.168.33.10` (Private Network)
  - Port Forwarding: Host `8080` -> Guest `80` (nginx)
- **vm-private (appserver)**: 
  - IP: `192.168.33.11` (Private Network)
  - Isolated from direct host access.

## Network Security (Simulated)

I replicated Azure NSG requirements using `iptables` on the gateway VM:
- **SSH**: Allowed only from the host gateway IP.
- **HTTP/HTTPS**: Allowed from any source.
- **Internal Traffic**: All traffic between the two VMs is allowed.
- **Default Policy**: All other inbound traffic is dropped.

## Configuration with Ansible

The playbook performs:
1. Nginx installation and activation.
2. Hostname configuration (`gateway`).
3. Creation of a `deploy` user with sudo privileges.
4. Application of persistent firewall rules.

## Running the Code

1. Ensure **Vagrant**, **VirtualBox**, and **Ansible** are installed.
2. Run:
   ```bash
   vagrant up
   ```
3. Verify nginx:
   ```bash
   curl http://localhost:8080
   ```
4. Access the gateway:
   ```bash
   vagrant ssh public
   ```
