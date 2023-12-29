terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    // for generating passwords, clientsecrets etc.
    random = {
      source = "hashicorp/random"
    }

    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.3.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# First connector
module "alice-connector" {
  source            = "./modules/connector"
  humanReadableName = "alice"
  participantId     = var.alice-bpn
  database-host     = local.pg-ip
  database-name     = "alice"
  database-credentials = {
    user     = "postgres"
    password = "postgres"
  }
  ssi-config = {
    miw-url            = "http://${kubernetes_service.miw.metadata.0.name}:${var.miw-api-port}"
    miw-authorityId    = var.miw-bpn
    oauth-tokenUrl     = "http://${kubernetes_service.keycloak.metadata.0.name}:${var.keycloak-port}/realms/miw_test/protocol/openid-connect/token"
    oauth-clientid     = "alice_private_client"
    oauth-secretalias  = "client_secret_alias"
    oauth-clientsecret = "alice_private_client"
  }
}

# Second connector
module "bob-connector" {
  source            = "./modules/connector"
  humanReadableName = "bob"
  participantId     = var.bob-bpn
  database-host     = local.pg-ip
  database-name     = "bob"
  database-credentials = {
    user     = "postgres"
    password = "postgres"
  }
  ssi-config = {
    miw-url            = "http://${kubernetes_service.miw.metadata.0.name}:${var.miw-api-port}"
    miw-authorityId    = var.miw-bpn
    oauth-tokenUrl     = "http://${kubernetes_service.keycloak.metadata.0.name}:${var.keycloak-port}/realms/miw_test/protocol/openid-connect/token"
    oauth-clientid     = "bob_private_client"
    oauth-secretalias  = "client_secret_alias"
    oauth-clientsecret = "bob_private_client"
  }
}