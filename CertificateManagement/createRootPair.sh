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
	touch $SERIAL_FILE_PATH
	echo_message "Index File '$SERIAL_FILE_PATH' created" success
fi
