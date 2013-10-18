#!/bin/bash

O="/O=Georgia Tech Network Operations and Internet Security Lab/OU=Project Bismark"
CN="/CN=downloads.projectbismark.net"
EA="/emailAddress = ssl-admin@projectbismark.net"  

CERTNAME=opkgcert.pem
PUBKEY=serverCA.pem

#generate both pub & priv keys in PEM format
openssl req -x509 -nodes -days 1800 \
  -subj "/C=US/ST=Georgia/L=Atlanta/$O$CN$EA" \
  -newkey rsa:2048 -keyout $CERTNAME -out $CERTNAME

openssl verify $CERTNAME


#extract public key from CERTNAME file                                                                                  
openssl x509 -in $CERTNAME -pubkey -outform PEM -out $PUBKEY 

gunzip $(find $1 -name Packages.gz)

list=$(find $1 -name Packages)

for i in $list
do
    openssl smime -sign -in $i -signer $CERTNAME -binary -outform PEM -out $i.sig
done

gzip $(find $1 -name Packages)

#extract public key from CERTNAME file
openssl x509 -in $CERTNAME -pubkey -outform PEM -out $PUBKEY

echo "** Please, update the $PUBKEY key in bismark-opkg-keys package. **"
