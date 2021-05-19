
# Create rules for VPC ACLs
##############################################################################

locals {

      hub_subnet_cidr_list = flatten([
            [
                  # for each zone in the cidr blocks map
                  for zone in keys(var.hub_vpc_cidr_blocks): 
                  [
                        # Create an object containing the rule name and the CIDR block
                        for cidr in var.hub_vpc_cidr_blocks[zone]:
                        {
                              # Format name zone-<>-subnet-<>
                              name = "zone-${
                                    index(keys(var.hub_vpc_cidr_blocks), zone) + 1
                              }-subnet-${
                                    index(var.hub_vpc_cidr_blocks[zone], cidr) + 1
                              }"
                              cidr = cidr
                        }
                  ]
            ], 
            [
                  {
                        name = "proxy-subnet"
                        cidr = var.spoke_vpc_cidr_blocks["zone-1"][0]
                  }
            ]
      ])

      hub_subnet_cidr_rules = flatten([
            [
                  # ROKS Rules
                  {
                        name        = "roks-create-worker-nodes-inbound"
                        action      = "allow"
                        source      = "161.26.0.0/16"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                  },
                  {
                        name        = "roks-create-worker-nodes-outbound"
                        action      = "allow"
                        destination = "161.26.0.0/16"
                        source      = "0.0.0.0/0"
                        direction   = "outbound"
                  },
                  {
                        name        = "roks-nodes-to-service-inbound"
                        action      = "allow"
                        source      = "166.8.0.0/14"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                  },
                  {
                        name        = "roks-nodes-to-service-outbound"
                        action      = "allow"
                        destination = "166.8.0.0/14"
                        source      = "0.0.0.0/0"
                        direction   = "outbound"
                  },
                  # App Rules
                  {
                        name        = "allow-app-incoming-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                        tcp         = {
                              port_min        = 1
                              port_max        = 65535
                              source_port_min = 30000
                              source_port_max = 32767
                        }
                  },
                  {
                        name        = "allow-app-outgoing-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "outbound"
                        tcp         = {
                              source_port_min = 1
                              source_port_max = 65535
                              port_min        = 30000
                              port_max        = 32767
                        }
                  },
                  {
                        name        = "allow-lb-incoming-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                        tcp         = {
                              source_port_min = 1
                              source_port_max = 65535
                              port_min        = 443
                              port_max        = 443
                        }
                  },
                  {
                        name        = "allow-lb-outgoing-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "outbound"
                        tcp         = {
                              port_min        = 1
                              port_max        = 65535
                              source_port_min = 443
                              source_port_max = 443
                        }
                  }
            ],
            # Create rules that allow incoming traffic from subnets
            [
                  for subnet in local.hub_subnet_cidr_list:           
                  {
                        name        = "allow-traffic-${subnet.name}-inbound"
                        action      = "allow"
                        source      = subnet.cidr
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                  }
            ],
            # Create rules to allow outbound traffic to subnets
            [
                  for subnet in local.hub_subnet_cidr_list:           
                  {
                        name        = "allow-traffic-${subnet.name}-outbound"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = subnet.cidr
                        direction   = "outbound"
                  }
            ],
            # Rules to allow proxy subnet to access all incoming and outgoing traffic
            [
                  {
                        name        = "allow-all-traffic-proxy-inbound"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = var.spoke_vpc_cidr_blocks["zone-1"][0]
                        direction   = "inbound"
                  },
                  {
                        name        = "allow-all-traffic-proxy-outbound"
                        action      = "allow"
                        destination = "0.0.0.0/0"
                        source      = var.spoke_vpc_cidr_blocks["zone-1"][0]
                        direction   = "outbound"
                  }
            ],
            # Rules to deny any other inbound and outound traffic
            [
                  {
                        name        = "deny-all-traffic-proxy-inbound"
                        action      = "deny"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                  },
                  {
                        name        = "deny-all-traffic-proxy-outbound"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "outbound"
                  }
            ]
    ])

    spoke_cidr_rules = flatten(
        [
            {
                name        = "allow-all-traffic-proxy-inbound"
                action      = "allow"
                source      = "0.0.0.0/0"
                destination = var.spoke_vpc_cidr_blocks["zone-1"][0]
                direction   = "inbound"
            },
            {
                name        = "allow-all-traffic-proxy-outbound"
                action      = "allow"
                destination = "0.0.0.0/0"
                source      = var.spoke_vpc_cidr_blocks["zone-1"][0]
                direction   = "outbound"
            }
        ]
    )
}

##############################################################################