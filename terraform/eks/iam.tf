resource "aws_iam_role" "master" {
  name = "${local.cluster_name}-master"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = "${aws_iam_role.master.name}"
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = "${aws_iam_role.master.name}"
}

resource "aws_iam_role" "worker" {
  name = "${local.cluster_name}-worker"
  assume_role_policy = "${data.aws_iam_policy_document.worker_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = "${aws_iam_role.worker.name}"
}

resource "aws_iam_role_policy_attachment" "worker_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = "${aws_iam_role.worker.name}"
}

resource "aws_iam_role_policy_attachment" "worker_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = "${aws_iam_role.worker.name}"
}

resource "aws_iam_role_policy" "worker_ecr_policy" {
  name = "worker-ecr-policy"
  role = "${aws_iam_role.worker.name}"
  policy = "${data.aws_iam_policy_document.worker_ecr_policy.json}"
}

resource "aws_iam_instance_profile" "worker" {
  name = "${local.cluster_name}-worker"
  role = "${aws_iam_role.worker.name}"
}