;-----------------------------------------------------------------------------
; Program Startup Skeleton
; by Morten Amundsen
;
; Onsdag, 13. Desember 1995, kl. 14:13
;-----------------------------------------------------------------------------

VERSION	= 39						; kick version
WB	= 1						; wb startup (0=no)
AGA	= 0						; use AGA (0=no)

;-----------------------------------------------------------------------------

NAME:	MACRO
	dc.b	"init"
	ENDM

VER:	MACRO
	dc.b	"1"
	ENDM

REV:	MACRO
	dc.b	"0"
	ENDM

DATE:	MACRO
	dc.b	"(14.11.95)"
	ENDM

VERSTR:	MACRO
	dc.b	"$VER: "
	NAME
	dc.b	" "
	VER
	dc.b	"."
	REV
	dc.b	" "
	DATE
	dc.b	10,13,0
	ENDM

;-----------------------------------------------------------------------------

	incdir	"include:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dosextens.i"
	include	"graphics/gfxbase.i"

	XDEF	_main
	XDEF	_SysBase
	XDEF	_DOSBase
	XDEF	_GfxBase
	XDEF	_IntuitionBase

_main:	movem.l	d0-d7/a0-a6,-(a7)

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

	IF AGA
	bsr.w	CHECK_AGA
	tst.b	Aga
	beq.s	EXIT
	ENDIF

;--------------------------------------------------------------------

	



;--------------------------------------------------------------------

EXIT:	bsr.w	CLOSEDOS
	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT

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

;-----------------------------------------------------------------------------

	IFD	AGA
CHECK_AGA:
	move.b	#0,Aga

	move.l	_GfxBase,a0
	btst	#GFXB_AA_ALICE,gb_ChipRevBits0(a0)
	beq.s	.NOT

	move.b	#1,Aga
.NOT:	rts
	ENDC

;----------------------------------------------------------------------------

	section	"Data",data

	IFD	AGA
Aga:		dc.b	0	; 0=no AGA, 1=AGA
		even
	ENDC

;--------------------------------------------------------------------

_WBMsg:		dc.l	0

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
_IntuitionBase:	dc.l	0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
IntuitionName:	dc.b	"intuition.library",0
		VERSTR
		even

;----------------------------------------------------------------------------
