/*
*+
*  Name:
*     smf_getrefwcs

*  Purpose:
*     Get the spatial and/or spectral WCS from a reference NDF.

*  Language:
*     Starlink ANSI C

*  Type of Module:
*     C function

*  Invocation:
*     smf_getrefwcs( const char *param, AstFrameSet **specwcs,
*                    AstFrameSet **spacewcs, int *status );

*  Arguments:
*     param = const char * (Given)
*        The name of the ADAM parameter used to get the reference NDF.
*     specwcs = AstFrameSet ** (Returned)
*        A pointer to a location at which to return a pointer to an AST 
*        FrameSet describing the spectral axis of the reference NDF. The
*        base Frame will be a 1D Frame with Domain PIXEL, and the current
*        Frame will be a DSBSpecFrame. If no reference NDF is supplied,
*        or if the reference NDF has no spectral axis, a NULL pointer 
*        will be returned.
*     spacewcs = AstFrameSet ** (Returned)
*        A pointer to a location at which to return a pointer to an AST 
*        FrameSet describing the spatial axes of the reference NDF. The
*        base Frame will be a 2D Frame with Domain PIXEL, and the current
*        Frame will be a SkyFrame. If no reference NDF is supplied,
*        or if the reference NDF has no spatial axes, a NULL pointer 
*        will be returned.
*     status = int * (Given and Returned)
*        The inherited status.

*  Description:
*     This function obtains a reference NDF form the user and splits
*     its WCS up into 2 parallel parts; one describing the spatial axes
*     and one descirbing the spectral axis. It is legal for the NDF to
*     contain only one of these two sets of WCS axes (so an output cube 
*     can be aligned with a apatial image or a 1D spectrum).

*  Authors:
*     David S Berry (JAC, UCLan)
*     {enter_new_authors_here}

*  History:
*     18-DEC-2007 (DSB):
*        Initial version.
*     {enter_further_changes_here}

*  Copyright:
*     Copyright (C) 2007 Science & Technology Facilities Council.
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
*     Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
*     MA 02111-1307, USA

*  Bugs:
*     {note_any_bugs_here}
*-
*/

/* Starlink includes */
#include "ast.h"
#include "par.h"
#include "mers.h"
#include "sae_par.h"

/* SMURF includes */
#include "smurf_par.h"
#include "libsmf/smf.h"

#define FUNC_NAME "smf_getrefwcs"


void smf_getrefwcs( const char *param, AstFrameSet **specwcs,
                    AstFrameSet **spacewcs, int *status ){

/* Local Variables */
   AstFrame *bfrm = NULL;       /* Frame describing full PIXEL coords */
   AstFrame *cfrm = NULL;       /* Frame describing required WCS coords */
   AstFrame *gfrm = NULL;       /* Frame describing required PIXEL coords */
   AstFrame *template = NULL;   /* A Frame defining what we are looking for */
   AstFrameSet *fs = NULL;      /* A conversion FrameSet */
   AstFrameSet *refwcs = NULL;  /* The WCS FrameSet from the reference NDF */
   AstMapping *map = NULL;      /* Mapping from full wcs to PIXEL coords */
   AstMapping *splitmap = NULL; /* Mapping from required wcs to PIXEL coords */
   int inax[ 2 ];               /* Indices of required WCS axes */
   int outax[ 7 ];              /* Indices of corresponding PIXEL axes */
   int refndf;                  /* NDF identifier for the refence NDF */

/* Initialise the returned values. */
   *specwcs = NULL;
   *spacewcs = NULL;

/* Check inherited status */
   if( *status != SAI__OK ) return;

/* Begin an AST context. */
   astBegin;

/* Attempt to get the reference NDF from the user. */
   ndfAssoc( param, "READ", &refndf, status ); 

/* If no NDF was supplied, annul the error and do nothing more. */
   if( *status == PAR__NULL ) {
      errAnnul( status );

/* Otherwise, get the WCS FrameSet from the reference NDF. */
   } else {
      ndfGtwcs( refndf, &refwcs, status ); 

/* We no longer need the NDF so annul it. */
      ndfAnnul( &refndf, status );

/* Since astConvert converts between current Frames, we need to ensure
   that the PIXEL Frame is the current Frame in the refernce WCS. This means
   that astConvert will return us the mapping from PIXEL coords to the 
   required WCS coords. The NDF libray ensures that the PIXEL Frame is
   always frame 2. */
      astSetI( refwcs, "Current", 2 );

/* First look for the spatial WCS. Create a SkyFrame that we can use as a
   template for searching the reference WCS. Set a high value for MaxAxes 
   so that SkyFrames can be found within CmpFrames (which will have
   more than 2 axes). We also set PreserveAxes true so that the order of
   the sky axes in the reference WCS is preserved. */
      template = (AstFrame *) astSkyFrame( "MaxAxes=7,PreserveAxes=1" );

/* Use astConvert to search the reference WCS for a SkyFrame. This search
   includes the component Frames contained within CmpFrames. */
      fs = astConvert( refwcs, template, "" );

/* If a SkyFrame was found... */
      if( fs ) {

/* Get the Mapping from sky coords to PIXEL coords. */
         map = astGetMapping( fs, AST__CURRENT, AST__BASE );

/* Get the sky coords Frame. This will be a SkyFrame, but its attributes
   will be inherited form the reference WCS rather than the template
   SkyFrame. */
         cfrm = astGetFrame( fs, AST__CURRENT );

/* Get the PIXEL Frame. If the reference NDF is a cube this will be a 3D
   Frame. */
         bfrm = astGetFrame( fs, AST__BASE );

/* Since the mappiong above may include a spectral axis, see if we can split 
   off the sky axes from the total Mapping. If we can, this will give us the 
   Mapping from 2D sky coords to 2D PIXEL coords. */
         inax[ 0 ] = 1;
         inax[ 1 ] = 2;
         astMapSplit( map, 2, inax, outax, &splitmap );
         if( splitmap && astGetI( splitmap, "Nout" ) == 2 ) {

/* Pick the corresponding 2 axes form the (potentially 3D) PIXEL Frame. */
            gfrm = astPickAxes( bfrm, 2, outax, NULL );

/* Create the returned spatial FrameSet. */
            *spacewcs = astFrameSet( gfrm, "" );
            astInvert( splitmap );
            astAddFrame( *spacewcs, AST__BASE, splitmap, cfrm );
         }                        
      }

/* Now look for the spectral WCS. Create a DSBSpecFrame that we can use as 
   a template for searching the reference WCS. Set a high value for MaxAxes 
   so that DSBSpecFrames can be found within CmpFrames (which will have
   more than 1 axis). */
      template = (AstFrame *) astDSBSpecFrame( "MaxAxes=7" );

/* Use astConvert to search the reference WCS for a DSBSpecFrame. This search
   includes the component Frames contained within CmpFrames. */
      fs = astConvert( refwcs, template, "" );

/* If a DSBSpecFrame was found... */
      if( fs ) {

/* Get the Mapping from spectral coords to PIXEL coords. */
         map = astGetMapping( fs, AST__CURRENT, AST__BASE );

/* Get the spectral coord Frame. This will be a DSBSpecFrame, but its 
   attributes will be inherited form the reference WCS rather than the 
   template DSBSpecFrame. */
         cfrm = astGetFrame( fs, AST__CURRENT );

/* Get the PIXEL Frame. If the reference NDF is a cube this will be a 3D
   Frame. */
         bfrm = astGetFrame( fs, AST__BASE );

/* Since the mappiong above may include spatial axes, see if we can split 
   off the spectral axis axes from the total Mapping. If we can, this will 
   give us the Mapping from 1D spectral coords to 1D PIXEL coords. */
         inax[ 0 ] = 1;
         astMapSplit( map, 1, inax, outax, &splitmap );
         if( splitmap && astGetI( splitmap, "Nout" ) == 1 ) {

/* Pick the corresponding axis form the (potentially 3D) PIXEL Frame. */
            gfrm = astPickAxes( bfrm, 1, outax, NULL );

/* Create the returned spectral FrameSet. */
            *specwcs = astFrameSet( gfrm, "" );
            astInvert( splitmap );
            astAddFrame( *spacewcs, AST__BASE, splitmap, cfrm );
         }                        
      }
   }

/* If no error has occurred, export any returned FrameSet pointers from 
   the current AST context so that it will not be annulled when the AST
   context is ended. Otherwise, ensure a null pointer is returned. */
   if( *status == SAI__OK ) {
      if( *spacewcs ) astExport( *spacewcs );
      if( *specwcs ) astExport( *specwcs );
   } else {
      if( *spacewcs ) *spacewcs = astAnnul( *spacewcs );
      if( *specwcs ) *specwcs = astAnnul( *specwcs );
   }

/* End the AST context. This will annul all AST objects created within the
   context (except for those that have been exported from the context). */
   astEnd;

}
