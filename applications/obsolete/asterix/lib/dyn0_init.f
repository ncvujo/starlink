      SUBROUTINE DYN0_INIT( )
*+
*  Name:
*     DYN0_INIT

*  Purpose:
*     Initialise DYN

*  Language:
*     Starlink Fortran

*  Invocation:
*     CALL DYN0_INIT()

*  Description:
*     Initialise DYN

*  Examples:
*     {routine_example_text}
*        {routine_example_description}

*  Pitfalls:
*     {pitfall_description}...

*  Notes:
*     {routine_notes}...

*  Prior Requirements:
*     {routine_prior_requirements}...

*  Side Effects:
*     {routine_side_effects}...

*  Algorithm:
*     {algorithm_description}...

*  Accuracy:
*     {routine_accuracy}

*  Timing:
*     {routine_timing}

*  External Routines Used:
*     {name_of_facility_or_package}:
*        {routine_used}...

*  Implementation Deficiencies:
*     {routine_deficiencies}...

*  References:
*     DYN Subroutine Guide : http://www.sr.bham.ac.uk/asterix-docs/Programmer/Guides/dyn.html

*  Keywords:
*     package:dyn, usage:private

*  Copyright:
*     Copyright (C) University of Birmingham, 1995

*  Authors:
*     DJA: David J. Allan (Jet-X, University of Birmingham)
*     {enter_new_authors_here}

*  History:
*     20 Mar 1995 (DJA):
*        Original version.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Variables:
      INCLUDE 'DYN_CMN'                                 ! DYN common block
*       DYS_PTR[] = INTEGER (given and returned)
*         Number of items in a memory area

*  Local Variables:
      INTEGER			I			! Loop over slots
*.

*  Zero slots
      DO I = 1, DYN__NMAX
        DYS_PTR(I) = 0
      END DO

*  Mark as initialised
      DYN_ISINIT = .TRUE.

      END
