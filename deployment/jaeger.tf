resource "kubernetes_deployment" "jaeger" {
  metadata {
    name = "jaeger"
    labels = {
      App = "jaeger"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "jaeger"
      }
    }
    template {
      metadata {
        labels = {
          App = "jaeger"
        }
      }
      spec {
        container {
          image = "jaegertracing/all-in-one:1.52"
          name  = "jaeger-all-in-one"

          # Ports
          port {
            container_port = 5775
            protocol       = "UDP"
          }
          port {
            container_port = 6831
            protocol       = "UDP"
          }
          port {
            container_port = 6832
            protocol       = "UDP"
          }
          port {
            container_port = 5778
          }
          port {
            container_port = 16686
            name           = "jaeger-ui"
          }
          port {
            container_port = 14250
          }
          port {
            container_port = 14268
          }
          port {
            container_port = 14269
          }
          port {
            container_port = 4317
          }
          port {
            container_port = 4318
          }
          port {
            container_port = 9411
          }

          #   volume_mount {
          #     mount_path = "/opt/keycloak/data/import/"
          #     name       = "miw-test-realm"
          #   }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.jaeger_env.metadata[0].name
            }
          }
        }
        # volume {
        #   name = "miw-test-realm"
        #   config_map {
        #     name = kubernetes_config_map.keycloak-realm.metadata.0.name
        #   }
        # }
      }
    }
  }
}

resource "kubernetes_config_map" "jaeger_env" {
  metadata {
    name = "jaeger-env"
  }
  data = {
    COLLECTOR_OTLP_ENABLED     = "true"
    COLLECTOR_ZIPKIN_HOST_PORT = ":9411"
    QUERY_BASE_PATH            = "/jaeger"
  }
}

resource "kubernetes_service" "jaeger" {
  metadata {
    name = "jaeger"
  }
  spec {
    selector = {
      App = kubernetes_deployment.jaeger.spec.0.template.0.metadata[0].labels.App
    }

    port {
      name        = "jaeger-ui"
      port        = 16686
      target_port = 16686
    }
    port {
      name        = "zipkin-thrift"
      protocol    = "UDP"
      port        = 5775
      target_port = 5775
    }
    port {
      name        = "jaeger-thrift-compact"
      protocol    = "UDP"
      port        = 6831
      target_port = 6831
    }
    port {
      name        = "jaeger-thrift-binary"
      protocol    = "UDP"
      port        = 6832
      target_port = 6832
    }
    port {
      name        = "jaeger-sampling"
      port        = 5778
      target_port = 5778
    }
    port {
      name        = "jaeger-grpc"
      port        = 14250
      target_port = 14250
    }
    port {
      name        = "http-sampling"
      port        = 14268
      target_port = 14268
    }
    port {
      name        = "http"
      port        = 14269
      target_port = 14269
    }
    port {
      name        = "otlp-grpc"
      port        = 4317
      target_port = 4317
    }
    port {
      name        = "otlp-http"
      port        = 4318
      target_port = 4318
    }
    port {
      name        = "zipkin-spans"
      port        = 9411
      target_port = 9411
    }
  }
}

resource "kubernetes_ingress_v1" "jaeger-ingress" {
  metadata {
    name = "jaeger-ingress"
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
          path      = "/jaeger(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.jaeger.metadata.0.name
              port {
                number = 16686
              }
            }
          }
        }
      }
    }
  }
}