resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  data {
    mapRoles = <<EOF
    - rolearn: ${data.terraform_remote_state.stwr.worker_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
  }
}

resource "null_resource" "cluster_autoscaler" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${pathexpand("~/.kube/patoarvizu-config")} --context=stwr apply -f ${pathexpand("${path.module}/kubernetes/cluster-autoscaler.yaml")}"
  }
}