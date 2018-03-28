#!/bin/bash -xe
#
# Build the required docker image to run QEMU and Robot test cases
#
#  Parameters:
#   parm1:  <optional, the name of the docker image to generate>
#            default is openbmc/ubuntu-robot-qemu

set -uo pipefail

DOCKER_IMG_NAME=${1:-"openbmc/ubuntu-robot-qemu"}

# Determine our architecture, ppc64le or the other one
if [ $(uname -m) == "ppc64le" ]; then
    DOCKER_BASE="ppc64le/"
else
    DOCKER_BASE=""
fi

################################# docker img # #################################
# Create docker image that can run QEMU and Robot Tests
Dockerfile=$(cat << EOF
FROM ${DOCKER_BASE}ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yy \
    debianutils \
    gawk \
    git \
    python \
    python-dev \
    python-setuptools \
    python3 \
    python3-dev \
    python3-setuptools \
    socat \
    texinfo \
    wget \
    gcc \
    libffi-dev \
    libssl-dev \
    xterm \
    mwm \
    ssh \
    vim \
    iputils-ping \
    sudo \
    cpio \
    unzip \
    diffstat \
    expect \
    curl \
    build-essential \
    libpixman-1-0 \
    xvfb python-pip \
    libglib2.0-0

RUN easy_install \
    tox \
    pip \
    requests

RUN pip install \
    json2yaml \
    robotframework \
    robotframework-requests \
    robotframework-sshlibrary \
    robotframework-scplibrary \
    robotframework-xvfb \
    robotframework-selenium2library \
    robotframework-seleniumlibrary \
    robotframework-extendedselenium2library \
    robotframework-angularjs \
    pysnmp

RUN pip list

RUN wget https://sourceforge.net/projects/ipmitool/files/ipmitool/1.8.18/ipmitool-1.8.18.tar.bz2
RUN tar xvfj ipmitool-*.tar.bz2
RUN ./ipmitool-1.8.18/configure
RUN make
RUN make install

RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.20.0/geckodriver-v0.20.0-linux64.tar.gz
RUN tar -xvf geckodriver-*.tar.gz
#RUN cp geckodriver /usr/local/bin
#RUN pwd
#RUN ls
#RUN ls -la /usr/local/bin
#RUN chmod 777 /usr/local/bin/geckodriver
#RUN ls -la /usr/local/bin
RUN export PATH=$PATH:/geckodriver

RUN grep -q ${GROUPS} /etc/group || groupadd -g ${GROUPS} ${USER}
RUN grep -q ${UID} /etc/passwd || useradd -d ${HOME} -m -u ${UID} -g ${GROUPS} \
                    ${USER}
USER ${USER}
ENV HOME ${HOME}
RUN /bin/bash
EOF
)

################################# docker img # #################################

# Build above image
docker build -t ${DOCKER_IMG_NAME} - <<< "${Dockerfile}"
