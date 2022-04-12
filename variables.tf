# The environment we use is stored in Terraform Cloud Variables
variable "CONFLUENT_CLOUD_ENVIRONMENT_ID" {
     type = string
}

variable "KAFKA_API_SECRET" {
     type = string
}

variable "KAFKA_API_KEY" {
     type = string
}
