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

resource "confluentcloud_kafka_cluster" "mz_cluster" {
   display_name = "sduff_dedicated_multizone"
   availability = "MULTI_ZONE"
   cloud        = "AWS"
   region       = "ap-southeast-2"
   dedicated {
     cku = 2
   }

   environment {
      id = data.confluentcloud_environment.shared-env.id
   }
}

# Create a Service Account
resource "confluentcloud_service_account" "svc_account" {
  display_name = "sduff_tf_svc_acct"
  description = "sduff has created this service account to test the terraform provider"
}

# Bind this Service Account to the CloudClusterAdmin
resource "confluentcloud_role_binding" "example-rb" {
  principal = "User:${confluentcloud_service_account.svc_account.id}"
  role_name  = "CloudClusterAdmin"
  crn_pattern = confluentcloud_kafka_cluster.mz_cluster.rbac_crn
}


