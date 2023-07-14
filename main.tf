terraform {
  required_version = ">= 1.1.0"

  required_providers {
    iosxe = {
      source  = "CiscoDevNet/iosxe"
      version = ">= 0.3.0"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.2.4"
    }
  }
}

locals {
  model = yamldecode(data.utils_yaml_merge.model.output)

  devices = concat(lookup(local.model.fabric.inventory, "leafs", []), lookup(local.model.fabric.inventory, "spines", []))
  leafs   = toset([for leaf in lookup(local.model.fabric.inventory, "leafs", []) : leaf.name])
  spines  = toset([for spine in lookup(local.model.fabric.inventory, "spines", []) : spine.name])
}

provider "iosxe" {
  devices = local.devices
}

data "utils_yaml_merge" "model" {
  input = [for file in fileset(path.module, "data/*.yaml") : file(file)]
}

module "iosxe_evpn_ospf_underlay" {
  source  = "netascode/evpn-ospf-underlay/iosxe"
  version = ">= 0.1.1"

  leafs                         = local.leafs
  spines                        = local.spines
  loopback_id                   = lookup(local.model.fabric.underlay, "loopback_id", null)
  pim_loopback_id               = lookup(local.model.fabric.underlay, "pim_loopback_id", null)
  loopbacks                     = lookup(local.model.fabric.underlay, "loopbacks", null)
  vtep_loopback_id              = lookup(local.model.fabric.underlay, "vtep_loopback_id", null)
  vtep_loopbacks                = lookup(local.model.fabric.underlay, "vtep_loopbacks", null)
  fabric_interface_type         = lookup(local.model.fabric.underlay, "fabric_interface_type", null)
  leaf_fabric_interface_prefix  = lookup(local.model.fabric.underlay, "leaf_fabric_interface_prefix", null)
  spine_fabric_interface_prefix = lookup(local.model.fabric.underlay, "spine_fabric_interface_prefix", null)
  leaf_fabric_interface_offset  = lookup(local.model.fabric.underlay, "leaf_fabric_interface_offset", null)
  spine_fabric_interface_offset = lookup(local.model.fabric.underlay, "spine_fabric_interface_offset", null)
  anycast_rp_ipv4_address       = lookup(local.model.fabric.underlay, "anycast_rp_ipv4_address", null)
}

module "iosxe_evpn_overlay" {
  source  = "netascode/evpn-overlay/iosxe"
  version = ">= 0.1.3"

  leafs                = local.leafs
  spines               = local.spines
  underlay_loopback_id = module.iosxe_evpn_ospf_underlay.loopback_id
  underlay_loopbacks   = module.iosxe_evpn_ospf_underlay.loopbacks
  vtep_loopback_id     = module.iosxe_evpn_ospf_underlay.vtep_loopback_id
  bgp_asn              = lookup(local.model.fabric.overlay, "bgp_asn", null)
  l2_services          = lookup(local.model.fabric.overlay, "l2_services", null)
  l3_services          = lookup(local.model.fabric.overlay, "l3_services", null)
}
