#!/bin/bash

set -e
umask 0022

version=3.0.3

if [[ "${HOSTNAME}" == "aci"* ]]; then
  dist_dir=/home/ljjacobson/dist
  install_dir=/home/ljjacobson/opt/native
  build_dir=/scratch/local/ljjacobson/build/native
  mcnp_exe=/home/ljjacobson/MCNP/MCNP_CODE/bin/mcnp5
elif [[ "${HOSTNAME}" == "tux"* ]]; then
  dist_dir=/groupspace/cnerg/users/jacobson/dist
  install_dir=/groupspace/cnerg/users/jacobson/opt/native
  build_dir=/local.hd/cnergg/jacobson/build/native
  mcnp_exe=/groupspace/cnerg/users/jacobson/MCNP/MCNP_CODE/bin/mcnp5
else
  dist_dir=/home/lucas/dist
  install_dir=/home/lucas/opt/native
  build_dir=/home/lucas/build/native
  mcnp_exe=/opt/MCNP/MCNP_CODE/bin/mcnp5
fi

mkdir -p ${build_dir}/advantg-${version}
cd ${build_dir}/advantg-${version}
tar -xzvf ${dist_dir}/misc/advantg-${version}-release.tgz
cd advantg-${version}-release/Installers

bash advantg-${version}-linux-x86_64-setup.sh \
  --keep \
  --nox11 \
  -- \
  --no-prompts \
  --mcnp-executable=${mcnp_exe} \
  --prefix=${install_dir}/advantg-${version}
