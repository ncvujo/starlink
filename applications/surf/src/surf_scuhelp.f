      SUBROUTINE SURF_SCUHELP( STATUS )
*+
*  Name:
*     SCUHELP

*  Purpose:
*     Gives help about SCUBA software

*  Language:
*     Starlink Fortran 77

*  Type of Module:
*     ADAM A-task

*  Invocation:
*     CALL SURF_SCUHELP( STATUS )

*  Arguments:
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Description:
*     Displays help about SCUBA software. The help information has classified
*     and alphabetical lists of commands, general information about
*     SCUBA and related material; it describes individual commands in
*     detail.
*

*  Examples:
*        scuhelp
*           No parameter is given so the introduction and the top-level
*           help index is displayed.
*        scuhelp application/topic
*           This gives help about the specified application or topic.
*        scuhelp application/topic subtopic
*           This lists help about a subtopic of the specified
*           application or topic. The hierarchy of topics has a maximum
*           of four levels.
*        scuhelp Hints
*           This gives hints for new and intermediate users.
*        scuhelp summary
*           This shows a one-line summary of each application.
*        scuhelp classified classification
*           This lists a one-line summary of each application in the
*           given functionality classification.


*  Usage:
*     scuhelp [topic] [subtopic] [subsubtopic] [subsubsubtopic]

*  ADAM Parameters:
*     TOPIC = LITERAL (Read)
*        Topic for which help is to be given.
*     SUBTOPIC = LITERAL (Read)
*        Subtopic for which help is to be given.
*     SUBSUBTOPIC = LITERAL (Read)
*        Subsubtopic for which help is to be given.
*     SUBSUBSUBTOPIC = LITERAL (Read)
*        Subsubsubtopic for which help is to be given.

*  Algorithm:
*     -  Check for error on entry; return if not o.k.
*     -  Obtain topic and subtopics required.  Concatenate them
*        separated by spaces.
*     -  If an error has occurred set all topics to be null.
*     -  Get help on required topic.

*  Navigating the Help Library:
*     The help information is arranged hierarchically.  You can move
*     around the help information whenever SCUHELP prompts.  This
*     occurs when it has either presented a screen's worth of text or
*     has completed displaying the previously requested help.  The
*     information displayed by SCUHELP on a particular topic includes a
*     description of the topic and a list of subtopics that further
*     describe the topic.
*
*     At a prompt you may enter:

*        -  a topic and/or subtopic name(s) to display the help for that
*           topic or subtopic, so for example, "block parameters box"
*           gives help on BOX, which is a subtopic of Parameters, which
*           in turn is a subtopic of BLOCK;
*
*        -  a <CR> to see more text at a "Press RETURN to continue ..."
*           request;
*
*        -  a <CR> at topic and subtopic prompts to move up one level
*           in the hierarchy, and if you are at the top level it will
*           terminate the help session;
*
*        -  a CTRL/D (pressing the CTRL and D keys simultaneously) in
*           response to any prompt will terminate the help session;
*
*        -  a question mark "?" to redisplay the text for the current
*           topic, including the list of topic or subtopic names; or
* 
*        -  an ellipsis "..." to display all the text below the
*           current point in the hierarchy.  For example, "BLOCK..."
*           displays information on the BLOCK topic as well as
*           information on all the subtopics under BLOCK.
*
*     You can abbreviate any topic or subtopic using the following
*     rules.
*
*        -  Just give the first few characters, e.g. "PARA" for
*           Parameters.
* 
*        -  Some topics are composed of several words separated by
*           underscores.  Each word of the keyword may be abbreviated,
*           e.g. "Colour_Set" can be shortened to "C_S".
* 
*        -  The characters "%" and "*" act as wildcards, where the
*           percent sign matches any single character, and asterisk
*           matches any sequence of characters.  Thus to display
*           information on all available topics, type an asterisk in
*           reply to a prompt.
*
*        -  If a word contains, but does end with an asterisk wildcard,
*           it must not be truncated.
* 
*        -  The entered string must not contain leading or embedded
*           spaces.
*
*     Ambiguous abbreviations result in all matches being displayed.

*  Notes:
*     The environment variable SURF_HELP should be set to point to
*     the help file. This variable is usually set as part of the Starlink
*     login.

*  Implementation Status:
*     -  Uses the portable help system.

*  Authors:
*     MJC: Malcolm J. Currie (STARLINK)
*     TIMJ: Tim Jenness (JACH)
*     {enter_new_authors_here}


*  Copyright:
*     Copyright (C) 1995,1996,1997,1998,1999, 2004 
*     Particle Physics and Astronomy Research Council. All Rights Reserved.

*  History:
*     1986 November 14 (MJC):
*        Original.
*     1988 October 11 (MJC):
*        Fixed bug to enable subtopics to be accessed from the command
*        line.
*     1991 September 25 (MJC):
*        Corrected the description for the new layout in the new help
*        library, KAPPA.
*     1992 June 17 (MJC):
*        UNIX version using portable HELP.
*     1992 August 19 (MJC):
*        Rewrote the description, added usage and implementation status.
*     1995 November 9 (MJC):
*        Modified for UNIX and added the Topic on Navigation.
*     1996 November 1 (TIMJ):
*        Modified for SCUBA software
*     2004 July 27 (TIMJ):
*        Switch to SHL library
*     {enter_further_changes_here}

*  Bugs:
*     {note_new_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE

*  Global Constants:
      INCLUDE 'SAE_PAR'        ! SSE global definitions

*  Status:
      INTEGER STATUS

*  External References:

*  Local Constants:
      CHARACTER*4 LIBNAM      ! Name of the SURF help library env var
      PARAMETER ( LIBNAM = 'SURF' )

*.

*  Check the inherited status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Open the help library application layer
      CALL SHL_ADAM( LIBNAM, .TRUE., STATUS)

      END
