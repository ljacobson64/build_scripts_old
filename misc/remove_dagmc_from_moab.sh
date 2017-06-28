#!/bin/bash

# Files to keep:
#     MeshFiles/unittest/test_geom.h5m
#     tools/dagmc/DagMC.cpp
#     tools/dagmc/DagMC.hpp
#     tools/dagmc/pt_vol_test.cc
#     tools/dagmc/ray_fire_test.cc
#     tools/dagmc/test_geom.cc
#     test/dagmc/dagmc_pointinvol_test.cpp
#     test/dagmc/dagmc_rayfire_test.cpp
#     test/dagmc/dagmc_simple_test.cpp

# Checkout the MOAB snapshot we're using to pull out DAGMC
# (commit 2fff341 in develop)
git clone https://bitbucket.org/ljacobson64/moab -b dagmc_final
cd moab
# Create a new branch that will eventually only contain the commits related to the files we're keeping
git checkout -b prepare_for_dagmc
# Delete all tags
git tag | xargs git tag -d
# Delete all commits not related to the files we're keeping
git filter-branch --force --prune-empty --tree-filter 'rm -rf $(git ls-files | grep -vE "MeshFiles/unittest/test_geom.h5m|tools/dagmc/DagMC.cpp|tools/dagmc/DagMC.hpp|tools/dagmc/pt_vol_test.cc|tools/dagmc/ray_fire_test.cc|tools/dagmc/test_geom.cc|test/dagmc/dagmc_pointinvol_test.cpp|test/dagmc/dagmc_rayfire_test.cpp|test/dagmc/dagmc_simple_test.cpp")'
# Delete all merge commits
git filter-branch --force --prune-empty --parent-filter 'sed "s/-p //g" | xargs -r git show-branch --independent | sed "s/\</-p /g"'
# Count the total number of commits
git rev-list HEAD --count
# Push the pruned branch
#git push -f origin prepare_for_dagmc
