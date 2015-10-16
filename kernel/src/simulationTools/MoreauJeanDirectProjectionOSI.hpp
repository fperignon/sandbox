/* Siconos-Kernel, Copyright INRIA 2005-2012.
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
  MoreauJeanOSI Time-Integrator for Dynamical Systems for Combined Projection Algorithm
*/

#ifndef MOREAUPROJECTONCONSTRAINTSOSI_H
#define MOREAUPROJECTONCONSTRAINTSOSI_H

#include "OneStepIntegrator.hpp"
#include "MoreauJeanOSI.hpp"
#include "SimpleMatrix.hpp"


const unsigned int MOREAUPROJECTONCONSTRAINTSOSISTEPSINMEMORY = 1;

/**  \class MoreauJeanDirectProjectionOSI 
 *   \brief One Step time Integrator for First Order Dynamical Systems  for
 *    mechanical Systems (LagrangianDS and NewtonEulerDS) with  Direct Projection Algorithm
 *  \author SICONOS Development Team - copyright INRIA
 *  \version 3.4.0.
 *  \date (Creation) May 02, 2012
 *
 * This class reimplement a special activation of constraints
 * in the MoreauJeanOSI for the Direct Projection Algorithm
 *
 * References :
 *
 * V. Acary. Projected event-capturing time-stepping schemes for nonsmooth mechanical systems with unilateral contact 
 * and coulomb’s friction. 
 * Computer Methods in Applied Mechanics and Engineering, 256:224 – 250, 2013. ISSN 0045-7825. 
 * URL http://www.sciencedirect.com/science/article/pii/S0045782512003829.
 *
 */
class MoreauJeanDirectProjectionOSI : public MoreauJeanOSI
{
protected:
  /** serialization hooks
  */
  ACCEPT_SERIALIZATION(MoreauJeanDirectProjectionOSI);

  /** Default constructor
   */
  MoreauJeanDirectProjectionOSI() {};

  double _deactivateYPosThreshold;
  double _deactivateYVelThreshold;
  double _activateYPosThreshold;
  double _activateYVelThreshold;




public:


  /** constructor from theta value only
   *  \param theta value for all these DS.
   */
  explicit MoreauJeanDirectProjectionOSI(double theta);

  DEPRECATED_OSI_API(MoreauJeanDirectProjectionOSI(SP::DynamicalSystem ds, double theta));

  /** constructor from theta value only
    *  \param theta value for all these DS.
    *  \param gamma value for all these DS.
    */
  explicit MoreauJeanDirectProjectionOSI(double theta, double gamma);

  DEPRECATED_OSI_API(MoreauJeanDirectProjectionOSI(SP::DynamicalSystem ds, double theta, double gamma));

  /** destructor
   */
  virtual ~MoreauJeanDirectProjectionOSI() {};

  // --- OTHER FUNCTIONS ---


  // setters and getters

  inline double deactivateYPosThreshold()
  {
    return  _deactivateYPosThreshold;
  };

  inline void setDeactivateYPosThreshold(double newValue)
  {
    _deactivateYPosThreshold = newValue;
  };

  inline double deactivateYVelThreshold()
  {
    return  _deactivateYVelThreshold;
  };

  inline void setDeactivateYVelThreshold(double newValue)
  {
    _deactivateYVelThreshold = newValue;
  };

  inline double activateYPosThreshold()
  {
    return  _activateYPosThreshold;
  };

  inline void setActivateYPosThreshold(double newValue)
  {
    _activateYPosThreshold = newValue;
  };

  inline double activateYVelThreshold()
  {
    return  _activateYVelThreshold;
  };

  inline void setActivateYVelThreshold(double newValue)
  {
    _activateYVelThreshold = newValue;
  };

  /** initialization of the integrator; for linear time
      invariant systems, we compute time invariant operator (example :
      W)
  */
  void initialize();

  /** Apply the rule to one Interaction to known if is it should be included
   * in the IndexSet of level i
   * \param inter concerned interaction 
   * \param i level
   * \return bool
   */
  bool addInteractionInIndexSet(SP::Interaction inter, unsigned int i);

  /** Apply the rule to one Interaction to known if is it should be removed
   * in the IndexSet of level i
   * \param inter concerned interaction 
   * \param i level
   * \return bool
   */
  bool removeInteractionInIndexSet(SP::Interaction inter, unsigned int i);

  /** Perform the integration of the dynamical systems linked to this integrator
   *  without taking into account the nonsmooth input (_r or _p)
   */
  void computeFreeState();

  /** visitors hook
  */
  ACCEPT_STD_VISITORS();

};

#endif // MOREAUPROJECTONCONSTRAINTSOSI_H