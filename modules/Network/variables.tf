###############################
#collecting AZ info for region#
###############################
  data "aws_availability_zones" "available" {
    state = "available"  
}