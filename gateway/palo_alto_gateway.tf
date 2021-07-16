##############################################################################
# Map containing Palo Alto Images by region
##############################################################################

locals {
  image_map = {
	  pa_vm_kvm_09_1_3_1 = {
      "us-south" = "r006-83c04bd0-f9c4-4e6d-bc0e-5b8618e66968"
		  "us-east"  = "r014-29b4bed0-9398-4a42-9220-f2cef4f5f39d"
		  "eu-gb"    = "r018-eefbfc05-af62-4b88-923d-a60eef249ec4"
      "eu-de"    = "r010-9899a24b-8d34-43cd-9f85-8d248af4e005"
		  "jp-tok"   = "r022-e37e9b23-e42c-46e6-a21a-6392c448f834"	
		  "eu-fr2"   = "r030-c6a4d0ef-e88a-4bfd-a4b4-0835e065cdc7"
      "au-syd"   = "r026-8d201ec3-6c48-45c4-9c61-ac1fd7720115"
      "ca-tor"   = "r038-01f97815-9b3c-47c5-840c-f50d4ddc8ea5"
      "jp-osa"   = "r034-a9430fad-9f49-49a7-ace5-c19db212a24d"
    }
  }        
}

##############################################################################


##############################################################################
# Provision VSI
##############################################################################

resource ibm_is_instance gateway_vsi {

  name           = "${var.unique_id}-gateway-vsi"
  image          = local.image_map.pa_vm_kvm_09_1_3_1[var.ibm_region]
  profile        = "bx2-8x32"
  resource_group = var.resource_group_id

  primary_network_interface {
    name   = "eth0"
    subnet = ibm_is_subnet.gateway_management_subnet.id
  }
  
  network_interfaces {
    name              = "eth1"
    subnet            = ibm_is_subnet.gateway_front_end_subnet.id
    allow_ip_spoofing = true
  }

  network_interfaces {
    name              = "eth2"
    subnet            = ibm_is_subnet.gateway_trusted_subnet.id
    allow_ip_spoofing = true
  
  }

  vpc  = var.vpc_id
  zone = "${var.ibm_region}-${var.zone}"
  keys = [ var.ssh_key_id ]

  provisioner local-exec {
    command = "sleep 30"
  }
                 
}

##############################################################################


##############################################################################
# Provision Floating IP for Linux VSI
##############################################################################

resource ibm_is_floating_ip gateway_vsi_fip {
  name   = "${var.unique_id}-gateway-vsi-fip"
  target = ibm_is_instance.gateway_vsi.primary_network_interface.0.id
}

##############################################################################