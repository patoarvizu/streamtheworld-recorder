output "kubeconfig" {
  value = "\n\n${data.template_file.kubeconfig.rendered}"
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}