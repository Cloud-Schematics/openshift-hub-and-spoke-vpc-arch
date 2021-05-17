##############################################################################
# Account variables
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
    description = "ID of VPC where cluster is to be created"
    type        = string
}

variable subnet_zone_list {
    description = "A map containing cluster subnet IDs and subnet zones"
    type        = list(object({
        id   = string
        zone = string
    }))
}

##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable machine_type {
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

variable wait_till {
    description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
    type        = string
    default     = "IngressReady"

    validation {
        error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
        condition     = contains([
            "MasterNodeReady",
            "OneWorkerNodeReady",
            "IngressReady"
        ], var.wait_till)
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

variable cos_id {
    description = "ID of COS instance"
    type        = string
}

variable kms_guid {
    description = "GUID of Key Protect Instance"
    type        = string
}

variable ibm_managed_key_id {
    description = "GUID of User Managed Key"
    type        = string
}

variable logdna_crn {
    description = "CRN of LogDNA Instance"
    type        = string
}

variable logdna_guid {
    description = "GUID of LogDNA instance"
    type        = string
}

variable sysdig_crn {
    description = "CRN of Sysdig Instance"
    type        = string
}

variable sysdig_guid {
    description = "GUID of Sysdig instance"
    type        = string
}

##############################################################################