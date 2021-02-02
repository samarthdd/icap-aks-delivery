#!/bin/bash

#Required
domain=$1
commonname=$domain

#Change to your company details
country=IN
state=Karnataka
locality=Bangalore
organization=glasswallsolutions.com
organizationalunit=IT
email=samarth@smalldaytech.com

#Optional
password=dummypassword

if [ -z "$domain" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"

    exit 99
fi

echo "Generating key request for $domain"

crt_name=certificate
key_name=tls

#Create the request
echo "Creating CSR"

openssl req -newkey rsa:2048 -nodes -keyout $key_name.key -x509 -days 365 -out $crt_name.crt  \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"


echo "---------------------------"
echo "-----Below is your crt-----"
echo "---------------------------"
echo
cat $crt_name.crt

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat $key_name.key
