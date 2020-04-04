/** -*- C -*- !! Do not edit this file !!

SiconosConfig.h is generated by cmake from config.h.cmake
depending on the current configuration, on user options (WITH_...) and on their
availability on your system.
Example : if cmake is executed with WITH_MPI=ON
--> if a proper mpi installation is found on your system, then
 SICONOS_HAS_MPI is on and will be defined in this file.
**/

#ifndef SICONOSCONFIG_H
#define SICONOSCONFIG_H

#define WITH_CMAKE

// -- Siconos components --
#cmakedefine HAVE_SICONOS_EXTERNALS
#cmakedefine HAVE_SICONOS_NUMERICS
#cmakedefine HAVE_SICONOS_KERNEL
#cmakedefine HAVE_SICONOS_CONTROL
#cmakedefine HAVE_SICONOS_MECHANICS
#cmakedefine HAVE_SICONOS_MECHANISMS
#cmakedefine HAVE_SICONOS_IO

// -- Global options --
// openmp required and available -
#cmakedefine WITH_OPENMP
// Fortran sources included in the build -
#cmakedefine HAS_FORTRAN
// Use c++ to build externals and numerics
#cmakedefine BUILD_AS_CPP
// Which version of C++ was used to compile siconos, needed for swig
//#define SICONOS_CXXVERSION @CXXVERSION@
#cmakedefine SICONOS_USE_MAP_FOR_HASH
// are int 64 bits longs
#cmakedefine SICONOS_INT64

// use to force 32 bits int when creating numpy array
// Useful to support old scipy version (< 0.14.0)
#cmakedefine SICONOS_FORCE_NPY_INT32

// on opensuse 42.3 Stdxx.h, failure with cxx11 and using std::isnan
#cmakedefine SICONOS_STD_ISNAN_ALREADY_HERE_AND_I_DO_NOT_KNOW_WHY

// -- Blas Lapack config --
// Where does cblas comes from? 
#cmakedefine HAS_MKL_CBLAS
#cmakedefine HAS_ACCELERATE // includes also lapack from Accelerate
#cmakedefine HAS_OpenBLAS 
// mkl stuff.
#cmakedefine WITH_MKL_SPBLAS
#cmakedefine WITH_MKL_PARDISO

// Which Lapack? 
#cmakedefine HAS_MKL_LAPACKE
#cmakedefine HAS_MATLAB_LAPACK

// Which functions are defined in lapack?
// This concerns only functions that are not available in all implementations.
#cmakedefine HAS_LAPACK_dgesvd
#cmakedefine HAS_LAPACK_dtrtrs
#cmakedefine HAS_LAPACK_dgels


// -- Optional parts in externals --
#cmakedefine HAVE_SORT
#cmakedefine HAVE_QL0001
// Some definitions required for boost numeric_bindings
#define BOOST_NUMERIC_BINDINGS_BLAS_CBLAS
#if defined(HAS_MKL_CBLAS)
#define BOOST_NUMERIC_BINDINGS_BLAS_MKL
#endif

// -- Optional solvers and tools for numerics --
// - Simplex solver -
#cmakedefine HAVE_MLCPSIMPLEX
// LP solver
#cmakedefine HAS_ONE_LP_SOLVER
#cmakedefine HAS_EXTREME_POINT_ALGO
// Gams stuff
#cmakedefine GAMS_MODELS_SOURCE_DIR "@GAMS_MODELS_SOURCE_DIR@"
#cmakedefine GAMS_MODELS_SHARE_DIR "@GAMS_MODELS_SHARE_DIR@"
#cmakedefine GAMS_DIR "@GAMS_ROOT@"
#cmakedefine HAVE_GAMS_C_API
// - Path solver -
#cmakedefine HAVE_PATHFERRIS
#cmakedefine HAVE_PATHVI
// umfpack solvers
#cmakedefine WITH_UMFPACK
// SuperLU solvers
#cmakedefine WITH_SUPERLU
#cmakedefine WITH_SUPERLU_MT
#cmakedefine WITH_SUPERLU_dist

// - internal timer -
#cmakedefine HAVE_TIME_H
#cmakedefine HAVE_SYSTIMES_H
#cmakedefine WITH_TIMERS
// - mpi part -
#cmakedefine SICONOS_HAS_MPI
#cmakedefine WITH_MPI4PY
// - mumps solver -
#cmakedefine WITH_MUMPS
// - fclib interface -
#cmakedefine WITH_FCLIB
// option in fc problems used to dump some info.
#cmakedefine DUMP_PROBLEM

// for md5 signatures
#cmakedefine WITH_OPENSSL

// -- Optional parts for mechanics --
#cmakedefine SICONOS_HAS_BULLET
#cmakedefine SICONOS_HAS_OCE

// -- Optional parts for io --
#cmakedefine SICONOS_HAS_VTK
#cmakedefine HAVE_SERIALIZATION
#cmakedefine WITH_SERIALIZATION
#cmakedefine HAVE_GENERATION
#cmakedefine WITH_HDF5



#endif

