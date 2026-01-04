terraform {
  required_version = ">= 1.5.0"
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello Terraform"
  }
}