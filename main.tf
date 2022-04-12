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

# remove buggy resources
#
# BUG - create a cluster outside of allowed regions
resource "confluentcloud_kafka_cluster" "banned-cluster" {
   display_name = "banned_cluster"
   availability = "SINGLE_ZONE"
   cloud        = "AWS"
   region       = "eu-central-1"
   basic {}

   environment {
      id = data.confluentcloud_environment.shared-env.id
   }
}

# BUG - create a cluster outside of allowed clouds
resource "confluentcloud_kafka_cluster" "banned-geo-cluster" {
   display_name = "banned_geo_cluster"
   availability = "SINGLE_ZONE"
   cloud        = "GCP"
   region       = "australia-southeast1"
   basic {}

   environment {
      id = data.confluentcloud_environment.shared-env.id
   }
}
