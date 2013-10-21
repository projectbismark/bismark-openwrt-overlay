#!/bin/bash

O="O=Georgia Tech Network Operations and Internet Security Lab/OU=Project Bismark/"
CN="CN=downloads.projectbismark.net/"
EA="emailAddress=ssl-admin@projectbismark.net"  

SSLDIR=ssl

CERTNAME=opkgcert.pem
PUBKEY=serverCA.pem

#using existing keys to sign pkgs
if [ ! -f $SSLDIR/$PUBKEY ];
then
   echo "Public key NOT found. Generating certificate and public key in $SSLDIR directory..."

   mkdir -p $SSLDIR

   #generate both pub & priv keys in PEM format
   openssl req -x509 -nodes -days 1800 \
     -subj "/C=US/ST=Georgia/L=Atlanta/$O$CN$EA" \
     -newkey rsa:2048 -keyout $SSLDIR/$CERTNAME -out $SSLDIR/$CERTNAME

   openssl verify $SSLDIR/$CERTNAME

   #extract public key from CERTNAME file
   openssl x509 -in $SSLDIR/$CERTNAME -pubkey -outform PEM -out $SSLDIR/$PUBKEY
else
   echo "Public key found: $SSLDIR/$PUBKEY. Continuing package signing..."
fi


for filename in $(find $1 -name Packages.gz); do
    zcat $filename | openssl smime -sign -signer $SSLDIR/$CERTNAME -binary -outform PEM -out $(echo ${filename}| cut -d"." -f1).sig
done


echo "** Please, update the $SSLDIR/$PUBKEY key in bismark-opkg-keys package. **"
