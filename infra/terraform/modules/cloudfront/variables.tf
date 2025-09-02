variable "origin_bucket_domain_name" {
  type = string
}

variable "alternative_domain_names" {
  type    = list(string)
  default = []
}
