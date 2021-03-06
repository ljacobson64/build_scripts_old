#!/bin/bash

# Package list:
# - alara
# - armadillo
# - astyle
# - binutils
# - cgm
# - cmake
# - dagmc
# - fluka
# - gcc
# - geant4
# - geany
# - git
# - hdf5
# - intltool
# - lapack
# - mcnp
# - mcnp2cad
# - moab
# - mpich
# - openmpi
# - pip
# - pyne
# - python
# - setuptools
# - talys

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
  make -j${jobs}
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
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xJvf ${dist_dir}/misc/${tarball}
  ln -snf ${tar_f} src
  cd bld

  cmake_string=
  cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
  cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"
  cmake_string_static=${cmake_string}
  cmake_string_shared=${cmake_string}
  cmake_string_static+=" -DBUILD_SHARED_LIBS=OFF"
  cmake_string_shared+=" -DBUILD_SHARED_LIBS=ON"

  cmake ../src ${cmake_string_static}
  make -j${jobs}
  make install
  cd ..; rm -rf bld; mkdir -p bld; cd bld
  cmake ../src ${cmake_string_shared}
  make -j${jobs}
  make install
}

function build_astyle() {
  name=astyle
  version=${astyle_version}
  folder=${name}-${version}
  tarball=${name}_${version}_linux.tar.gz
  tar_f=${name}
  url=https://sourceforge.net/projects/astyle/files/astyle/astyle%20${version}/astyle_${version}_linux.tar.gz

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd ${tar_f}/build
  if [[ ${compiler} == "clang"* ]]; then cd clang
  elif [[ ${compiler} == "intel"* ]]; then cd intel
  else cd gcc
  fi

  make -j${jobs}
  mkdir -p ${install_dir}/${folder}
  cp -r bin ../../file ${install_dir}/${folder}/
  chmod -x ${install_dir}/${folder}/file/*
}

function build_binutils() {
  name=binutils
  version=${binutils_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://ftp.gnu.org/gnu/binutils/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
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
  config_string+=" --with-cubit=${native_dir}/cubit-${cgm_version}"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  LDPATH_orig=${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${native_dir}/cubit-${cgm_version}/bin:${LD_LIBRARY_PATH}
  ../src/configure ${config_string}
  make -j${jobs}
  make install
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_cmake() {
  name=cmake
  version=${cmake_version}
  if   [ "${version:3:1}" == "." ]; then version_major=${version::3}
  elif [ "${version:4:1}" == "." ]; then version_major=${version::4}
  fi
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://cmake.org/files/v${version_major}/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${name}/${tarball} ]; then wget ${url} -P ${dist_dir}/${name}/; fi
  tar -xzvf ${dist_dir}/${name}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
}

function build_dagmc() {
  if [[ ${dagmc_version} == *"moab-"* ]]; then
    moab_version=$(cut -d '-' -f2  <<< "${dagmc_version}")
    dagmc_version=
  fi

  name=DAGMC
  folder=${name}-moab-${moab_version}
  repo=https://github.com/ljacobson64/${name}
  if [ ${moab_version} == "4.9.2" ]; then branch=moab-${moab_version}
  else branch=latest
  fi

  mcnp5_version=516
  mcnp6_version=611

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  git clone ${repo} -b ${branch} --single-branch
  ln -snf ${name} src

  build_dagmcnp5=true
  build_dagmcnp6=true
  if [[ ${HOSTNAME} == "aci"* ]]; then
    if [ ${compiler} == "gcc-6" ] || [ ${compiler} == "gcc-7" ]; then
      build_fludag=true
      build_daggeant4=true
    else
      build_fludag=false
      build_daggeant4=false
    fi
  else
    build_fludag=true
    build_daggeant4=true
  fi

  cmake_string=

  if [ ${build_dagmcnp5} == "true" ]; then
    cd ${name}/src/mcnp/mcnp5
    tar -xzvf ${dist_dir}/mcnp/mcnp${mcnp5_version}-source.tar.gz --strip-components=1
    patch -p0 < patch/dag-mcnp${mcnp5_version}.patch
    cd ../../../..
    cmake_string+=" -DBUILD_MCNP5=ON"
    cmake_string+=" -DMCNP5_PLOT=ON"
    cmake_string+=" -DMCNP5_DATAPATH=${DATAPATH}"
  fi
  if [ ${build_dagmcnp6} == "true" ]; then
    cd ${name}/src/mcnp/mcnp6
    tar -xzvf ${dist_dir}/mcnp/mcnp${mcnp6_version}-source.tar.gz --strip-components=1
    patch -p0 < patch/dag-mcnp${mcnp6_version}.patch
    cd ../../../..
    cmake_string+=" -DBUILD_MCNP6=ON"
    cmake_string+=" -DMCNP6_PLOT=ON"
    cmake_string+=" -DMCNP6_DATAPATH=${DATAPATH}"
  fi
  if [ ${build_fludag} == "true" ]; then
    if [ ! -x ${install_dir}/fluka-${fluka_version}/bin/flutil/rfluka.orig ]; then
      patch -Nb ${install_dir}/fluka-${fluka_version}/bin/flutil/rfluka ${name}/src/fluka/rfluka.patch
    fi
    cmake_string+=" -DBUILD_FLUKA=ON"
    cmake_string+=" -DFLUKA_DIR=${install_dir}/fluka-${fluka_version}/bin"
  fi
  if [ ${build_daggeant4} == "true" ]; then
    cmake_string+=" -DBUILD_GEANT4=ON"
    cmake_string+=" -DGEANT4_DIR=${install_dir}/geant4-${geant4_version}"
  fi
  cd bld

  cmake_string+=" -DMOAB_DIR=${install_dir}/moab-${moab_version}"
  cmake_string+=" -DMPI_BUILD=ON"
  #cmake_string+=" -DOPENMP_BUILD=ON"
  #cmake_string+=" -DBUILD_STATIC_EXE=ON"
  #cmake_string+=" -DBUILD_PIC=ON"
  cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
  cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  PATH_orig=${PATH}
  LDPATH_orig=${LD_LIBRARY_PATH}
  PATH=${install_dir}/openmpi-${openmpi_version}/bin:${PATH}
  LD_LIBRARY_PATH=${install_dir}/openmpi-${openmpi_version}/lib:${LD_LIBRARY_PATH}

  cmake ../src ${cmake_string}
  make -j${jobs}
  make install
  chmod 750 ${install_dir}/${folder}/bin/mcnp*

  PATH=${PATH_orig}
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_fluka() {
  name=fluka
  version=${fluka_version}
  folder=${name}-${version}
  tarball=fluka${version}-linux-gfor64bitAA.tar.gz

  cd ${install_dir}
  mkdir -p ${folder}/bin
  cd ${folder}/bin
  tar -xzvf ${dist_dir}/misc/${tarball}
  #export FLUFOR=$(basename $FC)
  export FLUFOR=gfortran
  export FLUPRO=${PWD}

  make
  #bash flutil/ldpmqmd
}

function build_gcc() {
  name=gcc
  version=${gcc_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://ftp.gnu.org/gnu/gcc/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${name}/${tarball} ]; then wget ${url} -P ${dist_dir}/${name}/; fi
  tar -xzvf ${dist_dir}/${name}/${tarball}
  ln -snf ${tar_f} src
  cd ${tar_f}

  gmp_tarball=gmp-${gmp_version}.tar.xz
  mpfr_tarball=mpfr-${mpfr_version}.tar.gz
  mpc_tarball=mpc-${mpc_version}.tar.gz
  gmp_url=https://ftp.gnu.org/gnu/gmp/${gmp_tarball}
  mpfr_url=https://ftp.gnu.org/gnu/mpfr/${mpfr_tarball}
  mpc_url=https://ftp.gnu.org/gnu/mpc/${mpc_tarball}
  if [ ! -f ${dist_dir}/misc/${gmp_tarball}  ]; then wget ${gmp_url}  -P ${dist_dir}/misc/; fi
  if [ ! -f ${dist_dir}/misc/${mpfr_tarball} ]; then wget ${mpfr_url} -P ${dist_dir}/misc/; fi
  if [ ! -f ${dist_dir}/misc/${mpc_tarball}  ]; then wget ${mpc_url}  -P ${dist_dir}/misc/; fi
  tar -xJvf ${dist_dir}/misc/${gmp_tarball}
  tar -xzvf ${dist_dir}/misc/${mpfr_tarball}
  tar -xzvf ${dist_dir}/misc/${mpc_tarball}
  ln -snf gmp-${gmp_version}   gmp
  ln -snf mpfr-${mpfr_version} mpfr
  ln -snf mpc-${mpc_version}   mpc

  cd ../bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  #config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
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
  if [ ! -f ${dist_dir}/${name}/${tarball} ]; then wget ${url} -P ${dist_dir}/${name}/; fi
  tar -xzvf ${dist_dir}/${name}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  cmake_string=
  cmake_string+=" -DBUILD_STATIC_LIBS=ON"
  cmake_string+=" -DGEANT4_USE_SYSTEM_EXPAT=OFF"
  cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
  cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j${jobs}
  make install
}

function build_geany() {
  name=geany
  version=${geany_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=http://download.geany.org/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
}

function build_git() {
  name=git
  version=${git_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://www.kernel.org/pub/software/scm/git/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd ${tar_f}

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ./configure ${config_string}
  make -j${jobs}
  make install
}

function build_hdf5() {
  name=hdf5
  version=${hdf5_version}
  if   [ "${version:3:1}" == "." ]; then version_major=${version::3}
  elif [ "${version:4:1}" == "." ]; then version_major=${version::4}
  fi
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${version_major}/hdf5-${version}/src/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${name}/${tarball} ]; then wget ${url} -P ${dist_dir}/${name}/; fi
  tar -xzvf ${dist_dir}/${name}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --enable-shared"
  config_string+=" --disable-debug"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
}

function build_intltool() {
  name=intltool
  version=${intltool_version}
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=https://launchpad.net/intltool/trunk/${version}/+download/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
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
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  ln -snf ${tar_f} src
  cd bld

  cmake_string=
  cmake_string+=" -DBUILD_STATIC_LIBS=ON"
  cmake_string+=" -DBUILD_SHARED_LIBS=ON"
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j${jobs}
  make install
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

  build_mcnp514=true
  build_mcnp515=true
  build_mcnp516=true
  if [[ ${HOSTNAME} == "aci"* ]] && [ ${compiler} == "intel-16" ]; then build_mcnpx27=false
  else build_mcnpx27=true
  fi
  build_mcnp602=true
  build_mcnp610=true
  build_mcnp611=true

  cmake_string=
  if [ ${build_mcnp514} == "true" ]; then cmake_string+=" -DBUILD_MCNP514=ON"; fi
  if [ ${build_mcnp515} == "true" ]; then cmake_string+=" -DBUILD_MCNP515=ON"; fi
  if [ ${build_mcnp516} == "true" ]; then cmake_string+=" -DBUILD_MCNP516=ON"; fi
  if [ ${build_mcnpx27} == "true" ]; then cmake_string+=" -DBUILD_MCNPX27=ON"; fi
  if [ ${build_mcnp602} == "true" ]; then cmake_string+=" -DBUILD_MCNP602=ON"; fi
  if [ ${build_mcnp610} == "true" ]; then cmake_string+=" -DBUILD_MCNP610=ON"; fi
  if [ ${build_mcnp611} == "true" ]; then cmake_string+=" -DBUILD_MCNP611=ON"; fi
  cmake_string+=" -DBUILD_PLOT=ON"
  cmake_string+=" -DBUILD_OPENMP=ON"
  #cmake_string+=" -DBUILD_MPI=ON"
  #cmake_string+=" -DBUILD_STATIC_EXE=ON"
  #cmake_string+=" -DBUILD_PIC=ON"
  cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
  cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j${jobs}
  make install
  cd ..; rm -rf bld; mkdir -p bld; cd bld
  PATH_orig=${PATH}
  LDPATH_orig=${LD_LIBRARY_PATH}
  PATH=${install_dir}/openmpi-${openmpi_version}/bin:${PATH}
  LD_LIBRARY_PATH=${install_dir}/openmpi-${openmpi_version}/lib:${LD_LIBRARY_PATH}
  cmake ../src ${cmake_string} -DBUILD_MPI=ON
  make -j${jobs}
  make install
  chmod 750 ${install_dir}/${folder}/bin/mcnp*
  PATH=${PATH_orig}
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_mcnp2cad() {
  if [[ ${mcnp2cad_version} == *"cgm-"* ]]; then
    cgm_version=$(cut -d '-' -f2  <<< "${mcnp2cad_version}")
    mcnp2cad_version=
  fi

  name=mcnp2cad
  folder=${name}-cgm-${cgm_version}
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
  if [ ! -f /usr/lib/libarmadillo.so ]; then
    make_string+=" ARMADILLO_BASE_DIR=${install_dir}/armadillo-${armadillo_version}"
  fi
  make_string+=" CGM_BASE_DIR=${install_dir}/cgm-${cgm_version}"
  make_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  LDPATH_orig=${LD_LIBRARY_PATH}
  if [ ! -f /usr/lib/libarmadillo.so ]; then
    LD_LIBRARY_PATH=${install_dir}/armadillo-${armadillo_version}/lib:${LD_LIBRARY_PATH}
  fi
  LD_LIBRARY_PATH=${native_dir}/cubit-${cgm_version}/bin:${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/cgm-${cgm_version}/lib:${LD_LIBRARY_PATH}
  make -j${jobs} ${make_string}
  mkdir -p ${install_dir}/${folder}/bin
  cp ${build_dir}/${folder}/${name}/mcnp2cad ${install_dir}/${folder}/bin
  LD_LIBRARY_PATH=${LDPATH_orig}
}

function build_moab() {
  if [[ ${moab_version} == *"-cgm-"* ]]; then
    with_cgm=true
    cgm_version=$(cut -d '-' -f3  <<< "${moab_version}")
    moab_version=$(cut -d '-' -f1  <<< "${moab_version}")
  else
    with_cgm=false
  fi

  name=moab
  version=${moab_version}
  if [ ${with_cgm} == "true" ]; then folder=${name}-${version}-cgm-${cgm_version}
  else folder=${name}-${version}
  fi
  if [[ ${compiler} == "intel"* ]]; then
    if [ ${version} == "master" ]; then
      repo=https://bitbucket.org/ljacobson64/${name}
      branch=master-fix-intel
    elif [ ${version} == "5.0" ]; then
      repo=https://bitbucket.org/ljacobson64/${name}
      branch=Version5.0-fix-intel
    else
      repo=https://bitbucket.org/fathomteam/${name}
      branch=Version${version}
    fi
  else
    if [ ${version} == "master" ]; then
      repo=https://bitbucket.org/fathomteam/${name}
      branch=master
    else
      repo=https://bitbucket.org/fathomteam/${name}
      branch=Version${version}
    fi
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
  config_string+=" --enable-dagmc"
  config_string+=" --disable-ahf"
  config_string+=" --enable-shared"
  config_string+=" --enable-optimize"
  config_string+=" --disable-debug"
  config_string+=" --with-hdf5=${install_dir}/hdf5-${hdf5_version}"
  if [ ${with_cgm} == "true" ]; then
    config_string+=" --enable-irel"
    config_string+=" --with-cgm=${install_dir}/cgm-${cgm_version}"
  fi
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  LDPATH_orig=${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/hdf5-${hdf5_version}/lib:${LD_LIBRARY_PATH}
  if [ ${with_cgm} == "true" ]; then
    LD_LIBRARY_PATH=${native_dir}/cubit-${cgm_version}/bin:${LD_LIBRARY_PATH}
    LD_LIBRARY_PATH=${install_dir}/cgm-${cgm_version}/lib:${LD_LIBRARY_PATH}
  fi
  ../src/configure ${config_string}
  make -j${jobs}
  make install
  LD_LIBRARY_PATH=${LDPATH_orig}
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
  if [ ! -f ${dist_dir}/${name}/${tarball} ]; then wget ${url} -P ${dist_dir}/${name}/; fi
  tar -xzvf ${dist_dir}/${name}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
}

function build_openmpi() {
  name=openmpi
  version=${openmpi_version}
  if   [ "${version:3:1}" == "." ]; then version_major=${version::3}
  elif [ "${version:4:1}" == "." ]; then version_major=${version::4}
  fi
  folder=${name}-${version}
  tarball=${name}-${version}.tar.gz
  tar_f=${name}-${version}
  url=http://www.open-mpi.org/software/ompi/v${version_major}/downloads/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  if [ ! -f ${dist_dir}/${name}/${tarball} ]; then wget ${url} -P ${dist_dir}/${name}/; fi
  tar -xzvf ${dist_dir}/${name}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --enable-static"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
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
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd ${tar_f}

  python setup.py install --user
}

function build_pyne() {
  name=pyne
  folder=${name}
  repo=https://github.com/pyne/${name}
  branch=develop

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  git clone $repo -b ${branch} --single-branch
  cd ${name}

  setup_string=
  setup_string+=" -DCMAKE_C_COMPILER=${CC}"
  setup_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
  setup_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  if [ $(basename $CXX) == "icpc" ]; then
    setup_string+=" -DCMAKE_BUILD_TYPE=Debug"
  else
    setup_string+=" -DCMAKE_BUILD_TYPE=Release"
  fi
  setup_string_2=
  setup_string_2+=" --hdf5=${install_dir}/hdf5-${hdf5_version}"
  setup_string_2+=" --moab=${install_dir}/moab-4.9.1"
  setup_string_2+=" --prefix=${install_dir}/${folder}"

  PATH_orig=${PATH}
  LDPATH_orig=${LD_LIBRARY_PATH}
  PPATH_orig=${PYTHONPATH}
  if [[ ${HOSTNAME} == "aci"* ]]; then
    PATH=${install_dir}/python-${python_version}/bin:${PATH}
    LD_LIBRARY_PATH=${install_dir}/python-${python_version}/lib:${LD_LIBRARY_PATH}
  fi
  LD_LIBRARY_PATH=${install_dir}/hdf5-${hdf5_version}/lib:${LD_LIBRARY_PATH}
  LD_LIBRARY_PATH=${install_dir}/moab-4.9.1/lib:${LD_LIBRARY_PATH}
  PYTHONPATH=${install_dir}/${folder}/lib/python2.7/site-packages:${PYTHONPATH}

  python --version
  python setup.py ${setup_string} install ${setup_string_2} -j${jobs}
  cd ..
  ${install_dir}/${folder}/bin/nuc_data_make
  chmod 640 ${install_dir}/${folder}/lib/python2.7/site-packages/${name}/nuc_data.h5

  PATH=${PATH_orig}
  LD_LIBRARY_PATH=${LDPATH_orig}
  PYTHONPATH=${PPATH_orig}
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
  if [ ! -f ${dist_dir}/${name}/${tarball} ]; then wget ${url} -P ${dist_dir}/${name}/; fi
  tar -xzvf ${dist_dir}/${name}/${tarball}
  ln -snf ${tar_f} src
  cd bld

  config_string=
  config_string+=" --enable-shared"
  #config_string+=" --with-lto"
  #config_string+=" --enable-optimizations"
  config_string+=" --prefix=${install_dir}/${folder}"
  config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"

  ../src/configure ${config_string}
  make -j${jobs}
  make install
}

function build_setuptools() {
  name=setuptools
  version=${setuptools_version}
  folder=${name}-${version}
  tarball=${name}-${version}.zip
  tar_f=${name}-${version}
  url=https://pypi.python.org/packages/e0/02/2b14188e06ddf61e5b462e216b15d893e8472fca28b1b0c5d9272ad7e87c/${tarball}

  cd ${build_dir}
  mkdir -p ${folder}
  cd ${folder}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd ${tar_f}

  python setup.py install --user
}

function build_talys() {
  name=talys
  version=1.8
  folder=${name}-${version}
  tarball_code=${name}${version}_code.tar.gz
  tarball_data=${name}${version}_data.tar.gz
  tar_f=${name}

  cd ${build_dir}
  mkdir -p ${folder}/bld
  cd ${folder}
  tar -xzvf ${dist_dir}/${name}/${tarball_code}
  ln -snf ${tar_f}/source src

  talyspath=`echo ${install_dir}/${folder}/ | sed 's/\//\\\\\//g'`
  cd ${tar_f}/source
  sed "s/ home='.*'/ home='${talyspath}'/; s/60/80/" machine.f > machine_tmp.f
  sed "s/60 path/80 path/" talys.cmb > talys_tmp.cmb
  sed "s/90/110/" fissionpar.f > fissionpar_tmp.f
  mv machine.f ../machine_orig.f
  mv talys.cmb ../talys_orig.cmb
  mv fissionpar.f ../fissionpar_orig.f
  mv machine_tmp.f machine.f
  mv talys_tmp.cmb talys.cmb
  mv fissionpar_tmp.f fissionpar.f
  rm -f CMakeLists.txt
  echo "project(talys Fortran)"                   >> CMakeLists.txt
  echo "cmake_minimum_required(VERSION 2.8)"      >> CMakeLists.txt
  echo "set(CMAKE_BUILD_TYPE Release)"            >> CMakeLists.txt
  echo "set(CMAKE_Fortran_FLAGS_RELEASE \"-O1\")" >> CMakeLists.txt
  echo "file(GLOB SRC_FILES \"*.f\")"             >> CMakeLists.txt
  echo "add_executable(talys \${SRC_FILES})"      >> CMakeLists.txt
  echo "install(TARGETS talys DESTINATION bin)"   >> CMakeLists.txt
  cd ../../bld

  cmake_string=
  cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
  cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_dir}/${folder}"

  cmake ../src ${cmake_string}
  make -j${jobs}
  make install

  cd ${install_dir}/${folder}
  if [ ${compiler} == "native" ]; then
    tar -xzvf ${dist_dir}/${name}/${tarball_data}
  else
    ln -snf ${native_dir}/${folder}/${tar_f} .
  fi
}
