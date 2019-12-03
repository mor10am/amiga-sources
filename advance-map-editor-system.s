;--------------------------------------------------------------------
; Advanced Map Editor System (AMES)
; by Morten Amundsen
;
; Assembled with PhxAss 4.23
;--------------------------------------------------------------------
;
; Sunday, 12/11 1995, 19:09
;
;	- Started coding
;	- Get WBMsg, open libraries, disable commodities
;	- Made setup/remove routines for: Copper
;					  Interrupt
;					  Input handler
;	- Allocates a new signal for our process. "_ThisTask" is signaled
;	  from the inputhandler, and we can check for the right key and
;	  mouse activity.
;	- Made a routine that checks for keyboard combinations.
;         ("KEY" macro and "CHECK_RAWKEY" subroutine)
;	- Made an animated cursor sprite.
;	- reads mouse and moves cursor accordingly
;	- when lcommand+m is pressed, default public screen is put
;	  to front. A small window is also opened, and when closed,
;	  returns the user to AMES.
;	- Made a routine that loads the file "AMES.cxignore", which
;	  contain the names of commodities AMES should not send
;	  either CXCMD_DISABLE or CXCMD_ENABLE to. (BUGGED!)
;	- Fixed bug in the routine that checks what commodities
;	  to disable or not. (CHECK_DISABLE)

;--------------------------------------------------------------------
; AMES keys:
;
; ralt+ESC ..................................................... EXIT
; rcommand+m ..................................... WORKBENCH TO FRONT
; F1 ....................................... LOAD/FRONT BRICKSCREEN 0
;--------------------------------------------------------------------

	MACHINE	68020

NEWCOP	= 1		; copper
NEWINT	= 1		; interrupt
NEWIPH	= 1		; input handler
UNC	= 1		; unchain inputstream
DISCX	= 0		; disable cx

;--------------------------------------------------------------------

	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"misc/rawkey.i"
	include	"exec/lists.i"
	include	"exec/memory.i"
	include	"dos/dosextens.i"
	include	"libraries/commodities.i"
	include	"libraries/reqtools.i"
	include	"graphics/gfxbase.i"
	include	"intuition/intuitionbase.i"
	include	"intuition/intuition.i"
	include	"hardware/intbits.i"
	include	"devices/input.i"
	include	"devices/inputevent.i"
	include	"libraries/iffparse.i"

;--------------------------------------------------------------------

NAME:		MACRO
		dc.b	"ames"
		ENDM

VER:		MACRO
		dc.b	"1"
		ENDM

REV:		MACRO
		dc.b	"0"
		ENDM

AMESNAME:	MACRO
		NAME
		dc.b	" "
		VER
		dc.b	"."
		REV
		ENDM

AMESDATE:	MACRO
		dc.b	"(9.11.95)"
		ENDM

;--------------------------------------------------------------------

; "SEARCH FOR KEYSTROKE"
; result=KEY(key,qualifier)

KEY:            MACRO
                move.l  #\1,d1
                move.l  #\2,d2
                bsr.w   CHECK_RAWKEY
                ENDM

;--------------------------------------------------------------------
; sets up the workbench screen

WBFRONT:	MACRO
		movem.l	d0-d7/a0-a6,-(a7)
		bsr.w	REMOVE_COPPERLIST
		bsr.w	REMOVE_INTERRUPT
		bsr.w	REM_INPUT_HANDLER
	
		move.l	#CXCMD_ENABLE,d7
		bsr.w	SEND_CX_COMMAND
		movem.l	(a7)+,d0-d7/a0-a6
		ENDM

;--------------------------------------------------------------------
; goes back to AMES copperlist

AMESFRONT:	MACRO
		movem.l	d0-d7/a0-a6,-(a7)
		move.l	#CXCMD_DISABLE,d7
		bsr.w	SEND_CX_COMMAND

		bsr.w	ADD_INPUT_HANDLER
		bsr.w	SETUP_INTERRUPT
		bsr.w	SETUP_COPPERLIST
		movem.l	(a7)+,d0-d7/a0-a6
		ENDM

;--------------------------------------------------------------------
; "Make char uppercase"
; UPPER(Dx)

UPPER:		MACRO
		cmp.b	#'a',\1
		blo.s	UDONE\@
		cmp.b	#'z',\1
		bhi.s	UDONE\@

		sub.b	#'a'-'A',\1
UDONE\@:	
		ENDM
;--------------------------------------------------------------------

; screen structure common to all screens

 STRUCTURE	am,0
	UBYTE	am_ID		; see below
	UBYTE	am_pad0
	APTR	am_bmap		; bitmap memory
	UWORD	am_depth
	UWORD	am_width
	UWORD	am_height
	UWORD	am_w8		; width in bytes
	UWORD	am_w16		; width modulo 16
	UWORD	am_h16		; height modulo 16
	UWORD	am_modulo
	APTR	am_coltable
	UWORD	am_xpos		; x scroll pos
	UWORD	am_ypos		; y scroll pos
	UWORD	am_cx		; last cursor x pos
	UWORD	am_cy		; last cursor y pos
	APTR	am_preset	; table of preset values
	LABEL	am_SIZEOF

; screen ID values (am_ID)

SC_MAP:		equ	0
SC_BRK0:	equ	1
SC_BRK1:	equ	2
SC_BRK2:	equ	3
SC_BRK3:	equ	4
SC_BRK4:	equ	5
SC_BRK5:	equ	6
SC_BRK6:	equ	7
SC_BRK7:	equ	8
SC_BRK8:	equ	9
SC_BRK9:	equ	10
SC_NOBRK:	equ	10		; number of brick screens
SC_NOSCREENS:	equ	11		; number of screens

; preset table structure

 STRUCTURE	pre,0
	UWORD	pre_ID
	UWORD	pre_block
	UWORD	pre_mode
	UWORD	pre_code
	LABEL	pre_SIZEOF

;--------------------------------------------------------------------

 STRUCTURE	bmh,0			; ILBM BMHD structure
	UWORD	bmh_Width
	UWORD	bmh_Height
	UWORD	bmh_XPos
	UWORD	bmh_YPos
	UBYTE	bmh_nPlanes
	UBYTE	bmh_Masking
	UBYTE	bmh_Compression
	UBYTE	bmh_Pad
	UWORD	bmh_TranspCol
	UBYTE	bmh_XAspect
	UBYTE	bmh_YAspect
	UWORD	bmh_PageWidth
	UWORD	bmh_PageHeight
	LABEL	bmh_SIZEOF

;--------------------------------------------------------------------

ANIMSPEED:	equ	3		; speed of cursor/ruler anims

;--------------------------------------------------------------------

	XDEF	_main
	XDEF	_DOSBase
	XDEF	_GfxBase
	XDEF	_IntuitionBase
	XDEF	_ReqToolsBase
	XDEF	_IFFParseBase

;--------------------------------------------------------------------

	section	"AMESCODE",code

_main:	movem.l	d0-d7/a0-a6,-(a7)

;--------------------------------------------------------------------
; get WB Message, if started from icon

	sub.l	a1,a1
	EXEC	FindTask
	move.l	d0,a4

	moveq	#0,d0

	tst.l	pr_CLI(a4)
	bne.s	.CLI

	lea	pr_MsgPort(a4),a0
	EXEC	WaitPort
	lea	pr_MsgPort(a4),a0
	EXEC	GetMsg
.CLI:	move.l	d0,_WBMsg

;--------------------------------------------------------------------
; open libraries

	OPENLIB	DOSName,39,_DOSBase
	beq.s	EXIT
	OPENLIB GfxName,39,_GfxBase
	beq.s	EXIT
	OPENLIB	IntuitionName,39,_IntuitionBase
	beq.s	EXIT
	OPENLIB ReqToolsName,38,_ReqToolsBase
	beq.s	EXIT
	OPENLIB	IFFParseName,39,_IFFParseBase
	beq.s	EXIT

	IFD	DISCX
	OPENLIB	CxName,39,_CxBase
	beq.s	EXIT
	ENDC

;--------------------------------------------------------------------

	moveq	#RT_REQINFO,d0			; requester
	sub.l	a0,a0
	CALL	rtAllocRequestA,_ReqToolsBase
	move.l	d0,_ReqInfo
	beq.s	EXIT

	moveq	#RT_FILEREQ,d0			; file requester
	sub.l	a0,a0
	CALL	rtAllocRequestA,_ReqToolsBase
	move.l	d0,_FileReq
	beq.s	EXIT

;--------------------------------------------------------------------
; Load "AMES:AMES.cxignore" file if it exists

	IFD	DISCX
	moveq	#DOS_FIB,d1
	moveq	#0,d2
	CALL	AllocDosObject,_DOSBase		; allocate FileInfoBlock
	move.l	d0,_FIB
	beq.s	NO_IGNORE

	move.l	#IgnoreFilename,d1
	move.l	#MODE_OLDFILE,d2		; open "AMES.cxignore" file
	CALL	Open,_DOSBase
	move.l	d0,_IgnoreFile
	beq.s	ABORT_LOAD

	move.l	d0,d1
	move.l	_FIB,d2
	CALL	ExamineFH,_DOSBase		; examine filehandle

	move.l	_FIB,a0
	move.l	fib_Size(a0),d7			; get filesize (in bytes)

	move.l	d7,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1		; alloc memory for file
	EXEC	AllocVec
	move.l	d0,_IgnoreList
	beq.s	ABORT_LOAD

	move.l	_IgnoreFile,d1
	move.l	_IgnoreList,d2
	move.l	d7,d3
	CALL	Read,_DOSBase			; load file

	cmp.l	d0,d7				; did we load all bytes
	beq.s	COUNT_CX			; yes!

COUNT_ERR:
	move.l	_IgnoreList,a1			; no! free list,
	EXEC	FreeVec
	move.l	#0,_IgnoreList			; ...and clear ptr
	move.l	#0,_IgnoreBuffer
	bra.s	ABORT_LOAD

COUNT_CX:				; first line of file is the
					; number of commodities in list

	move.l	_IgnoreList,a0
	moveq	#0,d0
	moveq	#0,d1
.LOOP:	move.b	(a0)+,d0
	cmp.b	#' ',d0			; skip SPACE
	beq.s	.LOOP
	cmp.b	#10,d0			; get chars until LF
	beq.s	.DONE

	cmp.b	#'0',d0			; if line isn't only numbers, FAIL!
	blo.s	COUNT_ERR
	cmp.b	#'9',d0
	bhi.s	COUNT_ERR

	sub.b	#'0',d0

	mulu	#10,d1			; make number
	add.b	d0,d1
	bra.s	.LOOP

.DONE:	move.w	d1,IgnoreCount		; save number
	beq.s	COUNT_ERR

	move.l	a0,_IgnoreBuffer	; address of line after number

ABORT_LOAD:
	tst.l	_FIB
	beq.s	.NOT1

	moveq	#DOS_FIB,d1
	move.l	_FIB,d2
	CALL	FreeDosObject,_DOSBase

.NOT1:	tst.l	_IgnoreFile
	beq.s	.NOT2

	move.l	_IgnoreFile,d1
	CALL	Close,_DOSBase

.NOT2:

NO_IGNORE:
	ENDC

;--------------------------------------------------------------------
; check if we're running AGA or not

	move.l	_GfxBase,a0
	btst	#GFXB_AA_ALICE,gb_ChipRevBits0(a0)	; AGA?
	beq.s	EXIT					; no! out!!!

	move.w	#$0,$dff1fc
	move.w	#$0,$dff106				; fix bug in V39 OS

;--------------------------------------------------------------------
; disable all commodities

	IFD	DISCX
	move.l	#MLH_SIZE,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1		; alloc mem for Cx list
	EXEC	AllocVec
	move.l	d0,_CxList
	beq.s	EXIT

	move.l	d0,a0
	NEWLIST	a0				; init Cx list

	move.l	d0,a0
	CALL	CopyBrokerList,_CxBase		; make copy of cx list

	move.l	#CXCMD_DISABLE,d7
	bsr.w	SEND_CX_COMMAND			; disable all commodities
	ENDC

;--------------------------------------------------------------------
; allocate memory for status bitmap

	move.l	#640,d0				; width
	move.l	#9,d1				; height
	move.l	d1,d6
	mulu	d0,d6				
	lsr.l	#5,d6				; longwords to allocate
	subq.l	#1,d6

	CALL	AllocRaster,_GfxBase		; allocate memory
	move.l	d0,_StatusPlane
	beq.s	EXIT				; failed!

	move.l	d0,a0
.CLR:	move.l	#0,(a0)+			; clear bitmap
	dbf	d6,.CLR

;--------------------------------------------------------------------
; init copperlist

	move.l	_StatusPlane,d0
	move.w	d0,LO1a				; plane ptrs for statusline
	swap	d0
	move.w	d0,HI1a

	move.l	#AnimA,d0			; insert cursor into copper
	move.w	d0,SLO5
	swap	d0
	move.w	d0,SHI5

	move.l	#AnimB,d0
	move.w	d0,SLO6
	swap	d0
	move.w	d0,SHI6

	move.l	#Cross,d0
	move.w	d0,SLO7
	swap	d0
	move.w	d0,SHI7

	bsr.w	READ_MOUSEPOS		; initialize mouse values
	moveq	#0,d2			; delta X
	moveq	#0,d3			; delta Y
	move.w	#0,CursorX		; Xpos
	move.w	#0,CursorY		; Ypos
	bsr.w	UPDATE_CURSOR		; update cursor to top-left

;--------------------------------------------------------------------
; setup level 3 VBLANK interrupt

	IFD	NEWINT
	bsr.w	SETUP_INTERRUPT
	ENDC

;--------------------------------------------------------------------
; setup new copperlist

	IFD	NEWCOP
	bsr.w	SETUP_COPPERLIST
	ENDC

;--------------------------------------------------------------------
; setup input-handler

	EXEC	CreateMsgPort
	move.l	d0,_MsgPort
	beq.s	EXIT

	move.l	d0,a0
	move.l	#IOSTD_SIZE,d0
	EXEC	CreateIORequest
	move.l	d0,_IORequest
	beq.s	EXIT

	lea	InputName,a0
	moveq	#0,d0
	move.l	_IORequest,a1
	moveq	#0,d1
	EXEC	OpenDevice		; open "input.device"

	IFD	NEWIPH
	bsr.w	ADD_INPUT_HANDLER	; add handler
	ENDC

;--------------------------------------------------------------------
; get this tasks structure and alloc new signal

	sub.l	a1,a1
	EXEC	FindTask
	move.l	d0,_ThisTask		; our task structure

	moveq	#-1,d0
	EXEC	AllocSignal		; allocate "any" free signal
	move.b	d0,OurSigNum
	bmi.s	EXIT			; fail!

	moveq	#0,d1
	bset	d0,d1
	move.l	d1,_OurSigSet		; make "sigset"

;--------------------------------------------------------------------

	XDEF	MAINLOOP

MAINLOOP:
	tst.w	ExitFlag
	bne.s	EXIT

	move.l	_OurSigSet,d0			; wait for signal
	or.l	#SIGBREAKF_CTRL_C,d0
	EXEC	Wait

	move.l	d0,d1
	and.l	#SIGBREAKF_CTRL_C,d1
	beq.s	NOT_CTRL_C

	move.w	#1,ExitFlag

NOT_CTRL_C:
	move.l	d0,d1
	and.l	_OurSigSet,d1			; did we get the right signal
	beq.s	NOT_RAWKEY			; no!

	bsr.w	HANDLE_RAWKEY			; yes! check key combination
	bra.s	MAINLOOP

NOT_RAWKEY:
	bra.s	MAINLOOP

;--------------------------------------------------------------------
; free all allocated resources and clean up!
;--------------------------------------------------------------------

	XDEF	EXIT

EXIT:	bsr.w	REMOVE_INPUTHANDLER

	IFD	NEWINT
	bsr.w	REMOVE_INTERRUPT		; remove out level 3 int.
	ENDC

	IFD	NEWCOP
	bsr.w	REMOVE_COPPERLIST		; give back system copper
	ENDC

	bsr.w	FREE_OUR_SIGNAL

	bsr.w	FREE_STATUS_MEM			; free status bitmap

	bsr.w	SET_OLD_CD			; set back current dir

	IFD	DISCX
	bsr.w	CLOSE_CX
	bsr.w	FREE_IGNORE_LIST		; free cxignore list
	ENDC

	bsr.w	CLOSE_DOS			; close libraries
	bsr.w	CLOSE_GFX
	bsr.w	CLOSE_INTUITION
	bsr.w	CLOSE_REQTOOLS
	bsr.w	CLOSE_IFFPARSE

	tst.l	_WBMsg
	beq.s	.NOT

	EXEC	Forbid
	move.l	_WBMsg,a1			; reply to WBMsg
	EXEC	ReplyMsg
	EXEC	Permit

.NOT:	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;--------------------------------------------------------------------

	XDEF	CLOSE_DOS

CLOSE_DOS:
	tst.l	_DOSBase
	beq.s	.NOT

	CLOSELIB _DOSBase
.NOT:	rts

	XDEF	CLOSE_GFX

CLOSE_GFX:
	tst.l	_GfxBase
	beq.s	.NOT

	CLOSELIB _GfxBase
.NOT:	rts

	XDEF	CLOSE_INTUITION

CLOSE_INTUITION:
	tst.l	_IntuitionBase
	beq.s	.NOT

	CLOSELIB _IntuitionBase
.NOT:	rts

	XDEF	CLOSE_IFFPARSE

CLOSE_IFFPARSE:
	tst.l	_IFFParseBase
	beq.s	.NOT

	CLOSELIB _IFFParseBase
.NOT:	rts

	XDEF	CLOSE_REQTOOLS

CLOSE_REQTOOLS:
	tst.l	_FileReq
	beq.s	.NOT1

	move.l	_FileReq,a1
	CALL	rtFreeRequest,_ReqToolsBase

.NOT1:	tst.l	_ReqInfo
	beq.s	.NOT2

	move.l	_ReqInfo,a1
	CALL	rtFreeRequest,_ReqToolsBase

.NOT2:	tst.l	_ReqToolsBase
	beq.s	.NOT

	CLOSELIB _ReqToolsBase
.NOT:	rts

;--------------------------------------------------------------------

	XDEF	SET_OLD_CD

SET_OLD_CD:
	tst.l	_OldCurrent
	beq.s	.NOT1

	move.l	_OldCurrent,d1
	CALL	CurrentDir,_DOSBase

.NOT1:	tst.l	_CurrentLock
	beq.s	.NOT2

	move.l	_CurrentLock,d1
	CALL	UnLock,_DOSBase
.NOT2:	rts

;--------------------------------------------------------------------

CLOSE_CX:
	IFD	DISCX
	tst.l	_CxList
	beq.s	.NOT2

	move.l	_CxList,a0
	TSTLIST	a0			; do we have a copy of cx list?
	beq.s	.FREE			; no! skip next part

	move.l	#CXCMD_ENABLE,d7
	bsr.w	SEND_CX_COMMAND		; enable all commodities

.FREE:	move.l	_CxList,a0
	CALL	FreeBrokerList,_CxBase	; free cx list

	move.l	_CxList,a1
	EXEC	FreeVec			; free our list structure
	ENDC

.NOT2:	tst.l	_CxBase
	beq.s	.NOT

	CLOSELIB _CxBase
.NOT:	rts

;--------------------------------------------------------------------

FREE_IGNORE_LIST:
	tst.l	_IgnoreList
	beq.s	.NOT

	move.l	_IgnoreList,a1
	EXEC	FreeVec
.NOT:	rts

;--------------------------------------------------------------------

SEND_CX_COMMAND:
	IFD	DISCX
	move.l	_CxList,a0
CXLOOP:
	TSTNODE	a0,a0			; get next cx node
	beq.s	SEND_EXIT		; until end of list...

	move.l	a0,-(a7)
	lea	bc_Name(a0),a0		; get its name

	bsr.s	CHECK_DISABLE
	beq.s	.NOT

	move.l	d7,d0			; command to send
	CALL	BrokerCommand,_CxBase	; send the command
.NOT:	move.l	(a7)+,a0
	bra.s	CXLOOP

SEND_EXIT:
	ENDC
	rts

;--------------------------------------------------------------------

CHECK_DISABLE:
	IFD	DISCX

	move.l	a0,a1
	move.l	_IgnoreBuffer,a2
	cmp.l	#NULL,a2		; out if there's no IgnoreList
	beq.s	IGDISABLE

	move.w	IgnoreCount,d6
	subq.w	#1,d6			; number of cx to ignore

	move.l	a2,a3
IGLOOP:	move.b	(a1)+,d0		; start comparing chars in names
	UPPER	d0			; uppercase
	move.b	(a3)+,d1
	UPPER	d1			; uppercase
	cmp.b	d0,d1
	beq.s	IGLOOP

IGEND:	tst.b	d0			; cxlist is 0 terminated
	bne.s	IGNEXT

	cmp.b	#10,d1			; _IgnoreList is LF terminated
	beq.s	IGSKIP			; done! name match -> ignore cx

IGNEXT:	move.b	(a2)+,d0		; go to next line in IgnoreList
	cmp.b	#10,d0
	bne.s	IGNEXT

	move.l	a0,a1
	move.l	a2,a3
	dbf	d6,IGLOOP		; next name, or out if at end

IGDISABLE:
	moveq	#1,d0			; send command to cx
	rts

IGSKIP:	moveq	#0,d0			; ignore cx
	ENDC
	rts

;--------------------------------------------------------------------

	XDEF	FREE_OUR_SIGNAL

FREE_OUR_SIGNAL:
	tst.l	_OurSigSet
	beq.s	.NOT

	moveq	#0,d0
	move.b	OurSigNum,d0
	EXEC	FreeSignal
.NOT:	rts

;--------------------------------------------------------------------

	XDEF	FREE_STATUS_MEM

FREE_STATUS_MEM:
	tst.l	_StatusPlane
	beq.s	.OUT

	move.l	_StatusPlane,a0
	move.l	#640,d0
	move.l	#9,d1
	CALL	FreeRaster,_GfxBase		; free!!
.OUT:	rts

;--------------------------------------------------------------------

	XDEF	SETUP_COPPERLIST

SETUP_COPPERLIST:
	IFD	NEWCOP
	tst.b	COP
	bne.s	.NOT

	CALL	WaitBlit,_GfxBase		; wait for blitter to finish
	CALL	OwnBlitter,_GfxBase		; take control over blitter

	sub.l	a1,a1
	CALL	LoadView,_GfxBase		; reset HW registers & view
	CALL	WaitTOF,_GfxBase
	CALL	WaitTOF,_GfxBase		; wait 2 frames
	
	move.l	#Copper,$dff080			; our new copperlist
	move.w	#0,$dff088			; start copperlist

	move.w	#$0020,$dff1dc			; use PAL mode

	move.b	#1,COP				; we have copper!
.NOT:	
	ENDC
	rts

	XDEF	REMOVE_COPPERLIST

REMOVE_COPPERLIST:
	IFD	NEWCOP
	tst.b	COP
	beq.s	.NOT

	CALL	WaitBlit,_GfxBase
	CALL	DisownBlitter,_GfxBase		; give system blitter back
	
	move.l	_IntuitionBase,a1
	lea	ib_ViewLord(a1),a1
	CALL	LoadView,_GfxBase		; setup system view
	CALL	WaitTOF,_GfxBase
	CALL	WaitTOF,_GfxBase		; wait 2 frames (if interlace)

	move.l	_GfxBase,a0
	move.l	gb_copinit(a0),$dff080		; system copper
	move.w	#0,$dff088			; start it

	move.b	#0,COP				; system has copper

	move.l	_IntuitionBase,a0
	move.l	ib_FirstScreen(a0),a0
	lea	sc_ViewPort(a0),a0
	CALL	GetVPModeID,_GfxBase		; what mode is system running?
	and.l	#MONITOR_ID_MASK,d0
	beq.s	.NOT				; neither PAL nor NTSC

	cmp.l	#PAL_MONITOR_ID,d0
	beq.s	.PAL

	move.w	#$0000,$dff1dc			; set to NTSC
	bra.s	.NOT

.PAL:	move.w	#$0020,$dff1dc			; set to PAL
.NOT:
	ENDC
	rts

;--------------------------------------------------------------------

	XDEF	REMOVE_INPUTHANDLER

REMOVE_INPUTHANDLER:
	IFD	NEWIPH
	bsr.w	REM_INPUT_HANDLER
	ENDC

	tst.l	_IORequest
	beq.s	.NOT

	move.l	_IORequest,a1
	EXEC	CloseDevice

	move.l	_IORequest,a0
	EXEC	DeleteIORequest

.NOT:	tst.l	_MsgPort
	beq.s	.NOT2

	move.l	_MsgPort,a0
	EXEC	DeleteMsgPort
.NOT2:	rts

	XDEF	ADD_INPUT_HANDLER

ADD_INPUT_HANDLER:
	tst.b	INP
	bne.s	.NOT

	move.l	_IORequest,a1
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	move.l	#HandlerStruct,IO_DATA(a1)
	EXEC	DoIO

	move.b	#1,INP
.NOT:	rts

	XDEF	REM_INPUT_HANDLER

REM_INPUT_HANDLER:
	tst.b	INP
	beq.s	.NOT

	move.l	_IORequest,a1
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	move.l	#HandlerStruct,IO_DATA(a1)
	EXEC	DoIO

	move.b	#0,INP
.NOT:	rts

;--------------------------------------------------------------------

	XDEF	SETUP_INTERRUPT

SETUP_INTERRUPT:
	IFD	NEWINT
	tst.b	INT
	bne.s	.NOT

	moveq	#INTB_VERTB,d0			; vertical blank interrupt
	lea	$dff000,a0
	lea	Level3Struct,a1			; interrupt structure
	EXEC	AddIntServer			; add it!!

	move.b	#1,INT

.NOT:
	ENDC
	rts

	XDEF	REMOVE_INTERRUPT

REMOVE_INTERRUPT:
	IFD	NEWINT
	tst.b	INT
	beq.s	.NOT

	moveq	#INTB_VERTB,d0
	lea	Level3Struct,a1
	EXEC	RemIntServer

	move.b	#0,INT
.NOT:
	ENDC
	rts

;--------------------------------------------------------------------
; code to run in vertical blanking interrupt
;--------------------------------------------------------------------

	XDEF	INTERRUPT_CODE

INTERRUPT_CODE:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr.w	READ_MOUSEPOS
	bsr.w	ANIMATIONS

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

	XDEF	READ_MOUSEPOS

READ_MOUSEPOS:
        moveq   #0,d0
        moveq   #0,d1
        moveq   #0,d2
        moveq   #0,d3

        move.w  $dff00a,d0		; hardware mouse position
        move.w  d0,d1

        and.w   #$00ff,d0
        and.w   #$ff00,d1
        lsr.w   #8,d1
 
	move.b	LastX,d2		; compare to last position
	sub.b	d0,d2
	move.b	d0,LastX
	move.b	LastY,d3
	sub.b	d1,d3
	move.b	d1,LastY

	ext.w	d2			; extend deltas to word size
	ext.w	d3

	move.w	d2,d4
	add.w	d3,d4
	beq.s	NO_SPRITE_UPDATE	; delta X + delta Y = 0
					; => mouse not moved!!

	XDEF	UPDATE_CURSOR

UPDATE_CURSOR:				; d2 and d3 should contain the
	move.w	CursorX,d0		; deltaX and deltaY.
	move.w	CursorY,d1

	sub.w	d2,d0			; new mouse position
	sub.w	d3,d1

	move.w	#319,d2			; can have some kind of screen
	move.w	#255,d3			; checking scheme here


	move.w	BrushSizeX,d4		; brush x/y size
	subq.w	#1,d4
	lsl.w	#4,d4
	move.w	BrushSizeY,d5
	subq.w	#1,d5
	lsl.w	#4,d5

	tst.w	d0
	bge.s	OK_LX			; left boundry OK

	moveq	#0,d0			; x pos = 0
	bra.s	CHECK_LY

OK_LX:
	move.w	d0,d6			; copy of x pos
	add.w	d4,d6			; xpos+brushsizex
	cmp.w	d2,d6			; check right boundry
	ble.s	CHECK_LY		; right boundy OK

	move.w	d2,d0			; d0=d2-brush x-size
	sub.w	d4,d0			; make new xpos

CHECK_LY:
	tst.w	d1
	bge.s	OK_TY			; top boundry OK

	moveq	#0,d1			; y pos = 0
	bra.s	NEW_POSITIONS

OK_TY:	move.w	d1,d6
	add.w	d5,d6
	cmp.w	d3,d6
	ble.s	NEW_POSITIONS		; Y bottom OK

	move.w	d3,d1			; d1=d3-brush y-size
	sub.w	d5,d1

NEW_POSITIONS:
	move.w	d0,CursorX		; save new x/y position
	move.w	d1,CursorY

	lea	Cross,a0
	move.w	d0,d6
	sub.w	#3,d0
	move.w	d1,d7
	sub.w	#3,d1
	moveq	#7,d2
	bsr.w	SETUP_SPRITE		; update "cross"

	and.w	#-16,d6			; cursor only moves every 16th pixel
	and.w	#-16,d7

	lea	AnimA,a0
	move.w	d6,d0
	move.w	d7,d1
	move.w	#16,d2
	bsr.w	SETUP_SPRITE		; update "cursor A"

	lea	AnimB,a0
	move.w	d6,d0
	move.w	BrushSizeX,d6
	subq.w	#1,d6
	lsl.w	#4,d6
	add.w	d6,d0
	move.w	d7,d1
	move.w	BrushSizeY,d6
	subq.w	#1,d6
	lsl.w	#4,d6
	add.w	d6,d1
	move.w	#16,d2
	bsr.w	SETUP_SPRITE		; update "cursor B"

NO_SPRITE_UPDATE:
	rts

;--------------------------------------------------------------------

	XDEF	ANIMATIONS

ANIMATIONS:
	subq.w	#1,AnimDelay
	bne.s	.NO_ANIM

        move.w  #ANIMSPEED,AnimDelay

        bsr.w   CURSOR_ANIM		; new frame every ANIMSPEED frames
 
.NO_ANIM:
        rts

	XDEF	CURSOR_ANIM

CURSOR_ANIM:
        move.l  AnimPtr,a0		; pointer to anim table

.S:     move.l  (a0)+,d0		; sprite A
        move.l  (a0)+,d1		; sprite B
        bne.s   .OK

        lea     AnimTable,a0		; end of anim, start over!
        bra.s   .S

.OK:    move.l  a0,AnimPtr		; save ptr to next anim frame

        lea     AnimA+4,a0		; copy animframe into sprite
        lea     AnimB+4,a1 
        move.l  d0,a2
        move.l  d1,a3
        move.w  #15,d7
.LOOP:  move.w  (a2)+,(a0)
        lea     4(a0),a0
        move.w  (a3)+,(a1)
        lea     4(a1),a1
        dbf     d7,.LOOP
        rts

;--------------------------------------------------------------------

	XDEF	SETUP_SPRITE

SETUP_SPRITE:				; a0=control words
					; d0=xpos
					; d1=ypos
					; d2=sprite height

        move.l  #0,(a0)			; clear control words

        add.w   #$34,d1			; add top of editor screen (y-start)
        move.b  d1,(a0)			; insert y-start

        btst    #8,d1			; are we in the PAL area?
        beq.s   .NO_YSTART		; no!

        bset    #2,3(a0)		; set Y hstart bit

.NO_YSTART:
        add.w   d2,d1			; add height
        move.b  d1,2(a0)		; set sprite stop value
        btst    #8,d1			; test if in PAL area
        beq.s   .NO_YSTOP		; nope!

        bset    #1,3(a0)		; set Y hstop value

.NO_YSTOP:
        add.w   #$80,d0			; add X start value
        lsr.w   #1,d0			; xstart needs even value
        bcc.s   .NO_ODD			; is xpos odd?

        bset    #0,3(a0)		; yes! set odd bit

.NO_ODD:
        move.b  d0,1(a0)		; set xpos value in ctrl word
	rts

;--------------------------------------------------------------------
; code to run if we recieve an input event
;--------------------------------------------------------------------

	XDEF	HANDLER_CODE

HANDLER_CODE:
	move.l	a2,-(a7)

PROCESS_NEXT:
	sub.l	a2,a2
	move.l	a0,a1

	moveq	#0,d0
	move.b	ie_Class(a1),d0			; get inputevent class

	cmp.b	#IECLASS_RAWKEY,d0
	beq.s	HANDLE_KEYBOARD
	cmp.b	#IECLASS_RAWMOUSE,d0
	beq.s	HANDLE_MOUSE

	move.l	a1,a2

NEXT_EVENT:
	move.l	(a1),a1
	move.l	a1,d0
	bne.s	PROCESS_NEXT

NO_HANDLE:
	move.l	a0,d0
	move.l	(a7)+,a2

EXIT_HANDLER:
	rts

UNCHAIN:			; unchains event after we've used it,
	move.l	a2,d0		; so the rest of the system doesn't see it
	bne.s	UNCHAIN2
	move.l	(a1),a0
	rts

UNCHAIN2:
	move.l	(a1),(a2)
	rts

;--------------------------------------------------------------------

	XDEF	HANDLE_KEYBOARD

HANDLE_KEYBOARD:
        moveq   #0,d0
        moveq   #0,d1

        move.w  ie_Code(a1),d0
        move.b  d0,KeyCode			; get key
        move.w  ie_Qualifier(a1),d1
        and.w   #$1ff,d1
        move.w  d1,KeyQualifier			; ...and qualifier

        movem.l a0-a2,-(a7)
        move.l  _ThisTask,a1
        move.l  _OurSigSet,d0
        EXEC    Signal				; then signal task to
        movem.l (a7)+,a0-a2			; check this key
 
	IFD	UNC
	bsr.w	UNCHAIN
	ENDC
	bra.s	NEXT_EVENT

;--------------------------------------------------------------------

	XDEF	HANDLE_MOUSE

HANDLE_MOUSE:
	movem.l	a0-a2,-(a7)



	movem.l	(a7)+,a0-a2
	IFD	UNC
	bsr.w	UNCHAIN
	ENDC
	bra.s	NEXT_EVENT

;--------------------------------------------------------------------

	XDEF	HANDLE_RAWKEY

HANDLE_RAWKEY:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

;--------------------------------------------------------------------
; ralt + ESC                                                     EXIT
;--------------------------------------------------------------------

	KEY	RAWKEY_ESC,IEQUALIFIER_RALT
	beq.s	NOT_COMMAND_EXIT

;	WBFRONT
;	lea	TXT_Exit,a1			; ask if user wants to exit
;	lea	GAD_YesNo,a2
;	move.l	_ReqInfo,a3
;	sub.l	a4,a4
;	lea	InfoTags,a0
;	CALL	rtEZRequestA,_ReqToolsBase
;	tst.l	d0
;	beq.s	.NOT

	move.w	#1,ExitFlag			; yes! set "exitflag"
	rts

;.NOT:	AMESFRONT
;	rts

;--------------------------------------------------------------------
; rcommand + m                                     WORKBENCH TO FRONT
;--------------------------------------------------------------------

NOT_COMMAND_EXIT:
	KEY	RAWKEY_M,IEQUALIFIER_LCOMMAND
	beq.s	NOT_COMMAND_WBFRONT

	WBFRONT

	sub.l	a0,a0
	CALL	LockPubScreen,_IntuitionBase	; get default pub screen
	move.l	d0,_PubScr
	beq.s	AFRONT

	move.l	d0,a0
	move.l	sc_Font(a0),a0			; ...and its font

	lea	WTitleIT,a1
	move.l	a0,it_ITextFont(a1)		; use this font in title

	move.l	_PubScr,a0
	moveq	#0,d0
	move.b	sc_BarHeight(a0),d0		; get titlebar height
	move.l	d0,d7
	addq.w	#1,d7

	SETTAG	#AMESWindow,WA_Height,d7	; ...and set in new window

	sub.l	a0,a0
	move.l	_PubScr,a1
	CALL	UnlockPubScreen,_IntuitionBase	; unlock pub screen
	move.l	#0,_PubScr

	lea	WTitleIT,a0
	CALL	IntuiTextLength,_IntuitionBase	; calc window width
	move.l	d0,d7

	add.w	#19+23+24,d7			; add for system gadgets
	SETTAG	#AMESWindow,WA_Width,d7

	sub.l	a0,a0
	lea	AMESWindow,a1			; open window
	CALL	OpenWindowTagList,_IntuitionBase
	move.l	d0,_Window
	beq.s	AFRONT

	move.l	d0,a0
	move.l	wd_UserPort(a0),_Userport

	moveq	#0,d7

.WAIT:	tst.w	d7				; d7=close flag, set=>OUT!
	bne.s	.CLOSE

	move.l	_Userport,a0			; wait for user to close
	EXEC	WaitPort			; window

.MSG:	move.l	_Userport,a0
	EXEC	GetMsg
	tst.l	d0
	beq.s	.WAIT

	move.l	d0,a0
	move.l	im_Class(a0),d0
	cmp.l	#IDCMP_CLOSEWINDOW,d0		; did he close it?
	bne.s	.REPLY

	moveq	#1,d7				; yes!

.REPLY:	move.l	a0,a1
	EXEC	ReplyMsg
	bra.s	.MSG

.CLOSE:	move.l	_Window,a0			; close window...
	CALL	CloseWindow,_IntuitionBase
	move.l	#0,_Window
	move.l	#0,_Userport

AFRONT:	AMESFRONT				; ...and return to AMES
	rts

;--------------------------------------------------------------------
; F1                                              LOAD/FRONT SCREEN 0
;--------------------------------------------------------------------

NOT_COMMAND_WBFRONT:
	KEY	RAWKEY_F1,NULL
	beq.s	NOT_COMMAND_BRK0

	moveq	#SC_BRK0,d7
	bsr.w	SCREEN_TO_FRONT
	rts

;--------------------------------------------------------------------

NOT_COMMAND_BRK0:
	rts

;--------------------------------------------------------------------

SCREEN_TO_FRONT:
	lea	ScreenPtrs,a0
	tst.l	(a0,d7.w*4)
	bne.s	PUT_TO_FRONT

	WBFRONT

	move.b	#1,UseReq

        move.l  _FileReq,a1
        lea     Filename,a2
        lea     AMESName,a3
        lea     CenterTags,a0
        CALL    rtFileRequestA,_ReqToolsBase    ; setup filerequester
        tst.l   d0
        beq.s   IFF_FAIL_CANCEL 

        move.l  _FileReq,a0
        move.l  rtfi_Dir(a0),a0
        tst.b   (a0)
        beq.s   LOAD_IFF_REQ  

        move.l  _CurrentLock,d1
        beq.s   .LOCK

        CALL    UnLock,_DOSBase                 ; unlock last current dir
        move.l  #0,_CurrentLock

.LOCK:  move.l  _FileReq,a0
        move.l  rtfi_Dir(a0),d1
        move.l  #ACCESS_READ,d2
        CALL    Lock,_DOSBase
        move.l  d0,_CurrentLock
        beq.s   IFF_FAIL_PATH

        move.l  d0,d1
        CALL    CurrentDir,_DOSBase             ; move to chosen directory

        tst.l   _OldCurrent
        bne.s   LOAD_IFF_REQ     

	move.l	d0,_OldCurrent

LOAD_IFF:
        move.b  #0,UseReq               ; do not post errors!
                                        ; d7=screen number
                                        ; If it's jumped directly here,
                                        ; filename should also contain path.

LOAD_IFF_REQ:
        move.l  #0,_StoredBMHD
        move.l  #0,_StoredCMAP
        move.l  #0,_StoredBODY

        CALL    AllocIFF,_IFFParseBase
        move.l  d0,_iff                         ; allocate IFF handle
        beq.s   IFF_FAIL_ALLOC

        move.l  #Filename,d1
        move.l  #MODE_OLDFILE,d2
        CALL    Open,_DOSBase                   ; IFF file to setup
        tst.l   d0
        beq.s   IFF_FAIL_OPEN

        move.l  _iff,a0
        move.l  d0,iff_Stream(a0)
        CALL    InitIFFasDOS,_IFFParseBase      ; init handle for file
 
        move.l  _iff,a0
        move.l  #IFFF_READ,d0
        CALL    OpenIFF,_IFFParseBase           ; open IFF for reading
        tst.l   d0
        bne.s   IFF_FAIL_OPEN

        move.l  _iff,a0
        move.l  #'ILBM',d0
        move.l  #'BMHD',d1
        CALL    PropChunk,_IFFParseBase         ; push ILBM,BMHD
        tst.l   d0
        bne.s   IFF_FAIL_OPEN
 
        move.l  _iff,a0
        move.l  #'ILBM',d0
        move.l  #'CMAP',d1
        CALL    PropChunk,_IFFParseBase         ; push ILBM,CMAP
        tst.l   d0
        bne.s   IFF_FAIL_OPEN

        move.l  _iff,a0
        move.l  #'ILBM',d0
        move.l  #'BODY',d1
        CALL    StopChunk,_IFFParseBase
        tst.l   d0
        bne.s   IFF_FAIL_OPEN
 
        move.l  _iff,a0
        move.l  #IFFPARSE_SCAN,d0
        CALL    ParseIFF,_IFFParseBase          ; parse IFF and store pushed
        tst.l   d0                              ; properties
        beq.s   PARSE_OK

        cmp.l   #IFFERR_EOF,d0                  ; "end of file"=BODY not found
        beq.s   IFF_FAIL_BODY
        bra.s   IFF_FAIL_OPEN

PARSE_OK:
        move.l  _iff,a0
        move.l  #'ILBM',d0
        move.l  #'BMHD',d1
        CALL    FindProp,_IFFParseBase          ; find stored properties
        tst.l   d0
        beq.s   IFF_FAIL_BMHD
 
        move.l  d0,a0
        move.l  spr_Data(a0),a0                 ; get property data.
        move.l  a0,_StoredBMHD                  ; in this case BMHD

        moveq   #0,d0
        move.b  bmh_nPlanes(a0),d0
        tst.w   SysDepth                        ; all screen has to have the
        beq.s   .LOAD                           ; same depth as the first
                                                ; loaded screen

        cmp.w   SysDepth,d0
        bne.w   IFF_FAIL_DEPTH

.LOAD:  move.l  _iff,a0
        move.l  #'ILBM',d0
        move.l  #'CMAP',d1
        CALL    FindProp,_IFFParseBase
        tst.l   d0
        beq.s   IFF_FAIL_CMAP

        move.l  d0,a0
        move.l  spr_Data(a0),a0
        move.l  a0,_StoredCMAP                  ; IFF pictures CMAP

        move.l  _iff,a0
        CALL    CurrentChunk,_IFFParseBase      ; Parser has stopped at
        tst.l   d0                              ; BODY. GET IT!!!
        beq.s   IFF_FAIL_OPEN

        move.l  d0,a0
        move.l  cn_Size(a0),d0
        move.l  d0,d6
        move.l  d6,BODYSize
        move.l  #MEMF_ANY!MEMF_CLEAR,d1         ; allocate mem for BODY
        EXEC    AllocVec
        move.l  d0,_StoredBODY  
        beq.s   IFF_FAIL_OPEN

        move.l  _iff,a0
        move.l  d0,a1
        move.l  d6,d0
        CALL    ReadChunkBytes,_IFFParseBase    ; read it!!!
        cmp.l   d6,d0                           ; check if we read all of it
        bne.s   IFF_FAIL_RBODY


	bsr.w	CLEANUP_LOADER

	AMESFRONT
	moveq	#1,d0
	rts

;--------------------------------------------------------------------

IFF_FAIL_CANCEL:
	bsr.w	CLEANUP_LOADER

	tst.b	UseReq
	beq.s	.NOT

	AMESFRONT
.NOT:	moveq	#0,d0
	rts

IFF_FAIL_PATH:			; unknown path name
        lea     ERR_Path,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_ALLOC:
	lea	ERR_AllocIFF,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_OPEN:
	lea	ERR_OpenIFF,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_BODY:
	lea	ERR_NoBODY,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_BMHD:
	lea	ERR_NoBMHD,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_CMAP:
	lea	ERR_NoCMAP,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_DEPTH:
	lea	ERR_IFFDepth,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_RBODY:
	lea	ERR_ReadBODY,a1
        bra.s   ERROR_REQUEST

IFF_FAIL_MEM:
        lea     ERR_AllocMem,a1         ; Not enough memory
        bra.s   ERROR_REQUEST

IFF_FAIL_TODEEP:
        lea     ERR_IFFToDeep,a1        ; to many planes
        bra.s   ERROR_REQUEST

;--------------------------------------------------------------------

ERROR_REQUEST:                          ; display error requester
        tst.b   UseReq
        beq.s   .NOT

        lea     GAD_Continue,a2
        move.l  _ReqInfo,a3
        sub.l   a4,a4
        lea     InfoTags,a0
        CALL    rtEZRequestA,_ReqToolsBase

        AMESFRONT

.NOT:   bsr.s   CLEANUP_LOADER
;       bsr.s   FREE_SCREEN
        moveq   #0,d0
        rts        

;--------------------------------------------------------------------

CLEANUP_LOADER:
        tst.l   _iff
        beq.s   .NOIFF

        move.l  _iff,a0
        CALL    CloseIFF,_IFFParseBase          ; close IFF handle

        move.l  _iff,a0
        move.l  iff_Stream(a0),d1
        beq.s   .NFILE

        CALL    Close,_DOSBase                  ; close IFF file

.NFILE: move.l  _iff,a0
        CALL    FreeIFF,_IFFParseBase           ; free IFF structure
        move.l  #0,_iff

        tst.l   _StoredBODY
        beq.s   .NOIFF

        move.l  _StoredBODY,a1                  ; free alloc'ed BODY mem
        EXEC    FreeVec
        move.l  #0,_StoredBODY
.NOIFF: rts
 
;--------------------------------------------------------------------

PUT_TO_FRONT:
	rts

;--------------------------------------------------------------------

CHECK_RAWKEY:                   ; d1=keyCode, d2=qualifier(s) to check

        move.b  KeyCode,d0      ; actual key pressed
        cmp.b   d1,d0           ; is this the one we're searching for?
        bne.s   .FAIL           ; no!

        move.w  KeyQualifier,d1 ; actual qualifier(s) pressed

        tst.w   d2              ; looking for just key, no qualifiers
        bne.s   .CHECK

        tst.w   d1              ; did we get no qualifers?
        beq.s   .OK             ; yes!

.CHECK: and.w   d2,d1           ; is/are this/these the right one(s)?
        beq.s   .FAIL           ; no!

.OK:    moveq   #1,d0           ; yupp!!
        rts

.FAIL:	moveq	#0,d0
	rts

;--------------------------------------------------------------------

	XDEF	WRITE_STATUSLINE

WRITE_STATUSLINE:
	CALL	WaitTOF,_GfxBase		; top of frame

	moveq	#0,d0
	lea	StatusLine,a0			; text
	lea	FontAddresses,a1		; char offsets in font
	move.l	_StatusPlane,a2			; status plane
.S:	move.b	(a0)+,d0			; get next char
	beq.s	.DONE				; until zero

	sub.b	#32,d0				; sub the 32 first chars

	lea	Font,a3
	add.w	(a1,d0.w*2),a3			; get char address

	move.b	(a3),(a2)			; copy to screen
        move.b  40(a3),80(a2)
        move.b  80(a3),160(a2)
        move.b  120(a3),240(a2)
        move.b  160(a3),320(a2)
        move.b  200(a3),400(a2)
        move.b  240(a3),480(a2)
        move.b  280(a3),560(a2)

	lea	1(a2),a2			; move one char right
	bra.s	.S				; next!
.DONE:	rts

;--------------------------------------------------------------------

	section	"AMESFAST",data

COP:		dc.b	0			; copper installed or not
INT:		dc.b	0			; interrupt installed or not
INP:		dc.b	0			; input handler installed or not
		even

ExitFlag:	dc.w	0			; set if AMES should exit

_OldCurrent:	dc.l	0			; original dir of shell
_CurrentLock:	dc.l	0			; user selected path

_ReqInfo:	dc.l	0			; requester
_FileReq:	dc.l	0			; filerequester

_WBMsg:		dc.l	0
_CxList:	dc.l	0			; list of commodities
_IgnoreFile:	dc.l	0			; ignorefile lock
_IgnoreList:	dc.l	0			; commodities to ignore
_IgnoreBuffer:	dc.l	0			; second line of _IgnoreList
IgnoreCount:	dc.w	0			; no of names in list
_FIB:		dc.l	0			; FileInfoBlock

IgnoreFilename:	dc.b	"AMES:AMES.cxignore",0	; commoditiy ignore file
		cnop	0,2

_MsgPort:	dc.l	0			; inputhandler msgport
_IORequest:	dc.l	0			; and ioreqeust

_ThisTask:	dc.l	0
_OurSigSet:	dc.l	0			; _thistasks sigset
OurSigNum:	dc.b	0			; bit number
		even

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
_IntuitionBase:	dc.l	0
_CxBase:	dc.l	0
_ReqToolsBase:	dc.l	0
_IFFParseBase:	dc.l	0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
IntuitionName:	dc.b	"intuition.library",0
CxName:		dc.b	"commodities.library",0
ReqToolsName:	dc.b	"reqtools.library",0
IFFParseName:	dc.b	"iffparse.library",0
InputName:	dc.b	"input.device",0
		dc.b	"$VER: "
		AMESNAME
		dc.b	" "
		dc.b	"by Morten Amundsen "
		AMESDATE
		dc.b	10,13,0
AMESName:	AMESNAME
		dc.b	0
		even

Level3Struct:	dc.l	0,0			; interrupt structure
		dc.b	NT_INTERRUPT
		dc.b	127			; priority
		dc.l	AMESName
		dc.l	0
		dc.l	INTERRUPT_CODE		; code to run in interrupt

HandlerStruct:	dc.l	0,0			; input handler structure
		dc.b	0,64
		dc.l	AMESName
		dc.l	0
		dc.l	HANDLER_CODE		; input handler code

;--------------------------------------------------------------------

_PubScr:		dc.l	0
_Window:	dc.l	0
_Userport:	dc.l	0

AMESWindow:	dc.l	WA_Top,0
		dc.l	WA_Left,0
		dc.l	WA_Width,0
		dc.l	WA_Height,0
		dc.l	WA_Title,WinTitle
		dc.l	WA_DetailPen,0
		dc.l	WA_BlockPen,1
		dc.l	WA_DragBar,TRUE
		dc.l	WA_CloseGadget,TRUE
		dc.l	WA_DepthGadget,TRUE
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW
		dc.l	TAG_DONE

WTitleIT:	dc.b	0,0
		dc.b	0,0
		dc.w	0,0
		dc.l	0
		dc.l	WinTitle
		dc.l	0

WinTitle:	AMESNAME
		dc.b	": Close to return!"
		dc.b	0
		even

;--------------------------------------------------------------------

InfoTags:	dc.l	RT_ReqPos,REQPOS_CENTERSCR
		dc.l	RTEZ_ReqTitle,AMESName
		dc.l	TAG_DONE

TXT_Exit:	dc.b	"Do you really want to quit?",0
TXT_Sure:	dc.b	"Clear all screens!",10,"Are you sure?",0
GAD_YesNo:	dc.b	"Yes|No",0

ERR_Path:	dc.b	"Error! Unknown path!",0
ERR_AllocIFF:	dc.b	"Error! Unable to allocate IFF!",0
ERR_OpenIFF:	dc.b	"Error! Unable to open IFF file!",0
ERR_NoBMHD:	dc.b	"Error! Bitmap Header (BMHD) of IFF not found!",0
ERR_NoCMAP:	dc.b	"Error! Colormap (CMAP) of IFF not found!",0
ERR_NoBODY:	dc.b	"Error! BODY of IFF not found!",0
ERR_ReadBODY:	dc.b	"Error! Unable to read BODY!",0
ERR_AllocMem:	dc.b	"Error! Not enough memory for IFF!",0
ERR_IFFToDeep:	dc.b	"Error! IFF can contain max 8 planes!",0
ERR_IFFDepth:	dc.b	"Error! All pictures has to have the same depth!",0
ERR_MemExit:	dc.b	"Error! Critically low on memory! Terminating!",0
GAD_Continue:	dc.b	"Continue",0
		even

;--------------------------------------------------------------------

UseReq:		dc.b	0			; use error requsters?
		even

	XDEF	_iff
	XDEF	_StoredBMHD
	XDEF	_StoredCMAP
	XDEF	_StoredBODY
	XDEF	_LocalBODY

_iff:		dc.l	0			; IFF handle
_StoredBMHD:	dc.l	0			; address of BitmapHader
_StoredCMAP:	dc.l	0			; address of Colormap
_StoredBODY:	dc.l	0			; address of IFF body
_LocalBODY:	dc.l	0			; LocalContextItem BODY
BODYSize:	dc.l	0			; size of BODY in bytes

CenterTags:	dc.l	RT_ReqPos,REQPOS_CENTERSCR
		dc.l	TAG_DONE

Filename:	dc.b	"AMES:AMESLogo.iff",0
		dcb.b	90,0			; from filerequester

;--------------------------------------------------------------------
 
KeyQualifier:	dc.w	0			; and its qualifier
KeyCode:	dc.b	0			; key pressed
		even

;--------------------------------------------------------------------
; status line stuff (offset table and text)

	XDEF	_StatusPlane

_StatusPlane:	dc.l	0		; bitplane pointer

FontAddresses:  dc.w    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
                dc.w    17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
                dc.w    33,34,35,36,37,38
                dc.w    400,401,402,403,404,405,406,407,408,409,410,411,412
                dc.w    413,414,415,416
                dc.w    417,418,419,420,421,422,423,424,425,426,427,428,429
                dc.w    430,431,432
                dc.w    433,434,435,436,437,438
                dc.w    800,801,802,803,804,805,806,807,808,809,810,811,812
                dc.w    813,814,815,816
                dc.w    817,818,819,820,821,822,823,824,825,826,827,828,829
                dc.w    830,831,832
                dc.w    833,834,835,836,837,838
                blk.w   139,0

StatusLine:	dc.b	"X:00 Y:00"		; (9) posisjon i current scr
		dc.b	" "			; (1)
		dc.b	"SX:00 SY:00"		; (11) posisjon i map
		dc.b	" "			; (1)
		dc.b	"B:0 0000 C:0 A:00"	; (17) brick, code og argument
		dc.b	" "			; (1)
		dc.b	"PC:0 PA:00"		; (10) preset code og argument
		dc.b	" "			; (1)
STAT_Scr:	dc.b	" "
STAT_Depth:	dc.b	" "
		dc.b	"----"			; (6) curr scr, depth + flags
		dc.b	" "			; (1) -> 58
		dc.b	'"'			; (1)
STAT_MapName:	dc.b	"                    "	; (20) filename
		dc.b	'"'			; (1)
		dc.b	0
		even

;--------------------------------------------------------------------

LastX:		dc.b	0			; used internally in
LastY:		dc.b	0			; mouse routine for deltas

CursorX:	dc.w	0			; x/y pos of cursor
CursorY:	dc.w	0

AnimDelay:	dc.w	ANIMSPEED

AnimPtr:        dc.l    AnimTable
AnimTable:      dc.l    AnimA1,AnimB1
                dc.l    AnimA2,AnimB2
                dc.l    AnimA3,AnimB3
                dc.l    AnimA4,AnimB4
                dc.l    AnimA5,AnimB5
                dc.l    0,0

;--------------------------------------------------------------------

BrushSizeX:	dc.w	1			; size of brush
BrushSizeY:	dc.w	1			; 1x1 = smallest

;--------------------------------------------------------------------

LastID:		dc.b	-1
CurrID:		dc.b	0

IDNames:	dc.b	"E0123456789"
		even

SysDepth:	dc.w	0

	XDEF	CurrStruct

CurrStruct:	dc.l	0

	XDEF	ScreenPtrs

ScreenPtrs:	dcb.l	SC_NOSCREENS,0		; ptr to screen structs

CopperCols:     dc.l    CH0+2,CL0+2
                dc.l    CH32+2,CL32+2
                dc.l    CH64+2,CL64+2
                dc.l    CH96+2,CL96+2
                dc.l    CH128+2,CL128+2
                dc.l    CH160+2,CL160+2
                dc.l    CH192+2,CL192+2
                dc.l    CH224+2,CL224+2
 
;--------------------------------------------------------------------

	section	"AMESCHIP",data_c

Copper:
	dc.w	$0096,$0020
	dc.w	$008E,$2681,$0090,$36c1
	dc.w	$0092,$003c,$0094,$00D4
	dc.w	$0100,$0001,$0102,$0000,$0104,$0220
	dc.w	$0108,$0000
	dc.w	$0106,$0002
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0106,$0202
	dc.w	$0180,$0000,$0182,$0fff

	dc.w	$0106,$2002
CH32:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
	dc.w	$0106,$2202
CL32:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$0106,$4002
CH64:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
	dc.w	$0106,$4202
CL64:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$0106,$6002
CH96:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
	dc.w	$0106,$6202
CL96:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$0106,$8002
CH128:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
	dc.w	$0106,$8202
CL128:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$0106,$a002
CH160:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
	dc.w	$0106,$a202
CL160:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$0106,$c002
CH192:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
	dc.w	$0106,$c202
CL192:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$0106,$e002
CH224:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
SprCH:	dc.w	$01a0,$0000,$01a2,$0fff,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0fff,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0fff,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0fff,$01bc,$0000,$01be,$0000
	dc.w	$0106,$e202
CL224:	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
SprCL:	dc.w	$01a0,$0000,$01a2,$0fff,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0fff,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0fff,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0fff,$01bc,$0000,$01be,$0000

	dc.w	$01fc,$0000,$010c,$00ff

	dc.w	$0120
SHI0:	dc.w	$0000
	dc.w	$0122
SLO0:	dc.w	$0000
	dc.w	$0124
SHI1:	dc.w	$0000
	dc.w	$0126
SLO1:	dc.w	$0000
	dc.w	$0128
SHI2:	dc.w	$0000
	dc.w	$012A
SLO2:	dc.w	$0000
	dc.w	$012C
SHI3:	dc.w	$0000
	dc.w	$012E
SLO3:	dc.w	$0000
	dc.w	$0130
SHI4:	dc.w	$0000
	dc.w	$0132
SLO4:	dc.w	$0000
	dc.w	$0134
SHI5:	dc.w	$0000
	dc.w	$0136
SLO5:	dc.w	$0000
	dc.w	$0138
SHI6:	dc.w	$0000
	dc.w	$013A
SLO6:	dc.w	$0000
	dc.w	$013C
SHI7:	dc.w	$0000
	dc.w	$013E
SLO7:	dc.w	$0000

	dc.w	$00E0
HI1a:	dc.w	$0000
	dc.w	$00E2
LO1a:	dc.w	$0000

	dc.w	$2601,$ff00
	dc.w	$0106,$0002,$0180,$0b00,$0106,$0202,$0180,$0000
	dc.w	$2701,$ff00,$0100,$9201
	dc.w	$0106,$0002,$0180,$0900,$0106,$0202,$0180,$0000
	dc.w	$3001,$ff00,$0100,$0000
	dc.w	$0106,$0002,$0180,$0700,$0106,$0202,$0180,$0000
	dc.w	$3101,$ff00
	dc.w	$0106,$0002,$0180,$0000,$0106,$0202,$0180,$0000

	dc.w	$0092,$0038,$0094,$00D0
	dc.w	$01fc,$0000
	dc.w	$0108
MOD0:	dc.w	$0000
	dc.w	$010a
MOD1:	dc.w	$0000

	dc.w	$00e0
HI0:	dc.w	$0000
	dc.w	$00e2
LO0:	dc.w	$0000
	dc.w	$00e4
HI1:	dc.w	$0000
	dc.w	$00e6
LO1:	dc.w	$0000
	dc.w	$00e8
HI2:	dc.w	$0000
	dc.w	$00ea
LO2:	dc.w	$0000
	dc.w	$00ec
HI3:	dc.w	$0000
	dc.w	$00ee
LO3:	dc.w	$0000
	dc.w	$00f0
HI4:	dc.w	$0000
	dc.w	$00f2
LO4:	dc.w	$0000
	dc.w	$00f4
HI5:	dc.w	$0000
	dc.w	$00f6
LO5:	dc.w	$0000
	dc.w	$00f8
HI6:	dc.w	$0000
	dc.w	$00fa
LO6:	dc.w	$0000
	dc.w	$00fc
HI7:	dc.w	$0000
	dc.w	$00fe
LO7:	dc.w	$0000

	dc.w	$3201,$ff00
	dc.w	$0106,$0002
CH0:	dc.w	$0180,$0000,$0182,$0fff,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
	dc.w	$0106,$0202
CL0:	dc.w	$0180,$0000,$0182,$0fff,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$3401,$ff00,$0100
PLANES:	dc.w	$0001
	dc.w	$ffdf,$fffe
	dc.w	$3401,$ff00,$0100,$0000
	dc.w	$0106,$0002,$0180,$0000,$0106,$0202,$0180,$0000
	dc.w	$FFFF,$FFFE

;--------------------------------------------------------------------

			cnop	0,8
NullSprite:		dcb.l	4,0

		cnop	0,8
Cross:		dc.w	$8080,$8700
		dc.w	%0001000000000000,0
		dc.w	%0001000000000000,0
		dc.w	%0001000000000000,0
		dc.w	%1110111000000000,0
		dc.w	%0001000000000000,0
		dc.w	%0001000000000000,0
		dc.w	%0001000000000000,0
		dc.l	0

		cnop	0,8
AnimA:		dc.w	$4040,$5001
		dcb.l	16,0
		dc.w	0,0,0,0

		cnop	0,8
AnimB:		dc.w	$4040,$5001
		dcb.l	16,0
		dc.w	0,0,0,0

AnimA1:
		dc.w	%1111011110111101
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000

AnimA2:	
		dc.w	%0111101111011110
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000

AnimA3:	
		dc.w	%1011101111101111
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000

AnimA4:	
		dc.w	%1101111011110111
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000

AnimA5:	
		dc.w	%1110111101111011
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%0000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000
		dc.w	%1000000000000000

AnimB1:
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%1011110111101111

AnimB2:
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0111101111011110

AnimB3:
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%1111011110111101

AnimB4:
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%1110111101111011

AnimB5:
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000001
		dc.w	%0000000000000000
		dc.w	%0000000000000001
		dc.w	%1101111011110111

RulerX:		dc.w	$3480,$3402
		dcb.l	256,0
		dc.l	0

RXAnim1:	REPT	16*2
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%0
		dc.w	%0
		ENDR

RXAnim2:	REPT	16*2
		dc.w	%0
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%0
		ENDR

RXAnim3:	REPT	16*2
		dc.w	%0
		dc.w	%0
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		ENDR

RXAnim4:	REPT	16*2
		dc.w	%1
		dc.w	%0
		dc.w	%0
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		ENDR

RXAnim5:	REPT	16*2
		dc.w	%1
		dc.w	%1
		dc.w	%0
		dc.w	%0
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		ENDR

RXAnim6:	REPT	16*2
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%0
		dc.w	%0
		dc.w	%1
		dc.w	%1
		dc.w	%1
		ENDR

RXAnim7:	REPT	16*2
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%0
		dc.w	%0
		dc.w	%1
		dc.w	%1
		ENDR

RXAnim8:	REPT	16*2
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%1
		dc.w	%0
		dc.w	%0
		dc.w	%1
		ENDR

RYAnim1:	dc.w	%1111110011111100
RYAnim2:	dc.w	%0111111001111110
RYAnim3:	dc.w	%0011111100111111
RYAnim4:	dc.w	%1001111110011111
RYAnim5:	dc.w	%1100111111001111
RYAnim6:	dc.w	%1110011111100111
RYAnim7:	dc.w	%1111001111110011
RYAnim8:	dc.w	%1111100111111001
RYSave:		dcb.w	20,0

Font:		incbin	"INC:DPFont.raw"	; font to use in statusline
		cnop	0,2


