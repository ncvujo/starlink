proc red4AppMask {taskname} {
#+
# Creates a dialog box for red4 action 
#-
    global env
    global Red4Widgets
    global Cred4NoticeBoard

# Check to see if task is busy
    set status [cgs4drCheckTask red4]
    if {$status!=0} {return}

# Create dialog box
    if {[winfo exists .red4Dialogue]} {destroy .red4Dialogue}
    set frame [dialogStart .red4Dialogue "Red4 Apply Bad Pixel Mask" 0 OK Cancel]
    cgs4drCursor pirate orange black
    .red4Dialogue config -cursor {arrow green black}

# Create and pack dialog box widgets
    set top [frame $frame.top]
    set bot [frame $frame.bot]
    pack $top $bot -in $frame -side top

    set Red4Widgets(AM_LAB01) [label $top.l1 -text "Mask"]
    set Red4Widgets(AM_ENT01) [entry $top.e1 -width 40]
    pack $Red4Widgets(AM_LAB01) $Red4Widgets(AM_ENT01) -in $top -side left
    if {[info exists Cred4NoticeBoard]==1} {
      $Red4Widgets(AM_ENT01) insert end [string trim [nbs get ${Cred4NoticeBoard}.miscellaneous.mask]]
    } else { 
      $Red4Widgets(AM_ENT01) insert end #
    }
 
    set Red4Widgets(AM_LAB02) [label $bot.l2 -text "Data"]
    set Red4Widgets(AM_ENT02) [entry $bot.e2 -width 40]
    pack $Red4Widgets(AM_LAB02) $Red4Widgets(AM_ENT02) -in $bot -side left -pady 2m
    $Red4Widgets(AM_ENT02) insert end $Red4Widgets(RO)

# Bind the defaults button
   bind $Red4Widgets(AM_LAB01) <Button-2> "red4Update red4AppMask ALL"
   bind $Red4Widgets(AM_LAB02) <Button-2> "red4Update red4AppMask ALL"
   bind $Red4Widgets(AM_ENT01) <Button-2> "red4Update red4AppMask AM_ENT01"
   bind $Red4Widgets(AM_ENT01) <Double-Button-2> "$Red4Widgets(AM_ENT01) delete 0 end"
   bind $Red4Widgets(AM_ENT02) <Button-2> "red4Update red4AppMask AM_ENT02"
   bind $Red4Widgets(AM_ENT02) <Double-Button-2> "$Red4Widgets(AM_ENT02) delete 0 end"

# Show the dialog box
    set bv [dialogShow .red4Dialogue .red4Dialogue]
    if {$bv==0} {
      cgs4drCursor watch red white
      set mask [string trim [$Red4Widgets(AM_ENT01) get]]
      set data [string trim [$Red4Widgets(AM_ENT02) get]]
      if {$data=="" || $data==$Red4Widgets(DRO) || $mask=="#"} {
        cgs4drClear $taskname
        set message "red4AppMask error : A dataset has not been specified properly!"
        cgs4drInform $taskname $message
      } else {

# Remove observation
        set Red4Widgets(RO) $data
        $taskname obey apply_mask "mask=$mask data=$data" -inform "cgs4drInform $taskname %V"
      }
    }

# Destroy the box
    cgs4drCursor arrow green black
    destroy .red4Dialogue
}
