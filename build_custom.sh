#!/bin/bash

compilers="gcc-6 clang-4.0 intel-17"
packages="hdf5 moab dagmc"

for compiler in ${compilers}; do
  ./install.sh ${compiler} ${packages}
done
