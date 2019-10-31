### Terraform testing varaiables.
### Upd. 10/30/2019
### Dzmitry Kozynda

variable "instanceType" {
    description = "Tyoe of instance to run EC2"
    type = string
    default = "t2.micro"
    }

variable "amiDefault" {
  description = "AMI ID"
  type = string
  default = "ami-00aa4671cbf840d82"  
}

variable "natAMI" {
  description = "NAT AMI ID"
  type = string
  default = "ami-001b36cbc16911c13"  
}

variable "bastionAMI" {
  description = "Bastion AMI ID"
  type = string
  default = "ami-00aa4671cbf840d82"  
}

variable "keyName" {
  description = "SSH key name for logging"
  type = string
  default = "access"
}


#variable "clusterName" {
#  description = "Name for all resources under the cluster"
#  type = string
#}

variable "minSize" {
    description = "The minimal size for scaling"
    type = number
    default = 1  
}

variable "maxSize" {
  description = "The maximum size for scaling"
  type = number
  default = 1
}

variable "httpPort" {
  description = "Port on EC2 server for HTTP requests"
  type = number
  default = 80
}
variable "elbHttpPort" {
    description = "Port on ELB to server HTTP requests"
    type = number
    default = 80
}