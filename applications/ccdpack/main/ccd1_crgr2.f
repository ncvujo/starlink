      SUBROUTINE CCD1_CRGR2( WEIGHT, NW, NODES, GRAPH, NEDGES, STATUS )
*+
*  Name:
*     CCD1_CRGR

*  Purpose:
*     Creates a graph of edges for PAIRNDF intercomparisons.

*  Language:
*     Starlink FORTRAN 77  

*  Invocation:
*     CALL CCD1_CRGR2( WEIGHT, NW, NODES, GRAPH, NEDGES, STATUS )

*  Description:
*     This routine generates a graph expressed as a series of edges and
*     weights, from the information generated by list intercomparison
*     using the PAIRNDF routine.

*  Arguments:
*     WEIGHT( NW ) = INTEGER (Given)
*        The weights associated  with the edges of the graph. These are
*        the numbers of point-pairs successfully matched between the
*        position lists (nodes). A null weight is indicated by a value
*        of zero.
*     NW = INTEGER (Given)
*        The number of weights given
*     NODES( 2, NW ) = INTEGER (Given)
*        The node numbers of the original position lists.
*     GRAPH( 4, * ) = INTEGER (Returned)
*        The graph with the nodes numbers (positions (1,*) and (2,*) )
*        of the edge, (3,*) the associated weights, and (4,*) the index
*        into any associated data created during the intercomparison.
*     NEDGE = INTEGER (Returned)
*        The number of valid edges entered into the graph.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     PDRAPER: Peter Draper (STARLINK)
*     {enter_new_authors_here}

*  History:
*     10-DEC-1992 (PDRAPER):
*        Original version.
*     26-MAR-1993 (PDRAPER):
*        Changed for use in PAIRNDF (no intercomparison loop).
*     17-MAR-1995 (PDRAPER):
*        Removed unused NNODES argument.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Arguments Given:
      INTEGER NW
      INTEGER NODES( 2, NW )
      INTEGER WEIGHT( NW )

*  Arguments Returned:
      INTEGER GRAPH( 4, * )
      INTEGER NEDGES

*  Status:
      INTEGER STATUS             ! Global status

*  Local Variables:
      INTEGER I                  ! Loop variables

*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Create the graph of position intercomparisons. The nodes are the
*  index of the positions lists and the weighting the number of
*  positions successfully matched between the lists.
      NEDGES = 0
      DO 1 I = 1, NW
         IF ( WEIGHT( I ) .GT. 0 ) THEN
            NEDGES = NEDGES + 1
            GRAPH( 1, NEDGES ) = NODES( 1, I )
            GRAPH( 2, NEDGES ) = NODES( 2, I )
            GRAPH( 3, NEDGES ) = WEIGHT( I )
            GRAPH( 4, NEDGES ) = I
         END IF
 1    CONTINUE
      END
* $Id$
