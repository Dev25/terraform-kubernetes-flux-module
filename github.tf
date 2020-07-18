resource "tls_private_key" "flux" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "github_repository_deploy_key" "flux" {
  title      = "Flux deploy key (${var.cluster_type}/${var.cluster_name})"
  repository = var.github_flux_repo
  read_only  = false
  key        = tls_private_key.flux.public_key_openssh
}
