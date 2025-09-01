## How to run the project
- packer init .
- packer fmt -var-file="variables.pkrvars.hcl" .
- packer validate -var-file="variables.pkrvars.hcl" .
- packer build -var-file="variables.pkrvars.hcl" .
---

# Part1 : Write a Packer Template
 Walk through updating a Packer HCL Template. It uses the amazon-ebs source to create a custom image in the us-west-2 region of AWS.

- Task 1: Create a Source Block
- Task 2: Validate the Packer Template
- Task 3: Create a Builder Block
- Task 4: Build a new Image using Packer

## Creating a Packer Template

```bash
mkdir packer_templates
cd packer_templates
```

### Task 1: Create a Source Block
Source blocks define what kind of virtualization to use for the image, how to launch the image and how to connect to the image.  Sources can be used across multiple builds.  We will use the `amazon-ebs` source configuration to launch a `t3.micro` AMI in the `us-west-2` region.

### Step 1.1.1

Create a `aws-ubuntu.pkr.hcl` file with the following Packer `source` block and `required_plugins`.

```hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
```

### Step 1.1.2
The `packer init` command is used to download Packer plugin binaries. This is the first command that should be executed when working with a new or existing template. This command is always safe to run multiple times.

```shell
packer init aws-ubuntu.pkr.hcl
```

### Task 2: Validate the Packer Template
Packer templates can be auto formatted and validated via the Packer command line.

### Step 2.1.1

Format and validate your configuration using the `packer fmt` and `packer validate` commands.

```shell
packer fmt aws-ubuntu.pkr.hcl 
packer validate aws-ubuntu.pkr.hcl
```

### Task 3: Create a Builder Block
Builders are responsible for creating machines and generating images from them for various platforms.  They are use in tandem with the source block within a template.

### Step 3.1.1
Add a builder block to `aws-ubuntu.pkr.hcl` referencing the source specified above.  The source can be referenced usin the HCL interpolation syntax.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}
```

### Task 4: Build a new Image using Packer
The `packer build` command is used to initiate the image build process for a given Packer template. For this lab, please note that you will need credentials for your AWS account in order to properly execute a `packer build`. You can set your credentials using [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#linux), using [aws configure](https://docs.aws.amazon.com/cli/latest/reference/configure/) if you have the AWSCLI installed, or [embed the credentials](https://www.packer.io/docs/builders/amazon/ebsvolume#access-configuration) in the template.

> Example using environment variables on a Linux or macOS:

```shell
export AWS_ACCESS_KEY_ID=<your access key>
export AWS_SECRET_ACCESS_KEY=<your secret key>
export AWS_DEFAULT_REGION=us-west-2
```

> Example via Powershell:

```pwsh
PS C:\> $Env:AWS_ACCESS_KEY_ID="<your access key>"
PS C:\> $Env:AWS_SECRET_ACCESS_KEY="<your secret key>"
PS C:\> $Env:AWS_DEFAULT_REGION="us-west-2"
```

### Step 4.1.1
Run a `packer build` for the `aws-ubuntu.pkr.hcl` template.

```shell
packer build aws-ubuntu.pkr.hcl
```

Packer will print output similar to what is shown below.

```bash
amazon-ebs.ubuntu: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: packer-ubuntu-aws-1620827902
    amazon-ebs.ubuntu: Found Image ID: ami-0dd273d94ed0540c0
==> amazon-ebs.ubuntu: Creating temporary keypair: packer_609bdefe-f179-a11c-3bfd-6f4deda66c99
==> amazon-ebs.ubuntu: Creating temporary security group for this instance: packer_609bdf00-c182-00a1-e516-32aea832ff9e
==> amazon-ebs.ubuntu: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs.ubuntu: Launching a source AWS instance...
==> amazon-ebs.ubuntu: Adding tags to source instance
    amazon-ebs.ubuntu: Adding tag: "Name": "Packer Builder"
    amazon-ebs.ubuntu: Instance ID: i-0c9a0b1b896b8c95a
==> amazon-ebs.ubuntu: Waiting for instance (i-0c9a0b1b896b8c95a) to become ready...
==> amazon-ebs.ubuntu: Using ssh communicator to connect: 34.219.135.12
==> amazon-ebs.ubuntu: Waiting for SSH to become available...
==> amazon-ebs.ubuntu: Connected to SSH!
==> amazon-ebs.ubuntu: Stopping the source instance...
    amazon-ebs.ubuntu: Stopping instance
==> amazon-ebs.ubuntu: Waiting for the instance to stop...
==> amazon-ebs.ubuntu: Creating AMI packer-ubuntu-aws-1620827902 from instance i-0c9a0b1b896b8c95a
    amazon-ebs.ubuntu: AMI: ami-0561bdc79bbb8f5a0
==> amazon-ebs.ubuntu: Waiting for AMI to become ready...
==> amazon-ebs.ubuntu: Terminating the source AWS instance...
==> amazon-ebs.ubuntu: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu: No volumes to clean up, skipping
==> amazon-ebs.ubuntu: Deleting temporary security group...
==> amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu' finished after 3 minutes 16 seconds.

==> Wait completed after 3 minutes 16 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
us-west-2: ami-0561bdc79bbb8f5a0
```

**Note:** This lab assumes you have the default VPC available in your account. If you do not, you will need to add the [`vpc_id`](https://www.packer.io/docs/builders/amazon/ebs#vpc_id) and [`subnet_id`](https://www.packer.io/docs/builders/amazon/ebs#subnet_id). The subnet will need to have public access and a valid route to an Internet Gateway.

##### Resources
* Packer [Docs](https://www.packer.io/docs/index.html)
* Packer [CLI](https://www.packer.io/docs/commands/index.html)
---

# Part 2: Packer Provisioners
Walk you through adding a provisioner to your Packer HCL Template. Provisioners use built-in and third-party software to install and configure the machine image after booting.

- Task 1: Add a Packer provisioner to install all updates and the nginx service
- Task 2: Validate the Packer Template
- Task 3: Build a new Image using Packer
- Task 4: Install Web App

### Task 1: Update Packer Template to support Multiple Regions
The Packer AWS builder supports the ability to create an AMI in multiple AWS regions.  AMIs are specific to regions so this will ensure that the same image is available in all regions within a single cloud.  We will also leverage Tags to indentify our image.

### Step 1.1.1

Validate that your `aws-ubuntu.pkr.hcl` file has the following Packer `source` block.

```hcl
source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-west-2"
  ami_regions   = ["us-west-2", "us-east-1", "eu-central-1"]
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name"        = "MyUbuntuImage"
    "Environment" = "Production"
    "OS_Version"  = "Ubuntu 22.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}
```

Add a provisioner to the `builder` block of your `aws-ubuntu.pkr.hcl`

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx"
    ]
  }
}
```

### Task 2: Validate the Packer Template
Packer templates can be auto formatted and validated via the Packer command line.

### Step 2.1.1

Format and validate your configuration using the `packer fmt` and `packer validate` commands.

```shell
packer fmt aws-ubuntu.pkr.hcl 
packer validate aws-ubuntu.pkr.hcl
```

### Task 3: Build a new Image using Packer
The `packer build` command is used to initiate the image build process for a given Packer template.

### Step 3.1.1
Run a `packer build` for the `aws-ubuntu.pkr.hcl` template.

```shell
packer build aws-ubuntu.pkr.hcl
```

Packer will print output similar to what is shown below.  Note the connection to SSH and the provisioning of the updtes and services before the image is finalized.

```bash
amazon-ebs.ubuntu: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: packer-ubuntu-aws-1620834314
    amazon-ebs.ubuntu: Found Image ID: ami-0dd273d94ed0540c0
==> amazon-ebs.ubuntu: Creating temporary keypair: packer_609bf80a-7759-bf2c-8ba3-91132538f80f
==> amazon-ebs.ubuntu: Creating temporary security group for this instance: packer_609bf80d-42af-bc1e-0e1f-e914806fb809
==> amazon-ebs.ubuntu: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs.ubuntu: Launching a source AWS instance...
==> amazon-ebs.ubuntu: Adding tags to source instance
    amazon-ebs.ubuntu: Adding tag: "Name": "Packer Builder"
    amazon-ebs.ubuntu: Instance ID: i-0348c8cc4584f902a
==> amazon-ebs.ubuntu: Waiting for instance (i-0348c8cc4584f902a) to become ready...
==> amazon-ebs.ubuntu: Using ssh communicator to connect: 52.33.179.108
==> amazon-ebs.ubuntu: Waiting for SSH to become available...
==> amazon-ebs.ubuntu: Connected to SSH!
==> amazon-ebs.ubuntu: Provisioning with shell script: /tmp/packer-shell794569831
    amazon-ebs.ubuntu: Installing Updates
    amazon-ebs.ubuntu: Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
    amazon-ebs.ubuntu: Get:2 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease [7515 B]
    amazon-ebs.ubuntu: Get:3 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [785 kB]
    amazon-ebs.ubuntu: Get:4 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease [7475 B]
    amazon-ebs.ubuntu: Hit:5 http://archive.ubuntu.com/ubuntu xenial InRelease
    amazon-ebs.ubuntu: Get:6 http://security.ubuntu.com/ubuntu xenial-security/universe Translation-en [225 kB]
    amazon-ebs.ubuntu: Get:7 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [7864 B]
    amazon-ebs.ubuntu: Get:8 http://security.ubuntu.com/ubuntu xenial-security/multiverse Translation-en [2672 B]
    amazon-ebs.ubuntu: Get:9 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [109 kB]
    amazon-ebs.ubuntu: Get:10 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security/main amd64 Packages [250 kB]
    amazon-ebs.ubuntu: Get:11 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [107 kB]
    amazon-ebs.ubuntu: Get:12 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [7532 kB]
    amazon-ebs.ubuntu: Get:13 http://archive.ubuntu.com/ubuntu xenial/universe Translation-en [4354 kB]
    amazon-ebs.ubuntu: Get:14 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [144 kB]
    amazon-ebs.ubuntu: Get:15 http://archive.ubuntu.com/ubuntu xenial/multiverse Translation-en [106 kB]
    amazon-ebs.ubuntu: Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 Packages [2049 kB]
    amazon-ebs.ubuntu: Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [1219 kB]
    amazon-ebs.ubuntu: Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/universe Translation-en [358 kB]
    amazon-ebs.ubuntu: Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [22.6 kB]
    amazon-ebs.ubuntu: Get:20 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse Translation-en [8476 B]
    amazon-ebs.ubuntu: Get:21 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [9812 B]
    amazon-ebs.ubuntu: Get:22 http://archive.ubuntu.com/ubuntu xenial-backports/main Translation-en [4456 B]
    amazon-ebs.ubuntu: Get:23 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [11.3 kB]
    amazon-ebs.ubuntu: Get:24 http://archive.ubuntu.com/ubuntu xenial-backports/universe Translation-en [4476 B]
    amazon-ebs.ubuntu: Fetched 17.4 MB in 7s (2273 kB/s)
    amazon-ebs.ubuntu: Reading package lists...
    amazon-ebs.ubuntu: Reading package lists...
    amazon-ebs.ubuntu: Building dependency tree...
    amazon-ebs.ubuntu: Reading state information...
    amazon-ebs.ubuntu: Calculating upgrade...
    amazon-ebs.ubuntu: The following packages will be upgraded:
    amazon-ebs.ubuntu:   ubuntu-advantage-tools
    amazon-ebs.ubuntu: 1 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    amazon-ebs.ubuntu: Need to get 703 kB of archives.
    amazon-ebs.ubuntu: After this operation, 60.4 kB of additional disk space will be used.
    amazon-ebs.ubuntu: Get:1 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 ubuntu-advantage-tools amd64 27.4.1~16.04.1 [703 kB]
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
==> amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Readline
==> amazon-ebs.ubuntu: debconf: (This frontend requires a controlling tty.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Teletype
==> amazon-ebs.ubuntu: dpkg-preconfigure: unable to re-open stdin:
    amazon-ebs.ubuntu: Fetched 703 kB in 0s (33.4 MB/s)
    amazon-ebs.ubuntu: (Reading database ... 51560 files and directories currently installed.)
    amazon-ebs.ubuntu: Preparing to unpack .../ubuntu-advantage-tools_27.4.1~16.04.1_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking ubuntu-advantage-tools (27.4.1~16.04.1) over (27.2.2~16.04.1) ...
    amazon-ebs.ubuntu: Processing triggers for man-db (2.7.5-1) ...
    amazon-ebs.ubuntu: Setting up ubuntu-advantage-tools (27.4.1~16.04.1) ...
    amazon-ebs.ubuntu: Installing new version of config file /etc/logrotate.d/ubuntu-advantage-tools ...
    amazon-ebs.ubuntu: Installing new version of config file /etc/ubuntu-advantage/help_data.yaml ...
    amazon-ebs.ubuntu: Installing new version of config file /etc/ubuntu-advantage/uaclient.conf ...
    amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
    amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
    amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
    amazon-ebs.ubuntu: Reading package lists...
    amazon-ebs.ubuntu: Building dependency tree...
    amazon-ebs.ubuntu: Reading state information...
    amazon-ebs.ubuntu: The following additional packages will be installed:
    amazon-ebs.ubuntu:   fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0
    amazon-ebs.ubuntu:   libjpeg-turbo8 libjpeg8 libtiff5 libvpx3 libxpm4 nginx-common nginx-core
    amazon-ebs.ubuntu: Suggested packages:
    amazon-ebs.ubuntu:   libgd-tools fcgiwrap nginx-doc ssl-cert
    amazon-ebs.ubuntu: The following NEW packages will be installed:
    amazon-ebs.ubuntu:   fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0
    amazon-ebs.ubuntu:   libjpeg-turbo8 libjpeg8 libtiff5 libvpx3 libxpm4 nginx nginx-common
    amazon-ebs.ubuntu:   nginx-core
    amazon-ebs.ubuntu: 0 upgraded, 13 newly installed, 0 to remove and 0 not upgraded.
    amazon-ebs.ubuntu: Need to get 2,860 kB of archives.
    amazon-ebs.ubuntu: After this operation, 9,315 kB of additional disk space will be used.
    amazon-ebs.ubuntu: Get:1 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 libjpeg-turbo8 amd64 1.4.2-0ubuntu3.4 [111 kB]
    amazon-ebs.ubuntu: Get:2 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial/main amd64 libjbig0 amd64 2.1-3.1 [26.6 kB]
    amazon-ebs.ubuntu: Get:3 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial/main amd64 fonts-dejavu-core all 2.35-1 [1,039 kB]
    amazon-ebs.ubuntu: Get:4 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 fontconfig-config all 2.11.94-0ubuntu1.1 [49.9 kB]
    amazon-ebs.ubuntu: Get:5 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 libfontconfig1 amd64 2.11.94-0ubuntu1.1 [131 kB]
    amazon-ebs.ubuntu: Get:6 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial/main amd64 libjpeg8 amd64 8c-2ubuntu8 [2,194 B]
    amazon-ebs.ubuntu: Get:7 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 libtiff5 amd64 4.0.6-1ubuntu0.8 [149 kB]
    amazon-ebs.ubuntu: Get:8 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 libvpx3 amd64 1.5.0-2ubuntu1.1 [732 kB]
    amazon-ebs.ubuntu: Get:9 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 libxpm4 amd64 1:3.5.11-1ubuntu0.16.04.1 [33.8 kB]
    amazon-ebs.ubuntu: Get:10 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 libgd3 amd64 2.1.1-4ubuntu0.16.04.12 [126 kB]
    amazon-ebs.ubuntu: Get:11 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 nginx-common all 1.10.3-0ubuntu0.16.04.5 [26.9 kB]
    amazon-ebs.ubuntu: Get:12 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 nginx-core amd64 1.10.3-0ubuntu0.16.04.5 [429 kB]
    amazon-ebs.ubuntu: Get:13 http://us-west-2.ec2.archive.ubuntu.com/ubuntu xenial-updates/main amd64 nginx all 1.10.3-0ubuntu0.16.04.5 [3,494 B]
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
==> amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Readline
    amazon-ebs.ubuntu: Fetched 2,860 kB in 0s (28.0 MB/s)
    amazon-ebs.ubuntu: Selecting previously unselected package libjpeg-turbo8:amd64.
==> amazon-ebs.ubuntu: debconf: (This frontend requires a controlling tty.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Teletype
==> amazon-ebs.ubuntu: dpkg-preconfigure: unable to re-open stdin:
    amazon-ebs.ubuntu: (Reading database ... 51574 files and directories currently installed.)
    amazon-ebs.ubuntu: Preparing to unpack .../libjpeg-turbo8_1.4.2-0ubuntu3.4_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libjpeg-turbo8:amd64 (1.4.2-0ubuntu3.4) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libjbig0:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../libjbig0_2.1-3.1_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libjbig0:amd64 (2.1-3.1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package fonts-dejavu-core.
    amazon-ebs.ubuntu: Preparing to unpack .../fonts-dejavu-core_2.35-1_all.deb ...
    amazon-ebs.ubuntu: Unpacking fonts-dejavu-core (2.35-1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package fontconfig-config.
    amazon-ebs.ubuntu: Preparing to unpack .../fontconfig-config_2.11.94-0ubuntu1.1_all.deb ...
    amazon-ebs.ubuntu: Unpacking fontconfig-config (2.11.94-0ubuntu1.1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libfontconfig1:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../libfontconfig1_2.11.94-0ubuntu1.1_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libfontconfig1:amd64 (2.11.94-0ubuntu1.1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libjpeg8:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../libjpeg8_8c-2ubuntu8_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libjpeg8:amd64 (8c-2ubuntu8) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libtiff5:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../libtiff5_4.0.6-1ubuntu0.8_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libtiff5:amd64 (4.0.6-1ubuntu0.8) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libvpx3:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../libvpx3_1.5.0-2ubuntu1.1_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libvpx3:amd64 (1.5.0-2ubuntu1.1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libxpm4:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../libxpm4_1%3a3.5.11-1ubuntu0.16.04.1_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libxpm4:amd64 (1:3.5.11-1ubuntu0.16.04.1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libgd3:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../libgd3_2.1.1-4ubuntu0.16.04.12_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libgd3:amd64 (2.1.1-4ubuntu0.16.04.12) ...
    amazon-ebs.ubuntu: Selecting previously unselected package nginx-common.
    amazon-ebs.ubuntu: Preparing to unpack .../nginx-common_1.10.3-0ubuntu0.16.04.5_all.deb ...
    amazon-ebs.ubuntu: Unpacking nginx-common (1.10.3-0ubuntu0.16.04.5) ...
    amazon-ebs.ubuntu: Selecting previously unselected package nginx-core.
    amazon-ebs.ubuntu: Preparing to unpack .../nginx-core_1.10.3-0ubuntu0.16.04.5_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking nginx-core (1.10.3-0ubuntu0.16.04.5) ...
    amazon-ebs.ubuntu: Selecting previously unselected package nginx.
    amazon-ebs.ubuntu: Preparing to unpack .../nginx_1.10.3-0ubuntu0.16.04.5_all.deb ...
    amazon-ebs.ubuntu: Unpacking nginx (1.10.3-0ubuntu0.16.04.5) ...
    amazon-ebs.ubuntu: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    amazon-ebs.ubuntu: Processing triggers for man-db (2.7.5-1) ...
    amazon-ebs.ubuntu: Processing triggers for ureadahead (0.100.0-19.1) ...
    amazon-ebs.ubuntu: Processing triggers for systemd (229-4ubuntu21.31) ...
    amazon-ebs.ubuntu: Processing triggers for ufw (0.35-0ubuntu2) ...
    amazon-ebs.ubuntu: Setting up libjpeg-turbo8:amd64 (1.4.2-0ubuntu3.4) ...
    amazon-ebs.ubuntu: Setting up libjbig0:amd64 (2.1-3.1) ...
    amazon-ebs.ubuntu: Setting up fonts-dejavu-core (2.35-1) ...
    amazon-ebs.ubuntu: Setting up fontconfig-config (2.11.94-0ubuntu1.1) ...
    amazon-ebs.ubuntu: Setting up libfontconfig1:amd64 (2.11.94-0ubuntu1.1) ...
    amazon-ebs.ubuntu: Setting up libjpeg8:amd64 (8c-2ubuntu8) ...
    amazon-ebs.ubuntu: Setting up libtiff5:amd64 (4.0.6-1ubuntu0.8) ...
    amazon-ebs.ubuntu: Setting up libvpx3:amd64 (1.5.0-2ubuntu1.1) ...
    amazon-ebs.ubuntu: Setting up libxpm4:amd64 (1:3.5.11-1ubuntu0.16.04.1) ...
    amazon-ebs.ubuntu: Setting up libgd3:amd64 (2.1.1-4ubuntu0.16.04.12) ...
    amazon-ebs.ubuntu: Setting up nginx-common (1.10.3-0ubuntu0.16.04.5) ...
    amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
    amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
    amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
    amazon-ebs.ubuntu: Setting up nginx-core (1.10.3-0ubuntu0.16.04.5) ...
    amazon-ebs.ubuntu: Setting up nginx (1.10.3-0ubuntu0.16.04.5) ...
    amazon-ebs.ubuntu: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    amazon-ebs.ubuntu: Processing triggers for ureadahead (0.100.0-19.1) ...
    amazon-ebs.ubuntu: Processing triggers for systemd (229-4ubuntu21.31) ...
    amazon-ebs.ubuntu: Processing triggers for ufw (0.35-0ubuntu2) ...
==> amazon-ebs.ubuntu: Stopping the source instance...
    amazon-ebs.ubuntu: Stopping instance
==> amazon-ebs.ubuntu: Waiting for the instance to stop...
==> amazon-ebs.ubuntu: Creating AMI packer-ubuntu-aws-1620834314 from instance i-0348c8cc4584f902a
    amazon-ebs.ubuntu: AMI: ami-040bd66b2e79ccb64
==> amazon-ebs.ubuntu: Waiting for AMI to become ready...
==> amazon-ebs.ubuntu: Copying/Encrypting AMI (ami-040bd66b2e79ccb64) to other regions...
    amazon-ebs.ubuntu: Copying to: eu-central-1
    amazon-ebs.ubuntu: Copying to: us-east-1
    amazon-ebs.ubuntu: Waiting for all copies to complete...
==> amazon-ebs.ubuntu: Adding tags to AMI (ami-00604b26ad22ba5ee)...
==> amazon-ebs.ubuntu: Tagging snapshot: snap-0b508fbc52fdd47a7
==> amazon-ebs.ubuntu: Creating AMI tags
    amazon-ebs.ubuntu: Adding tag: "OS_Version": "Ubuntu 16.04"
    amazon-ebs.ubuntu: Adding tag: "Release": "Latest"
    amazon-ebs.ubuntu: Adding tag: "Created-by": "Packer"
    amazon-ebs.ubuntu: Adding tag: "Environment": "Production"
    amazon-ebs.ubuntu: Adding tag: "Name": "MyUbuntuImage"
==> amazon-ebs.ubuntu: Creating snapshot tags
==> amazon-ebs.ubuntu: Adding tags to AMI (ami-08b5a99dee46eede8)...
==> amazon-ebs.ubuntu: Tagging snapshot: snap-0d7a5c9e418f54157
==> amazon-ebs.ubuntu: Creating AMI tags
    amazon-ebs.ubuntu: Adding tag: "Created-by": "Packer"
    amazon-ebs.ubuntu: Adding tag: "Environment": "Production"
    amazon-ebs.ubuntu: Adding tag: "Name": "MyUbuntuImage"
    amazon-ebs.ubuntu: Adding tag: "OS_Version": "Ubuntu 16.04"
    amazon-ebs.ubuntu: Adding tag: "Release": "Latest"
==> amazon-ebs.ubuntu: Creating snapshot tags
==> amazon-ebs.ubuntu: Adding tags to AMI (ami-040bd66b2e79ccb64)...
==> amazon-ebs.ubuntu: Tagging snapshot: snap-06fd314adc723181b
==> amazon-ebs.ubuntu: Creating AMI tags
    amazon-ebs.ubuntu: Adding tag: "Name": "MyUbuntuImage"
    amazon-ebs.ubuntu: Adding tag: "OS_Version": "Ubuntu 16.04"
    amazon-ebs.ubuntu: Adding tag: "Release": "Latest"
    amazon-ebs.ubuntu: Adding tag: "Created-by": "Packer"
    amazon-ebs.ubuntu: Adding tag: "Environment": "Production"
==> amazon-ebs.ubuntu: Creating snapshot tags
==> amazon-ebs.ubuntu: Terminating the source AWS instance...
==> amazon-ebs.ubuntu: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu: No volumes to clean up, skipping
==> amazon-ebs.ubuntu: Deleting temporary security group...
==> amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu' finished after 8 minutes 45 seconds.

==> Wait completed after 8 minutes 45 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
eu-central-1: ami-08b5a99dee46eede8
us-east-1: ami-00604b26ad22ba5ee
us-west-2: ami-040bd66b2e79ccb64
```


### Task 4: Install Web App

#### Step 4.1.1
Copy the web application assets into our packer working directory.  You can download the assets from https://github.com/btkrausen/hashicorp/tree/master/packer/assets

```bash
mkdir assets
```

#### Step 4.1.2
Replace the existing `builder` block of your `aws-ubuntu.pkr.hcl` with the code below. This will add a `file` provisioner and an additional `shell` provisioner.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  provisioner "file" {
    source      = "assets"
    destination = "/tmp/"
  }

   provisioner "shell" {
    inline = [
      "sudo sh /tmp/assets/setup-web.sh",
    ]
  }
}
```

Format and validate your configuration using the `packer fmt` and `packer validate` commands.

```shell
packer fmt aws-ubuntu.pkr.hcl 
packer validate aws-ubuntu.pkr.hcl
```

Run a `packer build` for the `aws-ubuntu.pkr.hcl` template.

```shell
packer build aws-ubuntu.pkr.hcl
```
---

# Part-3: Packer Post Processors
Walk you through adding a post-processor to your Packer HCL Template.  Post-processors run after the image is built by the builder and provisioned by the provisioner(s). Post-processors are optional, and they can be used to upload artifacts, re-package, or more.

Duration: 30 minutes

- Task 1: Add a Packer post-processor to write a manifest of all artifacts packer produced.
- Task 2: Validate the Packer Template
- Task 3: Build a new Image using Packer and display artifact list as a manifest

### Task 1: Add a Packer post-processor to write a manifest of all artifacts packer produced
The manifest post-processor writes a JSON file with a list of all of the artifacts packer produces during a run. If your packer template includes multiple builds, this helps you keep track of which output artifacts (files, AMI IDs, docker containers, etc.) correspond to each build.

### Step 1.1.1

Update the `build` block of your `aws-ubuntu.pkr.hcl` file with the following Packer `post-processor` block.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx"
    ]
  }

  post-processor "manifest" {}

}
```

### Task 2: Validate the Packer Template
Packer templates can be auto formatted and validated via the Packer command line.

### Step 2.1.1

Format and validate your configuration using the `packer fmt` and `packer validate` commands.

```shell
packer fmt aws-ubuntu.pkr.hcl 
packer validate aws-ubuntu.pkr.hcl
```

### Task 3: Build a new Image using Packer
The `packer build` command is used to initiate the image build process for a given Packer template.

### Step 3.1.1
Run a `packer build` for the `aws-ubuntu.pkr.hcl` template.

```shell
packer build aws-ubuntu.pkr.hcl
```

Packer will create a `manifest` file listing all of the image artifacts it has built

```bash
ls -la
```

This will return a list of files inside your working directory.  Validate that a `packer-manifest.json` file was created.
```bash
...

-rw-r--r--   1 gabe  staff   419 May  5 07:47 packer-manifest.json

...
```

View the `packer-manifest.json` for the details of the items that were built. 
```bash
cat packer-manifest.json
```

```bash 
{
  "builds": [
    {
      "name": "ubuntu",
      "builder_type": "amazon-ebs",
      "build_time": 1620215246,
      "files": null,
      "artifact_id": "eu-central-1:ami-0b70b458400c49bb3,us-east-1:ami-00c645bf39a7a66c2,us-west-2:ami-03b71c51298c1dc68",
      "packer_run_uuid": "136c7fbe-248e-d454-3f7a-ea39c873792e",
      "custom_data": null
    }
  ],
  "last_run_uuid": "136c7fbe-248e-d454-3f7a-ea39c873792e"
}%  
```
---

# Part-4: Integrating Packer with Ansible
The Ansible Packer provisioner runs Ansible playbooks. It dynamically creates an Ansible inventory file configured to use SSH, runs an SSH server, executes ansible-playbook , and marshals Ansible plays through the SSH server to the machine being provisioned by Packer.


- Task 1: Create Packer Template for Ubuntu server customized with an Ansible playbook
- Task 2: Create Ansible Playbooks
- Task 3: Validate the Packer Template
- Task 4: Build Image
- Task 5: Set Ansible env variables via Packer

## Task 1: Create Packer Template for Ubuntu server customized with an Ansible playbook

### Step 1.1.1
Create a `ansible` folder with the following Packer Template called `aws-clumsy-bird.pkr.hcl` the following code:

`aws-clumsy-bird.pkr.hcl`

```hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "ubuntu_22" {
  ami_name      = "${var.ami_prefix}-ubuntu22-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region
  ami_regions   = var.ami_regions
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags         = var.tags
}

build {
  sources = [
    "source.amazon-ebs.ubuntu_22"
  ]

  provisioner "file" {
    source      = "assets"
    destination = "/tmp/"
  }

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_NOCOWS=1"]
    extra_arguments  = ["--extra-vars", "desktop=false", "-v"]
    playbook_file    = "${path.root}/playbooks/playbook.yml"
    user             = var.ssh_username
  }

  post-processor "manifest" {}

}
```
### Step 1.1.2
Create a `variables.pkr.hcl` with the following code:

`variables.pkr.hcl`

```hcl
variable "ami_prefix" {
  type    = string
  default = "my-clumsy-bird"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_regions" {
  type    = list(string)
  default = ["us-east-1"]
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "tags" {
  type = map(string)
  default = {
    "Name"        = "ClumsyBird"
    "Environment" = "Production"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
```
### Step 1.1.3
Create a `assets` sub directory with the following files inside it: `launch.sh` and `clumsy-bird.service`

`launch.sh`

```bash
#!/bin/bash
grunt connect
```

`clumsy-bird.service`

```bash
[Install]
WantedBy=multi-user.target

[Unit]
Description=Clumsy Bird App

[Service]
WorkingDirectory=/src/clumsy-bird
ExecStart=/src/clumsy-bird/launch.sh >> /var/log/webapp.log
IgnoreSIGPIPE=false
KillMode=process
Restart=on-failure
```

## Task 2: Create Ansible Playbooks

Copy the ansible playbooks from the lab guide into our packer working directory

```bash
cp -R /playbooks/ /ansible/playbooks
```

Validate the directory structure is laid out as follows:

```bash
/ansible
.
├── assets
│   ├── clumsy-bird.service
│   └── launch.sh
├── aws-clumsy-bird.pkr.hcl
├── playbooks
│   ├── apps.yml
│   ├── base.yml
│   ├── cleanup.yml
│   ├── cloud-init.yml
│   ├── debian.yml
│   ├── playbook.yml
│   ├── redhat.yml
│   ├── virtualbox.yml
│   └── vmware.yml
└── variables.pkr.hcl
```

## Task 3: Validate the Packer Template

Format and validate your configuration using the `packer fmt` and `packer validate` commands.

```shell
cd ansible
packer init .
packer fmt .
packer validate .
```

## Task 4: Build Image
The `packer build` command is used to initiate the image build process for a given Packer template.

```shell
packer build .
```

Packer will print output similar to what is shown below.

```bash
amazon-ebs.ubuntu_20: output will be in this color.

==> amazon-ebs.ubuntu_20: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu_20: Prevalidating AMI Name: my-clumsy-bird-20-20210630223022
    amazon-ebs.ubuntu_20: Found Image ID: ami-0dd76f917833aac4b
==> amazon-ebs.ubuntu_20: Creating temporary keypair: packer_60dcf07e-3ad9-a149-0941-c13221aad1f1
==> amazon-ebs.ubuntu_20: Creating temporary security group for this instance: packer_60dcf080-d19e-de22-d1e0-6fcb46569297
==> amazon-ebs.ubuntu_20: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs.ubuntu_20: Launching a source AWS instance...
==> amazon-ebs.ubuntu_20: Adding tags to source instance
    amazon-ebs.ubuntu_20: Adding tag: "Name": "Packer Builder"
    amazon-ebs.ubuntu_20: Instance ID: i-0213b8618833c635d
==> amazon-ebs.ubuntu_20: Waiting for instance (i-0213b8618833c635d) to become ready...
==> amazon-ebs.ubuntu_20: Using ssh communicator to connect: 54.90.24.53
==> amazon-ebs.ubuntu_20: Waiting for SSH to become available...
==> amazon-ebs.ubuntu_20: Connected to SSH!
==> amazon-ebs.ubuntu_20: Uploading assets => /tmp/
==> amazon-ebs.ubuntu_20: Provisioning with Ansible...
    amazon-ebs.ubuntu_20: Setting up proxy adapter for Ansible....
==> amazon-ebs.ubuntu_20: Executing Ansible: ansible-playbook -e packer_build_name="ubuntu_20" -e packer_builder_type=amazon-ebs --ssh-extra-args '-o IdentitiesOnly=yes' --extra-vars desktop=false -v -e ansible_ssh_private_key_file=/var/folders/1c/qvs1hwp964z_dwd5qg07lv_00000gn/T/ansible-key756935621 -i /var/folders/1c/qvs1hwp964z_dwd5qg07lv_00000gn/T/packer-provisioner-ansible032233056 /Users/gabe/repos/packer_training/labs/ansible/playbooks/playbook.yml
    amazon-ebs.ubuntu_20: No config file found; using defaults
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: PLAY [default] *****************************************************************
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: TASK [Gathering Facts] *********************************************************
    amazon-ebs.ubuntu_20: ok: [default]
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: TASK [Debug Ansible OS Family] *************************************************
    amazon-ebs.ubuntu_20: ok: [default] => {
    amazon-ebs.ubuntu_20:     "ansible_os_family": "Debian"
    amazon-ebs.ubuntu_20: }
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: TASK [Debug Packer Builder Type] ***********************************************
    amazon-ebs.ubuntu_20: ok: [default] => {
    amazon-ebs.ubuntu_20:     "packer_builder_type": "amazon-ebs"
    amazon-ebs.ubuntu_20: }
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: TASK [Checking if /etc/packer_build_time Exists] *******************************
    amazon-ebs.ubuntu_20: ok: [default] => {"changed": false, "stat": {"exists": false}}
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: TASK [Setting Fact - _packer_build_complete] ***********************************
    amazon-ebs.ubuntu_20: ok: [default] => {"ansible_facts": {"_packer_build_complete": false}, "changed": false}
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: TASK [Debug _packer_build_complete] ********************************************
    amazon-ebs.ubuntu_20: ok: [default] => {
    amazon-ebs.ubuntu_20:     "_packer_build_complete": false
    amazon-ebs.ubuntu_20: }
    amazon-ebs.ubuntu_20:
    amazon-ebs.ubuntu_20: TASK [Base Tasks] **************************************************************

...

    amazon-ebs.ubuntu_20: PLAY RECAP *********************************************************************
    amazon-ebs.ubuntu_20: default                    : ok=41   changed=24   unreachable=0    failed=0    skipped=10   rescued=0    ignored=0
    amazon-ebs.ubuntu_20:
==> amazon-ebs.ubuntu_20: Stopping the source instance...
    amazon-ebs.ubuntu_20: Stopping instance
==> amazon-ebs.ubuntu_20: Waiting for the instance to stop...
==> amazon-ebs.ubuntu_20: Creating AMI my-clumsy-bird-20-20210630223022 from instance i-0213b8618833c635d
    amazon-ebs.ubuntu_20: AMI: ami-0f56ee21bc688cbab
==> amazon-ebs.ubuntu_20: Waiting for AMI to become ready...
==> amazon-ebs.ubuntu_20: Adding tags to AMI (ami-0f56ee21bc688cbab)...
==> amazon-ebs.ubuntu_20: Tagging snapshot: snap-00487425ac4014d00
==> amazon-ebs.ubuntu_20: Creating AMI tags
    amazon-ebs.ubuntu_20: Adding tag: "Environment": "Production"
    amazon-ebs.ubuntu_20: Adding tag: "Name": "ClumsyBird"
    amazon-ebs.ubuntu_20: Adding tag: "Release": "Latest"
    amazon-ebs.ubuntu_20: Adding tag: "Created-by": "Packer"
==> amazon-ebs.ubuntu_20: Creating snapshot tags
==> amazon-ebs.ubuntu_20: Terminating the source AWS instance...
==> amazon-ebs.ubuntu_20: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu_20: No volumes to clean up, skipping
==> amazon-ebs.ubuntu_20: Deleting temporary security group...
==> amazon-ebs.ubuntu_20: Deleting temporary keypair...
==> amazon-ebs.ubuntu_20: Running post-processor:  (type manifest)
Build 'amazon-ebs.ubuntu_20' finished after 6 minutes 38 seconds.

==> Wait completed after 6 minutes 38 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu_20: AMIs were created:
us-east-1: ami-0f56ee21bc688cbab
```

## Task 5: Set Ansible env variables via Packer
The `ansible_env_vars` can be updated inside the `ansible` Packer provisioner.

We will update our `ansible` provisioner block to set the `"Cow Selection"` to `random`.

```
build {
  sources = [
    "source.amazon-ebs.ubuntu_22"
  ]

  provisioner "file" {
    source      = "assets"
    destination = "/tmp/"
  }

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_COW_SELECTION=random"]
    extra_arguments  = ["--extra-vars", "desktop=false"]
    playbook_file    = "${path.root}/playbooks/playbook.yml"
    user             = var.ssh_username
  }

  post-processor "manifest" {}

}
```

```shell
packer build .
```

