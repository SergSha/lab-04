
[all]
%{ for haproxy-server in haproxy-servers ~}
${ haproxy-server["name"] } ansible_host=${ haproxy-server.network_interface[0].nat_ip_address }
%{ endfor ~}
%{ for backend-server in backend-servers ~}
${ backend-server["name"] } ansible_host=${ backend-server.network_interface[0].nat_ip_address }
%{ endfor ~}
%{ for db-server in db-servers ~}
${ db-server["name"] } ansible_host=${ db-server.network_interface[0].nat_ip_address }
%{ endfor ~}

[haproxy_servers]
%{ for haproxy-server in haproxy-servers ~}
${ haproxy-server["name"] }
%{ endfor ~}

[backend_servers]
%{ for backend-server in backend-servers ~}
${ backend-server["name"] }
%{ endfor ~}

[db_servers]
%{ for db-server in db-servers ~}
${ db-server["name"] }
%{ endfor ~}
