ami_name           = "toba0z3030-webapp-ami"
instance_type      = "t2.micro"
region             = "us-west-2"

vpc_id             = "vpc-09f38f53cfaff68c9"
subnet_id          = "subnet-0a34ef422985f9388" 
security_group_id  = "sg-0e8f16862cbe8c1b2"

ssh_username       = "ubuntu"

ami_filters = {
  name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  virtualization-type = "hvm"
  root-device-type    = "ebs"
}

ami_owners = ["099720109477"] # Canonical (Ubuntu)
