# Terraform EC2 Infrastructure

This folder creates one AWS EC2 instance that can be used as the deployment server for SkillPulse.

Terraform is responsible for infrastructure:

- EC2 instance
- security group
- SSH key pair
- public IP and DNS outputs

Ansible is used separately to install Docker, Docker Compose, and Git on the instance.

## Before running

Generate an SSH key pair in this folder:

```bash
ssh-keygen -t ed25519 -f terra-automate-key -C "skillpulse-ec2"
```

This creates:

- `terra-automate-key` - private key, do not commit this file.
- `terra-automate-key.pub` - public key used by Terraform.

Create your local variable file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars`, especially:

- `aws_region`
- `ec2_ami_id`
- `allowed_ssh_cidr`

For better SSH security, set `allowed_ssh_cidr` to your public IP with `/32`.

## Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

After apply, Terraform prints:

- `ec2_public_ip`
- `ec2_public_dns`
- `ssh_user`

Use the public IP in the Ansible inventory and in the GitHub Actions `EC2_HOST` secret.

## State note

This hackathon setup uses local Terraform state.

For production or team usage, use a remote backend such as S3 with DynamoDB locking.
