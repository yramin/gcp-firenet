variable "region" {
  description = "Primary GCP region where subnet and Aviatrix Transit Gateway will be created"
  type        = string
}

variable "ha_region" {
  description = "Secondary GCP region where subnet and HA Aviatrix Transit Gateway will be created"
  default     = ""
  type        = string
}

variable "account" {
  description = "Name of the GCP Access Account defined in the Aviatrix Controller"
  type        = string
}

variable "instance_size" {
  description = "Size of the compute instance for the Aviatrix Gateways"
  default     = "n1-standard-1"
  type        = string
}

variable "cidr" {
  description = "CIDR of the primary GCP subnet"
  type        = string
}

variable "ha_cidr" {
  description = "CIDR of the HA GCP subnet"
  type        = string
  default     = ""
}

variable "ha_gw" {
  description = "Set to false te deploy a single transit GW"
  type        = bool
  default     = true
}

variable "az1" {
  description = "Concatenates with region to form az names. e.g. us-east1b."
  type        = string
  default     = "b"
}

variable "az2" {
  description = "Concatenates with region or ha_region (depending whether ha_region is set) to form az names. e.g. us-east1c."
  type        = string
  default     = "c"
}

variable "name" {
  description = "Name for this spoke VPC and it's gateways"
  type        = string
  default     = ""
}

variable "prefix" {
  description = "Boolean to determine if name will be prepended with avx-"
  type        = bool
  default     = true
}

variable "suffix" {
  description = "Boolean to determine if name will be appended with -spoke"
  type        = bool
  default     = true
}

variable "connected_transit" {
  description = "Set to false to disable connected transit."
  type        = bool
  default     = true
}

variable "bgp_manual_spoke_advertise_cidrs" {
  description = "Define a list of CIDRs that should be advertised via BGP."
  type        = string
  default     = ""
}

variable "learned_cidr_approval" {
  description = "Set to true to enable learned CIDR approval."
  type        = string
  default     = "false"
}

variable "active_mesh" {
  description = "Set to false to disable active mesh."
  type        = bool
  default     = true
}

variable "insane_mode" {
  description = "Boolean to enable insane mode"
  type        = bool
  default     = true
}

variable "enable_segmentation" {
  description = "Switch to true to enable transit segmentation"
  type        = bool
  default     = false
}

variable "single_az_ha" {
  description = "Set to true if Controller managed Gateway HA is desired"
  type        = bool
  default     = true
}

variable "single_ip_snat" {
  description = "Enable single_ip mode Source NAT for this container"
  type        = bool
  default     = false
}

variable "enable_advertise_transit_cidr" {
  description = "Switch to enable/disable advertise transit VPC network CIDR for a VGW connection"
  type        = bool
  default     = false
}

variable "bgp_polling_time" {
  description = "BGP route polling time. Unit is in seconds"
  type        = string
  default     = "50"
}

variable "bgp_ecmp" {
  description = "Enable Equal Cost Multi Path (ECMP) routing for the next hop"
  type        = bool
  default     = false
}
/*
locals {
  lower_name = length(var.name) > 0 ? replace(lower(var.name), " ", "-") : replace(lower(var.region), " ", "-")
  prefix     = var.prefix ? "avx-" : ""
  suffix     = var.suffix ? "-transit" : ""
  name       = "${local.prefix}${local.lower_name}${local.suffix}"
  subnet     = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[0].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
  ha_subnet  = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[1].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
  region1    = "${var.region}-${var.az1}"
  region2    = length(var.ha_region) > 0 ? "${var.ha_region}-${var.az2}" : "${var.region}-${var.az2}"
}*/
locals {
  # Common tags to be assigned to all resources
  lower_name      = length(var.name) > 0 ? replace(lower(var.name), " ", "-") : replace(lower(var.region), " ", "-")
  prefix          = var.prefix ? "avx-" : ""
  suffix          = var.suffix ? "-transit" : ""
  ha_suffix       = var.ha_gw ? "-ha" : ""
  lanvpc_name     = length(var.lan_vpc_name) > 0 ? replace(lower(var.lan_vpc_name), " ", "-") : replace(lower(var.region), " ", "-")
  mgmtvpc_name    = length(var.mgmt_vpc_name) > 0 ? replace(lower(var.mgmt_vpc_name), " ", "-") : replace(lower(var.region), " ", "-")
  egressvpc_name  = length(var.egress_vpc_name) > 0 ? replace(lower(var.egress_vpc_name), " ", "-") : replace(lower(var.region), " ", "-")
  transit_region2 = length(var.ha_region) > 0 ? var.ha_region : var.region
  subnet          = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[0].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
  ha_subnet       = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[1].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
  no-firenet = {
    name = "${local.prefix}${local.lower_name}${local.suffix}"
    #subnet     = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[0].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
    #ha_subnet  = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[1].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
    region1 = "${var.region}-${var.az1}"
    region2 = length(var.ha_region) > 0 ? "${var.ha_region}-${var.az2}" : "${var.region}-${var.az2}"
    ha_name = "${local.prefix}${local.lower_name}${local.suffix}${local.ha_suffix}"
  }
  firenet = {

    name = "${local.prefix}${local.lower_name}${local.suffix}"
    #subnet    = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[0].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
    #ha_subnet = length(var.ha_region) > 0 ? aviatrix_vpc.gcp_transit.subnets[1].cidr : aviatrix_vpc.gcp_transit.subnets[0].cidr
    region1 = "${var.region}-${var.az1}"
    region2 = length(var.ha_region) > 0 ? "${var.ha_region}-${var.az2}" : "${var.region}-${var.az2}"

    ha_name         = "${local.prefix}${local.lower_name}${local.suffix}${local.ha_suffix}"
    lan_vpc_name    = "${local.prefix}${local.lanvpc_name}"
    egress_vpc_name = "${local.prefix}${local.egressvpc_name}"
    mgmt_vpc_name   = "${local.prefix}${local.mgmtvpc_name}"
  }
}
#-------------
variable "firenet" {
  type    = bool
  default = "false"
}
variable "lan_vpc_name" {
  default = ""
}
variable "lan_vpc_cidr" {
  default = ""
}
variable "egress_vpc_name" {
  default = ""
}
variable "egress_vpc_cidr" {
  default = ""
}
variable "mgmt_vpc_name" {
  default = ""
}
variable "mgmt_vpc_cidr" {
  default = ""
}
