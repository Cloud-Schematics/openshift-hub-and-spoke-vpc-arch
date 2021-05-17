##############################################################################
# This bash script is to install the IBM Cloud CLI, kubectl cli, openshift CLI
# and terraform. Then it will run a simple terraform script to create an NLB
# proxy inside the VSI.
##############################################################################

#!/bin/bash

IBMCLOUD_API_KEY=$1
IBM_REGION=$2
RESOURCE_GROUP=$3
CLUSTER_NAME=$4
PORT=$5

# Install Kubectl CLI
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
rm -rf kubectl kubectl.sha256 

# Install IBM Cloud CLI
curl -sL https://raw.githubusercontent.com/IBM-Cloud/ibm-cloud-developer-tools/master/linux-installer/idt-installer | bash
ibmcloud plugin install kubernetes-service

# Install OpenShift CLI
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.5/openshift-client-linux-4.5.38.tar.gz
tar xvzf openshift-client-linux-4.5.38.tar.gz 
mv oc /usr/local/bin

# Install Terraform 
wget https://releases.hashicorp.com/terraform/0.13.6/terraform_0.13.6_linux_amd64.zip
unzip terraform_0.13.6_linux_amd64.zip
chmod +x terraform
rm -rf terraform_0.13.6_linux_amd64.zip

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

##############################################################################' > nlb.tf

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

##############################################################################' > providers.tf


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

##############################################################################' > variables.tf

# Create Environment variables
echo '
ibmcloud_api_key="'$IBMCLOUD_API_KEY'"
ibm_region="'$IBM_REGION'"
resource_group="'$RESOURCE_GROUP'"
cluster_name="'$CLUSTER_NAME'"
private_service_endpoint_port="'$PORT'"
' > terraform.tfvars

# Execute Terraform
terraform init
terraform plan
echo "yes" | terraform apply