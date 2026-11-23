# Terraform AWS VPC and EC2 Deployment

Infrastructure as Code (IaC) for provisioning an AWS network foundation and a compute instance with Terraform. The configuration builds a VPC on the community-maintained `terraform-aws-modules/vpc` module and deploys an Amazon Linux 2023 EC2 instance into its public subnet. Provider versions are pinned, and AMI selection is dynamic.

## Architecture

| Component | Configuration |
|---|---|
| Region | `us-east-1` |
| VPC | `10.0.0.0/16` (`my-vpc`), provisioned with [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) |
| Public subnet | `10.0.101.0/24` in `us-east-1a` |
| Virtual private gateway | Attached to the VPC for site-to-site VPN connectivity |
| NAT gateway | Disabled to avoid hourly charges, since no private subnets are defined |
| EC2 instance | Amazon Linux 2023 (x86_64), instance type set through a variable |

## Design decisions

- **Reusable VPC module.** The VPC is built with the widely adopted community module rather than hand-written resources. This keeps the code short and follows AWS networking defaults.
- **Dynamic AMI lookup.** An `aws_ami` data source selects the most recent Amazon-owned Amazon Linux 2023 image at plan time, so no AMI IDs are hardcoded.
- **Pinned provider version.** The AWS provider is pinned to `6.73.0`, and `.terraform.lock.hcl` is committed, so every run uses the same provider build.
- **Parameterized sizing.** The instance type is an input variable, so it can change per environment without editing the code.
- **Credential isolation.** Authentication comes from a named AWS CLI profile. No credentials are stored in the repository.
- **Consistent tagging.** VPC resources are tagged with `Terraform` and `Environment` to support ownership tracking and cost allocation.

## Repository structure

| File | Purpose |
|---|---|
| `providers.tf` | Terraform and AWS provider requirements, region, and authentication profile |
| `main.tf` | VPC module, AMI data source, and EC2 instance |
| `variables.tf` | Input variable declarations |
| `.terraform.lock.hcl` | Provider dependency lock file |
| `.gitignore` | Excludes state, variable values, and local provider caches |

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `instance_type` | `string` | `t2.micro` | EC2 instance type |

Override values in a local `terraform.tfvars` file, which is excluded from version control:

```hcl
instance_type = "t3.micro"
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [AWS CLI v2](https://aws.amazon.com/cli/) with a configured `default` profile
- An IAM identity with permissions to manage VPC and EC2 resources

## Deployment

```bash
terraform init       # install the provider and module dependencies
terraform fmt -check # check formatting
terraform validate   # check the configuration statically
terraform plan       # review the execution plan
terraform apply      # provision the infrastructure
```

Tear down all resources when they are no longer needed:

```bash
terraform destroy
```

## Security

- Terraform state (`*.tfstate`) and variable files (`*.tfvars`) are excluded from version control, because they can contain account identifiers and sensitive values.
- AWS credentials are read from the local CLI profile and never committed.

## Cost considerations

The virtual private gateway and the EC2 instance are billed while they exist. NAT gateways are disabled on purpose. Run `terraform destroy` after testing to avoid ongoing charges.

## Known limitations and next steps

- **Local state.** State is stored on the local machine. A production setup would use a remote S3 backend with state locking.
- **Single availability zone.** The network spans one AZ. A production setup would use multiple AZs for high availability.
- **Default security group.** The instance uses the VPC default security group. Explicit, least-privilege security groups would be the next step.
- **No outputs.** Adding outputs, such as the instance ID and VPC ID, would let other configurations use these values.
