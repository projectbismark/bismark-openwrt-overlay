#!/bin/bash

O="/O=Georgia Tech Network Operations and Internet Security Lab/OU=Project Bismark"           
CN="/CN=downloads.projectbismark.net"                                                                                 
EA="/emailAddress = ssl-admin@projectbismark.net"                                                                                  

CERTNAME=opkgcert.pem                                                                                                     
PUBKEY=opkgpub.key                                                                                                           

if [ "$#" -ne 3 ]; then                                                                                                            
    echo "usage: signopkglist.sh <path-to-Packages-list-file> <name-for-private-key> <name-for-public-key>"                        
    echo "example: sighopkglist.sh /path/to/Packages opkgcert.pem opkgpub.key"                      
    exit 1                                                                                                                         
fi                                                                                                                                 

CERTNAME=$2                                                                                                                     
PUBKEY=$3                                                                                                                          

if [ ! -e $1 ]; then                                                                                                               
    echo "Package file $1 does not exist"                                                                                  
    exit 1                                                                                                                         
fi                                                                                                                                 

#generate both pub & priv keys in PEM format                                                                              
openssl req -x509 -nodes -days 1800 \                                                                                     
  -subj "/C=US/ST=Georgia/L=Atlanta/$O$CN$EA" \                                                                 
  -newkey rsa:2048 -keyout $CERTNAME -out $CERTNAME                                                                                                                                                                                        

openssl verify $CERTNAME                                                                                                                                                                                                                                        

#sign files list                                                                                                                   
openssl smime -sign -in $1 -signer $CERTNAME -binary -outform PEM -out $1.sig                       

#extract public key from CERTNAME file                                                                                  
openssl x509 -in $CERTNAME -pubkey -outform PEM -out $PUBKEY 