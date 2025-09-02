# NVIDIA Base Command Manager 10 Install on AWS EC2 (Ansible Add-On Method)

- AMI name: ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250821
- t3.xlarge
- 200GB gp3 ebs volume

Provision an AWS VPC and a head-node EC2 instance, then install **NVIDIA Base Command Manager 10 (BCM 10)** using the **Ansible add-on method**.

> **Why this repo?**  
> - Creates a clean, dedicated **VPC** and **EC2 head node** you can reach over SSH.  
> - Opens required ports (SSH + Base View).  
> - Primes the instance for **Ansible** and shows where to run the BCM Ansible add-on installer.

---

## References

- **BCM 10 Installation Manual** – Add-on Ansible method, licensing, supported OS, Base View on `:8081`. :contentReference[oaicite:1]{index=1}
- **Ansible install guide** (pip/pipx, apt, etc.): <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>

---

## Architecture

- **VPC** with 1 public and 1 private subnet (usable for future expansion).
- **Internet Gateway** + **NAT** (so private subnets can egress if extended later).
- **Security groups** exposing:
  - **22/tcp** (SSH) from your IP
  - **8081/tcp** (BCM Base View UI)
  - **80/443** (optional, for future)
- **EC2 head node** (Rocky Linux or Ubuntu LTS recommended; see _OS Support_ below).

Once the instance is up, install BCM 10 via the **Ansible add-on** approach on the head node.

---

## OS Support (Head Node)

BCM 10 supports RHEL family (incl. Rocky Linux 8/9), SLES 15, and Ubuntu 20.04/22.04/24.04 (plus DGX OS 6).  
Choose a **supported** AMI. We parameterize the AMI in Terraform to keep this explicit. :contentReference[oaicite:2]{index=2}

---

## Prerequisites

- **Terraform** ≥ 1.5
- **Ansible** on your workstation (see Ansible docs linked above)
- **AWS credentials** (env vars or profile)
- A **key pair** available in your AWS region
- A **supported AMI ID** for your chosen distro (Rocky 9 or Ubuntu 22.04 are common picks)

---

## Quick Start

### 1) Terraform Deploy

```bash
cd terraform

# Copy variables template (if you keep a *.tfvars):
# cp example.tfvars my.tfvars

terraform init

terraform apply \
  -var="project_name=bcm10" \
  -var="region=us-east-1" \
  -var="key_name=<your_aws_keypair_name>" \
  -var="admin_cidr=$(curl -s https://checkip.amazonaws.com)/32" \
  -var="head_instance_type=c6i.large" \
  -var="head_ami_id=<supported_ami_id>"
