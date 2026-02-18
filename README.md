# Terragrunt with Terraform & OpenTofu

Docker image for [Terragrunt](https://github.com/gruntwork-io/terragrunt) with support for both [Terraform](https://terraform.io) and [OpenTofu](https://opentofu.org/). Ideal for CI/CD pipelines.

[![DockerHub Badge](http://dockeri.co/image/cbcvaughan/terragrunt)](https://hub.docker.com/r/cbcvaughan/terragrunt/)

> [!WARNING]
> **Terragrunt defaults to OpenTofu (`tofu`) in this container.**
> To use Terraform, explicitly set `terraform_binary = "terraform"` in your `terragrunt.hcl`.

## Features

- **Multi-Arch:** linux/amd64, linux/arm64
- **Tools:** Terragrunt, Terraform, OpenTofu, [boilerplate](https://github.com/gruntwork-io/boilerplate), [terraform-docs](https://github.com/terraform-docs/terraform-docs)
- **Automatic Builds:** Triggered weekly or when new Terraform/OpenTofu versions are released.

## Supported Tags

| Tag | Description |
| :--- | :--- |
| `latest` | Latest Terragrunt + Latest Terraform |
| `1.8.4` / `tf1.8.4` | Latest Terragrunt + Terraform v1.8.4 |
| `otf1.7.1` | Latest Terragrunt + OpenTofu v1.7.1 |

*Note: Avoid using `latest` in production.*

## Usage

Mount your project directory to `/apps` and your credentials to the appropriate locations.

```bash
docker run -ti --rm \
  -v $HOME/.aws:/root/.aws \
  -v $HOME/.ssh:/root/.ssh \
  -v $(pwd):/apps \
  cbcvaughan/terragrunt:latest bash
```

### Common Commands

```bash
# Terraform
terraform init && terraform plan && terraform apply

# OpenTofu
tofu init && tofu plan && tofu apply

# Terragrunt
terragrunt run-all plan && terragrunt run-all apply
```

## Resources

- **Repo:** [github.com/cbcvaughan/terragrunt](https://github.com/cbcvaughan/terragrunt)
- **Docker Hub:** [hub.docker.com/r/cbcvaughan/terragrunt](https://hub.docker.com/r/cbcvaughan/terragrunt/)
- **Build Logs:** [GitHub Actions](https://github.com/cbcvaughan/terragrunt/actions)
