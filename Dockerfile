FROM debian:stretch as base

RUN mkdir /build && apt-get update && \
	apt-get install -y build-essential clang clang-format bison flex \
	libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz \
	xdot pkg-config python python3 libftdi-dev \
	qt5-default python3-dev libboost-all-dev cmake

FROM base as src

WORKDIR /build
RUN git clone https://github.com/cliffordwolf/icestorm.git 
RUN git clone https://github.com/YosysHQ/nextpnr.git 
RUN git clone https://github.com/YosysHQ/arachne-pnr.git
RUN git clone https://github.com/YosysHQ/yosys.git

FROM src as build

WORKDIR /build/icestorm
RUN sed -i 's#/usr/local$#/opt/icestorm#' config.mk
RUN make -j$(nproc)
RUN make install

WORKDIR /build/nextpnr
RUN cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/opt/icestorm -DICEBOX_ROOT=/opt/icestorm/share/icebox .
RUN make -j$(nproc)
RUN make install

WORKDIR /build/arachne-pnr
RUN sed -i 's#/usr/local$#/opt/icestorm#' Makefile
RUN make -j$(nproc)
RUN make install

WORKDIR /build/yosys
RUN sed -i 's#/usr/local$#/opt/icestorm#' Makefile 
RUN make -j$(nproc)
RUN make install

WORKDIR /build
