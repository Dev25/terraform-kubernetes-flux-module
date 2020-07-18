locals {
  flux_additional_arguments = [
    for key in keys(var.flux_args_extra) :
    "--${key}=${var.flux_args_extra[key]}"
  ]
}

resource "kubernetes_namespace" "flux" {
  metadata {
    name = var.flux_namespace
  }

  depends_on = [kubernetes_namespace.flux]

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_service_account" "flux" {
  metadata {
    name      = "flux"
    namespace = var.flux_namespace

    labels = {
      name = "flux"
    }
  }

  automount_service_account_token = true

  depends_on = [kubernetes_namespace.flux]

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_cluster_role" "flux" {
  metadata {
    name = "flux"

    labels = {
      name = "flux"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }

  depends_on = [kubernetes_namespace.flux]

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_cluster_role_binding" "flux" {
  metadata {
    name = "flux"

    labels = {
      name = "flux"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "flux"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "flux"
    namespace = var.flux_namespace
    api_group = ""
  }

  depends_on = [
    kubernetes_namespace.flux,
    kubernetes_cluster_role.flux,
    kubernetes_service_account.flux,
  ]

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "flux-git-deploy" {
  metadata {
    name      = "flux-git-deploy"
    namespace = var.flux_namespace
  }

  type = "Opaque"
  data = {
    identity = tls_private_key.flux.private_key_pem
  }

  depends_on = [kubernetes_namespace.flux]

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_deployment" "flux" {
  metadata {
    name      = "flux"
    namespace = var.flux_namespace
  }

  spec {
    selector {
      match_labels = {
        name = "flux"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app  = "flux"
          name = "flux"
        }
      }

      spec {
        service_account_name            = "flux"
        automount_service_account_token = true

        # See the following GH issue for why we have to do this manually
        # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38
        volume {
          name = kubernetes_service_account.flux.default_secret_name

          secret {
            secret_name = kubernetes_service_account.flux.default_secret_name
          }
        }

        volume {
          name = "git-key"

          secret {
            secret_name  = "flux-git-deploy"
            default_mode = "0400"
          }
        }

        volume {
          name = "git-keygen"

          empty_dir {
            medium = "Memory"
          }
        }

        container {
          name  = "flux"
          image = "docker.io/fluxcd/flux:${var.flux_tag}"

          volume_mount {
            name       = "git-key"
            mount_path = "/etc/fluxd/ssh"
            read_only  = true
          }

          volume_mount {
            name       = "git-keygen"
            mount_path = "/var/fluxd/keygen"
          }

          args = concat([
            "--ssh-keygen-dir=/var/fluxd/keygen",
            "--git-url=${var.flux_git_clone_url}",
            "--git-branch=${var.flux_git_branch}",
            "--git-user=Flux Automation",
            "--git-ci-skip=true",
            "--git-path=${var.flux_git_paths}",
            "--registry-scanning=false",
          ], local.flux_additional_arguments)
        }
      }
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.flux,
    kubernetes_secret.flux-git-deploy,
  ]

  # We assume this in a 'one shot' deployment since
  # Flux will overwrite itself with the deployment spec with its own config
  lifecycle {
    ignore_changes = [
      metadata,
      spec
    ]
  }
}

