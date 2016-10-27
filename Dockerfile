#
# Dockerfile for the zcash beta and integrated cpuminer
# usage: docker run marsmensch/zcash-cpuminer
#
# tip me BTC at 1PboFDkBsW2i968UnehWwcSrM9Djq5LcLB
#▒███████▒ ▄████▄   ▄▄▄        ██████  ██░ ██ 
#▒ ▒ ▒ ▄▀░▒██▀ ▀█  ▒████▄    ▒██    ▒ ▓██░ ██▒
#░ ▒ ▄▀▒░ ▒▓█    ▄ ▒██  ▀█▄  ░ ▓██▄   ▒██▀▀██░
#  ▄▀▒   ░▒▓▓▄ ▄██▒░██▄▄▄▄██   ▒   ██▒░▓█ ░██ 
#▒███████▒▒ ▓███▀ ░ ▓█   ▓██▒▒██████▒▒░▓█▒░██▓
#░▒▒ ▓░▒░▒░ ░▒ ▒  ░ ▒▒   ▓▒█░▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒
#░░▒ ▒ ░ ▒  ░  ▒     ▒   ▒▒ ░░ ░▒  ░ ░ ▒ ░▒░ ░
#░ ░ ░ ░ ░░          ░   ▒   ░  ░  ░   ░  ░░ ░
#  ░ ░    ░ ░            ░  ░      ░   ░  ░  ░
#░        ░   
#
# Step-by-step to start mining interactively on testnet
# 1) start the container
# docker run --interactive --tty --entrypoint=/bin/bash marsmensch/docker-zcash
#
# 2) run the zcashd daemon 
# zcashd -daemon
#
# 3) check the current state
# zcash-cli getinfo
# 
# You can also benchmark your configuration with
# time /usr/local/bin/zcash-cli zcbenchmark solveequihash 10

FROM		ubuntu:16.04
MAINTAINER info@webdevops.io

ENV APP_GIT git://github.com/zcash/zcash.git
ENV APP_VERSION v1.0.0-rc4 
ENV APP_RELEASED 2016-10-27

ENV APP_ROOT /app
ENV APP_CONF /app/conf/zcash.conf
ENV APP_DATA /app/data
ENV APP_BIN /app/bin
ENV APP_CODE /app/code
#ENV WEB_PHP_SOCKET  127.0.0.1:9000

LABEL vendor=WebDevOps.io
LABEL io.webdevops.layout=8
LABEL io.webdevops.version=0.57.1

# install dependencies
RUN apt-get update && \
    apt-get -qqy install --no-install-recommends build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python3 python3-pip zlib1g-dev wget bsdmainutils automake
    automake ncurses-dev libcurl4-openssl-dev libssl-dev libgtest-dev \
    make autoconf automake libtool git apt-utils pkg-config libc6-dev \
    libcurl4-dev libudev-dev m4 g++-multilib unzip git python zlib1g-dev \
    wget bsdmainutils && \
    rm -rf /var/lib/apt/lists/*
# apt-get -y install 
ENV HOME /app
VOLUME /app/data

# create code directory
RUN echo "check_certificate = off" > ${APP_HOME}/.wgetrc && \
    git clone ${APP_GIT} /tmp/zcash

WORKDIR /tmp/zcash

RUN git checkout ${APP_VERSION} && \
    ./zcutil/fetch-params.sh && 
    ./zcutil/build.sh -j4 && cd /opt/code/zcash/src && \
    /usr/bin/install -c bitcoin-tx zcashd zcash-cli zcash-gtest -t /usr/local/bin/ && \
    rm -rf /opt/code/


# generate a dummy config       
RUN PASS=$(date | md5sum | cut -c1-24); \
    printf '%s\n%s\n%s\n%s\n%s\n' "rpcuser=zcashrpc" "rpcpassword=${PASS}" \
    "testnet=1" "addnode=betatestnet.z.cash" "gen=1" >> /app/data/zcash.conf



ENTRYPOINT ["/usr/local/bin/zcashd"]
CMD ["--help"]


