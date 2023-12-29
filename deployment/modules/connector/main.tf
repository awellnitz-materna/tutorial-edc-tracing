resource "helm_release" "connector" {
  name              = lower(var.humanReadableName)
  force_update      = true
  dependency_update = true
  reuse_values      = true
  cleanup_on_fail   = true
  replace           = true

  repository = "https://eclipse-tractusx.github.io/charts/dev"
  chart      = "tractusx-connector"

  values = [
    file("${path.module}/values.yaml"),
    # dynamically set the vault secrets
    yamlencode({
      "vault" : {
        "server" : {
          "postStart" : [
            "sh",
            "-c",
            "sleep 5 && /bin/vault kv put secret/client-secret content=${local.client_secret} && /bin/vault kv put secret/aes-keys content=${local.aes_key_b64} && /bin/vault kv put secret/${var.ssi-config.oauth-secretalias} content=${var.ssi-config.oauth-clientsecret}"
          ]
        }
      }
    }),
    yamlencode({
      controlplane : {
        env : {
          "TX_SSI_ENDPOINT_AUDIENCE" : "http://${kubernetes_service.controlplane-service.metadata.0.name}:8084/api/v1/dsp"
          "EDC_DSP_CALLBACK_ADDRESS" : "http://${kubernetes_service.controlplane-service.metadata.0.name}:8084/api/v1/dsp"
          "APPLICATIONINSIGHTS_CONNECTION_STRING": "http://jaeger:14268/api/traces"
          "APPLICATIONINSIGHTS_ROLE_NAME": "${lower(var.humanReadableName)}-controlplane"
          "APPLICATIONINSIGHTS_INSTRUMENTATION_LOGGING_LEVEL": "DEBUG"
          "OTEL_SERVICE_NAME": "${lower(var.humanReadableName)}-controlplane"
          "OTEL_TRACES_EXPORTER": "jaeger"
          "OTEL_EXPORTER_JAEGER_ENDPOINT": "http://jaeger:14250"
          "OTEL_METRICS_EXPORTER": "prometheus"
        }
        ssi : {
          miw : {
            url : var.ssi-config.miw-url
            authorityId : var.ssi-config.miw-authorityId
          }
          oauth : {
            tokenurl : var.ssi-config.oauth-tokenUrl
            client : {
              id : var.ssi-config.oauth-clientid
              secretAlias : var.ssi-config.oauth-secretalias
            }
          }
        }
      }
      dataplane: {
        env: {
          "APPLICATIONINSIGHTS_CONNECTION_STRING": "http://jaeger:14268/api/traces"
          "APPLICATIONINSIGHTS_ROLE_NAME": "${lower(var.humanReadableName)}-dataplane"
          "APPLICATIONINSIGHTS_INSTRUMENTATION_LOGGING_LEVEL": "DEBUG"
          "OTEL_SERVICE_NAME": "${lower(var.humanReadableName)}-dataplane"
          "EDC_API_AUTH_KEY" : "password"
          "OTEL_TRACES_EXPORTER": "jaeger"
          "OTEL_EXPORTER_JAEGER_ENDPOINT": "http://jaeger:14250"
          "OTEL_METRICS_EXPORTER": "prometheus"
        }
      }
    })
  ]
  set {
    name  = "participant.id"
    value = var.participantId
  }

  set {
    name  = "controlplane.image.pullPolicy"
    value = var.image-pull-policy
  }

  set {
    name  = "dataplane.image.pullPolicy"
    value = var.image-pull-policy
  }

  set {
    name  = "postgresql.jdbcUrl"
    value = local.jdbcUrl
  }

  set {
    name  = "postgresql.auth.username"
    value = var.database-credentials.user
  }

  set {
    name  = "postgresql.auth.password"
    value = var.database-credentials.password
  }
  // we'll use a central postgres
  set {
    name  = "install.postgresql"
    value = "false"
  }

}

resource "random_string" "kc_client_secret" {
  length = 16
}

resource "random_string" "aes_key_raw" {
  length = 16
}

locals {
  aes_key_b64   = base64encode(random_string.aes_key_raw.result)
  client_secret = base64encode(random_string.kc_client_secret.result)
  jdbcUrl       = "jdbc:postgresql://${var.database-host}:${var.database-port}/${var.database-name}"
}