   proc CCDFITSDoImport { Top table args } {
#+
#  Name:
#     CCDFITSDoImport

#  Purpose:
#     Imports FITS items into NDFs.

#  Language:
#     Tcl/Tk procedure

#  Description:
#     This routine runs the IMPORT application on the list of NDFs
#     whose names are entered in the CCDallndfs global variable. The
#     import is controlled by file $table.

#  Arguments:
#     Top = window (read)
#        Name of the top-level window to parent the task output if
#        required.
#     table = string (read)
#        Name of the FITS import control table for the IMPORT application.
#     args = list (read)
#        If present this should be a command to run if the NDF import
#        runs successfully (such as enabling commands for the next section).

#  Global variables:
#     CCDallndfs = array (read)
#        The names of all the NDFs known to the system. These will
#        have
#      TASK = array (read and write)
#         Task control block. Use TASK(import,error) to check status
#         of task on exit.

#  Authors:
#     PDRAPER: Peter Draper (STARLINK - Durham University)
#     {enter_new_authors_here}

#  History:
#     29-MAR-1995 (PDRAPER):
#        Original version.
#     {enter_changes_here}

#  Bugs:
#     {note_any_bugs_here}

#-

#  Global variables:
      global CCDallndfs
      global CCDdir

#.

#  Create a list of all the NDF names to input into IMPORT.
      if { [info exists CCDallndfs] } {
	 if { ! [ catch { open XREDUCE.NDFS w } fileid ] } {

#  Put names into list.
            foreach ndf $CCDallndfs {
               puts $fileid [ CCDFileToNDFName $ndf ]
	    }
            close $fileid

#  Generate the command arguments.
            set command "in=^XREDUCE.NDFS table=$table reset accept "
            if { ! [info exists CCDglobalpars(LOGTO)] } {
               set CCDglobalpars(LOGTO) "BOTH"
	    }
	    append command "logto=$CCDglobalpars(LOGTO) "
            if { ! [info exists CCDglobalpars(LOGFILE)] } {
               set CCDglobalpars(LOGFILE) "CCDPACK.LOG"
	    }
	    append command "logfile=$CCDglobalpars(LOGFILE)"

#  Run IMPORT.
            set TASK(import,error) ""
            CCDRunTask import "$command" 2 $Top \
       " Importing FITS information into CCDPACK extensions, please wait "

#  Perform the successful completion command if given.
            if { "$args" != "" && $TASK(import,error) == "" } {
               eval $args
            }
	 } else {

#  Failed to open file.
            CCDIssueError "Failed to open temporary file"
	 }
      } else {

#  No NDFs to process.
         CCDIssueInfo "No NDFs are available for processing, \
have you imported any into the system?"
      }

#  End of procedure.
   }
# $Id$
