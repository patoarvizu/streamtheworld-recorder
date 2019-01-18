apiVersion: v1
clusters:
- cluster:
    server: ${server_endpoint}
    certificate-authority-data: ${certificate_authority_data}
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
      env:
        - name: "AWS_DEFAULT_PROFILE"
          value: "patoarvizu-admin"
      args:
        - "token"
        - "-i"
        - "${cluster_name}"