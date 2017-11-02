#!/bin/bash

# This script assumes that GCC, Python, HDF5, and MOAB are already built.

set -e
umask 0022

gcc_version=7.2.0
python_version=2.7.14
hdf5_version=1.8.13
moab_version=4.9.1
setuptools_version=36.6.0
pip_version=9.0.1

jobs=`grep -c processor /proc/cpuinfo`

if [[ "${HOSTNAME}" == "aci"* ]]; then
  dist_dir=/home/ljjacobson/dist
  install_dir=/home/ljjacobson/opt/gcc-7
  build_dir=/scratch/local/ljjacobson/build/gcc-7
  export PATH=${install_dir}/gcc-${gcc_version}/bin:${PATH}
  export LD_LIBRARY_PATH=${install_dir}/gcc-${gcc_version}/lib64
  export PATH=${install_dir}/python-${python_version}/bin:${PATH}
  export LD_LIBRARY_PATH=${install_dir}/python-${python_version}/lib:${LD_LIBRARY_PATH}
elif [[ "${HOSTNAME}" == "tux"* ]]; then
  dist_dir=/groupspace/cnerg/users/jacobson/dist
  install_dir=/groupspace/cnerg/users/jacobson/opt/gcc-4.9
  build_dir=/local.hd/cnergg/jacobson/build/gcc-4.9
else
  echo "Unknown hostname"
  exit
fi

CC=`which gcc`
CXX=`which g++`
FC=`which gfortran`

cmake  --version
${CC}  --version
${CXX} --version
${FC}  --version

export HDF5_DIR=${install_dir}/hdf5-${hdf5_version}
export PATH=${HDF5_DIR}/bin:${PATH}
export LD_LIBRARY_PATH=${HDF5_DIR}/lib:${LD_LIBRARY_PATH}

export MOAB_DIR=${install_dir}/moab-${moab_version}
export PATH=${MOAB_DIR}/bin:${PATH}
export LD_LIBRARY_PATH=${MOAB_DIR}/lib:${LD_LIBRARY_PATH}

mkdir -p ${build_dir}

# Build setuptools
if [[ "${HOSTNAME}" == "aci"* ]]; then
  cd ${build_dir}
  tarball=setuptools-${setuptools_version}.zip
  url=https://pypi.python.org/packages/45/29/8814bf414e7cd1031e1a3c8a4169218376e284ea2553cc0822a6ea1c2d78/${tarball}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  unzip ${dist_dir}/${tarball}
  cd setuptools-${setuptools_version}
  python setup.py install --user
fi

# Build pip
cd ${build_dir}
tarball=pip-${pip_version}.tar.gz
url=https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/${tarball}
if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
tar -xzvf ${dist_dir}/${tarball}
cd pip-${pip_version}
python setup.py install --user

export PATH=${HOME}/.local/bin:${PATH}

# Install some python packages
pip install --user --upgrade cython \
                             nose \
                             numpy \
                             pytaps \
                             scipy \
                             tables \
                             setuptools

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
export PATH=${install_dir}/pyne/bin:${PATH}
export PYTHONPATH=${install_dir}/pyne/lib/python2.7/site-packages:${PYTHONPATH}
nuc_data_make

# Install some more python packages
pip install --user --upgrade cloud_sptheme \
                             nbconvert \
                             numpydoc \
                             prettytable \
                             sphinx \
                             sphinxcontrib-bibtex

# Build Pyne documentation
cd ${build_dir}/pyne/docs
make html
