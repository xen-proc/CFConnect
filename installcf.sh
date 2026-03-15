#!/bin/bash

#cloudflared does not autoupdate if not ran as a service.

appname="cloudflared"
dir="/opt/cloudflared/"
apppath="$dir$appname"

# Detect architecture for correct download
arch=$(uname -m)
if [ "$arch" = "arm64" ]; then
    pkg="cloudflared-darwin-arm64.tgz"
else
    pkg="cloudflared-darwin-amd64.tgz"
fi

# Check if cloudflared is installed. Update if so, install if not.
if [ -f "$apppath" ]; then
    echo "Cloudflared found. Checking for updates..."
    "$apppath" update
    exit 0
else
    echo "Cloudflared not installed. Installing..."
    if [ ! -d "$dir" ]; then
        mkdir "$dir"
    fi
    curl -sL "https://github.com/cloudflare/cloudflared/releases/latest/download/$pkg" | tar -xz -C "$dir"
fi
