# technically, the Helm chart for the connector already brings a Kubernetes service, but there is no
# (easy) way to get a hold of it from terraform, so lets just declare another one

resource "kubernetes_service" "controlplane-service" {
  metadata {
    name = "${var.humanReadableName}-controlplane"
  }
  spec {
    type = "NodePort"
    selector = {
      "app.kubernetes.io/instance" = "${var.humanReadableName}-controlplane"
      "app.kubernetes.io/name"     = "tractusx-connector-controlplane"
    }
    port {
      name = "management"
      port = 8081
    }
    port {
      name = "health"
      port = 8080
    }
    port {
      name = "protocol"
      port = 8084
    }
    port {
      name = "debug"
      port = 1044
    }
  }
}