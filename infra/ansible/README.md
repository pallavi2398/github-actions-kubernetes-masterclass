# Ansible Server Setup

This folder configures the EC2 deployment server created by Terraform.

Ansible installs:

- Git
- Docker
- Docker Compose plugin

## Before running

Copy the example inventory:

```bash
cp inventory.example.ini inventory.ini
```

Edit `inventory.ini` and replace `<EC2_PUBLIC_IP>` with the public IP from Terraform output.

## Run Ansible

From this folder:

```bash
ansible-playbook -i inventory.ini setup-server.yml
```

After this, the EC2 server is ready for the existing GitHub Actions CD workflow.

Use these GitHub secrets:

- `EC2_HOST` - EC2 public IP from Terraform
- `EC2_USER` - `ubuntu`
- `EC2_SSH_KEY` - contents of `infra/terraform/terra-automate-key`
