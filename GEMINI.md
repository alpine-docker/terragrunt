# Gemini CLI Project Context

## Overview
This repository manages a Docker image for Terragrunt, including Terraform, OpenTofu, and Boilerplate.

## Development Workflow

### Branching Strategy
- **NEVER** make changes directly to the `main` branch.
- **ALWAYS** create a new feature or fix branch for any changes.
- Branch naming convention: `feature/...`, `fix/...`, or `chore/...`.

### Commit Conventions
- **ALWAYS** use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for all commit messages.
- Examples:
  - `feat: add support for new architecture`
  - `fix: correct terragrunt version detection`
  - `chore: update github action workflows`

### Testing
- Tests are located in the `test/` directory.
- Use `test/test.sh` to verify changes.
- The CI workflow in `.github/workflows/ci.yml` runs tests locally before building the Docker image.

### Building
- The `build.sh` script handles multi-architecture Docker builds using `docker buildx`.
- The CI workflow automates builds on pushes to `main` after tests pass.
