#!/bin/bash

ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/server-key.pem
ipsec pki --pub --in /etc/ipsec.d/private/server-key.pem --type rsa \
    | ipsec pki --issue --lifetime 1825 \
        --cacert /etc/ipsec.d/cacerts/ca-cert.pem \
        --cakey /etc/ipsec.d/private/ca-key.pem \
        --dn "CN=$server_server_id" --san "$server_server_id" \
        --flag serverAuth --flag ikeIntermediate --outform pem \
    >  /etc/ipsec.d/certs/server-cert.pem
