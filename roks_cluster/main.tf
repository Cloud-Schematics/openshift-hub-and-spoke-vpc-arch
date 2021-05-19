##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource ibm_container_vpc_cluster cluster {

  name              = "${var.unique_id}-roks-cluster"
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  flavor            = var.machine_type
  worker_count      = var.workers_per_zone
  kube_version      = var.kube_version != "" ? var.kube_version : null
  tags              = var.tags
  wait_till         = var.wait_till
  entitlement       = var.entitlement
  cos_instance_crn  = var.cos_id

  dynamic zones {
    for_each = var.subnet_zone_list
    content {
      subnet_id = zones.value.id
      name      = zones.value.zone
    }
  }

  disable_public_service_endpoint = var.disable_public_service_endpoint

  kms_config {
    instance_id      = var.kms_guid
    crk_id           = var.ibm_managed_key_id
    private_endpoint = true
  }

}

##############################################################################


##############################################################################
# Worker Pools
##############################################################################

module worker_pools {
  source            = "./worker_pools"
  ibm_region        = var.ibm_region
  pool_list         = var.worker_pools
  entitlement       = var.entitlement
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  cluster_name_id   = ibm_container_vpc_cluster.cluster.id
  subnets           = var.subnet_zone_list
}

##############################################################################