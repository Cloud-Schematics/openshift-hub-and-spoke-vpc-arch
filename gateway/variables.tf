##############################################################################
# Account Variables
##############################################################################

variable unique_id {
  description = "A unique identifier need to provision resources. Must begin with a letter"
  type        = string
  default     = "asset-roks"
  
  validation  {
    error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.unique_id))
  }
}

variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string

    validation  {
      error_message = "Must use an IBM Cloud region. Use `ibmcloud regions` with the IBM Cloud CLI to see valid regions."
      condition     = can(
        contains([
          "au-syd",
          "jp-tok",
          "eu-de",
          "eu-gb",
          "us-south",
          "us-east"
        ], var.ibm_region)
      )
    }
}

variable resource_group_id {
  description = "ID of resource group where all infrastructure will be provisioned"
  type        = string
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable vpc_id {
  description = "ID of VPC where VSI will be provisioned"
  type        = string
}

variable acl_id {
  description = "ACL ID where the subnets for the gateway will be provisioned"
}

variable cidr_blocks {
    description = "CIDR blocks for subnets to be created. If no CIDR blocks are provided, it will create subnets with 256 total ipv4 addresses"
}

variable ssh_key_id {
  description = "ID of SSH key to use when provisioning VSI"
}

variable zone {
  description = "Zone where the device will be provisioned"
  default     = 2
}

##############################################################################