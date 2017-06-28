#!/bin/bash

set -e
#umask 0022

# gcc:   4.4, 4.6, 4.7, 4.8, 4.9, 5, 6, 7
# clang: 3.5, 3.6, 3.7, 3.8, 3.9, 4.0
# intel: 12, 13, 14, 15, 16, 17

compiler=$1
shift

export install_dir=${HOME}/opt/${compiler}
export build_dir=${HOME}/build/${compiler}

if [[ ${compiler} == "gcc"* ]]; then
  gcc_version_major=${compiler:4}
  export CC=`which gcc-${gcc_version_major}`
  export CXX=`which g++-${gcc_version_major}`
  export FC=`which gfortran-${gcc_version_major}`
elif [[ ${compiler} == "clang"* ]]; then
  clang_version=${compiler:6}
  export CC=`which clang-${clang_version}`
  export CXX=`which clang++-${clang_version}`
  export FC=`which gfortran-6`
elif [[ ${compiler} == "intel"* ]]; then
  if   [[ ${compiler} == "intel-12" ]]; then intel_root=/opt/intel/composer_xe_2011_sp1.13.367
  elif [[ ${compiler} == "intel-13" ]]; then intel_root=/opt/intel/composer_xe_2013.5.192
  elif [[ ${compiler} == "intel-14" ]]; then intel_root=/opt/intel/composer_xe_2013_sp1.6.214
  elif [[ ${compiler} == "intel-15" ]]; then intel_root=/opt/intel/composer_xe_2015.6.233
  elif [[ ${compiler} == "intel-16" ]]; then intel_root=/opt/intel/compilers_and_libraries_2016.4.258/linux
  elif [[ ${compiler} == "intel-17" ]]; then intel_root=/opt/intel/compilers_and_libraries_2017.4.196/linux
  fi
  export PATH=${intel_root}/bin/intel64:${PATH}
  export LD_LIBRARY_PATH=${intel_root}/compiler/lib/intel64:${LD_LIBRARY_PATH}
  export CC=`which icc`
  export CXX=`which icpc`
  export FC=`which ifort`
else
  echo "Unknown compiler"
  exit
fi

install_mcnp5=true
install_mcnp6=true
install_geant4=true
install_fluka=true

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
