      SUBROUTINE SFIT( STATUS )
*+
*  Name:
*     SFIT

*  Purpose:
*     Spectral fitting program

*  Language:
*     Starlink Fortran

*  Type of Module:
*     ASTERIX task

*  Invocation:
*     CALL SFIT( STATUS )

*  Arguments:
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Description:
*     Adjusts parameters in a multicomponent model to achieve minimum
*     chi-squared or maximum likelihood fit to one or more datasets.
*     Only a single input dataset can be entered - if multiple datasets are
*     to be fitted a file containing references to them must be first set up
*     using SDATA.
*     The user can abort the program with ^C and will retain the last update
*     to the parameter values, which can then be used to generate plotted
*     output and taken as the starting point for further iteration.
*     Up to three user-defined models: FIT_USER1, _USER2 and _USER3, can be
*     linked to a private version of the program.

*  Usage:
*     sfit {parameter_usage}

*  Environment Parameters:
*     LIK = LOGICAL (read)
*        Likelihood fit (else chi-squared)
*     INP = CHAR (read)
*        Input data (either a single dataset or a file of references).
*     Z = REAL (read)
*        Redshift of spectrum
*     MODEL = CHAR (read)
*        Data object containing model specification
*     MAX = INTEGER (read)
*        Max number of iterations to be performed
*     MINS = REAL (read)
*        Minimum `reduced statistic' slope forcing continued iteration
*     NUP = INTEGER (read)
*        Number of iterations between updates of model parameter file
*     ERR = LOGICAL (read)
*        Evaluate approximate parameter errors and write to model file?
*     OUT = LOGICAL (read)
*        Spool (or send to file) summary of fit results?
*     FITOUT = CHAR (read)
*        File name for fit text output
*     APPEND = LOGICAL (read)
*        Append o/p to existing file?

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
*               Get genus, data, response and model spec.
*               Set up arrays required for fitting
*               Loop NITMAX/NUPDATE times
*		  Call FIT_MIN performing NUPDATE iterations
*		  Type diagnostic info
*		  Update model parameters in model_spec object
*		End loop
*		Optionally compute approximate errors for free parameters and
*                                                write to model file
*		Display and optionally print the results
*
*     The fit optimisation is done by FIT_MIN - a combined
*     gradient/quadratic-fitting minimisation routine based on the CURFIT
*     program of Bevington. Parameter bounds are incorporated by 'pegging'
*     parameters on bounds and excluding them from the fitting process until
*     the fitstat gradient takes them back into the allowed region. 'FROZEN'
*     parameters are never allowed to vary. Computing time is saved by using an
*     approximation to the fitstat second derivs within FIT_DERIVS, rather
*     than a rigorous evaluation.
*     Details of the model prescription (though not the parameter values and
*     bounds) and the observed and predicted data are not required by the
*     main fitting routine itself, only by the routines which evaluate the
*     fitstat value and its derivatives. These details (or in some cases
*     pointers to them) are stored in FORTRAN structures (for neatness given
*     the possibility of multiple datasets) and passed through FIT_MIN
*     intact.
*     For the spectral fitting case, a redshift may be incorporated by scaling
*     all the model space bounds by 1+z, to shift them into the source frame.

*  Accuracy:
*     {routine_accuracy}

*  Timing:
*     {routine_timing}

*  Implementation Status:
*     {routine_implementation_status}

*  External Routines Used:
*     {name_of_facility_or_package}:
*        {routine_used}...

*  Implementation Deficiencies:
*     {routine_deficiencies}...

*  References:
*     {task_references}...

*  Keywords:
*     sfit, usage:public

*  Copyright:
*     Copyright (C) University of Birmingham, 1995

*  Authors:
*     TJP: Trevor Ponman (University of Birmingham)
*     DJA: David J. Allan (Jet-X, University of Birmingham)
*     {enter_new_authors_here}

*  History:
*     31 Mar 1987 V0.6-1 (TJP):
*        Original GENFIT
*     15 May 1987 V0.6-2 (TJP):
*        Parameter error estimates & printout of results
*     11 Jun 1987 V0.6-3 (TJP):
*        Data file names returned from FIT_DATGET & output
*     26 Oct 1988 V0.6-4 (TJP):
*        Model listed in printed output
*      7 Jun 1989 V1.0-1 (TJP):
*        ASTERIX88 version
*      7 Dec 1990 V1.4-1 (TJP):
*        Bug with multiple spectra and model compts fixed
*      1 May 1991 V1.5-1 (TJP):
*        Common block allows 1st run to be flagged
*      5 Aug 1991 V1.5-2 (TJP):
*        Minor fix to allow printout when all params frozen
*      1 Apr 1992 V1.5-3 (RJV):
*        FIT_CHIFIT merged into top level
*     15 Jun 1992 V1.6-1 (TJP):
*        Supports likelihood fitting
*      9 Aug 1992 V1.6-2 (TJP):
*        Internal write replaces overwrite in printed o/p
*     23 Sep 1992 V1.6-3 (DJA):
*        Use D.P. for statistic
*      4 Dec 1992 V1.7-0 (DJA):
*        Fit error report and red-shift in subroutines
*     21 Dec 1992 V1.7-1 (DJA):
*        Terminal output via MSG
*     11 Jan 1993 V1.7-2 (DJA):
*        Output open/close moved to subroutines
*      8 Sep 1993 V1.7-3 (DJA)
*        Added SPEC_INIT call and removed reference to SPEC_CMN_RZ
*     23 May 1994 V1.7-4 (DJA):
*        Added parameter tying
*     21 Jul 1994 V1.7-5 (DJA):
*        File output moved to SFIT_OPFILES
*     25 Jul 1994 V1.7-6 (DJA):
*        File output now completely using AIO
*      7 Sep 1994 V1.8-0 (DJA):
*        Print out fit probability
*     24 Nov 1994 V1.8-1 (DJA):
*        Now use USI for user interface
*     21 Apr 1995 V1.8-2 (DJA):
*        Removed explicit use of HDS
*     30 Nov 1995 V2.0-0 (DJA):
*        ADI port
*     17 Apr 1996 V2.0-1 (DJA):
*        New minimisation control
*     13 May 1996 V2.0-2 (DJA):
*        Ensure tieing takes place for MAX=0
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'ADI_PAR'
      INCLUDE 'FIT_PAR'

*  Structure Definitions:
      INCLUDE 'FIT_STRUC'

*  Status:
      INTEGER			STATUS             	! Global status

*  External References:
      EXTERNAL			FIT_PREDDAT

*  Local Constants:
      INTEGER 			OPCHAN			! Output channel for diagnostic
	PARAMETER 		( OPCHAN = 6 )		! messages ( <1 for no messages)

      CHARACTER*30		VERSION
        PARAMETER		( VERSION = 'SFIT Version 2.2-1' )

*  Local Variables:
c     RECORD /DATASET/    	OBDAT(NDSMAX)		! Observed datasets
c     RECORD /INSTR_RESP/ 	INSTR(NDSMAX) 		! Instrument responses
c     RECORD /PREDICTION/ 	PREDDAT(NDSMAX) 	! Data predicted by model
c     RECORD /MODEL_SPEC/ 	MODEL			! Model specification
      INTEGER			IMOD

      CHARACTER*6		STYLE

      DOUBLE PRECISION 		STAT			! Fit statistic
      DOUBLE PRECISION 		FPROB			! Fit probability
      DOUBLE PRECISION 		LNDFAC

      REAL 			PARAM(NPAMAX)		! Model parameters
      REAL 			LB(NPAMAX)		! Parameter lower bounds
      REAL 			UB(NPAMAX)		! Parameter upper bounds
      REAL 			LE(NPAMAX)		! Lower error estimate
      REAL 			UE(NPAMAX)		! Upper error estimate
      REAL 			DPAR(NPAMAX)		! Differential parameter increments
      REAL 			PARSIG(NPAMAX)	        ! Parameter 1 sigma errors (approx)
      REAL 			Z			! Redshift [ Eobs/Esource=1/(1+z) ]

      INTEGER			IFID			! Input dataset id
      INTEGER			MCTRL			! Minimisation control
      INTEGER			MFID			! Model spec id
      INTEGER 			NDS			! No of datasets
      INTEGER 			NGOOD			! No. good data elements
      INTEGER 			SSCALE			! Factor for scaling fitstat
      INTEGER			NDOF			! No of degrees of freedom - should be
							!  no of data - no of unfrozen params
      INTEGER 			NITMAX			! Max # iterations
      INTEGER 			NPAR			! No of parameters
      INTEGER 			FITERR			! Fitting error encountered
      INTEGER 			OCI			! Output channel
      INTEGER 			FSTAT			! See FIT_PAR for info

      LOGICAL 			LIKSTAT			! Fitstat is Cash likelihood statistic?
      LOGICAL 			WORKSPACE		! Set up workspace for STAT gradients?
      LOGICAL 			FROZEN(NPAMAX)		! Frozen parameter flag
      LOGICAL 			PEGGED(NPAMAX)	     	! Parameter pegged on bound
      LOGICAL 			FINISHED		! Minimum found
      LOGICAL 			NOFREE			! No parameters free
      LOGICAL 			ER			! Parameter error calculation required?
      LOGICAL 			OP			! Printout required?
*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Version id
      CALL MSG_PRNT( VERSION )

*  Initialise ASTERIX
      CALL AST_INIT()
      CALL SPEC_INIT( STATUS )

*  Set up model genus
      IMOD = 1
      MODEL_SPEC_GENUS(IMOD) = 'SPEC'

*  Initialize variables
      NOFREE = .FALSE.

*  Chi-squared or likelihood fitting?
      CALL USI_GET0L( 'LIK', LIKSTAT, STATUS )
      IF ( LIKSTAT ) THEN
        FSTAT=FIT__LOGL
      ELSE
        FSTAT=FIT__CHISQ
      END IF

*  Get observed data (setting up data weights) and response
      CALL USI_ASSOC( 'INP', 'FileSet', 'READ', IFID, STATUS )
      IF ( STATUS .NE. SAI__OK ) THEN
        CALL ERR_ANNUL( STATUS )
        CALL USI_ASSOC( 'INP', 'BinDS', 'READ', IFID, STATUS )
      END IF
      WORKSPACE = .TRUE.
      CALL FIT_GETDAT( ADI__NULLID, IFID, 'SPEC', FSTAT, WORKSPACE,
     :                 (.NOT. LIKSTAT), NDS,
     :                 NGOOD, SSCALE, LNDFAC, STATUS )
      IF ( STATUS .NE. SAI__OK ) GOTO 99

*  Look for redshift
      CALL SFIT_GETZ( Z, STATUS )

*  Apply red-shift and check data structures
      CALL SFIT_PRECHK( NDS, Z, STATUS )

*  Get model specification
      CALL USI_ASSOC( 'MODEL', '*', 'UPDATE', MFID, STATUS )
      CALL FIT_MODGET( MFID, IMOD, NPAR, PARAM, LB, UB, LE, UE,
     :                 FROZEN, STATUS )
      IF ( STATUS .NE. SAI__OK ) GOTO 99

*  Number of degrees of freedom for chi-squared
      IF ( .NOT. LIKSTAT ) THEN

*    Finds NDOF from frozen array and constraints
        CALL FIT1_NDOF( NGOOD, IMOD, FROZEN, NDOF, STATUS )

*    NDOF to be used for scaling chisq statistic
	SSCALE = NDOF

      END IF

*  Get minimisation control
      CALL FCI_GETMC( MCTRL, STATUS )

*  Set up workspace for model stack
      CALL SFIT_MAPMODSTK( NDS, MODEL_SPEC_STACKPTR(IMOD), STATUS )
      IF ( STATUS .NE. SAI__OK ) GOTO 99

*  Zero iterations means just print the statistic
      CALL ADI_CGET0I( MCTRL, 'MaxIt', NITMAX, STATUS )
      IF ( NITMAX .EQ. 0 ) THEN

*    Evaluate the statistic
        CALL FIT_APPTIE( IMOD, .FALSE., PARAM, LB, UB, STATUS )
        CALL FIT_STAT( NDS, IMOD, PARAM, FSTAT,
     :                 FIT_PREDDAT, STAT, LNDFAC, STATUS )

*    Report value of statistic
        CALL SFIT_OPSTAT( FSTAT, STAT, SSCALE, NGOOD, OCI, STATUS )

*    Goodness of fit
        CALL FIT_MPROB( NDS, FSTAT, SSCALE, STAT,
     :                  FPROB, STATUS )
        CALL MSG_SETD( 'FPROB', FPROB )
        CALL MSG_PRNT( 'Prob = ^FPROB' )
        CALL MSG_BLNK()
        GOTO 99

      END IF

*  Perform fit iteration
      CALL FIT_MIN( NDS, IMOD, MCTRL, OPCHAN, .TRUE.,
     :              NPAR, LB, UB, FROZEN, SSCALE, LNDFAC, FSTAT,
     :              FIT_PREDDAT, PARAM, DPAR, PEGGED,
     :              STAT, FINISHED, FITERR, STATUS )
      IF ( STATUS .NE. SAI__OK ) GOTO 99

*  Fitting error?
      IF (FITERR.EQ.2.OR.FITERR.EQ.3)THEN

*    No free parameters?
	NOFREE=.TRUE.
        FINISHED=.TRUE.

*  Fatal fitting error?
      ELSE IF ( FITERR .NE. 0 )THEN
        CALL FIT_REPFERR( FITERR, STATUS )
	GOTO 99

      END IF

*  Should errors be calculated?
      IF ( NOFREE ) THEN
	ER = .FALSE.
      ELSE
	CALL ADI_CGET0C( MCTRL, 'Style', STYLE, STATUS )
        IF ( STYLE .EQ. 'GENALG' ) THEN
          ER = .FALSE.
        ELSE
	  CALL USI_GET0L('ERR',ER,STATUS)
        END IF
      END IF

*  Calculate approximate parameter errors and display
      IF ( ER ) THEN
	CALL MSG_BLNK()
	CALL MSG_PRNT( 'Calculating approximate parameter errors' )
	CALL FIT_PARERR(NDS,IMOD,NPAR,PARAM,LB,UB,DPAR,
     :                  FROZEN,PEGGED,SSCALE,FSTAT,FIT_PREDDAT,
     :                  PARSIG,LNDFAC,STATUS)
        CALL ARR_COP1R( NPAR, PARSIG, LE, STATUS )
        CALL ARR_COP1R( NPAR, PARSIG, UE, STATUS )

      ELSE

*    Reset array to ensure tidy print out
        CALL ARR_INIT1R( 0.0, NPAR, PARSIG, STATUS )

      END IF

*  Report parameter values
      CALL SFIT_OPTABLE( NPAR, PARAM, FROZEN, PEGGED, PARSIG,
     :                   IMOD, OCI, STATUS )

*  Report value of statistic
      CALL SFIT_OPSTAT( FSTAT, STAT, NDOF, NGOOD, OCI, STATUS )

*  Report red-shift
      IF ( Z .NE. 0.0 ) THEN
        CALL MSG_BLNK()
        CALL MSG_FMTR( 'Z', 'F7.5', Z )
        CALL MSG_PRNT( '--- Redshift = ^Z' )
        CALL MSG_BLNK()
      END IF

*  Update model_spec errors
      IF ( ER ) THEN
	CALL FIT_MODUP(MFID,MODEL_SPEC_NCOMP(IMOD),NPAR,PARAM,LE,UE,
     :                                                     1.0,STATUS)
	CALL MSG_PRNT( '** Error estimates entered in model spec. **' )
	CALL MSG_BLNK()
      END IF

*  Printed summary of fit results wanted?
      CALL SFIT_OPOPEN( OP, OCI, STATUS )

*  Write output?
      IF ( OP ) THEN

*    Write header
        CALL AIO_TITLE( OCI, VERSION, STATUS )

*      File list
        CALL SFIT_OPFILES( FSTAT, NDS, IMOD, OCI, STATUS )

*    Red-shift
	IF ( Z .NE. 0.0 ) THEN
          CALL MSG_FMTR( 'Z', 'F7.5', Z )
          CALL AIO_WRITE( OCI, '--- Redshifted to z = ^Z', STATUS )
          CALL AIO_BLNK( OCI, STATUS )
	END IF

*    Status of minimisation
        CALL AIO_BLNK( OCI, STATUS )
	IF ( FINISHED ) THEN
          CALL AIO_WRITE( OCI, 'Minimum found', STATUS )
	ELSE
          CALL AIO_WRITE( OCI, 'Minimum not found', STATUS )
	END IF

*    Report parameter values
        CALL SFIT_OPTABLE( NPAR, PARAM, FROZEN, PEGGED, PARSIG,
     :                                     IMOD, OCI, STATUS )

*    Value of statistic
        CALL SFIT_OPSTAT( FSTAT, STAT, NDOF, NGOOD, OCI, STATUS )

*    Close file
        CALL SFIT_OPCLOSE( OCI, STATUS )

      END IF

*  Tidy up & exit
 99   CALL USI_ANNUL( 'MODEL', STATUS )
      CALL USI_ANNUL( 'INP', STATUS )
      CALL AST_CLOSE()
      CALL AST_ERR( STATUS )

      END
