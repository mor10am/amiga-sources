;----------------------------------------------------------------------------------
; Strip files (HTML) of <> chars, and text in between.
; by Morten Amundsen
;
; Code start: Wednesday, 27/09 1995, 07:04 PM
;        end: Thursday, 28/09 1995, 06:19 PM
;
; Coded in PhxAss 4.20
;-----------------------------------------------------------------------------------

	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dos.i"
	include	"exec/memory.i"

	XDEF	_main
	XDEF	_DOSBase

	section	"RemoveHTML",code

_main:	movem.l	d0-d7/a0-a6,-(a7)

	OPENLIB DOSName,37,_DOSBase
	beq.s	EXIT

	move.l	#Template,d1
	move.l	#Arguments,d2
	moveq	#0,d3
	CALL	ReadArgs,_DOSBase
	move.l	d0,_RDArgs
	bne.s	OKARG

	CALL	IoErr,_DOSBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DOSBase
	bra.s	EXIT

OKARG:	move.l	#DOS_FIB,d1
	moveq	#0,d2
	CALL	AllocDosObject,_DOSBase
	move.l	d0,_FIB
	beq.s	EXIT

	lea	Arguments,a0
	move.l	(a0),d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open,_DOSBase
	move.l	d0,_InLock
	beq.s	EXIT

	move.l	d0,d1
	move.l	_FIB,d2
	CALL	ExamineFH,_DOSBase

	move.l	_FIB,a0
	move.l	fib_Size(a0),d0
	move.l	d0,InSize

	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,_InBuffer
	bne.s	ALLOC1

	move.l	#ERR_Mem,d1
	CALL	PutStr,_DOSBase
	bra.s	EXIT

ALLOC1:	move.l	_InLock,d1
	move.l	_InBuffer,d2
	move.l	InSize,d3
	CALL	Read,_DOSBase
	move.l	d0,d7

	bsr.w	CLOSEIN

	cmp.l	InSize,d7
	bne.s	EXIT

	move.l	InSize,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,_OutBuffer
	bne.s	ALLOC2

	move.l	#ERR_Mem,d1
	CALL	PutStr,_DOSBase
	bra.s	EXIT
	
ALLOC2:	bsr.w	STRIP_MOTHERFUCKER

	lea	Arguments,a0
	move.l	4(a0),d1
	move.l	#MODE_NEWFILE,d2
	CALL	Open,_DOSBase
	move.l	d0,_OutLock
	beq.s	EXIT

	move.l	d0,d1
	move.l	_OutBuffer,d2
	move.l	OutSize,d3
	CALL	Write,_DOSBase

	bsr.w	CLOSEOUT

	lea	StatusArgs,a0
	move.l	InSize,(a0)+
	move.l	OutSize,(a0)

	move.l	#Status,d1
	move.l	#StatusArgs,d2
	CALL	VPrintf,_DOSBase

EXIT:	bsr.w	CLEAN

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

CLEAN:	bsr.w	FREEARGS
	bsr.w	CLOSEIN
	bsr.w	CLOSEOUT
	bsr.w	FREEIN
	bsr.w	FREEOUT
	bsr.w	FREEFIB
	bsr.w	CLOSEDOS
	rts

FREEIN:
	tst.l	_InBuffer
	beq.s	.NOT

	move.l	_InBuffer,a1
	EXEC	FreeVec
.NOT:	rts

FREEOUT:
	tst.l	_OutBuffer
	beq.s	.NOT

	move.l	_OutBuffer,a1
	EXEC	FreeVec
.NOT:	rts

CLOSEIN:
	tst.l	_InLock
	beq.s	.NOT

	move.l	_InLock,d1
	CALL	Close,_DOSBase
	move.l	#0,_InLock
.NOT:	rts

CLOSEOUT:
	tst.l	_OutLock
	beq.s	.NOT

	move.l	_OutLock,d1
	CALL	Close,_DOSBase
	move.l	#0,_OutLock
.NOT:	rts

FREEFIB:
	tst.l	_FIB
	beq.s	.NOT

	move.l	#DOS_FIB,d1
	move.l	_FIB,d2
	CALL	FreeDosObject,_DOSBase
.NOT:	rts

FREEARGS:
	tst.l	_RDArgs
	beq.s	.NOT

	move.l	_RDArgs,d1
	CALL	FreeArgs,_DOSBase
.NOT:

CLOSEDOS:
	tst.l	_DOSBase
	beq.s	.NOT

	CLOSELIB _DOSBase
.NOT:	rts

;--------------------------------------------------------------------------------------

STRIP_MOTHERFUCKER:
	move.l	_InBuffer,a0
	move.l	_OutBuffer,a1
	move.l	InSize,d7
	moveq	#0,d6
LOOP:
	move.b	(a0)+,d0
	cmp.b	#13,d0
	beq.s	NEXT
	cmp.b	#'<',d0
	bne.s	COPY
	
	subq.l	#1,d7
	beq.s	OUT

STRIP:	move.b	(a0)+,d0
	cmp.b	#'>',d0
	beq.s	NEXT
	cmp.b	#10,d0
	bne.s	STRIP_NEXT

	move.b	d0,(a1)+
	addq.l	#1,d6

STRIP_NEXT:
	subq.l	#1,d7
	bne	STRIP
	bra.s	OUT

COPY:	move.b	d0,(a1)+
	addq.l	#1,d6
NEXT:	subq.l	#1,d7
	bne.s	LOOP
OUT:	move.l	d6,OutSize
	rts

;--------------------------------------------------------------------------------------

	section	"declr",data

_InLock:	dc.l	0
_OutLock:	dc.l	0
_FIB:		dc.l	0
_RDArgs:	dc.l	0

_DOSBase:	dc.l	0
DOSName:	dc.b	"dos.library",0
		dc.b	"$VER: stripml 37.0 (29.9.95)",10,13,0
		even

Arguments:	dc.l	0,0
Template:	dc.b	"IN/A,OUT/A",0
ERR_Mem:	dc.b	"Not enough memory.",10,0

Status:		dc.b	"IN: %ld, OUT: %ld",10,0
		even

StatusArgs:	dc.l	0,0

InSize:		dc.l	0
OutSize:	dc.l	0
_InBuffer:	dc.l	0
_OutBuffer:	dc.l	0
