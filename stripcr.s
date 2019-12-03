;-----------------------------------------------------------------------------
; StripCR v1.0                                                     Jan-26-1993
; Coded in AsmOne v1.16 (Case-sensitive assembly)
;
; by Morten Amundsen
;    181 Ames st., Sharon, MA 02067, USA
;    TEL: (617) 784-6775
;-----------------------------------------------------------------------------

	incdir	"INCLUDES:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"dos/dosextens.i"
	include	"graphics/gfxbase.i"
	include	"dos/dos.i"
	include	"exec/memory.i"

;------------------------------------------------------------------------------

VERSION		= 37		; Version required for development

AGA		= 0		; Uses AGA features? (1 = Yes!)
WBMSG		= 1		; Reply WBMsg? (0 = No!, Set for object)

;-----------------------------------------------------------------------------

	section	"SEGMENT0",code

S:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	#RETURN_FAIL,DosReturn

	IF	WBMSG
	bsr.w	GET_WBMSG
	ENDIF

	OPENLIB	DosName,VERSION,_DosBase
	beq.w	EXITPRG

	IF	AGA
	bsr.w	CHECK_AGA
	cmp.b	#FALSE,HasAGA
	beq.w	EXITPRG
	ENDIF

	move.l	#Template,d1
	move.l	#Arguments,d2
	moveq	#0,d3
	CALL	ReadArgs,_DosBase
	move.l	d0,_Args
	bne.s	.OK1

	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.w	EXITPRG

.OK1:	lea	Argument1,a0
	move.l	(a0),d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open,_DosBase
	move.l	d0,_FileHandleIn
	bne.s	.OK2

	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.w	EXITPRG

.OK2:	moveq	#DOS_FIB,d1
	moveq	#0,d0
	CALL	AllocDosObject,_DosBase
	move.l	d0,_FIB
	bne.s	.OK3

	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.w	EXITPRG

.OK3:
	move.l	_FileHandleIn,d1
	move.l	_FIB,d2
	CALL	ExamineFH,_DosBase
	tst.l	d0
	bne.s	.OK4

	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.w	EXITPRG

.OK4:	move.l	_FIB,a0
	move.l	fib_Size(a0),d0
	move.l	d0,FileSize
	move.l	#MEMF_PUBLIC,d1
	CALL	AllocVec,_ExecBase
	move.l	d0,_FileMem
	bne.s	.OK5

	move.l	#ERR_NoMem,d1
	CALL	PutStr,_DosBase
	bra.w	EXITPRG

.OK5:
	move.l	_FileHandleIn,d1
	move.l	_FileMem,d2
	move.l	FileSize,d3
	CALL	Read,_DosBase
	tst.l	d0
	bpl.s	.OK6

	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.w	EXITPRG

.OK6:	bsr.w	CLOSEFILE_IN

	lea	Argument2,a0
	move.l	(a0),d1
	move.l	#MODE_NEWFILE,d2
	CALL	Open,_DosBase
	move.l	d0,_FileHandleOut
	bne.s	.OK7

	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.w	EXITPRG

.OK7:	move.l	FileSize,d0
	move.l	d0,StripSize

	move.l	#MEMF_PUBLIC,d1
	CALL	AllocVec,_ExecBase
	move.l	d0,_StripBuffer
	bne.w	FILL_WHOLE

ALLOCLOOP:
	move.l	StripSize,d0
	lsr.l	#1,d0
	move.l	d0,StripSize

	move.l	#MEMF_PUBLIC,d1
	CALL	AllocVec,_ExecBase
	move.l	d0,_StripBuffer
	beq.s	ALLOCLOOP	

	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	#0,FullSize
	move.l	#0,Accum
	move.l	StripSize,d5
	move.l	FileSize,d6

	move.l	_FileMem,a0
	move.l	_StripBuffer,a1

.LOOP2:	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#13,d0
	beq.w	.NEXT2

	addq.l	#1,d4
	addq.l	#1,FullSize
	move.b	d0,(a1)+

.NEXT2:	addq.l	#1,d7

	cmp.l	d6,d7
	bne.s	.CHECKSTRIP

	move.w	#1,Done
	bra.s	.FLUSH

.CHECKSTRIP:
	cmp.l	d5,d4
	bne.s	.LOOP2

.FLUSH:	movem.l	d1-d7/a0-a6,-(a7)
	move.l	_FileHandleOut,d1
	move.l	_StripBuffer,d2
	move.l	d4,d3
	CALL	Write,_DosBase
	movem.l	(a7)+,d1-d7/a0-a6

	moveq	#0,d4
	move.l	_StripBuffer,a1

	tst.l	d0
	bpl.s	.OKWRITE
	
	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.w	EXITPRG

.OKWRITE:
	tst.w	Done
	bne.w	WRITE_STATUS

	move.l	Accum,d0
	add.l	StripSize,d0
	cmp.l	FileSize,d0
	blt.w	.LOOP2

	sub.l	FileSize,d0
	beq.w	WRITE_STATUS

	move.l	StripSize,d1
	sub.l	d0,d1
	move.l	d1,d5
	move.w	#1,Done
	bra.w	.LOOP2

;-----------------------------------------------------------------------------

FILL_WHOLE:
	moveq	#0,d5
	moveq	#0,d7
	move.l	#0,FullSize
	move.l	FileSize,d6

	move.l	_FileMem,a0
	move.l	_StripBuffer,a1

.LOOP:	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#13,d0
	beq.s	.NEXT

	move.b	d0,(a1)+
	addq.l	#1,d5
	addq.l	#1,FullSize

.NEXT:	addq.l	#1,d7
	cmp.l	d6,d7
	bne.s	.LOOP

	move.l	_FileHandleOut,d1
	move.l	_StripBuffer,d2
	move.l	d5,d3
	CALL	Write,_DosBase
	tst.l	d0
	bpl.s	WRITE_STATUS

	CALL	IoErr,_DosBase
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault,_DosBase
	bra.s	EXITPRG

WRITE_STATUS:
	lea	StringArgs,a0
	move.l	FileSize,(a0)
	move.l	StripSize,4(a0)
	move.l	FullSize,8(a0)

	move.l	#String,d1
	move.l	#StringArgs,d2
	CALL	VPrintf,_DosBase

	move.l	#RETURN_OK,DosReturn
EXITPRG:
	bsr.s	CLEANUP

	movem.l	(a7)+,d0-d7/a0-a6
	move.l	DosReturn,d0
	rts

CLEANUP:
	bsr.w	FREEMEMBUF
	bsr.w	FREEMEMFILE
	bsr.w	FREEOBJ
	bsr.w	CLOSEFILE_IN
	bsr.w	CLOSEFILE_OUT
	bsr.w	FREEARGS

	bsr.w	CLOSEDOS

	IF	WBMSG
	bsr.w	REPLYWB
	ENDIF
	rts

FREEMEMBUF:
	tst.l	_StripBuffer
	beq.s	.NOT

	move.l	_StripBuffer,a1
	CALL	FreeVec,_ExecBase
.NOT:	rts

FREEMEMFILE:
	tst.l	_FileMem
	beq.s	.NOT

	move.l	_FileMem,a1
	CALL	FreeVec,_ExecBase
.NOT:	rts

FREEOBJ:
	tst.l	_FIB
	beq.s	.NOT

	moveq	#DOS_FIB,d1
	move.l	_FIB,d2
	CALL	FreeDosObject,_DosBase
.NOT:	rts

CLOSEFILE_IN:
	tst.l	_FileHandleIn
	beq.s	.NOT

	move.l	_FileHandleIn,d1
	CALL	Close,_DosBase
	move.l	#0,_FileHandleIn
.NOT:	rts

CLOSEFILE_OUT:
	tst.l	_FileHandleOut
	beq.s	.NOT

	move.l	_FileHandleOut,d1
	CALL	Close,_DosBase
	move.l	#0,_FileHandleOut
.NOT:	rts

FREEARGS:
	tst.l	_Args
	beq.s	.NOT

	move.l	_Args,d1
	CALL	FreeArgs,_DosBase
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

	section	"SEGMENT1",data

HasAGA:			dc.b	0
			even

_FIB:			dc.l	0
_FileMem:		dc.l	0
_StripBuffer:		dc.l	0
_Args:			dc.l	0
_FileHandleIn:		dc.l	0
_FileHandleOut:		dc.l	0

_WBMsg:			dc.l	0

_DosBase:		dc.l	0
DosName:		dc.b	"dos.library",0
			even

Done:			dc.w	0
Accum:			dc.l	0
StripSize:		dc.l	0
FileSize:		dc.l	0
FullSize:		dc.l	0
DosReturn:		dc.l	0

Arguments:
Argument1:		dc.l	0
Argument2:		dc.l	0
StringArgs:		dc.l	0,0,0

			dc.b	"$VER: StripCR 1.0 (Jan-26-1993)",10,13,0
Template:		dc.b	"SOURCE/A,DESTINATION/A",0
String:			dc.b	"File Size: %ld, Buffer Size: %ld, Stripped "
			dc.b	"Size: %ld.",10,0
ERR_NoMem:		dc.b	"Out of memory!",10,0
