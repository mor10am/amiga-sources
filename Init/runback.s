;---------------------------------------------------------------------------
; runback hunk                                                       18.5.95
;---------------------------------------------------------------------------

VERSION	= 37						; kick version
RB	= 0						; rback startup (0=no)
AGA	= 0						; use AGA (0=no)

;-----------------------------------------------------------------------------

NAME:	MACRO
	dc.b	"runback_init"
	ENDM

VER:	MACRO
	dc.b	"1"
	ENDM

REV:	MACRO
	dc.b	"0"
	ENDM

DATE:	MACRO
	dc.b	"(18.5.95)"
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

	IF	RB

	section	"runback",code

RBACK:	sub.l	a1,a1
	EXEC	FindTask
	move.l	d0,a4

	moveq	#0,d0
	tst.l	pr_CLI(a4)
	bne.s	.CLI

	lea	pr_MsgPort(a4),a0
	EXEC	WaitPort
	lea	pr_MsgPort(a4),a0
	EXEC	GetMsg

.CLI:	move.l	d0,d7

	OPENLIB	DName(pc),0,_DBase
	beq.s	.EXIT

	move.l	pr_CurrentDir(a4),d1
	CALL	DupLock,_DBase
	move.l	d0,_CurrentDir

	EXEC	Forbid

	move.l	#ProgramName,d1
	moveq	#0,d2
	move.b	LN_PRI(a4),d2
	lea	RBACK-4(pc),a0
	move.l	(a0),d3
	clr.l	(a0)
	move.l	#4096,d4
	CALL	CreateProc,_DBase

	EXEC	Permit
	CLOSELIB _DBase

.EXIT:	tst.l	d7
	beq.s	.EXIT2

	EXEC	Forbid

	move.l	d7,a1
	EXEC	ReplyMsg

.EXIT2:	moveq	#0,d0
	rts

_DBase:			dc.l	0
DName:			dc.b	"dos.library",0
			even

;=========================================================================

	section	"Program",code

s:	bsr.w	MAIN

	EXEC	Forbid

	move.l	_CurrentDir(pc),d1
	CALL	UnLock,_DBase

	lea	s-4(pc),a0
	move.l	a0,d1
	lsr.l	#2,d1
	CALL	UnLoadSeg,_DBase
	moveq	#0,d0
	rts

_CurrentDir:		dc.l	0

ProgramName:		NAME
			dc.b	0
			cnop	0,2

	ENDIF

;----------------------------------------------------------------------------

MAIN:	OPENLIB	DOSName,VERSION,_DOSBase
	beq.s	EXIT
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.s	EXIT

	CALL	Output,_DOSBase
	move.l	d0,_stdout

	IF AGA
	bsr.w	CHECK_AGA
	ENDIF

EXIT:	bsr.w	CLEAN
	moveq	#0,d0
	rts

;----------------------------------------------------------------------------

CLEAN:	bsr.w	CLOSEDOS
	bsr.w	CLOSEGFX
	rts

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

	IF AGA
CHECK_AGA:
	move.b	#0,Aga

	move.l	_GfxBase,a0
	btst	#GFXB_AA_ALICE,gb_ChipRevBits0(a0)
	beq.s	.NOT

	move.b	#1,Aga
.NOT:	rts
	ENDIF

;----------------------------------------------------------------------------

	section	"data",data

_stdout:	dc.l	0

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
		VERSTR
