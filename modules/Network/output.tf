####################
#Output for VPC IDs#
#####################

output "practice-vpc-id" {
  value = "${aws_vpc.practice_vpc.id}"
}


########################
#Outputs for subnet IDs#
########################
output "practice-subnet-public-1-id" {
  value = "${aws_subnet.practice-subnet-public-1.id}"
}

output "practice-subnet-public-2-id" {
  value = "${aws_subnet.practice-subnet-public-2.id}"
}

output "practice-subnet-privatebackend-1-id" {
  value = "${aws_subnet.practice-subnet-privatebackend-1.id}"
}

output "practice-subnet-privatebackend-2-id" {
  value = "${aws_subnet.practice-subnet-privatebackend-2.id}"
}

output "practice-subnet-privatedb-1-id" {
  value = "${aws_subnet.practice-subnet-privateDB-1.id}"
}

output "practice-subnet-privatedb-2-id" {
  value = "${aws_subnet.practice-subnet-privateDB-2.id}"
}

######################
#Outputs for AZ naems#
######################
output "availability-zone-1" {
  value = "${data.aws_availability_zones.available.names[0]}"
}

output "availability-zone-2" {
  value = "${data.aws_availability_zones.available.names[1]}"
}

############################
#Outputs for Sec Groups IDs#
############################
output "default-access-sec-id" {
  value = "${aws_security_group.default-practice-access-sec.id}"
}
output "ssh-access-sec-id" {
  value = "${aws_security_group.ssh-access-sec.id}"
}

output "web-access-sec-id" {
  value = "${aws_security_group.web-access-sec.id}"
}
output "db-access-sec-id" {
  value = "${aws_security_group.db-access-sec.id}"
}