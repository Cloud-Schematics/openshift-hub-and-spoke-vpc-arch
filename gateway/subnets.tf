##############################################################################
# Locals
##############################################################################

locals {
  # Create a list of subnet objects from the CIDR blocks object by flattening all arrays into a single list
  subnet_list_from_object = flatten([
    # For each key in the object create an array
    for i in keys(var.cidr_blocks):
    # Each item in the list contains information about a single subnet
    [
      for j in var.cidr_blocks[i]:
      {
        zone      = "${var.ibm_region}-${var.zone}"
        cidr      = j                                                           # Subnet CIDR block
        count     = index(var.cidr_blocks[i], j) + 1                            # Count of the subnet within the zone
      }
    ]
  ])
}

##############################################################################


##############################################################################
# Public Gateway
##############################################################################

resource ibm_is_public_gateway public_gateway {
  name           = "${var.unique_id}-public-gateway"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  zone           = "${var.ibm_region}-${var.zone}"
}

##############################################################################


##############################################################################
# Prefixes and subnets
##############################################################################

resource ibm_is_vpc_address_prefix subnet_prefix {
  count = length(local.subnet_list_from_object)
  name  = "${var.unique_id}-prefix-gateway-subnet-${local.subnet_list_from_object[count.index].count}" 
  zone  = "${var.ibm_region}-${var.zone}"
  vpc   = var.vpc_id
  cidr  = local.subnet_list_from_object[count.index].cidr
}

##############################################################################


##############################################################################
# Management Subnet
##############################################################################

resource ibm_is_subnet gateway_management_subnet {
  name            = "${var.unique_id}-gateway-management-subnet"
  vpc             = var.vpc_id
  resource_group  = var.resource_group_id
  zone            = "${var.ibm_region}-${var.zone}"
  ipv4_cidr_block = ibm_is_vpc_address_prefix.subnet_prefix[0].cidr
  network_acl     = var.acl_id
  public_gateway  = ibm_is_public_gateway.public_gateway.id
}

##############################################################################



##############################################################################
# Front End
##############################################################################

resource ibm_is_subnet gateway_front_end_subnet {
  name            = "${var.unique_id}-gateway-front-end-subnet"
  vpc             = var.vpc_id
  resource_group  = var.resource_group_id
  zone            = "${var.ibm_region}-${var.zone}"
  ipv4_cidr_block = ibm_is_vpc_address_prefix.subnet_prefix[1].cidr
  network_acl     = var.acl_id
  public_gateway  = ibm_is_public_gateway.public_gateway.id
}

##############################################################################


##############################################################################
# Trusted
##############################################################################

resource ibm_is_subnet gateway_trusted_subnet {
  name              = "${var.unique_id}-gateway-trusted-subnet"
  vpc               = var.vpc_id
  resource_group    = var.resource_group_id
  zone              = "${var.ibm_region}-${var.zone}"
  ipv4_cidr_block   = ibm_is_vpc_address_prefix.subnet_prefix[2].cidr
  network_acl       = var.acl_id
}

##############################################################################