#!/bin/bash

# gcc:   4.4, 4.6, 4.7, 4.8, 4.9, 5, 6, 7
# clang: 3.5, 3.6, 3.7, 3.8, 3.9, 4.0
# intel: 15, 16, 17

function unknown_compiler() {
  echo "Unknown compiler = ${compiler}"
  exit
}

set -e
umask 0002

compiler=$1
if [ -z ${compiler} ]; then unknown_compiler; fi
shift

jobs=`grep -c processor /proc/cpuinfo`
install_dir=${HOME}/opt/${compiler}
build_dir=${HOME}/build/${compiler}
mcnp_dir=/opt/MCNP/MCNP_CODE/bin

if [[ ${compiler} == "gcc"* ]]; then
  gcc_version_major=${compiler:4}
  CC=`which gcc-${gcc_version_major}`
  CXX=`which g++-${gcc_version_major}`
  FC=`which gfortran-${gcc_version_major}`
elif [[ ${compiler} == "clang"* ]]; then
  clang_version_major=${compiler:6}
  CC=`which clang-${clang_version_major}`
  CXX=`which clang++-${clang_version_major}`
  FC=`which gfortran-7`
elif [[ ${compiler} == "intel"* ]]; then
  if   [ ${compiler} == "intel-15" ]; then intel_root=/opt/intel/composer_xe_2015.6.233
  elif [ ${compiler} == "intel-16" ]; then intel_root=/opt/intel/compilers_and_libraries_2016.4.258/linux
  elif [ ${compiler} == "intel-17" ]; then intel_root=/opt/intel/compilers_and_libraries_2017.5.239/linux
  fi
  PATH=${intel_root}/bin/intel64:${PATH}
  LD_LIBRARY_PATH=${intel_root}/compiler/lib/intel64:${LD_LIBRARY_PATH}
  CC=`which icc`
  CXX=`which icpc`
  FC=`which ifort`
else
  unknown_compiler
fi

install_mcnp5=true
install_mcnp6=true
install_fluka=true
install_geant4=true
install_astyle=true

cmake  --version
${CC}  --version
${CXX} --version
${FC}  --version

source versions.sh
source build_funcs.sh
mkdir -p ${build_dir}

for package in "$@"; do
  if [[ ${package} == *"-"* ]]; then
    name=$(cut -d '-' -f1  <<< "${package}")
    version=$(cut -d '-' -f2- <<< "${package}")
    eval ${name}_version=${version}
  else
    name=${package}
    temp=${name}_version
    eval version=${!temp}
  fi
  echo "Building ${name} version ${version}"
  build_${name}
done
