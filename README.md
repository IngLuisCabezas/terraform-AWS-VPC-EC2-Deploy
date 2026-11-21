# My First Terraform Project

A beginner Terraform project, built while following an online course. It deploys a small network and one virtual server on AWS.

## What it creates

| Resource | Description |
|---|---|
| VPC | A private network (`10.0.0.0/16`) named `my-vpc`, built with the [terraform-aws-modules/vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) module |
| Public subnet | `10.0.101.0/24` in `us-east-1a` |
| VPN gateway | Attached to the VPC (`enable_vpn_gateway = true`) |
| EC2 instance | A server named `HelloWorld`, running the latest Amazon Linux 2023 image |

Everything is deployed in the `us-east-1` region.

## Files

| File | Purpose |
|---|---|
| `providers.tf` | Sets the AWS provider (version 6.73.0), region, and AWS CLI profile |
| `main.tf` | Defines the VPC, the AMI lookup, and the EC2 instance |
| `variables.tf` | Declares the `instance_type` variable (default `t2.micro`) |
| `terraform.tfvars` | Sets variable values. Not committed to Git |
| `.terraform.lock.hcl` | Locks the exact provider versions |

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- An AWS account
- [AWS CLI](https://aws.amazon.com/cli/) with a `default` profile, created with `aws configure`

## Usage

```bash
terraform init      # download the provider and the VPC module
terraform plan      # preview the changes
terraform apply     # create the resources (type "yes" to confirm)
terraform destroy   # delete everything when finished
```

To choose a different server size, create a `terraform.tfvars` file:

```hcl
instance_type = "t3.micro"
```

## Cost warning

The VPN gateway and the EC2 instance are billed while they exist. Run `terraform destroy` when you finish working.

## Security

These files are excluded from Git by `.gitignore`, because they can contain account details or secrets:

- `.terraform/`
- `*.tfstate` and `*.tfstate.*`
- `*.tfvars`

Never put AWS access keys in `.tf` files. Terraform reads them from the AWS CLI profile.
