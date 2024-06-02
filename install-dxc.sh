#!/usr/bin/env bash

set -e

DXC_VERSION=${1:-"none"}

if [ "${DXC_VERSION}" = "none" ]; then
    echo "No DXC version specified, skipping DXC installation"
    exit 0
fi

# Cleanup temporary directory and associated files when exiting the script.
cleanup() {
    EXIT_CODE=$?
    set +e
    if [[ -n "${BUILD_DIR}" ]]; then
        echo "Executing cleanup of tmp files"
        rm -Rf "${BUILD_DIR}"
    fi
    exit $EXIT_CODE
}
trap cleanup EXIT

echo "Installing DXC version ${DXC_VERSION}..."

# Set up build directory
BUILD_DIR=$(mktemp -d -t dxc-XXXXXXXXXX)

# Clone the repository and checkout the specified version
git clone --recursive https://github.com/microsoft/DirectXShaderCompiler "${BUILD_DIR}"
cd "${BUILD_DIR}"
git checkout "v${DXC_VERSION}"

# Initialize and update submodules
git submodule update --init

# Create build directory and configure the build with CMake
mkdir -p build
cd build
# use clang
cmake .. -GNinja -C../cmake/caches/PredefinedParams.cmake -DSPIRV_BUILD_TESTS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++-17 -DCMAKE_C_COMPILER=clang-17 -DCMAKE_CXX_FLAGS="-stdlib=libc++" -DCMAKE_EXE_LINKER_FLAGS="-stdlib=libc++"

# Build the project using Ninja
ninja

# Install the binaries
cp -r bin/* "/usr/local/bin/"
cp -r lib/* "/usr/local/lib/"

echo "DXC installation complete."
 