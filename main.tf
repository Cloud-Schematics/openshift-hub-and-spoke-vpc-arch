##############################################################################
# Resource Group where VPC will be created
##############################################################################

data ibm_resource_group resource_group {
  name = var.resource_group
}

##############################################################################


##############################################################################
# Create VPC Architecture
##############################################################################

module hub_vpc {
    source            = "./multizone_vpc"
    # Account Variables
    unique_id         = "${var.unique_id}-hub"
    ibm_region        = var.ibm_region
    resource_group_id = data.ibm_resource_group.resource_group.id
    # VPC Variables
    cidr_blocks       = var.hub_vpc_cidr_blocks
    acl_rules         = local.hub_subnet_cidr_rules
}

module spoke_vpc {
    source                = "./multizone_vpc"
    # Account Variables
    unique_id             = "${var.unique_id}-spoke"
    ibm_region            = var.ibm_region
    resource_group_id     = data.ibm_resource_group.resource_group.id
    # VPC Variables
    cidr_blocks           = var.spoke_vpc_cidr_blocks
    enable_public_gateway = true
    acl_rules             = local.spoke_cidr_rules
}

##############################################################################


##############################################################################
# Create Resources
##############################################################################

module resources {
    source            = "./resources"
    # Account Variables
    unique_id         = var.unique_id
    ibm_region        = var.ibm_region
    resource_group_id = data.ibm_resource_group.resource_group.id
    # Service Variables
    service_endpoints = var.service_endpoints
    kms_plan          = var.kms_plan
    kms_root_key_name = var.kms_root_key_name
    cos_plan          = var.cos_plan
}

##############################################################################


##############################################################################
# Create Cluster and Respirces
##############################################################################

module roks_cluster {
    source                          = "./roks_cluster"
    # Account Variables
    unique_id                       = var.unique_id
    ibm_region                      = var.ibm_region
    resource_group_id               = data.ibm_resource_group.resource_group.id
    # VPC Variables
    vpc_id                          = module.hub_vpc.vpc_id
    subnet_zone_list                = module.hub_vpc.subnet_zone_list
    # Cluster Variables
    machine_type                    = var.cluster_machine_type
    workers_per_zone                = var.workers_per_zone
    disable_public_service_endpoint = var.disable_public_service_endpoint
    entitlement                     = var.entitlement
    kube_version                    = var.kube_version
    tags                            = var.tags
    worker_pools                    = var.worker_pools
    cos_id                          = module.resources.cos_id
    kms_guid                        = module.resources.kms_guid
    ibm_managed_key_id              = module.resources.ibm_managed_key_id
    # Logging and Monitoring Variables
    logdna_crn                      = module.resources.logdna_crn
    logdna_guid                     = module.resources.logdna_guid
    sysdig_crn                      = module.resources.sysdig_crn
    sysdig_guid                     = module.resources.sysdig_guid
}

##############################################################################


##############################################################################
# Create Bastion VSI
##############################################################################

module bastion_vsi {
    source                                = "./bastion_vsi"
    # Account Variables
    ibmcloud_api_key                      = var.ibmcloud_api_key
    unique_id                             = var.unique_id
    ibm_region                            = var.ibm_region
    resource_group                        = var.resource_group
    resource_group_id                     = data.ibm_resource_group.resource_group.id
    # VPC Variables
    vpc_id                                = module.spoke_vpc.vpc_id
    proxy_subnet                          = module.spoke_vpc.subnet_zone_list[0]
    ssh_public_key                        = var.ssh_public_key
    # VSI Variables
    linux_vsi_image                       = var.linux_vsi_image
    linux_vsi_machine_type                = var.linux_vsi_machine_type
    windows_vsi_image                     = var.windows_vsi_image
    windows_vsi_machine_type              = var.windows_vsi_machine_type
    # Cluster Variables
    cluster_name                          = module.roks_cluster.cluster_name
    cluster_private_service_endpoint_port = module.roks_cluster.cluster_private_service_endpoint_port
}

##############################################################################