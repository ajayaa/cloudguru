openssl genrsa -des3 -out server.key 2048
openssl rsa -in server.key -out server.key.insecure
mv server.key server.key.secure
mv server.key.insecure server.key

# Create CSR
openssl req -new -key server.key -out server.csr

# Create self-signed certificate
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
