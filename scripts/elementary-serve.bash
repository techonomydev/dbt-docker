#!/bin/bash


# exit on fail, and echo commands that are ran.
set -xe

# Parameters
port="${ELEMENTARY_SERVE_PORT:-8080}"

# Create working directory
workdir="$(mktemp -d)"
cd $workdir

# Make sure temporary directory is cleaned up
rm_workdir() {
    rm -rf "$workdir"
}
trap rm_workdir EXIT

# Generate edr report, passing all cli arguments to edr
edr report --file-path index.html $@

# Serve the report on chosen port
python -m http.server $port

