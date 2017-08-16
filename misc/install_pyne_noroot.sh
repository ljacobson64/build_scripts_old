#!/bin/bash

set -e
umask 0022

gmp_version=6.1.2
mpfr_version=3.1.5
mpc_version=1.0.3
gcc_version=6.4.0
python_version=2.7.13
hdf5_version=1.8.13
moab_version=4.9.2
setuptools_version=36.2.7
pip_version=9.0.1

jobs=`grep -c processor /proc/cpuinfo`

if [[ "${HOSTNAME}" == "aci"* ]]; then
  install_dir=/home/lucas/opt/gcc-6
  build_dir=/scratch/local/lucas/build/gcc-6
elif [[ "${HOSTNAME}" == "tux"* ]]; then
  install_dir=/groupspace/cnerg/users/jacobson/opt/gcc-6
  build_dir=/local.hd/cnergg/jacobson/build/gcc-6
else
  echo "Unknown hostname"
  exit
fi

mkdir -p ${build_dir}

# Build GCC
cd ${build_dir}
mkdir -p gcc-${gcc_version}/bld
cd gcc-${gcc_version}
wget http://www.netgull.com/gcc/releases/gcc-${gcc_version}/gcc-${gcc_version}.tar.gz
tar -xzvf gcc-${gcc_version}.tar.gz
ln -s gcc-${gcc_version} src
cd gcc-${gcc_version}
wget https://gmplib.org/download/gmp/gmp-${gmp_version}.tar.xz
wget http://www.mpfr.org/mpfr-current/mpfr-${mpfr_version}.tar.gz
wget ftp://ftp.gnu.org/gnu/mpc/mpc-${mpc_version}.tar.gz
tar -xjvf gmp-${gmp_version}.tar.xz
tar -xzvf mpfr-${mpfr_version}.tar.gz
tar -xzvf mpc-${mpc_version}.tar.gz
ln -s gmp-${gmp_version} gmp
ln -s mpfr-${mpfr_version} mpfr
ln -s mpc-${mpc_version} mpc
cd ../bld
../src/configure --prefix=${install_dir}/gcc-${gcc_version}
make -j${jobs}
make install
export PATH=${install_dir}/gcc-${gcc_version}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/gcc-${gcc_version}/lib64
export CC=`which gcc`
export CXX=`which g++`
export FC=`which gfortran`

# Build Python
cd ${build_dir}
mkdir -p python-${python_version}/bld
cd python-${python_version}
wget https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz
tar -xzvf Python-${python_version}.tgz
ln -s Python-${python_version} src
cd bld
../src/configure --enable-shared \
                 --prefix=${install_dir}/python-${python_version} \
                 CC=${CC} CXX=${CXX} FC=${FC}
make -j${jobs}
make install
export PATH=${install_dir}/python-${python_version}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/python-${python_version}/lib:${LD_LIBRARY_PATH}

# Build HDF5
cd ${build_dir}
mkdir -p hdf5-${hdf5_version}/bld
cd hdf5-${hdf5_version}
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-${hdf5_version}/src/hdf5-${hdf5_version}.tar.gz
tar -xzvf hdf5-${hdf5_version}.tar.gz
ln -s hdf5-${hdf5_version} src
cd bld
../src/configure --enable-shared \
                 --disable-debug \
                 --prefix=${install_dir}/hdf5-${hdf5_version} \
                 CC=${CC} CXX=${CXX} FC=${FC}
make -j${jobs}
make install
export PATH=${install_dir}/hdf5-${hdf5_version}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/hdf5-${hdf5_version}/lib:${LD_LIBRARY_PATH}

# Build MOAB
cd ${build_dir}
mkdir -p moab-${moab_version}/bld
cd moab-${moab_version}
git clone https://bitbucket.org/fathomteam/moab -b Version${moab_version}
ln -s moab src
cd moab
autoreconf -fi
cd ../bld
../src/configure --enable-dagmc \
                 --disable-ahf \
                 --enable-shared \
                 --enable-optimize \
                 --disable-debug \
                 --with-hdf5=${install_dir}/hdf5-${hdf5_version} \
                 --prefix=${install_dir}/moab-${moab_version} \
                 CC=${CC} CXX=${CXX} FC=${FC}
make -j${jobs}
make install
export PATH=${install_dir}/moab-${moab_version}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/moab-${moab_version}/lib:${LD_LIBRARY_PATH}

# Build setuptools and pip
cd ${build_dir}
wget https://pypi.python.org/packages/07/a0/11d3d76df54b9701c0f7bf23ea9b00c61c5e14eb7962bb29aed866a5844e/setuptools-${setuptools_version}.zip
unzip setuptools-${setuptools_version}.zip
cd setuptools-${setuptools_version}
python setup.py install --user
cd ..
wget https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-${pip_version}.tar.gz
tar -xzvf pip-${pip_version}.tar.gz
cd pip-${pip_version}
python setup.py install --user
export PATH=${HOME}/.local/bin:${PATH}

# Install some python packages
pip install --user cython nose numpy scipy tables

# Build Pyne
cd ${build_dir}
git clone https://github.com/ljacobson64/pyne -b dagmc_singleton_support
cd pyne
python setup.py -DMOAB_LIBRARY=${install_dir}/moab-${moab_version}/lib/libMOAB.so \
                -DMOAB_INCLUDE_DIR=${install_dir}/moab-${moab_version}/include \
                -DCMAKE_C_COMPILER=${CC} \
                -DCMAKE_CXX_COMPILER=${CXX} \
                -DCMAKE_Fortran_COMPILER=${FC} \
                install --user -j${jobs}
cd ..
nuc_data_make

# Install some more python packages
pip install --user cloud_sptheme nbconvert numpydoc prettytable sphinx sphinxcontrib-bibtex

# Build Pyne documentation
cd ${build_dir}/pyne/docs
make html
