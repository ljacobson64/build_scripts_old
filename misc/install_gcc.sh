#!/bin/bash

set -e
umask 0022

version=$1
if [ -z ${version} ]; then
  echo "Usage: ./install_gcc.sh <gcc_version>"
  exit
fi

gmp_version=6.1.2
mpfr_version=3.1.6
mpc_version=1.0.3

jobs=`grep -c processor /proc/cpuinfo`

if [[ "${HOSTNAME}" == "aci"* ]]; then
  dist_dir=/home/ljjacobson/dist
  install_dir=/home/ljjacobson/opt/native
  build_dir=/scratch/local/ljjacobson/build/native
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
FC=`which gfortran`

${CC}  --version
${CXX} --version
${FC}  --version

mkdir -p ${build_dir} ${dist_dir}/gcc
cd ${build_dir}
mkdir -p gcc-${version}/bld
cd gcc-${version}

tarball=gcc-${version}.tar.gz
url=http://www.netgull.com/gcc/releases/gcc-${version}/${tarball}
if [ ! -f ${dist_dir}/gcc/${tarball} ]; then wget ${url} -P ${dist_dir}/gcc; fi
tar -xzvf ${dist_dir}/gcc/${tarball}
ln -snf gcc-${version} src
cd gcc-${version}

gmp_tarball=gmp-${gmp_version}.tar.xz
mpfr_tarball=mpfr-${mpfr_version}.tar.gz
mpc_tarball=mpc-${mpc_version}.tar.gz
gmp_url=https://gmplib.org/download/gmp/${gmp_tarball}
mpfr_url=http://www.mpfr.org/mpfr-current/${mpfr_tarball}
mpc_url=ftp://ftp.gnu.org/gnu/mpc/${mpc_tarball}
if [ ! -f ${dist_dir}/${gmp_tarball}  ]; then wget ${gmp_url}  -P ${dist_dir}; fi
if [ ! -f ${dist_dir}/${mpfr_tarball} ]; then wget ${mpfr_url} -P ${dist_dir}; fi
if [ ! -f ${dist_dir}/${mpc_tarball}  ]; then wget ${mpc_url}  -P ${dist_dir}; fi
tar -xJvf ${dist_dir}/${gmp_tarball}
tar -xzvf ${dist_dir}/${mpfr_tarball}
tar -xzvf ${dist_dir}/${mpc_tarball}
ln -snf gmp-${gmp_version}   gmp
ln -snf mpfr-${mpfr_version} mpfr
ln -snf mpc-${mpc_version}   mpc

cd ../bld

../src/configure --prefix=${install_dir}/gcc-${version}
make -j ${jobs}
make install
