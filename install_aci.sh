#!/bin/bash

set -e
umask 0022

# gcc:   4.4, 5, 6, 7
# clang:
# intel: 13, 16

compiler=$1
shift

export jobs=`grep -c processor /proc/cpuinfo`
export install_dir=${HOME}/opt/${compiler}
export build_dir=/scratch/local/${USER}/build/${compiler}
export mcnp_dir=${HOME}/MCNP/MCNP_CODE/bin/orig

export install_mcnp5=true
export install_mcnp6=true
export install_geant4=true
export install_fluka=false

if [[ ${compiler} == "gcc"* ]]; then
  gcc_version_major=${compiler:4}
  if [[ ${gcc_version_major} == "5" ]]; then
    export PATH=${install_dir}/gcc-5.4.0/bin:${PATH}
    export LD_LIBRARY_PATH=${install_dir}/gcc-5.4.0/lib64:${LD_LIBRARY_PATH}
  elif [[ ${gcc_version_major} == "6" ]]; then
    export PATH=${install_dir}/gcc-6.3.0/bin:${PATH}
    export LD_LIBRARY_PATH=${install_dir}/gcc-6.3.0/lib64:${LD_LIBRARY_PATH}
  elif [[ ${gcc_version_major} == "7" ]]; then
    export PATH=${install_dir}/gcc-7.1.0/bin:${PATH}
    export LD_LIBRARY_PATH=${install_dir}/gcc-7.1.0/lib64:${LD_LIBRARY_PATH}
  fi
  export CC=`which gcc`
  export CXX=`which g++`
  export FC=`which gfortran`
elif [[ ${compiler} == "intel"* ]]; then
  if   [[ ${compiler} == "intel-13" ]]; then intel_root=/opt/intel/composer_xe_2013.5.192
  elif [[ ${compiler} == "intel-16" ]]; then intel_root=/opt/intel-2016/compilers_and_libraries_2016.2.181/linux
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
