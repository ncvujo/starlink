*+  CRED4_WRITE_NB - Write the CRED4 noticeboard from parameters
      SUBROUTINE CRED4_WRITE_NB( STATUS )
*    Description :
*     This routine reads the information contained in the noticeboard
*     and transfers it to variables stored in the common block. Any
*     changes made to the noticeboard are therefore transferred to these
*     variables, which will cause the data reduction to implement them.
*    Invocation :
*     CALL CRED4_WRITE_NB( STATUS )
*    Authors :
*     S M Beard  (UK.AC.ROE.STAR::SMB)
*     P N Daly   (JACH.HAWAII.EDU::PND)
*    History :
*     19-Jun-1990: Original version, as part of the phase 2
*                  major changes.                             (SMB)
*     21-Jun-1990: Typing mistakes fixed.                     (SMB)
*     22-Jun-1990: Bug fix. SLICE_START and SLICE_END
*                  parameters are REAL.                       (SMB)
*     18-Jul-1990: Parameters added to allow a reduced
*                  observation to be displayed up to 4 times
*                  using any desired method.                  (SMB)
*      1-Oct-1990: AFIT_NROWS parameter added, to allow more
*                  than one row to be averaged for line
*                  fitting.                                   (SMB)
*      2-Oct-1990: SUBTRACT_SKY parameter removed and replaced
*                  with ADD_OBS.                              (SMB)
*     25-Oct-1990: GROUP display parameters added.            (SMB)
*      1-Nov-1990: DISP_FREQUENCY parameter added.            (SMB)
*      5-Nov-1990: VARIANCE_WT and SKY_WT parameters added.   (SMB)
*     13-Nov-1990: ISTART, IEND, JSTART, JEND display parameters
*                  removed, as the P4 task has now been made
*                  more consistent.                           (SMB)
*     19-Nov-1990: LAMBDA_METHOD parameter added, to control
*                  the wavelength calibration.                (SMB)
*      3-Jan-1991: Bad pixel mask and linearisation cofficients
*                  included in noticeboard and configuration. (SMB)
*      2-Feb-1991: ADD_IN_PAIRS and ERRORS parameters added,
*                  so that OBJECT and SKY observations can be
*                  added together in pairs. It has been discovered
*                  that the only way to sky-subtract reliably 
*                  is to add pairs in this way.               (UKIRT::SMB)
*     27-Jun-1991: Add point_source_options                   (UKIRT::PND)
*     31-Jul-1991: BOXSIZE parameter added.                   (SMB)
*     14-Apr-1992: Add BIAS_MODE, DARK_MODE, FLAT_MODE,
*                  CALIB_MODE, STANDARD_MODE, SPECIFIED_BIAS,
*                  SPECIFIED_DARK, SPECIFIED_FLAT,
*                  SPECIFIED_CALIB and SPECIFIED_STD
*                  parameters, for DRIMP/5.1 and DRIMP/5.2.   (SMB)
*     17-Jul-1992: Add SUBTRACT_BIAS and ARCHIVE_OBS          (PND)
*     11-Feb-1993: Conform to error strategy                  (PND)
*     24-May-1994: add bright or faint source algorithm       (PND)
*     29-Jul-1994: Major changes for Unix port                (PND)
*    endhistory
*    Type Definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
      INCLUDE 'PRM_PAR'
*    Status :
      INTEGER STATUS             ! Global status
*    Global variables :
      INCLUDE 'CRED4COM.INC'     ! CRED4 common block
*    External refernces :
      INTEGER CHR_LEN
*    Local variables :
      INTEGER CLEN
*-

*   Check for error on entry.
      IF ( STATUS .NE. SAI__OK ) RETURN

*   Write the parameters controlling the data reduction sequence.
      IF ( VERBOSE )  CALL MSG_OUT( ' ', 'Writing miscellaneous parameters to noticeboard', STATUS )
      CLEN = CHR_LEN( SUBTRACT_BIAS )
      CALL NBS_PUT_CVALUE( SUBTRACT_BIAS_ID, 0, SUBTRACT_BIAS(1:CLEN), STATUS )
      CLEN = CHR_LEN( SUBTRACT_DARK )
      CALL NBS_PUT_CVALUE( SUBTRACT_DARK_ID, 0, SUBTRACT_DARK(1:CLEN), STATUS )
      CLEN = CHR_LEN( ADD_INT )
      CALL NBS_PUT_CVALUE( ADD_INT_ID, 0, ADD_INT(1:CLEN), STATUS )
      CLEN = CHR_LEN( ARCHIVE_OBS )
      CALL NBS_PUT_CVALUE( ARCHIVE_OBS_ID, 0, ARCHIVE_OBS(1:CLEN), STATUS )
      CLEN = CHR_LEN( FILE_OBS )
      CALL NBS_PUT_CVALUE( FILE_OBS_ID, 0, FILE_OBS(1:CLEN), STATUS )
      CLEN = CHR_LEN( NORMALISE_FF )
      CALL NBS_PUT_CVALUE( NORMALISE_FF_ID, 0, NORMALISE_FF(1:CLEN), STATUS )
      CLEN = CHR_LEN( DIVIDE_BY_FF )
      CALL NBS_PUT_CVALUE( DIVIDE_BY_FF_ID, 0, DIVIDE_BY_FF(1:CLEN), STATUS )
      CLEN = CHR_LEN( ADD_OBS )
      CALL NBS_PUT_CVALUE( ADD_OBS_ID, 0, ADD_OBS(1:CLEN), STATUS )
      CLEN = CHR_LEN( TO_WAVELENGTH )
      CALL NBS_PUT_CVALUE( TO_WAVELENGTH_ID, 0, TO_WAVELENGTH(1:CLEN), STATUS )
      CLEN = CHR_LEN( DIVIDE_BY_STD )
      CALL NBS_PUT_CVALUE( DIVIDE_BY_STD_ID, 0, DIVIDE_BY_STD(1:CLEN), STATUS )
      CLEN = CHR_LEN( EXTRACT_SPC )
      CALL NBS_PUT_CVALUE( EXTRACT_SPC_ID, 0, EXTRACT_SPC(1:CLEN), STATUS )
      CLEN = CHR_LEN( AUTOFIT )
      CALL NBS_PUT_CVALUE( AUTOFIT_ID, 0, AUTOFIT(1:CLEN), STATUS )

*   Write the display parameters
      IF ( STATUS.EQ.SAI__OK .AND. VERBOSE ) CALL MSG_OUT( ' ', 'Writing display parameters to noticeboard', STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(0) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(0), 0, DISPLAY_INT(0)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(1) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(1), 0, DISPLAY_INT(1)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(2) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(2), 0, DISPLAY_INT(2)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(3) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(3), 0, DISPLAY_INT(3)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(4) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(4), 0, DISPLAY_INT(4)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(5) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(5), 0, DISPLAY_INT(5)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(6) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(6), 0, DISPLAY_INT(6)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(7) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(7), 0, DISPLAY_INT(7)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_INT(8) )
      CALL NBS_PUT_CVALUE( DISPLAY_INT_ID(8), 0, DISPLAY_INT(8)(1:CLEN), STATUS )

      CLEN = CHR_LEN( DISPLAY_OBS(0) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(0), 0, DISPLAY_OBS(0)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(1) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(1), 0, DISPLAY_OBS(1)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(2) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(2), 0, DISPLAY_OBS(2)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(3) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(3), 0, DISPLAY_OBS(3)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(4) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(4), 0, DISPLAY_OBS(4)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(5) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(5), 0, DISPLAY_OBS(5)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(6) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(6), 0, DISPLAY_OBS(6)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(7) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(7), 0, DISPLAY_OBS(7)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_OBS(8) )
      CALL NBS_PUT_CVALUE( DISPLAY_OBS_ID(8), 0, DISPLAY_OBS(8)(1:CLEN), STATUS )

      CLEN = CHR_LEN( DISPLAY_GRP(0) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(0), 0, DISPLAY_GRP(0)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(1) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(1), 0, DISPLAY_GRP(1)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(2) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(2), 0, DISPLAY_GRP(2)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(3) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(3), 0, DISPLAY_GRP(3)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(4) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(4), 0, DISPLAY_GRP(4)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(5) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(5), 0, DISPLAY_GRP(5)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(6) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(6), 0, DISPLAY_GRP(6)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(7) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(7), 0, DISPLAY_GRP(7)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_GRP(8) )
      CALL NBS_PUT_CVALUE( DISPLAY_GRP_ID(8), 0, DISPLAY_GRP(8)(1:CLEN), STATUS )

      CLEN = CHR_LEN( DISPLAY_SPC(0) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(0), 0, DISPLAY_SPC(0)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(1) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(1), 0, DISPLAY_SPC(1)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(2) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(2), 0, DISPLAY_SPC(2)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(3) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(3), 0, DISPLAY_SPC(3)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(4) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(4), 0, DISPLAY_SPC(4)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(5) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(5), 0, DISPLAY_SPC(5)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(6) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(6), 0, DISPLAY_SPC(6)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(7) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(7), 0, DISPLAY_SPC(7)(1:CLEN), STATUS )
      CLEN = CHR_LEN( DISPLAY_SPC(8) )
      CALL NBS_PUT_CVALUE( DISPLAY_SPC_ID(8), 0, DISPLAY_SPC(8)(1:CLEN), STATUS )

*   Write the miscellaneous parameters.
      IF ( STATUS.EQ.SAI__OK .AND. VERBOSE ) CALL MSG_OUT( ' ', 'Writing astronomical params to noticeboard', STATUS )
      CLEN = CHR_LEN( BIAS_MODE )
      CALL NBS_PUT_CVALUE( BIAS_MODE_ID, 0, BIAS_MODE(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( DARK_MODE )
      CALL NBS_PUT_CVALUE( DARK_MODE_ID, 0, DARK_MODE(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( FLAT_MODE )
      CALL NBS_PUT_CVALUE( FLAT_MODE_ID, 0, FLAT_MODE(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( CALIB_MODE )
      CALL NBS_PUT_CVALUE( CALIB_MODE_ID, 0, CALIB_MODE(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( STANDARD_MODE )
      CALL NBS_PUT_CVALUE( STANDARD_MODE_ID, 0, STANDARD_MODE(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( SPECIFIED_BIAS )
      CALL NBS_PUT_CVALUE( SPECIFIED_BIAS_ID, 0, SPECIFIED_BIAS(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( SPECIFIED_DARK )
      CALL NBS_PUT_CVALUE( SPECIFIED_DARK_ID, 0, SPECIFIED_DARK(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( SPECIFIED_FLAT )
      CALL NBS_PUT_CVALUE( SPECIFIED_FLAT_ID, 0, SPECIFIED_FLAT(1:CLEN), STATUS )
      CLEN = CHR_LEN( SPECIFIED_CALIB )
      CALL NBS_PUT_CVALUE( SPECIFIED_CALIB_ID, 0, SPECIFIED_CALIB(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( SPECIFIED_STD )
      CALL NBS_PUT_CVALUE( SPECIFIED_STD_ID, 0, SPECIFIED_STD(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( MASK )
      CALL NBS_PUT_CVALUE( MASK_ID, 0, MASK(1:CLEN), STATUS ) 
      CLEN = CHR_LEN( LINCOEFFS )
      CALL NBS_PUT_CVALUE( LINCOEFFS_ID, 0, LINCOEFFS(1:CLEN), STATUS ) 
      CALL NBS_PUT_VALUE( VARIANCE_WT_ID, 0, VAL__NBI, VARIANCE_WT, STATUS ) 
      CALL NBS_PUT_VALUE( ADD_IN_PAIRS_ID, 0, VAL__NBI, ADD_IN_PAIRS, STATUS ) 
      CLEN = CHR_LEN( ERRORS )
      CALL NBS_PUT_CVALUE( ERRORS_ID, 0, ERRORS(1:CLEN), STATUS ) 
      CALL NBS_PUT_VALUE( SKY_WT_ID, 0, VAL__NBR, SKY_WT, STATUS ) 
      CLEN = CHR_LEN( PF_POLYFIT )
      CALL NBS_PUT_CVALUE( PF_POLYFIT_ID, 0, PF_POLYFIT(1:CLEN), STATUS ) 
      CALL NBS_PUT_VALUE( PF_WEIGHT_ID, 0, VAL__NBI, PF_WEIGHT, STATUS ) 
      CALL NBS_PUT_VALUE( PF_DEGREE_ID, 0, VAL__NBI, PF_DEGREE, STATUS )
      CALL NBS_PUT_VALUE( PF_NREJECT_ID, 0, VAL__NBI, PF_NREJECT, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYS1_ID, 0, VAL__NBI, PF_SAYS1, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYE1_ID, 0, VAL__NBI, PF_SAYE1, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYS2_ID, 0, VAL__NBI, PF_SAYS2, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYE2_ID, 0, VAL__NBI, PF_SAYE2, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYS3_ID, 0, VAL__NBI, PF_SAYS3, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYE3_ID, 0, VAL__NBI, PF_SAYE3, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYS4_ID, 0, VAL__NBI, PF_SAYS4, STATUS )
      CALL NBS_PUT_VALUE( PF_SAYE4_ID, 0, VAL__NBI, PF_SAYE4, STATUS )

*   Write the parameters controlling the flat field normalisation.
      CLEN = CHR_LEN( NORM_METHOD )
      CALL NBS_PUT_CVALUE( NORM_METHOD_ID, 0, NORM_METHOD(1:CLEN), STATUS )
      CALL NBS_PUT_VALUE( ORDER_ID, 0, VAL__NBI, ORDER, STATUS )
      CALL NBS_PUT_VALUE( BOXSIZE_ID, 0, VAL__NBI, BOXSIZE, STATUS )

*   Write the parameters controlling the wavelength calibration.
      CLEN = CHR_LEN( LAMBDA_METHOD )
      CALL NBS_PUT_CVALUE( LAMBDA_METHOD_ID, 0, LAMBDA_METHOD(1:CLEN), STATUS )

*   Write the extract nod spc parameters
      CALL NBS_PUT_VALUE( SPC_ROW1S_ID, 0, VAL__NBR, SPC_ROW1S, STATUS )
      CALL NBS_PUT_VALUE( SPC_ROW1E_ID, 0, VAL__NBR, SPC_ROW1E, STATUS )
      CALL NBS_PUT_VALUE( SPC_ROW2S_ID, 0, VAL__NBR, SPC_ROW2S, STATUS )
      CALL NBS_PUT_VALUE( SPC_ROW2E_ID, 0, VAL__NBR, SPC_ROW2E, STATUS )
      CALL NBS_PUT_VALUE( SPC_ROW3S_ID, 0, VAL__NBR, SPC_ROW3S, STATUS )
      CALL NBS_PUT_VALUE( SPC_ROW3E_ID, 0, VAL__NBR, SPC_ROW3E, STATUS )
      CALL NBS_PUT_VALUE( SPC_INVERT_ID, 0, VAL__NBI, SPC_INVERT, STATUS )
      CLEN = CHR_LEN( SPC_ALGORITHM )
      CALL NBS_PUT_CVALUE( SPC_ALGORITHM_ID, 0, SPC_ALGORITHM(1:CLEN), STATUS )

*   Write the parameters controlling the line fitting.
      CALL NBS_PUT_VALUE( AFIT_NROWS_ID, 0, VAL__NBI, AFIT_NROWS, STATUS )
      CALL NBS_PUT_VALUE( AFIT_ROW1_ID, 0, VAL__NBI, AFIT_ROW1, STATUS )
      CALL NBS_PUT_VALUE( AFIT_ROW2_ID, 0, VAL__NBI, AFIT_ROW2, STATUS )
      CALL NBS_PUT_VALUE( AFIT_XSTART_ID, 0, VAL__NBR, AFIT_XSTART, STATUS )
      CALL NBS_PUT_VALUE( AFIT_XEND_ID, 0, VAL__NBR, AFIT_XEND, STATUS )

      IF ( STATUS.EQ.SAI__OK .AND. VERBOSE ) CALL MSG_OUT( ' ', 'Written params to noticeboard OK', STATUS )
      END
