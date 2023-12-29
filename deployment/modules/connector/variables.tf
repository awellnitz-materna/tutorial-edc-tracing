variable "image-pull-policy" {
  default     = "Always"
  type        = string
  description = "Kubernetes ImagePullPolicy for all images"
}

variable "humanReadableName" {
  type        = string
  description = "Human readable name of the connector, NOT the BPN!!. Required."
}

variable "participantId" {
  type        = string
  description = "Participant ID of the connector. In Catena-X, this MUST be the BPN"
}

variable "database-host" {
  description = "IP address (ClusterIP) or host name of the postgres database host"

}
variable "database-port" {
  default     = 5432
  description = "Port where the Postgres database is reachable, defaults to 5432."
}

variable "database-name" {
  description = "Name for the Postgres database. Cannot contain special characters"
}

variable "database-credentials" {
  default = {
    user     = "postgres"
    password = "password"
  }
}

variable "ssi-config" {
  default = {
    miw-url            = ""
    miw-authorityId    = ""
    oauth-tokenUrl     = ""
    oauth-clientid     = ""
    oauth-clientsecret = ""
    oauth-secretalias  = ""
  }
}