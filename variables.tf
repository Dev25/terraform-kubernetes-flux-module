variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
}

variable "cluster_type" {
  type        = string
  description = "Kubernetes cluster type e.g. aws, gke, on-prem"
}

## Github
variable "github_flux_repo" {
  type        = string
  description = "Github gitops repo"
}

# Flux
variable "flux_namespace" {
  description = "Namespace to deploy flux"
  type        = string
  default     = "flux"
}

variable "flux_tag" {
  description = "Tag of flux Docker image to pull"
  type        = string
  default     = "1.20.2"
}

variable "flux_args_extra" {
  description = "Additional arguments to provide to the flux daemon"
  type        = map(string)
  default     = {}
}

variable "flux_git_paths" {
  type        = string
  description = "Paths from git repo to apply via Flux"
  default     = "/"
}

variable "flux_git_branch" {
  type        = string
  description = "Git branch to use in flux"
  default     = "master"
}

variable "flux_git_clone_url" {
  type        = string
  description = "Git clone url to use in flux"
}
