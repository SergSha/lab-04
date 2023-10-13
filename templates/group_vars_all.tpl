---
# group vars

ip_address:
%{ for haproxy-server in haproxy-servers ~}
  ${ haproxy-server["name"] }: ${ haproxy-server.network_interface[0].ip_address }
%{ endfor ~}
%{ for backend-server in backend-servers ~}
  ${ backend-server["name"] }: ${ backend-server.network_interface[0].ip_address }
%{ endfor ~}
%{ for db-server in db-servers ~}
  ${ db-server["name"] }: ${ db-server.network_interface[0].ip_address }
%{ endfor ~}


domain: "mydomain.test"
ntp_timezone: "UTC"
backend_password: "strong_pass" # cluster user: hacluster
cluster_name: "hacluster"
subnet_cidrs: "{ %{ for subnet_cidr in subnet_cidrs ~} ${ subnet_cidr }, %{ endfor ~} }"