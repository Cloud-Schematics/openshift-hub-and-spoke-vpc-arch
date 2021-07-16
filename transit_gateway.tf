##############################################################################
# Transit Gateway
##############################################################################

resource ibm_tg_gateway transit_gateway {
  name           = "${var.unique_id}-transit-gateway"
  location       = var.ibm_region
  global         = false
  resource_group = data.ibm_resource_group.resource_group.id
}

##############################################################################


##############################################################################
# Transit Gateway Connections
##############################################################################

resource ibm_tg_connection spoke_connection {
  gateway      = ibm_tg_gateway.transit_gateway.id
  network_type = "vpc"
  name         = "${var.unique_id}-hub-connection"
  network_id   = module.spoke_vpc.vpc_crn
}

resource ibm_tg_connection hub_connection {
  gateway      = ibm_tg_gateway.transit_gateway.id
  network_type = "vpc"
  name         = "${var.unique_id}-spoke-connection"
  network_id   = module.hub_vpc.vpc_crn
}

##############################################################################
