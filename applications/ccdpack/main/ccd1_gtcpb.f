      SUBROUTINE CCD1_GTCPB( IMETH, CMODE, NITER, NSIGMA, ALPHA, RMIN,
     :                       RMAX, STATUS )
*+
*  Name:
*     CCD1_GTCPA - GeT Combination Parameters - Version B

*  Purpose:
*     To return the image stacking combination method with any other
*     ancilliary data.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL CCD1_GTCPB( IMETH, CMODE, NITER, NSIGMA, ALPHA, RMIN, RMAX,
*                      STATUS )

*  Description:
*     The routine accesses the combination method as a string through
*     the ADAM parameter METHOD. This string is then
*     (case-insensitively) checked by PAR_CHOIC against the given list
*     of possible modes.  Using the value of the returned string the
*     method number is assigned to IMETH. If other data values are
*     required in addition to the method they are then prompted for.
*     These values should then be used by the combination routine.
*     This version does not allow the weighting option.  Method 1
*     (summation is also disabled). The variances are assumed not to
*     exist and are not required.

*  Arguments:
*     IMETH = INTEGER (Returned)
*        An integer representing the method chosen.
*        2 = MEAN
*        3 = MEDIAN
*        4 = TRIMMED MEAN
*        5 = MODE
*        6 = SIGMA CLIPPED MEAN
*        7 = THRESHOLD EXCLUSION MEAN
*        8 = MINMAX MEAN
*        9 = BROADENED MEDIAN
*     CMODE = CHARACTER * ( * ) (Returned)
*        The method chosen represented as a string.
*     NITER = INTEGER (Returned)
*        The maximum number of iterations ( IMETH = 5 and 6 ).
*     NSIGMA = REAL (Returned)
*        The number of sigmas to clip the data at (IMETH = 5 and 6 ).
*     ALPHA = REAL (Returned)
*        The fraction of data values to remove from data (IMETH = 4 ).
*     RMIN = REAL (Returned)
*        The minimum allowed data value ( IMETH = 7 )
*     RMAX = REAL (Returned)
*        The maximum allowed data value ( IMETH = 7 )
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     PDRAPER: Peter Draper (STARLINK)
*     {enter_new_authors_here}

*  History:
*     3-APR-1991 (PDRAPER):
*        Original version.
*     3-APR-1991 (PDRAPER):
*        Modified from GTCMBA for use with MAKEBIAS routine -
*        summation not allowed, weights not relevant.
*     19-JUL-1995 (PDRAPER):
*        Removed AIF_ calls
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Arguments Returned:
      INTEGER IMETH
      CHARACTER CMODE * ( * )
      INTEGER NITER
      REAL NSIGMA
      REAL ALPHA
      REAL RMIN
      REAL RMAX

*  Status:
      INTEGER STATUS             ! Global status

*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Find out the combination mode. Use median as the default
      CALL PAR_CHOIC( 'METHOD', ' ', 'MEDIAN ,MEAN ,TRIMMED ,'//
     :                'MODE , SIGMA ,THRESHOLD ,MINMAX ,BROADENED', 
     :                .FALSE., CMODE, STATUS )
      IF ( STATUS .NE. SAI__OK ) GO TO 99

*  Act on the return, set the IMETH value
      IF ( CMODE .EQ. 'MEAN' ) THEN
         IMETH = 2
      ELSE IF ( CMODE .EQ. 'MEDIAN' ) THEN
         IMETH = 3
      ELSE IF ( CMODE .EQ. 'TRIMMED' ) THEN
         IMETH = 4
      ELSE IF ( CMODE .EQ. 'MODE' ) THEN
         IMETH = 5
      ELSE IF ( CMODE .EQ. 'SIGMA' ) THEN
         IMETH = 6
      ELSE IF ( CMODE .EQ. 'THRESHOLD' ) THEN
         IMETH = 7
      ELSE IF ( CMODE .EQ. 'MINMAX' ) THEN
         IMETH = 8
      ELSE IF ( CMODE .EQ. 'BROADENED' ) THEN
         IMETH = 9
      ELSE

*  Bad return set status and exit.
         STATUS = SAI__ERROR
         CALL ERR_REP( 'BADMETH', 'Bad combination method', STATUS )
         IF ( STATUS .NE. SAI__OK ) GO TO 99
      END IF

      IF ( IMETH .EQ. 4 ) THEN

*  Get the trim fraction for trimmed mean.
         CALL PAR_GDR0R( 'ALPHA', 0.2, 0.001, 0.499, .FALSE., ALPHA, 
     :                   STATUS )
      ELSE IF ( IMETH .EQ. 5  .OR.  IMETH .EQ. 6 ) THEN

*  Sigma clipping get the number of sigmas to clip at.
         CALL PAR_GDR0R( 'SIGMAS', 4.0, 0.1, 100.0, .FALSE., NSIGMA, 
     :                   STATUS )
         IF ( IMETH .EQ. 5  ) THEN

*  Iterative sigma clipping get the maximum number of iterations.
            CALL PAR_GDR0I( 'NITER', 10, 1, 100, .FALSE., NITER, 
     :                      STATUS )
         ELSE

*  Just the single clip - set niter to one
            NITER = 1
         END IF

      ELSE IF ( IMETH .EQ. 7 ) THEN

*  Applying threshold cuts get the range of values
         CALL PAR_GET0R( 'MIN', RMIN, STATUS )
         CALL PAR_GET0R( 'MAX', RMAX, STATUS )
      END IF

99    END
* $Id$
