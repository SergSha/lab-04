locals {
  vm_user         = "cloud-user"
  ssh_public_key  = "~/.ssh/otus.pub"
  ssh_private_key = "~/.ssh/otus"
  #vm_name = "instance"
  vpc_name = "my_vpc_network"
  subnet_cidrs = ["10.10.20.0/24"]
  subnet_name = "my_vpc_subnet"
  haproxy_count = "2"
  backend_count = "2"
  db_count = "1"
  disks = {
    "web-01" = {
      "size"        = "1"
    },
    "web-02" = {
      "size"        = "1"
    }
  }
}

resource "yandex_vpc_network" "vpc" {
  # folder_id = var.folder_id
  name = local.vpc_name
}

resource "yandex_vpc_subnet" "subnet" {
  # folder_id = var.folder_id
  v4_cidr_blocks = local.subnet_cidrs
  zone           = local.zone
  name           = local.subnet_name
  network_id     = yandex_vpc_network.vpc.id
}

module "haproxy-servers" {
  source = "./modules/instances"
  count = local.haproxy_count
  vm_name = "haproxy-${format("%02d", count.index + 1)}"
  vpc_name = local.vpc_name
  subnet_cidrs = yandex_vpc_subnet.subnet.v4_cidr_blocks
  subnet_name = yandex_vpc_subnet.subnet.name
  subnet_id = yandex_vpc_subnet.subnet.id
  vm_user = local.vm_user
  ssh_public_key = local.ssh_public_key
  secondary_disk = {}
  depends_on = [ yandex_compute_disk.disks ]
}

data "yandex_compute_instance" "haproxy-servers" {
  count = length(module.haproxy-servers)
  name = module.haproxy-servers[count.index].vm_name
  depends_on = [ module.haproxy-servers ]
}
/*
module "backend-servers" {
  source = "./modules/instances"
  count = local.backend_count
  vm_name = "backend-${format("%02d", count.index + 1)}"
  vpc_name = local.vpc_name
  subnet_cidrs = yandex_vpc_subnet.subnet.v4_cidr_blocks
  subnet_name = yandex_vpc_subnet.subnet.name
  subnet_id = yandex_vpc_subnet.subnet.id
  vm_user = local.vm_user
  ssh_public_key = local.ssh_public_key
  secondary_disk = {
    for disk in data.yandex_compute_disk.disks :
    disk.name => {
      disk_id     = disk.id
      #"auto_delete" = true
      #"mode"        = "READ_WRITE"
    }
    if disk.name == "web-${format("%02d", count.index + 1)}"
  }
  depends_on = [ yandex_compute_disk.disks ]
}

data "yandex_compute_instance" "backend-servers" {
  count = length(module.backend-servers)
  name = module.backend-servers[count.index].vm_name
  depends_on = [ module.backend-servers ]
}

module "db-servers" {
  source = "./modules/instances"
  count = local.db_count
  vm_name = "db-${format("%02d", count.index + 1)}"
  vpc_name = local.vpc_name
  subnet_cidrs = yandex_vpc_subnet.subnet.v4_cidr_blocks
  subnet_name = yandex_vpc_subnet.subnet.name
  subnet_id = yandex_vpc_subnet.subnet.id
  vm_user = local.vm_user
  ssh_public_key = local.ssh_public_key
  secondary_disk = {}
  depends_on = [ yandex_compute_disk.disks ]
}

data "yandex_compute_instance" "db-servers" {
  count = length(module.db-servers)
  name = module.db-servers[count.index].vm_name
  depends_on = [ module.db-servers ]
}
*/
resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      haproxy-servers = data.yandex_compute_instance.haproxy-servers
#      backend-servers   = data.yandex_compute_instance.backend-servers
#      db-servers   = data.yandex_compute_instance.db-servers
    }
  )
  filename = "${path.module}/inventory.ini"
}

resource "local_file" "group_vars_all_file" {
  content = templatefile("${path.module}/templates/group_vars_all.tpl",
    {
      haproxy-servers = data.yandex_compute_instance.haproxy-servers
#      backend-servers = data.yandex_compute_instance.backend-servers
#      db-servers      = data.yandex_compute_instance.db-servers
      subnet_cidrs    = local.subnet_cidrs
    }
  )
  filename = "${path.module}/group_vars/all/main.yml"
}

resource "yandex_compute_disk" "disks" {
  for_each = local.disks
  name     = each.key
  size     = each.value["size"]
  zone     = local.zone
}

data "yandex_compute_disk" "disks" {
  for_each = yandex_compute_disk.disks
  name = each.value["name"]
  depends_on = [ yandex_compute_disk.disks ]
}
/*
resource "null_resource" "haproxy-servers" {

  count = length(module.haproxy-servers)

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    name = module.haproxy-servers[count.index].vm_name
  }

  
  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]
  }

  connection {
    type        = "ssh"
    user        = local.vm_user
    private_key = file(local.ssh_private_key)
    host        = "${module.haproxy-servers[count.index].instance_external_ip_address}"
  }

  # Note that the -i flag expects a comma separated list, so the trailing comma is essential!

  provisioner "local-exec" {
    command = "ansible-playbook -u '${local.vm_user}' --private-key '${local.ssh_private_key}' --become -i ./inventory.ini -l '${module.haproxy-servers[count.index].instance_external_ip_address},' provision.yml"
    #command = "ansible-playbook provision.yml -u '${local.vm_user}' --private-key '${local.ssh_private_key}' --become -i '${element(module.haproxy-servers.nat_ip_address, 0)},' "
  }
  
}
*/
/*
resource "null_resource" "backend-servers" {

  count = length(module.backend-servers)

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    name = "${module.backend-servers[count.index].vm_name}"
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]
  }

  connection {
    type        = "ssh"
    user        = local.vm_user
    private_key = file(local.ssh_private_key)
    host        = "${module.backend-servers[count.index].instance_external_ip_address}"
  }

  # Note that the -i flag expects a comma separated list, so the trailing comma is essential!

  provisioner "local-exec" {
    command = "ansible-playbook -u '${local.vm_user}' --private-key '${local.ssh_private_key}' --become -i '${module.backend-servers[count.index].instance_external_ip_address},' provision.yml"
    #command = "ansible-playbook provision.yml -u '${local.vm_user}' --private-key '${local.ssh_private_key}' --become -i '${element(module.backend-servers.nat_ip_address, 0)},' "
  }
}
*/
