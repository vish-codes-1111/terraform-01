# terraform-01

Basic Terraform project that provisions EC2 instances on AWS behind a security group, using S3 + DynamoDB as a remote backend for state management.

## What this creates

- **Key Pair** — imports a local SSH public key (`terra-key`) into AWS for EC2 access.
- **Default VPC** — uses the account's existing default VPC (no custom VPC created).
- **Security Group** (`automate-sec-group`) — allows inbound SSH (22) and HTTP (80) from anywhere, and all outbound traffic.
- **EC2 Instances** — provisions multiple instances via `for_each` over a map of instance types (currently `t2.micro`, `t2.medium`, `t2.large`), each:
  - Uses the key pair and security group above
  - Boots from an AMI defined in `var.aws_instance_ami`
  - Attaches a `gp3` root volume sized by `var.aws_instance_storage_size`
  - Runs `install_nginx.sh` as user data on first launch

## Remote backend

State is stored remotely instead of locally:

| Resource | Purpose |
|---|---|
| S3 bucket `remote-state-bucket-vish-1111` | Stores `terraform.tfstate` |
| DynamoDB table `state-table` | State locking (prevents concurrent applies) |

Region: `us-east-1`.

> **Note:** the S3 bucket and DynamoDB table must already exist before running `terraform init` — Terraform's backend config doesn't create them for you.

## Project structure

```
.
├── ec2.tf              # key pair, security group, EC2 instances
├── terraform.tf        # provider + S3/DynamoDB remote backend config
├── variables.tf         # input variables (ami, storage size, etc.)
├── output.tf            # output values
├── install_nginx.sh    # user-data script — installs & starts nginx on boot
├── terra-key / terra-key.pub  # local SSH key pair used for EC2 access
```

## Prerequisites

- Terraform >= (compatible with AWS provider `~> 6.0`)
- AWS CLI configured with credentials that have permission to manage EC2, VPC, S3, and DynamoDB
- An existing S3 bucket and DynamoDB table matching the backend config in `terraform.tf`

## Usage

```bash
# Initialize backend and providers
terraform init

# Preview changes
terraform plan

# Apply
terraform apply

# Destroy when done
terraform destroy
```

Re-run `terraform init` any time `terraform.tf` changes (e.g. backend or provider updates).

## SSH access

Once instances are up, connect using the private half of `terra-key`:

```bash
ssh -i terra-key ec2-user@<instance-public-ip>
```

(Adjust the username depending on the AMI's default OS.)

