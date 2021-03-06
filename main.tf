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

resource "confluentcloud_environment" "new-env" {
  display_name = "a-new-environment"
}

resource "confluentcloud_kafka_cluster" "my_cluster" {
   display_name = "sduff_basic_cluster"
   availability = "SINGLE_ZONE"
   cloud        = "AWS"
   region       = "ap-southeast-2"
   standard {}

   environment {
      id = data.confluentcloud_environment.shared-env.id
   }
}

resource "confluentcloud_kafka_cluster" "ded2" {
   display_name = "sduff_ded2"
   availability = "SINGLE_ZONE"
   cloud        = "AWS"
   region       = "ap-southeast-2"
   dedicated {
     cku = 4
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
  crn_pattern = confluentcloud_kafka_cluster.my_cluster.rbac_crn
}

# CREATE API KEY MANUALLY

# Topic
resource "confluentcloud_kafka_topic" "test_topic" {
  kafka_cluster      = confluentcloud_kafka_cluster.my_cluster.id
  topic_name         = "orders"
  partitions_count   = 6
  http_endpoint      = confluentcloud_kafka_cluster.my_cluster.http_endpoint
  config = { 
    "cleanup.policy"    = "compact"
    "max.message.bytes" = "12345"
    "retention.ms"      = "67890"
  }
  credentials {
    key    = "${var.KAFKA_API_KEY}"
    secret = "${var.KAFKA_API_SECRET}"
  }
}

## ACL
resource "confluentcloud_kafka_acl" "describe-basic-cluster" {
  kafka_cluster = confluentcloud_kafka_cluster.my_cluster.id
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:sa-yovo3j"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  http_endpoint = confluentcloud_kafka_cluster.my_cluster.http_endpoint
  credentials {
    key    = "${var.KAFKA_API_KEY}"
    secret = "${var.KAFKA_API_SECRET}"
  }
}
