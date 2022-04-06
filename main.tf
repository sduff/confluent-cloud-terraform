# Terraform Provider for Confluent Cloud
#
terraform {
   required_providers {
      confluentcloud = {
         source  = "confluentinc/confluentcloud"
         version = "0.5.0"
      }
   }
}

provider "confluentcloud" {}

# The environment we use is stored in Terraform Cloud Variables
variable "CONFLUENT_CLOUD_ENVIRONMENT_ID" {
     type = string
}
data "confluentcloud_environment" "shared-env" {
   id = "${var.CONFLUENT_CLOUD_ENVIRONMENT_ID}"
}

# Create a basic cluster
resource "confluentcloud_kafka_cluster" "basic-cluster" {
   display_name = "sduff_basic_kafka_cluster"
   availability = "SINGLE_ZONE"
   cloud        = "AWS"
   region       = "ap-southeast-2"
   basic {}

   environment {
      id = data.confluentcloud_environment.shared-env.id
   }
}
