##############################################################################
# VPC GUID
##############################################################################

output vpc_id {
  description = "ID of VPC created"
  value       = ibm_is_vpc.vpc.id
}

output vpc_crn {
  description = "CRN of VPC"
  value       = ibm_is_vpc.vpc.resource_crn
}

##############################################################################


##############################################################################
# Subnet Outputs
##############################################################################

output subnet_ids {
  description = "List of subnet ids in vpc tier 1"
  value       = module.subnets.subnet_ids
}

output subnet_zone_list {
  description = "A map containing cluster subnet IDs and subnet zones"
  value       = module.subnets.subnet_zone_list
}

output subnet_detail_list {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value       = module.subnets.subnet_detail_list
}

##############################################################################
