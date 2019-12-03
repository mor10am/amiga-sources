;---------------------------------------------------------------------------
; IFF Picture Pixel Count v1.0 by Morten Amundsen
;---------------------------------------------------------------------------

	incdir	"INCLUDES:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"libraries/iff.i"
	include	"graphics/gfx.i"
	include	"libraries/reqtools.i"
	include	"graphics/view.i"
	include	"exec/memory.i"
	include	"intuition/screens.i"

;---------------------------------------------------------------------------

	section	SEGMENT0,code

S:	movem.l	d0-d7/a0-a6,-(a7)

	OPENLIB IFFName,0,_IffBase
	beq.w	EXITPRG
	OPENLIB	GraphicsName,37,_GfxBase
	beq.w	EXITPRG
	OPENLIB	ReqToolsName,0,_ReqBase
	beq.w	EXITPRG
	OPENLIB	DosName,37,_DosBase
	beq.w	EXITPRG
	OPENLIB	UtilityName,37,_UtilityBase
	beq.w	EXITPRG
	OPENLIB	IntuitionName,37,_IntuitionBase
	beq.w	EXITPRG

	moveq	#RT_FILEREQ,d0
	sub.l	a0,a0
	CALL	rtAllocRequestA,_ReqBase
	move.l	d0,Request
	beq.w	EXITPRG

	move.l	d0,a1
	lea	Filename,a2
	lea	ReqTitle,a3
	lea	ReqTags,a0
	CALL	rtFileRequestA,_ReqBase
	tst.l	d0
	beq.w	EXITPRG

	bsr.w	MAKEFILENAME
	bsr.w	FREEREQ

	lea	CompleteName,a0
	moveq	#IFFL_MODE_READ,d0
	CALL	IFFL_OpenIFF,_IffBase
	move.l	d0,Handle
	bne.s	OK_HANDLE

	move.l	#ERR_NoIFF,d1
	CALL	PutStr,_DosBase
	bra.w	EXITPRG

OK_HANDLE:
	move.l	Handle,a1
	CALL	IFFL_GetViewModes,_IffBase
	move.w	d0,ViewModes

	move.l	#V_HAM,d1
	and.l	d1,d0
	beq.s	OK_NOHAM

	move.l	#ERR_HAM,d1
	CALL	PutStr,_DosBase
	bra.w	EXITPRG

OK_NOHAM:
	move.l	Handle,a1
	CALL	IFFL_GetBMHD,_IffBase
	move.l	d0,Header
	beq.w	EXITPRG

	move.l	d0,a0
	move.w	bmh_Width(a0),Width
	move.w	bmh_Height(a0),Height
	move.b	bmh_nPlanes(a0),Planes

	moveq	#0,d0
	moveq	#1,d1
	move.b	Planes,d0
	lsl.w	d0,d1
	move.w	d1,NoColors
	add.w	d1,d1
	move.l	d1,ColMemUse
	add.w	d1,d1
	move.l	d1,PixMemUse

	move.l	ColMemUse,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALL	AllocMem,EXECBASE
	move.l	d0,Colors
	beq.w	EXITPRG

	move.l	PixMemUse,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALL	AllocMem,EXECBASE
	move.l	d0,Pixels
	beq.w	EXITPRG	

	move.l	Handle,a1
	move.l	Colors,a0
	CALL	IFFL_GetColorTab,_IffBase
	tst.l	d0
	beq.w	EXITPRG

	lea	IFF_Bitmap,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	Planes,d0
	move.w	Width,d1
	move.w	Height,d2
	CALL	InitBitMap,_GfxBase

	moveq	#0,d7
	move.b	Planes,d7
	subq.w	#1,d7

	lea	IFF_Bitmap,a0
	lea	bm_Planes(a0),a0

ALLOCLOOP:
	moveq	#0,d0
	moveq	#0,d1
	move.w	Width,d0
	move.w	Height,d1
	movem.l	d7/a0,-(a7)
	CALL	AllocRaster,_GfxBase
	movem.l	(a7)+,d7/a0

	tst.l	d0
	beq.w	EXITPRG

	move.l	d0,(a0)+
	dbf	d7,ALLOCLOOP

	move.l	Handle,a1
	lea	IFF_Bitmap,a0
	CALL	IFFL_DecodePic,_IffBase
	tst.l	d0
	bne.s	OK_DECODE

	move.l	#ERR_Decode,d1
	CALL	PutStr,_DosBase
	bra.w	EXITPRG

OK_DECODE:
	lea	HNewScreen,a0
	move.l	Header,a1
	move.w	bmh_PageWidth(a1),ns_Width(a0)
	move.w	bmh_PageHeight(a1),ns_Height(a0)
	move.b	bmh_nPlanes(a1),ns_Depth+1(a0)
	move.w	ViewModes,ns_ViewModes(a0)

	CALL	OpenScreen,_IntuitionBase
	move.l	d0,HScreen
	beq.w	EXITPRG

	move.l	d0,a0
	lea	sc_ViewPort(a0),a0
	move.l	Colors,a1
	moveq	#0,d0
	move.w	NoColors,d0
	CALL	LoadRGB4,_GfxBase

	moveq	#0,d0
	moveq	#0,d1
	move.w	Width,d0
	move.w	Height,d1
	CALL	UMult32,_UtilityBase
	move.l	d0,NoPixels		; Number of pixels in picture

	move.l	Pixels,a2

	move.l	d0,d7
	moveq	#0,d6
COUNTLOOP:
	moveq	#0,d5

	move.l	d6,d0

	lea	IFF_Bitmap,a0
	lea	bm_Planes(a0),a0
	move.l	(a0)+,a1

	moveq	#0,d1
	move.l	d0,d1
	not.b	d1
	lsr.l	#3,d0

	add.l	d0,a1

	moveq	#0,d2
	moveq	#0,d3
COL_LOOP:
	btst	d1,(a1)
	beq.s	NEXT

	bset	d3,d2

NEXT:	move.l	(a0)+,a1
	add.l	d0,a1
	add.b	#1,d3
	cmp.b	Planes,d3
	bne.s	COL_LOOP

	lsl.l	#2,d2
	add.l	#1,(a2,d2.w)

	addq.l	#1,d6
	cmp.l	d7,d6
	bne.s	COUNTLOOP

;-------------------------

	bsr.w	CLEARPARAM
	lea	Parameters,a0
	move.w	Width,2(a0)
	move.w	Height,6(a0)
	move.b	Planes,11(a0)
	move.l	#InfoString,d1
	move.l	#Parameters,d2
	CALL	VPrintf,_DosBase

	bsr.w	CLEARPARAM

	move.l	Pixels,a0
	moveq	#0,d7
OUTLOOP:
	lea	Parameters,a1
	move.l	d7,(a1)+
	move.l	(a0)+,(a1)

	move.l	#Histogram,d1
	move.l	#Parameters,d2
	move.l	a0,-(a7)
	CALL	VPrintf,_DosBase
	move.l	(a7)+,a0
	addq.w	#1,d7
	cmp.w	NoColors,d7
	bne.s	OUTLOOP

EXITPRG:
	bsr.s	CLOSESCR
	bsr.s	FREEBMAP
	bsr.w	FREEPIX
	bsr.w	FREECOLS
	bsr.w	FREEIFF
	bsr.w	FREEREQ
	bsr.w	CLOSEINT
	bsr.w	CLOSEUTL
	bsr.w	CLOSEDOS
	bsr.w	CLOSEREQ
	bsr.w	CLOSEGFX
	bsr.w	CLOSEIFF

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

CLOSESCR:
	tst.l	HScreen
	beq.s	.NOT

	move.l	HScreen,a0
	CALL	ScreenToBack,_IntuitionBase

	move.l	HScreen,a0
	CALL	CloseScreen,_IntuitionBase
.NOT:	rts

FREEBMAP:
	moveq	#0,d7
	move.b	Planes,d7
	beq.s	NO_FREEBMAP

	lea	IFF_Bitmap,a1
	lea	bm_Planes(a1),a1

	subq.w	#1,d7
FREELOOP:
	moveq	#0,d0
	moveq	#0,d1
	move.w	Width,d0
	move.w	Height,d1

	move.l	(a1)+,a0
	cmp.l	#NULL,a0
	beq.s	NEXT_FREE

	movem.l	d7/a1,-(a7)
	CALL	FreeRaster,_GfxBase
	movem.l	(a7)+,d7/a1

NEXT_FREE:
	dbf	d7,FREELOOP

NO_FREEBMAP:
	rts

FREEPIX:
	tst.l	Pixels
	beq.s	.NOT

	move.l	Pixels,a1
	move.l	PixMemUse,d0
	CALL	FreeMem,EXECBASE
.NOT:	rts

FREECOLS:
	tst.l	Colors
	beq.s	.NOT

	move.l	Colors,a1
	move.l	ColMemUse,d0
	CALL	FreeMem,EXECBASE
.NOT:	rts

FREEIFF:
	tst.l	Handle
	beq.s	.NOT

	move.l	Handle,a1
	CALL	IFFL_CloseIFF,_IffBase
.NOT:	rts

FREEREQ:
	tst.l	Request
	beq.s	.NOT

	move.l	Request,a1
	CALL	rtFreeRequest,_ReqBase
	move.l	#0,Request
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

CLOSEREQ:
	tst.l	_ReqBase
	beq.s	.NOT

	CLOSELIB _ReqBase
.NOT:	rts

CLOSEGFX:
	tst.l	_GfxBase
	beq.s	.NOT

	CLOSELIB _GfxBase
.NOT:	rts

CLOSEIFF:
	tst.l	_IffBase
	beq.s	.NOT

	CLOSELIB _IffBase
.NOT:	rts

CLOSEUTL:
	tst.l	_UtilityBase
	beq.s	.NOT

	CLOSELIB _UtilityBase
.NOT:	rts

;---------------------------------------------------------------------------

CLEARPARAM:
	lea	Parameters,a0
	moveq	#2,d7
CP:	move.l	#0,(a0)+
	dbf	d7,CP
	rts

DEC2TXT:
	subq.l	#1,d1
D2TLOOP:
	bsr.s	DIVIDE
	dbf	d1,D2TLOOP
	rts

DIVIDE:
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,(a2,d1.w)
	clr.w	d0
	swap	d0
	rts

MAKEFILENAME:
	move.l	Request,a0
	move.l	rtfi_Dir(a0),a0
	lea	CompleteName,a1

	tst.b	(a0)
	beq.s	OK_COLON

NAME1:	move.b	(a0)+,(a1)+
	bne.s	NAME1

	lea	-1(a1),a1

	cmp.b	#':',-1(a1)
	beq.s	OK_COLON

	move.b	#'/',(a1)+

OK_COLON:
	lea	Filename,a0
NAME2:	move.b	(a0)+,(a1)+
	bne.s	NAME2
	rts

;---------------------------------------------------------------------------

	section	SEGMENT1,data

_ReqBase:	dc.l	0
_IffBase:	dc.l	0
_GfxBase:	dc.l	0
_DosBase:	dc.l	0
_UtilityBase:	dc.l	0
_IntuitionBase:	dc.l	0
IntuitionName:	dc.b	"intuition.library",0
UtilityName:	dc.b	"utility.library",0
DosName:	dc.b	"dos.library",0
ReqToolsName:	dc.b	"reqtools.library",0
IFFName:	dc.b	"iff.library",0
GraphicsName:	dc.b	"graphics.library",0
		even

;-------------
; REQUESTER
;-------------

Request:	dc.l	0

Filename:	blk.b	108,0
CompleteName:	blk.b	256,0
ReqTitle:	dc.b	"Load IFF File...",0
		even

ReqTags:	dc.l	RT_ReqPos,REQPOS_CENTERSCR
		dc.l	TAG_DONE


;-------------
; IFF
;-------------

Handle:		dc.l	0		; IFF picture handle
Header:		dc.l	0		; IFF BMHD Header
Colors:		dc.l	0		; Color values
Pixels:		dc.l	0		; Number of pixels of each color
Width:		dc.w	0
Height:		dc.w	0
ViewModes:	dc.w	0
Planes:		dc.b	0
		even
NoColors:	dc.w	0
ColMemUse:	dc.l	0
PixMemUse:	dc.l	0
NoPixels:	dc.l	0

HScreen:	dc.l	0
HNewScreen:	dc.w	0,0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.b	0,0
		dc.w	0
		dc.w	SCREENQUIET!CUSTOMBITMAP
		dc.l	0,0,0
		dc.l	IFF_Bitmap

IFF_Bitmap:	blk.b	bm_SIZEOF,0

Parameters:	dc.l	0,0,0
Histogram:	dc.b	"Color %ld, %ld pixels",10,0
InfoString:	dc.b	"Width %ld, Height %ld, Planes %ld",10,0
		even

;----------------
; ERRORS
;----------------

ERR_NoIFF:	dc.b	"ERROR! No IFF File!",10,0
ERR_HAM:	dc.b	"ERROR! Can't count HAM picture!",10,0
ERR_Decode:	dc.b	"ERROR! Couldn't decode picture!",10,0
