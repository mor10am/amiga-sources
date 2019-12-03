;-----------------------------------------------------------------------------
; System Friendly Startup For AmigaOS Devlopment                   Mar-30-1994
; Coded in AsmOne v1.16 (Case-sensitive assembly)
;
; by   Morten Amundsen
;      Rute 20/14, Hjuksebø,
;      3670 NOTODDEN.
;      NORWAY
; TEL: 35 95 74 57
;-----------------------------------------------------------------------------

	incdir	"INCLUDE:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dosextens.i"
	include	"graphics/gfxbase.i"

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

VERSION		= 36		; Version required for development

AGA		= 0		; Uses AGA features? (1 = Yes!)
WBMSG		= 0		; Reply WBMsg? (0 = No!, Set for object)

;-----------------------------------------------------------------------------

	section	"SEGMENT0",code

S:	movem.l	d0-d7/a0-a6,-(a7)

	IF	WBMSG
	bsr.w	GET_WBMSG
	ENDIF

	OPENLIB	DosName,VERSION,_DOSBase
	beq.w	EXITPRG
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.w	EXITPRG
	OPENLIB	IntuitionName,VERSION,_IntuitionBase
	beq.w	EXITPRG

	CALL	Output,_DOSBase
	move.l	d0,_stdout

	CALL	Input,_DOSBase
	move.l	d0,_stdin

	IF	AGA
	bsr.w	CHECK_AGA
	cmp.b	#FALSE,HasAGA
	beq.w	EXITPRG
	ENDIF

EXITPRG:
	bsr.s	CLEANUP

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

CLEANUP:

	tst.l	_IntuitionBase
	beq.s	.NOT

	DEALLOC	TRUE

.NOT:	bsr.s	CLOSEGFX
	bsr.s	CLOSEINT
	bsr.s	CLOSEDOS

	IF	WBMSG
	bsr.w	REPLYWB
	ENDIF
	rts

;----------------------------------------------------------------------------


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
	tst.l	_DOSBase
	beq.s	.NOT

	CLOSELIB _DOSBase
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

	section	"SEGMENT1",data

HasAGA:			dc.b	0
			even

_stdin:			dc.l	0
_stdout:		dc.l	0

_WBMsg:			dc.l	0
_RememberKey:		dc.l	0

_GfxBase:		dc.l	0
_IntuitionBase:		dc.l	0
_DOSBase:		dc.l	0
GfxName:		dc.b	"graphics.library",0
IntuitionName:		dc.b	"intuition.library",0
DosName:		dc.b	"dos.library",0
			even
