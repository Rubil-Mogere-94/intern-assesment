output "vm1_public_ip" {
  description = "Public IP address of VM1"
  value       = azurerm_public_ip.vm1.ip_address
}

output "vm2_private_ip" {
  description = "Private IP address of VM2"
  value       = azurerm_linux_virtual_machine.vm2.private_ip_address
}
