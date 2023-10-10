
output "haproxy-servers-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.haproxy-servers : 
    vm.name => {
      ip_address = vm.network_interface.*.ip_address
      nat_ip_address = vm.network_interface.*.nat_ip_address
    }
  }
}

output "backend-servers-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.backend-servers : 
    vm.name => {
      ip_address = vm.network_interface.*.ip_address
      nat_ip_address = vm.network_interface.*.nat_ip_address
    }
  }
}

output "db-servers-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.db-servers : 
    vm.name => {
      ip_address = vm.network_interface.*.ip_address
      nat_ip_address = vm.network_interface.*.nat_ip_address
    }
  }
}