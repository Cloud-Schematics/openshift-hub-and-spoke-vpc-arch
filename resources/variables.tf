##############################################################################
# Account Variables
##############################################################################

variable unique_id {
  description = "Unique ID for resources that will be provisioned"
  type        = string
}

variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
}

variable resource_group_id {
    description = "ID for IBM Cloud Resource Group where resources will be deployed"
    type        = string
}

##############################################################################


##############################################################################
# Resource Variables
##############################################################################

variable service_endpoints {
    description = "Service endpoints for resource instances. Can be `public`, `private`, or `public-and-private`."
    type        = string
    default     = "private"

    validation {
        error_message = "Service endpoints must be `public`, `private`, or `public-and-private`."
        condition = contains([
            "private",
            "public",
            "public-and-private"
        ], var.service_endpoints)
    }
}

variable kms_plan {
    description = "Plan for Key Protect"
    type        = string
    default     = "tiered-pricing"  
}

variable kms_root_key_name {
    description = "Name of the root key for Key Protect instance"
    type        = string
    default     = "root-key"

    validation {
        error_message = "Key protect root key name  must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
        condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.kms_root_key_name))
    }
}

variable kms_private_service_endpoint {
    description = "Use private service endpoint for Key Protect instance"
    type        = bool
    default     = true
}

variable cos_plan {
    description = "Plan for Cloud Object Storage instance"
    type        = string
    default     = "standard"
}

##############################################################################


##############################################################################
# Logging and Monitoring Variables
##############################################################################

variable logdna_plan {
  description = "Plan for LogDNA"
  type        = string
  default     = "7-day"
}

variable sysdig_plan {
  description = "Plan for Sysdig"
  type        = string
  default     = "graduated-tier"
}

##############################################################################