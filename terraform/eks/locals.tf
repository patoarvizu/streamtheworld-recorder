locals {
  cluster_name = "stwr"
  worker_user_data = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.stwr.endpoint}' --b64-cluster-ca '${aws_eks_cluster.stwr.certificate_authority.0.data}' '${local.cluster_name}'
USERDATA
}