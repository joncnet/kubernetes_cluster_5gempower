
sed -i 's/CLIENT_SERVER_ADDRESS/'$client_server_address'/g' /etc/ipsec.conf
sed -i 's/CLIENT_SERVER_ID/'$client_server_id'/g' /etc/ipsec.conf
sed -i 's/CLIENT_CLIENT_USER/'$client_client_user'/g' /etc/ipsec.conf
sed -i 's/SERVER_SERVER_ID/'$server_server_id'/g' /etc/ipsec.conf
sed -i 's/SERVER_CLIENT_SUBNET/'$server_client_subnet'/g' /etc/ipsec.conf
sed -i 's/CLIENT_SERVER_SUBNET/'$client_server_subnet'/g' /etc/ipsec.conf

if [ ! -z "$has_own_subnet" ]
then
    sed -i '/rightsourceip/s/#//g' /etc/ipsec.conf
else
    sed -i '/rightsubnet/s/#//g' /etc/ipsec.conf
fi

if [ ! -z "$client_client_ip" ]
then
    sed -i '/leftsourceip/s/#//g' /etc/ipsec.conf
    sed -i 's/CLIENT_CLIENT_IP/'$client_client_ip'/g' /etc/ipsec.conf
else
    sed -i '/leftsubnet/s/#//g' /etc/ipsec.conf
    sed -i 's/CLIENT_CLIENT_SUBNET/'$client_client_subnet'/g' /etc/ipsec.conf
fi

#sed -i 's/SERVER_SUBNET/'$server_subnet'/g' /rules.sh

sed -i 's/CLIENT_CLIENT_USER/'$client_client_user'/g' /etc/ipsec.secrets
sed -i 's/CLIENT_CLIENT_PASS/'$client_client_pass'/g' /etc/ipsec.secrets
sed -i 's/SERVER_CLIENT_USER/'$server_client_user'/g' /etc/ipsec.secrets
sed -i 's/SERVER_CLIENT_PASS/'$server_client_pass'/g' /etc/ipsec.secrets
