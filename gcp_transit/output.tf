output "vpc" {
  description = "Returns aviatrix_vpc object and all of its attributes"
  value       = aviatrix_vpc.gcp_transit
}

output "transit_gateway" {
  description = "Return Aviatrix Transit Gateway with all attributes"
  value       = aviatrix_transit_gateway.default
}
output "transit_vpc" {
  description = "Returns aviatrix_vpc object and all of its attributes"
  value       = aviatrix_vpc.gcp_transit
}
output "lan_vpc" {
  description = "Returns aviatrix_vpc object and all of its attributes"
  value       = aviatrix_vpc.gcp_lan
}
output "egress_vpc" {
  description = "Returns aviatrix_vpc object and all of its attributes"
  value       = aviatrix_vpc.gcp_egress
}
output "mgmt" {
  description = "Returns aviatrix_vpc object and all of its attributes"
  value       = aviatrix_vpc.mgmt
}
