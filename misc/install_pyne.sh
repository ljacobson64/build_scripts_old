#!/bin/bash

# This script assumes that GCC, Python, HDF5, and MOAB are already built.

set -e
umask 0022

hdf5_version=1.8.13
moab_version=4.9.1
setuptools_version=38.2.4
pip_version=9.0.1

jobs=`grep -c processor /proc/cpuinfo`

if [[ "${HOSTNAME}" == "aci"* ]]; then
  dist_dir=/home/ljjacobson/dist
  install_dir=/home/ljjacobson/opt/gcc-7
  build_dir=/scratch/local/ljjacobson/build/gcc-7

  gcc_version=7.2.0
  gcc_dir=/home/ljjacobson/opt/native/gcc-${gcc_version}
  PATH=${gcc_dir}/bin:${PATH}
  LD_LIBRARY_PATH=${gcc_dir}/lib64

  python_version=2.7.14
  python_dir=${install_dir}/python-${python_version}
  PATH=${python_dir}/bin:${PATH}
  LD_LIBRARY_PATH=${python_dir}/lib:${LD_LIBRARY_PATH}
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

HDF5_DIR=${install_dir}/hdf5-${hdf5_version}
PATH=${HDF5_DIR}/bin:${PATH}
LD_LIBRARY_PATH=${HDF5_DIR}/lib:${LD_LIBRARY_PATH}

MOAB_DIR=${install_dir}/moab-${moab_version}
PATH=${MOAB_DIR}/bin:${PATH}
LD_LIBRARY_PATH=${MOAB_DIR}/lib:${LD_LIBRARY_PATH}

mkdir -p ${build_dir}

# Build setuptools
if [[ "${HOSTNAME}" == "aci"* ]]; then
  cd ${build_dir}
  tarball=setuptools-${setuptools_version}.zip
  url=https://pypi.python.org/packages/69/56/f0f52281b5175e3d9ca8623dadbc3b684e66350ea9e0006736194b265e99/${tarball}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}/; fi
  unzip ${dist_dir}/${tarball}
  cd setuptools-${setuptools_version}
  python setup.py install --user
fi

# Build pip
cd ${build_dir}
tarball=pip-${pip_version}.tar.gz
url=https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/${tarball}
if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}/; fi
tar -xzvf ${dist_dir}/${tarball}
cd pip-${pip_version}
python setup.py install --user

PATH=${HOME}/.local/bin:${PATH}

# Install some python packages
pip install --user --upgrade cython nose numpy pytaps scipy tables setuptools

# Build pyne
cd ${build_dir}
git clone https://github.com/pyne/pyne -b develop
cd pyne
python setup.py -DCMAKE_C_COMPILER=${CC} \
                -DCMAKE_CXX_COMPILER=${CXX} \
                -DCMAKE_Fortran_COMPILER=${FC} \
                -DCMAKE_BUILD_TYPE=Release \
                install \
                --hdf5=${HDF5_DIR} \
                --moab=${MOAB_DIR} \
                --prefix=${install_dir}/pyne \
                -j${jobs}
cd ..
PATH=${install_dir}/pyne/bin:${PATH}
PYTHONPATH=${install_dir}/pyne/lib/python2.7/site-packages:${PYTHONPATH}
nuc_data_make

# Install some more python packages
pip install --user --upgrade cloud_sptheme nbconvert numpydoc prettytable sphinx sphinxcontrib-bibtex

# Build pyne documentation
cd ${build_dir}/pyne/docs
make html
