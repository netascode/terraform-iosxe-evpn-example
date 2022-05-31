# Cisco Catalyst 9000 EVPN Terraform Example

This example demonstrates how the [IOS-XE Terraform Provider](https://registry.terraform.io/providers/netascode/iosxe/latest/docs) can be used to build a Catalyst 9000 EVPN Fabric. It currently supports underlay and overlay configuration, but no access interfaces.

It uses the following Terrafrom Modules:

- [EVPN OSPF Underlay Module](https://registry.terraform.io/modules/netascode/evpn-ospf-underlay/iosxe/latest)
- [EVPN Overlay Module](https://registry.terraform.io/modules/netascode/evpn-overlay/iosxe/latest)

The configuration is derived from a set of yaml files in the `data` [directory](https://github.com/netascode/terraform-iosxe-evpn-example/tree/main/data).

To point this to your own Cat9k fabric, update the `data/inventory.yaml` file accordingly.

```yaml
---
fabric:
  inventory:
    spines:
      - name: SPINE-1
        url: https://10.1.1.1
      - name: SPINE-2
        url: https://10.1.1.2

    leafs:
      - name: LEAF-1
        url: https://10.1.1.3
      - name: LEAF-2
        url: https://10.1.1.4
```

Credentials can either be provided via environment variables:

```shell
export IOSXE_USERNAME=admin
export IOSXE_PASSWORD=Cisco123
```

Or by updating the provider configuration in `main.tf`:

```terraform
provider "iosxe" {
  username = admin
  password = Cisco123
  devices  = local.devices
}
```
