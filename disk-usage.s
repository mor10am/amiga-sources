;----------------------------------------------------------------------------
; DU v1.0                                                            12.02.93
; by Morten Amundsen                                       mortena@ifi.uio.no
;----------------------------------------------------------------------------

NULL:			equ	0

MODE_NEW:		equ	1006
MODE_READ:		equ	-2

LF:			equ	10
SPC:			equ	32

DU_SIZEOF:		equ	1316
DU_NEXT:		equ	0
DU_PREV:		equ	4
DU_LOCK:		equ	8
DU_LENGTH:		equ	12
DU_ORIGIN:		equ	16
DU_SUBDIR:		equ	20
DU_INFO:		equ	276

IB_TYPE:		equ	4
IB_NAME:		equ	8
IB_SIZE:		equ	124

ID_BLOCKS:		equ	12
ID_USED:		equ	16
ID_PERBLK:		equ	20

MEMF_CLEAR:		equ	$10000
MEMF_PUBLIC:		equ	$00001

	incdir	"RAM:"
	include	"libraries.s"

;----------------------------------------------------------------------------
;	PROGRAM
;----------------------------------------------------------------------------

	section	CHIP,code_p

S:
	move.l	#BOGUS,a0
	move.l	BOGLEN,d0

	move.l	a0,ARGV
	move.l	d0,ARGC
	clr.b	-1(a0,d0.l)

	move.l	4.w,a6
	moveq	#0,d0
	lea	DOSNAME,a1
	jsr	OpenLibrary(a6)

	move.l	d0,DOSBASE
	beq.w	EXITPRG

	move.l	DOSBASE,a6			; Open console for writing
	move.l	#CONSOLE,d1
	move.l	#MODE_NEW,d2
	jsr	Open(a6)

	move.l	d0,CONBASE
	beq.w	EXITPRG
	
	subq.l	#1,ARGC				; Did we can an argument?
	ble.w	WRITEUSE

	move.l	ARGV,a0
	move.l	ARGC,d0
	cmp.b	#':',-1(a0,d0.w)
	bne.w	WRITEUSE

	move.l	ARGV,d1
	moveq	#MODE_READ,d2
	jsr	Lock(a6)

	move.l	d0,DEVLOCK
	beq.w	NOLOCK

	move.l	DEVLOCK,d1
	move.l	#INFOBLOCK,d2
	jsr	Examine(a6)
	
	tst.l	d0
	beq.w	EXITPRG

;--------------------------------------------------------------------------

	move.l	4.w,a6
	move.l	#DU_SIZEOF,d0
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	jsr	AllocMem(a6)

	move.l	d0,FIRSTSUB
	beq.w	EXITPRG

	move.l	d0,CURRENT
	move.l	d0,a0
	move.l	DEVLOCK,DU_LOCK(a0)
	bsr.w	PATHNAME

	move.l	d0,a0
	lea	DU_SUBDIR(a0),a0
SEEKK:	tst.b	(a0)+
	bne.s	SEEKK

	lea	-1(a0),a0
	move.b	#':',(a0)

DULOOP:
	move.l	CURRENT,a0
	move.l	DU_LOCK(a0),d1

	move.l	DOSBASE,a6
	move.l	#INFOBLOCK,d2
	jsr	ExNext(a6)

	tst.l	d0
	beq.w	FALLBACK

	lea	INFOBLOCK,a0
	tst.l	IB_TYPE(a0)
	bpl.s	CHAINDIR

	bsr.l	RECORDLENGTH	
	bra.s	DULOOP

CHAINDIR:
	bsr.w	SAVEINFO

	move.l	4.w,a6
	move.l	#DU_SIZEOF,d0
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	jsr	AllocMem(a6)

	tst.l	d0
	beq.w	NO_MEM

	move.l	CURRENT,a1

SEARCHFREE:
	tst.l	DU_NEXT(a1)
	beq.s	USEFREE

	move.l	DU_NEXT(a1),a1
	bra.s	SEARCHFREE

USEFREE:
	move.l	d0,a0
	move.l	d0,DU_NEXT(a1)

	move.l	CURRENT,a1
	move.l	a1,DU_ORIGIN(a0)

	lea	DU_SUBDIR(a1),a1
	lea	DU_SUBDIR(a0),a0
COPYP:	move.b	(a1)+,(a0)+
	bne.s	COPYP

	lea	-2(a0),a0
	cmp.b	#':',(a0)+
	beq.s	OKPATH

	move.b	#'/',(a0)+

OKPATH:
	move.l	d0,CURRENT
	bsr.w	APPENDNAME

	move.l	CURRENT,a0
	lea	DU_SUBDIR(a0),a0
	move.l	a0,d1
	move.l	#MODE_READ,d2
	move.l	DOSBASE,a6
	jsr	Lock(a6)

	tst.l	d0
	beq.w	EXITPRG

	move.l	CURRENT,a0
	move.l	d0,DU_LOCK(a0)
	move.l	d0,d1
	move.l	#INFOBLOCK,d2
	jsr	Examine(a6)

	tst.l	d0
	beq.w	EXITPRG
	bra.w	DULOOP	

;---------------------------------------------------------------------------

FALLBACK:
	bsr.w	WRITEUSAGE

	move.l	CURRENT,a0
	move.l	DU_ORIGIN(a0),CURRENT

	tst.l	CURRENT
	beq.w	GETINFO

	bsr.w	LOADINFO
	bra.w	DULOOP

;---------------------------------------------------------------------------

GETINFO:
	lea	LINE,a0
	move.b	#LF,(a0)

	move.l	DOSBASE,a6
	move.l	CONBASE,d1
	move.l	#LINE,d2
	move.l	#1,d3
	jsr	Write(a6)

	move.l	FIRSTSUB,a0
	move.l	DU_LOCK(a0),d1
	move.l	#INFODATA,d2

	move.l	DOSBASE,a6
	jsr	Info(a6)

	moveq	#0,d0
	move.l	FIRSTSUB,a0
DU:	add.l	DU_LENGTH(a0),d0
	move.l	DU_NEXT(a0),a0
	cmp.l	#NULL,a0
	bne.s	DU	

	move.l	d0,WHOLE
a:
	bsr.w	FILLLINE
	move.l	WHOLE,d0	
	bsr.w	HEXDEC

	lea	LINE,a0
	moveq	#0,d0
	moveq	#0,d1
ST1:	addq.w	#1,d1
	cmp.w	#11,d1
	beq.s	STR1
	move.b	(a0),d0
	cmp.b	#SPC,d0
	beq.s	NX1
	cmp.b	#'0',d0
	bne.s	STR1
	move.b	#SPC,(a0)
NX1:	lea	1(a0),a0
	bra.s	ST1

STR1:
	lea	LINE,a0
	lea	12(a0),a0
	lea	BYTES,a1
C1:	move.b	(a1)+,(a0)+
	bne.s	C1

	lea	-1(a0),a0
	move.l	a0,DUMMY

	move.l	FIRSTSUB,a1
	move.l	DU_LOCK(a1),d1

	move.l	#INFODATA,d2

	move.l	DOSBASE,a6
	jsr	Info(a6)	

	lea	INFODATA,a0
	move.l	ID_BLOCKS(a0),d0
	move.l	ID_PERBLK(a0),d1
	mulu	d1,d0
	lsr.l	#4,d0
	move.l	WHOLE,d1
	lsr.l	#4,d1
	mulu	#100,d1
	divu	d0,d1

	move.l	DUMMY,a0
	lea	2(a0),a0

	moveq	#0,d0
	move.w	d1,d0
	clr.w	d1
	swap	d1

	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-1(a0)
	clr.w	d0
	swap	d0

	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-2(a0)
	clr.w	d0
	swap	d0

	move.b	#'.',(a0)+

	divu	#10,d1
	swap	d1
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
	swap	d1

	lea	USED,a1
CPY1:	move.b	(a1)+,(a0)+
	bne.s	CPY1

;--
	move.b	#SPC,-1(a0)
	move.b	#LF,(a0)
	move.b	#NULL,1(a0)

	lea	LINE,a0
	bsr.w	COUNT

	move.l	DOSBASE,a6
	move.l	CONBASE,d1
	move.l	#LINE,d2
	move.l	LENGTH,d3
	jsr	Write(a6)

;---------------------------------------------------------------------------

EXITPRG:
	bsr.s	CLEANUP
	moveq	#0,d0
	rts

;----------------------------------------------------------------------------

SAVEINFO:
	move.l	CURRENT,a0
	lea	DU_INFO(a0),a0
	lea	INFOBLOCK,a1
	move.w	#259,d7
SALOOP:	move.l	(a1)+,(a0)+
	dbf	d7,SALOOP
	rts

LOADINFO:
	move.l	CURRENT,a0
	lea	DU_INFO(a0),a0
	lea	INFOBLOCK,a1
	move.w	#259,d7
LOLOOP:	move.l	(a0)+,(a1)+
	dbf	d7,LOLOOP
	rts

;----------------------------------------------------------------------------
; 	FREE SYSTEM RESOURCES
;----------------------------------------------------------------------------

CLEANUP:
	bsr.s	CLOSELOC
	bsr.s	CLOSEMEM
	bsr.s	CLOSECON
	bsr.s	CLOSEDOS
NOPE:	rts

;----------------------------------------------------------------------------

CLOSEMEM:
	tst.l	FIRSTSUB
	beq.s	NOPE

CLOLOOP:
	move.l	FIRSTSUB,a0
	cmp.l	#NULL,a0
	beq.s	CLOMEM

	move.l	DU_NEXT(a0),FIRSTSUB

	move.l	a0,a1
	move.l	#DU_SIZEOF,d0

	move.l	4.w,a6
	jsr	FreeMem(a6)

	bra.s	CLOLOOP

CLOMEM:
	rts

;----------------------------------------------------------------------------

CLOSELOC:
	tst.l	FIRSTSUB
	beq.s	NOPE

CLOSELOOP:
	move.l	FIRSTSUB,a0
	cmp.l	#NULL,a0
	beq.s	CLOSED

	move.l	DU_LOCK(a0),d1
	move.l	DU_NEXT(a0),FIRSTSUB

	move.l	DOSBASE,a6
	jsr	UnLock(a6)

	bra.s	CLOSELOOP

CLOSED:
	rts

;----------------------------------------------------------------------------

CLOSECON:
	tst.l	CONBASE
	beq.s	NOPE

	move.l	DOSBASE,a6
	move.l	CONBASE,d1
	jsr	Close(a6)
	rts

;----------------------------------------------------------------------------

CLOSEDOS:
	tst.l	DOSBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	DOSBASE,a1
	jsr	CloseLibrary(a6)
	rts

;----------------------------------------------------------------------------
;	ROUTINES
;----------------------------------------------------------------------------

NO_MEM:
	lea	NO_MEM,a0
	bsr	COUNT

	move.l	DOSBASE,a6
	move.l	CONBASE,d1
	move.l	#NOMEMTXT,d2
	move.l	LENGTH,d3
	jsr	Write(a6)
	bra.w	EXITPRG

;----------------------------------------------------------------------------

NOLOCK:
	lea	LOCKTXT,a0
	bsr.w	COUNT

	move.l	DOSBASE,a6
	move.l	CONBASE,d1
	move.l	#LOCKTXT,d2
	move.l	LENGTH,d3
	jsr	Write(a6)
	bra.w	EXITPRG

;----------------------------------------------------------------------------

WRITEUSE:
	lea	USAGETXT,a0
	bsr.w	COUNT

	move.l	DOSBASE,a6
	move.l	CONBASE,d1
	move.l	#USAGETXT,d2
	move.l	LENGTH,d3
	jsr	Write(a6)
	bra.w	EXITPRG

;----------------------------------------------------------------------------

WRITEUSAGE:
	bsr.w	FILLLINE

	move.l	CURRENT,a0
	move.l	DU_LENGTH(a0),d0
	bsr.s	HEXDEC

	moveq	#0,d1
	lea	LINE,a0
STRIP:	addq.w	#1,d1
	cmp.w	#11,d1
	beq.s	STRIPPED

	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#SPC,d0
	beq.s	NEXTST
	cmp.b	#'0',d0
	beq.s	STRIPIT
	bra.s	STRIPPED

STRIPIT:
	move.b	#SPC,(a0)
NEXTST:
	lea	1(a0),a0
	bra.s	STRIP

STRIPPED:
	lea	LINE,a0
	lea	13(a0),a0

	move.l	CURRENT,a1
	lea	DU_SUBDIR(a1),a1

NAMEP:
	move.b	(a1)+,(a0)+
	bne.s	NAMEP

	lea	LINE,a0
	bsr.w	COUNT

	lea	-1(a0),a0
	move.b	#LF,(a0)

	addq.l	#1,LENGTH

	move.l	DOSBASE,a6
	move.l	CONBASE,d1
	move.l	#LINE,d2
	move.l	LENGTH,d3
	jsr	Write(a6)
	rts
;----------------------------------------------------------------------------

HEXDEC:
	lea	LINE,a0
	lea	11(a0),a0

	divu	#1000,d0			; d0 er mer signifikant
	move.l	d0,d1
	and.l	#$0000ffff,d0
	lsr.l	#8,d1
	lsr.l	#8,d1

	move.w	#2,d7
DECLOOP1:
	bsr.s	DECIMAL1
	dbf	d7,DECLOOP1

	move.w	#6,d7
DECLOOP2:
	bsr.s	DECIMAL2
	dbf	d7,DECLOOP2
	rts

;---------------------------------------------------------------------------

DECIMAL1:
	divu	#10,d1
	swap	d1
	add.b	#'0',d1
	move.b	d1,-(a0)
	clr.w	d1
	swap	d1
	rts

DECIMAL2:
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	clr.w	d0
	swap	d0
	rts

;----------------------------------------------------------------------------

FILLLINE:
	lea	LINE,a0
	move.w	#255,d7

LLOOP:	move.b	#SPC,(a0)+
	dbf	d7,LLOOP
	rts

;----------------------------------------------------------------------------

COUNT:
	clr.l	LENGTH

CLOOP:	addq.l	#1,LENGTH
	tst.b	(a0)+
	bne.s	CLOOP

	subq.l	#1,LENGTH
	rts

;----------------------------------------------------------------------------

PATHNAME:
	lea	INFOBLOCK,a1
	lea	IB_NAME(a1),a1
	lea	DU_SUBDIR(a0),a0

PATHLOOP:
	move.b	(a1)+,(a0)+
	bne.s	PATHLOOP
	rts

;----------------------------------------------------------------------------

APPENDNAME:
	lea	INFOBLOCK,a1
	lea	IB_NAME(a1),a1
APPLOOP:
	move.b	(a1)+,(a0)+
	bne.s	APPLOOP
	rts

;----------------------------------------------------------------------------

RECORDLENGTH:
	lea	INFOBLOCK,a0
	move.l	IB_SIZE(a0),d0

	move.l	CURRENT,a1
	add.l	d0,DU_LENGTH(a1)
	rts

;----------------------------------------------------------------------------
;	VARIABLES
;----------------------------------------------------------------------------

	section	VARS,data_p

DEVLOCK:		dc.l	0
CONBASE:		dc.l	0
DOSBASE:		dc.l	0
CONSOLE:		dc.b	"*",0
DOSNAME:		dc.b	"dos.library",0
			even

ARGV:			dc.l	0
ARGC:			dc.l	0

WHOLE:			dc.l	0
			cnop	0,4
INFOBLOCK:		blk.l	260,0
			cnop	0,4
INFODATA:		blk.b	36,0

ARGPATH:		blk.b	256,-1

FIRSTSUB:		dc.l	0
CURRENT:		dc.l	0

LINE:			blk.b	256," "

;----------------------------------------------------------------------------
;	TEXT STRINGS
;----------------------------------------------------------------------------

DUMMY:			dc.l	0
LENGTH:			dc.l	0


BYTES:			dc.b	"Bytes, ",0
USED:			dc.b	"% Used",0
USAGETXT:		dc.b	"DU v1.0 by Morten Amundsen, Feb. 1993",10
			dc.b	"USAGE: du <drive>",10,0

LOCKTXT:		dc.b	"** ERROR! Unknown Device!",10,0
NOMEMTXT:		dc.b	"** ERROR! Not Enough Memory!",10,0

;---------------------------------------------------------------------------

BOGUS:			dc.b	"df0:",0
			even

BOGLEN:			dc.l	5

