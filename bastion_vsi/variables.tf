##############################################################################
# Account variables
##############################################################################

variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string
}

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

variable resource_group {
    description = "Name of resource group where all infrastructure will be provisioned"
    type        = string
    default     = "asset-development"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
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

variable proxy_subnet {
  description = "An object containing the CIDR block, zone, and ID of the proxy subnet"
  type        = object({
    id   = string
    zone = string
  })
}

##############################################################################


##############################################################################
# VSI Variables
##############################################################################

variable ssh_public_key {
  description = "ssh public key to use for vsi"
  type        = string
}

##############################################################################


##############################################################################
# Linux VSI Variables
##############################################################################

variable linux_vsi_image {
  description = "Image name used for VSI. Run 'ibmcloud is images' to find available images in a region"
  type        = string
  default     = "ibm-centos-7-6-minimal-amd64-2"
}

variable linux_vsi_machine_type {
  description = "VSI machine type. Run 'ibmcloud is instance-profiles' to get a list of regional profiles"
  type        =  string
  default     = "bx2-8x32"
}

variable cluster_name {
  description = "Name of the cluster to connect to"
  type        = string
}

variable cluster_private_service_endpoint_port {
  description = "Port of the cluster private service endpoint"
}

variable cluster_id {
  description = "ID of the cluster. This is used to trigger the recreation and destruction of VSI"
  type        = string
}

##############################################################################


##############################################################################
# Windows VSI Variables
##############################################################################

variable windows_vsi_image {
  description = "Image name used for VSI. Run 'ibmcloud is images' to find available images in a region"
  type        = string
  default     = "ibm-windows-server-2012-full-standard-amd64-3"
}

variable windows_vsi_machine_type {
  description = "VSI machine type. Run 'ibmcloud is instance-profiles' to get a list of regional profiles"
  type        =  string
  default     = "bx2-8x32"
}

##############################################################################