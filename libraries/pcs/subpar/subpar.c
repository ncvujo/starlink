/*
 *+
 *  Name:
 *     subpar.c

 *  Purpose:
 *     C interface to Fortran SUBPAR routines.

 *  Language:
 *     Starlink ANSI C

 *  Copyright:
 *     Copyright (C) 2008 Science and Technology Facilities Council.
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
 *     TIMJ: Tim Jenness (JAC, Hawaii)
 *     {enter_new_authors_here}

 *  History:
 *     19-JUL-2008 (TIMJ):
 *        Initial version. Don't worry about MUTEXes.

 *  Bugs:
 *     {note_any_bugs_here}

 *-
*/

#include "f77.h"

#include "subpar.h"

F77_SUBROUTINE(subpar_findpar)( CHARACTER(NAME), INTEGER(NAMECODE),
				INTEGER(STATUS) TRAIL(NAME) );

void subParFindpar( const char * name, size_t * namecode, int * status ) {

  DECLARE_CHARACTER_DYN(NAME);
  DECLARE_INTEGER(NAMECODE);
  DECLARE_INTEGER(STATUS);

  F77_CREATE_EXPORT_CHARACTER(name, NAME);
  F77_EXPORT_INTEGER( *status, STATUS );

  F77_CALL(subpar_findpar)( CHARACTER_ARG(NAME),
			    INTEGER_ARG(&NAMECODE),
			    INTEGER_ARG(&STATUS)
			    TRAIL_ARG(NAME) );

  F77_FREE_CHARACTER(NAME);
  F77_IMPORT_INTEGER( NAMECODE, *namecode );
  F77_IMPORT_INTEGER( STATUS, *status );

  return;
}

F77_SUBROUTINE(subpar_get0c)( INTEGER(NAMECODE), CHARACTER(CVALUE),
			      INTEGER(STATUS) TRAIL(CVALUE) );


void subParGet0c( size_t namecode, char *cvalue, size_t cvalue_length,
		  int * status ) {
  DECLARE_INTEGER(NAMECODE);
  DECLARE_CHARACTER_DYN(CVALUE);
  DECLARE_INTEGER(STATUS);

  F77_EXPORT_INTEGER( namecode, NAMECODE );
  F77_CREATE_CHARACTER( CVALUE, cvalue_length - 1 );
  F77_EXPORT_INTEGER( *status, STATUS );

  F77_CALL(subpar_get0c)( INTEGER_ARG(&NAMECODE), CHARACTER_ARG(CVALUE),
			  INTEGER_ARG(&STATUS) TRAIL_ARG(CVALUE) );

  F77_IMPORT_CHARACTER( CVALUE, CVALUE_length, cvalue );
  F77_FREE_CHARACTER( CVALUE );
  F77_IMPORT_INTEGER( STATUS, *status );

  return;
}

F77_SUBROUTINE(subpar_getkey)( INTEGER(NAMECODE), CHARACTER(KEYWORD),
			      INTEGER(STATUS) TRAIL(KEYWORD) );


void subParGetKey( size_t namecode, char *keyword, size_t keyword_length,
		  int * status ) {
  DECLARE_INTEGER(NAMECODE);
  DECLARE_CHARACTER_DYN(KEYWORD);
  DECLARE_INTEGER(STATUS);

  F77_EXPORT_INTEGER( namecode, NAMECODE );
  F77_CREATE_CHARACTER( KEYWORD, keyword_length - 1 );
  F77_EXPORT_INTEGER( *status, STATUS );

  F77_CALL(subpar_getkey)( INTEGER_ARG(&NAMECODE), CHARACTER_ARG(KEYWORD),
			  INTEGER_ARG(&STATUS) TRAIL_ARG(KEYWORD) );

  F77_IMPORT_CHARACTER( KEYWORD, KEYWORD_length, keyword );
  F77_FREE_CHARACTER( KEYWORD );
  F77_IMPORT_INTEGER( STATUS, *status );

  return;
}

F77_SUBROUTINE(subpar_sync)(INTEGER(STATUS));

void subParSync( int * status ) {
  DECLARE_INTEGER(STATUS);
  F77_EXPORT_INTEGER( *status, STATUS );
  F77_CALL(subpar_sync)( INTEGER_ARG(&STATUS) );
  F77_IMPORT_INTEGER( STATUS, *status );

  return;
}

