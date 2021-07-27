aws_account_name   = "avxacc"
avtx_key_name      = "avtx-key"
aws_spoke_gw_size  = "t3.micro"
create_private_ec2 = false
create_public_ec2  = true
aws_region_1       = "us-east-1"
aws_region_2       = "us-east-2"
ssh_addresses      = ["0.0.0.0/0"]
aws_profile        = "avxacc"

avx_transit = {
  east1 = {
    region           = "us-east-1"
    account          = "avxacc"
    aws_transit_name = "eva-transit"
    cidr             = "10.100.0.0/16"
    transit_gw_size  = "c5.xlarge"
    hpe              = "false"
    firenet          = "true"
    aws              = "region_1"
  }
  east2 = {
    region           = "us-east-2"
    account          = "avxacc"
    aws_transit_name = "eoh-transit"
    cidr             = "10.200.0.0/16"
    transit_gw_size  = "c5.xlarge"
    hpe              = "false"
    firenet          = "false"
    aws              = "region_2"
  }
}


vpc_data_va = {
  spoke_vpc1 = {
    name          = "VPC1-East1"
    cidr          = "10.40.0.0/16"
    instance_size = "n1-highcpu-4"
  }
  spoke_vpc2 = {
    name          = "VPC2-East1"
    cidr          = "10.41.0.0/16"
    instance_size = "n1-highcpu-4"
  }


}

firewall = {
  east = {
    name                 = ["east-fw"]
    aws_byol             = false
    aws_pan_subscription = "Palo Alto Networks VM-Series Next-Generation Firewall BUNDLE1"
    firewall_size        = "n1-standard-4"
  }
  east2 = {
    name                 = ["east2-fw"]
    aws_byol             = false
    aws_pan_subscription = "Palo Alto Networks VM-Series Next-Generation Firewall BUNDLE1"
    firewall_size        = "n1-standard-4"

  }

}

firenet = true
