FROM ubuntu:18.04

ARG INSTALL_NODE_VERSION="20.9.0"
ARG INSTALL_CMAKE_VERSION="3.29.3"
ARG INSTALL_NINJA_VERSION="1.12.1"
ARG INSTALL_SDL2_VERSION="2.30.3"
ARG INSTALL_DXC_VERSION="1.8.2405"

# Setup LLVM 17 & Git PPA
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends software-properties-common wget gnupg \
  && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
  && add-apt-repository -y ppa:git-core/candidate \
  && echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-17 main" | tee /etc/apt/sources.list.d/llvm.list \
  && echo "deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-17 main" | tee -a /etc/apt/sources.list.d/llvm.list \
  && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
  && apt-get update

# Install dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends build-essential libsdl2-dev libgtk-3-dev lld llvm clang-17 libfuse2 libssl-dev git unzip llvm-17 llvm-17-tools lld-17 curl file g++-11 libstdc++-11-dev

# Install Node20
RUN curl -LO "https://unofficial-builds.nodejs.org/download/release/v${INSTALL_NODE_VERSION}/node-v${INSTALL_NODE_VERSION}-linux-x64-glibc-217.tar.xz" \
  && mkdir -p /node20217 \
  && tar -xf "node-v${INSTALL_NODE_VERSION}-linux-x64-glibc-217.tar.xz" -C /node20217 --strip-components=1 \
  && rm -f "node-v${INSTALL_NODE_VERSION}-linux-x64-glibc-217.tar.xz"

# Install CMake
COPY ./install-cmake.sh /tmp/
RUN if [ "${INSTALL_CMAKE_VERSION}" != "none" ]; then \
  chmod +x /tmp/install-cmake.sh && /tmp/install-cmake.sh ${INSTALL_CMAKE_VERSION}; \
  fi \
  && rm -f /tmp/install-cmake.sh

# Install Ninja
COPY ./install-ninja.sh /tmp/
RUN if [ "${INSTALL_NINJA_VERSION}" != "none" ]; then \
  chmod +x /tmp/install-ninja.sh && /tmp/install-ninja.sh ${INSTALL_NINJA_VERSION}; \
  fi \
  && rm -f /tmp/install-ninja.sh

# Install SDL2
COPY ./install-sdl2.sh /tmp/
RUN if [ "${INSTALL_SDL2_VERSION}" != "none" ]; then \
  chmod +x /tmp/install-sdl2.sh && /tmp/install-sdl2.sh ${INSTALL_SDL2_VERSION}; \
  fi \
  && rm -f /tmp/install-sdl2.sh

# Install DXC
COPY ./install-dxc.sh /tmp/
RUN if [ "${INSTALL_DXC_VERSION}" != "none" ]; then \
  chmod +x /tmp/install-dxc.sh && /tmp/install-dxc.sh ${INSTALL_DXC_VERSION}; \
  fi \
  && rm -f /tmp/install-dxc.sh
