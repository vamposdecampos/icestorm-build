
icestorm-build
--------------

This docker container sets up a build environment for the  [Project
IceStorm](http://www.clifford.at/icestorm/) and
[prjtrellis](https://github.com/SymbiFlow/prjtrellis) tools for Lattice
ICE40 and ECP5 FPGA devices. This allows one to easily build and install
the icestorm  toolchain without installing a bunch of dependencies
system-wide.

This builds `icestorm`, `prjtrellis`, `nextpnr`, `arachnepnr` and `yosys`.


# Usage

```
$ git clone https://github.com/vamposdecampos/icestorm-build.git && cd icestorm-build
$ docker build -t icestorm-build .

$ cd ../nifty-fpga-project
$ docker run --rm -it -u $(id -u):$(id -g) -v $(pwd):/src -w /src icestorm-build make
```
