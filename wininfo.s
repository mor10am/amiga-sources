;-----------------------------------------------------------------------------
; WinInfo							   25-Feb-1994
; Coded in AsmOne v1.16 (Case-sensitive assembly)
;
; by Morten Amundsen
;    181 Ames st., Sharon, MA 02067, USA
;    TEL: (617) 784-6775
;-----------------------------------------------------------------------------

DEV_VERSION:	MACRO
		dc.b	"1.0"		; version of program
		ENDM

DEV_DATE:	MACRO
		dc.b	"25.2.94"	; date of prod. (CBM style)
		ENDM

;-----------------------------------------------------------------------------

	incdir	"INCLUDE:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dosextens.i"
	include	"graphics/gfxbase.i"
	include	"exec/memory.i"
	include	"libraries/commodities.i"
	include	"libraries/reqtools.i"
	include	"intuition/intuition.i"

;-------------------
; EXTRA MACROS
;-------------------

; "ALLOCATE MEMORY"
; ALLOC(Size,Flags)

ALLOC:		MACRO
		move.l	_RememberKey,a0
		move.l	#\1,d0
		move.l	#\2,d1
		CALL	AllocRemember,_IntuitionBase
		ENDM

;------------------------------------------------------------------------------

; "FREE MEMORY"
; DEALLOC(reallyForget)

DEALLOC:	MACRO
		move.l	_RememberKey,a0
		moveq	#\1,d0
		CALL	FreeRemember,_IntuitionBase
		ENDM

;------------------------------------------------------------------------------

; "SET TAG TO VALUE"
; SETTAG(TagList,Tag,Value)

SETTAG:		MACRO
		move.l	\1,a0
		move.l	#\2,d0
.1:		cmp.l	ti_Tag(a0),d0
		beq.s	.2
		lea	ti_SIZEOF(a0),a0
		bra.s	.1
.2:		move.l	\3,ti_Data(a0)
		ENDM

;------------------------------------------------------------------------------

; "RETURN TAG VALUE"
; RETTAG(TagList,Tag)

RETTAG:		MACRO
		move.l	\1,a0
		move.l	#\2,d0
.1:		cmp.l	ti_Tag(a0),d0
		beq.s	.2
		lea	ti_SIZEOF(a0),a0
		bra.s	.1
.2:		move.l	ti_Data(a0),d0
		ENDM

;------------------------------------------------------------------------------

VERSION		= 37		; Version required for development

AGA		= 0		; Uses AGA features? (1 = Yes!)
WBMSG		= 0		; Reply WBMsg? (0 = No!, Set for object)


;-----------------------------------------------------------------------------

EVT_HOTKEY:		equ	1

;-----------------------------------------------------------------------------

	XREF	CreateTask

;-----------------------------------------------------------------------------

	section	"SEGMENT0",code

S:	movem.l	d0-d7/a0-a6,-(a7)

	jsr	CreateTask

	IF	WBMSG
	bsr.w	GET_WBMSG
	ENDIF

	OPENLIB	DosName,VERSION,_DosBase
	beq.w	EXITPRG
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.w	EXITPRG
	OPENLIB	IntuitionName,VERSION,_IntuitionBase
	beq.w	EXITPRG
	OPENLIB	CxName,VERSION,_CxBase
	beq.w	EXITPRG
	OPENLIB	ReqName,38,_ReqBase
	beq.w	EXITPRG
	OPENLIB	IconName,VERSION,_IconBase
	beq.w	EXITPRG

	moveq	#RT_REQINFO,d0
	sub.l	a0,a0
	CALL	rtAllocRequestA,_ReqBase
	move.l	d0,_InfoReq
	beq.w	EXITPRG

	ALLOC	NewBroker_SIZEOF,MEMF_ANY!MEMF_CLEAR
	move.l	d0,_NewBroker
	beq.w	EXITPRG

	CALL	CreateMsgPort,_ExecBase
	move.l	d0,_CxPort
	beq.w	EXITPRG

	move.l	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	MP_SIGBIT(a0),d0
	bset	d0,d1
	move.l	d1,_CxPortSigSet
	
	move.l	_NewBroker,a0
	move.b	#NB_VERSION,nb_Version(a0)
	move.l	#Broker_Name,nb_Name(a0)
	move.l	#Broker_Title,nb_Title(a0)
	move.l	#Broker_Descr,nb_Descr(a0)
	move.l	_CxPort,nb_Port(a0)
	move.w	#NBU_UNIQUE!NBU_NOTIFY,nb_Unique(a0)
	moveq	#0,d0
	CALL	CxBroker,_CxBase
	move.l	d0,_CxBroker
	beq.w	EXITPRG
	
	moveq	#CX_FILTER,d0
	lea	CxHotKey,a0
	sub.l	a1,a1
	CALL	CreateCxObj,_CxBase
	move.l	d0,_CxFilter
	beq.w	EXITPRG

	move.l	_CxBroker,a0
	move.l	_CxFilter,a1
	CALL	AttachCxObj,_CxBase

	moveq	#CX_SEND,d0
	move.l	_CxPort,a0
	move.l	#EVT_HOTKEY,a1
	CALL	CreateCxObj,_CxBase
	move.l	d0,_CxSender
	beq.w	EXITPRG

	move.l	_CxFilter,a0
	move.l	d0,a1
	CALL	AttachCxObj,_CxBase
	
	moveq	#CX_TRANSLATE,d0
	sub.l	a0,a0
	sub.l	a1,a1			; remove hotkey from input stream
	CALL	CreateCxObj,_CxBase
	move.l	d0,_CxTranslate
	beq.w	EXITPRG

	move.l	_CxFilter,a0
	move.l	d0,a1
	CALL	AttachCxObj,_CxBase

	move.l	_CxFilter,a0
	CALL	CxObjError,_CxBase
	tst.l	d0
	bne.w	EXITPRG

	move.l	_CxBroker,a0
	moveq	#TRUE,d0
	CALL	ActivateCxObj,_CxBase

	move.w	#1,CxStarted

WAITLOOP:
	tst.w	ExitFlag
	bne.w	EXITPRG

	move.l	_CxPortSigSet,d0
	or.l	#SIGBREAKF_CTRL_C,d0
	CALL	Wait,_ExecBase

	move.l	d0,d1
	and.l	#SIGBREAKF_CTRL_C,d1		; ^C = Exit!!
	bne.s	EXITPRG

GETMSG:	move.l	_CxPort,a0
	CALL	GetMsg,_ExecBase
	move.l	d0,_CxMessage
	beq.s	WAITLOOP

	move.l	_CxMessage,a0
	CALL	CxMsgID,_CxBase
	move.l	d0,_CxMsgID

	move.l	_CxMessage,a0
	CALL	CxMsgType,_CxBase

	cmp.l	#CXM_IEVENT,d0
	bne.s	.NEXT1

	bsr.w	CHECK_HOTKEY				; hotkey
	bra.s	REPLYMSG

.NEXT1:	cmp.l	#CXM_COMMAND,d0
	bne.s	REPLYMSG

	bsr.w	CHECK_COMMAND				; Cx command

REPLYMSG:
	move.l	_CxMessage,a1
	CALL	ReplyMsg,_ExecBase
	bra.w	WAITLOOP

EXITPRG:
	bsr.s	CLEANUP

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

CLEANUP:
	bsr.w	REMCX
	bsr.w	REMPORT
	bsr.w	CLOSECX

	bsr.w	FREEREQ
	bsr.w	CLOSEREQ

	bsr.w	CLOSEICON

	tst.l	_IntuitionBase
	beq.s	.NOT

	DEALLOC	TRUE

.NOT:	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT
	bsr.w	CLOSEDOS

	IF	WBMSG
	bsr.w	REPLYWB
	ENDIF
	rts

;----------------------------------------------------------------------------

REMPORT:
	tst.l	_CxPort
	beq.s	.NOT

	move.l	_CxPort,a0
	CALL	DeleteMsgPort,_ExecBase
.NOT:	rts

REMCX:
	tst.w	CxStarted
	beq.s	.NOT

	move.l	_CxBroker,a0
	CALL	DeleteCxObjAll,_CxBase

.LOOP:	move.l	_CxPort,a0
	CALL	GetMsg,_ExecBase
	tst.l	d0
	beq.s	.NOT

	move.l	d0,a1
	CALL	ReplyMsg,_ExecBase
	bra.s	.LOOP

.NOT:	rts

CLOSECX:
	tst.l	_CxBase
	beq.s	.NOT

	CLOSELIB _CxBase
.NOT:	rts	

FREEREQ:
	tst.l	_InfoReq
	beq.s	.NOT

	move.l	_InfoReq,a1
	CALL	rtFreeRequest,_ReqBase
.NOT:	rts

CLOSEREQ:
	tst.l	_ReqBase
	beq.s	.NOT

	CLOSELIB _ReqBase
.NOT:	rts

CLOSEICON:
	tst.l	_IconBase
	beq.s	.NOT

	CLOSELIB _IconBase
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

CLOSEDOS:
	tst.l	_DosBase
	beq.s	.NOT

	CLOSELIB _DosBase
.NOT:	rts

;-----------------------------------------------------------------------------

	IF	WBMSG
GET_WBMSG:
	sub.l	a1,a1
	CALL	FindTask,_ExecBase
	move.l	d0,a4

	moveq	#0,d0

	tst.l	pr_CLI(a4)
	bne.s	.CLI

	lea	pr_MsgPort(a4),a0
	CALL	WaitPort,_ExecBase
	lea	pr_MsgPort(a4),a0
	CALL	GetMsg,_ExecBase

.CLI:	move.l	d0,_WBMsg

REPLYWB:
	tst.l	_WBMsg
	beq.s	.NOT

	move.l	_WBMsg,a1
	CALL	ReplyMsg,_ExecBase
.NOT:	rts
	ENDIF

	IF	AGA
CHECK_AGA:
	move.b	#FALSE,HasAGA

	move.l	_GfxBase,a0
	btst	#GFXB_AA_ALICE,gb_ChipRevBits0(a0)
	beq.s	.NO_AGA

	move.b	#TRUE,HasAGA

.NO_AGA:	
	rts
	ENDIF

;-----------------------------------------------------------------------------
; check hotkey
;-----------------------------------------------------------------------------

CHECK_HOTKEY:
	move.l	_CxMsgID,d0

	cmp.l	#EVT_HOTKEY,d0
	bne.w	.NOT

	sub.l	a1,a1
	CALL	FindTask,_ExecBase
	move.l	d0,a2
	move.l	pr_WindowPtr(a2),_OldWindowPtr

	moveq	#0,d0
	CALL	LockIBase,_IntuitionBase
	move.l	d0,_ILock

	move.l	_IntuitionBase,a0
	move.l	ib_ActiveWindow(a0),_ActiveWindow

	move.l	_ILock,a0
	CALL	UnlockIBase,_IntuitionBase

	tst.l	_ActiveWindow
	beq.s	.NOT

	moveq	#0,d0
	move.l	_ActiveWindow,a0
	move.l	a0,pr_WindowPtr(a2)

	lea	HotArgs,a1
	move.l	wd_Title(a0),(a1)+
	move.w	wd_LeftEdge(a0),d0
	move.l	d0,(a1)+
	move.w	wd_TopEdge(a0),d0
	move.l	d0,(a1)+
	move.w	wd_Width(a0),d0
	move.l	d0,(a1)+
	move.w	wd_Height(a0),d0
	move.l	d0,(a1)

	lea	HotBody,a1
	lea	ContinueGad,a2
	move.l	_InfoReq,a3
	lea	HotArgs,a4
	lea	ReqTags,a0
	CALL	rtEZRequestA,_ReqBase

	sub.l	a1,a1
	CALL	FindTask,_ExecBase
	move.l	d0,a2
	move.l	_OldWindowPtr,pr_WindowPtr(a2)

.NOT:	rts

;-----------------------------------------------------------------------------
; check commodity command
;-----------------------------------------------------------------------------

CHECK_COMMAND:
	move.l	_CxMsgID,d0

	cmp.l	#CXCMD_DISABLE,d0
	beq.s	CX_DISABLE
	cmp.l	#CXCMD_ENABLE,d0
	beq.s	CX_DISABLE
	cmp.l	#CXCMD_KILL,d0
	beq.s	CX_KILL
	cmp.l	#CXCMD_UNIQUE,d0
	beq.s	CX_UNIQUE
	rts

;-----------------------------------------------------------------------------

CX_DISABLE:
	move.l	_CxBroker,a0
	moveq	#FALSE,d0
	CALL	ActivateCxObj,_CxBase
	rts

;-----------------------------------------------------------------------------

CX_ENABLE:
	move.l	_CxBroker,a0
	moveq	#TRUE,d0
	CALL	ActivateCxObj,_CxBase
	rts

;-----------------------------------------------------------------------------

CX_KILL:
	move.w	#1,ExitFlag
	rts

;-----------------------------------------------------------------------------

CX_UNIQUE:
	lea	ReallyBody,a1
	lea	ExitGads,a2
	move.l	_InfoReq,a3
	sub.l	a4,a4
	lea	ReqTags,a0
	CALL	rtEZRequestA,_ReqBase
	tst.l	d0
	beq.s	.NOT

	move.w	#1,ExitFlag

.NOT:	rts

;-----------------------------------------------------------------------------

	section	"SEGMENT1",data

HasAGA:			dc.b	0
			even

ExitFlag:		dc.w	0		; 1=Exit!
CxStarted:		dc.w	0		; 0=No!

_ILock:			dc.l	0		; IBaseLock

_InfoReq:		dc.l	0		; reqtools requester

_CxBroker:		dc.l	0		; result of CxBroker()
_NewBroker:		dc.l	0		; new broker structure.
_CxFilter:		dc.l	0		; hotkey
_CxSender:		dc.l	0		; port to recieve hotkey msg
_CxTranslate:		dc.l	0		; remove hotkey-event after use

_CxPort:		dc.l	0		; Broker MsgPort
_CxPortSigSet:		dc.l	0		; _CxPort signal
_CxMessage:		dc.l	0		; address of CxMsg recieved

_CxMsgID:		dc.l	0		; ID of CxMsg
_CxMsgType:		dc.l	0		; Type of CxMsg recieved

_WBMsg:			dc.l	0
_RememberKey:		dc.l	0

_CxBase:		dc.l	0
_GfxBase:		dc.l	0
_IntuitionBase:		dc.l	0
_DosBase:		dc.l	0
_ReqBase:		dc.l	0
_IconBase:		dc.l	0
CxName:			dc.b	"commodities.library",0
GfxName:		dc.b	"graphics.library",0
IntuitionName:		dc.b	"intuition.library",0
DosName:		dc.b	"dos.library",0
ReqName:		dc.b	"reqtools.library",0
IconName:		dc.b	"icon.library",0
			dc.b	"$VER: WinInfo "
			DEV_VERSION
			dc.b	" "
			DEV_DATE
			dc.b	10,13,0
			even

;----------------------------------------------------------------------------
; commodity
;----------------------------------------------------------------------------

CxHotKey:		dc.b	"rawkey lshift lalt x",0
			blk.b	51,0

Broker_Name:		dc.b	"WinInfo",0
Broker_Title:		dc.b	"WinInfo v"
			DEV_VERSION
			dc.b	0
Broker_Descr:		dc.b	"Get info about active window.",0
			even

;----------------------------------------------------------------------------
; reqtools
;----------------------------------------------------------------------------

ReqTags:		dc.l	RT_ReqPos,REQPOS_CENTERSCR
			dc.l	RTEZ_ReqTitle,WinInfoTitle

WinInfoTitle:		dc.b	"WinInfo v"
			DEV_VERSION
			dc.b	0
			even

ReallyBody:		dc.b	"Exit WinInfo?",0

ExitGads:		dc.b	"Yes|No",0
ContinueGad:		dc.b	"Continue",0
			even

;----------------------------------------------------------------------------
; wininfo
;----------------------------------------------------------------------------

_OldWindowPtr:		dc.l	0
_ActiveWindow:		dc.l	0

HotBody:		dc.b	'Title    : "%s"',10
			dc.b	"LeftEdge : %ld",10
			dc.b	"TopEdge  : %ld",10
			dc.b	"Width    : %ld",10
			dc.b	"Height   : %ld",10
			dc.b	0
			even

HotArgs:		dc.l	0
			dc.l	0
			dc.l	0
			dc.l	0
			dc.l	0
