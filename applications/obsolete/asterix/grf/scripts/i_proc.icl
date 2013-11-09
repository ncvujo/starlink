proc IBOXSTATS
  X1=0.0
  X2=0.0
  Y1=0.0
  Y2=0.0
  MODE="     "
  ICURRENT SUPPRESS X1=(X1) X2=(X2) Y1=(Y1) Y2=(Y2) MODE=(MODE)
  XWID=X2-X1
  YWID=Y2-Y1
  XCENT=(X2+X1)/2.0
  YCENT=(Y2+Y1)/2.0
  IBOX
  ISTATS
{
{ ICL if not working properly here
{
  IF ( MODE = 'CURS')
    IMODE KEY
  ENDIF
  IBOX XCENT=(XCENT) YCENT=(YCENT) XWID=(XWID) YWID=(YWID)
  IF MODE="CURS"
    IMODE CURS
  ENDIF
endproc
proc ICIRCSTATS
  X1=0.0
  X2=0.0
  Y1=0.0
  Y2=0.0
  MODE="     "
  ICURRENT SUPPRESS X1=(X1) X2=(X2) Y1=(Y1) Y2=(Y2) MODE=(MODE)
  XWID=X2-X1
  YWID=Y2-Y1
  XCENT=(X2+X1)/2.0
  YCENT=(Y2+Y1)/2.0
  ICIRCLE
  ISTATS
  IF ( MODE = 'CURS' )
    IMODE KEY
  ENDIF
  IBOX XCENT=(XCENT) YCENT=(YCENT) XWID=(XWID) YWID=(YWID)
  IF ( MODE = 'CURS' )
    IMODE CURS
  ENDIF
endproc
proc IDTODMS D,DMS
  R=D*3.14159265/180.0
  DMS=DEC2S((R),2,":")
endproc
proc IDMSTOD DMS,D
  R=DECL((DMS))
  D=R*180.0/3.14159265
endproc
proc IDTOHMS D,HMS
  R=D*3.14159265/180.0
  HMS=RA2S((R),2,":")
endproc
proc IHMSTOD HMS,D
  R=RA((HMS))
  D=R*180.0/3.14159265
endproc
HIDDEN PROC ISUBSET

  XLO = 0.0
  XHI = 0.0
  YLO = 0.0
  YHI = 0.0
  IMG = " "

;Zoom in
  IZOOM

;Get current display bounds
  ICURRENT NAME=(IMG) X1=(XLO) X2=(XHI) Y1=(YLO) Y2=(YHI)

;Subset it
  RX = CHAR(34)&(XLO)&":"&(XHI)&CHAR(34)
  RY = CHAR(34)&(YLO)&":"&(YHI)&CHAR(34)
  COM = "INP="&(IMG)&" AXES="&CHAR(34)&"1 2"&CHAR(34)&" SLICE AXIS1="&(RX)&" AXIS2="&(RY)
  BINSUBSET ((COM)&" ")

END PROC
