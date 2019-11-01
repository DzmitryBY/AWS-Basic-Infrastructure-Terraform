terraform {
    required_version = ">= 0.12"
}
##############
#Creating VPC#
##############

resource "aws_vpc" "practice_vpc" {
    cidr_block = "192.168.40.0/24"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"

    tags = {
        Name = "Terraform practice VPC"
    }
}

##############
#Creating iGW#
##############
resource "aws_internet_gateway" "practice-IGW" {
    vpc_id = "${aws_vpc.practice_vpc.id}"
    tags = {
        Name = "IGW Practice"
    }  
}

######################
#Creating Route Table#
######################

resource "aws_route_table" "practice-public-routeTBL" {
  vpc_id = "${aws_vpc.practice_vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"

      gateway_id = "${aws_internet_gateway.practice-IGW.id}"
  }

  tags = {
      Name = "Route TBL Public Practice"
  }
}

##################
#Creating Subnets#
##################

###############
#Public ranges#
###############
resource "aws_subnet" "practice-subnet-public-1" {
    vpc_id = "${aws_vpc.practice_vpc.id}"
    cidr_block = "192.168.40.0/28"
    map_public_ip_on_launch = "true"
    availability_zone = "${data.aws_availability_zones.available.names[0]}"
    tags = {
      Name = "Public Subnet AZ1"
    }
}
resource "aws_subnet" "practice-subnet-public-2" {
    vpc_id = "${aws_vpc.practice_vpc.id}"
    cidr_block = "192.168.40.16/28"
    map_public_ip_on_launch = "true"
    availability_zone = "${data.aws_availability_zones.available.names[1]}"
    tags = {
      Name = "Public Subnet AZ2"
    }
}
#############################
#Private ranges  for backend#
#############################
resource "aws_subnet" "practice-subnet-privatebackend-1" {
  vpc_id = "${aws_vpc.practice_vpc.id}"
  cidr_block = "192.168.40.32/28"
  map_public_ip_on_launch = "false"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "Private backend AZ1"
  }
}


resource "aws_subnet" "practice-subnet-privatebackend-2" {
  vpc_id = "${aws_vpc.practice_vpc.id}"
  cidr_block = "192.168.40.48/28"
  map_public_ip_on_launch = "false"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "Private backed AZ2"
  }
}
#######################
#private ranges for DB#
#######################
resource "aws_subnet" "practice-subnet-privateDB-1" {
  vpc_id = "${aws_vpc.practice_vpc.id}"
  cidr_block = "192.168.40.64/28"
  map_public_ip_on_launch = "false"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "Private DB AZ1"
  }
}

resource "aws_subnet" "practice-subnet-privateDB-2" {
  vpc_id = "${aws_vpc.practice_vpc.id}"
  cidr_block = "192.168.40.80/28"
  map_public_ip_on_launch = "false"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "Private DB AZ2"
  }
}

#################################################
#attaching RouteTable to public tables in two AZ#
#################################################
resource "aws_route_table_association" "practice-route-table-subnet-association-1" {
  subnet_id = "${aws_subnet.practice-subnet-public-1.id}"
  route_table_id = "${aws_route_table.practice-public-routeTBL.id}"  
}

resource "aws_route_table_association" "practice-route-table-subnet-association-2" {
  subnet_id = "${aws_subnet.practice-subnet-public-2.id}"
  route_table_id = "${aws_route_table.practice-public-routeTBL.id}"  
}




##########################
#Creating Security Groups#
##########################

resource "aws_security_group" "ssh-access-sec" {
    vpc_id = "${aws_vpc.practice_vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    } 
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["82.209.242.83/32", "86.57.156.77/32"]
    }
    tags = {
        Name = "Practice ssh access Sec"
    }
}
resource "aws_security_group" "web-access-sec" {
    vpc_id = "${aws_vpc.practice_vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    } 
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Practice Web access Sec"
    }
}

resource "aws_security_group" "db-access-sec" {
    vpc_id = "${aws_vpc.practice_vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["192.168.40.0/24"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["192.168.40.0/24"]
    }  

    tags = {
      Name = "DB internal security group"
    }
}

resource "aws_security_group" "default-practice-access-sec" {
    vpc_id = "${aws_vpc.practice_vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    } 
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["192.168.40.0/24"]
    }
    tags = {
        Name = "Default internal Sec Group"
    } 
}