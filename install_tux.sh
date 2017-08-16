#!/bin/bash

set -e
umask 0022

# gcc:   4.7, 6, 7
# clang: 4.0
# intel: 17

compiler=$1
shift

export jobs=`grep -c processor /proc/cpuinfo`
export install_dir=/groupspace/cnerg/users/jacobson/opt/${compiler}
export build_dir=/local.hd/cnergg/jacobson/build/${compiler}
export mcnp_dir=/groupspace/cnerg/users/jacobson/MCNP/MCNP_CODE/bin

export install_mcnp5=true
export install_mcnp6=true
export install_geant4=true
export install_fluka=false

if [[ ${compiler} == "gcc"* ]]; then
  if [[ ! ${compiler} == "gcc-4.7" ]]; then
    if   [[ ${compiler} == "gcc-6" ]]; then gcc_root=${install_dir}/gcc-6.4.0
    elif [[ ${compiler} == "gcc-7" ]]; then gcc_root=${install_dir}/gcc-7.2.0
    else echo "Unknown compiler"; exit
    fi
    export PATH=${gcc_root}/bin:${PATH}
    export LD_LIBRARY_PATH=${gcc_root}/lib64:${LD_LIBRARY_PATH}
  fi
  export CC=`which gcc`
  export CXX=`which g++`
  export FC=`which gfortran`
elif [[ ${compiler} == "clang"* ]]; then
  gcc_root=/groupspace/cnerg/users/jacobson/opt/gcc-6/gcc-6.4.0
  export PATH=${gcc_root}/bin:${PATH}
  export LD_LIBRARY_PATH=${gcc_root}/lib64:${LD_LIBRARY_PATH}
  if [[ ${compiler} == "clang-4.0" ]]; then clang_root=${install_dir}/llvm-4.0.1
  else echo "Unknown compiler"; exit
  fi
  export PATH=${clang_root}/bin:${PATH}
  export LD_LIBRARY_PATH=${clang_root}/lib:${LD_LIBRARY_PATH}
  export CC=`which clang`
  export CXX=`which clang++`
  export FC=`which gfortran`
elif [[ ${compiler} == "intel"* ]]; then
  if   [[ ${compiler} == "intel-17" ]]; then intel_root=/groupspace/cnerg/users/jacobson/intel/compilers_and_libraries_2017.4.196/linux
  else echo "Unknown compiler"; exit
  fi
  export PATH=${intel_root}/bin/intel64:${PATH}
  export LD_LIBRARY_PATH=${intel_root}/compiler/lib/intel64:${LD_LIBRARY_PATH}
  export CC=`which icc`
  export CXX=`which icpc`
  export FC=`which ifort`
else echo "Unknown compiler"; exit
fi

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
