FROM ghcr.io/unit-e/esp-idf-qemu:release-v4.4

# insecure/hacky script to run an ssh server inside a running docker container
# don't use for anything important. dev-only.
# the purpose is to get access to the source code of esp-idf which is inside the container in /opt
# for remote debugging purposes. avoid using this container unless you need it

USER root
WORKDIR /root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server && mkdir -p /run/sshd

RUN echo 'root:Pass42^' | chpasswd
COPY sshd_config /etc/ssh/sshd_config

CMD /usr/sbin/sshd -D

EXPOSE 2222