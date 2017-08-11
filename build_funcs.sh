#!/bin/bash

# Package list
#     GCC
#     OpenMPI
#     MPICH
#     Python
#     HDF5
#     LAPACK
#     Armadillo
#     Setuptools
#     Pip
#     CUBIT
#     CGM
#     MOAB
#     MCNP5/6
#     Geant4
#     FLUKA
#     DAGMC
#     MCNP2CAD
#     ALARA
#     PyNE
#     ADVANTG

function build_gcc() {
  name=gcc
  version=${gcc_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=http://www.netgull.com/gcc/releases/gcc-${version}/${tarball}

  gmp_version=6.1.2
  mpfr_version=3.1.5
  mpc_version=1.0.3

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd ${tar_f}
  tar -xjvf ${dist_dir}/gmp-${gmp_version}.tar.bz2
  tar -xzvf ${dist_dir}/mpfr-${mpfr_version}.tar.gz
  tar -xzvf ${dist_dir}/mpc-${mpc_version}.tar.gz
  ln -snf gmp-${gmp_version} gmp
  ln -snf mpfr-${mpfr_version} mpfr
  ln -snf mpc-${mpc_version} mpc
  cd ../bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"

  ../src/configure ${config_string}
  make -j ${jobs}
  make install
}

function build_openmpi() {
  name=openmpi
  version=${openmpi_version}
  if   [[ "${version:3:1}" == "." ]]; then version_major=${version::3}
  elif [[ "${version:4:1}" == "." ]]; then version_major=${version::4}
  fi
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=http://www.open-mpi.org/software/ompi/v${version_major}/downloads/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --enable-static"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j ${jobs}
  make install
}

function build_mpich() {
  name=mpich
  version=${mpich_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=http://www.mpich.org/static/downloads/${version}/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j ${jobs}
  make install
}

function build_python() {
  name=python
  version=${python_version}
  folder=${name}-${version}
  tarball=Python-${version}.tgz
  tar_f=Python-${version}
  url=https://www.python.org/ftp/python/${version}/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --enable-shared"
  #config_string+=" --with-lto"
  #config_string+=" --enable-optimizations"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j ${jobs}
  make install
}

function build_hdf5() {
  name=hdf5
  version=${hdf5_version}
  if   [[ "${version:3:1}" == "." ]]; then version_major=${version::3}
  elif [[ "${version:4:1}" == "." ]]; then version_major=${version::4}
  fi
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${version_major}/hdf5-${version}/src/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --enable-shared"
  config_string+=" --disable-debug"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j ${jobs}
  make install
}

function build_lapack() {
  name=lapack
  version=${lapack_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tgz
  tar_f=${name}-${version}
  url=http://www.netlib.org/lapack/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  cmake_string=
  cmake_string+=" -DBUILD_STATIC_LIBS=ON"
  cmake_string+=" -DBUILD_SHARED_LIBS=ON"
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j ${jobs}
  make install
}

function build_armadillo() {
  name=armadillo
  version=${armadillo_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.xz
  tar_f=${name}-${version}
  url=http://sourceforge.net/projects/arma/files/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  cmake_string=
  cmake_string+=" -DBUILD_STATIC_LIBS=ON"
  cmake_string+=" -DBUILD_SHARED_LIBS=ON"
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j ${jobs}
  make install
}

function build_setuptools() {
  name=setuptools
  version=${setuptools_version}
  folder=${name}-${version}
  tarball=${name}-${version}.zip
  tar_f=${name}-${version}
  url=https://pypi.python.org/packages/07/a0/11d3d76df54b9701c0f7bf23ea9b00c61c5e14eb7962bb29aed866a5844e/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  cd ${tar_f}

  python setup.py install --user
}

function build_pip() {
  name=pip
  version=${pip_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  cd ${tar_f}

  python setup.py install --user
}

function build_cubit() {
  name=cubit
  version=${cubit_version}
  folder=${name}-${version}
  tarball=Cubit_LINUX64.${version}.tar.gz

  cd ${install_dir}
  mkdir ${folder}
  cd ${folder}
  tar -xzvf ${dist_dir}/${tarball}
}

function build_cgm() {
  name=cgm
  version=${cgm_version}
  folder=${name}-${version}
  repo=https://bitbucket.org/fathomteam/${name}
  if [[ ${version} == "14"* ]]; then
    repo=https://bitbucket.org/makeclean/${name}
    branch=add_torus_14
  else
    repo=https://bitbucket.org/fathomteam/${name}
    branch=cgm${version}
  fi

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  git clone ${repo} -b ${branch} --single-branch
  ln -snf ${name} src
  cd ${name}
  autoreconf -fi
  cd ../bld
  
  config_string=
  config_string+=" --enable-optimize"
  config_string+=" --enable-shared"
  config_string+=" --disable-debug"
  config_string+=" --with-cubit=${install_dir}/cubit-${cubit_version}"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  LDPATH_orig=${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/cubit-${cubit_version}/bin:${LD_LIBRARY_PATH}
  ../src/configure ${config_string}
  make -j ${jobs}
  make install
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_moab() {
  if [[ ${moab_version} == "4.9.1"* ]]; then with_cgm=true
  else with_cgm=false
  fi
  with_cgm=false

  name=moab
  version=${moab_version}
  if [[ ${with_cgm} == "true" ]]; then folder=${name}-${version}-cgm-${cgm_version}
  else folder=${name}-${version}
  fi
  if [[ ${version} == "master" ]]; then
    repo=https://bitbucket.org/fathomteam/${name}
    branch=master
  elif [[ ${version} == "5.0" ]]; then
    repo=https://bitbucket.org/ljacobson64/${name}
    branch=fix_intel_build
  else
    repo=https://bitbucket.org/fathomteam/${name}
    branch=Version${version}
  fi
  echo "Installing to ${build_dir}/${folder}"

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  git clone ${repo} -b ${branch} --single-branch
  ln -snf ${name} src
  cd ${name}
  autoreconf -fi
  cd ../bld

  config_string=
  config_string+=" --enable-dagmc"
  config_string+=" --disable-ahf"
  config_string+=" --enable-shared"
  config_string+=" --enable-optimize"
  config_string+=" --disable-debug"
  config_string+=" --with-hdf5=${install_dir}/hdf5-${hdf5_version}"
  if [[ ${with_cgm} == "true" ]]; then
    config_string+=" --enable-irel"
    config_string+=" --with-cgm=${install_dir}/cgm-${cgm_version}"
  fi
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  LDPATH_orig=${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/hdf5-${hdf5_version}/lib:${LD_LIBRARY_PATH}
  if [[ ${with_cgm} == "true" ]]; then
    LD_LIBRARY_PATH=${install_dir}/cubit-${cubit_version}/bin:${LD_LIBRARY_PATH}
    LD_LIBRARY_PATH=${install_dir}/cgm-${cgm_version}/lib:${LD_LIBRARY_PATH}
  fi
  ../src/configure ${config_string}
  make -j ${jobs}
  make install
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_mcnp() {
  name=MCNP
  folder=${name}
  repo=https://github.com/ljacobson64/MCNP_CMake
  branch=master

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  git clone ${repo} -b ${branch} --single-branch
  ln -snf MCNP_CMake src
  cd MCNP_CMake
  bash mcnp_source.sh
  cd ../bld

  cmake_string=
  cmake_string+=" -DBUILD_MCNP5=ON"
  cmake_string+=" -DBUILD_MCNPX=ON"
  cmake_string+=" -DBUILD_MCNP6=ON"
  cmake_string+=" -DBUILD_MCNP611=ON"
  cmake_string+=" -DMCNP_PLOT=ON"
  cmake_string+=" -DOPENMP_BUILD=ON"
  #cmake_string+=" -DMPI_BUILD=ON"
  cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
  cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j ${jobs}
  make install
  cd ..; rm -rf bld; mkdir -p bld; cd bld
  PATH_orig=${PATH}
  LDPATH_orig=${LD_LIBRARY_PATH}
  PATH=${install_dir}/openmpi-${openmpi_version}/bin:${PATH}
  LD_LIBRARY_PATH=${install_dir}/openmpi-${openmpi_version}/lib:${LD_LIBRARY_PATH}
  cmake ../src ${cmake_string} -DMPI_BUILD=ON
  make -j ${jobs}
  make install
  PATH=${PATH_orig}
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_geant4() {
  name=geant4
  version=${geant4_version}
  folder=${name}-${version}
  tarball=${name}.${version}.tar.gz
  tar_f=${name}.${version}
  url=http://geant4.cern.ch/support/source/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}; fi
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  cmake_string=
  cmake_string+=" -DBUILD_STATIC_LIBS=ON"
  cmake_string+=" -DGEANT4_USE_SYSTEM_EXPAT=OFF"
  cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
  cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j ${jobs}
  make install
}

function build_fluka() {
  name=fluka
  version=${fluka_version}
  folder=${name}-${version}
  tarball=fluka${version}-linux-gfor64bitAA.tar.gz

  cd ${install_dir}
  mkdir -p ${folder}/bin
  cd ${folder}/bin
  tar -xzvf ${dist_dir}/${tarball}
  #export FLUFOR=$(basename $FC)
  export FLUFOR=gfortran
  export FLUPRO=${PWD}

  make
  bash flutil/ldpmqmd
}

function build_dagmc() {
  name=DAGMC
  folder=${name}
  repo=https://github.com/svalinn/${name}
  branch=develop
  mcnp5_version=5.1.60
  mcnp6_version=6.1.1beta
  mcnp5_tarball=mcnp/mcnp${mcnp5_version}_source.tar.gz
  mcnp6_tarball=mcnp/mcnp${mcnp6_version}_source.tar.gz

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  git clone ${repo} -b ${branch} --single-branch
  ln -snf ${name} src

  if [[ ${install_mcnp5} == "true" ]]; then
    cd ${name}/mcnp/mcnp5
    tar -xzvf ${dist_dir}/${mcnp5_tarball} --strip-components=1
    patch -p0 < patch/dagmc.${mcnp5_version}.patch
    cd ../../..
  fi
  if [[ ${install_mcnp6} == "true" ]]; then  
    cd ${name}/mcnp/mcnp6
    tar -xzvf ${dist_dir}/${mcnp6_tarball} --strip-components=1
    patch -p0 < patch/dagmc.${mcnp6_version}.patch
    cd ../../..
  fi
  if [[ ${install_fluka} == "true" ]]; then  
    if [ ! -x ${install_dir}/fluka-${fluka_version}/bin/flutil/rfluka.orig ]; then
      patch -Nb ${install_dir}/fluka-${fluka_version}/bin/flutil/rfluka ${name}/fluka/rfluka.patch
    fi
  fi
  cd bld

  cmake_string=
  if [[ ${install_mcnp5} == "true" ]]; then
    cmake_string+=" -DBUILD_MCNP5=ON"
    cmake_string+=" -DMCNP5_PLOT=ON"
    cmake_string+=" -DMCNP5_DATAPATH=${DATAPATH}"
  fi
  if [[ ${install_mcnp6} == "true" ]]; then
    cmake_string+=" -DBUILD_MCNP6=ON"
    cmake_string+=" -DMCNP6_PLOT=ON"
    cmake_string+=" -DMCNP6_DATAPATH=${DATAPATH}"
  fi
  cmake_string+=" -DMPI_BUILD=ON"
  #cmake_string+=" -DOPENMP_BUILD=ON"
  if [[ ${install_geant4} == "true" ]]; then
    cmake_string+=" -DBUILD_GEANT4=ON"
    cmake_string+=" -DGEANT4_DIR=${install_dir}/geant4-${geant4_version}"
  fi
  if [[ ${install_fluka} == "true" ]]; then
    cmake_string+=" -DBUILD_FLUKA=ON"
    cmake_string+=" -DFLUKA_DIR=${install_dir}/fluka-${fluka_version}/bin"
  fi
  #cmake_string+=" -DBUILD_STATIC=ON"
  cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
  cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  PATH_orig=${PATH}
  LDPATH_orig=${LD_LIBRARY_PATH}

  PATH=${install_dir}/openmpi-${openmpi_version}/bin:${PATH}
  PATH=${install_dir}/hdf5-${hdf5_version}/bin:${PATH}
  LD_LIBRARY_PATH=${install_dir}/openmpi-${openmpi_version}/lib:${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/hdf5-${hdf5_version}/lib:${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/moab-${moab_version}/lib:${LD_LIBRARY_PATH}
  if [[ ${install_geant4} == "true" ]]; then
    LD_LIBRARY_PATH=${install_dir}/geant4-${geant4_version}/lib:${LD_LIBRARY_PATH}
  fi
  if [[ ${install_fluka} == "true" ]]; then  
    FLUFOR=$(basename $FC)
    FLUPRO=${install_dir}/fluka-${fluka_version}/bin
    FLUDAG=${install_dir}/${folder}/bin
  fi

  cmake ../src ${cmake_string}
  make -j ${jobs}
  make install

  PATH=${PATH_orig}
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_mcnp2cad() {
  name=mcnp2cad
  folder=mcnp2cad-cgm-${cgm_version}
  if [[ ${cgm_version} == "14"* ]]; then
    repo=https://github.com/svalinn/${name}
    branch=sns_gq_updates
  else
    repo=https://github.com/ljacobson64/${name}
    branch=mcnp6_fixes
  fi

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  git clone ${repo} -b ${branch} --single-branch
  ln -snf ${name} src
  cd ${name}

  make_string=
  make_string+=" CGM_BASE_DIR=${install_dir}/cgm-${cgm_version}"
  make_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  LDPATH_orig=${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/cubit-${cubit_version}/bin:${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/cgm-${cgm_version}/lib:${LD_LIBRARY_PATH}
  make -j ${jobs} ${make_string}
  mkdir -p ${install_dir}/${folder}/bin
  cp ${build_dir}/${folder}/${name}/mcnp2cad ${install_dir}/${folder}/bin
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_alara() {
  name=ALARA
  folder=${name}
  repo=https://github.com/svalinn/${name}
  branch=master

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  git clone ${repo} -b ${branch} --single-branch
  ln -snf ${name} src
  cd ${name}
  autoreconf -fi
  cd ../bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j ${jobs}
  make install
}

function build_pyne() {
  name=pyne
  folder=${name}
  repo=https://github.com/ljacobson64/${name}
  branch=dagmc_singleton_support

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  git clone $repo -b ${branch} --single-branch
  ln -snf ${name} src
  mkdir -p ${install_dir}/${folder}/lib/python2.7/site-packages
  cd ${name}

  setup_string=
  setup_string+=" -DMOAB_LIBRARY=${install_dir}/moab-${moab_version}/lib/libMOAB.so"
  setup_string+=" -DMOAB_INCLUDE_DIR=${install_dir}/moab-${moab_version}/include"
  setup_string+=" -DCMAKE_C_COMPILER=${CC}"
  setup_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  setup_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  if [[ $(basename $CXX) == "icpc" ]]; then
    setup_string+=" -DCMAKE_BUILD_TYPE=Debug"
  fi
  setup_string_2=
  setup_string_2+=" --prefix=${install_dir}/${folder}"

  LDPATH_orig=${LD_LIBRARY_PATH}
  PPATH_orig=${PYTHONPATH}
  LD_LIBRARY_PATH=${install_dir}/hdf5-${hdf5_version}/lib:${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/moab-${moab_version}/lib:${LD_LIBRARY_PATH}
  PYTHONPATH=${install_dir}/${folder}/lib/python2.7/site-packages:${PYTHONPATH}
  python setup.py ${setup_string} install ${setup_string_2} -j ${jobs}
  cd ..
  ${install_dir}/${folder}/bin/nuc_data_make
  LD_LIBRARY_PATH=${LDPATH_orig}
  PYTHONPATH=${PPATH_orig}
}

function build_advantg() {
  name=advantg
  version=${advantg_version}
  folder=${name}-${version}
  tarball=${name}-${version}-release.tgz
  tar_f=${name}-${version}-release
  
  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  tar -xzvf ${dist_dir}/${tarball}
  ln -snf ${tar_f} src
  cd ${tar_f}/Installers

  setup_string=
  setup_string+=" --keep"
  setup_string+=" --nox11"
  setup_string+=" --"
  setup_string+=" --no-prompts"
  setup_string+=" --mcnp-executable=${mcnp_dir}/mcnp5"
  #setup_string+=" --prefix=${HOME}/opt/precompiled/advantg-3.0.3"
  setup_string+=" --prefix=/opt/advantg-3.0.3"

  bash advantg-3.0.3-linux-x86_64-setup.sh ${setup_string}
  cd ${build_dir}
}
