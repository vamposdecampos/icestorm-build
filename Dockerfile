FROM debian:stretch as base

RUN mkdir /build && apt-get update && \
	apt-get install -y build-essential clang clang-format bison flex \
	libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz \
	xdot pkg-config python python3 libftdi-dev \
	qt5-default python3-dev libboost-all-dev cmake

RUN apt-get install -y libeigen3-dev


FROM base as build-icestorm
WORKDIR /build
RUN git clone https://github.com/cliffordwolf/icestorm.git
WORKDIR /build/icestorm
RUN sed -i 's#/usr/local$#/opt/icestorm#' config.mk
RUN make -j$(nproc)
RUN make install

FROM base as build-trellis
WORKDIR /build
RUN git clone --recursive https://github.com/SymbiFlow/prjtrellis
WORKDIR /build/prjtrellis/libtrellis
RUN git checkout 3311e6d
RUN cmake -DCMAKE_INSTALL_PREFIX=/opt/icestorm .
RUN make -j$(nproc)
RUN make install

FROM base as build-nextpnr
COPY --from=build-icestorm /opt/icestorm /opt/icestorm
COPY --from=build-trellis /opt/icestorm /opt/icestorm
WORKDIR /build
RUN git clone https://github.com/YosysHQ/nextpnr.git
WORKDIR /build/nextpnr
RUN git checkout 19cb4ca
WORKDIR /build/nextpnr/build-ice40
RUN cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/opt/icestorm -DICEBOX_ROOT=/opt/icestorm/share/icebox ..
RUN make -j$(nproc)
RUN make install
WORKDIR /build/nextpnr/build-ecp5
RUN cmake -DARCH=ecp5 -DCMAKE_INSTALL_PREFIX=/opt/icestorm -DTRELLIS_ROOT=/opt/icestorm/share/trellis ..
RUN make -j$(nproc)
RUN make install



FROM base as build-apnr
COPY --from=build-icestorm /opt/icestorm /opt/icestorm
WORKDIR /build
RUN git clone https://github.com/YosysHQ/arachne-pnr.git
WORKDIR /build/arachne-pnr
RUN sed -i 's#/usr/local$#/opt/icestorm#' Makefile
RUN make -j$(nproc)
RUN make install


FROM base as build-yosys
WORKDIR /build
RUN git clone https://github.com/YosysHQ/yosys.git
WORKDIR /build/yosys
RUN git checkout 70d0f38
RUN sed -i 's#/usr/local$#/opt/icestorm#' Makefile 
RUN make -j$(nproc)
RUN make install


FROM base as stitch
COPY --from=build-icestorm /opt/icestorm /opt/icestorm
COPY --from=build-trellis /opt/icestorm /opt/icestorm
COPY --from=build-nextpnr /opt/icestorm /opt/icestorm
COPY --from=build-apnr /opt/icestorm /opt/icestorm
COPY --from=build-yosys /opt/icestorm /opt/icestorm
WORKDIR /
ENV PATH=/opt/icestorm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
