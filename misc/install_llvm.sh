#!/bin/bash

function setup_project() {
  orig_dir=${PWD}
  mkdir -p $1
  cd $1
  tarball=$2-${version}.src.tar.xz
  url=http://releases.llvm.org/${version}/${tarball}
  if [ ! -f ${dist_dir}/llvm/${tarball} ]; then wget ${url} -P ${dist_dir}/llvm/; fi
  tar -xJvf ${dist_dir}/llvm/${tarball}
  mv $2-${version}.src $3
  #svn co http://llvm.org/svn/llvm-project/$2/branches/release_50 $3
  cd ${orig_dir}
}

set -e
umask 0022

version=$1
if [ -z ${version} ]; then
  echo "Usage: ./install_llvm.sh <llvm_version>"
  exit
fi

jobs=`grep -c processor /proc/cpuinfo`

if [[ "${HOSTNAME}" == "aci"* ]]; then
  dist_dir=/home/ljjacobson/dist
  install_dir=/home/ljjacobson/opt/gcc-7
  build_dir=/scratch/local/ljjacobson/build/gcc-7

  gcc_version=7.2.0
  gcc_dir=/home/ljjacobson/opt/native/gcc-${gcc_version}
  PATH=${gcc_dir}/bin:${PATH}
  LD_LIBRARY_PATH=${gcc_dir}/lib64
elif [[ "${HOSTNAME}" == "tux"* ]]; then
  dist_dir=/groupspace/cnerg/users/jacobson/dist
  install_dir=/groupspace/cnerg/users/jacobson/opt/native
  build_dir=/local.hd/cnergg/jacobson/build/native
else
  dist_dir=/home/lucas/dist
  install_dir=/home/lucas/opt/native
  build_dir=/home/lucas/build/native
fi

CC=`which gcc`
CXX=`which g++`
CMAKE=`which cmake`

${CC}    --version
${CXX}   --version
${CMAKE} --version

mkdir -p ${build_dir} ${dist_dir}/llvm
cd ${build_dir}
mkdir -p llvm-${version}/bld
cd llvm-${version}

setup_project .                      llvm              llvm
setup_project llvm/tools             cfe               clang
setup_project llvm/tools             lld               lld
setup_project llvm/tools             polly             polly
setup_project llvm/tools/clang/tools clang-tools-extra extra
setup_project llvm/projects          compiler-rt       compiler-rt
setup_project llvm/projects          libcxx            libcxx
setup_project llvm/projects          libcxxabi         libcxxabi
setup_project llvm/projects          libunwind         libunwind
setup_project llvm/projects          openmp            openmp
setup_project llvm/projects          test-suite        test-suite

ln -s llvm src
cd bld

${CMAKE} ../src -DCMAKE_C_COMPILER=${CC} \
                -DCMAKE_CXX_COMPILER=${CXX} \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=${install_dir}/llvm-${version}
make -j${jobs}
make install
