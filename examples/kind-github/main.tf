provider "github" {
  token = var.gh_token

  # 2.9.0 is required for personal repo support
  # until 3.0 is released. 2.9.1 revert necessary support
  version = "= 2.9.0"
}

provider "kubernetes" {
  config_context_cluster = "kind-test-cluster"
}

module "flux" {
  source = "../../"

  cluster_name = "test-cluster"
  cluster_type = "kind"

  github_flux_repo = "k8s-gitops-test"

  flux_namespace     = "flux"
  flux_tag           = "1.20.0"
  flux_args_extra    = {}
  flux_git_paths     = "base,clusters/kind"
  flux_git_branch    = "master"
  flux_git_clone_url = "git@github.com:Dev25/k8s-gitops-demo"
}

# Create ZFS compatible kind cluster
provider "kind" {}
resource "kind_cluster" "zfs" {
  name        = "test-cluster"
  node_image  = "kindest/node:v1.18.6"
  kind_config = <<KIONF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
- role: worker

containerdConfigPatches:
- |-
 [plugins."io.containerd.grpc.v1.cri".containerd]
 snapshotter = "native"

KIONF
}
