proc red4FileStd {taskname} {
#+
# Creates a dialog box for red4 action 
#-
    global env
    global Red4Widgets

# Check to see if task is busy
    set status [cgs4drCheckTask red4]
    if {$status!=0} {return}

# Create dialog box
    if {[winfo exists .red4Dialogue]} {destroy .red4Dialogue}
    set frame [dialogStart .red4Dialogue "Red4 File Standard" 0 OK Cancel]
    cgs4drCursor pirate orange black
    .red4Dialogue config -cursor {arrow green black}

# Create and pack dialog box widgets
    set top [frame $frame.top]
    set mid [frame $frame.mid]
    set bot [frame $frame.bot]
    pack $top $mid $bot -in $frame -side top

    set Red4Widgets(FS_LAB01) [label $top.tl1 -text "Filename"]
    set Red4Widgets(FS_ENT01) [entry $top.te1 -width 40]
    pack $Red4Widgets(FS_LAB01) $Red4Widgets(FS_ENT01) -in $top -side left
    $Red4Widgets(FS_ENT01) insert end $Red4Widgets(RG)

    set Red4Widgets(FS_LAB02) [label $mid.ml1 -text "Effective Temperature"]
    set Red4Widgets(FS_ENT02) [entry $mid.me1]
    pack $Red4Widgets(FS_LAB02) $Red4Widgets(FS_ENT02) -in $mid -side left
    $Red4Widgets(FS_ENT02) insert end 00

    set Red4Widgets(FS_LAB03) [label $mid.ml2 -text "Reference Wavelength"]
    set Red4Widgets(FS_ENT03) [entry $mid.me2]
    pack $Red4Widgets(FS_ENT03) $Red4Widgets(FS_LAB03) -in $mid -side right
    $Red4Widgets(FS_ENT03) insert end 2.2

    set Red4Widgets(FS_LAB04) [label $bot.bl1 -text "Extract Row Start"]
    set Red4Widgets(FS_ENT04) [entry $bot.be1]
    pack $Red4Widgets(FS_LAB04) $Red4Widgets(FS_ENT04) -in $bot -side left
    $Red4Widgets(FS_ENT04) insert end 1

    set Red4Widgets(FS_LAB05) [label $bot.bl2 -text "Extract Row End"]
    set Red4Widgets(FS_ENT05) [entry $bot.be2]
    pack $Red4Widgets(FS_ENT05) $Red4Widgets(FS_LAB05) -in $bot -side right
    $Red4Widgets(FS_ENT05) insert end 256

# Bind the defaults to Button-2
    bind $Red4Widgets(FS_LAB01) <Button-2> "red4Update red4FileStd ALL"
    bind $Red4Widgets(FS_LAB02) <Button-2> "red4Update red4FileStd ALL"
    bind $Red4Widgets(FS_LAB03) <Button-2> "red4Update red4FileStd ALL"
    bind $Red4Widgets(FS_LAB04) <Button-2> "red4Update red4FileStd ALL"
    bind $Red4Widgets(FS_LAB05) <Button-2> "red4Update red4FileStd ALL"
    bind $Red4Widgets(FS_ENT01) <Button-2> "red4Update red4FileStd FS_ENT01"
    bind $Red4Widgets(FS_ENT02) <Button-2> "red4Update red4FileStd FS_ENT02"
    bind $Red4Widgets(FS_ENT03) <Button-2> "red4Update red4FileStd FS_ENT03"
    bind $Red4Widgets(FS_ENT04) <Button-2> "red4Update red4FileStd FS_ENT04"
    bind $Red4Widgets(FS_ENT05) <Button-2> "red4Update red4FileStd FS_ENT05"
    bind $Red4Widgets(FS_ENT01) <Double-Button-2> "$Red4Widgets(FS_ENT01) delete 0 end"
    bind $Red4Widgets(FS_ENT02) <Double-Button-2> "$Red4Widgets(FS_ENT02) delete 0 end"
    bind $Red4Widgets(FS_ENT03) <Double-Button-2> "$Red4Widgets(FS_ENT03) delete 0 end"
    bind $Red4Widgets(FS_ENT04) <Double-Button-2> "$Red4Widgets(FS_ENT04) delete 0 end"
    bind $Red4Widgets(FS_ENT05) <Double-Button-2> "$Red4Widgets(FS_ENT05) delete 0 end"

# Show the dialog box
    set bv [dialogShow .red4Dialogue .red4Dialogue] 
    if {$bv==0} {
      cgs4drCursor watch red white
      set data [string trim [$Red4Widgets(FS_ENT01) get]]
      set teff [string trim [$Red4Widgets(FS_ENT02) get]]
      set rf [string trim [$Red4Widgets(FS_ENT03) get]]
      set ys [string trim [$Red4Widgets(FS_ENT04) get]]
      set ye [string trim [$Red4Widgets(FS_ENT05) get]]
      if {$data=="" || $data==$Red4Widgets(DRG)} {
        cgs4drClear $taskname
        set message "red4FileStd error : A dataset has not been specified properly!"
        cgs4drInform $taskname $message
      } else {
        set Red4Widgets(RG) $data
        $taskname obey file_standard \
          "grpfile=$data teff=$teff rflambda=$rf whole=F xstart=0 xend=256.0 ystart=$ys yend=$ye oper='OR' mend=T" \
          -inform "cgs4drInform $taskname %V"
      }
    }

# Remove the dialog box
    cgs4drCursor arrow green black
    destroy .red4Dialogue
}
