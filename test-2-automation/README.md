# Test 2 – Infrastructure Automation

## Tool Choice

I used **Vagrant** to provision two Ubuntu 22.04 virtual machines locally (VirtualBox provider), and **Ansible** to configure the public‑facing VM.

- **Vagrant** is used as Infrastructure as Code for VMs on a local machine, simulating the provisioning of cloud resources. It is lightweight and perfect for demonstrating IaC principles without requiring a cloud subscription.
- **Ansible** handles configuration management, ensuring the gateway VM is correctly set up with required services and security rules.

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
