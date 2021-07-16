##############################################################################
# VSI Outputs
##############################################################################

output gateway_vsi_info {
    description = "Information for the Gateway VSI"
    value       = {
        name         = ibm_is_instance.gateway_vsi.name
        id           = ibm_is_instance.gateway_vsi.id
        floating_ip  = ibm_is_floating_ip.gateway_vsi_fip.address
        eth0         = ibm_is_instance.gateway_vsi.primary_network_interface[0].primary_ipv4_address
        eth1         = ibm_is_instance.gateway_vsi.network_interfaces[0].primary_ipv4_address
        eth2         = ibm_is_instance.gateway_vsi.network_interfaces[1].primary_ipv4_address
    }
}

##############################################################################