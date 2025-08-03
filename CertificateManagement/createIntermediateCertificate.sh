#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -eq 0 ]; then
  echo "Error: No argument provided." >&2
  echo "Usage: $0 -n <CertificateCommonName>" >&2 # $0 is the script's name
  exit 1 # Exit with a non-zero status to indicate an error
fi

# If we reach here, an argument was passed
PASSED_ARG="$1"
echo "Argument received: $PASSED_ARG"

while getopts "n:" opt; do
	case $opt in 
		n)
			NAME="$OPTARG"
			;;
		:)
			echo "Options -$OPTARG requires an argument." >&2
			exit 1
			;;
		*) # Fallback for unexpected argument (shouldn't happen with getopt unless -- is missing)
		echo "Internal error: unrecognized option '$1'" >&2
		exit 1
		;;
	esac
done

# Shift off the options so that remaining arguments (if any) are
# accessible starting from $1
shift $((OPTIND - 1))

echo "Name: $NAME"

PROJECT_PATH="/workspaces/homelab"
CERTIFICATE_FOLDER_PATH="$PROJECT_PATH/certs"
ROOT_CA_FOLDER_PATH="$CERTIFICATE_FOLDER_PATH/root/ca"

ROOT_PRIVATE_FOLDER_PATH="$ROOT_CA_FOLDER_PATH/private"
ROOT_CA_KEY_FILE_PATH="$ROOT_PRIVATE_FOLDER_PATH/ca.key.pem"

ROOT_CERTS_FOLDER_PATH="$ROOT_CA_FOLDER_PATH/certs"
ROOT_CA_FILE_PATH="$ROOT_CERTS_FOLDER_PATH/ca.cert.pem"
ROOT_OPENSSL_CONF="$ROOT_CA_FOLDER_PATH/openssl.conf"

INTERMEDIATE_CA_FOLDER_PATH="$CERTIFICATE_FOLDER_PATH/root/ca/$NAME"
INTERMEDIATE_CERTS_FOLDER_PATH="$INTERMEDIATE_CA_FOLDER_PATH/certs"
INTERMEDIATE_CRL_FOLDER_PATH="$INTERMEDIATE_CA_FOLDER_PATH/crl"
INTERMEDIATE_NEWCERTS_FOLDER_PATH="$INTERMEDIATE_CA_FOLDER_PATH/newcerts"
INTERMEDIATE_PRIVATE_FOLDER_PATH="$INTERMEDIATE_CA_FOLDER_PATH/private"
INTERMEDIATE_CSR_FOLDER_PATH="$INTERMEDIATE_CA_FOLDER_PATH/csr"

INTERMEDIATE_CRL_FOLDER_PATH="$INTERMEDIATE_CA_FOLDER_PATH/crl"
INTERMEDIATE_NEWCERTS_FOLDER_PATH="$INTERMEDIATE_CA_FOLDER_PATH/newcerts"
REQUIRED_PERMS="700"

INDEX_FILE_PATH="$INTERMEDIATE_CA_FOLDER_PATH/index.txt"
SERIAL_FILE_PATH="$INTERMEDIATE_CA_FOLDER_PATH/serial"
CRLNUMBER_FILE_PATH="$INTERMEDIATE_CA_FOLDER_PATH/crlnumber"
OPENSSL_CONF="$INTERMEDIATE_CA_FOLDER_PATH/openssl.conf"

INTERMEDIATE_CA_KEY_FILE_PATH="$INTERMEDIATE_PRIVATE_FOLDER_PATH/$NAME.key.pem"
INTERMEDIATE_CA_FILE_PATH="$INTERMEDIATE_CERTS_FOLDER_PATH/$NAME.cert.pem"
INTERMEDIATE_CSR_FILE_PATH="$INTERMEDIATE_CSR_FOLDER_PATH/$NAME.csr.pem"

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

	cat <<EOF > "$confFilePath"
[ ca ]
# \`man ca\`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = $INTERMEDIATE_CA_FOLDER_PATH
certs             = $INTERMEDIATE_CERTS_FOLDER_PATH
crl_dir           = $INTERMEDIATE_CRL_FOLDER_PATH
new_certs_dir     = $INTERMEDIATE_NEWCERTS_FOLDER_PATH
database          = $INDEX_FILE_PATH
serial            = $SERIAL_FILE_PATH
RANDFILE          = $INTERMEDIATE_PRIVATE_FOLDER_PATH/.rand

# The root key and root certificate.
private_key       = $INTERMEDIATE_CA_KEY_FILE_PATH
certificate       = $INTERMEDIATE_CA_FILE_PATH

# For certificate revocation lists.
crlnumber         = $CRLNUMBER_FILE_PATH
crl               = $INTERMEDIATE_CRL_FOLDER_PATH/crl/$NAME.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_loose

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
organizationalUnitName_default  = NSCubed Certificate Authority
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
create_directory $INTERMEDIATE_CA_FOLDER_PATH
create_directory $INTERMEDIATE_CERTS_FOLDER_PATH
create_directory $INTERMEDIATE_CRL_FOLDER_PATH
create_directory $INTERMEDIATE_NEWCERTS_FOLDER_PATH
create_directory $INTERMEDIATE_PRIVATE_FOLDER_PATH
create_directory $INTERMEDIATE_CSR_FOLDER_PATH
echo_message "Directories created"

echo_message "Setting Permissions"
CURRENT_PERMS=$(stat -c "%a" "$INTERMEDIATE_PRIVATE_FOLDER_PATH")
if [ "$CURRENT_PERMS" -eq "$REQUIRED_PERMS" ]; then
	echo_message "Permissions already set." warn
else
	chmod 700 $INTERMEDIATE_PRIVATE_FOLDER_PATH
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

echo_message "Create CRL Number file"
if [ -e "$CRLNUMBER_FILE_PATH" ]; then
	echo_message "File '$CRLNUMBER_FILE_PATH' already exists." warn
else
	echo 1000 > $CRLNUMBER_FILE_PATH
	echo_message "CRLNUMBER File '$CRLNUMBER_FILE_PATH' created" success
fi

echo_message "OpenSSL Configuration File"
if [ -e "$OPENSSL_CONF" ]; then
	echo_message "File '$OPENSSL_CONF' already exists." warn
else
	create_openssl_conf "$OPENSSL_CONF" "$INTERMEDIATE_CA_FOLDER_PATH"
	echo_message "OpenSSL Configuration '$OPENSSL_CONF' created" success
fi

echo_message "Create $NAME CA Key"
if [ -e "$INTERMEDIATE_CA_KEY_FILE_PATH" ]; then
	echo_message "$NAME CA Key already exists" 
	echo_message "Skipping $NAME CA Key creation" warn
else
	echo_message "Enter passphrase when prompted"
	openssl genrsa -aes256 -out $INTERMEDIATE_CA_KEY_FILE_PATH 4096
	chmod 400 $INTERMEDIATE_CA_KEY_FILE_PATH
	echo_message "Key Created and Permissions set" success
fi

echo_message "Certificate Signing Request (CSR)"
if [ -e "$INTERMEDIATE_CSR_FILE_PATH" ]; then
	echo_message "$NAME CSR already exists" 
	echo_message "Skipping $NAME CSR creation" warn
else
	echo_message "Enter passphrase when prompted"
	openssl req -config $OPENSSL_CONF -new -sha256 -key $INTERMEDIATE_CA_KEY_FILE_PATH -out $INTERMEDIATE_CSR_FILE_PATH
	echo_message "'$INTERMEDIATE_CSR_FILE_PATH' CSR created." success
fi

echo_message "Create $NAME certificate"
if [ -e "$INTERMEDIATE_CA_FILE_PATH" ]; then
	echo_message "$NAME Cert already exists" 
	echo_message "Skipping $NAME Cert creation" warn
else
	echo_message "Enter passphrase when prompted"
	openssl ca -config $ROOT_OPENSSL_CONF -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in $INTERMEDIATE_CSR_FILE_PATH -out $INTERMEDIATE_CA_FILE_PATH
	chmod 444 $INTERMEDIATE_CA_FILE_PATH
	echo_message "'$INTERMEDIATE_CA_FILE_PATH' Certificate created." success
fi

echo_message "Verify $NAME Certificate"
openssl x509 -noout -text -in $INTERMEDIATE_CA_FILE_PATH

echo_message "Verify $NAME Certificate against Root CA"
openssl verify -CAfile $ROOT_CA_FILE_PATH $INTERMEDIATE_CA_FILE_PATH
