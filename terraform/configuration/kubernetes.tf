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