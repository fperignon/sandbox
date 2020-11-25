#!bin/bash

# --- Script use in continuous integration to configure, build and test siconos software ---
#
# Usage :
# > export CI_PROJECT_DIR=<path-to-siconos-repository>
# > export ctest_build_model=Experimental or Continuous or Nightly
# > export IMAGE_NAME="some name for cdash build site"
# 
# > sh ctest_siconos.sh <ctest_mode> user_option_filename
#
#  - Requires an existing build directory where siconos has been configured and compiled.
#  - Will execute ctest (cmake conf or build or test depending on ctest_mode value) and submit to cdash.
#
# - ctest_mode : choose among 'configure', 'build', 'tests' or 'all'
# - user_option_filename is optional. If not set, siconos build will use cmake/siconos_default.cmake file.
#   Use absolute path or path relative to $CI_PROJECT_DIR/build

: ${CI_PROJECT_DIR:?"Please set environment variable CI_PROJECT_DIR with 'siconos' repository (absolute) path."}
: ${ctest_build_model:?"Please set Dashboard client mode. Choose among Experimental, Continuous or Nightly."}
: ${IMAGE_NAME:?"Please set environment variable IMAGE_NAME. It will be used to name cdash build site."}
: ${cdash_submit:?"Please set environment variable cdash_submit to TRUE or FALSE. If true, ctests results will be submitted to cdash server."}
: ${allow_parallel_build:?"Please set environment variable allow_parallel_build to TRUE or FALSE. If true, ctests will use paralle build option (-jN)".}

ctest_mode=$1
user_file=$2

echo "${ctest_mode} and ${user_file}"
if [ $1 = "Configure" ] || [ $1 = "all" ]
then
    rm -rf $CI_PROJECT_DIR/build
    mkdir -p $CI_PROJECT_DIR/build
    #tmp fix
    python3 -m pip  install packaging
fi
   
# --- Run ctest for Siconos ---
# configure, build, test and submit to cdash.
# 
# Input variables are :
# - model (from gitlab-ci file), Dashboard client mode can be Continuous, Nightly, Experimental, check https://cmake.org/cmake/help/latest/manual/ctest.1.html#ctest-start-step
# - SICONOS_INSTALL_DIR : where Siconos will be installed
# - USER_FILE : user options file.
# - OSNAME : set to IMAGE_NAME
# - ALLOW_PARALLEL_BUILD : set to 1 to allow -jN, 0 to restrict to -j1.
# - CTEST_MODE : choose which parts of ctest process must be run (configure, build, tests or all)
cd $CI_PROJECT_DIR/build
git rev-parse HEAD
    ctest -S ${CI_PROJECT_DIR}/ci_gitlab/ctest_driver_install_siconos.cmake -Dmodel=$ctest_build_model -DSICONOS_INSTALL_DIR=${CI_PROJECT_DIR}/install-siconos -DUSER_FILE=$user_file -DOSNAME=$IMAGE_NAME -DALLOW_PARALLEL_BUILD=$allow_parallel_build -DCDASH_SUBMIT=$cdash_submit -VV -DCTEST_MODE=${ctest_mode}
