#!/bin/csh 

#+
#  Name:
#     gaia.csh

#  Purpose:
#     Start the GAIA application.

#  Language:
#     C-Shell

#  Invocation:
#     gaia.csh

#  Authors:
#     PWD: Peter Draper (STARLINK - Durham University)
#     {enter_new_authors_here}

#  History:
#     23-JAN-1997 (PWD):
#        Original version.
#     28-JUL-2000 (PWD):
#        Changed argument passing to quote filename. This may have 
#        special characters to protect.
#     {enter_changes_here}

#  Bugs:
#     {note_any_bugs_here}

#-

#  If available and not set then initialize the CONVERT package.
if ( $?CONVERT_DIR && ! $?NDF_FORMATS_IN ) then
   alias echo 'echo >/dev/null'
   if ( "`alias convert`" != "" ) then 
      convert
   else 
      if ( -e $CONVERT_DIR/convert.csh ) then 
         source $CONVERT_DIR/convert.csh
      endif
   endif
   unalias echo
endif

#  Now start up the application proper. 
if ( $?GAIA_DIR ) then 
   $GAIA_DIR/gaia.sh "$1" $argv[2-]
else if ( -e /star/bin/gaia/gaia.sh ) then 
   /star/bin/gaia/gaia.sh "$1" $argv[2-]
else 
   echo Sorry cannot find GAIA anywhere on your system
endif
