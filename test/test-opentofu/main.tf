# main.tf
provider "local" {
  version = "~> 2.0"
}

resource "local_file" "hello_world" {
  content  = "Hello, World!"
  filename = "${path.module}/hello_world.txt"
}

output "hello_message" {
  value = "Hello, World!"
}
