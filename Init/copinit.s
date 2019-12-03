;-----------------------------------------------------------------------------
; Copper & Interrupt Startup (Complete System Takeover)            Jan-06-1994
;
; by Morten Amundsen
;    181 Ames st.,Sharon, MA 02067, USA.
;    TEL: (617) 784-6775
;-----------------------------------------------------------------------------

WBMsg:		equ	0		; Include WBMsg handling? (0 = No!)
NewCop:		equ	1		; New Copperlist (1 = Yes!)
Lev3:		equ	1		; Use LEVEL3 Interrupt (1 = Yes!)
Aga:		equ	0		; Needs AGA? (1 = Yes!)

;------------------------------------------------------------------------------

ROMVER:		equ	39

NAME:		MACRO
		dc.b	"copinit"
		ENDM

VERSION:	MACRO
		dc.b	"1.0"
		ENDM

DATE:		MACRO
		dc.b	"(4.3.94)"
		ENDM

;-----------------------------------------------------------------------------

	incdir	"INCLUDE:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dosextens.i"
	include	"exec/memory.i"
	include	"graphics/gfxbase.i"
	include	"hardware/intbits.i"
	include	"hardware/cia.i"
	include	"intuition/intuitionbase.i"

;-----------------------------------------------------------------------------

	XDEF	_main
	XDEF	_IntuitionBase
	XDEF	_GfxBase


	section	"SEGMENT0",code

_main:	movem.l	d0-d7/a0-a6,-(a7)

	IF	WBMsg
	bsr.w	GET_WBENCHMSG
	ENDIF

	OPENLIB	IntuiName,ROMVER,_IntuitionBase
	beq.w	EXITPRG
	OPENLIB	GfxName,ROMVER,_GfxBase
	beq.w	EXITPRG

	bsr.w	INIT_PROGRAM
	bne.w	EXITPRG

	IF	NewCop
	bsr.w	NEW_COPPER
	ENDIF

	IF	Lev3
	bsr.w	ADD_INTERRUPT
	ENDIF

	IF	Aga
	tst.b	AGA
	beq.s	EXITPRG
	ENDIF

;-----------------------------------------------------------------------------





;-----------------------------------------------------------------------------

EXITPRG:
	bsr.s	CLEANUP

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

CLEANUP:
	IF	Lev3
	bsr.s	CLOSEINTER
	ENDIF

	IF	NewCop
	bsr.s	CLOSECOP
	ENDIF

	tst.l	_IntuitionBase
	beq.s	.NOT

	DEALLOC	TRUE

.NOT:	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT

	IF	WBMsg
	bsr.w	REPLYWB
	ENDIF
	rts

;-----------------------------------------------------------------------------

	IF	Lev3
CLOSEINTER:
	tst.b	INT
	beq.s	.NOT

	moveq	#INTB_VERTB,d0
	lea	Interrupt,a1
	CALL	RemIntServer,EXECBASE
.NOT:	rts
	ENDIF

	IF	NewCop
CLOSECOP:
	tst.b	COP
	beq.s	.NOT

	CALL	WaitBlit,_GfxBase
	CALL	DisownBlitter,_GfxBase

	move.l	_IntuitionBase,a1
	lea	ib_ViewLord(a1),a1
	CALL	LoadView,_GfxBase
	CALL	WaitTOF,_GfxBase
	CALL	WaitTOF,_GfxBase

	move.l	_GfxBase,a0
	move.l	gb_copinit(a0),$DFF080
	move.w	#0,$DFF088

.NOT:	rts
	ENDIF

CLOSEINT:
	tst.l	_IntuitionBase
	beq.s	.NOT

	CLOSELIB _IntuitionBase
.NOT:	rts

CLOSEGFX:
	tst.l	_GfxBase
	beq.s	.NOT

	CLOSELIB _GfxBase
.NOT:	rts

	IF	WBMsg
REPLYWB:
	tst.l	_WBMessage
	beq.s	.NOT

	move.l	_WBMessage,a1
	CALL	ReplyMsg,_ExecBase
.NOT:	rts
	ENDIF

;------------------------------------------------------------------------------

	IF	WBMsg
GET_WBENCHMSG:
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
.CLI:	move.l	d0,_WBMessage
	rts
	ENDIF

	IF	Lev3
ADD_INTERRUPT:
	moveq	#INTB_VERTB,d0
	lea	$DFF000,a0
	lea	Interrupt,a1
	CALL	AddIntServer,EXECBASE
	move.b	#1,INT
	rts
	ENDIF

	IF	NewCop
NEW_COPPER:
	CALL	WaitBlit,_GfxBase
	CALL	OwnBlitter,_GfxBase

	sub.l	a1,a1
	CALL	LoadView,_GfxBase
	CALL	WaitTOF,_GfxBase
	CALL	WaitTOF,_GfxBase

	IF	Aga
	bsr.w	CHECK_AGA
	bsr.w	FIX_V39BUG
	ENDIF

	move.l	#Copper,$DFF080
	move.w	#0,$DFF088
	move.b	#1,COP
	rts
	ENDIF

;-----------------------------------------------------------------------------

	IF	Aga
CHECK_AGA:
	move.b	#0,AGA

	move.l	_GfxBase,a0
	btst	#GFXB_AA_ALICE,gb_ChipRevBits0(a0)
	beq.s	.NOT

	move.b	#1,AGA
.NOT:	rts

FIX_V39BUG:
	tst.b	AGA
	beq.s	.NOT

	move.w	#0,$DFF1FC
	move.w	#0,$DFF106

.NOT:	rts
	ENDIF

;-----------------------------------------------------------------------------

INIT_PROGRAM:
	IF	NewCop
	move.l	#NullSprite,d0
	move.w	d0,SLO0
	swap	d0
	move.w	d0,SHI0
	swap	d0
	move.w	d0,SLO1
	swap	d0
	move.w	d0,SHI1
	swap	d0
	move.w	d0,SLO2
	swap	d0
	move.w	d0,SHI2
	swap	d0
	move.w	d0,SLO3
	swap	d0
	move.w	d0,SHI3
	swap	d0
	move.w	d0,SLO4
	swap	d0
	move.w	d0,SHI4
	swap	d0
	move.w	d0,SLO5
	swap	d0
	move.w	d0,SHI5
	swap	d0
	move.w	d0,SLO6
	swap	d0
	move.w	d0,SHI6
	swap	d0
	move.w	d0,SLO7
	swap	d0
	move.w	d0,SHI7
	ENDIF

	moveq	#0,d0
	rts

INIT_FAIL:
	moveq	#1,d0
	rts

;------------------------------------------------------------------------------

	IF	Lev3
INT_CODE:
	movem.l	d0-d7/a0-a6,-(a7)


	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts
	ENDIF

;-----------------------------------------------------------------------------

	section	"SEGMENT1",data

CLR:		blk.l	16,0

;----------------------
; Verification flags
;----------------------

AGA:		dc.b	0		; AGA?
COP:		dc.b	0		; COPPER?
INT:		dc.b	0		; INTERRUPT?
		even

;---------------------
; System structures
;---------------------

_WBMessage:			dc.l	0

;-------------------------
; Libraries
;-------------------------

_IntuitionBase:		dc.l	0
_GfxBase:		dc.l	0
IntuiName:		dc.b	"intuition.library",0
GfxName:		dc.b	"graphics.library",0

			dc.b	"$VER: copinit v1.0 (01/06/94)",10,13,0
			even

;----------------------------
; Level3 VBLANK Interrupt
;----------------------------

	IF	Lev3
Interrupt:
	dc.l	0
	dc.l	0
	dc.b	NT_INTERRUPT
	dc.b	1
	dc.l	IntName
	dc.l	NULL
	dc.l	INT_CODE

IntName:
	dc.b	"INIT_LEVEL3 INTERRUPT",0
	even
	ENDIF

;-----------------------------------------------------------------------------

	section	"SEGMENT2",data_c

	IF	NewCop
Copper:
	dc.w	$008E,$2C81,$0090,$f4C1,$0092,$0038,$0094,$00D0
	dc.w	$0100,$0000,$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010A,$0000
	dc.w	$0106,$0002
	dc.w	$0180,$0000,$0182,$0999

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
HI1:	dc.w	$0000
	dc.w	$00E2
LO1:	dc.w	$0000
	dc.w	$00E4
HI2:	dc.w	$0000
	dc.w	$00E6
LO2:	dc.w	$0000
	dc.w	$00E8
HI3:	dc.w	$0000
	dc.w	$00EA
LO3:	dc.w	$0000
	dc.w	$00EC
HI4:	dc.w	$0000
	dc.w	$00EE
LO4	dc.w	$0000
	dc.w	$FFFF,$FFFE
	ENDIF

NullSprite:		blk.l	6,0
