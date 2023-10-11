
[all]
%{ for haproxy-server in haproxy-servers ~}
${ haproxy-server["name"] } ansible_host=${ haproxy-server.network_interface[0].nat_ip_address }
%{ endfor ~}

[haproxy_servers]
%{ for haproxy-server in haproxy-servers ~}
${ haproxy-server["name"] }
%{ endfor ~}
