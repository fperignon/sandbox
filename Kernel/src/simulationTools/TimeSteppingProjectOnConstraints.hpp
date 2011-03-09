/* Siconos-Kernel, Copyright INRIA 2005-2010.
 * Siconos is a program dedicated to modeling, simulation and control
 * of non smooth dynamical systems.
 * Siconos is a free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * Siconos is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Siconos; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * Contact: Vincent ACARY, siconos-team@lists.gforge.inria.fr
*/
/*! \file
  Time-Stepping simulation with projections on constraints
*/
#ifndef TIMESTEPPINGPROJECTONCONSTRAINTS_H
#define TIMESTEPPINGPROJECTONCONSTRAINTS_H

#include "TimeStepping.hpp"



/** Time-Stepping scheme
 *
 *  \author SICONOS Development Team - copyright INRIA
 *  \version 3.0.0.
 *  \date (Creation) Aug 2010
 *
 */
class TimeSteppingProjectOnConstraints : public TimeStepping
{
protected:
  virtual void initOSNS();
  /*tolerence allowed on the constrain.*/
  double _constraintTol;
  /*disabled or enabled projection*/
  unsigned int _doProj;
public:

  /** Constructor with the time-discretisation.
  *  \param a pointer to a timeDiscretisation (linked to the model
  *  that owns this simulation)
     \param a one step integrator
     \param a one step non smooth problem for the velocity formulation
     \param a one step non smooth problem for the position formulation
  */
  TimeSteppingProjectOnConstraints(SP::TimeDiscretisation td,
                                   SP::OneStepIntegrator osi,
                                   SP::OneStepNSProblem osnspb_velo,
                                   SP::OneStepNSProblem osnspb_pos);

  virtual ~TimeSteppingProjectOnConstraints();

  virtual bool predictorDeactivate(SP::UnitaryRelation ur, unsigned int i);
  virtual bool predictorActivate(SP::UnitaryRelation ur, unsigned int i);
  virtual void updateWorldFromDS()
  {
    printf("TimeSteppingProjectOnConstraints::updateWordFromDS\n");
  }
  inline void setConstraintTol(double v)
  {
    _constraintTol = v;
  }
  inline void setDoProj(unsigned int v)
  {
    _doProj = v;
  }

  /** newton algorithm
   * \param double, convergence criterion
   * \param unsigned int: maximum number of Newton steps
   */
  void newtonSolve(double, unsigned int);

  /** visitors hook
   */
  //ACCEPT_STD_VISITORS();

};

DEFINE_SPTR(TimeSteppingProjectOnConstraints);

#endif // TIMESTEPPINGPROJECTONCONSTRAINTS_H





