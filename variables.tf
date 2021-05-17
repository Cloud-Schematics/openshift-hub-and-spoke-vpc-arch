##############################################################################
# Account Variables
##############################################################################

variable TF_VERSION {
 default     = "0.13"
 description = "The version of the Terraform engine that's used in the Schematics workspace."
}

variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string
}

variable unique_id {
    description = "A unique identifier need to provision resources. Must begin with a letter"
    type        = string
    default     = "asset-multizone"

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

##############################################################################


##############################################################################
# Network variables
##############################################################################

variable classic_access {
  description = "Enable VPC Classic Access. Note: only one VPC per region can have classic access"
  type        = bool
  default     = false
}

variable hub_vpc_cidr_blocks {
  description = "An object containing lists of CIDR blocks. Each CIDR block will be used to create a subnet"
  type        = object({
    zone-1 = list(string)
    zone-2 = list(string)
    zone-3 = list(string)
  })
  default     = {
    zone-1 = [
      "10.10.10.0/24"
    ],

    zone-2 = [
      "10.40.10.0/24"
    ],

    zone-3 = [
      "10.70.10.0/24"
    ]
  }

  validation {
    error_message = "The var.cidr_blocks objects must have 1, 2, or 3 keys."
    condition     = length(keys(var.hub_vpc_cidr_blocks)) <= 3 && length(keys(var.hub_vpc_cidr_blocks)) >= 1
  }

  validation {
    error_message = "Each list must have at least one CIDR block."
    condition     = length(distinct(
      [
        for zone in keys(var.hub_vpc_cidr_blocks):
        false if length(var.hub_vpc_cidr_blocks[zone]) == 0
      ]
    )) == 0
  }

  validation {
    error_message = "Each item in each list must contain a valid CIDR block."
    condition     = length(
      distinct(
        flatten([
          for zone in keys(var.hub_vpc_cidr_blocks):
          false if length([
            for cidr in var.hub_vpc_cidr_blocks[zone]:
            false if !can(regex("^(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2}).(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2}).(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2}).(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2})\\/(3[0-2]|2[0-9]|1[0-9]|[0-9])$", cidr))
          ]) > 0
        ])
      )
    ) == 0
  }
}

variable spoke_vpc_cidr_blocks {
  description = "An object containing lists of CIDR blocks. Each CIDR block will be used to create a subnet"
  default     = {
    zone-1 = [
      "10.100.10.0/24"
    ]
  }

  validation {
    error_message = "The var.cidr_blocks objects must have 1, 2, or 3 keys."
    condition     = length(keys(var.spoke_vpc_cidr_blocks)) <= 3 && length(keys(var.spoke_vpc_cidr_blocks)) >= 1
  }

  validation {
    error_message = "Each list must have at least one CIDR block."
    condition     = length(distinct(
      [
        for zone in keys(var.spoke_vpc_cidr_blocks):
        false if length(var.spoke_vpc_cidr_blocks[zone]) == 0
      ]
    )) == 0
  }

  validation {
    error_message = "Each item in each list must contain a valid CIDR block."
    condition     = length(
      distinct(
        flatten([
          for zone in keys(var.spoke_vpc_cidr_blocks):
          false if length([
            for cidr in var.spoke_vpc_cidr_blocks[zone]:
            false if !can(regex("^(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2}).(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2}).(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2}).(2[0-5][0-9]|1[0-9]{1,2}|[0-9]{1,2})\\/(3[0-2]|2[0-9]|1[0-9]|[0-9])$", cidr))
          ]) > 0
        ])
      )
    ) == 0
  }

}

##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable cluster_machine_type {
    description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
    type        = string
    default     = "bx2.4x16"
}

variable workers_per_zone {
    description = "Number of workers to provision in each subnet"
    type        = number
    default     = 2

    validation {
        error_message = "Each zone must contain at least 2 workers."
        condition     = var.workers_per_zone >= 2
    }
}

variable disable_public_service_endpoint {
    description = "Disable public service endpoint for cluster"
    type        = bool
    default     = true
}

variable entitlement {
    description = "If you purchased an IBM Cloud Cloud Pak that includes an entitlement to run worker nodes that are installed with OpenShift Container Platform, enter entitlement to create your cluster with that entitlement so that you are not charged twice for the OpenShift license. Note that this option can be set only when you create the cluster. After the cluster is created, the cost for the OpenShift license occurred and you cannot disable this charge."
    type        = string
    default     = "cloud_pak"
}

variable kube_version {
    description = "Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`."
    type        = string
    default     = "4.6.23_openshift"

    validation {
        error_message = "To create a ROKS cluster, the kube version must include `openshift`."
        condition     = can(regex(".*openshift", var.kube_version))
    }
}

variable tags {
    description = "A list of tags to add to the cluster"
    type        = list(string)
    default     = []

    validation  {
        error_message = "Tags must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for name in var.tags:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
        ]) == 0
    }
}

variable worker_pools {
    description = "List of maps describing worker pools"

    type        = list(object({
        pool_name        = string
        machine_type     = string
        workers_per_zone = number
    }))

    default     = [
        {
            pool_name        = "dev"
            machine_type     = "cx2.8x16"
            workers_per_zone = 2
        },
        {
            pool_name        = "test"
            machine_type     = "mx2.4x32"
            workers_per_zone = 2
        }
    ]

    validation  {
        error_message = "Worker pool names must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for pool in var.worker_pools:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", pool.pool_name))
        ]) == 0
    }

    validation {
        error_message = "Worker pools cannot have duplicate names."
        condition     = length(distinct([
            for pool in var.worker_pools:
            pool.pool_name
        ])) == length(var.worker_pools)
    }

    validation {
        error_message = "Worker pools must have at least two workers per zone."
        condition     = length([
            for pool in var.worker_pools:
            false if pool.workers_per_zone < 2
        ]) == 0
    }

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

variable cos_plan {
    description = "Plan for Cloud Object Storage instance"
    type        = string
    default     = "standard"
}

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


##############################################################################
# VSI Variables
##############################################################################

variable ssh_public_key {
  description = "ssh public key to use for vsi"
  type        = string
}

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