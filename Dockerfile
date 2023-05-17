ARG MAKEFLAGS=-j$(nproc)
# FROM espressif/idf:release-v4.4 AS esp-idf
FROM espressif/idf:v5.0.2 AS esp-idf

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
	
# a list of optional but useful ports this container might listen on.
# (however, it may be easier to just run docker with "--network host" to expose all ports)
#  i.e. in case your qemu running esp32 is running a web server / char device fwd'ing / etc

# for debugging QEMU's GDB server from outside the container
EXPOSE 1234/tcp

# ---------
# because you might want to use these, and this is a dev container so, useful to have a few presets
# ---------

# for vaguely telnet-y / serial console-ish stuff
EXPOSE 23/tcp

# for vaguely HTTP-ish stuff. use qemu's port forwarding stuff
EXPOSE 8088/tcp
