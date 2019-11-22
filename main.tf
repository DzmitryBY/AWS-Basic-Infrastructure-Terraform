terraform {
    required_version = ">= 0.12"
}

provider "aws" {
    region = "eu-central-1"
}

module "Network" {
  source = "./modules/Network/"
  
}

#######################
#Creating NAT instance#
#######################

resource "aws_instance" "NAT" {
    instance_type = "${var.instanceType}"
    ami = "${var.natAMI}"
    availability_zone = "${module.Network.availability-zone-1}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-public-1-id}"
    source_dest_check = false
    associate_public_ip_address = true
    depends_on = ["module.Network"]
    user_data = file("./files/configure-nat.sh")
/*    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo sh /usr/sbin/configure-pat.sh",
            "cat  /etc/sysctl.d/10-nat-settings.conf"
        ]
    }
*/
    tags = merge(map("Name", "NAT AZ1 instance"), var.def_tags)
}

resource "aws_instance" "NAT-2" {
    instance_type = "${var.instanceType}"
    ami = "${var.natAMI}"
    availability_zone = "${module.Network.availability-zone-2}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-public-2-id}"
    source_dest_check = false
    associate_public_ip_address = true
    depends_on = ["module.Network"]
    user_data = file("./files/configure-nat.sh")
    tags = {
        Name = "NAT AZ2 instance"
    }
}

########################################
#Creating NAT routing for new instances#
########################################

resource "aws_route_table" "practice-private-routeTBL-1" {
    vpc_id = "${module.Network.practice-vpc-id}"
    depends_on = ["aws_instance.NAT"]

    route {
        cidr_block = "0.0.0.0/0"

        instance_id = "${aws_instance.NAT.id}"
    }
  
}

resource "aws_route_table" "practice-private-routeTBL-2" {
    vpc_id = "${module.Network.practice-vpc-id}"
    depends_on = ["aws_instance.NAT-2"]

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.NAT-2.id}"
    }
  
}

resource "aws_route_table_association" "pivatebackend-route-table-subnet-association-1" {
  subnet_id = "${module.Network.practice-subnet-privatebackend-1-id}"
  route_table_id = "${aws_route_table.practice-private-routeTBL-1.id}"  
}

resource "aws_route_table_association" "pivatebackend-route-table-subnet-association-2" {
  subnet_id = "${module.Network.practice-subnet-privatebackend-2-id}"
  route_table_id = "${aws_route_table.practice-private-routeTBL-2.id}"  
}


resource "aws_route_table_association" "pivateDB-route-table-subnet-association-1" {
  subnet_id = "${module.Network.practice-subnet-privatedb-1-id}"
  route_table_id = "${aws_route_table.practice-private-routeTBL-1.id}"  
}

resource "aws_route_table_association" "pivateDB-route-table-subnet-association-2" {
  subnet_id = "${module.Network.practice-subnet-privatedb-2-id}"
  route_table_id = "${aws_route_table.practice-private-routeTBL-2.id}"  
}

###########################
#Creating Bastion Instance#
###########################
resource "aws_instance" "Bastion" {
    instance_type = "${var.instanceType}"
    ami = "${var.bastionAMI}"
    availability_zone = "${module.Network.availability-zone-1}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.ssh-access-sec-id}", "${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-public-1-id}"
    associate_public_ip_address = true
    depends_on = ["module.Network"]

    tags = {
        Name = "Bastion Host Terra"
    }
}
/*
resource "aws_instance" "Bastion" {
    instance_type = "${var.instanceType}"
    ami = "${var.bastionAMI}"
    availability_zone = "${module.Network.availability-zone-2}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.ssh-access-sec-id}", "${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-public-2-id}"
    associate_public_ip_address = true
    depends_on = ["module.Network"]

    tags = {
        Name = "Bastion Host Terra"
    }
}
*/
#########################
#Creating NGINX instance#
#########################
resource "aws_instance" "Nginx" {
    instance_type = "${var.instanceType}"
    ami = "${var.amiDefault}"
    availability_zone = "${module.Network.availability-zone-1}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.web-access-sec-id}", "${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-public-1-id}"
    depends_on = ["module.Network"]
/*    provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install docker",
      "sudo systemctl start docker",
      "sudo usermod -a -G docker ec2-user"
    ]
  }
*/
    tags = {
        Name = "Nginx AZ1 LB"
    }
}

resource "aws_instance" "Nginx-2" {
    instance_type = "${var.instanceType}"
    ami = "${var.amiDefault}"
    availability_zone = "${module.Network.availability-zone-2}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.web-access-sec-id}", "${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-public-2-id}"
    depends_on = ["module.Network"]
    tags = {
        Name = "Nginx AZ2 LB"
    }
}

################################
#Attaching Elastic IPs to NGINX#
################################
resource "aws_eip" "nginx-1" {
    depends_on = ["aws_instance.Nginx"]
    instance = "${aws_instance.Nginx.id}"
    vpc = true

    tags = {
        Name = "Nginx AZ1 ElasticIP"
    }
}

resource "aws_eip" "nginx-2" {
    depends_on = ["aws_instance.Nginx-2"]
    instance = "${aws_instance.Nginx-2.id}"
    vpc = true

    tags = {
        Name = "Nginx AZ2 ElasticIP"
    }
}


#################################
#Attaching Elastic IP to Bastion#
#################################

resource "aws_eip" "bastion" {
    depends_on = ["aws_instance.Bastion"]
    instance = "${aws_instance.Bastion.id}"
    vpc = true

    tags = {
        Name = "Bastion ElasticIP"
    } 
}



#############################
#Creating web data instances#
#############################

resource "aws_instance" "web-data-1" {
    instance_type = "${var.instanceType}"
    ami = "${var.amiDefault}"
    availability_zone = "${module.Network.availability-zone-1}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-privatebackend-1-id}"
    associate_public_ip_address = false

    tags = {
        Name = "Web Backend AZ1"
    }
}

resource "aws_instance" "web-data-2" {
    instance_type = "${var.instanceType}"
    ami = "${var.amiDefault}"
    availability_zone = "${module.Network.availability-zone-2}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.default-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-privatebackend-2-id}"
    associate_public_ip_address = false
    tags = {
        Name = "Web Backend AZ2"
    }
}

#######################
#Creating DB instances#
#######################

resource "aws_instance" "db-1" {
    instance_type = "${var.instanceType}"
    ami = "${var.amiDefault}"
    availability_zone = "${module.Network.availability-zone-1}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.db-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-privatedb-1-id}"
    associate_public_ip_address = false
    tags = {
        Name = "DB AZ1"
    }
}

resource "aws_instance" "db-2" {
    instance_type = "${var.instanceType}"
    ami = "${var.amiDefault}"
    availability_zone = "${module.Network.availability-zone-2}"
    key_name = "${var.keyName}"
    vpc_security_group_ids = ["${module.Network.db-access-sec-id}"]
    subnet_id = "${module.Network.practice-subnet-privatedb-2-id}"
    associate_public_ip_address = false
    tags = {
        Name = "DB AZ2"
    }
}

#######################
#Creating Route53 zone#
#######################

resource "aws_route53_zone" "bastion" {
    name = "bastion.kozynda.com"  
}


############################################
#Attaching route53 to point to bastion host#
############################################

resource "aws_route53_record" "www-bastion" {
  depends_on = ["aws_eip.bastion"]
  zone_id = "${aws_route53_zone.bastion.zone_id}"
  name = "bastion.kozynda.com"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.Bastion.public_ip}"]
}
