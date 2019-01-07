output "kubeconfig" {
  value = "\n\n${data.template_file.kubeconfig.rendered}"
}

output "worker_role_arn" {
  value = "${aws_iam_role.worker.arn}"
}