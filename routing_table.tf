##############################################################################
# Routing Table
##############################################################################

resource ibm_is_vpc_routing_table routing_table {
    vpc  = module.hub_vpc.vpc_id
    name = "${var.unique_id}-routing-table"
}

resource ibm_is_vpc_routing_table_route hub_vpc_egress {
    vpc           = module.hub_vpc.vpc_id
    routing_table = ibm_is_vpc_routing_table.routing_table.routing_table
    zone          = "${var.ibm_region}-1"
    name          = "${var.unique_id}-egress"
    destination   = "0.0.0.0/0"
    action        = "deliver"
    next_hop      = module.bastion_vsi.linux_vsi_info.ipv4_address
}

##############################################################################