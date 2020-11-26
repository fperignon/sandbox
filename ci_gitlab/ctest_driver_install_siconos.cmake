#-----------------------------------------------
# Ctest driver for siconos install.
# Target : continuous integration on gitlab-ci,
# aims at providing a proper install of siconos for a given configuration.
#
# Input variables :
# - SICONOS_INSTALL_DIR : where to install siconos. Default : ../install-siconos
# - USER_FILE : user option file used by cmake to configure siconos. Default : siconos_conf.cmake.
#   Warning : always searched in siconos-tutorials/ci directory.
# - OSNAME : host system name (used to qualify cdash build). If not set, try to catch info
#   using common commands (lsb_release ...)
# ----------------------------------------------


message("--- Start conf for siconos ctest pipeline.")

# ============= setup  ================

# -- CI_PROJECT_DIR is a required environment variable --
# --> set by default for gitlab-ci, even inside the docker container
# --> unknown in docker container run with travis/siconos pipeline.


if(NOT DEFINED ENV{CI_PROJECT_DIR} )
  if(DEFINED CTEST_SOURCE_DIRECTORY) # travis case
    set(ENV{CI_PROJECT_DIR} ${CTEST_SOURCE_DIRECTORY})
  else()    
    message(FATAL_ERROR "Please set env variable CI_PROJECT_DIR to siconos sources directory (git repo).")
  endif()
endif()
message(" TEST TRAVIS $ENV{CI_PROJECT_DIR}")

# -- Definition of all variables required for ctest --
include($ENV{CI_PROJECT_DIR}/ci_gitlab/ctest_common.cmake)

if(USER_FILE)
  # Push user file as notes to cdash.
  set(CTEST_NOTES_FILES ${USER_FILE})
endif()

# =============  Run ctest steps ================
# Either one by one (to split ci jobs) if CTEST_MODE=Configure, Build, Test or
# all in a row if CTEST_MODE=all.
# Submit : only after test phase except if conf or build failed.

# - Configure -- 
if(${CTEST_MODE} STREQUAL "Configure" OR ${CTEST_MODE} STREQUAL "all")

  # Current testing model. Priority: 
  # Nightly -> set by scheduler on gricad-gitlab
  # Continuous -> set in .gitlab-ci.yml
  # Experimental : default
  if(NOT model)
    set(model Experimental)
  endif()

  ctest_start(${model})

  # Set CTEST_CONFIGURE_COMMAND to cmake followed by siconos options 
  set(CTEST_CONFIGURE_COMMAND ${CMAKE_COMMAND})
  foreach(option IN LISTS SICONOS_CMAKE_OPTIONS)
    set(CTEST_CONFIGURE_COMMAND "${CTEST_CONFIGURE_COMMAND} ${option}")
  endforeach()
  set(CTEST_CONFIGURE_COMMAND "${CTEST_CONFIGURE_COMMAND} ${CTEST_SOURCE_DIRECTORY}")

  message("\n\n=============== Start ctest_configure =============== ")
  message("- Configure command line :\n ${CTEST_CONFIGURE_COMMAND}\n")

  ctest_configure(
    RETURN_VALUE _RESULT
    CAPTURE_CMAKE_ERROR _STATUS
    #QUIET
    )
  post_ctest(PHASE Configure)
endif()
 
# - Build -
if(${CTEST_MODE} STREQUAL "Build" OR ${CTEST_MODE} STREQUAL "all")

  if(${CTEST_MODE} STREQUAL "Build")
    ctest_start(APPEND) # Restart from existing (configure step) cdash config
  endif()
  # --- Build ---

  message("\n\n=============== Start ctest_build =============== ")

  cmake_host_system_information(RESULT NP QUERY NUMBER_OF_LOGICAL_CORES)
  if(NOT ALLOW_PARALLEL_BUILD)
    set(NP 1)
  endif()
  ctest_build(
    FLAGS -j${NP}
    CAPTURE_CMAKE_ERROR _STATUS
    RETURN_VALUE _RESULT
    #QUIET if quiet, travis failed because of missing outputs during a long time ...
    )
  post_ctest(PHASE Build)
endif()

# - Test -
if(${CTEST_MODE} STREQUAL "Test" OR ${CTEST_MODE} STREQUAL "all")
  # -- Tests --
  
  if(${CTEST_MODE} STREQUAL "Test")
    ctest_start(APPEND)
  endif()
  message("\n\n=============== Start ctest_test (nbprocs = ${NP}) =============== ")
  ctest_test(
    #PARALLEL_LEVEL NP
    CAPTURE_CMAKE_ERROR _STATUS
    #SCHEDULE_RANDOM ON
    RETURN_VALUE _RESULT
    # QUIET
    )
  
  if(WITH_MEMCHECK AND CTEST_COVERAGE_COMMAND)
    #find_program(CTEST_COVERAGE_COMMAND NAMES gcov)
    # set(CTEST_COVERAGE_COMMAND gcov)

    ctest_coverage(
      CAPTURE_CMAKE_ERROR COVERAGE_STATUS
      RETURN_VALUE COVERAGE_RESULT  
      )
  endif()

  if(WITH_MEMCHECK AND CTEST_MEMORYCHECK_COMMAND)
    ctest_memcheck()
  endif()

  if(CDASH_SUBMIT)
    ctest_submit(
      RETURN_VALUE RETURN_STATUS
      CAPTURE_CMAKE_ERROR SUBMISSION_STATUS
      )
    if(NOT SUBMISSION_STATUS EQUAL 0)
      message(WARNING " *** submission failure *** ")
    endif()
  endif()

  # -- memory check -- Skip this to 'enlight' submit process, since cdash inria is overbooked ...
  # if(CTEST_BUILD_CONFIGURATION MATCHES "Profiling")
  #   find_program(CTEST_MEMORYCHECK_COMMAND NAMES valgrind)
  #   set(CTEST_MEMORYCHECK_COMMAND_OPTIONS "--quiet --leak-check=full --show-leak-kinds=definite,possible --track-origins=yes --error-limit=no --gen-suppressions=all") 
  #   set(CTEST_MEMORYCHECK_COMMAND_OPTIONS "--quiet --leak-check=full --show-reachable=yes --error-limit=no --gen-suppressions=all") 
  #   ctest_memcheck(PARALLEL_LEVEL NP QUIET)
  # endif()

endif()


# ============= Summary =============
message(STATUS "\n============================================ Summary ============================================")
message(STATUS "CTest process for Siconos has ended.")
message(STATUS "Ctest model is: ${model}")
message(STATUS "Ctest mode was: ${CTEST_MODE}")
message(STATUS "Ctest executed on sources directory : ${CTEST_SOURCE_DIRECTORY}")
message(STATUS "CTEST_BINARY_DIRECTORY is: ${CTEST_BINARY_DIRECTORY}")
message(STATUS "CTEST_BUILD_CONFIGURATION is: ${CTEST_BUILD_CONFIGURATION}")
if(CDASH_SUBMIT)
  message(STATUS "Cdash server name: ${CTEST_DROP_SITE}/${CTEST_DROP_LOCATION}.")
  message(STATUS "Cdash build name: ${CTEST_BUILD_NAME}")
  message(STATUS "Cdash Site name: ${CTEST_SITE}")
endif()
message(STATUS "=================================================================================================\n")
