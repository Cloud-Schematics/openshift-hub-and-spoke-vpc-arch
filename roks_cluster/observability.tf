##############################################################################
# Create LogDNA Ingestion Key and setup agents
##############################################################################

resource ibm_resource_key logdna_secret {
  name                 = "logdna_key"
  role                 = "Manager"
  resource_instance_id = var.logdna_crn
}

resource ibm_ob_logging logdna_deployment {
  cluster     = ibm_container_vpc_cluster.cluster.id
  instance_id = var.logdna_guid
  depends_on  = [ ibm_resource_key.logdna_secret ]
}

##############################################################################


##############################################################################
# Create sysdig access key and setup agents
##############################################################################

resource ibm_resource_key sysdig_secret {
  name                 = "monitor_key"
  role                 = "Manager"
  resource_instance_id = var.sysdig_crn
}

resource ibm_ob_monitoring sysdig_deployment {
  cluster     = ibm_container_vpc_cluster.cluster.id
  instance_id = var.sysdig_guid
  depends_on  = [ ibm_resource_key.sysdig_secret ]
}

##############################################################################