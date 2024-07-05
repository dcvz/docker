#!/usr/bin/env bash

set -e

NINJA_VERSION=${1:-"none"}

if [ "${NINJA_VERSION}" = "none" ]; then
    echo "No Ninja version specified, skipping Ninja installation"
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

echo "Installing Ninja..."

architecture=$(dpkg --print-architecture)
case "${architecture}" in
    arm64)
        ARCH=aarch64 ;;
    amd64)
        ARCH=x86_64 ;;
    *)
        echo "Unsupported architecture ${architecture}."
        exit 1
        ;;
esac

TMP_DIR=$(mktemp -d -t ninja-XXXXXXXXXX)

echo "${TMP_DIR}"
cd "${TMP_DIR}"

# Download and install Ninja from source
wget https://github.com/ninja-build/ninja/archive/v${NINJA_VERSION}.tar.gz -O ninja-${NINJA_VERSION}.tar.gz
tar -xzf ninja-${NINJA_VERSION}.tar.gz
cd ninja-${NINJA_VERSION}
./configure.py --bootstrap

# Move the ninja executable to /usr/local/bin
mv ninja /usr/local/bin/ninja

echo "Ninja installed successfully."
