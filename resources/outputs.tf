##############################################################################
# Outputs
##############################################################################

output cos_id {
    description = "ID of COS instance"
    value       = ibm_resource_instance.cos.id
}

##############################################################################


##############################################################################
# Key Protect Outputs
##############################################################################

output kms_guid {
    description = "GUID of Key Protect Instance"
    value       = ibm_resource_instance.kms.guid
}

output ibm_managed_key_id {
    description = "GUID of User Managed Key"
    value       = ibm_kms_key.root_key.key_id
}

##############################################################################


##############################################################################
# Logging and Monitoring Outputs
##############################################################################

output logdna_crn {
    description = "CRN of LogDNA Instance"
    value       = ibm_resource_instance.logdna.id
}

output logdna_guid {
    description = "GUID of LogDNA Instance"
    value       = ibm_resource_instance.logdna.guid
}

output sysdig_crn {
    description = "CRN of Sysdig Instance"
    value       = ibm_resource_instance.sysdig.id
}

output sysdig_guid {
    description = "GUID of Sysdig Instance"
    value       = ibm_resource_instance.sysdig.guid
}

##############################################################################