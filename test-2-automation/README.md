# Test 2 – Infrastructure Automation

## Tool Choice & Justification

### IaC tool: Terraform
- **Why Terraform?** It’s the primary tool we use for provisioning cloud resources. It supports Azure (our preferred cloud) natively, has a declarative syntax, and manages state.
- **Single tool?** I used Terraform alone for infrastructure provisioning because the required resources (VNet, subnets, VMs, NSG) are well‑supported and the state is easy to maintain.

### Configuration management: Ansible
- **Why Ansible?** After the VMs are provisioned, Ansible is used to configure the public VM (VM1) because it’s agentless, idempotent, and works perfectly for installing packages (nginx) and managing files.
- **Separation of concerns**: Terraform handles the “what” (infrastructure), Ansible handles the “how” (software configuration). This is a real‑world pattern that keeps each tool focused on its strength.

### Handling secrets
- Sensitive values (e.g., SSH keys, admin passwords) are stored in environment variables and referenced in Terraform as `TF_VAR_*` variables.
- In Ansible, I use `ansible-vault` for any secrets, but here I only used a basic SSH key (placeholder). In production, secrets would be injected via a secure vault (e.g., Azure Key Vault).

## Provisioned Infrastructure

- **Target cloud**: Azure
- **Resources**:
  - Resource Group: `sre-intern-rg`
  - Virtual Network: `vnet-sre` with two subnets: `subnet-public` and `subnet-private`
  - VM1 (public): `vm-public` – Ubuntu 22.04, public IP, NSG allows SSH (from my IP) and HTTP/HTTPS (anywhere)
  - VM2 (private): `vm-private` – Ubuntu 22.04, no public IP, NSG allows all traffic from VM1 only
- **Configuration** (via Ansible): Installs nginx on VM1 and starts the service.

## How to Run

### Prerequisites
- Azure CLI authenticated (`az login`)
- Terraform installed
- Ansible installed
- SSH key pair (default location `~/.ssh/id_rsa.pub`)

### 1. Set environment variables
```bash
export TF_VAR_subscription_id="your-subscription-id"
export TF_VAR_public_ssh_key="$(cat ~/.ssh/id_rsa.pub)"
```

### 2. Terraform
```bash
cd terraform
terraform init
terraform plan -out plan.tfplan   # review plan
terraform apply plan.tfplan
```

### 3. Ansible
After Terraform finishes, it outputs the public IP of VM1.
Update the `ansible/inventory.ini` file with that IP.
```bash
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml --private-key ~/.ssh/id_rsa
```

### 4. Verify
Open a browser to `http://<public-ip>` – you should see the default nginx welcome page.

## What I Would Add in Production

- **State backend**: Use Azure Storage for remote state with locking.
- **Modularisation**: Split Terraform code into modules (networking, compute, security).
- **CI/CD**: Run Terraform and Ansible in a pipeline (e.g., GitHub Actions) with approval gates.
- **Secrets management**: Integrate Azure Key Vault for SSH keys, admin passwords, etc.
- **Monitoring**: Add Azure Monitor agent on VMs to collect logs and metrics.
- **Backups**: Enable VM backups via Azure Backup.
