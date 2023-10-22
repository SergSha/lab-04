
[all]
%{ for nginx-server in nginx-servers ~}
${ nginx-server["name"] } ansible_host=${ nginx-server.network_interface[0].nat_ip_address }
%{ endfor ~}
%{ for backend-server in backend-servers ~}
${ backend-server["name"] } ansible_host=${ backend-server.network_interface[0].nat_ip_address }
%{ endfor ~}
%{ for iscsi-server in iscsi-servers ~}
${ iscsi-server["name"] } ansible_host=${ iscsi-server.network_interface[0].nat_ip_address }
%{ endfor ~}
%{ for db-server in db-servers ~}
${ db-server["name"] } ansible_host=${ db-server.network_interface[0].nat_ip_address }
%{ endfor ~}

[nginx_servers]
%{ for nginx-server in nginx-servers ~}
${ nginx-server["name"] }
%{ endfor ~}

[backend_servers]
%{ for backend-server in backend-servers ~}
${ backend-server["name"] }
%{ endfor ~}

[iscsi_servers]
%{ for iscsi-server in iscsi-servers ~}
${ iscsi-server["name"] }
%{ endfor ~}

[db_servers]
%{ for db-server in db-servers ~}
${ db-server["name"] }
%{ endfor ~}
