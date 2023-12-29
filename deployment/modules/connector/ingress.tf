resource "kubernetes_ingress_v1" "mxd-ingress" {
  metadata {
    name = "${var.humanReadableName}-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/${var.humanReadableName}(/|$)(.*)"
          backend {
            service {
              name = local.control-plane-service
              port {
                number = 8081
              }
            }
          }
        }
        path {
          path = "/${var.humanReadableName}/health(/|$)(.*)"
          backend {
            service {
              name = local.control-plane-service
              port {
                number = 8080
              }
            }
          }
        }
        path {
          path = "/${var.humanReadableName}(/|$)(proxy/.*)"
          backend {
            service {
              name = local.data-plane-service
              port {
                number = 8186
              }
            }
          }
        }
        path {
          path = "/${var.humanReadableName}(/|$)(api/public.*)"
          backend {
            service {
              name = local.data-plane-service
              port {
                number = 8081
              }
            }
          }
        }
      }
    }
  }
}

locals {
  control-plane-service = "${var.humanReadableName}-tractusx-connector-controlplane"
  data-plane-service    = "${var.humanReadableName}-tractusx-connector-dataplane"
  management_url        = "http://localhost/${var.humanReadableName}/management/v2"
  proxy_url             = "http://localhost/${var.humanReadableName}/proxy"
  health_url            = "http://localhost/${var.humanReadableName}/health"
  public_url            = "http://localhost/${var.humanReadableName}/api/public"
}