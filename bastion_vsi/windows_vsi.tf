##############################################################################
# Data Blocks
##############################################################################

data ibm_is_image windows_image {
  name = var.windows_vsi_image
}

##############################################################################


##############################################################################
# Provision VSI
##############################################################################

resource ibm_is_instance windows_vsi {
    name           = "${var.unique_id}-windows-vsi"
    image          = data.ibm_is_image.windows_image.id
    profile        = var.windows_vsi_machine_type
    resource_group = var.resource_group_id

    primary_network_interface {
      subnet       = var.proxy_subnet.id
    }
  
    vpc            = var.vpc_id
    zone           = var.proxy_subnet.zone
    keys           = [ ibm_is_ssh_key.ssh_key.id ]

    user_data = <<POWERSHELL
#ps1_sysnative
Try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
  choco install kubernetes-cli -y
}
Catch
{
  Set-Content C:\setup-error.txt -Value $_.Exception.Message
  throw
}
    POWERSHELL

    # Prevents the windows VSI from being created before the cluster is finished provisioning
    depends_on     = [ ibm_is_instance.linux_vsi ]
}

##############################################################################


##############################################################################
# Provision Floating IP for Windows VSI
##############################################################################

resource ibm_is_floating_ip windows_vsi_fip {
  name   = "${var.unique_id}-windows-vsi-fip"
  target = ibm_is_instance.windows_vsi.primary_network_interface.0.id
}

##############################################################################