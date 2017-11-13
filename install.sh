#!/bin/bash

function unknown_compiler() {
  echo "Unknown compiler = ${compiler}"
  exit
}

set -e
umask 0022

compiler=$1
if [ -z ${compiler} ]; then unknown_compiler; fi
shift

jobs=`grep -c processor /proc/cpuinfo`

if [[ ${HOSTNAME} == "aci"* ]]; then
  dist_dir=/home/ljjacobson/dist
  native_dir=/home/ljjacobson/opt/native
  install_dir=/home/ljjacobson/opt/${compiler}
  build_dir=/scratch/local/ljjacobson/build/${compiler}
  intel_root=
elif [[ ${HOSTNAME} == "tux"* ]]; then
  dist_dir=/groupspace/cnerg/users/jacobson/dist
  native_dir=/groupspace/cnerg/users/jacobson/opt/native
  install_dir=/groupspace/cnerg/users/jacobson/opt/${compiler}
  build_dir=/local.hd/cnergg/jacobson/build/${compiler}
  intel_root=/groupspace/cnerg/users/jacobson/intel
else
  dist_dir=/home/lucas/dist
  native_dir=/home/lucas/opt/native
  install_dir=/home/lucas/opt/${compiler}
  build_dir=/home/lucas/build/${compiler}
  intel_root=/opt/intel
fi

if [ ${compiler} == "native" ]; then
  CC=`which gcc`
  CXX=`which g++`
  FC=`which gfortran`
elif [[ ${compiler} == "gcc"* ]]; then
  if [[ ${HOSTNAME} == "aci"* ]] || [[ ${HOSTNAME} == "tux"* ]]; then
    if   [ ${compiler} == "gcc-4.8" ]; then gcc_dir=${native_dir}/gcc-4.8.5
    elif [ ${compiler} == "gcc-4.9" ]; then gcc_dir=${native_dir}/gcc-4.9.4
    elif [ ${compiler} == "gcc-5"   ]; then gcc_dir=${native_dir}/gcc-5.5.0
    elif [ ${compiler} == "gcc-6"   ]; then gcc_dir=${native_dir}/gcc-6.4.0
    elif [ ${compiler} == "gcc-7"   ]; then gcc_dir=${native_dir}/gcc-7.2.0
    else unknown_compiler
    fi
    PATH=${gcc_dir}/bin:${PATH}
    LD_LIBRARY_PATH=${gcc_dir}/lib64:${LD_LIBRARY_PATH}
    CC=`which gcc`
    CXX=`which g++`
    FC=`which gfortran`
  else
    gcc_version_major=${compiler:4}
    CC=`which gcc-${gcc_version_major}`
    CXX=`which g++-${gcc_version_major}`
    FC=`which gfortran-${gcc_version_major}`
  fi
elif [[ ${compiler} == "clang"* ]]; then
  if [[ ${HOSTNAME} == "aci"* ]]; then
    gcc_dir=/home/ljjacobson/opt/gcc-7/gcc-7.2.0
    PATH=${gcc_dir}/bin:${PATH}
    LD_LIBRARY_PATH=${gcc_dir}/lib64:${LD_LIBRARY_PATH}
  fi
  if [[ ${HOSTNAME} == "aci"* ]] || [[ ${HOSTNAME} == "tux"* ]]; then
    if   [ ${compiler} == "clang-4.0" ]; then clang_dir=${native_dir}/llvm-4.0.1
    elif [ ${compiler} == "clang-5.0" ]; then clang_dir=${native_dir}/llvm-5.0.0
    else unknown_compiler
    fi
    PATH=${clang_dir}/bin:${PATH}
    LD_LIBRARY_PATH=${clang_dir}/lib:${LD_LIBRARY_PATH}
    CC=`which clang`
    CXX=`which clang++`
  else
    clang_version_major=${compiler:6}
    CC=`which clang-${clang_version_major}`
    CXX=`which clang++-${clang_version_major}`
  fi
  FC=`which gfortran`
elif [[ ${compiler} == "intel"* ]]; then
  if [[ ${HOSTNAME} == "aci"* ]]; then
    if   [ ${compiler} == "intel-13" ]; then intel_dir=/opt/intel/composer_xe_2013.5.192
    elif [ ${compiler} == "intel-16" ]; then intel_dir=/opt/intel-2016/compilers_and_libraries_2016.2.181/linux
    else unknown_compiler
    fi
  else
    if   [ ${compiler} == "intel-15" ]; then intel_dir=${intel_root}/composer_xe_2015.6.233
    elif [ ${compiler} == "intel-16" ]; then intel_dir=${intel_root}/compilers_and_libraries_2016.4.258/linux
    elif [ ${compiler} == "intel-17" ]; then intel_dir=${intel_root}/compilers_and_libraries_2017.5.239/linux
    else unknown_compiler
    fi
  fi
  PATH=${intel_dir}/bin/intel64:${PATH}
  LD_LIBRARY_PATH=${intel_dir}/compiler/lib/intel64:${LD_LIBRARY_PATH}
  CC=`which icc`
  CXX=`which icpc`
  FC=`which ifort`
else
  unknown_compiler
fi

CMAKE=`which cmake`

${CC}    --version
${CXX}   --version
${FC}    --version
${CMAKE} --version

install_mcnp5=true
install_mcnp6=true
if [[ ${HOSTNAME} == "aci"* ]]; then
  if [ ${compiler} == "gcc-6"* ] || [ ${compiler} == "gcc-7"* ]; then
    install_fluka=true
    install_geant4=true
  else
    install_fluka=false
    install_geant4=false
  fi
else
  install_fluka=true
  install_geant4=true
fi

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
