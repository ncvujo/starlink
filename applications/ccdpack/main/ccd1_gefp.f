      SUBROUTINE CCD1_GEFP( GRAPH, NEDGES, X1, Y1, X2, Y2, ID1, N, OFFS,
     :                      NODE, XN, YN, IDN, NOUT, STATUS )
*+
*  Name:
*     CCD1_GEFP

*  Purpose:
*     Creates the final position lists removing multiple
*     identifications.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL CCD1_GEFP( GRAPH, NEDGES, X1, Y1, X2, Y2, ID1, N, OFFS,
*                     NODE, XN, YN, IDN, NOUT, STATUS )

*  Description:
*     This routine perform the task of extracting all the position
*     information from an extended list of X and Y positions which have
*     identifiers assigned. Multiple occurrences of any identifiers
*     are removed and all the positions related to a given node are
*     returned.

*  Arguments:
*     GRAPH( 4, NEDGES ) = INTEGER ) (Given)
*        The spanning graph of edges which are associated with the
*        positions X1(*), Y1(*) and X2(*), Y2(*).
*        The indices of an edge's position list are (4,*) in this array.
*     NEDGES = INTEGER (Given)
*        The number of edges in the spanning graph.
*     X1( N ) = DOUBLE PRECISION (Given)
*        The X1 position list merged into one. The offsets into this
*        list are OFFS.
*     Y1( N ) = DOUBLE PRECISION (Given)
*        The Y1 position list merged into one. The offsets into this
*        list are OFFS.
*     X2( N ) = DOUBLE PRECISION (Given)
*        The X2 position list merged into one. The offsets into this
*        list are OFFS.
*     Y2( N ) = DOUBLE PRECISION (Given)
*        The X1 position list merged into one. The offsets into this
*        list are OFFS.
*     N = INTEGER (Given)
*        The total number of entries in input merged lists.
*     OFFS( NEDGES  + 1 ) = INTEGER (Given)
*        The offsets of the start of the input lists which are
*        associated with an edge. Thus range (OFFS(1), OFFS(2) -1 )
*        of the arrays X1,Y1 and X2,Y2 contains the first edges position
*        lists etc.
*     NODE = INTEGER (Given)
*        The number of the node whose positions and identifiers are to
*        be removed from the input lists and returned with multiple
*        identifications of the same position removed.
*     XN( * ) = DOUBLE PRECISION (Returned)
*        On exit this array contains the extracted X positions.
*     YN( * ) = DOUBLE PRECISION (Returned)
*        On exit this array contains the extracted Y positions.
*     IDN( * ) = DOUBLE PRECISION (Returned)
*        On exit this array contains the extracted identifiers.
*     NOUT = INTEGER (Returned)
*        The number of valid entries in the XN,YN and IDN arrays on
*        exit.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     PDRAPER: Peter Draper (STARLINK)
*     {enter_new_authors_here}

*  History:
*     15-DEC-1992 (PDRAPER):
*        Original version.
*     7-MAR-1993 (PDRAPER):
*        Complete rewrite.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Arguments Given:
      INTEGER NEDGES
      INTEGER GRAPH( 4, NEDGES )
      INTEGER N
      INTEGER ID1( N )
      DOUBLE PRECISION X1( N )
      DOUBLE PRECISION Y1( N )
      DOUBLE PRECISION X2( N )
      DOUBLE PRECISION Y2( N )
      INTEGER OFFS( NEDGES + 1 )
      INTEGER NODE

*  Arguments Returned:
      INTEGER IDN( * )
      DOUBLE PRECISION XN( * )
      DOUBLE PRECISION YN( * )
      INTEGER NOUT

*  Status:
      INTEGER STATUS             ! Global status

*  Local Variables:
      INTEGER I                  ! Loop variable
      INTEGER K                  ! Loop variable
      INTEGER NN                 ! Count of output values
      INTEGER IDNOW              ! Current ID
*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Initialise the output count.
      NN = 0 

*  Visit each edge.
      DO 1 I = 1, NEDGES

*  Does this edge contain the node?
         IF ( GRAPH( 1, I ) .EQ. NODE ) THEN 

*  Start copying X, Y and IDs
            DO 2 K = OFFS( I ), OFFS( I + 1 ) - 1
               NN = NN + 1
               IDN( NN ) = ID1( K )
               XN( NN ) = X1( K ) 
               YN( NN ) = Y1( K )
 2          CONTINUE
         ELSE IF ( GRAPH( 2, I ) .EQ. NODE ) THEN 

*  Start copying X, Y and IDs
            DO 3 K = OFFS( I ), OFFS( I + 1 ) - 1 
               NN = NN + 1
               IDN( NN ) = ID1( K )
               XN( NN ) = X2( K ) 
               YN( NN ) = Y2( K )
 3          CONTINUE
         END IF
 1    CONTINUE

*  Now have all the data associated with this node, remove multiple
*  identifications.
      DO 4 I = 1, NN - 1
         IDNOW = IDN( I )
         DO 5 K = I + 1, NN
            IF ( IDN( K ) .EQ. IDNOW ) THEN
               IDN( K ) = 0
            END IF
 5       CONTINUE
 4    CONTINUE

*  Finally remove any positions identified as zero.
      NOUT = 0
      DO 6 I = 1, NN
         IF ( IDN( I ) .NE. 0 ) THEN
            NOUT = NOUT + 1
            IDN( NOUT ) = IDN( I )
            XN( NOUT ) = XN( I )
            YN( NOUT ) = YN( I )
         END IF
 6    CONTINUE      
      END
* $Id$
