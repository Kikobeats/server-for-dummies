#!/bin/bash

help(){
  echo " Use: $0 <client/server>"
}

welcome(){
clear
echo "   _____ _____ _____ _____ _____ _   _ _____ "
echo "  |_   _|  ___/  ___|_   _|_   _| \ | |  __ \ "
echo "    | | | |__ \ \`--.  | |   | | |  \| | |  \/ "
echo "    | | |  __| \`--. \ | |   | | | . \` | | __  "
echo "    | | | |___/\__/ / | |  _| |_| |\  | |_\ \ "
echo "    \_/ \____/\____/  \_/  \___/\_| \_/\____/"
echo
}

test_ping(){
  ping -q -c5 $1 > /dev/null 2>&1
}

show_status(){
  if [ $? -eq 0 ]
  then
    echo "OK"
  else
    echo "Fail"
  fi
}

[ "$(id -u)" != "0" ] && echo " Error. This script must be run as root" 1>&2 && exit 1
[ $# != 1 ] && help && exit 1
[ $1 != "client" -a $1 != "server" ] && help && exit 2
. $PWD/settings.sh
welcome

### MAIN
## Client Test
if [ $1 = "client" ]; then

  echo " [ PING ] "
  echo -n " * Connectivity Primary DNS Private Cloud..."
  test_ping $PRIMARY_DNS
  show_status

  echo -n " * Connectivity Secundary DNS Private Cloud..."
  test_ping $SECUNDARY_DNS
  show_status

  echo -n " * Connectivity Primary DNS Nameserver..."
  test_ping ns1.$DNS_NAME
  show_status

  echo -n " * Connectivity Secundary DNS Nameserver..."
  test_ping ns2.$DNS_NAME
  show_status

  echo " [ DNS ] "
  echo -n " * Connectivity DNS Name..."
  test_ping $DNS_NAME
  show_status

  echo -n " * Connectivity Primary DNS Name..."
  test_ping ns1.$DNS_NAME
  show_status

  echo -n " * Connectivity Secondary DNS Name..."
  test_ping ns2.$DNS_NAME
  show_status

  echo " [ LDAP ] "
  echo -n " * Connectivity LDAP Server..."
  test_ping ldap.$DNS_NAME
  show_status

  echo -n " * Check read LDAP..."
  sudo ldapsearch -x -H ldap://ldap.$DNS_NAME -b "cn=Usuario1,ou=st,o=um,c=es" mobile > /dev/null 2>&1
  show_status

  # echo -n " * Check modify LDAP..."
  # sudo ldamodify -x -H ldap://ldap.$DNS_NAME -b "cn=Usuario1,ou=st,o=um,c=es" mobile > /dev/null 2>&1
  # show_status

  echo " [ SMTP ] "
  echo -n " * Connectivity SMTP Server..."
  test_ping smtp.$DNS_NAME
  show_status

  echo " [ POP ] "
  echo -n " * Connectivity POP Server..."
  test_ping pop.$DNS_NAME
  show_status


## Server Test
else
  echo " [ BIND Check Files ] "
  echo -n " * Check Config file..."
  named-checkconf
  show_status
  # echo -n " * Check Database file..."
  # named-checkzone /var/cache/bind/db.$DNS_NAME.zone
  # show_status


  echo " [ MAIL ] "
  echo " * Creating usuario1..."
  useradd usuario1 -m
  passwd usuario1
  echo " * Creating usuario2..."
  useradd usuario2 -m
  passwd usuario2

  echo " [ LDAP ]"
  echo -n " * Connectivity LDAP local..."
  sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b "cn=config" olcRootDN olcRootPW > /dev/null 2>&1
  show_status
fi