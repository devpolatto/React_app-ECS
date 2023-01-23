variable "common_tags" {
  type = map(any)
  default = {
    ENV           = "lab"
    LABID = ""
    ALIAS_PROJECT = "Depoy React App in AWS ECS"
    MANAGED_BY    = "Terraform"
  }
}