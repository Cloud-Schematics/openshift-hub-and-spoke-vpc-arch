##############################################################################
# Data Blocks
##############################################################################

data ibm_is_image linux_vsi_image {
  name = var.linux_vsi_image
}


##############################################################################


##############################################################################
# Provision VSI
##############################################################################

resource ibm_is_instance linux_vsi {

    name           = "${var.unique_id}-vsi-nlb-proxy"
    image          = data.ibm_is_image.linux_vsi_image.id
    profile        = var.linux_vsi_machine_type
    resource_group = var.resource_group_id

    primary_network_interface {
      subnet       = var.proxy_subnet.id
    }
  
    vpc            = var.vpc_id
    zone           = var.proxy_subnet.zone
    keys           = [ var.ssh_key_id ]

    user_data  = <<BASH
#!/bin/bash

IBMCLOUD_API_KEY="${var.ibmcloud_api_key}"
IBM_REGION="${var.ibm_region}"
RESOURCE_GROUP="${var.resource_group}"
CLUSTER_NAME="${var.cluster_name}"
PORT=${var.cluster_private_service_endpoint_port}

# Install Kubectl CLI
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
rm -rf kubectl kubectl.sha256 

# Install IBM Cloud CLI
curl -sL https://raw.githubusercontent.com/IBM-Cloud/ibm-cloud-developer-tools/master/linux-installer/idt-installer | bash
sleep 10
ibmcloud plugin install container-service

# Install OpenShift CLI
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.5/openshift-client-linux-4.5.40.tar.gz
tar xvzf openshift-client-linux-4.5.40.tar.gz 
mv oc /usr/local/bin

# Install Terraform 
yum install -y net-tools
yum install unzip -y
wget https://releases.hashicorp.com/terraform/0.14.6/terraform_0.14.6_linux_amd64.zip
unzip terraform_0.14.6_linux_amd64.zip
chmod +x terraform
mv terraform /usr/local/bin
rm -rf terraform_0.14.6_linux_amd64.zip

# Create Terraform Files

# Create nlb.tf
echo '
##############################################################################
# Create NLB and Enpoints
##############################################################################

resource kubernetes_service kube_api_via_nlb {
    metadata {
        name      = "kube-api-via-nlb"
        namespace = "default"
        annotations = {
            "service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type" = "private"
        }
     }

    spec {
        port {
            protocol    = "TCP"
            port        = var.private_service_endpoint_port
            target_port = var.private_service_endpoint_port
        }

        type = "LoadBalancer"
    }

}


resource kubernetes_endpoints kube_api_via_nlb {

    metadata {
        name = "kube-api-via-nlb"
    }

    subset {
        address {
            ip = "172.20.0.1"
        }

        port {
            port = 2040
        }
    }

    depends_on = [ kubernetes_service.kube_api_via_nlb ]
}

##############################################################################' > ~/nlb.tf

echo '##############################################################################
# Create Proxy
##############################################################################

resource kubernetes_service_account crio_updater_ds {
  metadata {
    name = "crio-updater-ds"
  }

  depends_on = [ kubernetes_endpoints.kube_api_via_nlb ]
}

# https://jpapejr.github.io/content/roks_proxy.html
resource null_resource oc_commands {
  provisioner local-exec {
    command = <<CLI
      ibmcloud login --apikey $${var.ibmcloud_api_key} -r ${var.ibm_region} -g ${var.resource_group}
      ibmcloud cs cluster config --cluster ${var.cluster_name} --admin 
      oc project default 
      oc adm policy add-scc-to-user privileged -z crio-updater-ds
    CLI
  }

  depends_on = [ kubernetes_service_account.crio_updater_ds ]
}

##############################################################################' > ~/proxy.tf



# Create Providers.tf
echo '
##############################################################################
# Terraform Providers
##############################################################################

terraform {
    required_providers {
        ibm = {
            source = "IBM-Cloud/ibm"
            version = ">=1.24.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0"
        }
    }
}

##############################################################################

##############################################################################
# Provider
##############################################################################

provider ibm {
    ibmcloud_api_key = var.ibmcloud_api_key
    region           = var.ibm_region
    ibmcloud_timeout = 60
    generation       = 2
}

##############################################################################

##############################################################################
# Resource Group
##############################################################################

data ibm_resource_group group {
    name = var.resource_group
}

##############################################################################

##############################################################################
# Cluster Data
##############################################################################

data ibm_container_cluster_config cluster {
    cluster_name_id   = var.cluster_name
    resource_group_id = data.ibm_resource_group.group.id
    admin             = true
}

##############################################################################

##############################################################################
# Kubernetes Provider
##############################################################################

provider kubernetes {
    host                   = data.ibm_container_cluster_config.cluster.host
    client_certificate     = data.ibm_container_cluster_config.cluster.admin_certificate
    client_key             = data.ibm_container_cluster_config.cluster.admin_key
    cluster_ca_certificate = data.ibm_container_cluster_config.cluster.ca_certificate
}

##############################################################################' > ~/providers.tf


# Create Variables.tf
echo '
##############################################################################
# Account variables
##############################################################################

variable ibmcloud_api_key {
    description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
    type        = string
}

variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
}

variable resource_group {
    description = "Name of resource group where the cluster is provisioned"
    type        = string
}

##############################################################################

##############################################################################
# Cluster Variables
##############################################################################

variable cluster_name {
    description = "Name of the cluster where the NLB endpoint will be created"
    type        = string
}
variable private_service_endpoint_port {
    description = "Private service endpoint port"
    type        = number
}

##############################################################################' > ~/variables.tf

# Create Environment variables
echo '
ibmcloud_api_key="'$IBMCLOUD_API_KEY'"
ibm_region="'$IBM_REGION'"
resource_group="'$RESOURCE_GROUP'"
cluster_name="'$CLUSTER_NAME'"
private_service_endpoint_port="'$PORT'"
' > ~/terraform.tfvars

cd ~/

# Execute Terraform
terraform init
terraform plan
echo "yes" | terraform apply

ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_REGION -g $RESOURCE_GROUP
ibmcloud plugin install container-service
ibmcloud cs cluster config --cluster $CLUSTER_NAME --admin 

set -o xtrace
for NODE in `oc get no -oname`; do
    echo $NODE
    oc debug $NODE -- /bin/sh -c 'echo NO_PROXY="localhost,127.0.0.1,172.20.0.1,172.21.0.0/16,172.17.0.0/18,161.26.0.0/16,166.8.0.0/14,172.20.0.0/16,10.10.10.0/24,10.40.10.0/24,10.70.10.0/24"  > /host/etc/sysconfig/crio-network;'
    oc debug $NODE -- /bin/sh -c 'echo HTTP_PROXY="http://10.241.0.11:3128/" >> /host/etc/sysconfig/crio-network;'
    oc debug $NODE -- /bin/sh -c 'echo HTTPS_PROXY="http://10.241.0.11:3128/" >> /host/etc/sysconfig/crio-network;'
    oc debug $NODE -- /bin/sh -c 'cat /host/etc/sysconfig/crio-network;'
    oc label $NODE crio-proxified=true; 
done
for WORKER in ` ibmcloud cs worker ls --cluster $CLUSTER_NAME | grep kube | cut -d' ' -f1`; do
    echo $WORKER
    ibmcloud cs worker reboot -f --skip-master-health --worker $WORKER --cluster $CLUSTER_NAME;
    sleep 5m;
done

echo "Proxified nodes:"
oc get nodes -l crio-proxified=true

rm -rf terraform.tfvars
  BASH
                 
}

##############################################################################


##############################################################################
# Provision Floating IP for Linux VSI
##############################################################################

resource ibm_is_floating_ip linux_vsi_fip {
  name   = "${var.unique_id}-vsi-nlb-proxy-fip"
  target = ibm_is_instance.linux_vsi.primary_network_interface.0.id
}

##############################################################################