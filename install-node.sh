#!/usr/bin/env bash

set -e

NODE_VERSION=${1:-"none"}

if [ "${NODE_VERSION}" = "none" ]; then
    echo "No Node version specified, skipping Node installation"
    exit 0
fi

# Cleanup temporary directory and associated files when exiting the script.
cleanup() {
    EXIT_CODE=$?
    set +e
    if [[ -n "${TMP_DIR}" ]]; then
        echo "Executing cleanup of tmp files"
        rm -Rf "${TMP_DIR}"
    fi
    exit $EXIT_CODE
}
trap cleanup EXIT

echo "Installing Node..."

TMP_DIR=$(mktemp -d -t node-XXXXXXXXXX)

echo "${TMP_DIR}"
cd "${TMP_DIR}"

curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
bash n ${NODE_VERSION}

# Build and install glibc 2.28:
wget -c https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz
tar -zxf glibc-2.28.tar.gz
mkdir glibc-build
cd glibc-build
../glibc-2.28/configure --prefix=/opt/glibc-2.28
make -j $(nproc)
make install

# Patch the installed Node.js 20 to work with /opt/glibc-2.28 instead:
patchelf --set-interpreter /opt/glibc-2.28/lib/ld-linux-x86-64.so.2 --set-rpath /opt/glibc-2.28/lib/:/lib/x86_64-linux-gnu/:/usr/lib/x86_64-linux-gnu/ /usr/local/bin/node

echo "Node installed successfully."
