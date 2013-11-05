#!/bin/bash

CERTNAME=bismark_signing_key.pem
CERTPATH=$HOME/.$CERTNAME
PUBKEY=serverCA.pem
PUBKEYPATH=bismark-feeds/bismark/utils/bismark-opkg-keys/files/etc/ssl

echo "Checking for signer certificate in [$CERTPATH]"

if [ -f $CERTPATH ];
then
   echo "FOUND. Checking bismark-opkg-keys for server's pubkey ..."
   openssl verify $CERTPATH

   for filename in $(find $1 -name Packages.gz); do
      cat $filename | openssl smime -sign -signer $CERTPATH -binary -outform PEM -out $(echo ${filename%.gz}.sig)
   done
else
   echo "NOT FOUND. Not signing packages list. Please run generatecert.sh script to generate self-signed certificate."
fi
