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

##############################################################################