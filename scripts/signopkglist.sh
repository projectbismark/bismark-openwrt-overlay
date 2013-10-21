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

   #extract public key from CERTNAME file
   openssl x509 -in $CERTPATH -pubkey -outform PEM -out $PUBKEY

   if [ -f $PUBKEYPATH/$PUBKEY ];
   then
      echo "FOUND in [$PUBKEYPATH/$PUBKEY]..."
      if diff -q $PUBKEY $PUBKEYPATH/$PUBKEY > /dev/null ;
      then
         echo "Public keys MATCHED in bismark-opkg-keys package, nothing to do."
      else
         echo "Public keys DIFFER. Updating in [$PUBKEYPATH/$PUBKEY], Please re-run deploy-release.sh to update bismark-opkg-keys package."
         mv $PUBKEY $PUBKEYPATH/$PUBKEY
      fi

      for filename in $(find $1 -name Packages.gz); do
         zcat $filename | openssl smime -sign -signer $CERTPATH -binary -outform PEM -out $(echo ${filename}| cut -d"." -f1).sig
      done
   else
      echo "NOT FOUND. Isn't the Package bismark-opkg-keys installed ?"
   fi
else
   echo "NOT FOUND. Not signing packages list. Please run generatecert.sh script to generate self-signed certificate."
fi
