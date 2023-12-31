# configuration values for the MIW+Keycloak Postgres db
variable "keycloak-database" {
  default = "keycloak"
}
variable "keycloak-db-user" {
  default = "keycloak_user"
}
variable "miw-database" {
  default = "miw"
}
variable "miw-db-user" {
  default = "miw_user"
}
variable "postgres-port" {
  default = 5432
}

variable "keycloak-port" {
  default = 8080
}

variable "miw-api-port" {
  default = 8000
}

variable "miw-bpn" {
  default = "BPNL000000000000"
}

variable "alice-bpn" {
  default = "BPNL000000000001"
}

variable "bob-bpn" {
  default = "BPNL000000000002"
}