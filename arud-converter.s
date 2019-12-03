;-----------------------------------------------------------------------------
; Arud Converter v2.0
; by Morten Amundsen
;
; start: Monday, 16/10 1995, 09:46 PM
;   end: Sunday, 22/10 1995, 02:34 PM
;
; Arud Converter V2.01
; (Rename .info file also, if they exists)
;
; start: Friday, 27/10 1995, 04:09 PM
;   end: Friday, 27/10 1995, 04:24 PM
;
; Arud Converter V2.1
; (Add a gadget to reverse the order of renaming)
;
; start: Monday, 06/11 1995, 21:33
;   end: Monday, 06/11 1995, 22:02
;
; Arud Converter V2.2
; (Added the option of either renaming, copying or copying to a specified
;  directory plus "Places needed" now also shows max number of places
;  used in number sequence.)
;
; start: Thursday, 09/11 1995, 20:27
;   end: Friday, 10/11 1995, 14:08
;
; Arud Converter V2.201
; (Reduced height of window)
;
; start: Saturday, 10/2 1996, 20:57
;   end: Saturday, 10/2 1996, 21:02
;
; Arud Converter V2.3
; (Made gadgets higher and vertical space between gadgets smaller.
;  Version bumped 2.3 because this is the last(?) fix and I wanted
;  a "nice" version number)
;
; start: Monday, 15/4 1996, 19:10
;   end: Monday, 15/4 1996, 19:26

; Assembled in PhxAss 4.26
;-----------------------------------------------------------------------------

VERSION = 39            ; kick version
WB  = 1           ; wb startup (0=no)

;-----------------------------------------------------------------------------

NAME: MACRO
  dc.b  "arud "
  ENDM

VER:  MACRO
  dc.b  "2"
  ENDM

REV:  MACRO
  dc.b  "3"
  ENDM

DATE: MACRO
  dc.b  "(15.4.96)"
  ENDM

VERSTR: MACRO
  dc.b  "$VER: "
  NAME
  VER
  dc.b  "."
  REV
  dc.b  " by Morten Amundsen "
  DATE
  dc.b  10,13,0
  ENDM

;-----------------------------------------------------------------------------

  include "misc/lvooffsets.i"
  include "misc/macros.i"
  include "graphics/gfxbase.i"
  include "dos/dosextens.i"
  include "intuition/intuition.i"
  include "libraries/gadtools.i"
  include "libraries/reqtools.i"
  include "exec/memory.i"

  XDEF  _main
  XDEF  _DOSBase
  XDEF  _GfxBase
  XDEF  _IntuitionBase
  XDEF  _GadToolsBase
  XDEF  _ReqToolsBase

;-----------------------------------------------------------------------------

MAGIC:    equ 5   ; "magic" pixel value
GUISPACE: equ 2
SPACE:  equ GUISPACE

GAD_PBUTTON:  equ 0
GAD_PSTRING:  equ 1
GAD_BASETEXT: equ 2
GAD_REQPLACE: equ 3
GAD_NOFILES:  equ 4
GAD_RANGE:  equ 5
GAD_NEWBASE:  equ 6
GAD_PLACES: equ 7
GAD_STARTVAL: equ 8
GAD_LEADING:  equ 9
GAD_CONVERT:  equ 10
GAD_QUIT: equ 11
GAD_FORCE:  equ 12
GAD_DIRECTION:  equ 13
GAD_ACTION: equ 14
GAD_PLACEUSE: equ 15
SUMGAD:   equ 16    ; number of gadgets

PATHLEN:  equ 128   ; no. of chars in path
BASELEN:  equ 20    ; no. of chars in base
PLACESLEN:  equ 10    ; max no of numbers in integer.
          ; BASELEN+PLACESLEN should equal 30

FILELEN:  equ 30    ; length of filename
PCALCLEN: equ 40    ; no of chars to calc window width

 STRUCTURE  ArudFile,0
  STRUCT  af_Node,MLN_SIZE
  APTR  af_Name
  ULONG af_Count
  LABEL af_SIZEOF

;-----------------------------------------------------------------------------

_main:  movem.l d0-d7/a0-a6,-(a7)

  IFD WB
  bsr.w FIND_WBMSG
  ENDC

  lea ArudList,a0
  NEWLIST a0

  OPENLIB DOSName,VERSION,_DOSBase
  beq.s EXIT
  OPENLIB GfxName,VERSION,_GfxBase
  beq.s EXIT
  OPENLIB IntuitionName,VERSION,_IntuitionBase
  beq.s EXIT
  OPENLIB GadToolsName,VERSION,_GadToolsBase
  beq.s EXIT
  OPENLIB ReqToolsName,38,_ReqToolsBase
  beq.s EXIT

  moveq #RT_REQINFO,d0
  sub.l a0,a0
  CALL  rtAllocRequestA,_ReqToolsBase
  move.l  d0,_InfoReq
  beq.s EXIT

  moveq #RT_FILEREQ,d0
  sub.l a0,a0
  CALL  rtAllocRequestA,_ReqToolsBase
  move.l  d0,_FileReq
  beq.s EXIT

; get initial values (fontheight, fontwidth and titleheight) from WB screen.

  lea WorkbenchName,a0
  CALL  LockPubScreen,_IntuitionBase
  move.l  d0,_WBScr
  beq.s EXIT

  move.w  #1,WBLock

  move.l  d0,a0
  move.l  sc_Font(a0),a0
  bsr.w GET_FONT_DATA
  beq.s EXIT

  moveq #0,d0
  move.l  _WBScr,a0
  move.b  sc_BarHeight(a0),d0
  move.w  d0,TitleHeight

  sub.l a1,a1
  CALL  GetVisualInfoA,_GadToolsBase
  move.l  d0,d7

  lea WorkbenchName,a0
  CALL  UnlockPubScreen,_IntuitionBase

  clr.w WBLock

  move.l  d7,_VisualInfo
  beq.s EXIT

; set VisualInfo in bevelbox taglist

  SETTAG  #BevelTags,GT_VisualInfo,d7

; calc window height & width

  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #11,d1      ; 11 lines of gadgets
  add.w d1,d0
  add.w #MAGIC*16,d0    ; "magic" space between gads
  move.w  d0,WindowHeight

  move.l  _WBScr,a0
  move.w  sc_Height(a0),d1  ; if window is higher than screen...
  cmp.w d0,d1
  bge.s OK_HEIGHT

  move.l  _Font,a1
  CALL  CloseFont,_GfxBase
  move.l  #0,_Font

  lea TopazAttr,a0    ; ...adjust to topaz.font 8
  bsr.w GET_FONT_DATA
  beq.w EXIT

  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #11,d1      ; 11 lines of gadgets
  add.w d1,d0
  add.w #SPACE*17,d0
  move.w  d0,WindowHeight

OK_HEIGHT:
  lea PCalcIT,a0
  move.l  _TextAttr,it_ITextFont(a0)
  CALL  IntuiTextLength,_IntuitionBase
  add.w #MAGIC*2,d0
  move.w  d0,WindowWidth

;---------------------------------------------------------------------
; calc all gadget positions

;-----------------
; PATH button
;-----------------

  lea ForceIT,a0
  move.l  _TextAttr,it_ITextFont(a0)
  CALL  IntuiTextLength,_IntuitionBase

  lea PButtonS,a0
  add.w #MAGIC*2,d0
  move.w  d0,gng_Width(a0)
  move.w  #MAGIC*2,gng_LeftEdge(a0)
  move.w  TitleHeight,d0
  add.w #SPACE,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  GadgetHeight,gng_Height(a0)
  move.w  FontWidth,d0

;----------------
; PATH string
;----------------

  lea PStringS,a0     ; 'Path' string
  move.w  TitleHeight,d0
  add.w #SPACE,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  GadgetHeight,gng_Height(a0)

  lea PButtonS,a1
  move.w  gng_Width(a1),d0
  move.w  d0,d1
  add.w #MAGIC*3,d1
  move.w  d1,gng_LeftEdge(a0)

  move.w  WindowWidth,d0
  sub.w d1,d0
  sub.w #MAGIC*2,d0
  move.w  d0,gng_Width(a0)

;---------------------------------------------------------------------
; BASENAME text
;------------------

  lea BaseTextS,a0
  move.w  TitleHeight,d0
  add.w GadgetHeight,d0
  add.w #SPACE*3,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  WindowWidth,d0
  lsr.w #1,d0
  move.w  d0,gng_LeftEdge(a0)
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; REQPLACE number
;------------------

  lea ReqPlaceS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  lsl.w #1,d1
  add.w d1,d0
  add.w #SPACE*4,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  WindowWidth,d0
  lsr.w #1,d0
  move.w  d0,gng_LeftEdge(a0)
  move.w  d0,d7
  sub.w #MAGIC*4,d0
  lsr.w #1,d0
  sub.w #MAGIC,d0
  move.w  d0,gng_Width(a0)
  move.w  d0,d6
  add.w d0,d7
  move.w  GadgetHeight,gng_Height(a0)

;--------------------------------------------------------------------
; PLACESUSED number
;-----------------------

  lea PlaceUseS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  lsl.w #1,d1
  add.w d1,d0
  add.w #SPACE*4,d0
  move.w  d0,gng_TopEdge(a0)
  add.w #MAGIC*2,d7
  move.w  d7,gng_LeftEdge(a0)
  move.w  d6,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; NOFILES number
;------------------

  lea NoFilesS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #3,d1
  add.w d1,d0
  add.w #SPACE*5,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  WindowWidth,d0
  lsr.w #1,d0
  move.w  d0,gng_LeftEdge(a0)
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; RANGE text
;------------------

  lea RangeS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  lsl.w #2,d1
  add.w d1,d0
  add.w #SPACE*6,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  WindowWidth,d0
  lsr.w #1,d0
  move.w  d0,gng_LeftEdge(a0)
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; NEWBASE string
;------------------

  lea NewBaseS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #5,d1
  add.w d1,d0
  add.w #SPACE*9,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  d0,d7
  move.w  WindowWidth,d0
  lsr.w #1,d0
  move.w  d0,gng_LeftEdge(a0)
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;------------------
; FORCE cycle
;------------------

  lea ForceIT,a0
  move.l  _TextAttr,it_ITextFont(a0)
  CALL  IntuiTextLength,_IntuitionBase

  lea ForceS,a0
  add.w #MAGIC*2,d0
  add.w #32,d0
  move.w  d0,gng_Width(a0)
  move.w  d7,gng_TopEdge(a0)
  move.w  #MAGIC*3,gng_LeftEdge(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; PLACES integer
;------------------

  lea PlacesS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #6,d1
  add.w d1,d0
  add.w #SPACE*10,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  WindowWidth,d0
  lsr.w #1,d0
  move.w  d0,gng_LeftEdge(a0)
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; STARTVAL integer
;------------------

  lea StartValS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #7,d1
  add.w d1,d0
  add.w #SPACE*11,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  WindowWidth,d0
  lsr.w #1,d0
  move.w  d0,gng_LeftEdge(a0)
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; LEADING cycle
;------------------

  lea LeadingS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #8,d1
  add.w d1,d0
  add.w #SPACE*13,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  #MAGIC*2,gng_LeftEdge(a0)
  move.w  WindowWidth,d0
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;--------------------------------------------------------------------
; DIRECTION cycle
;-----------------------

  lea DirectionS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #9,d1
  add.w d1,d0
  add.w #SPACE*14,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  #MAGIC*2,gng_LeftEdge(a0)
  move.w  WindowWidth,d0
  sub.w #MAGIC*4,d0
  move.w  d0,gng_Width(a0)
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; CONVERT button
;------------------

  lea ConvertS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #10,d1
  add.w d1,d0
  add.w #SPACE*15,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  #MAGIC*2,gng_LeftEdge(a0)
  move.w  WindowWidth,d0
  lsr.w #2,d0
  move.w  d0,gng_Width(a0)
  move.w  d0,d7
  move.w  GadgetHeight,gng_Height(a0)

;---------------------------------------------------------------------
; QUIT button
;------------------

  lea QuitS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #10,d1
  add.w d1,d0
  add.w #SPACE*15,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  WindowWidth,d0
  move.w  d0,d1
  lsr.w #2,d0
  move.w  d0,gng_Width(a0)
  sub.w d0,d1
  sub.w #MAGIC*2,d1
  move.w  d1,gng_LeftEdge(a0)
  move.w  GadgetHeight,gng_Height(a0)

;--------------------------------------------------------------------
; ACTION cycle
;-----------------------

  lea ActionS,a0
  move.w  TitleHeight,d0
  move.w  GadgetHeight,d1
  mulu  #10,d1
  add.w d1,d0
  add.w #SPACE*15,d0
  move.w  d0,gng_TopEdge(a0)
  move.w  GadgetHeight,gng_Height(a0)
  move.w  d7,d6
  add.w #MAGIC*3,d6
  move.w  d6,gng_LeftEdge(a0)
  add.w d7,d7
  add.w #MAGIC*6,d7
  move.w  WindowWidth,d6
  sub.w d7,d6
  move.w  d6,gng_Width(a0)

;----------------------------------------------------------------------
; setup gadgets

  lea _Gad,a0
  CALL  CreateContext,_GadToolsBase
  tst.l d0
  beq.s EXIT

  lea GadgetTags,a3
  lea GadgetTypes,a4
  lea GadgetStructs,a5

  lea GadgetList,a6
GADGET_LOOP:
  move.l  d0,a0
  beq.s EXIT

  move.l  (a5)+,a1
  cmp.l #NULL,a1
  beq.s GADGETS_DONE

  move.l  _TextAttr,gng_TextAttr(a1)
  move.l  _VisualInfo,gng_VisualInfo(a1)

  move.l  (a4)+,d0
  move.l  (a3)+,a2

  move.l  a6,-(a7)
  CALL  CreateGadgetA,_GadToolsBase
  move.l  (a7)+,a6

  move.l  d0,(a6)+
  bra.s GADGET_LOOP

; open window

GADGETS_DONE:
  SETTAG  #NewWindowTags,WA_Gadgets,_Gad

  moveq #0,d7
  move.w  WindowHeight,d7
  SETTAG  #NewWindowTags,WA_Height,d7

  move.w  WindowWidth,d7
  SETTAG  #NewWindowTags,WA_Width,d7

  sub.l a0,a0
  lea NewWindowTags,a1
  CALL  OpenWindowTagList,_IntuitionBase
  move.l  d0,_Window
  beq.s EXIT

  move.l  d0,a1
  move.l  wd_RPort(a1),a1
  move.l  _Font,a0
  CALL  SetFont,_GfxBase  

  bsr.w REFRESH_WINDOW

  SETTAG  #FileReqTags,RT_Window,_Window
  SETTAG  #EZReqTags,RT_Window,_Window

;--------------------------------------------------------------------------

  move.l  _Window,a0
  move.l  wd_UserPort(a0),a0
  move.l  a0,_UserPort

MAINLOOP:
  tst.w ExitFlag
  bne.s EXIT

  move.l  _UserPort,a0
  EXEC  WaitPort

MSGLOOP:
  move.l  _UserPort,a0
  CALL  GT_GetIMsg,_GadToolsBase
  move.l  d0,_Message
  beq.s MAINLOOP

  move.l  d0,a0
  move.l  im_Class(a0),d0

  cmp.l #IDCMP_CLOSEWINDOW,d0
  bne.s NO_CLOSEWINDOW

  move.w  #1,ExitFlag
  bra.s REPLYMSG

NO_CLOSEWINDOW:
  cmp.l #IDCMP_GADGETUP,d0
  bne.s REPLYMSG

  moveq #0,d0
  move.l  im_IAddress(a0),a1
  move.w  gg_GadgetID(a1),d0
  lsl.w #2,d0
  lea SubJumpTable,a2
  move.l  (a2,d0.w),a2
  jsr (a2)

REPLYMSG:
  move.l  _Message,a1
  CALL  GT_ReplyIMsg,_GadToolsBase
  bra.s MSGLOOP

EXIT: bsr.s CLEAN
  movem.l (a7)+,d0-d7/a0-a6
  moveq #0,d0
  rts

;-----------------------------------------------------------------------------

CLEAN:
  bsr.w UNLOCK_WB

  bsr.s CLOSE_WINDOW

  bsr.s SET_PROGDIR
  bsr.s FREE_FIB
  bsr.s FREE_LIST
  bsr.w FREE_FILEBUFFER

  bsr.w CLOSEREQ
  bsr.w CLOSEGAD
  bsr.w CLOSEINT
  bsr.w CLOSEGFX
  bsr.w CLOSEDOS

  IFD WB
  bsr.w REPLY_WBMSG
  ENDC
  rts

;------------------------------------------------------------------------

UNLOCK_WB:
  tst.w WBLock
  beq.s .NOT

  lea WorkbenchName,a0
  CALL  UnlockPubScreen,_IntuitionBase
.NOT: rts

CLOSE_WINDOW:
  tst.l _Window
  beq.s .NOT1

  move.l  _Window,a0
  CALL  CloseWindow,_IntuitionBase

.NOT1:  tst.l _Gad
  beq.s .NOT2

  move.l  _Gad,a0
  CALL  FreeGadgets,_GadToolsBase

.NOT2:  tst.l _Font
  beq.s .NOT3

  move.l  _Font,a1
  CALL  CloseFont,_GfxBase

.NOT3:  tst.l _VisualInfo
  beq.s .NOT4

  move.l  _VisualInfo,a0
  CALL  FreeVisualInfo,_GadToolsBase
.NOT4:  rts

;------------------------------------------------------------------------

SET_PROGDIR:
  tst.w CurrentDone
  beq.s .NOT1

  move.l  _OldCurrent,d1
  CALL  CurrentDir,_DOSBase

.NOT1:  tst.l _CDLock
  beq.s .NOT2

  move.l  _CDLock,d1
  CALL  UnLock,_DOSBase
.NOT2:  rts

;------------------------------------------------------------------------

FREE_FIB:
  tst.l _FIB
  beq.s .NOT

  moveq #DOS_FIB,d1
  move.l  _FIB,d2
  CALL  FreeDosObject,_DOSBase
  move.l  #0,_FIB
.NOT: rts

;------------------------------------------------------------------------

FREE_LIST:
  lea ArudList,a0
  TSTLIST a0
  beq.s .EMPTY

.LOOP:  lea ArudList,a0
  TSTNODE a0,a1
  beq.s .DONE

  move.l  a1,a2
  REMOVE

  move.l  af_Name(a2),d3
  tst.l d3
  beq.s .NODE

  move.l  d3,a1
  EXEC  FreeVec     ; free name

.NODE:  move.l  a2,a1
  EXEC  FreeVec     ; free node
  bra.s .LOOP

.DONE:  lea ArudList,a0
  NEWLIST a0
.EMPTY: rts

;--------------------------------------------------------------------------

CLOSEREQ:
  tst.l _FileReq
  beq.s .NOT1

  move.l  _FileReq,a1
  CALL  rtFreeRequest,_ReqToolsBase

.NOT1:  tst.l _InfoReq
  beq.s .NOT2

  move.l  _InfoReq,a1
  CALL  rtFreeRequest,_ReqToolsBase

.NOT2:  tst.l _ReqToolsBase
  beq.s .NOT3

  CLOSELIB _ReqToolsBase
.NOT3:  rts

CLOSEGAD:
  tst.l _GadToolsBase
  beq.s .NOT

  CLOSELIB _GadToolsBase
.NOT: rts

CLOSEINT:
  tst.l _IntuitionBase
  beq.s .NOT

  CLOSELIB _IntuitionBase
.NOT: rts

CLOSEDOS:
  tst.l _DOSBase
  beq.s .NOT

  CLOSELIB _DOSBase
.NOT: rts

CLOSEGFX:
  tst.l _GfxBase
  beq.s .NOT

  CLOSELIB _GfxBase
.NOT: rts

;----------------------------------------------------------------------------

  IFD WB
FIND_WBMSG:
  sub.l a1,a1
  EXEC  FindTask
  move.l  d0,a4

  moveq #0,d0

  tst.l pr_CLI(a4)
  bne.s .CLI

  lea pr_MsgPort(a4),a0
  EXEC  WaitPort
  lea pr_MsgPort(a4),a0
  EXEC  GetMsg
.CLI: move.l  d0,_WBMsg
  rts

REPLY_WBMSG:
  tst.l _WBMsg
  beq.s .NOT

  EXEC  Forbid
  move.l  _WBMsg,a1
  EXEC  ReplyMsg
  EXEC  Permit
.NOT: rts
  ENDC

;-----------------------------------------------------------------------------

GET_FONT_DATA:
  move.l  a0,_TextAttr
  CALL  OpenFont,_GfxBase
  move.l  d0,_Font
  beq.s .EXIT

  move.l  d0,a0
  move.w  tf_YSize(a0),FontHeight
  move.w  tf_XSize(a0),FontWidth

  move.w  FontHeight,d0
  add.w #GUISPACE*4,d0
  move.w  d0,GadgetHeight

  moveq #1,d0
.EXIT:  rts

;-------------------------------------------------------------------------

REFRESH_WINDOW:
  move.l  _Window,a0
  sub.l a1,a1
  CALL  GT_RefreshWindow,_GadToolsBase

  bsr.w RENDER_BEVELBOXES
  rts

RENDER_BEVELBOXES:
  move.l  _Window,a0
  move.l  wd_RPort(a0),a0
  lea BevelTags,a1
  moveq #MAGIC,d0
  move.w  TitleHeight,d1
  add.w GadgetHeight,d1
  add.w #SPACE*2,d1
  move.w  WindowWidth,d2
  sub.w #MAGIC*2,d2
  move.w  GadgetHeight,d3
  lsl.w #2,d3
  add.w #SPACE*5,d3
  add.w #SPACE/2,d3
  move.w  d3,d4
  add.w d1,d4
  CALL  DrawBevelBoxA,_GadToolsBase

  move.l  _Window,a0
  move.l  wd_RPort(a0),a0
  lea BevelTags,a1
  moveq #MAGIC,d0
  move.w  d4,d1
  addq.w  #1,d1
  move.w  WindowWidth,d2
  sub.w #MAGIC*2,d2
  move.w  GadgetHeight,d3
  mulu  #3,d3
  add.w #SPACE*5,d3
  sub.w #SPACE/2,d3
  CALL  DrawBevelBoxA,_GadToolsBase
  rts 

;-----------------------------------------------------------------------------

NO_OP:  rts

;-----------------------------------------------------------------------------

PATH_BUTTON:
  bsr.w ALL_GADS_OFF

  move.l  _FileReq,a1
  sub.l a2,a2
  lea ArudTitle,a3
  lea FileReqTags,a0
  CALL  rtFileRequestA,_ReqToolsBase
  tst.l d0
  beq.s NO_PATHB

  move.l  _FileReq,a0
  move.l  rtfi_Dir(a0),a0   ; copy result to buffer
  lea PathString,a1
  move.w  #PATHLEN-1,d7
.LOOP:  move.b  (a0)+,(a1)+
  beq.s .DONE
  dbf d7,.LOOP

.DONE:  moveq #GAD_PSTRING,d0   ; put pathname in string-gadget
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea PStringTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  move.l  #PathString,d7
  bsr.s CURRENT_DIRECTORY

  bsr.w BUILD_STRUCTURE
  beq.s NO_PATHB

  moveq #GAD_BASETEXT,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea BaseTextTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  move.l  NoFiles,d7
  SETTAG  #NoFilesTags,GTNM_Number,d7

  moveq #GAD_NOFILES,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea NoFilesTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #ReqPlaceTags,GTNM_Number,ReqPlaceLow

  moveq #GAD_REQPLACE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea ReqPlaceTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #PlaceUseTags,GTNM_Number,PlacesUsed

  moveq #GAD_PLACEUSE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea PlaceUseTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  moveq #GAD_RANGE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea RangeTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase
NO_PATHB:
  bsr.w ALL_GADS_ON
  rts

;------------------------------------------------------------------------

PATH_STRING:
  move.l  gg_SpecialInfo(a1),a2
  move.l  si_Buffer(a2),d7
  bsr.s CURRENT_DIRECTORY
  beq.s PS_FAIL

  move.l  d7,a0
  lea PathString,a1
  move.w  #PATHLEN-1,d7
.LOOP:  move.b  (a0)+,(a1)+
  beq.s .DONE
  dbf d7,.LOOP

.DONE:  move.l  _FileReq,a1
  lea ChangeDirTags,a0
  CALL  rtChangeReqAttrA,_ReqToolsBase

MAIN_BSTRUCT:
  bsr.w ALL_GADS_OFF

  bsr.w BUILD_STRUCTURE
  beq.s PS_FAIL

  moveq #GAD_BASETEXT,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea BaseTextTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  move.l  NoFiles,d7
  SETTAG  #NoFilesTags,GTNM_Number,d7

  moveq #GAD_NOFILES,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea NoFilesTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #ReqPlaceTags,GTNM_Number,ReqPlaceLow

  moveq #GAD_REQPLACE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea ReqPlaceTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #PlaceUseTags,GTNM_Number,PlacesUsed

  moveq #GAD_PLACEUSE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea PlaceUseTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  moveq #GAD_RANGE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea RangeTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase
  bsr.w ALL_GADS_ON
  rts

PS_FAIL:
  moveq #GAD_PSTRING,d0   ; put pathname in string-gadget
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  a0,a4
  move.l  _Window,a1
  sub.l a2,a2
  lea PStringTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #NoFilesTags,GTNM_Number,#0

  moveq #GAD_NOFILES,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea NoFilesTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  bsr.w ALL_GADS_ON

  move.l  a4,a0
  move.l  _Window,a1
  sub.l a2,a2
  CALL  ActivateGadget,_IntuitionBase
  rts

;---------------------------------------------------------------------------

NEWBASE_STRING:
  move.l  gg_SpecialInfo(a1),a2
  move.l  si_Buffer(a2),a2
  move.l  a2,a3
  
.ILL: move.b  (a3)+,d0
  beq.s .DONE

  lea IllegalChars,a4   ; check for illegal chars
.LOOP:  move.b  (a4)+,d1
  beq.s .ILL

  cmp.b d0,d1
  bne.s .LOOP

  move.l  _WBScr,a0
  CALL  DisplayBeep,_IntuitionBase

  moveq #GAD_NEWBASE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  a0,a4
  move.l  _Window,a1
  sub.l a2,a2
  lea ChangeStrTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  move.l  a4,a0
  move.l  _Window,a1
  sub.l a2,a2
  CALL  ActivateGadget,_IntuitionBase
  rts

.DONE:  lea BaseString,a3
.LOOP2: move.b  (a2)+,(a3)+
  bne.s .LOOP2

  tst.l PreDefBase
  beq.s .NOT

  lea BaseString,a0
  lea FileBase,a1
  move.w  #-1,d7
.LOOP3: addq.w  #1,d7
  move.b  (a0)+,(a1)+
  bne.s .LOOP3

  move.w  d7,PreBaseLen
.NOT: rts

;-------------------------------------------------------------------------

PLACES_INTEGER:
  move.l  gg_SpecialInfo(a1),a2
  move.l  si_LongInt(a2),d7
  ble.s .NULL

  cmp.l #PLACESLEN,d7
  ble.s OK_INTP

.NULL:  move.l  _WBScr,a0
  CALL  DisplayBeep,_IntuitionBase

  move.l  PlacesValue,d7
  SETTAG  #ChangeIntTags,GTIN_Number,d7

  moveq #GAD_PLACES,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  a0,a4
  move.l  _Window,a1
  sub.l a2,a2
  lea ChangeIntTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  move.l  a4,a0
  move.l  _Window,a1
  sub.l a2,a2
  CALL  ActivateGadget,_IntuitionBase

OK_INTP:
  move.l  d7,PlacesValue
  rts

;-----------------------------------------------------------------------------

START_INTEGER:
  move.l  gg_SpecialInfo(a1),a2
  move.l  si_LongInt(a2),d7
  bge.s OK_INTS

  move.l  _WBScr,a0
  CALL  DisplayBeep,_IntuitionBase

  move.l  StartValue,d7
  SETTAG  #ChangeIntTags,GTIN_Number,d7

  moveq #GAD_PLACES,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  a0,a4
  move.l  _Window,a1
  sub.l a2,a2
  lea ChangeIntTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  move.l  a4,a0
  move.l  _Window,a1
  sub.l a2,a2
  CALL  ActivateGadget,_IntuitionBase

OK_INTS:
  move.l  d7,StartValue
  rts

;-----------------------------------------------------------------------------

LEADING_CYCLE:
  move.w  im_Code(a0),UseLeading
  rts

;-----------------------------------------------------------------------------

CONVERT_BUTTON:
  bsr.w ALL_GADS_OFF

  move.l  _Window,a0
  lea ArudWorking,a1
  lea ArudScrTitle,a2
  CALL  SetWindowTitles,_IntuitionBase

  lea ArudList,a0
  TSTLIST a0
  beq.s NOC_LIST

  lea BaseString,a0
  tst.b (a0)
  beq.s NOC_BASE

  move.l  ReqPlaceLow,d0
  move.l  PlacesValue,d1
  cmp.l d1,d0
  bgt.s NOC_PLACES

  move.l  StartValue,d7
  add.l NoFiles,d7
  lea DummyString,a2
  bsr.w NUM2TXT
  move.l  d6,ReqPlaceNew    ; required places!!!

  move.l  PlacesValue,d1
  cmp.l d1,d6
  bgt.s NOC_PLACES

;--------------------------------------------------------------------

  lea ArudList,a0
CONVERT_LOOP:
  TSTNODE a0,a1
  beq.s CONVERT_DONE

;--------------------------------------------------------------------

  tst.w ReverseFlag
  bne.s .REVERSE

  move.l  af_Count(a1),d0
  sub.l SmallestNo,d0
  add.l StartValue,d0     ; new count for this number.
  bra.s .NEWVAL

.REVERSE:         ; reverse renaming
  move.l  af_Count(a1),d0

  move.l  StartValue,d1
  add.l NoFiles,d1
  subq.l  #1,d1       ; highest value

  move.l  SmallestNo,d2
  sub.l d0,d2
  add.l d1,d2
  move.l  d2,d0

;--------------------------------------------------------------------

.NEWVAL:
  lea BaseString,a2
  lea Filename,a3
.COPY:  move.b  (a2)+,(a3)+
  bne.s .COPY

  lea -1(a3),a3

  lea DummyString,a4
  move.l  PlacesValue,d7
  move.b  #0,(a4,d7.w)
  subq.w  #1,d7
.NUMTXT:
  divu  #10,d0
  swap  d0
  add.b #'0',d0
  move.b  d0,(a4,d7.w)
  clr.w d0
  swap  d0
  dbf d7,.NUMTXT

;--------------------------------------------------------------------

  tst.w UseLeading
  bne.s .COPY2

.SEEK:  cmp.b #'0',(a4)
  bne.s .ZERO

  lea 1(a4),a4
  bra.s .SEEK

.ZERO:  tst.b (a4)
  bne.s .COPY2

  lea -1(a4),a4

.COPY2: move.b  (a4)+,(a3)+
  bne.s .COPY2

;--------------------------------------------------------------------
  
  move.l  af_Name(a1),d1
  move.l  #Filename,d2

  movem.l a0/a1,-(a7)

  tst.w ActionFlag    ; rename or copy files?
  bne.s COPY_FILE

RENAME_FILE:
  CALL  Rename,_DOSBase
  bra.s ACTION_DONE

COPY_FILE:
  bsr.w ACTION_COPY_FILE

ACTION_DONE:
  movem.l (a7)+,a0/a1

  tst.l d0
  beq.s RENAME_ERROR

;--------------------------------------------------------------------

  move.l  af_Name(a1),a2
  move.l  a2,d1
.SRCH:  tst.b (a2)+
  bne.s .SRCH

  lea -1(a2),a2
  lea InfoString,a3
.COPY3: move.b  (a3)+,(a2)+
  bne.s .COPY3

  movem.l a0/a1,-(a7)

  move.l  #ACCESS_READ,d2
  CALL  Lock,_DOSBase
  tst.l d0
  bne.s .UNL

  movem.l (a7)+,a0/a1
  bra.s CONTINUE

.UNL: move.l  d0,d1
  CALL  UnLock,_DOSBase

  movem.l (a7)+,a0/a1

;--------------------------------------------------------------------

  lea Filename,a2
.SRCH2: tst.b (a2)+
  bne.s .SRCH2

  lea -1(a2),a2

  lea InfoString,a3
.COPY4: move.b  (a3)+,(a2)+
  bne.s .COPY4

;--------------------------------------------------------------------

  move.l  af_Name(a1),d1
  move.l  #Filename,d2

  movem.l a0/a1,-(a7)

  tst.w ActionFlag    ; rename or copy files?
  bne.s COPY_INFO

RENAME_INFO:
  CALL  Rename,_DOSBase
  bra.s ACTION_DONE2

COPY_INFO:
  bsr.w ACTION_COPY_FILE

ACTION_DONE2:
  movem.l (a7)+,a0/a1

  tst.l d0
  beq.s RENAME_ERROR

CONTINUE:
  move.l  a1,a0
  bra.s CONVERT_LOOP

;--------------------------------------------------------------------

CONVERT_DONE:
  move.l  _Window,a0
  lea ArudTitle,a1
  lea ArudScrTitle,a2
  CALL  SetWindowTitles,_IntuitionBase

  bsr.w ALL_GADS_ON
  rts

;--------------------------------------------------------------------

ACTION_COPY_FILE:
  move.l  d1,d6     ; from
  move.l  d2,d7     ; to

  bsr.w FREE_FIB

  moveq #DOS_FIB,d1
  moveq #0,d2
  CALL  AllocDosObject,_DOSBase
  move.l  d0,_FIB
  beq.s COPY_FAIL

  move.l  d6,d1
  move.l  #MODE_OLDFILE,d2
  CALL  Open,_DOSBase
  move.l  d0,_CopyFile
  beq.s COPY_FAIL

  move.l  d0,d1
  move.l  _FIB,d2
  CALL  ExamineFH,_DOSBase

  move.l  _FIB,a0
  move.l  fib_Size(a0),d4
  addq.l  #1,d4
  move.l  d4,d0
  move.l  #MEMF_ANY,d1
  EXEC  AllocVec
  move.l  d0,_FileBuffer
  beq.s COPY_FAIL

  subq.l  #1,d4

  move.l  _CopyFile,d1
  move.l  _FileBuffer,d2
  move.l  d4,d3
  CALL  Read,_DOSBase
  cmp.l d0,d4
  bne.s COPY_FAIL

  bsr.s FREE_COPYFILE

  cmp.w #2,ActionFlag     ; Copy to?
  bne.s .NOT

  move.l  CPathStart,a0
  move.l  #Filename,a1
.CPY: move.b  (a1)+,(a0)+
  bne.s .CPY

  move.l  #CopyToPath,d7

.NOT: move.l  d7,d1
  move.l  #MODE_NEWFILE,d2
  CALL  Open,_DOSBase
  move.l  d0,_CopyFile
  beq.s COPY_FAIL

  move.l  d0,d1
  move.l  _FileBuffer,d2
  move.l  d4,d3
  CALL  Write,_DOSBase

  bsr.w FREE_COPYFILE
  bsr.w FREE_FILEBUFFER
  moveq #1,d0
  rts

COPY_FAIL:
  bsr.w FREE_COPYFILE
  bsr.w FREE_FILEBUFFER
  moveq #0,d0
  rts

;--------------------------------------------------------------------

FREE_COPYFILE:
  tst.l _CopyFile
  beq.s .NOT

  move.l  _CopyFile,d1
  CALL  Close,_DOSBase
  move.l  #0,_CopyFile
.NOT: rts

FREE_FILEBUFFER:
  tst.l _FileBuffer
  beq.s .NOT

  move.l  _FileBuffer,a1
  EXEC  FreeVec
  move.l  #0,_FileBuffer
.NOT: rts

;--------------------------------------------------------------------

RENAME_ERROR:
  CALL  IoErr,_DOSBase

  cmp.l #ERROR_OBJECT_IN_USE,d0
  beq.s NOC_INUSE
  cmp.l #ERROR_OBJECT_EXISTS,d0
  beq.s NOC_EXISTS
  cmp.l #ERROR_OBJECT_NOT_FOUND,d0
  beq.s NOC_NOTFOUND

  lea ERRRename,a1
  bsr.s DISPLAY_REQUESTER
  rts

;--------------------------------------------------------------------

NOC_INUSE:
  lea ERRInUse,a1
  bsr.s DISPLAY_REQUESTER
  rts

NOC_EXISTS:
  lea ERRExists,a1
  bsr.s DISPLAY_REQUESTER
  rts

NOC_NOTFOUND:
  lea ERRNotFound,a1
  bsr.s DISPLAY_REQUESTER
  rts

;--------------------------------------------------------------------

NOC_BASE:
  lea ERRNoBase,a1
  bsr.s DISPLAY_REQUESTER
  rts

NOC_LIST:
  lea ERRNoList,a1
  bsr.s DISPLAY_REQUESTER
  rts

NOC_PLACES:
  lea ERRCheckPlaces,a1
  bsr.s DISPLAY_REQUESTER
  rts

DISPLAY_REQUESTER:
  move.l  a1,-(a7)
  move.l  _Window,a0
  lea ArudTitle,a1
  sub.l a2,a2
  CALL  SetWindowTitles,_IntuitionBase
  move.l  (a7)+,a1

  lea GADText_Ok,a2
  move.l  _InfoReq,a3
  sub.l a4,a4
  lea EZReqTags,a0
  CALL  rtEZRequestA,_ReqToolsBase

  bsr.w ALL_GADS_ON
  rts

;-----------------------------------------------------------------------------

QUIT_BUTTON:
  move.w  #1,ExitFlag
  rts

;-----------------------------------------------------------------------------

FORCE_CYCLE:
  moveq #0,d0
  move.w  im_Code(a0),d0
  move.l  d0,PreDefBase
  beq.s PREDEF_OFF

  lea BaseString,a0
  tst.b (a0)
  beq.s PREDEF_NOSTRING

  lea FileBase,a1
  move.w  #-1,d7
.LOOP:  addq.w  #1,d7
  move.b  (a0)+,(a1)+
  bne.s .LOOP

  move.w  d7,PreBaseLen
  rts

PREDEF_OFF:
  lea FileBase,a0
  move.b  #0,(a0)
  rts

PREDEF_NOSTRING:
  clr.l PreDefBase

  lea FileBase,a0
  move.b  #0,(a0)

  move.l  _WBScr,a0
  CALL  DisplayBeep,_IntuitionBase

  moveq #GAD_FORCE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  a0,a4
  move.l  _Window,a1
  sub.l a2,a2
  lea ForceTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase
  rts

;-------------------------------------------------------------------

DIRECT_CYCLE:
  move.w  im_Code(a0),ReverseFlag
  rts

;--------------------------------------------------------------------

ACTION_CYCLE:
  move.w  im_Code(a0),ActionFlag
  cmp.w #2,ActionFlag
  bne.s SAME_PATH

  bsr.w ALL_GADS_OFF

  move.l  _FileReq,a1
  sub.l a2,a2
  lea ArudTitle,a3
  lea FileReqTags,a0
  CALL  rtFileRequestA,_ReqToolsBase
  tst.l d0
  beq.s SET_ACT_RENAME

  move.l  _FileReq,a0
  move.l  rtfi_Dir(a0),a0   ; copy result to buffer
  lea CopyToPath,a1
.LOOP:  move.b  (a0)+,(a1)+
  bne.s .LOOP

  lea -1(a1),a1
  move.l  a1,CPathStart   ; this is where the filename
          ; starts

  cmp.b #':',-1(a1)
  beq.s NO_ACT_PATH

  cmp.b #'/',-1(a1)
  beq.s NO_ACT_PATH

  move.b  #'/',(a1)+
  move.l  a1,CPathStart

NO_ACT_PATH:
  bsr.w ALL_GADS_ON
  rts

SET_ACT_RENAME:
  SETTAG  #ActionTags,GTCY_Active,#0

  moveq #GAD_ACTION,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  a0,a4
  move.l  _Window,a1
  sub.l a2,a2
  lea ActionTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  move.w  #0,ActionFlag

  bsr.w ALL_GADS_ON
  rts

SAME_PATH:
  move.l  #0,CPathStart
  rts

;--------------------------------------------------------------------

CURRENT_DIRECTORY:      ; d7=pathname
  tst.l _CDLock
  beq.s .LOCK

  move.l  _CDLock,d1
  CALL  UnLock,_DOSBase
  move.l  #0,_CDLock

.LOCK:  move.l  d7,d1
  move.l  #ACCESS_READ,d2
  CALL  Lock,_DOSBase
  move.l  d0,_CDLock
  bne.s .OKLOCK

  move.l  _WBScr,a0
  CALL  DisplayBeep,_IntuitionBase
  moveq #0,d0
  rts

.OKLOCK:
  move.l  d0,d1
  CALL  CurrentDir,_DOSBase

  tst.w CurrentDone
  bne.s .PRGCD

  move.l  d0,_OldCurrent
  move.w  #1,CurrentDone

.PRGCD: moveq #1,d0
  rts

;-----------------------------------------------------------------------------
  
BUILD_STRUCTURE:
  bsr.w FREE_LIST
  bsr.w FREE_FIB

  move.w  #0,HasStructure
  move.l  #$fffffff,SmallestNo
  move.l  #0,HighestNo
  move.l  #0,NoFiles
  move.l  #0,PlacesUsed

  bsr.w RESET_GADGETS

  moveq #GAD_FORCE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea ForceAttrTags,a3
  CALL  GT_GetGadgetAttrsA,_GadToolsBase

  moveq #DOS_FIB,d1
  moveq #0,d2
  CALL  AllocDosObject,_DOSBase
  move.l  d0,_FIB
  beq.s BUILD_FAIL

  move.l  _CDLock,d1
  move.l  _FIB,d2
  CALL  Examine,_DOSBase
  beq.s BUILD_FAIL  

BUILD_LOOP:
  move.l  _CDLock,d1
  move.l  _FIB,d2
  CALL  ExNext,_DOSBase
  tst.l d0
  beq.s CHECK_END

  move.l  _FIB,a0
  tst.l fib_DirEntryType(a0)  ; files only
  bpl.s BUILD_LOOP

  lea fib_FileName(a0),a2

  tst.l PreDefBase
  bne.s BASE_PREDEF

  bsr.s CHECK_NAME    ; check for illegal filename
  beq.s BUILD_LOOP

BASE_PREDEF:
  move.l  a2,a3
  lea FileBase,a4   ; files must have same basename!!
.SAME:  move.b  (a4)+,d0
  beq.s .SOK

  move.b  (a3)+,d1
  cmp.b d0,d1
  beq.s .SAME
  bra.s BUILD_LOOP

.SOK: tst.b (a3)      ; filename has same base
  beq.s BUILD_LOOP

  moveq #0,d2

.CHK2:  move.b  (a3)+,d0    ; ... now check if next part is a
  beq.s .USE      ; number...
  cmp.b #'0',d0
  blo.s BUILD_LOOP
  cmp.b #'9',d0   
  bhi.s BUILD_LOOP

  addq.l  #1,d2
  bra.s .CHK2

.USE: move.l  d2,PlacesUsed   ; max number of places used

  move.l  #af_SIZEOF,d0
  move.l  #MEMF_ANY!MEMF_CLEAR,d1
  EXEC  AllocVec
  move.l  d0,_CurrentNode
  beq.s BUILD_FAIL

  move.l  #FILELEN+1,d0
  move.l  #MEMF_ANY!MEMF_CLEAR,d1
  EXEC  AllocVec
  tst.l d0
  beq.s BUILD_FAIL

  move.l  _CurrentNode,a1
  move.l  d0,af_Name(a1)    ; insert filenameptr into node

  move.l  d0,a0
  move.w  #FILELEN-1,d7   ; copy text
  move.l  a2,a3
COPY_NAME:
  move.b  (a2)+,(a0)+
  beq.s .DONE
  dbf d7,COPY_NAME

.DONE:  move.w  PreBaseLen,d7
  lea (a3,d7.w),a3    ; jump to number-part of string

MAKE_NUMBER:
  moveq #0,d0
  moveq #0,d1
.MAKE:  move.b  (a3)+,d1
  beq.s .DONE

  sub.b #'0',d1
  mulu  #10,d0
  add.w d1,d0
  bra.s .MAKE

.DONE:  move.l  d0,af_Count(a1)

  move.l  HighestNo,d1
  cmp.l d1,d0
  blt.s .LOW

  move.l  d0,HighestNo

.LOW: move.l  SmallestNo,d1
  cmp.l d1,d0
  bgt.s .BIG

  move.l  d0,SmallestNo

.BIG: lea ArudList,a0
  move.l  _CurrentNode,a1   ; insert node into list
  ADDTAIL

  add.l #1,NoFiles
  bra.s BUILD_LOOP

BUILD_FAIL:
  move.l  #0,_CurrentNode
  moveq #0,d0
  rts

CHECK_END:
  CALL  IoErr,_DOSBase
  cmp.l #ERROR_NO_MORE_ENTRIES,d0
  bne.s BUILD_FAIL

  lea ArudList,a0
  TSTLIST a0
  beq.s BUILD_FAIL

; make range-text

  move.l  SmallestNo,d7   ; smallest in range
  lea RangeString,a2
  bsr.w NUM2TXT

  move.b  #'-',-1(a2)

  move.l  SmallestNo,d7
  add.l NoFiles,d7
  subq.l  #1,d7     ; d7=largest in range
  bsr.w NUM2TXT

  move.b  #0,-1(a2)

  move.l  NoFiles,d7
  lea DummyString,a2
  bsr.w NUM2TXT
  move.l  d6,ReqPlaceLow    ; required places!!!

  move.w  #1,HasStructure
  moveq #1,d0
  rts

;-----------------------------------------------------------------------------

NUM2TXT:        ; d7=number, a2=string to fill
  move.l  d7,d0
  lea DummyStringE,a0

  lea DummyString,a1
  move.w  #9,d1
.CLR: clr.b (a1)+
  dbf d1,.CLR

  moveq #0,d6
.LOOP:  addq.l  #1,d6
  divu  #10,d0
  swap  d0
  add.b #'0',d0
  move.b  d0,-(a0)
  clr.w d0
  swap  d0
  tst.w d0
  bne.s .LOOP
  move.b  #0,-(a0)

  lea DummyString,a1
.SEEK:  tst.b (a1)+
  beq.s .SEEK

  lea -1(a1),a1
.COPY:  move.b  (a1)+,(a2)+
  bne.s .COPY
  rts       ; d6=places in string used

;-----------------------------------------------------------------------------

CHECK_NAME:     ; only names that end in a number are legal
  move.l  a2,a3
.NULL:  tst.b (a3)+
  bne.s .NULL

  lea -1(a3),a3

.CHK: lea -1(a3),a3
  cmp.b #' ',(a3)
  beq.s .CHK

  cmp.b #'0',(a3)
  blo.s .FAIL
  cmp.b #'9',(a3)
  bhi.s .FAIL

.BASE:  lea -1(a3),a3 ; find last char of basename
  cmp.b #'0',(a3)
  blo.s .FOUND
  cmp.b #'9',(a3)
  ble.s .BASE

.FOUND: lea 1(a3),a3
  move.l  a2,a4
  lea FileBase,a5
  moveq #0,d7   ; length of basename
.CPY: move.b  (a4)+,(a5)+
  addq.w  #1,d7
  cmp.l a3,a4
  bne.s .CPY

  move.b  #0,(a5)

  cmp.w #BASELEN,d7 ; too many chars used in basename
  bgt.s .FAIL

  move.w  d7,PreBaseLen ; length of pre-defined basename length

  move.l  #1,PreDefBase
  moveq #1,d0
  rts

.FAIL:  moveq #0,d0
  rts

;-----------------------------------------------------------------------------

RESET_GADGETS:
  moveq #GAD_BASETEXT,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea ClrBTextTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #ReqPlaceTags,GTNM_Number,#0

  moveq #GAD_REQPLACE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea ReqPlaceTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #PlaceUseTags,GTNM_Number,#0

  moveq #GAD_PLACEUSE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea PlaceUseTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  SETTAG  #NoFilesTags,GTNM_Number,#0

  moveq #GAD_NOFILES,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea NoFilesTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase

  lea RangeString,a0
  move.b  #0,(a0)

  moveq #GAD_RANGE,d0
  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea RangeTags,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase
  rts

;-----------------------------------------------------------------------------

ALL_GADS_ON:
  lea AllGads,a5
.LOOP:  move.l  (a5)+,d0
  bmi.s .DONE

  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea AllOnTag,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase
  bra.s .LOOP
.DONE:  rts

ALL_GADS_OFF:
  lea AllGads,a5
.LOOP:  move.l  (a5)+,d0
  bmi.s .DONE

  lsl.w #2,d0
  lea GadgetList,a0
  move.l  (a0,d0.w),a0
  move.l  _Window,a1
  sub.l a2,a2
  lea AllOffTag,a3
  CALL  GT_SetGadgetAttrsA,_GadToolsBase
  bra.s .LOOP
.DONE:  rts
  

;-----------------------------------------------------------------------------

  section "Data",data

  IFD WB
_WBMsg:   dc.l  0
  ENDC

_DOSBase: dc.l  0
_GfxBase: dc.l  0
_GadToolsBase:  dc.l  0
_IntuitionBase: dc.l  0
_ReqToolsBase:  dc.l  0
ReqToolsName: dc.b  "reqtools.library",0
IntuitionName:  dc.b  "intuition.library",0
GadToolsName: dc.b  "gadtools.library",0
DOSName:  dc.b  "dos.library",0
GfxName:  dc.b  "graphics.library",0
    VERSTR
ProgramName:  dc.b  "Arud Converter V"
    VER
    dc.b  "."
    REV
    dc.b  0
    even

;----------------------------------------------------------------------------

WBLock:   dc.w  0
ExitFlag: dc.w  0

_UserPort:  dc.l  0
_Message: dc.l  0

_FileReq: dc.l  0
_InfoReq: dc.l  0

;----------------------------------------------------------------------------

SubJumpTable: dc.l  PATH_BUTTON
    dc.l  PATH_STRING
    dc.l  NO_OP
    dc.l  NO_OP
    dc.l  NO_OP
    dc.l  NO_OP
    dc.l  NEWBASE_STRING
    dc.l  PLACES_INTEGER
    dc.l  START_INTEGER
    dc.l  LEADING_CYCLE
    dc.l  CONVERT_BUTTON
    dc.l  QUIT_BUTTON
    dc.l  FORCE_CYCLE
    dc.l  DIRECT_CYCLE
    dc.l  ACTION_CYCLE
    dc.l  NO_OP

;----------------------------------------------------------------------------

HasStructure: dc.w  0
_CurrentNode: dc.l  0
ArudList: dcb.b MLH_SIZE,0

;----------------------------------------------------------------------------

CurrentDone:  dc.w  0     ; has CurrentDir() ever
            ; been done?
_OldCurrent:  dc.l  0
_CDLock:  dc.l  0     ; lock to chosen path
_FIB:   dc.l  0

UseLeading: dc.w  0     ; use leading zeros
PlacesValue:  dc.l  1     ; number of places
StartValue: dc.l  0     ; new start value

HighestNo:  dc.l  0
SmallestNo: dc.l  $fffffff    ; smallest number
NoFiles:  dc.l  0     ; number of files found
ReqPlaceLow:  dc.l  0
ReqPlaceNew:  dc.l  0     ; required places
PlacesUsed: dc.l  0

PreBaseLen: dc.w  0     ; pre-def basename length
PreDefBase: dc.l  0     ; is basename pre-defined?

ReverseFlag:  dc.w  0     ; order of renaming (reverse)
ActionFlag: dc.w  0     ; Rename() or Copy() files

_CopyFile:  dc.l  0
_FileBuffer:  dc.l  0

CPathStart: dc.l  0

IllegalChars: dc.b  ":;*/?'#%",0    ; cannot be used in basename

PathString: dcb.b PATHLEN+1,0
BaseString: dcb.b BASELEN+1,0   ; user defined
FileBase: dcb.b BASELEN+1,0   ; set by 'BUILD_STRUCTURE'
RangeString:  dcb.b 18,0      ; Range of files
Filename: dcb.b 108,0
CopyToPath: dcb.b 108,0

DummyString:  dcb.b PLACESLEN+1,0   ; dummy string for converting
DummyStringE: dc.b  0     ; numbers to decimal text

InfoString: dc.b  ".info",0

ERRNoBase:  dc.b  "No basestring defined.",0
ERRNoList:  dc.b  "No filelist defined.",0
ERRCheckPlaces: dc.b  "Places value too low.",0
ERRRename:  dc.b  "Copy/Rename error.",0
ERRInUse: dc.b  "File is in use.",0
ERRExists:  dc.b  "File already exists.",0
ERRNotFound:  dc.b  "File not found! Update filelist.",0

GADText_Ok: dc.b  "Ok",0
    even

FileReqTags:  dc.l  RT_ReqPos,REQPOS_CENTERWIN
    dc.l  RT_Window,0
    dc.l  RTFI_Flags,FREQF_NOFILES
    dc.l  RTEZ_ReqTitle,ProgramName
    dc.l  TAG_DONE

EZReqTags:  dc.l  RT_ReqPos,REQPOS_CENTERWIN
    dc.l  RT_Window,0
    dc.l  RTEZ_ReqTitle,ProgramName
    dc.l  TAG_DONE

ChangeDirTags:  dc.l  RTFI_Dir,PathString
    dc.l  TAG_DONE

ChangeIntTags:  dc.l  GTIN_Number,0
    dc.l  TAG_DONE

ChangeStrTags:  dc.l  GTST_String,BaseString
    dc.l  TAG_DONE

ForceAttrTags:  dc.l  GTCY_Active,PreDefBase
    dc.l  TAG_DONE

ClrBTextTags: dc.l  GTTX_Text,NULL
    dc.l  TAG_DONE

;----------------------------------------------------------------------------

_TextAttr:  dc.l  0
_Font:    dc.l  0

_VisualInfo:  dc.l  0
_WBScr:   dc.l  0
WorkbenchName:  dc.b  "Workbench",0
    even

FontHeight: dc.w  0
FontWidth:  dc.w  0
TitleHeight:  dc.w  0

WindowHeight: dc.w  0
WindowWidth:  dc.w  0

GadgetHeight: dc.w  0

_Gad:   dc.l  0
GadgetList: dcb.l SUMGAD,0

AllGads:  dc.l  GAD_PBUTTON,GAD_PSTRING,GAD_NEWBASE,GAD_PLACES
    dc.l  GAD_STARTVAL,GAD_LEADING,GAD_CONVERT,GAD_QUIT
    dc.l  GAD_FORCE,GAD_DIRECTION,GAD_ACTION,-1

AllOnTag: dc.l  GA_Disabled,FALSE
    dc.l  TAG_DONE

AllOffTag:  dc.l  GA_Disabled,TRUE
    dc.l  TAG_DONE

GadgetTags: dc.l  PButtonTags
    dc.l  PStringTags
    dc.l  BaseTextTags
    dc.l  ReqPlaceTags
    dc.l  NoFilesTags
    dc.l  RangeTags
    dc.l  NewBaseTags
    dc.l  PlacesTags
    dc.l  StartValTags
    dc.l  LeadingTags
    dc.l  ConvertTags
    dc.l  QuitTags
    dc.l  ForceTags
    dc.l  DirectionTags
    dc.l  ActionTags
    dc.l  PlaceUseTags
    dc.l  0

PButtonTags:  dc.l  TAG_DONE
PStringTags:  dc.l  GTST_String,PathString
    dc.l  GTST_MaxChars,PATHLEN
    dc.l  GA_TabCycle,FALSE
    dc.l  TAG_DONE
BaseTextTags: dc.l  GTTX_Border,TRUE
    dc.l  GTTX_Text,FileBase
    dc.l  TAG_DONE
ReqPlaceTags: dc.l  GTNM_Number,0
    dc.l  GTNM_Border,TRUE
    dc.l  TAG_DONE
NoFilesTags:  dc.l  GTNM_Number,0
    dc.l  GTNM_Border,TRUE
    dc.l  TAG_DONE
RangeTags:  dc.l  GTTX_Text,RangeString
    dc.l  GTTX_Border,TRUE
    dc.l  TAG_DONE
NewBaseTags:  dc.l  GTST_MaxChars,BASELEN
    dc.l  GA_TabCycle,TRUE
    dc.l  TAG_DONE
PlacesTags: dc.l  GTIN_MaxChars,2
    dc.l  GA_TabCycle,TRUE
    dc.l  GTIN_Number,1
    dc.l  TAG_DONE
StartValTags: dc.l  GTIN_MaxChars,8
    dc.l  GA_TabCycle,TRUE
    dc.l  TAG_DONE
LeadingTags:  dc.l  GTCY_Labels,LeadingPtrs
    dc.l  TAG_DONE
ConvertTags:  dc.l  TAG_DONE
QuitTags: dc.l  TAG_DONE
ForceTags:  dc.l  GTCY_Active,0
    dc.l  GTCY_Labels,ForcePtrs
DirectionTags:  dc.l  GTCY_Labels,DirectionPtrs
    dc.l  TAG_DONE
ActionTags: dc.l  GTCY_Active,0
    dc.l  GTCY_Labels,ActionPtrs
    dc.l  TAG_DONE
PlaceUseTags: dc.l  GTNM_Number,0
    dc.l  GTNM_Border,TRUE
    dc.l  TAG_DONE

GadgetTypes:  dc.l  BUTTON_KIND
    dc.l  STRING_KIND
    dc.l  TEXT_KIND
    dc.l  NUMBER_KIND
    dc.l  NUMBER_KIND
    dc.l  TEXT_KIND
    dc.l  STRING_KIND
    dc.l  INTEGER_KIND
    dc.l  INTEGER_KIND
    dc.l  CYCLE_KIND
    dc.l  BUTTON_KIND
    dc.l  BUTTON_KIND
    dc.l  CYCLE_KIND
    dc.l  CYCLE_KIND
    dc.l  CYCLE_KIND
    dc.l  NUMBER_KIND

GadgetStructs:  dc.l  PButtonS
    dc.l  PStringS
    dc.l  BaseTextS
    dc.l  ReqPlaceS
    dc.l  NoFilesS
    dc.l  RangeS
    dc.l  NewBaseS
    dc.l  PlacesS
    dc.l  StartValS
    dc.l  LeadingS
    dc.l  ConvertS
    dc.l  QuitS
    dc.l  ForceS
    dc.l  DirectionS
    dc.l  ActionS
    dc.l  PlaceUseS
    dc.l  0

PButtonS: dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  PathText  ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_PBUTTON ; gng_GadgetID
    dc.l  PLACETEXT_IN  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

PathText: dc.b  "Path",0
    even

PStringS: dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  0   ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_PSTRING ; gng_GadgetID
    dc.l  0   ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

PCalcIT:  dc.b  0,0
    dc.b  0,0
    dc.w  0,0
    dc.l  0
    dc.l  PCalcString
    dc.l  0

PCalcString:  dcb.b PCALCLEN,"a"
    dc.b  0
    even


BaseTextS:  dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  BaseTextText  ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_BASETEXT  ; gng_GadgetID
    dc.l  PLACETEXT_LEFT  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

BaseTextText: dc.b  "Basename",0
    even

ReqPlaceS:  dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  ReqPlaceText  ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_REQPLACE  ; gng_GadgetID
    dc.l  PLACETEXT_LEFT  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

ReqPlaceText: dc.b  "Need/Used",0
    even

NoFilesS: dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  NoFilesText ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_NOFILES ; gng_GadgetID
    dc.l  PLACETEXT_LEFT  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

NoFilesText:  dc.b  "Files",0
    even

RangeS:   dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  RangeText ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_RANGE ; gng_GadgetID
    dc.l  PLACETEXT_LEFT  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

RangeText:  dc.b  "Range",0
    even

NewBaseS: dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  NewBaseText ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_NEWBASE ; gng_GadgetID
    dc.l  PLACETEXT_LEFT  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

NewBaseText:  dc.b  "Base",0
    even

PlacesS:  dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  PlacesText  ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_PLACES  ; gng_GadgetID
    dc.l  PLACETEXT_LEFT  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

PlacesText: dc.b  "Places",0
    even

StartValS:  dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  StartValText  ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_STARTVAL  ; gng_GadgetID
    dc.l  PLACETEXT_LEFT  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

StartValText: dc.b  "Start value",0
    even

LeadingS: dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  0   ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_LEADING ; gng_GadgetID
    dc.l  0   ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

LeadingPtrs:  dc.l  NoLeadingText
    dc.l  LeadingText
    dc.l  0

NoLeadingText:  dc.b  "No leading zeros",0
LeadingText:  dc.b  "Leading zeros",0
    even

ConvertS: dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  ConvertText ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_CONVERT ; gng_GadgetID
    dc.l  PLACETEXT_IN  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

ConvertText:  dc.b  "Convert",0
    even

QuitS:    dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  QuitText  ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_QUIT  ; gng_GadgetID
    dc.l  PLACETEXT_IN  ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

QuitText: dc.b  "Quit",0
    even

ForceS:   dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  0   ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_FORCE ; gng_GadgetID
    dc.l  0   ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

ForcePtrs:  dc.l  ForceOff
    dc.l  ForceOn
    dc.l  0

ForceOff: dc.b  "First",0
ForceOn:  dc.b  "Force",0
    even

ForceIT:  dc.b  0,0
    dc.b  0,0
    dc.w  0,0
    dc.l  0
    dc.l  ForceOn
    dc.l  0

DirectionS: dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  0   ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_DIRECTION ; gng_GadgetID
    dc.l  0   ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

DirectionPtrs:  dc.l  DirSame
    dc.l  DirReverse
    dc.l  0

DirSame:  dc.b  "Same Order",0
DirReverse: dc.b  "Reversed Order",0
    even

ActionS:  dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  0   ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_ACTION  ; gng_GadgetID
    dc.l  0   ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

ActionPtrs: dc.l  ActRename
    dc.l  ActCopy
    dc.l  ActCopyto
    dc.l  0

ActRename:  dc.b  "Rename",0
ActCopy:  dc.b  "Copy",0
ActCopyto:  dc.b  "Copy To",0
    even

PlaceUseS:  dc.w  0   ; gng_LeftEdge
    dc.w  0   ; gng_TopEdge
    dc.w  0   ; gng_Width
    dc.w  0   ; gng_Height
    dc.l  0   ; gng_GadgetText
    dc.l  0   ; gng_TextAttr
    dc.w  GAD_PLACEUSE  ; gng_GadgetID
    dc.l  0   ; gng_Flags
    dc.l  0   ; gng_VisualInfo
    dc.l  0   ; gng_UserData

;----------------------------------------------------------------------

BevelTags:  dc.l  GT_VisualInfo,0
    dc.l  TAG_DONE

;----------------------------------------------------------------------

_Window:  dc.l  0
NewWindowTags:  dc.l  WA_Left,0
    dc.l  WA_Top,0
    dc.l  WA_Height,0
    dc.l  WA_Width,0
    dc.l  WA_Title,ArudTitle
    dc.l  WA_ScreenTitle,ArudScrTitle
    dc.l  WA_DetailPen,0
    dc.l  WA_BlockPen,1
    dc.l  WA_Gadgets,0
    dc.l  WA_DragBar,TRUE
    dc.l  WA_CloseGadget,TRUE
    dc.l  WA_DepthGadget,TRUE
    dc.l  WA_Activate,TRUE
    dc.l  WA_RMBTrap,TRUE
    dc.l  WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_GADGETUP
    dc.l  TAG_DONE

ArudTitle:  dc.b  "Arud Converter V"
    VER
    dc.b  "."
    REV
    dc.b  0
ArudScrTitle: dc.b  "Arud Converter V"
    VER
    dc.b  "."
    REV
    dc.b  " by Morten Amundsen, 1993-1996.",0
ArudWorking:  dc.b  "Working...",0
    even

TopazAttr:  dc.l  TopazName
    dc.w  8
    dc.b  0
    dc.b  FPF_ROMFONT

TopazName:  dc.b  "topaz.font",0
    even
