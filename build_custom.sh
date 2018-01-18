#!/bin/bash

compilers=""
packages=""

compilers+=" native"

compilers+=" gcc-4.8"
compilers+=" gcc-4.9"
compilers+=" gcc-5"
compilers+=" gcc-6"
compilers+=" gcc-7"

compilers+=" clang-4.0"
compilers+=" clang-5.0"

compilers+=" intel-13"
compilers+=" intel-15"
compilers+=" intel-16"
compilers+=" intel-17"
compilers+=" intel-18"

packages+=" alara"
packages+=" armadillo"
packages+=" hdf5"
packages+=" python"
packages+=" mpich"
packages+=" openmpi"

packages+=" fluka"
packages+=" geant4"
packages+=" talys"

packages+=" cgm-12.2"
packages+=" cgm-13.1"
packages+=" cgm-14.0"
packages+=" mcnp2cad-cgm-13.1"
packages+=" mcnp2cad-cgm-14.0"
packages+=" moab-4.9.1"
packages+=" moab-4.9.2"
packages+=" moab-5.0"
packages+=" moab-master"

packages+=" mcnp"
packages+=" dagmc"
packages+=" pyne"

for package in ${packages}; do
  for compiler in ${compilers}; do
    ./install.sh ${compiler} ${package}
  done
done
