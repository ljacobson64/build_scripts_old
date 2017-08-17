#!/bin/bash

function setup_project() {
  orig_dir=${PWD}
  mkdir -p $1
  cd $1
  tarball=$2-${version}.src.tar.xz
  if [ ! -f ${dist_dir}/llvm/${tarball} ]; then
    wget url=http://releases.llvm.org/${version}/${tarball} -P ${dist_dir}/llvm
  fi
  tar -xJvf ${dist_dir}/llvm/${tarball}
  mv $2-${version}.src $3
  #svn co http://llvm.org/svn/llvm-project/$2/branches/release_40 $3
  cd ${orig_dir}
}

set -e
umask 0022

version=4.0.1
jobs=`grep -c processor /proc/cpuinfo`

if [[ "${HOSTNAME}" == "aci"* ]]; then
  dist_dir=/home/ljjacobson/dist
  install_dir=/home/ljjacobson/opt/clang-4.0
  build_dir=/scratch/local/ljjacobson/build/clang-4.0
  gcc_root=/home/ljjacobson/opt/gcc-6/gcc-6.4.0
elif [[ "${HOSTNAME}" == "tux"* ]]; then
  dist_dir=/groupspace/cnerg/users/jacobson/dist
  install_dir=/groupspace/cnerg/users/jacobson/opt/clang-4.0
  build_dir=/local.hd/cnergg/jacobson/build/clang-4.0
  gcc_root=/groupspace/cnerg/users/jacobson/opt/gcc-6/gcc-6.4.0
else
  echo "Unknown hostname"
  exit
fi

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

PATH=${gcc_root}/bin:${PATH}
LD_LIBRARY_PATH=${gcc_root}/lib64
CC=`which gcc`
CXX=`which g++`

ln -s llvm src
cd bld
cmake ../src -DCMAKE_C_COMPILER=${CC} \
             -DCMAKE_CXX_COMPILER=${CXX} \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=${install_dir}/llvm-${version}
make -j${jobs}
make install
