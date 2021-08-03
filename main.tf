data "aviatrix_account" "gcp" {
  account_name = "avx-gcp"
}
module "gcp_ha_transit_1" {
  source = "./gcp_transit"

  account         = "avx-gcp"
  cidr            = "10.10.0.0/16"
  region          = "us-east1"
  ha_cidr         = "10.20.0.0/16"
  lan_vpc_cidr    = "10.30.0.0/16"
  egress_vpc_cidr = "10.40.0.0/16"
  mgmt_vpc_cidr   = "10.50.0.0/16"
  firenet         = var.firenet
  lan_vpc_name    = "lan"
  egress_vpc_name = "egress"
  mgmt_vpc_name   = "mgmt"
  instance_size   = "n1-highcpu-4"
  #  ha_region       = "us-east4"
  single_az_ha = false
}

module "aviatrix-create-pan-area-1" {
  source         = "./pan_firewalls"
  region         = module.gcp_ha_transit_1.transit_gateway.vpc_reg
  firewall_names = var.firewall.east.name
  #key_name                 = aws_key_pair.ec2_key_region_1.key_name
  cloud                    = "gcp"
  byol                     = var.firewall.east.aws_byol
  pan_subscription         = var.firewall.east.aws_pan_subscription
  firewall_size            = var.firewall.east.firewall_size
  inspection_enabled       = true
  egress_enabled           = false #?????
  firenet_gw_name          = module.gcp_ha_transit_1.transit_gateway.gw_name
  vpc_id                   = format("%s~-~%s", module.gcp_ha_transit_1.transit_gateway.vpc_id, data.aviatrix_account.gcp.gcloud_project_id)
  iam_role                 = ""
  bootstrap_bucket_name    = ""
  bootstrap_bucket_name_ha = ""
  management_subnet        = format("%s~~%s~~%s", module.gcp_ha_transit_1.mgmt[0].subnets[0].cidr, module.gcp_ha_transit_1.mgmt[0].subnets[0].region, module.gcp_ha_transit_1.mgmt[0].subnets[0].name)
  egress_subnet            = format("%s~~%s~~%s", module.gcp_ha_transit_1.egress_vpc[0].subnets[0].cidr, module.gcp_ha_transit_1.egress_vpc[0].subnets[0].region, module.gcp_ha_transit_1.egress_vpc[0].subnets[0].name)
  management_subnet_ha     = format("%s~~%s~~%s", module.gcp_ha_transit_1.mgmt[0].subnets[0].cidr, module.gcp_ha_transit_1.mgmt[0].subnets[0].region, module.gcp_ha_transit_1.mgmt[0].subnets[0].name)
  egress_subnet_ha         = format("%s~~%s~~%s", module.gcp_ha_transit_1.egress_vpc[0].subnets[0].cidr, module.gcp_ha_transit_1.egress_vpc[0].subnets[0].region, module.gcp_ha_transit_1.egress_vpc[0].subnets[0].name)
  #gwlb                     = true
  firewall_image_version = "9.0.9"
  management_vpc_id      = module.gcp_ha_transit_1.mgmt[0].vpc_id
  egress_vpc_id          = module.gcp_ha_transit_1.egress_vpc[0].vpc_id
  ha_region              = module.gcp_ha_transit_1.transit_gateway.ha_zone


}


module "gcp_ha_spoke_1" {
  source        = "terraform-aviatrix-modules/gcp-spoke/aviatrix"
  version       = "3.0.0"
  insane_mode   = true
  name          = var.vpc_data_va.spoke_vpc1.name
  account       = "avx-gcp"
  cidr          = var.vpc_data_va.spoke_vpc1.cidr
  region        = "us-east1"
  transit_gw    = module.gcp_ha_transit_1.transit_gateway.gw_name
  instance_size = var.vpc_data_va.spoke_vpc1.instance_size
  single_az_ha  = false
}
module "gcp_ha_spoke_2" {
  source        = "terraform-aviatrix-modules/gcp-spoke/aviatrix"
  version       = "3.0.0"
  insane_mode   = true
  name          = var.vpc_data_va.spoke_vpc2.name
  account       = "avx-gcp"
  cidr          = var.vpc_data_va.spoke_vpc2.cidr
  region        = "us-east1"
  transit_gw    = module.gcp_ha_transit_1.transit_gateway.gw_name
  instance_size = var.vpc_data_va.spoke_vpc2.instance_size
  single_az_ha  = false
}

resource "tls_private_key" "avtx_key" {
  algorithm = "RSA"
  rsa_bits  = 2048

}
resource "local_file" "private_key" {
  content         = tls_private_key.avtx_key.private_key_pem
  filename        = "gcp_private_key.pem"
  file_permission = "0600"
}

module "test_instance_1" {
  source     = "./gcp_instance"
  public_key = tls_private_key.avtx_key.public_key_openssh
  vpc_id     = module.gcp_ha_spoke_1.vpc.vpc_id
  zone       = module.gcp_ha_spoke_1.spoke_gateway.vpc_reg
  subnetwork = module.gcp_ha_spoke_1.vpc.subnets[0].name
  tags       = "testinstance1"
}
module "test_instance_2" {
  source     = "./gcp_instance"
  public_key = tls_private_key.avtx_key.public_key_openssh
  vpc_id     = module.gcp_ha_spoke_2.vpc.vpc_id
  zone       = module.gcp_ha_spoke_2.spoke_gateway.vpc_reg
  subnetwork = module.gcp_ha_spoke_2.vpc.subnets[0].name
  tags       = "testinstance2"
}



//----------------test router applicnce with cloud router -----------
/*
resource "google_compute_router" "foobar" {
  name    = "my-router"
  network = module.gcp_ha_transit_1.vpc.name
  bgp {
    asn            = 64514
    advertise_mode = "DEFAULT"


  }
}*/
