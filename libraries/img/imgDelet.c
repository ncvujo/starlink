/*
 *+
 *  Name:
 *     imgDelet
 
 *  Purpose:
 *     Deletes an image.
 
 *  Language:
 *     ANSI C
 
 *  Invocation:
 *     imgDelet( param,
 *               status )
 
 *  Description:
 *     This C function sets up the required arguments and calls the
 *     Fortran subroutine img_delet.
 *     On return, values are converted back to C form if necessary.
 
 *  Arguments:
 *     param = char * (Given)
 *        Parameter name specifying the image to be deleted.
 *     status = int * (Given and Returned)
 *        The global status.
 
*  Copyright:
*     Copyright (C) 1996 Central Laboratory of the Research Councils.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 2 of
*     the License, or (at your option) any later version.
*     
*     This program is distributed in the hope that it will be
*     useful,but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*     
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA
*     02111-1307, USA

 *  Authors:
 *     The orginal version was generated automatically from the
 *     Fortran source of img_delet by the Perl script fcwrap.
 *     {enter_new_authors_here}
 
 *  History:
 *     17-May-1996 (fcwrap):
 *        Original version
 *     {enter_changes_here}
 
 *-
 */
#include "cnf.h"
#include "f77.h"
#include "string.h"

F77_SUBROUTINE(img_delet)( CHARACTER(param),
                           INTEGER(status)
                           TRAIL(param) );

void imgDelet( char *param,
               int *status ) {
  
  DECLARE_CHARACTER_DYN(fparam);

  F77_CREATE_CHARACTER(fparam,strlen( param ));
  cnf_exprt( param, fparam, fparam_length );

  F77_CALL(img_delet)( CHARACTER_ARG(fparam),
                       INTEGER_ARG(status)
                       TRAIL_ARG(fparam) );

  F77_FREE_CHARACTER(fparam);

  return;
}

/* $Id$ */
