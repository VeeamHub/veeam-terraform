output "public_ip_vbaz" {
    value = azurerm_public_ip.vbaz.ip_address
    depends_on = [
      azurerm_public_ip.vbaz
    ]
}