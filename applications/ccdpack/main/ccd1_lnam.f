      SUBROUTINE CCD1_LNAM( PARAM, INDXLO, INDXHI, TITLE, GRPID,
     :                      COMMEN, STATUS )
*+
*  Name:
*     CCD1_LNAM

*  Purpose:
*     Lists the contents of an IRH group to a file via an ADAM
*     parameter.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL CCD1_LNAM( PARAM, INDXHI, INDXLO, TITLE, GRPID, COMMEN,
*                     STATUS )

*  Description:
*     This routine writes the names of the elements in the input IRH
*     group into a text file. The text file is opened via the ADAM
*     parameter PARAM.  The names in the group are taken from the index
*     range INDXLO to INDXHI. A title is written to the first line of
*     the file.

*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        The ADAM parameter used to obtain the text file.
*     INDXLO = INTEGER (Given)
*        The index of the first element of the group which is to be
*        written out.
*     INDXHI = INTEGER (Given)
*        The index of the last element of the group which is to be
*        written out.
*     TITLE = CHARACTER * ( * ) (Given)
*        A title for the first line of the file. This must contain the
*        character # first (i.e. '#  then the actual comment').
*     GRPID = INTEGER (Given)
*        The IRH identifier of the group.
*     COMMEN = _LOGICAL (Given)
*        Whether to write a comment to the user about the name of the
*        output file or not.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     PDRAPER: Peter Draper (STARLINK)
*     {enter_new_authors_here}

*  History:
*     25-MAY-1993 (PDRAPER):
*        Original version.
*     16-JUN-1993 (PDRAPER):
*        Added COMMEN argument as $PARAMETER does not return name.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'IRH_PAR'          ! IRH parameters
      INCLUDE 'FIO_PAR'          ! FIO parameters

*  Arguments Given:
      CHARACTER *  ( * ) PARAM
      INTEGER INDXLO
      INTEGER INDXHI
      CHARACTER * ( * ) TITLE
      INTEGER GRPID
      LOGICAL COMMEN

*  Status:
      INTEGER STATUS             ! Global status

*  External References:
      EXTERNAL CHR_LEN
      INTEGER CHR_LEN            ! Length of string

*  Local Variables:
      CHARACTER * ( IRH__SZNAM ) NAME ! Buffer for name
      CHARACTER * ( FIO__SZFNM ) FNAME ! Buffer for file name
      INTEGER I                  ! Loop variable
      INTEGER FD                 ! File descriptor
      LOGICAL OPEN               ! File is open flag

*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Open the file via the named adam parameter.
      OPEN = .FALSE.
      CALL CCD1_ASFIO( PARAM, 'WRITE', 'LIST', IRH__SZNAM, FD, OPEN,
     :                 STATUS )

*  Write the title
      CALL FIO_WRITE( FD, TITLE( : CHR_LEN( TITLE ) ), STATUS )

*  Loop over the required index extracting the names and then writting
*  them into the file.
      DO 1 I = INDXLO, INDXHI
         NAME = ' '
         CALL IRH_GET( GRPID, I, 1, NAME, STATUS )

*  Now write out the name.
         CALL FIO_WRITE( FD, NAME( : CHR_LEN( NAME ) ), STATUS )
 1    CONTINUE

      IF ( COMMEN .AND. STATUS .EQ. SAI__OK ) THEN 

*  Write a comment about the name of the list.
         CALL FIO_FNAME( FD, FNAME, STATUS )
         CALL MSG_SETC( 'FNAME', FNAME )
         CALL CCD1_MSG( ' ',
     :   '  Namelist written to file: ^FNAME', STATUS )
      END IF

*  Close the file if it is open.
      IF ( OPEN ) CALL FIO_CLOSE( FD, STATUS )
      END
* $Id$
