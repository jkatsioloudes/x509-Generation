#!/bin/bash

################# APACHE ########
# prep the apache user dirs
X509DIR=$PWD
cd ${X509DIR}
cd apache
touch ipsec.conf ipsec.secrets
mkdir ipsec
cd ipsec
mkdir cacerts certs csr private
cd ../

# generate the apache's private key
openssl genrsa  -out ipsec/private/apache.key.pem 1024
chmod 400 ipsec/private/apache.key.pem

# generate the apache cert
openssl req -config ./openssl.cnf \
      -key ipsec/private/apache.key.pem \
      -new -sha256 \
      -out ipsec/csr/apache.csr.pem


######### INTERMDEDIATE CA SIGNS APACHE CSR #################
# send the apache cert csr to the intermediate ca
cd ${X509DIR}
cp ./apache/ipsec/csr/apache.csr.pem ./ca/intermediate/unsigned/

# get the apache cert signed by the intermediate cert
cd ./ca/intermediate/
openssl ca -config ./openssl.cnf \
      -days 375 \
      -notext -md sha256 \
      -in unsigned/apache.csr.pem \
      -out signed/apache.cert.pem

# verify the cert
openssl x509 -noout -text -in signed/apache.cert.pem
 
# return it to the apache
cd ${X509DIR}
cp ./ca/intermediate/signed/apache.cert.pem ./apache/ipsec/certs  
chmod 444 ./apache/ipsec/certs/apache.cert.pem


################# PUT THE ROOT CERT ON ALL CLIENTS ########
cd ${X509DIR}
cp ./ca/root/certs/ca.cert.pem ./apache/ipsec/cacerts/

echo "/// SCRIPT FINISHED SUCCESSFULLY! ///"
