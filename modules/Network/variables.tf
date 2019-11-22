###############################
#collecting AZ info for region#
###############################

variable "def_tags" {
  type = "map"
  default = {
    "coherent:client" : "Coherent"
    "coherent:environment" : "Sandbox",
    "coherent:owner" : "dmitrykozynda@coherentsolutions.com",
    "coherent:project" : "TC - DevOps"
  }
}
  data "aws_availability_zones" "available" {
    state = "available"  
}