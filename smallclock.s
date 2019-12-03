;----------------------------------------------------------------------------
; smallclock v39.0 by Morten Amundsen
;
; start: Wednesday, 20/09 1995, 03:31 PM
;   end: Wednesday, 20/09 1995, 08:16 PM
;
; smallclock v39.01 (Added FRONTPEN and BACKPEN tooltypes)
;
; start: Sunday, 01/10 1995, 07:40 PM
;   end: Sunday, 01/10 1995, 07:50 PM
;
; smallclock v39.02 (Made a better estimate of window width)
;
; start: Friday, 06/10 1995, 09:40 PM
;   end: Friday, 06/10 1995, 09:45 PM
;
; smallclock v39.1 (Added hotkey for turning clock on/off)
;
; start: Monday, 06/11 1995, 22:10
;   end: Monday, 06/11 1995, 23:31
;
; Coded in PhxAss 4.23 
;-----------------------------------------------------------------------------

VERSION	= 39						; kick version
WB	= 1						; wb startup (0=no)

;-----------------------------------------------------------------------------

NAME:	MACRO
	dc.b	"SmallClock"
	ENDM

VER:	MACRO
	dc.b	"39"
	ENDM

REV:	MACRO
	dc.b	"1"
	ENDM

DATE:	MACRO
	dc.b	"(6.11.95)"
	ENDM

VERSTR:	MACRO
	dc.b	"$VER: "
	NAME
	dc.b	" "
	VER
	dc.b	"."
	REV
	dc.b	" "
	dc.b	"by Morten Amundsen "
	DATE
	dc.b	10,13,0
	ENDM

;-----------------------------------------------------------------------------

	incdir	"include:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"graphics/gfxbase.i"
	include	"libraries/commodities.i"
	include	"dos/dosextens.i"
	include	"devices/timer.i"
	include	"graphics/text.i"
	include	"intuition/intuition.i"
	include	"intuition/screens.i"
	include	"libraries/commodities.i"
	include	"workbench/startup.i"
	include	"workbench/workbench.i"

	XDEF	_main
	XDEF	_SysBase
	XDEF	_DOSBase
	XDEF	_GfxBase
	XDEF	_CxBase
	XDEF	_IconBase
	XDEF	_stdout

HOTKEY:	equ	1

_main:	movem.l	d0-d7/a0-a6,-(a7)

	IFD WB
	bsr.w	FIND_WBMSG
	ENDC

	OPENLIB	DOSName,VERSION,_DOSBase
	beq.s	EXIT
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.s	EXIT
	OPENLIB	UtilityName,VERSION,_UtilityBase
	beq.s	EXIT
	OPENLIB IntuitionName,VERSION,_IntuitionBase
	beq.s	EXIT
	OPENLIB	CxName,VERSION,_CxBase
	beq.s	EXIT
	OPENLIB IconName,VERSION,_IconBase
	beq.s	EXIT

	CALL	Output,_DOSBase
	move.l	d0,_stdout

	tst.l	_WBMsg
	beq.s	FROM_SHELL			; get arguments from commandline

	CALL	GetProgramDir,_DOSBase		; CD to PROGDIR:
	move.l	d0,d1
	CALL	CurrentDir,_DOSBase
	move.l	d0,_OldLock

	move.l	_WBMsg,a0
	move.l	sm_ArgList(a0),a0
	move.l	wa_Name(a0),a0
	CALL	GetDiskObject,_IconBase		; get icon
	move.l	d0,_DiskObject
	beq	SETUP_CX

	move.l	_DiskObject,a0			; read tooltypes
	move.l	do_ToolTypes(a0),a0
	lea	CXPRI_Text,a1
	CALL	FindToolType,_IconBase
	moveq	#0,d7			; default value
	bsr	STR2INT

	lea	New_Broker,a1
	move.b	d0,nb_Pri(a1)		; CX_PRIORITY=

	move.l	_DiskObject,a0			; read tooltypes
	move.l	do_ToolTypes(a0),a0
	lea	CXKEY_Text,a1
	CALL	FindToolType,_IconBase		; CX_POPKEY=

	lea	DefHotKey,a1			; default hotkey

	tst.l	d0
	beq.s	.DEF

	move.l	d0,a1				; user defined

.DEF:	lea	ClockHotKey,a2
.LOOP:	move.b	(a1)+,(a2)+
	bne.s	.LOOP

	move.l	_DiskObject,a0
	move.l	do_ToolTypes(a0),a0
	lea	CXXPOS_Text,a1
	CALL	FindToolType,_IconBase
	moveq	#0,d7			; default value
	bsr	STR2INT

	move.l	d0,WndXPos		; XPOS=

	move.l	_DiskObject,a0
	move.l	do_ToolTypes(a0),a0
	lea	CXYPOS_Text,a1
	CALL	FindToolType,_IconBase
	moveq	#0,d7			; default value
	bsr	STR2INT

	move.l	d0,WndYPos		; YPOS=

	move.l	_DiskObject,a0
	move.l	do_ToolTypes(a0),a0
	lea	CXFPEN_Text,a1
	CALL	FindToolType,_IconBase
	moveq	#0,d7			; default value
	bsr	STR2INT

	move.l	d0,FrontPen		; FRONTPEN=

	move.l	_DiskObject,a0
	move.l	do_ToolTypes(a0),a0
	lea	CXBPEN_Text,a1
	CALL	FindToolType,_IconBase
	moveq	#1,d7			; default value
	bsr	STR2INT

	move.l	d0,BackPen		; BACKPEN=


	move.l	_DiskObject,a0
	CALL	FreeDiskObject,_IconBase

	move.l	_OldLock,d1		; CD to original dir.
	CALL	CurrentDir,_DOSBase
	bra.s	SETUP_CX

FROM_SHELL:
	move.l	#TEMPLATE,d1		; read commandline
	move.l	#Arguments,d2
	moveq	#0,d3
	CALL	ReadArgs,_DOSBase
	move.l	d0,_RDArgs
	bne.s	OKARG

	CALL	IoErr,_DOSBase		; woops! syntax error!

	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DOSBase	; why!?
	bra	EXIT

OKARG:	lea	Arguments,a0
	move.l	(a0)+,d0
	bne.s	.U0

	moveq	#0,d0

.U0:	lea	New_Broker,a1
	move.b	d0,nb_Pri(a1)		; CX_PRIORITY=

	move.l	(a0)+,a1
	cmp.l	#NULL,a1
	bne.s	.U1

	lea	DefHotKey,a2
	lea	ClockHotKey,a3
.L1:	move.b	(a2)+,(a3)+
	bne.s	.L1
	bra.s	.N1

.U1:	lea	ClockHotKey,a2
.L2:	move.b	(a1)+,(a2)+
	bne.s	.L2

.N1:	move.l	(a0)+,a1
	cmp.l	#NULL,a1
	bne.s	.U2

	move.l	#0,WndXPos
	bra.s	.N2

.U2:	move.l	(a1),WndXPos		; XPOS=

.N2:	move.l	(a0)+,a1
	cmp.l	#NULL,a1
	bne.s	.U3

	move.l	#0,WndYPos
	bra.s	.N3

.U3:	move.l	(a1),WndYPos		; YPOS=

.N3:	move.l	(a0)+,a1
	cmp.l	#NULL,a1
	bne.s	.U4

	move.l	#0,FrontPen
	bra.s	.N4

.U4:	move.l	(a1),FrontPen		; FRONTPEN=

.N4:	move.l	(a0),a1
	cmp.l	#NULL,a1
	bne.s	.N5

	move.l	#1,BackPen
	bra.s	SETUP_CX

.N5:	move.l	(a1),BackPen		; BACKPEN

;--------------------------------------------------------------------

SETUP_CX:
	move.l	#ClockHotKey,cx_HotKey

	EXEC	CreateMsgPort
	move.l	d0,_BrokerPort
	beq	EXIT

	moveq	#0,d1
	move.l	_BrokerPort,a0
	move.b	MP_SIGBIT(a0),d0
	bset	d0,d1
	move.l	d1,_CxSigSet

	lea	New_Broker,a0
	move.l	_BrokerPort,nb_Port(a0)
	moveq	#0,d0
	CALL	CxBroker,_CxBase
	move.l	d0,_Broker
	beq	EXIT

	move.l	#CX_FILTER,d0
	move.l	cx_HotKey,a0
	sub.l	a1,a1
	CALL	CreateCxObj,_CxBase
	move.l	d0,_Filter
	beq.s	EXIT

	move.l	_Broker,a0
	move.l	_Filter,a1
	CALL	AttachCxObj,_CxBase

	move.l	#CX_SEND,d0
	move.l	_BrokerPort,a0
	move.l	#HOTKEY,a1
	CALL	CreateCxObj,_CxBase
	move.l	d0,_Sender
	beq.s	EXIT

	move.l	_Filter,a0
	move.l	_Sender,a1
	CALL	AttachCxObj,_CxBase

	move.l	#CX_TRANSLATE,d0
	sub.l	a0,a0
	sub.l	a1,a1
	CALL	CreateCxObj,_CxBase
	move.l	d0,_Translate
	beq.s	EXIT

	move.l	_Filter,a0
	move.l	_Translate,a1
	CALL	AttachCxObj,_CxBase

	move.l	_Filter,a0
	CALL	CxObjError,_CxBase
	tst.l	d0
	bne.s	EXIT

;-------------------------------------------------------------------------------------

	bsr.w	OPEN_WINDOW
	beq.s	EXIT

;-------------------------------------------------------------------------------------

	EXEC	CreateMsgPort
	move.l	d0,_TimerMP
	beq	EXIT

	moveq	#0,d2
	move.l	d0,a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d2
	move.l	d2,_TimerSigBit

	move.l	d0,a0
	move.l	#IOTV_SIZE,d0
	EXEC	CreateIORequest
	move.l	d0,_TimerIO
	beq	EXIT

	lea	TimerName,a0
	moveq	#UNIT_VBLANK,d0
	move.l	_TimerIO,a1
	moveq	#0,d0
	EXEC	OpenDevice

	move.l	_TimerIO,a0
	move.l	IO_DEVICE(a0),_TimerBase
	beq	EXIT

	move.l	_Broker,a0
	moveq	#TRUE,d0
	CALL	ActivateCxObj,_CxBase

	move.w	#TRUE,ClockON

CLOCK_LOOP:
	moveq	#0,d0

	tst.w	ClockON
	beq.s	NO_CLOCK

	move.l	_TimerIO,a1
	move.w	#TR_ADDREQUEST,IO_COMMAND(a1)		; wait a second!!
	lea	IOTV_TIME(a1),a0
	move.l	#1,TV_SECS(a0)
	move.l	#0,TV_MICRO(a0)
	EXEC	SendIO

	move.l	_TimerSigBit,d0

NO_CLOCK:
	or.l	_CxSigSet,d0				; wait for CTRL-C, CX and timer
	or.l	#SIGBREAKF_CTRL_C,d0
	EXEC	Wait

	move.l	d0,d1
	and.l	#SIGBREAKF_CTRL_C,d1
	bne	EXIT

	move.l	d0,d1
	move.l	_CxSigSet,d2
	and.l	d2,d1
	beq	UPDATE_CLOCK

CXMSG_LOOP:
	tst.w	ExitFlag
	bne	EXIT

	move.l	_BrokerPort,a0
	EXEC	GetMsg
	move.l	d0,_CxMessage
	beq	CLOCK_LOOP

	move.l	d0,a0
	CALL	CxMsgID,_CxBase
	move.l	d0,_CxID

	move.l	_CxMessage,a0
	CALL	CxMsgType,_CxBase
	move.l	d0,_CxType

	move.l	_CxType,d0
	cmp.l	#CXM_COMMAND,d0			; command from "Exchange"
	bne.s	NOT_CXCOMMAND

	move.l	_CxID,d0
	cmp.l	#CXCMD_UNIQUE,d0		; quit if started twice!
	bne.s	NOT_UNIQUE

	move.w	#1,ExitFlag
	bra.s	CXMSG_REPLY

NOT_UNIQUE:
	cmp.l	#CXCMD_KILL,d0			; remove
	bne.s	NOT_KILL

	move.w	#1,ExitFlag
	bra.s	CXMSG_REPLY

NOT_KILL:
	cmp.l	#CXCMD_ENABLE,d0		; active
	bne.s	NOT_ENABLE

	move.l	_Broker,a0
	moveq	#TRUE,d0
	CALL	ActivateCxObj,_CxBase
	move.w	#TRUE,ClockON
	bra.s	CXMSG_REPLY

NOT_ENABLE:
	cmp.l	#CXCMD_DISABLE,d0
	bne	CXMSG_REPLY

	move.l	_Broker,a0
	moveq	#FALSE,d0
	CALL	ActivateCxObj,_CxBase		; inactive
	move.w	#FALSE,ClockON
	bra	CXMSG_REPLY

NOT_CXCOMMAND:
	cmp.l	#CXM_IEVENT,d0
	bne.s	CXMSG_REPLY

	move.l	_CxID,d0
	cmp.l	#HOTKEY,d0
	bne.s	CXMSG_REPLY

	tst.l	_Window
	beq.s	.OPEN

	bsr.w	CLOSEWND
	bra.s	CXMSG_REPLY

.OPEN:	bsr.w	OPEN_WINDOW
	bne.s	CXMSG_REPLY

	move.w	#1,ExitFlag

CXMSG_REPLY:
	move.l	_CxMessage,a1
	EXEC	ReplyMsg
	bra.s	CXMSG_LOOP

;--------------------------------------------------------------------

UPDATE_CLOCK:
	tst.w	ClockON
	beq	CLOCK_LOOP

	tst.l	_Window
	beq.s	CLOCK_LOOP

	lea	TimeVal,a0			; get SysTime if Clock is active
	CALL	GetSysTime,_TimerBase

	lea	TimeVal,a0

	move.l	TV_SECS(a0),d0
	move.l	#60,d1
	CALL	UDivMod32,_UtilityBase		; calculate time of day
	move.w	d1,Seconds
	
	move.l	#60,d1
	CALL	UDivMod32,_UtilityBase
	move.w	d1,Minutes

	move.l	#24,d1
	CALL	UDivMod32,_UtilityBase
	move.w	d1,Hours

	lea	HTxt,a0				; convert into string
	moveq	#0,d0
	move.w	d1,d0
	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a0)
	swap	d0
	add.b	#'0',d0
	move.b	d0,1(a0)

	lea	MTxt,a0
	moveq	#0,d0
	move.w	Minutes,d0
	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a0)
	swap	d0
	add.b	#'0',d0
	move.b	d0,1(a0)

	lea	STxt,a0
	moveq	#0,d0
	move.w	Seconds,d0
	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a0)
	swap	d0
	add.b	#'0',d0
	move.b	d0,1(a0)

	move.l	_Window,a1
	move.l	wd_RPort(a1),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	WndXSize,d2
	move.w	WndYSize,d3
	CALL	RectFill,_GfxBase		; clear window

	move.l	_Window,a0
	move.l	wd_RPort(a0),a0
	lea	TimeIText,a1
	moveq	#0,d0
	moveq	#2,d1
	CALL	PrintIText,_IntuitionBase	; ohhh!? is it that much already?
	bra	CLOCK_LOOP

EXIT:	bsr.w	CLEAN				; bye!!!
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;-----------------------------------------------------------------------------

OPEN_WINDOW:
	tst.l	_Window
	bne.s	SKIP_OPEN

	lea	TIText,a0
	move.b	#'4',(a0)+
	move.b	#'4',(a0)+
	move.b	#'4',(a0)+
	move.b	#'4',(a0)+
	move.b	#'4',(a0)+
	move.b	#'4',(a0)+
	move.b	#'4',(a0)+
	move.b	#'4',(a0)

	SETTAG	#WindowTags,WA_Left,WndXPos		; clock window position
	SETTAG	#WindowTags,WA_Top,WndYPos

	lea	WBName,a0
	CALL	LockPubScreen,_IntuitionBase
	move.l	d0,_WBScr
	beq	OPEN_FAIL

	move.l	d0,a0
	move.l	sc_Font(a0),a0				; get screen font
	lea	TimeIText,a1
	move.l	a0,it_ITextFont(a1)

	CALL	OpenFont,_GfxBase
	move.l	d0,_WBFont
	beq	OPEN_FAIL

	moveq	#0,d2
	moveq	#0,d3
	move.l	d0,a0
	move.w	tf_YSize(a0),d2				; check it x/y size
	addq.w	#2,d2
	move.w	d2,WndYSize
	SETTAG	#WindowTags,WA_Height,d2		; clock window y size

	lea	TimeIText,a0
	CALL	IntuiTextLength,_IntuitionBase
	move.w	d0,WndXSize
	move.w	d0,d3

	SETTAG	#WindowTags,WA_Width,d3

	lea	TimeIText,a0
	move.l	#NULL,it_ITextFont(a0)

	sub.l	a0,a0
	move.l	_WBScr,a1
	CALL	UnlockPubScreen,_IntuitionBase

	sub.l	a0,a0
	lea	WindowTags,a1
	CALL	OpenWindowTagList,_IntuitionBase
	move.l	d0,_Window
	beq	OPEN_FAIL

	move.l	d0,a0
	move.l	wd_RPort(a0),a1
	move.l	_WBFont,a0
	CALL	SetFont,_GfxBase	; use WBFont in our window

	move.l	_Window,a1
	move.l	wd_RPort(a1),a1
	move.l	BackPen,d0
	CALL	SetAPen,_GfxBase

	move.l	FrontPen,d0
	move.l	BackPen,d1

	lea	TimeIText,a0
	move.b	d0,(a0)			; frontpen
	move.b	d1,1(a0)		; backpen

	move.b	#':',CTxt
	move.b	#'.',DTxt

SKIP_OPEN:
	moveq	#1,d0
	rts

OPEN_FAIL:
	moveq	#0,d0
	rts

;--------------------------------------------------------------------

	IFD WB

FIND_WBMSG:
	sub.l	a1,a1
	CALLEXEC FindTask
	move.l	d0,a4

	moveq	#0,d0

	tst.l	pr_CLI(a4)
	bne.s	.CLI

	lea	pr_MsgPort(a4),a0
	CALLEXEC WaitPort
	lea	pr_MsgPort(a4),a0
	CALLEXEC GetMsg
.CLI:	move.l	d0,_WBMsg
	rts

REPLY_WBMSG:
	tst.l	_WBMsg
	beq.s	.NOT

	move.l	_WBMsg,a1
	CALLEXEC ReplyMsg
.NOT:	rts

	ENDC

;-----------------------------------------------------------------------------

CLEAN:	bsr.w	FREEARGS

	bsr.w	REMOVE_CX
	bsr.w	CLOSE_CXPORT

	bsr.w	CLOSETIME
	bsr.w	DEL_EXTIO
	bsr.w	DEL_PORT

	bsr	CLOSEWND

	bsr.w	CLOSEICN
	bsr.w	CLOSEDOS
	bsr.w	CLOSEGFX
	bsr.w	CLOSEUTL
	bsr.w	CLOSEINT
	bsr.w	CLOSECX

	IFD WB
	bsr.s	REPLY_WBMSG
	ENDC
	rts

;------------------------------------------------------------------------------------

REMOVE_CX:
	tst.l	_Broker
	beq	.NOT

	move.l	_Broker,a0
	CALL	DeleteCxObj,_CxBase
.NOT:	rts

CLOSE_CXPORT:
	tst.l	_BrokerPort
	beq	.NOT
	
	move.l	_BrokerPort,a0
	EXEC	DeleteMsgPort
.NOT:	rts

FREEARGS:
	tst.l	_RDArgs
	beq	.NOT

	move.l	_RDArgs,d1
	CALL	FreeArgs,_DOSBase
.NOT:	rts

CLOSEFNT:
	tst.l	_WBFont
	beq	.NOT

	move.l	_WBFont,a1
	CALL	CloseFont,_GfxBase
.NOT:	rts

CLOSEWND:
	tst.l	_Window
	beq	.NOT

	move.l	_Window,a0
	CALL	CloseWindow,_IntuitionBase
	move.l	#0,_Window

.NOT:	bsr.w	CLOSEFNT
	rts

CLOSETIME:
	tst.l	_TimerIO
	beq	.NOT

	move.l	_TimerIO,a1
	EXEC	CheckIO
	tst.l	d0
	bne	.PROG

	move.l	_TimerIO,a1
	EXEC	AbortIO

.PROG:	move.l	_TimerIO,a1
	EXEC	WaitIO

	move.l	_TimerIO,a1
	EXEC	CloseDevice
.NOT:	rts

DEL_EXTIO:
	tst.l	_TimerIO
	beq	.NOT

	move.l	_TimerIO,a0
	EXEC	DeleteIORequest
.NOT:	rts

DEL_PORT:
	tst.l	_TimerMP
	beq	.NOT

	move.l	_TimerMP,a0
	EXEC	DeleteMsgPort
.NOT:	rts

CLOSEICN:
	tst.l	_IconBase
	beq.s	.NOT

	CLOSELIB _IconBase
.NOT:	rts

CLOSECX:
	tst.l	_CxBase
	beq.s	.NOT

	CLOSELIB _CxBase
.NOT:	rts

CLOSEINT:
	tst.l	_IntuitionBase
	beq.s	.NOT

	CLOSELIB _IntuitionBase
.NOT:	rts

CLOSEUTL:
	tst.l	_UtilityBase
	beq.s	.NOT

	CLOSELIB _UtilityBase
.NOT:	rts

CLOSEDOS:
	tst.l	_DOSBase
	beq.s	.NOT

	CLOSELIB _DOSBase
.NOT:	rts

CLOSEGFX:
	tst.l	_GfxBase
	beq.s	.NOT

	CLOSELIB _GfxBase
.NOT:	rts

;----------------------------------------------------------------------------
; NAME		STR2INT
; DESCRIPTION	Make a tooltype integer string into a long. If string is
;		incorrect, the default value will be returned.
; USAGE		value=STR2INT(string,default)
;		d0            d0     d7
;-----------------------------------------------------------------------------

STR2INT:
	tst.l	d0				; no string!
	beq	S2I_DEFAULT

	move.l	d0,a0
	tst.b	(a0)				; string is empty!
	beq	S2I_DEFAULT

	moveq	#0,d0
	moveq	#0,d6
S2I_LOOP:
	tst.b	(a0)
	beq.s	S2I_INTEGER			; done!
	cmp.b	#' ',(a0)
	beq	S2I_NEXT			; we've got a 'space', next please!

	cmp.b	#'0',(a0)
	blo.s	S2I_DEFAULT
	cmp.b	#'9',(a0)
	bhi.s	S2I_DEFAULT

	move.b	(a0),d0				; ok! a number between 0 and 9
	sub.b	#'0',d0				; convert to number
	mulu	#10,d6				; multiply what we already have by 10
	add.l	d0,d6				; and add this number

S2I_NEXT:
	lea	1(a0),a0			; next char
	bra.s	S2I_LOOP

S2I_INTEGER:
	move.l	d6,d0				; we're done, return in d0
	rts

S2I_DEFAULT:
	move.l	d7,d0				; error! return default value!
	rts

;-----------------------------------------------------------------------------

	section	"Data",data

	IFD WB
_WBMsg:		dc.l	0
	ENDC

_stdout:	dc.l	0

_RDArgs:	dc.l	0

_TimerIO:	dc.l	0
_TimerMP:	dc.l	0
_TimerSigBit:	dc.l	0
_TimerBase:	dc.l	0	; library base of timer.device

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
_UtilityBase:	dc.l	0
_IntuitionBase:	dc.l	0
_CxBase:	dc.l	0
_IconBase:	dc.l	0
IconName:	dc.b	"icon.library",0
IntuitionName:	dc.b	"intuition.library",0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
UtilityName:	dc.b	"utility.library",0
CxName:		dc.b	"commodities.library",0
TimerName:	dc.b	"timer.device",0
		VERSTR
		even

ExitFlag:	dc.w	0		; set if we're to remove ourselves
ClockON:	dc.w	0		; set if SmallClock is active

;------------------------------

_CxID:		dc.l	0
_CxType:	dc.l	0

_CxSigSet:	dc.l	0
_CxMessage:	dc.l	0
_BrokerPort:	dc.l	0
_Broker:	dc.l	0

New_Broker:	dc.b	NB_VERSION
		dc.b	0
		dc.l	ClockName
		dc.l	ClockTitle
		dc.l	ClockDescr
		dc.w	NBU_UNIQUE!NBU_NOTIFY
		dc.w	0
		dc.b	0
		dc.b	0
		dc.l	0
		dc.w	0

ClockTitle:	NAME
		dc.b	" "
		VER
		dc.b	"."
		REV
		dc.b	0

ClockName:	NAME
		dc.b	0

ClockDescr:	dc.b	"Hotkey: "
ClockHotKey:	dcb.b	33,0
DefHotKey:	dc.b	"ralt e",0
		even

cx_HotKey:	dc.l	0
_Sender:	dc.l	0
_Filter:	dc.l	0
_Translate:	dc.l	0

CXPRI_Text:	dc.b	"CX_PRIORITY",0
CXKEY_Text:	dc.b	"CX_POPKEY",0
CXXPOS_Text:	dc.b	"XPOS",0
CXYPOS_Text:	dc.b	"YPOS",0
CXFPEN_Text:	dc.b	"FRONTPEN",0
CXBPEN_Text:	dc.b	"BACKPEN",0

;--------------------------------------------------

WBName:		dc.b	"Workbench",0
TEMPLATE:	dc.b	"CX_PRIORITY/N/K,CX_POPKEY/K,XPOS/N/K,YPOS/N/K,FRONTPEN/N/K,BACKPEN/N/K",0
		even

_OldLock:	dc.l	0
_DiskObject:	dc.l	0
Arguments:	dcb.l	5,0

;----------------------------------------------

FrontPen:	dc.l	0
BackPen:	dc.l	0

_WBFont:	dc.l	0
_WBScr:		dc.l	0

WndXSize:	dc.w	0
WndYSize:	dc.w	0
WndXPos:	dc.l	0
WndYPos:	dc.l	0

_Window:	dc.l	0
WindowTags:	dc.l	WA_Left,0
		dc.l	WA_Top,0
		dc.l	WA_Width,0
		dc.l	WA_Height,0
		dc.l	WA_Borderless,TRUE
		dc.l	WA_RMBTrap,TRUE
		dc.l	TAG_DONE

;-------------------------------------------------

TimeVal:	dcb.b	TV_SIZE,0

Hours:		dc.w	0
Minutes:	dc.w	0
Seconds:	dc.w	0

TimeIText:	dc.b	1,0			; front & back pen
		dc.b	0			; drawmode
		dc.b	0			; KludgeFill00
		dc.w	0,0			; rel x/y
		dc.l	0			; font
		dc.l	TIText
		dc.l	0			; next

TIText:	
HTxt:		dc.b	"44"
CTxt:		dc.b	"4"
MTxt:		dc.b	"44"
DTxt:		dc.b	"4"
STxt:		dc.b	"44"
		dc.b	0
		even
