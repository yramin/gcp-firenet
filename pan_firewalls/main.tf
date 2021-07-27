resource "aviatrix_firewall_instance" "firewall_instance" {
  for_each = var.firewall_names

  firenet_gw_name        = var.firenet_gw_name
  firewall_name          = each.value
  firewall_size          = var.firewall_size
  vpc_id                 = var.vpc_id
  firewall_image         = var.byol ? "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)" : var.pan_subscription
  firewall_image_version = var.cloud == "azure" ? var.firewall_image_version : var.cloud == "gcp" ? var.firewall_image_version : null
  management_subnet      = var.management_subnet
  egress_subnet          = var.egress_subnet
  iam_role               = var.cloud == "aws" ? var.iam_role : null
  bootstrap_bucket_name  = var.cloud == "aws" ? var.bootstrap_bucket_name : null
  key_name               = var.key_name == "" ? null : var.key_name
  username               = var.cloud == "azure" ? "avxuser" : null
  password               = var.cloud == "azure" ? "Aviatrix123#" : null
  zone                   = var.cloud == "aws" ? (var.gwlb ? "${var.region}${var.az1}" : null) : (var.cloud == "gcp" ? var.region : null)
  management_vpc_id      = var.cloud == "gcp" ? var.management_vpc_id : null
  egress_vpc_id          = var.cloud == "gcp" ? var.egress_vpc_id : null
}

resource "aviatrix_firewall_instance" "firewall_instance_ha" {

  for_each = var.ha ? toset(slice((tolist(var.firewall_names)), 0, 1)) : []
  #for_each = var.avtx_gw_ha ? var.firewall_names : []

  firenet_gw_name        = "${var.firenet_gw_name}-hagw"
  firewall_name          = "${each.value}-ha"
  firewall_size          = var.firewall_size
  vpc_id                 = var.vpc_id
  firewall_image         = var.byol ? "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)" : var.pan_subscription
  firewall_image_version = var.cloud == "azure" || var.cloud == "gcp" ? var.firewall_image_version : null
  management_subnet      = var.management_subnet_ha
  egress_subnet          = var.egress_subnet_ha
  iam_role               = var.cloud == "aws" ? var.iam_role : null
  bootstrap_bucket_name  = var.cloud == "aws" ? var.bootstrap_bucket_name_ha : null
  key_name               = var.key_name == "" ? null : var.key_name
  username               = var.cloud == "azure" ? var.azure_fw_user : null
  password               = var.cloud == "azure" ? var.azure_fw_pass : null
  zone                   = var.cloud == "aws" ? (var.gwlb ? "${var.region}${var.az2}" : null) : (var.cloud == "gcp" ? var.ha_region : null)
  management_vpc_id      = var.cloud == "gcp" ? var.management_vpc_id : null
  egress_vpc_id          = var.cloud == "gcp" ? var.egress_vpc_id : null
  lifecycle {
    ignore_changes = all
  }
  depends_on = [aviatrix_firewall_instance.firewall_instance]
}

resource "aviatrix_firenet" "firewall_net" {
  vpc_id                               = var.vpc_id
  inspection_enabled                   = var.inspection_enabled
  egress_enabled                       = var.egress_enabled
  keep_alive_via_lan_interface_enabled = var.keep_alive_via_lan_interface_enabled
  manage_firewall_instance_association = false
  depends_on = [
    aviatrix_firewall_instance_association.firewall_instance_association_1,
    aviatrix_firewall_instance_association.firewall_instance_association_2
  ]
}

resource "aviatrix_firewall_instance_association" "firewall_instance_association_1" {
  for_each = var.firewall_names
  #firenet_gw_name      = var.gwlb ? null : var.firenet_gw_name
  firenet_gw_name      = var.firenet_gw_name
  vendor_type          = "Generic"
  instance_id          = aviatrix_firewall_instance.firewall_instance[each.key].instance_id
  firewall_name        = var.cloud != "gcp" ? aviatrix_firewall_instance.firewall_instance[each.key].firewall_name : null
  attached             = true
  lan_interface        = aviatrix_firewall_instance.firewall_instance[each.key].lan_interface
  management_interface = var.cloud == "aws" || var.cloud == "gcp" ? aviatrix_firewall_instance.firewall_instance[each.key].management_interface : null
  egress_interface     = aviatrix_firewall_instance.firewall_instance[each.key].egress_interface
  vpc_id               = var.vpc_id
}

resource "aviatrix_firewall_instance_association" "firewall_instance_association_2" {
  for_each = var.ha ? toset(slice((tolist(var.firewall_names)), 0, 1)) : []
  #for_each = var.avtx_gw_ha ? var.firewall_names : []
  #firenet_gw_name      = var.gwlb ? null : "${var.firenet_gw_name}-hagw"
  firenet_gw_name      = "${var.firenet_gw_name}-hagw"
  vendor_type          = "Generic"
  instance_id          = aviatrix_firewall_instance.firewall_instance_ha[each.key].instance_id
  firewall_name        = var.cloud != "gcp" ? aviatrix_firewall_instance.firewall_instance_ha[each.key].firewall_name : null
  attached             = true
  lan_interface        = aviatrix_firewall_instance.firewall_instance_ha[each.key].lan_interface
  management_interface = var.cloud == "aws" || var.cloud == "gcp" ? aviatrix_firewall_instance.firewall_instance[each.key].management_interface : null
  egress_interface     = aviatrix_firewall_instance.firewall_instance_ha[each.key].egress_interface
  vpc_id               = var.vpc_id
}


# Vendor integration delays every TF operation significantly
# Uncomment the following section after the firewalls are available through their UI
# run terraform again and comment it back. Or configure vendor integration from the UI

/*
data "aviatrix_firenet_vendor_integration" "pan" {
  for_each = var.firewall_names

  vpc_id            = var.vpc_id
  instance_id       = aviatrix_firewall_instance.firewall_instance[each.value].instance_id
  public_ip         = aviatrix_firewall_instance.firewall_instance[each.value].public_ip
  vendor_type       = "Palo Alto Networks VM-Series"
  username          = "admin"
  password          = "Aviatrix123#"
  save              = true
  number_of_retries = 1
  retry_interval    = 60
}

data "aviatrix_firenet_vendor_integration" "pan_ha" {
  for_each = var.ha ? toset(slice((tolist(var.firewall_names)), 0, 1)) : []
  #for_each = var.avtx_gw_ha ? var.firewall_names : []

  vpc_id            = var.vpc_id
  instance_id       = aviatrix_firewall_instance.firewall_instance_ha[each.value].instance_id
  public_ip         = aviatrix_firewall_instance.firewall_instance_ha[each.value].public_ip
  vendor_type       = "Palo Alto Networks VM-Series"
  username          = "admin"
  password          = "Aviatrix123#"
  save              = true
  number_of_retries = 1
  retry_interval    = 60
}*/
