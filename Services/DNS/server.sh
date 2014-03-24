write_database(){
echo "\$TTL  604800
@ IN  SOA ns1.$DNS_NAME. root.ns1.$DNS_NAME. (
            1   ; Serial
       604800   ; Refresh
        86400   ; Retry
      2419200   ; Expire
       604800 ) ; Negative Cache TTL

@             IN      NS         ns1.$DNS_NAME.
ns1           IN      A          $PRIMARY_DNS
@             IN      NS         ns2.$DNS_NAME.

ns2           IN      A          $SECONDARY_DNS
$DNS_NAME.    IN      A          $PRIMARY_DNS

smtp          IN      CNAME      $DNS_NAME.
pop           IN      CNAME      $DNS_NAME.
ldap          IN      CNAME      $DNS_NAME.
www           IN      CNAME      $DNS_NAME.
" > /etc/bind/db.$DNS_NAME.zone
}

write_config_local_server(){
echo "zone \"$DNS_NAME.\" IN {
  type master;
  file \"/etc/bind/db.$DNS_NAME.zone\";
  allow-transfer {$SECONDARY_DNS;};
  }; " > /etc/bind/named.conf.local

}

write_config_local_client(){
echo " * Configuring local file..."
echo "zone \"$DNS_NAME.\" IN {
  type slave;
  file \"/var/cache/bind/db.$DNS_NAME.zone\";
  masters {$PRIMARY_DNS;};
};
" > /etc/bind/named.conf.local
}

write_cofig_options(){
echo "options {
  directory \"/var/cache/bind\";
  //dnssec-validation auto;
  auth-nxdomain no;         # conform to RFC1035
  listen-on-v6 { any; };
   forwarders {$FORWARDERS}; # UM DNS
  }; " > /etc/bind/named.conf.options

}

### Main
echo " * Installing DNS..."
apt-get -y install bind9

answer="undefined"
while [ $answer != "primary" -a $answer != "secondary" ]; do
  read -p " Can you configure DNS? [primary/secondary]: " answer
done
if [ $answer = "primary" ] ; then

  echo " * Configuring local file..."
  write_config_local_server

  echo " * Configuring local options..."
  write_cofig_options

  echo " * Configuring zone file..."
  write_database

else
  write_config_local_client

fi