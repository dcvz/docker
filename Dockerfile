FROM mcr.microsoft.com/devcontainers/cpp:1-ubuntu-22.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends ninja-build libsdl2-dev libgtk-3-dev lld llvm clang-15 libfuse2

ARG INSTALL_SDL2_VERSION_FROM_SOURCE="2.30.3"

COPY ./install-sdl2.sh /tmp/
RUN if [ "${INSTALL_SDL2_VERSION_FROM_SOURCE}" != "none" ]; then \
  chmod +x /tmp/install-sdl2.sh && /tmp/install-sdl2.sh ${INSTALL_SDL2_VERSION_FROM_SOURCE}; \
  fi \
  && rm -f /tmp/install-sdl2.sh

COPY ./install-n64recomp.sh /tmp/
RUN chmod +x /tmp/install-n64recomp.sh && /tmp/install-n64recomp.sh
RUN rm -f /tmp/install-n64recomp.sh

RUN curl -Ssf https://pkgx.sh | sh
