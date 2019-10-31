Basic infrastructure setup for AWS.
1x Bastion Host
2x NAT with the different AZ
2x servers for nginx with public EIPs
2x servers for web-apps with traffic routing via NAT
2x servers for DB with traffic routing via NAT
