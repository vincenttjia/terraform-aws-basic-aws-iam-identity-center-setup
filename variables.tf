variable "users" {
  type = list(
    object(
      {
        email       = string
        given_name  = string
        family_name = string
      }
    )
  )
}

variable "default_aws_region" {
  type        = string
  default     = ""
  description = "value"
}

variable "default_session_duration" {
  type        = string
  default     = "1H"
  description = "value"
}

variable "super_admins" {
  type    = list(string)
  default = []
}

variable "power_users" {
  type    = list(string)
  default = []
}

variable "readonly_users" {
  type    = list(string)
  default = []
}
