#!/bin/bash

# exit on fail, and echo commands that are ran.
set -e

# Parameters
port="${ELEMENTARY_SERVE_PORT:-8080}"

# Create working directory
workdir="$(mktemp -d)"

# Make sure temporary directory is cleaned up
rm_workdir() {
    rm -rf "$workdir"
}
trap rm_workdir EXIT

cd $workdir

# Blob destination
account_name=$AZ_ACCOUNT_NAME
account_key=${AZ_ACCOUNT_KEY:-""}
container_name=$AZ_CONTAINER_NAME
blob_name=$AZ_BLOB_NAME

# try this: https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-blobs-download

# Download report
if [ "$account_key" != "" ]; then
    az storage blob download --account-name $account_name --account-key $account_key --container-name $container_name --name $blob_name --file ./index.html
else
    az storage blob download --account-name $account_name --container-name $container_name --name $blob_name --file ./index.html
fi

# Serve the report on chosen port
python3 -m http.server $port
