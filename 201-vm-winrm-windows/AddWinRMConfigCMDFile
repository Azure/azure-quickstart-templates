call winrm set winrm/config/service/auth @{Basic="true"}
call winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="%1";CertificateThumbprint="%2"}
