locals {
  cluster_name = "stwr"
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.stwr.endpoint}
    certificate-authority-data: ${aws_eks_cluster.stwr.certificate_authority.0.data}
  name: stwr
contexts:
- context:
    cluster: stwr
    user: aws
  name: stwr
current-context: stwr
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${local.cluster_name}"
KUBECONFIG
  worker_user_data = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.stwr.endpoint}' --b64-cluster-ca '${aws_eks_cluster.stwr.certificate_authority.0.data}' '${local.cluster_name}'
USERDATA
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.worker.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}