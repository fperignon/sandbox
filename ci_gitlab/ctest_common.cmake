#[=======================================================================[.rst:
ctest_common.cmake
----
This file contains:

- some functions used to setup ctest config
- the ctest configuration (global variables like CTEST_SOURCE_DIR and so on)

#]=======================================================================]

#[=======================================================================[.rst:
Call this function after each ctest step (ctest_configure,ctest_build ...)
to handle errors and submission to cdash

Usage :

post_ctest(PHASE <phase_name>)

with phase_name in (Configure, Build, Test).
#]=======================================================================]
function(post_ctest)
  set(oneValueArgs PHASE)
  cmake_parse_arguments(run "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  message("------> status/result : ${_STATUS}/${_RESULT}")
  if(${run_PHASE} STREQUAL Configure)
    set(parts ${run_PHASE} Notes)
  else()
    set(parts ${run_PHASE})

  endif()
  if(CDASH_SUBMIT)
    ctest_submit(
      PARTS ${parts}
      RETURN_VALUE RETURN_STATUS
      CAPTURE_CMAKE_ERROR SUBMISSION_STATUS
      )
  else()
    message("- Results won't be submitted to a cdash server.\n")
    return()
  endif()

  if(NOT _STATUS EQUAL 0 OR NOT _RESULT EQUAL 0)
    message(FATAL_ERROR "\n\n *** ${run_PHASE} process failed *** \n\n")
  endif()
  unset(_RESULT PARENT_SCOPE)
  unset(_STATUS PARENT_SCOPE)
  message("=============== End of ctest ${run_PHASE} =============== ")
  if(NOT SUBMISSION_STATUS EQUAL 0)
    message(WARNING " *** submission failure *** ")
  endif()

endfunction()

# Set site name (cdash) according to current host status. 
function(set_site_name)
  
  # -- Query host system information --
  # --> to set ctest site for cdash.
  #include(cmake_host_system_information)
  cmake_host_system_information(RESULT hostname QUERY HOSTNAME)
  cmake_host_system_information(RESULT fqdn QUERY FQDN)

  if(${CMAKE_VERSION} VERSION_GREATER "3.10.3") 
    cmake_host_system_information(RESULT osname QUERY OS_NAME)
    cmake_host_system_information(RESULT osrelease QUERY OS_RELEASE)
    cmake_host_system_information(RESULT osversion QUERY OS_VERSION)
    cmake_host_system_information(RESULT osplatform QUERY OS_PLATFORM)
  else()
    set(osname ${CMAKE_SYSTEM_NAME})
    set(osversion ${CMAKE_SYSTEM_VERSION})
    set(osplatform ${CMAKE_SYSTEM_PROCESSOR})
  endif()

  # With gitlab-ci, runner name is too long and useless ...
  string(FIND ${hostname} "runner-" on_ci) 
  if(on_ci GREATER -1)
    set(hostname "runner: $ENV{CI_RUNNER_DESCRIPTION}")
  endif()

  # Host description
  if(NOT OSNAME)
    set(OSNAME ${osname}) # Use -DOSNAME=docker_image name on CI
  endif()
  
  string(REPLACE
    "gricad-registry.univ-grenoble-alpes.fr/nonsmooth/siconos/"
    "registry, "
    OSNAME ${OSNAME})
  
  set(CTEST_SITE "${OSNAME} ${osrelease}, ${osplatform}, ${hostname}" PARENT_SCOPE)

endfunction()
# set build name, according to host, ci, git status ...
function(set_cdash_build_name)
  # Get hash for commit of current version of Siconos
  # Saved by CI in CI_COMMIT_SHORT_SHA.
  if(DEFINED ENV{GITLAB_CI})
    if($ENV{GITLAB_CI} STREQUAL true)
      set(branch_commit "$ENV{CI_COMMIT_REF_NAME}/$ENV{CI_COMMIT_SHORT_SHA}")
    endif()
    #elseif($ENV{TRAVIS}) # not defined inside docker container run from travis ... ?
    #  set(branch_commit "$ENV{TRAVIS_BRANCH}/$ENV{TRAVIS_COMMIT}")
  else()
    find_package(Git)
    execute_process(COMMAND
      ${GIT_EXECUTABLE} rev-parse --short HEAD
      OUTPUT_VARIABLE COMMIT_SHORT_SHA
      OUTPUT_STRIP_TRAILING_WHITESPACE
      WORKING_DIRECTORY $ENV{CI_PROJECT_DIR})
    execute_process(COMMAND
      ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
      OUTPUT_VARIABLE COMMIT_REF_NAME
      OUTPUT_STRIP_TRAILING_WHITESPACE
      WORKING_DIRECTORY $ENV{CI_PROJECT_DIR})
    set(branch_commit "${COMMIT_REF_NAME}/${COMMIT_SHORT_SHA}")
  endif()
  message("THIS IS A TEST ${branch_commit}")
  include(${CTEST_SOURCE_DIRECTORY}/cmake/SiconosVersion.cmake)  
  set(CTEST_BUILD_NAME "Siconos (${SICONOS_VERSION}-devel, branch/commit=${branch_commit}")
  if(USER_FILE)
    get_filename_component(_name ${USER_FILE} NAME)
    set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME} - Option file: ${_name}")
  endif()

  set(CTEST_BUILD_NAME ${CTEST_BUILD_NAME} PARENT_SCOPE)
  
endfunction()

# ------------------
# Here starts ctest config
# ------------------

if($ENV{TRAVIS})

  list(APPEND CMAKE_MODULE_PATH ${CTEST_SOURCE_DIRECTORY}/ci_travis/cmake)
  list(APPEND CMAKE_MODULE_PATH ${CTEST_SOURCE_DIRECTORY}/ci_travis/config)
  list(APPEND CMAKE_MODULE_PATH ${CTEST_SOURCE_DIRECTORY}/ci_travis)
  include(Tools)

  # -- Get config --
  # i.e. set extra options/values (cmake -Doption=value ...)
  # either from file default.cmake or
  # from file CI_CONFIG.cmake
  # --> may set SICONOS_CMAKE_OPTIONS
  # --> may set DSICONOS_COMPONENTS
  # Rq : For Travis CI, we include cmake files while for gitlab CI we use
  # siconos user option file. Todo: one way to rule them all?

  if(CI_CONFIG)
    string(REPLACE "," ";" CI_CONFIG_LIST ${CI_CONFIG})
    foreach(_CI IN LISTS CI_CONFIG_LIST)
      include(${_CI})
    endforeach()
  else()
    set(CI_CONFIG default)
    include(${CI_CONFIG})
  endif()
endif()

# - Source dir and path to siconos install
if(NOT CTEST_SOURCE_DIRECTORY)
  set(CTEST_SOURCE_DIRECTORY $ENV{CI_PROJECT_DIR})
endif()

# - Top level build directory -
# If not specified : current dir.
if(NOT CTEST_BINARY_DIRECTORY)
  set(CTEST_BINARY_DIRECTORY .)
endif()

# Install dir (used as CMAKE_INSTALL_PREFIX)
# Must be in ${CI_PROJECT_DIR} to work properly with ci artifacts and similar.
if(NOT SICONOS_INSTALL_DIR)
  set(SICONOS_INSTALL_DIR $ENV{CI_PROJECT_DIR}/install-siconos/)
endif()

# Build name (for cdash)
if(NOT CTEST_BUILD_NAME)
  set_cdash_build_name()
endif()

if(USER_FILE)
  list(APPEND SICONOS_CMAKE_OPTIONS -DUSER_OPTIONS_FILE=${USER_FILE})
endif()

list(APPEND SICONOS_CMAKE_OPTIONS -DCMAKE_INSTALL_PREFIX=${SICONOS_INSTALL_DIR})

if(DEFINED ENV{OCE_INSTALL}) # set if oce has been installed using oce repo, in install_oce.sh
  message("Search oce in $ENV{OCE_INSTALL}.")
  list(APPEND SICONOS_CMAKE_OPTIONS -DOCE_DIR=$ENV{OCE_INSTALL})
endif()

# Parallel build only for siconos_install. For examples it leads to: warning: jobserver unavailable: using -j1. Add `+' to parent make rule.
#set(CTEST_MEMORYCHECK_SUPPRESSIONS_FILE ${CTEST_SOURCE_DIRECTORY}/cmake/valgrind.supp)

if(NOT CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()

# if(NOT DEFINED ALLOW_PARALLEL_BUILD)
#   set(ALLOW_PARALLEL_BUILD ON)
# endif()
# option(ALLOW_PARALLEL_BUILD "Allow parallel build" ${ALLOW_PARALLEL_BUILD})
cmake_host_system_information(RESULT NP QUERY NUMBER_OF_LOGICAL_CORES)
if(NOT ALLOW_PARALLEL_BUILD)
  set(NP 1)
endif()
set(CTEST_BUILD_FLAGS -j${NP})

if(NOT CTEST_SITE)
  set_site_name()
endif()

if(NOT CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION "Release")
endif()

