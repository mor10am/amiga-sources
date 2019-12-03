;--------------------------------------------------------------------
; Insert Date V38.0
; "Insert Current Time and Date In InputStream"
; by Morten Amundsen
;
; Assembled with PhxAss V4.26
;--------------------------------------------------------------------

VERSION	= 38						; kick version
WB	= 1						; wb startup (0=no)

;--------------------------------------------------------------------

PRG_NAME:	MACRO
		dc.b	"Insert Date"
		ENDM

VER:	MACRO
	dc.b	"38"
	ENDM

REV:	MACRO
	dc.b	"0"
	ENDM

DATE:	MACRO
	dc.b	"(11.2.95)"
	ENDM

VERSTR:	MACRO
	dc.b	"$VER: "
	PRG_NAME
	dc.b	" "
	VER
	dc.b	"."
	REV
	dc.b	" "
	DATE
	dc.b	10,13,0
	ENDM

;--------------------------------------------------------------------
; -- hotkey identifiers --

POPKEY:		equ	0
INSERTKEY:	equ	1

;--------------------------------------------------------------------
; -- gadget identifiers

GAD_POPKEY:	equ	0
GAD_HOTKEY:	equ	1
GAD_DESCR:	equ	2
GAD_SAVE:	equ	3
GAD_USE:	equ	4
GAD_CANCEL:	equ	5
NOGADS:		equ	6

GUISPACE:	equ	2

;--------------------------------------------------------------------

	incdir	"include:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dosextens.i"
	include	"exec/memory.i"
	include	"graphics/gfxbase.i"
	include	"intuition/intuition.i"
	include	"workbench/icon.i"
	include	"workbench/workbench.i"
	include "libraries/locale.i"
	include	"libraries/gadtools.i"
	include	"graphics/text.i"
	include	"libraries/commodities.i"
	include	"devices/input.i"
	include "devices/inputevent.i"

;--------------------------------------------------------------------
; -- Bevelbox dimensions --


 STRUCTURE	bev,0
	UWORD	bev_topedge
	UWORD	bev_leftedge
	UWORD	bev_height
	UWORD	bev_width
	LABEL	bev_SIZEOF

;--------------------------------------------------------------------
; -- Prefs --

 STRUCTURE	prefs,0
	STRUCT	prefs_popkey,65
	STRUCT	prefs_hotkey,65
	STRUCT	prefs_descr,65
	LABEL	prefs_SIZEOF

;--------------------------------------------------------------------
; dest=STRCPY(source,dest)
;  d0           ax     ax
;--------------------------------------------------------------------

STRCPY:		MACRO

		move.l	\2,d1
		beq.s	\@SC2

\@SC1:		move.b	(\1)+,(\2)+
		bne.s	\@SC1
		
\@SC2:		move.l	d1,d0
		ENDM

;--------------------------------------------------------------------
; string=TOUPPER(string)
;   d0           ax
;--------------------------------------------------------------------

TOUPPER:	MACRO
		move.l	\1,d1
		beq.s	\@TO2

\@TO1:		move.b	(\1),d0
		beq.s	\@TO2

		cmp.b	#'a',d0
		blo.s	\@TO3
		cmp.b	#'z',d0
		bhi.s	\@TO3

		sub.b	#'a'-'A',d0

\@TO3:		move.b	d0,(\1)+
		bra.s	\@TO1

\@TO2:		move.l	d1,d0
		ENDM

;--------------------------------------------------------------------
; result=STRCMP(source,dest)
;   d0            ax    ax
;--------------------------------------------------------------------

STRCMP:		MACRO

		moveq	#0,d0

\@SP1:		move.b	(\1)+,d1
		move.b	(\2)+,d2

		cmp.b	d1,d2
		bne.s	\@SP2

		tst.b	d1
		bne.s	\@SP1
		bra.s	\@SP3

\@SP2:		moveq	#1,d0
\@SP3:
		ENDM

;--------------------------------------------------------------------

	XDEF	_main
	XDEF	_SysBase
	XDEF	_DOSBase
	XDEF	_GfxBase
	XDEF	_IntuitionBase
	XDEF	_IconBase
	XDEF	_LocaleBase
	XDEF	_GadToolsBase
	XDEF	_DiskFontBase
	XDEF	_CxBase
	
	XDEF	_stdout

	XREF	_ArgArrayInit
	XREF	_ArgArrayDone
	XREF	_ArgInt
	XREF	_ArgString
	XREF	_HotKey

_main:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	d0,_argc
	move.l	a0,_argv

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

	OPENLIB	DOSName,VERSION,_DOSBase
	beq.s	EXIT
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.s	EXIT
	OPENLIB	IntuitionName,VERSION,_IntuitionBase
	beq.s	EXIT
	OPENLIB IconName,VERSION,_IconBase
	beq.s	EXIT
	OPENLIB LocaleName,VERSION,_LocaleBase
	beq.s	EXIT
	OPENLIB GadToolsName,VERSION,_GadToolsBase
	beq.s	EXIT
	OPENLIB DiskFontName,VERSION,_DiskFontBase
	beq.s	EXIT
	OPENLIB CxName,VERSION,_CxBase
	beq.s	EXIT

	CALL	Output,_DOSBase
	move.l	d0,_stdout

;--------------------------------------------------------------------

	tst.l	_WBMsg
	beq.s	FROM_SHELL

;--------------------------------------------------------------------
; -- Icon Arguments --

	CALL	GetProgramDir,_DOSBase
	move.l	d0,d1
	CALL	CurrentDir,_DOSBase
	move.l	d0,_OldCurrent

	move.l	_WBMsg,-(sp)
	move.l	#0,-(sp)

	jsr	_ArgArrayInit
	add.l	#8,sp

	move.l	d0,_ttypes
	beq.s	EXIT
	
;--------------------------------------------------------------------
; -- cx_priority --

	move.l	DefPri,-(sp)
	move.l	#CxPriTxt,-(sp)
	move.l	_ttypes,-(sp)
	jsr	_ArgInt
	add.l	#12,sp

	move.l	d0,CxPri

;--------------------------------------------------------------------
; -- cx_popup --

	move.l	#DefPopUpString,-(sp)
	move.l	#CxPopUpTxt,-(sp)
	move.l	_ttypes,-(sp)
	jsr	_ArgString
	add.l	#12,sp

	move.l	d0,a0
	TOUPPER	a0

	move.l	d0,a0
	lea	CxPopString,a1
	move.w	#4,d7
.LOOP:	move.b	(a0)+,(a1)+
	beq.s	.DONE
	dbf	d7,.LOOP

.DONE:	lea	DefPopUpString,a0			; false
	lea	CxPopString,a1
	STRCMP	a0,a1
	beq.s	.NO

	move.l	#TRUE,CxPopUp
	bra.s	BUILD_APP

.NO:	move.l	#FALSE,CxPopUp
	bra.s	BUILD_APP

;--------------------------------------------------------------------
; -- Shell Arguments --

FROM_SHELL:
	move.l	#Template,d1
	move.l	#ShellArgs,d2
	moveq	#0,d3
	CALL	ReadArgs,_DOSBase
	move.l	d0,_RDArgs
	bne.s	PARSE_SHELLARGS

	CALL	IoErr,_DOSBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DOSBase
	bra.w	EXIT

PARSE_SHELLARGS:
	lea	ShellArgs,a4

;--------------------------------------------------------------------
; -- cx_priority --

GET_CXPRI:
	move.l	(a4)+,a0
	cmp.l	#NULL,a0
	beq.s	USE_CXPRI_DEF

	move.l	(a0),d0
	bra.s	SET_CXPRI

USE_CXPRI_DEF:
	move.l	DefPri,d0

SET_CXPRI:
	move.l	d0,CxPri

;--------------------------------------------------------------------
; -- cx_popup --

GET_CXPOPUP:
	move.l	(a4)+,d0
	beq.s	USE_CXPOPUP_DEF

	move.l	#TRUE,d0
	bra.s	SET_CXPOPUP

USE_CXPOPUP_DEF:
	move.l	DefPopUp,d0

SET_CXPOPUP:
	move.l	d0,CxPopUp

;--------------------------------------------------------------------

BUILD_APP:
	bsr.w	SET_CURRENTDIR

	move.l	#PrefsENV,d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open,_DOSBase

	move.l	d0,_PrefsLock
	beq.s	USE_DEFAULT_PREFS

	move.l	d0,d1
	move.l	#PrefsBuffer,d2
	move.l	#prefs_SIZEOF,d3
	CALL	Read,_DOSBase
	
	move.l	_PrefsLock,d1
	CALL	Close,_DOSBase
	bra.s	SETUP_CXBROKER

USE_DEFAULT_PREFS:
	lea	PrefsBuffer,a4

	lea	DefPopKey,a2
	lea	prefs_popkey(a4),a3
	STRCPY	a2,a3

	lea	DefHotKey,a2
	lea	prefs_hotkey(a4),a3
	STRCPY	a2,a3

	lea	DefDescr,a2
	lea	prefs_descr(a4),a3
	STRCPY	a2,a3

;--------------------------------------------------------------------

SETUP_CXBROKER:
	EXEC	CreateMsgPort
	move.l	d0,_BrokerPort
	beq.s	EXIT

	moveq	#0,d1
	move.l	d0,a0
	move.b	MP_SIGBIT(a0),d0
	bset	d0,d1
	move.l	d1,_CxSigSet

	lea	New_Broker,a0
	move.l	_BrokerPort,nb_Port(a0)
	move.l	CxPri,d0
	move.b	d0,nb_Pri(a0)
	moveq	#0,d0
	CALL	CxBroker,_CxBase
	move.l	d0,_Broker
	beq.s	EXIT
	
	move.l	#POPKEY,-(sp)
	move.l	_BrokerPort,-(sp)
	lea	PrefsBuffer,a0
	lea	prefs_popkey(a0),a0
	move.l	a0,-(sp)
	jsr	_HotKey
	add.l	#12,sp

	move.l	d0,_PopFilter
	beq.s	EXIT

	move.l	_Broker,a0
	move.l	d0,a1
	CALL	AttachCxObj,_CxBase

	move.l	#INSERTKEY,-(sp)
	move.l	_BrokerPort,-(sp)
	lea	PrefsBuffer,a0
	lea	prefs_hotkey(a0),a0
	move.l	a0,-(sp)
	jsr	_HotKey
	add.l	#12,sp

	move.l	d0,_HotFilter
	beq.s	EXIT

	move.l	_Broker,a0
	move.l	d0,a1
	CALL	AttachCxObj,_CxBase

	move.l	_Broker,a0
	move.l	#TRUE,d0
	CALL	ActivateCxObj,_CxBase

;--------------------------------------------------------------------

	sub.l	a0,a0
	CALL	OpenLocale,_LocaleBase
	move.l	d0,_Locale
	beq.s	EXIT

;--------------------------------------------------------------------


;	move.l	CxPopUp,d0
;	cmp.l	#FALSE,d0
;	beq.s	MAINLOOP

	bsr.w	OPEN_WINDOW

MAINLOOP:
	tst.w	ExitFlag
	bne.s	EXIT

	move.l	#SIGBREAKF_CTRL_C,d0
	or.l	_CxSigSet,d0

	tst.l	_WndSigSet
	beq.s	.NOWND

	or.l	_WndSigSet,d0

.NOWND:	EXEC	Wait

	move.l	d0,d1

	and.l	#SIGBREAKF_CTRL_C,d1
	beq.s	NO_CTRL_C

	move.w	#1,ExitFlag

NO_CTRL_C:
	move.l	d0,d1
	and.l	_WndSigSet,d1
	beq.s	NO_WNDMSG

;--------------------------------------------------------------------

WNDMSGLOOP:
	move.l	_UPort,a0
	cmp.l	#NULL,a0
	beq.s	MAINLOOP

	CALL	GT_GetIMsg,_GadToolsBase
	move.l	d0,_WndMessage
	beq.s	MAINLOOP

	move.l	d0,a0
	move.l	im_Class(a0),d0

	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	NOT_CLOSEWINDOW

	lea	PrefsBackup,a0
	lea	PrefsBuffer,a1
	move.l	#prefs_SIZEOF,d0
	EXEC	CopyMem

	bsr.w	CLOSE_WINDOW
	bra.s	WNDREPLYMSG

NOT_CLOSEWINDOW:
	cmp.l	#IDCMP_GADGETUP,d0
	bne.s	WNDREPLYMSG

	move.l	im_IAddress(a0),a1		; a1=gadget
	move.l	gg_UserData(a1),a2
	cmp.l	#NULL,a2
	beq.s	WNDREPLYMSG

	jsr	(a2)

WNDREPLYMSG:
	move.l	_WndMessage,a1
	cmp.l	#NULL,a1
	beq.s	WNDMSGLOOP

	CALL	GT_ReplyIMsg,_GadToolsBase
	bra.s	WNDMSGLOOP

;--------------------------------------------------------------------

NO_WNDMSG:
	and.l	_CxSigSet,d0
	beq.s	MAINLOOP

CXMSGLOOP:
	move.l	_BrokerPort,a0
	EXEC	GetMsg
	move.l	d0,_CxMessage
	beq.s	MAINLOOP

	move.l	d0,a0
	CALL	CxMsgID,_CxBase
	move.l	d0,_CxID

	move.l	_CxMessage,a0
	CALL	CxMsgType,_CxBase

	cmp.l	#CXM_COMMAND,d0
	bne.s	NOT_CXCOMMAND

	move.l	_CxID,d0
	cmp.l	#CXCMD_UNIQUE,d0
	bne.s	NOT_UNIQUE

	bra.s	CXMSGREPLY

NOT_UNIQUE:
	cmp.l	#CXCMD_KILL,d0
	bne.s	NOT_KILL

	move.w	#1,ExitFlag
	bra.s	CXMSGREPLY

NOT_KILL:
	cmp.l	#CXCMD_ENABLE,d0
	bne.s	NOT_ENABLE

	move.l	_Broker,a0
	move.l	#TRUE,d0
	CALL	ActivateCxObj,_CxBase
	bra.s	CXMSGREPLY

NOT_ENABLE:
	cmp.l	#CXCMD_DISABLE,d0
	bne.s	NOT_DISABLE

	move.l	_Broker,a0
	move.l	#FALSE,d0
	CALL	ActivateCxObj,_CxBase
	bra.s	CXMSGREPLY

NOT_DISABLE:
	cmp.l	#CXCMD_APPEAR,d0
	bne.s	NOT_APPEAR

	tst.l	_Window
	bne.s	.NOT

	bsr.w	OPEN_WINDOW
.NOT:	bra.s	CXMSGREPLY

NOT_APPEAR:
	cmp.l	#CXCMD_DISAPPEAR,d0
	bne.s	CXMSGREPLY

	tst.l	_Window
	beq.s	CXMSGREPLY

	bsr.w	CLOSE_WINDOW
	bra.s	CXMSGREPLY

;--------------------------------------------------------------------

NOT_CXCOMMAND:
	cmp.l	#CXM_IEVENT,d0
	bne.s	CXMSGREPLY

	move.l	_CxID,d0
	cmp.l	#POPKEY,d0
	bne.s	NOT_POPKEY

	tst.l	_Window
	bne.s	.NOT

	bsr.w	OPEN_WINDOW
.NOT:	bra.s	CXMSGREPLY

NOT_POPKEY:
	cmp.l	#INSERTKEY,d0
	bne.s	CXMSGREPLY

	move.l	#DateNow,d1
	CALL	DateStamp,_DOSBase

	move.l	_Locale,a0
	lea	DescrString,a1
	lea	DateNow,a2
	lea	DateHook,a3
	CALL	FormatDate,_LocaleBase

CXMSGREPLY:
	move.l	_CxMessage,a1
	EXEC	ReplyMsg
	bra.s	CXMSGLOOP

;--------------------------------------------------------------------

SUB_GETCHAR:
	movem.l	d0-d7/a0-a6,-(a7)

	cmp.l	#NULL,a1
	beq.s	.DONE

	lea	DateIEvent,a3
	move.l	a3,a4
	move.w	#ie_SIZEOF-1,d7
.CLR:	move.b	#0,(a4)+
	dbf	d7,.CLR

	move.l	a1,d0
	move.l	a3,a0
	sub.l	a1,a1
	CALL	InvertKeyMap,_CxBase

	move.l	a3,a0
	CALL	AddIEvents,_CxBase

.DONE:	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------

EXIT:
	bsr.w	FREE_PUBSCREEN
	bsr.w	FREE_TTYPES
	bsr.w	FREE_RDARGS
	bsr.w	SET_CURRENTDIR
	bsr.w	FREE_LOCALE

	bsr.w	REMOVE_CX

	bsr.w	CLOSE_WINDOW

	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT
	bsr.w	CLOSELOCALE
	bsr.w	CLOSECX
	bsr.w	CLOSEGADTOOLS
	bsr.w	CLOSEDISKFONT
	bsr.w	CLOSEICON
	bsr.w	CLOSEDOS

	tst.l	_WBMsg
	beq.s	.NOT

	EXEC	Forbid
	move.l	_WBMsg,a1
	EXEC	ReplyMsg
	EXEC	Permit
.NOT:	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;--------------------------------------------------------------------
; -- Open Window --

OPEN_WINDOW:
	sub.l	a0,a0
	CALL	LockPubScreen,_IntuitionBase
	move.l	d0,_PubScreen
	beq.s	OPEN_FAIL

	move.l	d0,a4				; a4 = public screen
	move.l	sc_Font(a4),a5

	moveq	#0,d0
	move.b	sc_WBorTop(a4),d0		; window border dimensions
	addq.w	#1,d0
	move.w	d0,WinBorTop
	move.b	sc_WBorLeft(a4),d0
	addq.w	#1,d0
	move.w	d0,WinBorLeft

	move.l	#ta_SIZEOF,d0
	move.l	#MEMF_ANY,d1
	EXEC	AllocVec
	move.l	d0,_TextAttr
	beq.s	OPEN_FAIL

	move.l	d0,a1
	move.l	a5,a0
	move.l	#ta_SIZEOF,d0
	EXEC	CopyMem

	move.l	ta_Name(a5),a0
	moveq	#0,d7
.COUNT:	addq.w	#1,d7
	tst.b	(a0)+
	bne.s	.COUNT

	move.l	#MEMF_ANY,d1
	EXEC	AllocVec
	move.l	d0,_FontName
	beq.s	OPEN_FAIL

	move.l	d0,a1
	move.l	ta_Name(a5),a0
	move.l	d7,d0
	EXEC	CopyMem

	move.l	_TextAttr,a0
	move.l	_FontName,a1
	move.l	a1,ta_Name(a0)

	move.l	_PubScreen,a0
	sub.l	a1,a1
	CALL	GetVisualInfoA,_GadToolsBase
	move.l	d0,_VisualInfo

	bsr.w	FREE_PUBSCREEN

	move.l	_TextAttr,_DateAttr

	move.l	_TextAttr,a0
	CALL	OpenDiskFont,_DiskFontBase
	move.l	d0,_Font
	bne.s	OK_FONT

	lea	TopazAttr,a0
	CALL	OpenFont,_GfxBase
	move.l	d0,_Font
	beq.s	OPEN_FAIL

	move.l	#TopazAttr,_DateAttr

OK_FONT:
	move.l	_Font,_DateFont

	move.l	d0,a0
	move.w	tf_YSize(a0),d0
	addq.w	#1,d0
	add.w	d0,WinBorTop

	move.w	tf_YSize(a0),d0
	add.w	#GUISPACE*4,d0
	move.w	d0,GadgetHeight

;--------------------------------------------------------------------
; -- Layout Gadgets --

	moveq	#0,d4
	moveq	#0,d5
	move.w	WinBorLeft,d4			; left-most x-pos
	move.w	WinBorTop,d5			; d5 = current y-pos

	lea	StrWidthStr,a1
	bsr.w	GET_STRLEN
	sub.w	WinBorLeft,d0
	move.w	d0,d6				; d6 = width of string gad

	moveq	#0,d7
	lea	TXT_HotKey,a1			; find out which string
	bsr.w	GET_STRLEN			; is the longest
	move.w	d0,d7				; "Insert Key"

	lea	TXT_PopKey,a1			; "Pop Key"
	bsr.w	GET_STRLEN

	cmp.w	d0,d7
	bgt.s	.N1

	move.w	d0,d7

.N1:	lea	TXT_Descr,a1			; "Description"
	bsr.w	GET_STRLEN

	cmp.w	d0,d7
	bgt.s	.N2

	move.w	d0,d7

.N2:	move.w	WinBorLeft,d0
	add.w	d0,d0
	add.w	WinBorLeft,d0
	add.w	d7,d0
	add.w	d6,d0
	move.l	d0,WinWidth
	move.l	d0,d7				; d7 = window width

;--------------------------------------------------------------------
; -- "Pop Key" string gadget --

	lea	PopKeyS,a0
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d6,gng_Width(a0)
	move.w	d7,d0
	sub.w	d6,d0
	add.w	d4,d0
	sub.w	WinBorLeft,d0
	move.w	d0,gng_LeftEdge(a0)

;--------------------------------------------------------------------
; -- "Insert Key" string gadget --

	lea	HotKeyS,a1
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a1)
	move.w	gng_Width(a0),gng_Width(a1)
	move.w	gng_Height(a0),gng_Height(a1)
	move.w	gng_LeftEdge(a0),gng_LeftEdge(a1)

;--------------------------------------------------------------------
; -- "Description" string gadget --

	lea	DescrS,a1
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a1)
	move.w	gng_Width(a0),gng_Width(a1)
	move.w	gng_Height(a0),gng_Height(a1)
	move.w	gng_LeftEdge(a0),gng_LeftEdge(a1)

;--------------------------------------------------------------------
; -- Bevelbox divider --

	lea	BevDivide,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,bev_topedge(a0)
	move.w	#GUISPACE,bev_height(a0)
	move.w	WinBorLeft,d0
	add.w	#GUISPACE,d0
	move.w	d0,bev_leftedge(a0)
	move.w	d7,d0
	sub.w	#GUISPACE*3,d0
	move.w	d0,bev_width(a0)

;--------------------------------------------------------------------
; -- "Save" button --

	move.w	d7,d0
	lsr.w	#2,d0				; d0 = button width
	move.w	d0,d1
	lsr.w	#1,d1				; d1 = space between buts.

	lea	SaveS,a0
	add.w	#GUISPACE*2,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	WinBorLeft,d3
	add.w	#GUISPACE,d3
	move.w	d3,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d0,gng_Width(a0)

;--------------------------------------------------------------------
; -- "Use" button --

	lea	UseS,a1
	move.w	gng_TopEdge(a0),gng_TopEdge(a1)
	move.w	gng_Height(a0),gng_Height(a1)
	move.w	gng_Width(a0),gng_Width(a1)
	add.w	d0,d3
	add.w	d1,d3
	move.w	d3,gng_LeftEdge(a1)

;--------------------------------------------------------------------
; -- "Cancel" button --

	lea	CancelS,a1
	move.w	gng_TopEdge(a0),gng_TopEdge(a1)
	move.w	gng_Height(a0),gng_Height(a1)
	move.w	gng_Width(a0),gng_Width(a1)
	move.w	d7,d3
	sub.w	d0,d3
	move.w	d3,gng_LeftEdge(a1)

	add.w	GadgetHeight,d5
	add.w	#GUISPACE*2,d5
	sub.w	WinBorTop,d5
	move.l	d5,WinHeight

;--------------------------------------------------------------------
; -- Create Gadgets --

	lea	_FirstGadget,a0
	CALL	CreateContext,_GadToolsBase
	
	lea	GadgetTypes,a3
	lea	GadgetTags,a4
	lea	GadgetStructs,a5
	lea	GadgetList,a6

CREATE_LOOP:
	tst.l	d0
	beq.s	OPEN_FAIL
	
	move.l	d0,a0

	move.l	(a5)+,a1
	cmp.l	#NULL,a1
	beq.s	CREATE_DONE

	move.l	_VisualInfo,gng_VisualInfo(a1)
	move.l	_DateAttr,gng_TextAttr(a1)

	move.l	(a3)+,d0
	move.l	(a4)+,a2	

	move.l	a6,-(a7)
	CALL	CreateGadgetA,_GadToolsBase
	move.l	(a7)+,a6
	
	move.l	d0,(a6)+
	bra.s	CREATE_LOOP

CREATE_DONE:
	SETTAG	#NewWindowTags,WA_Gadgets,_FirstGadget
	SETTAG	#NewWindowTags,WA_InnerWidth,WinWidth
	SETTAG	#NewWindowTags,WA_InnerHeight,WinHeight

;--------------------------------------------------------------------
; -- Open Window --

	sub.l	a0,a0
	lea	NewWindowTags,a1
	CALL	OpenWindowTagList,_IntuitionBase
	move.l	d0,_Window
	beq.s	OPEN_FAIL

	move.l	d0,a0
	move.l	wd_RPort(a0),_RPort
	move.l	wd_UserPort(a0),_UPort

	move.l	_UPort,a0
	moveq	#0,d0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	move.l	d0,_WndSigSet

	move.l	_RPort,a1
	move.l	_DateFont,a0
	CALL	SetFont,_GfxBase

	move.l	_Window,a0
	sub.l	a1,a1
	CALL	GT_RefreshWindow,_GadToolsBase

	SETTAG	#BevTags,GT_VisualInfo,_VisualInfo

	move.l	_RPort,a0
	lea	BevDivide,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	lea	PrefsBuffer,a0
	lea	PrefsBackup,a1
	move.l	#prefs_SIZEOF,d0
	EXEC	CopyMem

	moveq	#1,d0
	rts

OPEN_FAIL:
	bsr.w	CLOSE_WINDOW
	moveq	#0,d0
	rts

;--------------------------------------------------------------------

CLOSE_WINDOW:
	tst.l	_Window
	beq.s	.NOT1

	bsr.w	STRIP_PORT

	move.l	_Window,a0
	CALL	CloseWindow,_IntuitionBase

	move.l	#0,_Window
	move.l	#0,_RPort
	move.l	#0,_UPort
	move.l	#0,_WndSigSet
	move.l	#0,_WndMessage

.NOT1:	tst.l	_FirstGadget
	beq.s	.NOT2

	move.l	_FirstGadget,a0
	CALL	FreeGadgets,_GadToolsBase
	move.l	#0,_FirstGadget

.NOT2:	bsr.w	CLOSE_FONT
	bsr.w	FREE_VI
	rts

;--------------------------------------------------------------------

STRIP_PORT:
	move.l	_WndMessage,d0
	bne.s	.REP

.GET:	move.l	_UPort,a0
	cmp.l	#NULL,a0
	beq.s	.NOT

	CALL	GT_GetIMsg,_GadToolsBase
	tst.l	d0
	beq.s	.NOT

.REP:	move.l	d0,a1
	CALL	GT_ReplyIMsg,_GadToolsBase
	bra.s	.GET
.NOT:	rts

;--------------------------------------------------------------------

FREE_TTYPES:
	tst.l	_ttypes
	beq.s	.NOT

	jsr	_ArgArrayDone
.NOT:	rts

;--------------------------------------------------------------------

SET_CURRENTDIR:
	move.l	_OldCurrent,d1
	cmp.l	#-1,d1
	beq.s	.NOT

	CALL	CurrentDir,_DOSBase
	move.l	#-1,_OldCurrent
.NOT:	rts
	
;--------------------------------------------------------------------

FREE_RDARGS:
	tst.l	_RDArgs
	beq.s	.NOT

	move.l	_RDArgs,d1
	CALL	FreeArgs,_DOSBase
.NOT:	rts

;--------------------------------------------------------------------

FREE_PUBSCREEN:
	tst.l	_PubScreen
	beq.s	.NOT

	sub.l	a0,a0
	move.l	_PubScreen,a1
	CALL	UnlockPubScreen,_IntuitionBase
	move.l	#0,_PubScreen
.NOT:	rts

;--------------------------------------------------------------------

CLOSE_FONT:
	tst.l	_DateFont
	beq.s	.NOT1

	move.l	_DateFont,a1
	CALL	CloseFont,_GfxBase
	move.l	#0,_DateFont

.NOT1:	tst.l	_TextAttr
	beq.s	.NOT2

	move.l	_TextAttr,a1
	EXEC	FreeVec
	move.l	#0,_TextAttr

.NOT2:	tst.l	_FontName
	beq.s	.NOT3

	move.l	_FontName,a1
	EXEC	FreeVec
	move.l	#0,_FontName

.NOT3:	move.l	#0,_DateAttr
	rts

;--------------------------------------------------------------------

FREE_VI:
	tst.l	_VisualInfo
	beq.s	.NOT

	move.l	_VisualInfo,a0
	CALL	FreeVisualInfo,_GadToolsBase
	move.l	#0,_VisualInfo
.NOT:	rts

;--------------------------------------------------------------------

CLOSECX:
	tst.l	_CxBase
	beq.s	.NOT

	CLOSELIB _CxBase
.NOT:	rts

;--------------------------------------------------------------------

FREE_LOCALE:
	tst.l	_Locale
	beq.s	.NOT

	move.l	_Locale,a0
	CALL	CloseLocale,_LocaleBase
	move.l	#0,_Locale
.NOT:	rts

;--------------------------------------------------------------------
CLOSEDISKFONT:
	tst.l	_DiskFontBase
	beq.s	.NOT

	CLOSELIB _DiskFontBase
.NOT:	rts

CLOSEGADTOOLS:
	tst.l	_GadToolsBase
	beq.s	.NOT

	CLOSELIB _GadToolsBase
.NOT:	rts

CLOSELOCALE:
	tst.l	_LocaleBase
	beq.s	.NOT

	CLOSELIB _LocaleBase
.NOT:	rts

CLOSEICON:
	tst.l	_IconBase
	beq.s	.NOT

	CLOSELIB _IconBase
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

CLOSEINT:
	tst.l	_IntuitionBase
	beq.s	.NOT

	CLOSELIB _IntuitionBase
.NOT:	rts

;--------------------------------------------------------------------

REMOVE_CX:
	tst.l	_Broker
	beq.s	.NOT1

	move.l	_Broker,a0
	CALL	DeleteCxObj,_CxBase

.NOT1:	tst.l	_BrokerPort
	beq.s	.NOT2

	move.l	_BrokerPort,a0
	EXEC	DeleteMsgPort
.NOT2:	rts

;--------------------------------------------------------------------

GET_STRLEN:
	lea	StrLenITxt,a0
	move.l	a1,it_IText(a0)
	move.l	_DateAttr,it_ITextFont(a0)
	CALL	IntuiTextLength,_IntuitionBase
	rts

;--------------------------------------------------------------------

SUB_CANCEL:
	lea	PrefsBackup,a0
	lea	PrefsBuffer,a1
	move.l	#prefs_SIZEOF,d0
	EXEC	CopyMem

	bsr.w	CLOSE_WINDOW
	rts

;--------------------------------------------------------------------

SUB_USE:
	move.l	#PrefsENV,d1
	move.l	#MODE_NEWFILE,d2
	CALL	Open,_DOSBase
	move.l	d0,_PrefsLock
	beq.s	.USE

	move.l	d0,d1
	move.l	#PrefsBuffer,d2
	move.l	#prefs_SIZEOF,d3
	CALL	Write,_DOSBase

	move.l	_PrefsLock,d1
	CALL	Close,_DOSBase
	move.l	#0,_PrefsLock

.USE:	bsr.w	CLOSE_WINDOW
	rts

;--------------------------------------------------------------------

SUB_SAVE:
	move.l	#PrefsENV,d1
	move.l	#MODE_NEWFILE,d2
	CALL	Open,_DOSBase
	move.l	d0,_PrefsLock
	beq.s	.SAVE

	move.l	d0,d1
	move.l	#PrefsBuffer,d2
	move.l	#prefs_SIZEOF,d3
	CALL	Write,_DOSBase

	move.l	_PrefsLock,d1
	CALL	Close,_DOSBase
	move.l	#0,_PrefsLock

.SAVE:	move.l	#PrefsENVARC,d1
	move.l	#MODE_NEWFILE,d2
	CALL	Open,_DOSBase
	move.l	d0,_PrefsLock
	beq.s	.SAVE2

	move.l	d0,d1
	move.l	#PrefsBuffer,d2
	move.l	#prefs_SIZEOF,d3
	CALL	Write,_DOSBase

	move.l	_PrefsLock,d1
	CALL	Close,_DOSBase
	move.l	#0,_PrefsLock

.SAVE2:	bsr.w	CLOSE_WINDOW
	rts

;--------------------------------------------------------------------

SUB_POPKEY:
	move.l	gg_SpecialInfo(a1),a1
	move.l	si_Buffer(a1),a1
	lea	PrefsBuffer,a2
	lea	prefs_popkey(a2),a2
	STRCPY	a1,a2
	rts

;--------------------------------------------------------------------

SUB_HOTKEY:
	move.l	gg_SpecialInfo(a1),a1
	move.l	si_Buffer(a1),a1
	lea	PrefsBuffer,a2
	lea	prefs_hotkey(a2),a2
	STRCPY	a1,a2
	rts

;--------------------------------------------------------------------

SUB_DESCR:
	move.l	gg_SpecialInfo(a1),a1
	move.l	si_Buffer(a1),a1
	lea	PrefsBuffer,a2
	lea	prefs_descr(a2),a2
	STRCPY	a1,a2
	rts

;--------------------------------------------------------------------

	section	"Data",data

ExitFlag:	dc.w	0

_ttypes:	dc.l	0
_argc:		dc.l	0
_argv:		dc.l	0

_stdout:	dc.l	0

_WBMsg:		dc.l	0
_OldCurrent:	dc.l	-1

_RDArgs:	dc.l	0

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
_IntuitionBase:	dc.l	0
_IconBase:	dc.l	0
_LocaleBase:	dc.l	0
_DiskFontBase:	dc.l	0
_GadToolsBase:	dc.l	0
_CxBase:	dc.l	0
CxName:		dc.b	"commodities.library",0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
IntuitionName:	dc.b	"intuition.library",0
IconName:	dc.b	"icon.library",0
LocaleName:	dc.b	"locale.library",0
GadToolsName:	dc.b	"gadtools.library",0
DiskFontName:	dc.b	"diskfont.library",0
		VERSTR
		even

;--------------------------------------------------------------------
; -- Commodity --

_BrokerPort:	dc.l	0
_CxSigSet:	dc.l	0

_Broker:	dc.l	0
_CxMessage:	dc.l	0
_PopFilter:	dc.l	0
_HotFilter:	dc.l	0

_CxID:		dc.l	0

New_Broker:	dc.b	NB_VERSION
		dc.b	0
		dc.l	CxTitle
		dc.l	CxFullName
		dc.l	PopKeyString
		dc.w	NBU_UNIQUE!NBU_NOTIFY
		dc.w	COF_SHOW_HIDE
		dc.b	0,0
		dc.l	0
		dc.w	0


CxTitle:	PRG_NAME
		dc.b	0

CxFullName:	PRG_NAME
		dc.b	" V"
		VER
		dc.b	"."
		REV
		dc.b	0
		even

;--------------------------------------------------------------------
; -- locale --

_Locale:	dc.l	0

DateNow:	dcb.b	ds_SIZEOF,0

DateHook:	dcb.b	MLN_SIZE,0
		dc.l	SUB_GETCHAR
		dc.l	0
		dc.l	0

DateIEvent:	dcb.b	ie_SIZEOF,0

;--------------------------------------------------------------------
; -- program arguments --
  
ShellArgs:	dcb.l	2,0
Template:	dc.b	"CX_PRIORITY/N,CX_POPUP/S",0
CxPriTxt:	dc.b	"CX_PRIORITY",0
CxPopUpTxt:	dc.b	"CX_POPUP",0
		even

;-- Defaults --

DefPri:		dc.l	0			; cx_priority = 0
DefPopUp:	dc.l	FALSE
DefPopUpString:	dc.b	"FALSE",0		; cx_popup = false
DefPopKey:	dc.b	"ralt rshift p",0	; cx_popkey = ...
DefHotKey:	dc.b	"ralt rshift d",0	; hotkey = ...
DefDescr:	dc.b	"%c",0
		even

;-- PopKey, HotKey and Description strings --

CxPri:		dc.l	0
CxPopUp:	dc.l	0
CxPopString:	dc.b	"     ",0
		even

_PrefsLock:	dc.l	0			; prefs filehandle

PrefsBuffer:
PopKeyString:	dcb.b	65,0
HotKeyString:	dcb.b	65,0
DescrString:	dcb.b	65,0
		even

PrefsBackup:	dcb.b	prefs_SIZEOF,0
		
PrefsENV:	dc.b	"ENV:InsertDate.prefs",0
PrefsENVARC:	dc.b	"ENVARC:InsertDate.prefs",0
		even

;--------------------------------------------------------------------
; -- "Insert Date" Window

_PubScreen:	dc.l	0

_VisualInfo:	dc.l	0

_Window:	dc.l	0
_UPort:		dc.l	0
_RPort:		dc.l	0
_WndMessage:	dc.l	0
_WndSigSet:	dc.l	0

WinWidth:	dc.l	0
WinHeight:	dc.l	0

WinBorTop:	dc.w	0
WinBorLeft:	dc.w	0

GadgetHeight:	dc.w	0

_Font:		dc.l	0
_TextAttr:	dc.l	0
_FontName:	dc.l	0

_DateAttr:	dc.l	0
_DateFont:	dc.l	0

TopazAttr:	dc.l	TopazName
		dc.w	8
		dc.b	0,FPF_ROMFONT

TopazName:	dc.b	"topaz.font",0
		even

NewWindowTags:	dc.l	WA_Top,0
		dc.l	WA_Left,0
		dc.l	WA_InnerWidth,300
		dc.l	WA_InnerHeight,100
		dc.l	WA_Title,WinTitle
		dc.l	WA_CloseGadget,TRUE
		dc.l	WA_DepthGadget,TRUE
		dc.l	WA_DragBar,TRUE
		dc.l	WA_PubScreen,NULL
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_GADGETUP
		dc.l	WA_Gadgets,0
		dc.l	TAG_DONE

WinTitle:	PRG_NAME
		dc.b	" "
		VER
		dc.b	"."
		REV
		dc.b	0
		even

;--------------------------------------------------------------------

StrLenITxt:	dc.b	0,0
		dc.b	0,0
		dc.w	0,0
		dc.l	0
		dc.l	0
		dc.l	0

StrWidthStr:	dcb.b	20,"a"
		dc.b	0
		even

;--------------------------------------------------------------------
; -- Gadgets --

BevDivide:	dcb.b	bev_SIZEOF,0

BevTags:	dc.l	GTBB_Recessed,TRUE
		dc.l	GT_VisualInfo,0
		dc.l	TAG_DONE

_FirstGadget:	dc.l	0
GadgetList:	dcb.l	NOGADS,0

GadgetTypes:	dc.l	STRING_KIND
		dc.l	STRING_KIND
		dc.l	STRING_KIND
		dc.l	BUTTON_KIND
		dc.l	BUTTON_KIND
		dc.l	BUTTON_KIND
		
GadgetTags:	dc.l	PopKeyTags
		dc.l	HotKeyTags
		dc.l	DescrTags
		dc.l	SaveTags
		dc.l	UseTags
		dc.l	CancelTags

PopKeyTags:	dc.l	GTST_String,PopKeyString
		dc.l	TAG_DONE
HotKeyTags:	dc.l	GTST_String,HotKeyString
		dc.l	TAG_DONE
DescrTags:	dc.l	GTST_String,DescrString
		dc.l	TAG_DONE
SaveTags:	dc.l	TAG_DONE
UseTags:	dc.l	TAG_DONE
CancelTags:	dc.l	TAG_DONE

GadgetStructs:	dc.l	PopKeyS
		dc.l	HotKeyS
		dc.l	DescrS
		dc.l	SaveS
		dc.l	UseS
		dc.l	CancelS
		dc.l	NULL
		
PopKeyS:	dc.w    0               ; gng_LeftEdge
		dc.w    0               ; gng_TopEdge
		dc.w    0               ; gng_Width
		dc.w    0               ; gng_Height
		dc.l    TXT_PopKey      ; gng_GadgetText
		dc.l    0               ; gng_TextAttr
		dc.w    GAD_POPKEY      ; gng_GadgetID
		dc.l    PLACETEXT_LEFT  ; gng_Flags
		dc.l    0               ; gng_VisualInfo
		dc.l    SUB_POPKEY      ; gng_UserData

TXT_PopKey:	dc.b	"PopUp Key",0
		even

HotKeyS:	dc.w    0               ; gng_LeftEdge
		dc.w    0               ; gng_TopEdge
		dc.w    0               ; gng_Width
		dc.w    0               ; gng_Height
		dc.l    TXT_HotKey      ; gng_GadgetText
		dc.l    0               ; gng_TextAttr
		dc.w    GAD_HOTKEY      ; gng_GadgetID
		dc.l    PLACETEXT_LEFT  ; gng_Flags
		dc.l    0               ; gng_VisualInfo
		dc.l    SUB_HOTKEY      ; gng_UserData

TXT_HotKey:	dc.b	"Insert Date",0
		even

DescrS:		dc.w    0               ; gng_LeftEdge
		dc.w    0               ; gng_TopEdge
		dc.w    0               ; gng_Width
		dc.w    0               ; gng_Height
		dc.l    TXT_Descr       ; gng_GadgetText
		dc.l    0               ; gng_TextAttr
		dc.w    GAD_DESCR       ; gng_GadgetID
		dc.l    PLACETEXT_LEFT  ; gng_Flags
		dc.l    0               ; gng_VisualInfo
		dc.l    SUB_DESCR       ; gng_UserData

TXT_Descr:	dc.b	"Date Format",0
		even

SaveS:		dc.w    0               ; gng_LeftEdge
		dc.w    0               ; gng_TopEdge
		dc.w    0               ; gng_Width
		dc.w    0               ; gng_Height
		dc.l    TXT_Save        ; gng_GadgetText
		dc.l    0               ; gng_TextAttr
		dc.w    GAD_SAVE        ; gng_GadgetID
		dc.l    PLACETEXT_IN    ; gng_Flags
		dc.l    0               ; gng_VisualInfo
		dc.l    SUB_SAVE        ; gng_UserData

TXT_Save:	dc.b	"Save",0
		even

UseS:		dc.w    0               ; gng_LeftEdge
		dc.w    0               ; gng_TopEdge
		dc.w    0               ; gng_Width
		dc.w    0               ; gng_Height
		dc.l    TXT_Use         ; gng_GadgetText
		dc.l    0               ; gng_TextAttr
		dc.w    GAD_USE         ; gng_GadgetID
		dc.l    PLACETEXT_IN    ; gng_Flags
		dc.l    0               ; gng_VisualInfo
		dc.l    SUB_USE         ; gng_UserData

TXT_Use:	dc.b	"Use",0
		even
		
CancelS:	dc.w    0               ; gng_LeftEdge
		dc.w    0               ; gng_TopEdge
		dc.w    0               ; gng_Width
		dc.w    0               ; gng_Height
		dc.l    TXT_Cancel      ; gng_GadgetText
		dc.l    0               ; gng_TextAttr
		dc.w    GAD_CANCEL      ; gng_GadgetID
		dc.l    PLACETEXT_IN    ; gng_Flags
		dc.l    0               ; gng_VisualInfo
		dc.l    SUB_CANCEL      ; gng_UserData

TXT_Cancel:	dc.b	"Cancel",0
		even

test:	dc.b	"test!",10,0
