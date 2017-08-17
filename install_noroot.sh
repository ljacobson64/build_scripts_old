#!/bin/bash

function unknown_hostname() {
  echo "Unknown hostname = ${HOSTNAME}"
  exit
}

function unknown_compiler() {
  echo "Unknown compiler = ${compiler}"
  exit
}

#            ACI       TUX
# gcc-4.4    native    -
# gcc-4.7    -         native
# gcc-4.8    -         -
# gcc-4.9    -         -
# gcc-5      -         -
# gcc-6      compiled  compiled
# gcc-7      compiled  compiled
# clang-3.0  -         native
# clang-3.4  native    -
# clang-4.0  -         compiled
# intel-13   module    -
# intel-16   module    -
# intel-17   -         user

set -e
umask 0022

compiler=$1
if [ -z ${compiler} ]; then unknown_compiler; fi
shift

jobs=`grep -c processor /proc/cpuinfo`

if [[ ${HOSTNAME} == "aci"* ]]; then
  gcc_version_native=4.4
  install_dir=/home/lucas/opt/${compiler}
  build_dir=/scratch/local/${USER}/build/${compiler}
  mcnp_dir=/home/lucas/MCNP/MCNP_CODE/bin
elif [[ ${HOSTNAME} == "tux"* ]]; then
  gcc_version_native=4.7
  install_dir=/groupspace/cnerg/users/jacobson/opt/${compiler}
  build_dir=/local.hd/cnergg/jacobson/build/${compiler}
  mcnp_dir=/groupspace/cnerg/users/jacobson/MCNP/MCNP_CODE/bin
else
  unknown_hostname
fi

if [[ ${compiler} == "gcc"* ]]; then
  if [ ! ${compiler} == "gcc-${gcc_version_native}" ]; then
    if   [ ${compiler} == "gcc-4.8" ]; then gcc_root=${install_dir}/gcc-4.8.5
    elif [ ${compiler} == "gcc-4.9" ]; then gcc_root=${install_dir}/gcc-4.9.3
    elif [ ${compiler} == "gcc-5"   ]; then gcc_root=${install_dir}/gcc-5.4.0
    elif [ ${compiler} == "gcc-6"   ]; then gcc_root=${install_dir}/gcc-6.4.0
    elif [ ${compiler} == "gcc-7"   ]; then gcc_root=${install_dir}/gcc-7.2.0
    else unknown_compiler
    fi
    PATH=${gcc_root}/bin:${PATH}
    LD_LIBRARY_PATH=${gcc_root}/lib64:${LD_LIBRARY_PATH}
  fi
  CC=`which gcc`
  CXX=`which g++`
  FC=`which gfortran`
elif [[ ${compiler} == "clang"* ]]; then
  if   [[ ${HOSTNAME} == "aci"* ]]; then gcc_root=/home/lucas/opt/gcc-6/gcc-6.4.0
  elif [[ ${HOSTNAME} == "tux"* ]]; then gcc_root=/groupspace/cnerg/users/jacobson/opt/gcc-6/gcc-6.4.0
  fi
  PATH=${gcc_root}/bin:${PATH}
  LD_LIBRARY_PATH=${gcc_root}/lib64:${LD_LIBRARY_PATH}
  if [ ${compiler} == "clang-4.0" ]; then clang_root=${install_dir}/llvm-4.0.1
  else unknown_compiler
  fi
  PATH=${clang_root}/bin:${PATH}
  LD_LIBRARY_PATH=${clang_root}/lib:${LD_LIBRARY_PATH}
  CC=`which clang`
  CXX=`which clang++`
  FC=`which gfortran`
elif [[ ${compiler} == "intel"* ]]; then
  if [[ ${HOSTNAME} == "aci"* ]]; then
    if   [ ${compiler} == "intel-13" ]; then intel_root=/opt/intel/composer_xe_2013.5.192
    elif [ ${compiler} == "intel-16" ]; then intel_root=/opt/intel-2016/compilers_and_libraries_2016.2.181/linux
    else unknown_compiler
    fi
  elif [[ ${HOSTNAME} == "tux"* ]]; then
    if [ ${compiler} == "intel-17" ]; then intel_root=/groupspace/cnerg/users/jacobson/intel/compilers_and_libraries_2017.4.196/linux
    else unknown_compiler
    fi
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
install_geant4=true
install_fluka=false

cmake  --version
${CC}  --version
${CXX} --version
${FC}  --version

source versions.sh
source build_funcs.sh
mkdir -p ${build_dir}

for build in "$@"; do
  build_${build}
done
