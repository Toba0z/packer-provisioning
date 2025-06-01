### How to run
packer init .
packer fmt -var-file="variables.pkrvars.hcl" .
packer validate -var-file="variables.pkrvars.hcl" .
packer build -var-file="variables.pkrvars.hcl" .