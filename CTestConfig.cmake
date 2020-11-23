## This file should be placed in the root directory of your project.
## Then modify the CMakeLists.txt file in the root directory of your
## project to incorporate the testing dashboard.
##
## # The following are required to submit to the CDash dashboard:
##   ENABLE_TESTING()
##   INCLUDE(CTest)

set(CTEST_PROJECT_NAME "siconos-sandbox")
set(CTEST_NIGHTLY_START_TIME "20:00:00 CET")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "siconos-web.univ-grenoble-alpes.fr:8080")
set(CTEST_DROP_LOCATION "/submit.php?project=siconos-dashboard")
#set(CTEST_DROP_SITE "siconos-runner-2.univ-grenoble-alpes.fr")
#set(CTEST_DROP_LOCATION "/submit.php?project=siconos-sandbox")
set(CTEST_DROP_SITE_CDASH TRUE)
if(BUILD_NAME)
  set(CTEST_BUILD_NAME Siconos-${BUILD_NAME})
endif()
