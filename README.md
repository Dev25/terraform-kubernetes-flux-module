Terraform Kubernetes Flux Boostrap Module
---

A module that allows you to bootstrap a [Flux](https://fluxcd.io/) GitOps cluster allowing you to fully automate the process of creating and deploying workloads using Terraform.

- Create a RSA key for flux and upload to Github
- Create a cluster wide `flux` deployment

## Providers

| Name | Version |
|------|---------|
| github | n/a |
| kubernetes | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Kubernetes cluster name | `string` | n/a | yes |
| cluster\_type | Kubernetes cluster type e.g. aws, gke, on-prem | `string` | n/a | yes |
| flux\_args\_extra | Additional arguments to provide to the flux daemon | `map(string)` | `{}` | no |
| flux\_git\_branch | Git branch to use in flux | `string` | `"master"` | no |
| flux\_git\_clone\_url | Git clone url to use in flux | `string` | n/a | yes |
| flux\_git\_paths | Paths from git repo to apply via Flux | `string` | `"/"` | no |
| flux\_namespace | Namespace to deploy flux | `string` | `"flux"` | no |
| flux\_tag | Tag of flux Docker image to pull | `string` | `"1.20.0"` | no |
| github\_flux\_repo | Github gitops repo | `string` | n/a | yes |

