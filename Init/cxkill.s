;-----------------------------------------------------------------------------
; System Friendly Startup For AmigaOS Devlopment                   Jan-06-1994
; Coded in AsmOne v1.16 (Case-sensitive assembly)
;
; by Morten Amundsen
;    181 Ames st., Sharon, MA 02067, USA
;    TEL: (617) 784-6775
;-----------------------------------------------------------------------------

	incdir	"INCLUDE:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dosextens.i"
	include	"graphics/gfxbase.i"
	include	"libraries/commodities.i"
	include	"exec/memory.i"

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

VERSION		= 39		; Version required for development

AGA		= 1		; Uses AGA features? (1 = Yes!)
WBMSG		= 0		; Reply WBMsg? (0 = No!, Set for object)

;-----------------------------------------------------------------------------

	section	"SEGMENT0",code

S:	movem.l	d0-d7/a0-a6,-(a7)

	IF	WBMSG
	bsr.w	GET_WBMSG
	ENDIF

	OPENLIB	DosName,VERSION,_DosBase
	beq.w	EXITPRG
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.w	EXITPRG
	OPENLIB	IntuitionName,VERSION,_IntuitionBase
	beq.w	EXITPRG
	OPENLIB	CommodityName,VERSION,_CommodityBase
	beq.s	EXITPRG

	IF	AGA
	bsr.w	CHECK_AGA
	cmp.b	#FALSE,HasAGA
	beq.w	EXITPRG

;------------------------------------------------------------------------------

	move.l	#LH_SIZE,d0
	move.l	#MEMF_PUBLIC,d1
	CALL	AllocVec,_ExecBase			; Allocate mem for
	move.l	d0,_CxList				; Commoditylist
	beq.s	EXITPRG
	
	move.l	_CxList,a0
	NEWLIST	a0					; init list

	move.l	_CxList,a0
	CALL	CopyBrokerList,_CommodityBase		; fill list with
							; commodities

	move.l	#CXCMD_DISABLE,d7			; send CXCMD_DISABLE
	bsr.w	BROKER_COMMAND

	move.l	#CXCMD_ENABLE,d7			; send CXCMD_ENABLE
	bsr.w	BROKER_COMMAND

;-----------------------------------------------------------------------------

EXITPRG:
	bsr.s	CLEANUP

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

CLEANUP:
	bsr.w	FREECXLIST
	bsr.w	FREELIST

	tst.l	_IntuitionBase
	beq.s	.NOT

	DEALLOC	TRUE

.NOT:	bsr.w	CLOSECOM
	bsr.s	CLOSEGFX
	bsr.s	CLOSEINT
	bsr.w	CLOSEDOS

	IF	WBMSG
	bsr.w	REPLYWB
	ENDIF
	rts

;---------------------------------------------------------------------------

FREECXLIST:
	tst.l	_CxList
	beq.s	.NOT

	move.l	_CxList,a0
	CALL	FreeBrokerList,_CommodityBase
.NOT:	rts

FREELIST:
	tst.l	_CxList
	beq.s	.NOT

	move.l	_CxList,a1
	CALL	FreeVec,_ExecBase
.NOT:	rts

CLOSECOM:
	tst.l	_CommodityBase
	beq.s	.NOT

	CLOSELIB _CommodityBase
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

BROKER_COMMAND:
	move.l	_CxList,a0			; list of commodities
.LOOP:
	TSTNODE	a0,a0				; get next node (end?) 
	beq.s	.EXIT				; yes!

	movem.l	d0-d7/a0-a6,-(a7)

	lea	bc_Name(a0),a0			; get commodity name
	move.l	d7,d0
	CALL	BrokerCommand,_CommodityBase	; send command (D7)

	movem.l	(a7)+,d0-d7/a0-a6
	bra.s	.LOOP				; next...

.EXIT:	rts

;-----------------------------------------------------------------------------

	section	"SEGMENT1",data

HasAGA:			dc.b	0
			even

_WBMsg:			dc.l	0
_RememberKey:		dc.l	0

_CxList:		dc.l	0

_GfxBase:		dc.l	0
_IntuitionBase:		dc.l	0
_DosBase:		dc.l	0
_CommodityBase:		dc.l	0
CommodityName:		dc.b	"commodities.library",0
GfxName:		dc.b	"graphics.library",0
IntuitionName:		dc.b	"intuition.library",0
DosName:		dc.b	"dos.library",0
			even
