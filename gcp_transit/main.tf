resource "aviatrix_vpc" "gcp_transit" {
  cloud_type           = 4
  account_name         = var.account
  name                 = var.firenet ? local.firenet.name : local.no-firenet.name
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  subnets {
    name   = var.firenet ? local.firenet.name : local.no-firenet.name
    cidr   = var.cidr
    region = var.region
  }
  subnets {
    name   = var.ha_gw ? (var.firenet ? local.firenet.ha_name : local.no-firenet.ha_name) : null
    cidr   = var.ha_gw ? var.ha_cidr : null
    region = var.ha_gw ? local.transit_region2 : null
  }
  /*
  dynamic "subnets" {
    for_each = length(var.ha_region) > 0 ? ["dummy"] : []
    content {
      name   = var.firenet ? "${local.firenet.name}-ha" : "${local.no-firenet.name}-ha"
      cidr   = var.ha_cidr
      region = var.ha_region
    }
  }*/
}

resource "aviatrix_vpc" "gcp_lan" {
  count                = var.firenet ? 1 : 0
  cloud_type           = 4
  account_name         = var.account
  name                 = local.firenet.lan_vpc_name
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  subnets {
    name   = local.firenet.lan_vpc_name
    cidr   = var.lan_vpc_cidr
    region = var.region
  }


}
resource "aviatrix_vpc" "gcp_egress" {
  count                = var.firenet ? 1 : 0
  cloud_type           = 4
  account_name         = var.account
  name                 = local.firenet.egress_vpc_name
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  subnets {
    name   = local.firenet.egress_vpc_name
    cidr   = var.egress_vpc_cidr
    region = var.region
  }


}

resource "aviatrix_vpc" "mgmt" {
  count                = var.firenet ? 1 : 0
  cloud_type           = 4
  account_name         = var.account
  name                 = local.firenet.mgmt_vpc_name
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  subnets {
    name   = local.firenet.mgmt_vpc_name
    cidr   = var.mgmt_vpc_cidr
    region = var.region
  }


}



resource "aviatrix_transit_gateway" "default" {
  gw_name                          = var.firenet ? local.firenet.name : local.no-firenet.name
  vpc_id                           = aviatrix_vpc.gcp_transit.name
  cloud_type                       = 4
  vpc_reg                          = var.firenet ? local.firenet.region1 : local.no-firenet.region1
  enable_active_mesh               = var.active_mesh
  gw_size                          = var.instance_size
  account_name                     = var.account
  subnet                           = local.subnet
  insane_mode                      = var.insane_mode
  ha_subnet                        = var.ha_gw ? local.ha_subnet : null
  ha_gw_size                       = var.ha_gw ? var.instance_size : null
  ha_zone                          = var.ha_gw ? (var.firenet ? local.firenet.region2 : local.no-firenet.region2) : null
  connected_transit                = var.connected_transit
  bgp_manual_spoke_advertise_cidrs = var.bgp_manual_spoke_advertise_cidrs
  enable_learned_cidrs_approval    = var.learned_cidr_approval
  enable_segmentation              = var.enable_segmentation
  single_az_ha                     = var.single_az_ha
  single_ip_snat                   = var.single_ip_snat
  enable_advertise_transit_cidr    = var.enable_advertise_transit_cidr
  bgp_polling_time                 = var.bgp_polling_time
  bgp_ecmp                         = var.bgp_ecmp
  lan_vpc_id                       = var.firenet ? aviatrix_vpc.gcp_lan[0].vpc_id : null
  lan_private_subnet               = var.firenet ? var.lan_vpc_cidr : null
  enable_transit_firenet           = var.firenet
  #zone                             = var.firenet ? local.firenet.region1 : local.no-firenet.region1
}
