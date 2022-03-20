ARG MAKEFLAGS=-j$(nproc)
FROM espressif/idf:release-v4.4 AS esp-idf

USER root
WORKDIR /root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    pkg-config libffi-dev libssl-dev dfu-util libusb-1.0-0 \
	libglib2.0-dev libpixman-1-dev libgcrypt20-dev

RUN git clone --quiet https://github.com/espressif/qemu.git \
	&& cd qemu \
	&& mkdir -p build \
	&& cd build \
	&& ../configure --target-list=xtensa-softmmu --enable-debug --enable-sanitizers --disable-strip --disable-capstone --disable-vnc \
	&& make vga=no \
	&& make install \
	&& cd ../.. \ 
	&& rm -rf qemu