      SUBROUTINE IRH1_SETC( FIRST, LAST, SIZE, ARRAY, VALUE, STATUS )
*+
*  Name:
*     IRH1_SETC

*  Purpose:
*     Set part of a character array to a constant value.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL IRH1_SETC( FIRST, LAST, SIZE, ARRAY, VALUE, STATUS )

*  Description:
*     The given value is written into the given part of the array.

*  Arguments:
*     FIRST = INTEGER (Given)
*        The first array element to be written to.
*     LAST = INTEGER (Given)
*        The last array element to be written to.
*     SIZE = INTEGER (Given)
*        The total size of the array.
*     ARRAY( SIZE ) = CHARACTER (Given and Returned)
*        The array.
*     VALUE = CHARACTER (Given)
*        The value to write to the array.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     DSB: David Berry (STARLINK)
*     PDRAPER: Peter Draper (STARLINK)
*     {enter_new_authors_here}

*  History:
*     13-JUN-1991 (DSB):
*        Original version.
*     27-FEB-1992 (PDRAPER):
*        Moved VALUE to end of list as ARRAY usually passed using %VAL
*        construct. %VALed characters must be BEFORE characters passed
*        by descriptor/address on Unix.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Arguments Given:
      INTEGER FIRST
      INTEGER LAST
      CHARACTER VALUE*(*)
      INTEGER SIZE

*  Arguments Given and Returned:
      CHARACTER ARRAY( SIZE )*(*)

*  Status:
      INTEGER STATUS             ! Global status

*  Local Variables:
      INTEGER I                  ! Loop count.

*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Write the given value to the given range of the array.
      DO I = MAX( 1, FIRST ), MIN( SIZE, LAST )
         ARRAY( I ) = VALUE
      END DO

      END
* $Id$
