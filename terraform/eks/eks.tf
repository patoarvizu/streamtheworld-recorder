resource "aws_eks_cluster" "stwr" {
  name = "${local.cluster_name}"
  role_arn = "${aws_iam_role.master.arn}"
  vpc_config {
    security_group_ids = [ "${aws_security_group.master.id}" ]
    subnet_ids = [ "${aws_subnet.stwr.*.id}" ]
  }
  depends_on = [
    "aws_iam_role_policy_attachment.cluster_policy",
    "aws_iam_role_policy_attachment.service_policy",
  ]
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.kubeconfig.rendered}' > '${pathexpand("~/.kube/patoarvizu-config")}'"
  }
}