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
  if(NOT _STATUS EQUAL 0 OR NOT _RESULT EQUAL 0)
    if(CDASH_SUBMIT)
      ctest_submit(
        RETURN_VALUE RETURN_STATUS
        CAPTURE_CMAKE_ERROR SUBMISSION_STATUS
        )
      if(NOT SUBMISSION_STATUS EQUAL 0)
        message(WARNING " *** submission failure *** ")
      endif()
    else()
      message("- Results won't be submitted to a cdash server.\n")
      return()
    endif()
    message(FATAL_ERROR "\n\n *** ${run_PHASE} process failed *** \n\n")
  endif()
  unset(_RESULT PARENT_SCOPE)
  unset(_STATUS PARENT_SCOPE)
  message("=============== End of ctest ${run_PHASE} =============== ")

endfunction()

# Set site name (cdash) according to current host status. 
function(set_site_name)
  
  # -- Query host system information --
  # --> to set ctest site for cdash.
  #include(cmake_host_system_information)
  cmake_host_system_information(RESULT hostname QUERY HOSTNAME)
  cmake_host_system_information(RESULT fqdn QUERY FQDN)

  if(${CMAKE_VERSION} VERSION_GREATER "3.10.3") 
    # https://cmake.org/cmake/help/latest/command/cmake_host_system_information.html
    cmake_host_system_information(RESULT osname QUERY OS_NAME)
    cmake_host_system_information(RESULT osrelease QUERY OS_RELEASE)
    cmake_host_system_information(RESULT osplatform QUERY OS_PLATFORM)
    cmake_host_system_information(RESULT hostname QUERY HOSTNAME)

    message(STATUS "ok ${osname}")
    message(STATUS "ok ${osrelease}")
    message(STATUS "ok ${hostname}")
    message(STATUS "ok ${osplatform}")
   
   
  else()
    set(osname ${CMAKE_SYSTEM_NAME})
    set(osplatform ${CMAKE_SYSTEM_PROCESSOR})
  endif()

  string(STRIP ${osname} osname)
  string(STRIP ${osplatform} osplatform)

  if(CI_GITLAB)
  message(" oosoqsoo o oo o  $ENV{CI_REGISTRY_IMAGE} and $ENV{CI_JOB_IMAGE}")

    string(REPLACE "\${CI_REGISTRY_IMAGE}/" " " dockerimagename $ENV{CI_JOB_IMAGE} )
   message(" oosoqsoo o oo o  ${dockerimagename}")
    string(STRIP ${dockerimagename} dockerimagename)
    set(osname "${osname}-${dockerimagename}")
     message(" oosoqsoo o oo o  ${osname}")
  
    string(STRIP ${osname} osname)
    set(hostname "registry-on-gitlab-runner-$ENV{CI_RUNNER_DESCRIPTION}")
  elseif(CI_TRAVIS)
    set(hostname "${hostname}-travis") 
  endif()
 message(" RAAAAAA   ${hostname}")
  
  set(_SITE "${osname}-${osrelease}-${osplatform}-${hostname}")
  string(STRIP _SITE ${_SITE})
    
  set(CTEST_SITE "${_SITE}" PARENT_SCOPE)
endfunction()

# set build name, according to host, ci, git status ...
function(set_cdash_build_name)
  # Get hash for commit of current version of Siconos
  # Saved by CI in CI_COMMIT_SHORT_SHA.
  if(CI_GITLAB)
    set(branch_commit "$ENV{CI_COMMIT_REF_NAME}-$ENV{CI_COMMIT_SHORT_SHA}")
  elseif(CI_TRAVIS) 
    string(SUBSTRING $ENV{TRAVIS_COMMIT} 1 7 TRAVIS_SHORT_COMMIT})
    message("SHORT TRAVIS SHA ${TRAVIS_SHORT_COMMIT}")
    string(STRIP ${TRAVIS_SHORT_COMMIT} TRAVIS_SHORT_COMMIT)
    set(branch_commit "$ENV{TRAVIS_BRANCH}-${TRAVIS_SHORT_COMMIT}")
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
    set(branch_commit "${COMMIT_REF_NAME}-${COMMIT_SHORT_SHA}")
  endif()
  include(${CTEST_SOURCE_DIRECTORY}/cmake/SiconosVersion.cmake)  
  set(_name "Siconos(${SICONOS_VERSION}-devel,${branch_commit})")
  if(USER_FILE)
     get_filename_component(_fname ${USER_FILE} NAME)
     string(STRIP ${_fname} _fname)
     set(_name "${_name}-option-${_fname}")
     string(STRIP ${_name} _name)
  endif()

  set(CTEST_BUILD_NAME "${_name}" PARENT_SCOPE)
  
endfunction()

# ------------------
# Here starts ctest config
# ------------------

if(CI_TRAVIS)
  message("TRAVIS SEEN !!!!")
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

if(NOT CTEST_SITE)
  set_site_name()
endif()

if(NOT CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION "Release")
endif()

