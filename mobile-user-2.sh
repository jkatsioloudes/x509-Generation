#!/bin/bash

################# MOBILE-USER-2 ########
# prep the mobile user dirs
X509DIR=$PWD
cd ${X509DIR}
cd mobile-user-2
touch ipsec.conf ipsec.secrets
mkdir ipsec
cd ipsec
mkdir cacerts certs csr private
cd ../

# generate the second mobile user key
openssl genrsa  -out ipsec/private/mobile-user-2.key.pem 1024
chmod 400 ipsec/private/mobile-user-2.key.pem

# generate the mobile-user-2 cert
openssl req -config ./openssl.cnf \
      -key ipsec/private/mobile-user-2.key.pem \
      -new -sha256 \
      -out ipsec/csr/mobile-user-2.csr.pem


######### INTERMDEDIATE CA SIGNS MOBILE-USER-2 CSR #################
# send the mobile-user-2 cert csr to the intermediate ca
cd ${X509DIR}
cp ./mobile-user-2/ipsec/csr/mobile-user-2.csr.pem ./ca/intermediate/unsigned/

# get the mobile-user-2 cert signed by the intermediate cert
cd ./ca/intermediate/
openssl ca -config ./openssl.cnf \
      -days 375 \
      -notext -md sha256 \
      -in unsigned/mobile-user-2.csr.pem \
      -out signed/mobile-user-2.cert.pem

# verify the cert
openssl x509 -noout -text -in signed/mobile-user-2.cert.pem
 
# return it to the mobile-user-2
cd ${X509DIR}
cp ./ca/intermediate/signed/mobile-user-2.cert.pem ./mobile-user-2/ipsec/certs  
chmod 444 ./mobile-user-2/ipsec/certs/mobile-user-2.cert.pem


################# PUT THE ROOT CERT ON ALL CLIENTS ########
cd ${X509DIR}
cp ./ca/root/certs/ca.cert.pem ./mobile-user-2/ipsec/cacerts/

echo "/// SCRIPT FINISHED SUCCESSFULLY! ///"
