#include <stdio.h>                 // for printf, fclose, fopen, FILE, NULL
/* Siconos is a program dedicated to modeling, simulation and control
 * of non smooth dynamical systems.
 *
 * Copyright 2020 INRIA.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#include <stdlib.h>                // for malloc
#include "CSparseMatrix_internal.h"         // for cs_dl_entry, CS_INT, cs_dl_print
#include "NumericsFwd.h"           // for NumericsMatrix, NumericsSparseMatrix
#include "NumericsMatrix.h"        // for NM_zentry, NM_display, NM_create
#include "NumericsSparseMatrix.h"  // for NumericsSparseMatrix, NSM_TRIPLET
#include "NumericsVector.h"        // for NV_display

#ifdef SICONOS_HAS_MPI
#include <mpi.h>
#endif
int add_square_triplet(void);
int add_square_csc(void);
int add_square_triplet_into_csc(void);

int add_rectangle_triplet(void);

int add_square_triplet()
{


  int size0 =3;
  int size1 =3;

  // product of triplet matrices into triplet matrix
  NumericsMatrix * A  = NM_create(NM_SPARSE, size0, size1);
  NM_triplet_alloc(A,0);
  A->matrix2->origin= NSM_TRIPLET;
  NM_zentry(A, 0, 0, 1);
  NM_zentry(A, 0, 1, 2);
  NM_zentry(A, 0, 2, 3);
  NM_zentry(A, 1, 1, 2);
  NM_zentry(A, 1, 2, 3);
  NM_display(A);


  NumericsMatrix * B  = NM_create(NM_SPARSE, size0, size1);
  NM_triplet_alloc(B,0);
  B->matrix2->origin= NSM_TRIPLET;
  NM_zentry(B, 0, 0, 1);
  NM_zentry(B, 1, 1, 2);
  NM_zentry(B, 2, 2, 3);
  NM_display(B);

  double alpha = 2.0;
  double beta =2.0;
  NumericsMatrix * C = NM_add(alpha, A, beta, B);
  NM_display(C);

  NumericsMatrix * Cref  = NM_create(NM_SPARSE, size0, size1);
  NM_triplet_alloc(Cref,0);
  Cref->matrix2->origin= NSM_TRIPLET;
  NM_zentry(Cref, 0, 0, 4);
  NM_zentry(Cref, 0, 1, 4);
  NM_zentry(Cref, 0, 2, 6);
  NM_zentry(Cref, 1, 1, 8);
  NM_zentry(Cref, 1, 2, 6);
  NM_zentry(Cref, 2, 2, 6);
  NM_display(Cref);

  printf("add_square_triplet: NM_equal(C,Cref) =%i \n", NM_equal(C,Cref));
  return (int)!NM_equal(C,Cref);


}

int add_square_csc()
{


  int size0 =3;
  int size1 =3;

  // product of csc matrices into csc matrix
  NumericsMatrix * A  = NM_create(NM_SPARSE, size0, size1);
  NM_csc_empty_alloc(A,0);
  A->matrix2->origin= NSM_CSC;
  NM_zentry(A, 0, 0, 1);
  NM_zentry(A, 0, 1, 2);
  NM_zentry(A, 0, 2, 3);
  NM_zentry(A, 1, 1, 2);
  NM_zentry(A, 1, 2, 3);
  /* NM_display(A); */


  NumericsMatrix * B  = NM_create(NM_SPARSE, size0, size1);
  NM_csc_empty_alloc(B,0);
  B->matrix2->origin= NSM_CSC;
  NM_zentry(B, 0, 0, 1);
  NM_zentry(B, 1, 1, 2);
  NM_zentry(B, 2, 2, 3);
  /* NM_display(B); */

  double alpha = 2.0;
  double beta =  2.0;
  NumericsMatrix * C = NM_add(alpha, A, beta, B);
  NM_display(C);

  NumericsMatrix * Cref  = NM_create(NM_SPARSE, size0, size1);
  NM_csc_empty_alloc(Cref,0);
  Cref->matrix2->origin= NSM_CSC;
  NM_zentry(Cref, 0, 0, 4);
  NM_zentry(Cref, 0, 1, 4);
  NM_zentry(Cref, 0, 2, 6);
  NM_zentry(Cref, 1, 1, 8);
  NM_zentry(Cref, 1, 2, 6);
  NM_zentry(Cref, 2, 2, 6);
  NM_display(Cref);
  printf("add_square_csc: NM_equal(C,Cref) =%i \n", NM_equal(C,Cref));
  return (int)!NM_equal(C,Cref);;

}

int add_rectangle_triplet()
{


  int size0 =3;
  int size1 =9;

  // product of triplet matrices into triplet matrix
  NumericsMatrix * A  = NM_create(NM_SPARSE, size0, size1);
  NM_triplet_alloc(A,0);
  A->matrix2->origin= NSM_TRIPLET;
  NM_zentry(A, 0, 0, 1);
  NM_zentry(A, 0, 1, 2);
  NM_zentry(A, 0, 2, 3);
  NM_zentry(A, 1, 1, 2);
  NM_zentry(A, 1, 2, 3);
  NM_zentry(A, 2, 6, 2);
  NM_zentry(A, 2, 5, 22);
  NM_display(A);


  NumericsMatrix * B  = NM_create(NM_SPARSE, size0, size1);
  NM_triplet_alloc(B,0);
  B->matrix2->origin= NSM_TRIPLET;
  NM_zentry(B, 0, 0, 1);
  NM_zentry(B, 1, 1, 2);
  NM_zentry(B, 2, 2, 3);
  NM_zentry(B, 0, 3, 1);
  NM_zentry(B, 1, 4, 2);
  NM_zentry(B, 2, 5, 3);
  NM_display(B);

  double alpha = 1.0;
  double beta  = 2.0;
  NumericsMatrix * C = NM_add(alpha, A, beta, B);
  NM_display(C);

  NumericsMatrix * Cref  = NM_create(NM_SPARSE, size0, size1);
  NM_triplet_alloc(Cref,0);
  Cref->matrix2->origin= NSM_TRIPLET;
  NM_zentry(Cref, 0, 0, 3);
  NM_zentry(Cref, 0, 1, 2);
  NM_zentry(Cref, 0, 2, 3);
  NM_zentry(Cref, 0, 3, 2);

  NM_zentry(Cref, 1, 1, 6);
  NM_zentry(Cref, 1, 2, 3);
  NM_zentry(Cref, 1, 4, 4);

  NM_zentry(Cref, 2, 2, 6);


  NM_zentry(Cref, 2, 5, 28);
  NM_zentry(Cref, 2, 6, 2);
  NM_display(Cref);

  printf("add_rectangle_triplet : NM_equal(C,Cref) =%i \n", NM_equal(C,Cref));
  return (int)!NM_equal(C,Cref);


}

static int add_test(void)
{

  int info = add_square_triplet();
  info += add_square_csc();
  info +=  add_rectangle_triplet();

  return info;
}



/* create an empty triplet matrix, insert 2 elements, print and free */
static int test_CSparseMatrix_alloc(void)
{
  CSparseMatrix *m = cs_spalloc(0,0,0,0,1); /* coo format */

  CS_INT info1 = 1-cs_entry(m, 3, 4, 1.0);
  CS_INT info2 = 1-cs_entry(m, 1, 2, 2.0);

  CS_INT info3 = 1-cs_print(m, 0);

  m=cs_spfree(m);

  CS_INT info4 = 1-(m==NULL);

  return (int)(info1+info2+info3+info4);
}

static int test_CSparseMatrix_spsolve_unit(CSparseMatrix *M )
{
  //cs_print(M, 0);

  CSparseMatrix *b_triplet = cs_spalloc(M->m, M->n,M->n, 1, 1); /* coo format */
  for (int i; i < M->n; i++)
    cs_entry(b_triplet, i, i, 1.0);

  CSparseMatrix *B = cs_compress(b_triplet);

  CSparseMatrix *X = cs_spalloc(M->m, M->n, M->nzmax, 1,0); /* csr format */

  CSparseMatrix_factors* cs_lu_M = (CSparseMatrix_factors*) malloc(sizeof(CSparseMatrix_factors));

  int info = 1-CSparseMatrix_lu_factorization(1, M, 1e-14, cs_lu_M);

  if (info)
  {
    printf("problem in Lu factor\n");
    return info;
  }
  /* printf(" L:\n"); */
  /* cs_print(cs_lu_M->N->L, 0); */
  /* printf(" U:\n"); */
  /* cs_print(cs_lu_M->N->U, 0); */

  info = !CSparseMatrix_spsolve(cs_lu_M, X, B);
  if (info)
  {
    printf("problem in spsolve\n");
    return info;
  }
  CSparseMatrix* I = cs_multiply(M, B);
  //printf(" M * M^-1:\n");
  //cs_print(I, 0);

  CSparseMatrix *Id = cs_compress(b_triplet);

  CSparseMatrix* check = cs_add(I, Id, 1.0, -1.0);
  //cs_print(check, 0);

  if (cs_norm(check) > 1-14)
  {
    return 1;

  }

  return  info;
}



static int test_CSparseMatrix_spsolve(void)
{
  CSparseMatrix *m_triplet = cs_spalloc(3,3,3,1,1); /* coo format */
  cs_entry(m_triplet, 0, 0, 1.0);
  cs_entry(m_triplet, 1, 1, 2.0);
  cs_entry(m_triplet, 2, 2, 4.0);
//  CS_INT info4 = 1-cs_print(m_triplet, 0);
  CSparseMatrix *M = cs_compress(m_triplet);

  int info =  test_CSparseMatrix_spsolve_unit(M);

  cs_entry(m_triplet, 0, 1, 3.0);
  cs_entry(m_triplet, 0, 2, 6.0);
  cs_entry(m_triplet, 1, 2, 5.0);

  CSparseMatrix *M1 = cs_compress(m_triplet);
  info +=  test_CSparseMatrix_spsolve_unit(M1);

  cs_entry(m_triplet, 1, 0, 7.0);
  cs_entry(m_triplet, 2, 0, 8.0);
  cs_entry(m_triplet, 2, 1, 9.0);

  CSparseMatrix *M2 = cs_compress(m_triplet);
  info +=  test_CSparseMatrix_spsolve_unit(M2);


  int size0 =10;
  int size1 =10;
  CSparseMatrix *a_triplet = cs_spalloc(size0,size1,size0,1,1); /* coo format */
  for(int i =0; i < size0; i++)
  {
    for(int j =i; j < size1; j++)
    {
      cs_entry(a_triplet, i, j, i+j+1);
    }
  }
  CSparseMatrix *A = cs_compress(a_triplet);
  info +=  test_CSparseMatrix_spsolve_unit(A);

  return  info;
}





int main()
{
#ifdef SICONOS_HAS_MPI
  MPI_Init(NULL, NULL);
#endif
  int info = add_test();

  info += test_CSparseMatrix_alloc();



  info += test_CSparseMatrix_spsolve();

#ifdef SICONOS_HAS_MPI
  MPI_Finalize();
#endif

  return info;
}
