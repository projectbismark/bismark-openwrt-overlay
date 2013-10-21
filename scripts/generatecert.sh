#!/bin/bash

O="O=Georgia Tech Network Operations and Internet Security Lab/OU=Project Bismark/"
CN="CN=downloads.projectbismark.net/"
EA="emailAddress=ssl-admin@projectbismark.net"  

CERTNAME=bismark_signing_key.pem
CERTPATH=$HOME/.$CERTNAME

#generate both pub & priv keys in PEM format
openssl req -x509 -nodes -days 1800 \
   -subj "/C=US/ST=Georgia/L=Atlanta/$O$CN$EA" \
   -newkey rsa:2048 -keyout $CERTPATH -out $CERTPATH

openssl verify $CERTPATH

echo "Generated signer certificate in $CERTPATH."