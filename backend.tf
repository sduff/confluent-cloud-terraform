terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "confluent-env"

    workspaces {
      name = "confluent-cloud-terraform"
    }
  }
}
