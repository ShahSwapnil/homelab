#!/bin/bash

PROJECT_PATH="/workspaces/homelab"
CERTIFICATE_FOLDER_PATH="$PROJECT_PATH/certs"

ROOT_CA_FOLDER_PATH="$CERTIFICATE_FOLDER_PATH/root/ca"
ROOT_CERTS_FOLDER_PATH="$ROOT_CA_FOLDER_PATH/certs"
ROOT_CRL_FOLDER_PATH="$ROOT_CA_FOLDER_PATH/crl"
ROOT_NEWCERTS_FOLDER_PATH="$ROOT_CA_FOLDER_PATH/newcerts"
ROOT_PRIVATE_FOLDER_PATH="$ROOT_CA_FOLDER_PATH/private"
REQUIRED_PERMS="700"

INDEX_FILE_PATH="$ROOT_CA_FOLDER_PATH/index.txt"
SERIAL_FILE_PATH="$ROOT_CA_FOLDER_PATH/serial"
OPENSSL_CONF="$ROOT_CA_FOLDER_PATH/openssl.conf"

ROOT_CA_KEY_FILE_PATH="$ROOT_PRIVATE_FOLDER_PATH/ca.key.pem"
ROOT_CA_FILE_PATH="$ROOT_CERTS_FOLDER_PATH/ca.cert.pem"
ROOT_CA_PFX_FILE_PATH="$ROOT_CERTS_FOLDER_PATH/NSCubedRootCACertificate.pfx"

echo_message() {
	local message="$1"
	local level="$2"

	if [ -z "$level" ]; then
		level="info"
	fi

	case "$level" in 
		info)
			echo -e "\033[35m$message\033[0m"
			;;
		error)
			echo -e "\033[31m$message\033[0m"
			;;
		success)
			echo -e "\033[32m$message\033[0m"
			;;
		warn)
			echo -e "\033[33m$message\033[0m"
			;;
	esac
}

create_directory() {
	local folder_path="$1"

	if [ -d "$folder_path" ]; then
		echo_message "Directory '$folder_path' exists."
		echo_message "Skipping Directory creation" warn
	else
		echo_message "Creating Directory '$folder_path'"
		mkdir -p $folder_path
		echo_message "Created directory '$folder_path'." success
	fi	
}

create_openssl_conf() {
	local confFilePath="$1"
	local rootPath="$2"

	cat <<EOF > "$confFilePath"
[ ca ]
# \`man ca\`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = $rootPath
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

# The root key and root certificate.
private_key       = $dir/private/ca.key.pem
certificate       = $dir/certs/ca.cert.pem

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of \'man ca\`.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the \'ca\` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the \'req\` tool (\'man req\`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
commonName                      = Common Name
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = US
stateOrProvinceName_default     = Michigan
localityName_default            = Macomb
0.organizationName_default      = NSCubed
organizationalUnitName_default  = NSCubed Root Certificate Authority
emailAddress_default            = admin@nscubed.com

[ v3_ca ]
# Extensions for a typical CA (\'man x509v3_config\`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (\'man x509v3_config\`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (\'man x509v3_config\`).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates (\'man x509v3_config\`).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
# Extension for CRLs (\'man x509v3_config\`).
authorityKeyIdentifier=keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (\'man ocsp\`).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
EOF
}

echo_message "Starting Script" 

echo_message "Creating Directories"
create_directory $ROOT_CA_FOLDER_PATH
create_directory $ROOT_CERTS_FOLDER_PATH
create_directory $ROOT_CRL_FOLDER_PATH
create_directory $ROOT_NEWCERTS_FOLDER_PATH
create_directory $ROOT_PRIVATE_FOLDER_PATH
echo_message "Directories created"

echo_message "Setting Permissions"
CURRENT_PERMS=$(stat -c "%a" "$ROOT_PRIVATE_FOLDER_PATH")
if [ "$CURRENT_PERMS" -eq "$REQUIRED_PERMS" ]; then
	echo_message "Permissions already set." warn
else
	chmod 700 $ROOT_PRIVATE_FOLDER_PATH
	echo_message "Permissions set" success
fi

echo_message "Create Index File"
if [ -e "$INDEX_FILE_PATH" ]; then
	echo_message "File '$INDEX_FILE_PATH' already exists." warn
else
	touch $INDEX_FILE_PATH
	echo_message "Index File '$INDEX_FILE_PATH' created" success
fi

echo_message "Create Serial file"
if [ -e "$SERIAL_FILE_PATH" ]; then
	echo_message "File '$SERIAL_FILE_PATH' already exists." warn
else
	echo 1000 > $SERIAL_FILE_PATH
	echo_message "Index File '$SERIAL_FILE_PATH' created" success
fi

echo_message "OpenSSL Configuration File"
if [ -e "$OPENSSL_CONF" ]; then
	echo_message "File '$OPENSSL_CONF' already exists." warn
else
	create_openssl_conf "$OPENSSL_CONF" "$ROOT_CA_FOLDER_PATH"
	echo_message "OpenSSL Configuration '$OPENSSL_CONF' created" success
fi
echo_message "Create Root CA Key"
if [ -e "$ROOT_CA_KEY_FILE_PATH" ]; then
	echo_message "Root CA Key already exists" 
	echo_message "Skipping Root CA Key creation" warn
else
	echo_message "Enter passphrase when prompted"
	openssl genrsa -aes256 -out $ROOT_CA_KEY_FILE_PATH 4096
	chmod 400 $ROOT_CA_KEY_FILE_PATH
	echo_message "Key Created and Permissions set" success
fi

echo_message "Create Root Certificate"
if [ -e "$ROOT_CA_FILE_PATH" ]; then
	echo_message "Root CA already exists"
	echo_message "Skipping Root CA Creation" warn
else
	echo_message "Enter Information when prompted"
	openssl req -config $OPENSSL_CONF -key $ROOT_CA_KEY_FILE_PATH -new -x509 -days 7300 -sha256 -extensions v3_ca -out $ROOT_CA_FILE_PATH
	chmod 444 $ROOT_CA_FILE_PATH
	echo_message "Cert Created and Permissions set" success
fi

echo_message "Verify Root Certificate"
openssl x509 -noout -text -in $ROOT_CA_FILE_PATH

echo_message "PFX Certificate"
if [ -e "$ROOT_CA_PFX_FILE_PATH" ]; then
	echo_message "Root CA PFX already exists"
	echo_message "Skipping Root CA PFX Creation" warn
else
	openssl pkcs12 -export -out $ROOT_CA_PFX_FILE_PATH -inkey $ROOT_CA_KEY_FILE_PATH -in $ROOT_CA_FILE_PATH
	echo_message "PFX Cert created" success
fi

