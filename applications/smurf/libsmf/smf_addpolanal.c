/*
*+
*  Name:
*     smf_addpolanal

*  Purpose:
*     Add a POLANAL Frame to the output FrameSet if required.

*  Language:
*     Starlink ANSI C

*  Type of Module:
*     C function

*  Invocation:
*     smf_addpolanal( AstFrameSet *fset, smfHead *hdr, int *status )

*  Arguments:
*     fset = AstFrameSet * (Given)
*        The WCS FrameSet to be added to the makemap output map. The
*        original base and current Frames are unchanged on exit.
*     hdr = SmfHead * (Given)
*        The header for an example input time-series file.
*     status = int * (Given and Returned)
*        Pointer to the inherited status.

*  Description:
*     If the supplied smfHead indicates that the input time-series
*     data holds POL-2 Q or U values, then a new Frame is added to
*     the supplied FrameSet, which POLPACK will use to define the
*     polarimetric reference direction. The new Frame has domain POLANAL,
*     and its first axis (which defines the reference direction) is
*     parallel to tracking north.
*
*     The input data is assumed to be POL-2 data if the FITS header
*     contains a boolean keyword "POLNORTH" (as written by smurf task
*     CALCQU). An error is reported if POLNORTH is false (i.e. if the Q/U
*     values use focal plane Y as the reference direction rather than
*     tracking north).

*  Authors:
*     David S Berry (JAC, UCLan)
*     {enter_new_authors_here}

*  History:
*     5-JUN-2015 (DSB):
*        Initial version.
*     {enter_further_changes_here}

*  Copyright:
*     Copyright (C) 2015 East Asian Observatory.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 3 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public
*     License along with this program; if not, write to the Free
*     Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
*     MA 02110-1301, USA

*  Bugs:
*     {note_any_bugs_here}
*-
*/

/* Starlink includes */
#include "ast.h"
#include "mers.h"
#include "sae_par.h"

/* SMURF includes */
#include "libsmf/smf.h"

void smf_addpolanal( AstFrameSet *fset, smfHead *hdr, int *status ){

/* Local Variables */
   AstFrame *cfrm;
   AstFrame *pfrm;
   AstFrame *tfrm;
   AstFrameSet *tfs;
   AstPermMap *pm;
   const char *cursys;
   const char *trsys;
   int icurr;
   int inperm[2];
   int outperm[2];
   int polnorth;

/* Check inherited status, and also check the supplied angle is not bad. */
   if( *status != SAI__OK ) return;

/* Begin an AST object context. */
   astBegin;

/* Get the value of the POLNORTH FITS keyword from the supplied header.
   The rest only happens if the keyword is found. */
   if( astGetFitsL( hdr->fitshdr, "POLNORTH", &polnorth ) ) {

/* Report an error if the Q/U data uses focal plane Y as the reference
   direction. */
      if( !polnorth && *status == SAI__OK ) {
         *status = SAI__ERROR;
         errRep( "", "The input NDFs hold POL-2 Q/U data specified with "
                 "respect to focal plane Y.",status );
         errRep( "", "Maps can only be made from POL-2 data specified with "
                 "respect to tracking north.",status );


/* If the ref. direction is tracking north, create a suitable Frame and
   Mapping and add them into the supplied FrameSet. */
      } else {

/* Check the current Frame is a SkyFrame. */
         cfrm = astGetFrame( fset, AST__CURRENT );
         if( astIsASkyFrame( cfrm ) ) {

/* Create a POLANAL Frame. */
            pfrm = astFrame( 2, "Domain=POLANAL" );
            astSet( pfrm, "Title=Polarimetry reference frame" );
            astSet( pfrm, "Label(1)=Polarimetry reference direction" );
            astSet( pfrm, "Label(2)=" );

/* Create a PermMap that ensures that axis 1 of the POLANAL Frame is parallel
   to the latitude axis (i.e. north) of the curent Frame (the current Frame axes
   may have been swapped). */
            outperm[0] = astGetI( cfrm, "LatAxis" );
            outperm[1] = astGetI( cfrm, "LonAxis" );
            inperm[outperm[0]] = 0;
            inperm[outperm[1]] = 1;
            pm = astPermMap( 2, inperm, 2, outperm, NULL, " " );

/* Record the index of the original current Frame. */
            icurr = astGetI( fset, "Current" );

/* Determine the tracking system. */
            trsys = sc2ast_convert_system( hdr->state->tcs_tr_sys, status );

/* If the current Frame in the supplied FrameSet has this system. Then we
   use the above PermMap to connect the POLANAL Frame directly to the current
   Frame. */
            cursys = astGetC( cfrm, "System" );
            if( trsys && cursys && !strcmp( cursys, trsys ) ) {
               astAddFrame( fset, AST__CURRENT, pm, pfrm );

/* Otherwise we need to get a Mapping from the current Frame to the
   tracking frame. */
            } else {

/* Take a copy of the current Frame (in order to pick up epoch, observatory
   position, etc), and set its System to the tracking system. */
               tfrm = astCopy( cfrm );
               astSetC( tfrm, "System", trsys );

/* Get the Mapping from the original current Frame to this modified copy. */
               tfs = astConvert( cfrm, tfrm, "SKY" );
               if( tfs ) {

/* Use it, in series with with the above PermMap, to connect the POLANAL frame
   to the current Frame. */
                  astAddFrame( fset, AST__CURRENT,
                               astCmpMap( astGetMapping( tfs, AST__BASE,
                                                         AST__CURRENT ),
                                          pm, 1, " " ), pfrm );

/* Report an error if the mapping from current to tracking systems could
   not be found. */
               } else if( *status == SAI__OK ) {
                  *status = SAI__ERROR;
                  errRepf( "", "smf_addpolanal: Could not convert Frame "
                           "from %s to %s (prgramming error).", status,
                           cursys, trsys );
               }
            }

/* Re-instate the original current Frame. */
            astSetI( fset, "Current", icurr );

/* Report an error if the current Frame is not a SkyFrame. */
         } else if( *status == SAI__OK ) {
            *status = SAI__ERROR;
            errRep( "", "smf_addpolanal: The current Frame in the "
                    "supplied FrameSet is not a SkyFrame (prgramming "
                    "error).", status );
         }
      }
   }

/* End the AST object context. */
   astEnd;
}

