;-----------------------------------------------------------------------------
; Program Startup Skeleton	                                    Apr-5-1995
; by Morten Amundsen
;
; Coded in AsmOne 1.25
;-----------------------------------------------------------------------------

VERSION	= 37						; kick version
WB	= 0						; wb startup (0=no)
AGA	= 0						; use AGA (0=no)
STK	= 1						; use new stack (1=yes)

STKSIZE	= 4096						; stack size in bytes

;-----------------------------------------------------------------------------

NAME:	MACRO
	dc.b	"init "
	ENDM

VER:	MACRO
	dc.b	"1"
	ENDM

REV:	MACRO
	dc.b	"0"
	ENDM

DATE:	MACRO
	dc.b	"(5.4.95)"
	ENDM

VERSTR:	MACRO
	dc.b	"$VER: "
	NAME
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
	include	"graphics/gfxbase.i"
	include	"exec/memory.i"

	XDEF	_main
	XDEF	_DOSBase
	XDEF	_GfxBase
	XDEF	_stdout
	XDEF	_stdin

_main:	

	IF STK
	move.l	#STKSIZE,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,_stack
	beq.s	EXIT

	move.l	a7,_oldstack
	move.l	d0,a7
	add.l	#STKSIZE,a7
	ENDIF

	IF WB
	bsr.w	FIND_WBMSG
	ENDIF

	OPENLIB	DOSName,VERSION,_DOSBase
	beq.s	EXIT
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.s	EXIT

	IF AGA
	bsr.w	CHECK_AGA
	ENDIF

	CALL	Output,_DOSBase
	move.l	d0,_stdout

	CALL	Input,_DOSBase
	move.l	d0,_stdin

EXIT:	bsr.w	CLEAN
	movem.l	(a7)+,d0-d7/a0-a6

	IF STK
	tst.l	_stack
	beq.s	.NOT

	move.l	_oldstack,a7
	move.l	_stack,a1
	EXEC	FreeVec	
.NOT:
	ENDIF	

	move.l	ReturnCode,d0
	rts

;-----------------------------------------------------------------------------

	IF WB

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

	ENDIF

;-----------------------------------------------------------------------------

	IF AGA

CHECK_AGA:
	move.b	#0,Aga

	move.l	_GfxBase,a0
	btst	#GFXB_AA_ALICE,gb_ChipRevBits0(a0)
	beq.s	.NOT

	move.b	#1,Aga
.NOT:	rts

	ENDIF

;-----------------------------------------------------------------------------

CLEAN:	bsr.w	CLOSEDOS
	bsr.w	CLOSEGFX

	IF WB
	bsr.s	REPLY_WBMSG
	ENDIF
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

	section	"Data",data

ReturnCode:	dc.l	0

	IF STK
_stack:		dc.l	0
_oldstack:	dc.l	0
	ENDIF

	IF AGA
Aga:		dc.b	0	; 0=no AGA, 1=AGA
		even
	ENDIF

	IF WB
_WBMsg:		dc.l	0
	ENDIF

_stdout:	dc.l	0
_stdin:		dc.l	0

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
		VERSTR

;----------------------------------------------------------------------------
