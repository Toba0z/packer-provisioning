packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name          = var.ami_name
  instance_type     = var.instance_type
  region            = var.region
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id

  source_ami_filter {
    filters     = var.ami_filters
    most_recent = true
    owners      = var.ami_owners
  }

  ssh_username = var.ssh_username
}

build {
  name = "Toba0z-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Update the system
  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  # # Copy web app files to the instance
  # provisioner "file" {
  #   source      = "assets"
  #   destination = "/tmp/"
  # }

  # # Run setup script to install web app
  # provisioner "shell" {
  #   inline = [
  #     "chmod +x /tmp/assets/setup-web.sh",
  #     "sudo sh /tmp/assets/setup-web.sh"
  #   ]
  # }
}
