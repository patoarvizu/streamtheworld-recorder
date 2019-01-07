provider "kubernetes" {
  config_path = "${pathexpand("~/.kube/patoarvizu-config")}"
  config_context = "stwr"
}