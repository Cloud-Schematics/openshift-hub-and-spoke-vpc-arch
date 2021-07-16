##############################################################################
# Routing Table
##############################################################################

resource ibm_is_vpc_routing_table spoke_vpc_routing_table {
    vpc  = module.spoke_vpc.vpc_id
    name = "${var.unique_id}-routing-table"
}

##############################################################################


##############################################################################
# Rules to route traffic to Spoke VPC Subnet
##############################################################################

resource ibm_is_vpc_routing_table_route spoke_vpc_egress {
    count         = length(keys(var.spoke_vpc_cidr_blocks))
    vpc           = module.spoke_vpc.vpc_id
    routing_table = ibm_is_vpc_routing_table.spoke_vpc_routing_table.routing_table
    zone          = "${var.ibm_region}-${count.index + 1}"
    name          = "${var.unique_id}-egress-zone-${count.index + 1}"
    destination   = "8.8.8.8/32"
    action        = "deliver"
    next_hop      = module.palo_alto_gateway.gateway_vsi_info.eth2 # e2 private ip
}

##############################################################################

