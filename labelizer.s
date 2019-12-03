s:
	movem.l	d0-d7/a0-a6,-(a7)

	movem.l	d0-d7/a0-a6,-(a7)
	bsr	InitPrg
	movem.l	(a7)+,d0-d7/a0-a6

	move.l	4.w,a6
	lea	dos,a1
	jsr	-408(a6)
	move.l	d0,base

	move.l	base,a6
	move.l	#name,d1
	move.l	#1005,d2
	jsr	-30(a6)
	tst.l	d0
	beq.w	CloseDOS
	move.l	d0,handle

DoLoop:
	bsr	ClearWindow
	bsr	StartMessage

;---------------------------------------

	bsr	AskString		; String handling

;---------------------------------------

TheFileL:
	bsr	AskFileLoad
	cmp.b	#'q',Filename
	beq.w	CloseWindow
	cmp.b	#'Q',Filename
	beq.w	CloseWindow	

	move.l	base,a6			; Get file lock
	move.l	#filename,d1
	move.l	#1005,d2
	jsr	-84(a6)
	tst.l	d0
	beq.w	NewLoad

	move.l	d0,Lock

	move.l	base,a6			; Examine File
	move.l	Lock,d1
	move.l	#InfoBlock,d2
	jsr	-102(a6)
	tst.l	d0
	beq.w	UnLockFileRedo

	move.l	base,a6			; Unlock File
	move.l	Lock,d1
	jsr	-90(a6)

	lea	InfoBlock,a0		; Get Filelength
	move.l	124(a0),FileLength

	tst.l	FileLength
	beq.w	NewLoad

;---------------------------------------------------------------------

	move.l	FileLength,DoneLength
	add.l	#16,FileLength
	add.l	#[10*1024],DoneLength
	
	move.l	4.w,a6				; memory management
	move.l	FileLength,d0
	move.l	#$10004,d1
	jsr	-198(a6)
	tst.l	d0
	beq.w	NotEnoughMem

	move.l	d0,Block1
	move.l	Block1,Pointer

	move.l	4.w,a6
	move.l	DoneLength,d0
	move.l	#$10004,d1
	jsr	-198(a6)
	tst.l	d0
	beq.w	NotEnoughMem2

	move.l	d0,Block2
	move.l	Block2,Destination

;----------------------------------------------------------------

	move.l	base,a6
	move.l	#filename,d1
	move.l	#1005,d2
	jsr	-30(a6)
	move.l	d0,filehandle

	move.l	filehandle,d1
	move.l	Pointer,d2
	move.l	FileLength,d3
	jsr	-42(a6)
	tst.l	d0
	bmi.w	ReleaseBlock2

	move.l	base,a6
	move.l	FileHandle,d1
	jsr	-36(a6)

	move.l	Pointer,a0		; File end-mark
	move.l	FileLength,d0
	sub.l	#16,d0
	add.l	d0,a0

	move.b	#-1,(a0)		; Safe EndMark
	move.b	#$0a,1(a0)
	move.b	#-1,2(a0)

;----------------------------------------------------------------

MakeIt:
	bsr	MainProgram		; Labelize

;----------------------------------------------------------------

TheFileS:
	bsr	AskFileSave
	cmp.b	#'q',FilenameS
	beq.w	ReleaseBlock2
	cmp.b	#'Q',FilenameS
	beq.w	ReleaseBlock2

SaveFile:
	movem.l	CLR,d0-d7/a0-a6

	move.l	base,a6
	move.l	#FileNameS,d1
	move.l	#1006,d2
	jsr	-30(a6)
	move.l	d0,FileHandle

	tst.l	d0
	beq.s	TheFileS

	move.l	Destination,a0
	move.l	Block2,a1
	sub.l	a1,a0
	move.l	a0,Destination

	move.l	base,a6
	move.l	FileHandle,d1
	move.l	Block2,d2
	move.l	Destination,d3
	jsr	-48(a6)

	move.l	FileHandle,d1
	jsr	-36(a6)

;----------------------------------------------------------------

ReleaseBlock2:
	move.l	4.w,a6
	move.l	Block2,a1
	move.l	DoneLength,d0
	jsr	-210(a6)

ReleaseBlock1:
	move.l	4.w,a6
	move.l	Block1,a1
	move.l	FileLength,d0
	jsr	-210(a6)
	
CloseWindow:
	move.l	base,a6
	move.l	handle,d1
	jsr	-36(a6)

CloseDOS:
	move.l	4.w,a6
	move.l	base,a1
	jsr	-414(a6)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------

NotEnoughMem2:
	move.l	4.w,a6
	move.l	Block1,a1
	move.l	FileLength,d0
	jsr	-210(a6)

NotEnoughMem:
	move.l	base,a6
	move.l	handle,d1
	move.l	#nomem,d2
	move.l	#nomeme-nomem,d3
	jsr	-48(a6)

	bsr	RightMouse

	bsr	CursorTwoUp
	bra.w	TheFileL


nomem:
	dc.b	"** Not Enough Memory",$0a
	dc.b	"Press Right MB To Continue",$0a
	dc.b	0
nomeme:
	even

CursorTwoUp:
	move.l	base,a6
	move.l	handle,d1
	move.l	#cup2,d2
	move.l	#cup2e-cup2,d3
	jsr	-48(a6)
	rts	

cup2:
	dc.b	$9b,$41,$9b,$4b,$9b,$41,$9b,$4b,$9b,$41,$0
cup2e:
	even

;--------------------------------------------------------------

NewLoad:
	bsr	CursorUp
	bra.w	TheFileL

UnLockFileRedo:
	move.l	base,a6
	move.l	Lock,d1
	jsr	-90(a6)

	bra.s	NewLoad

;--------------------------------------------------------------

FileHandle:	dc.l	0
Block1:		dc.l	0
Block2:		dc.l	0
FileLength:	dc.l	0
DoneLength:	dc.l	0
Lock:		dc.l	1
		cnop	0,4
InfoBlock:	blk.l	260,0

;--------------------------------------------------------------

base:		dc.l	0
dos:		dc.b	'dos.library',0
		even

handle:		dc.l	0
name:		dc.b	"CON:0/0/640/256/Labelizer v1.0",0
		even

;--------------------------------------------------------------------

RightMouse:
	btst	#2,$dff016
	bne.s	RightMouse	
	rts

;--------------------------------------------------------------------

AskString:
	move.l	base,a6
	move.l	handle,d1
	move.l	#str,d2
	move.l	#stre-str,d3
	jsr	-48(a6)
	
	move.l	handle,d1
	move.l	#Label,d2
	move.l	#80,d3
	jsr	-42(a6)

	cmp.b	#$0a,Label
	bne.s	DoneString

	bsr	CursorUP
	bra.s	AskString

DoneString:
	bsr	FindDel0A
	rts

str:
 dc.b	$9b,"1;31;40m"
 dc.b	" String: "
 dc.b	$9b,"0;31;40m"
 dc.b	0
stre:
 even

;--------------------------------------------------------------

FindDel0A:
	lea	Label,a0
FD0A:
	cmp.b	#$0a,(a0)+
	bne.s	FD0A

	clr.b	-1(a0)
	rts

CursorUP:
	move.l	base,a6
	move.l	handle,d1
	move.l	#cup,d2
	move.l	#cupe-cup,d3
	jsr	-48(a6)
	rts	

cup:
	dc.b	$9b,$41,$9b,$4b,$0
cupe:
	even

;--------------------------------------------------------------------

AskFileSave:
	move.l	base,a6
	move.l	handle,d1
	move.l	#files,d2
	move.l	#filese-files,d3
	jsr	-48(a6)

	move.l	handle,d1
	move.l	#filenameS,d2
	move.l	#80,d3
	jsr	-42(a6)

	cmp.b	#$0a,filenameS
	bne.s	DoneFileSave

	bsr	CursorUP
	bra.s	AskFileSave

DoneFileSave:
	lea	FileNameS,a0
	bsr	FD0A
	rts

files:
 dc.b	$9b,"1;31;40m"
 dc.b	" Save File: "
 dc.b	$9b,"0;31;40m"
 dc.b	0
filese:
 even

;--------------------------------------------------------------------

AskFileLoad:
	move.l	base,a6
	move.l	handle,d1
	move.l	#filel,d2
	move.l	#filele-filel,d3
	jsr	-48(a6)

	move.l	handle,d1
	move.l	#filename,d2
	move.l	#80,d3
	jsr	-42(a6)

	cmp.b	#$0a,filename
	bne.s	DoneFileLoad

	bsr	CursorUP
	bra.s	AskFileLoad

DoneFileLoad:
	lea	FileName,a0
	bsr	FD0A
	rts

filel:
 dc.b	$9b,"1;31;40m"
 dc.b	" Load File: "
 dc.b	$9b,"0;31;40m"
 dc.b	0
filele:
 even

;--------------------------------------------------------------------

ClearWindow:
	move.l	base,a6
	move.l	handle,d1
	move.l	#clrw,d2
	move.l	#clrwe-clrw,d3
	jsr	-48(a6)
	rts

clrw:	dc.b	$0c,0
clrwe:
	even

;------------------------------------------------------------------

StartMessage:
	move.l	base,a6
	move.l	handle,d1
	move.l	#mess,d2
	move.l	#messe-mess,d3
	jsr	-48(a6)
	rts

mess:
 dc.b	$0a
 dc.b	" "
 dc.b	$9b,"7;33;40m"
 dc.b	"L a b e l i z e r",$0a
 dc.b	$9b,"0;31;40m"
 dc.b	$0a

 dc.b	" "
 dc.b	$9b,"4;31;40m"
 dc.b	"Programming by Morten Amundsen",$0a
 dc.b	$9b,"0;31;40m"
 dc.b	$0a

 dc.b	$9b,"1;33;40m"
 dc.b	" A D D R E S S",$0a
 dc.b	$9b,"0;31;40m"
 dc.b	" Morten Amundsen, 25A315 Fjellbirkeland Studentby,",$0a
 dc.b	" Sognsveien 218. 0864 OSLO 8. Norway.",$0a
 dc.b	" Tel: 02/187319",$0a
 dc.b	$0a

 dc.b	$9b,"1;33;40m"
 dc.b	" U N I V E R S I T Y   O F   O S L O  (InterNet)",$0a
 dc.b	$9b,"0;31;40m"
 dc.b	" mortena@ifi.uio.no",$0a
 dc.b	$0a,$0a

 dc.b	$9b,"3;31;40m"
 dc.b	" This program puts a user-defined textstring in front of ",$0a
 dc.b	" all labels in an assembler source.",$0a
 dc.b	" The program allocates 10K for extra label size",$0a
 dc.b	" Type 'q' or 'Q' as either filenames to exit.",$0a
 dc.b	$9b,"0;31;40m"
 dc.b	$0a

 dc.b	$9b,"1;33;40m"
 dc.b	" W A R N I N G !",$0a
 dc.b	$9b,"0;31;40m"

 DC.B	" The maker of this program takes no responsibility for",$0a
 dc.b	" lost sources!",$0a

 dc.b	$0a,$0a
 dc.b	0
messe:
	even

;------------------------------------------------------------------

MainProgram:
	movem.l	d0-d7/a0-a6,-(a7)
MainLoop:

	movem.l	CLR,d0-d7/a0-a6

	clr.b	LastSeen
	bsr	GetWord	
	move.b	d0,LastSeen

	tst.w	DoneFlag
	bne.w	ExitProgram

	tst.w	OneByte
	bne.w	EnterByte

	bsr	WordUpperCase

	moveq	#0,d6

	tst.w	InstrBeen
	bne.s	HasBeen	

	cmp.b	#':',LastSeen
	beq.s	HasBeen

	bsr	CheckForInstruction
	tst.l	d6
	bne.w	WasInstruction

	bsr.w	CheckForOpCode
	tst.l	d6
	bne.w	WasOpCode

HasBeen:
	bsr.w	CheckForRegister
	tst.l	d6
	bne.w	WasRegister

	cmp.b	#'9',Store		; Label kan ikke begynne med
	bgt.s	WasLabel		; et tall!

	lea	Store,a0
	move.l	Destination,a1
FillFake:
	move.b	(a0)+,(a1)+
	bne.s	FillFake

	lea	-1(a1),a1
	move.l	a1,Destination
	bra.w	MainLoop

WasLabel:
	lea	Label,a0
	move.l	Destination,a1
FillFront:
	move.b	(a0)+,(a1)+
	tst.b	-1(a1)
	bne.s	FillFront

	lea	-1(a1),a1

	lea	Store,a0
FillStore2:
	move.b	(a0)+,(a1)+
	tst.b	-1(a1)
	bne.s	FillStore2

	lea	-1(a1),a1
	move.l	a1,Destination
	bra.w	MainLoop

ExitProgram:
	move.l	Destination,a0
	move.b	#$1a,(a0)+
	move.l	a0,Destination

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;-----------------------------------------------------------------

EnterByte:
	moveq	#0,d0
	lea	Store,a0
	move.b	(a0),d0

	cmp.w	#$0a,d0
	beq.s	Was0A

	cmp.b	#';',d0
	beq.w	Comment

	cmp.b	#'$',d0
	beq.s	UntilStop

	cmp.b	#'"',d0
	beq.w	TillNext
	cmp.b	#"'",d0
	beq.w	TillNext
	cmp.b	#'(',d0
	beq.w	TillNextX
	cmp.b	#".",d0
	beq.s	TillSomething

NewDest:
	move.l	Destination,a0
	move.b	d0,(a0)+
	move.l	a0,Destination
	bra.w	MainLoop

Was0A:
	clr.w	InstrBeen
	bra.s	NewDest

TillSomething:
	move.l	Destination,a0
	move.l	Pointer,a1
	move.b	d0,(a0)+
Tiloop:
	move.b	(a1)+,d0

	cmp.b	#',',d0
	beq.s	DoneSome
	cmp.b	#$09,d0
	beq.s	DoneSome
	cmp.b	#$0a,d0
	beq.s	DoneSome
	cmp.b	#';',d0
	beq.s	DoneSome

	move.b	d0,(a0)+
	bra.s	Tiloop

DoneSome:
	move.b	d0,(a0)+

	move.l	a0,Destination
	move.l	a1,Pointer
	bra.w	MainLoop

;---------------------------------------------------------------

UntilStop:
	move.l	Destination,a0
	move.b	d0,(a0)+

	move.l	Pointer,a1
UStop:
	moveq	#0,d0
	move.b	(a1),d0

	cmp.b	#'(',d0
	beq.s	DoStop
	cmp.b	#')',d0
	beq.s	DoStop
	cmp.b	#'.',d0
	beq.s	DoStop
	cmp.b	#',',d0
	beq.s	DoStop
	cmp.b	#$09,d0
	beq.s	DoStop
	cmp.b	#$0a,d0
	beq.s	DoStopX
	cmp.b	#'+',d0
	beq.s	DoStop
	cmp.b	#'-',d0
	beq.s	DoStop
	cmp.b	#'*',d0
	beq.s	DoStop
	cmp.b	#'/',d0
	beq.s	DoStop

	move.b	d0,(a0)+
	lea	1(a1),a1
	bra.s	UStop

DoStopX:
	clr.w	InstrBeen
DoStop:
	move.l	a0,Destination
	move.l	a1,Pointer
	bra.w	MainLoop

;---------------------------------------------------------------

TillNextX:
	moveq	#1,d7
	bra.s	Fuck

TillNext:
	moveq	#0,d7
Fuck:
	moveq	#0,d1
	move.b	d0,d1

	move.l	Destination,a0
	move.l	Pointer,a1

	move.b	d0,(a0)+
	add.b	d7,d1

TNext:
	moveq	#0,d0
	move.b	(a1)+,d0
	cmp.b	d0,d1
	beq.s	OkTillNext

	move.b	d0,(a0)+
	bra.s	TNext

OkTillNext:
	move.b	d0,(a0)+

	move.l	a0,Destination
	move.l	a1,Pointer

	bra.w	MainLoop

;-----------------------------------------------------------------

Comment:
	clr.w	InstrBeen

	move.l	Destination,a0
	move.b	d0,(a0)+

	move.l	Pointer,a1
Until0A:
	move.b	(a1),d0
	cmp.b	#$0a,d0
	beq.s	Done0A2

	lea	1(a1),a1
	move.b	d0,(a0)+
	bra.s	Until0A

Done0A2:
	lea	1(a1),a1
	move.b	d0,(a0)+

	move.l	a0,Destination
	move.l	a1,Pointer
	bra.w	MainLoop

;-----------------------------------------------------------------

WasRegister:
	lea	Store,a0
	move.l	Destination,a1
FillReg:
	move.b	(a0)+,(a1)+
	bne.s	FillReg

	lea	-1(a1),a1
	move.l	a1,Destination
	bra.w	MainLoop

;-----------------------------------------------------------------

WasInstruction:
	move.w	#1,InstrBeen

	lea	Store,a0
	move.l	Destination,a1
FillInstr:
	move.b	(a0)+,(a1)+
	bne.s	FillInstr

	lea	-1(a1),a1
	move.l	Pointer,a0
FillRest:
	moveq	#0,d0
	move.b	(a0),d0

	cmp.b	#' ',d0
	beq.s	DoneRest
	cmp.b	#$09,d0
	beq.s	DoneRest
	cmp.b	#$0a,d0
	beq.s	DoneRestX

	lea	1(a0),a0
	move.b	d0,(a1)+
	bra.s	FillRest

DoneRest:
	move.l	a0,Pointer
	move.l	a1,Destination
	bra.w	MainLoop

DoneRestX:
	clr.w	InstrBeen
	bra.s	DoneRest

;-------------------------------------------------------------------

WasOpcode:
	lea	Store,a0
	move.l	Destination,a1
FillOpCode:
	move.b	(a0)+,(a1)+
	bne.s	FillOpCode

	lea	-1(a1),a1
	move.l	Pointer,a0

Fill932:
	moveq	#0,d0
	move.b	(a0),d0

	cmp.b	#$09,d0
	beq.s	Done932
	cmp.b	#' ',d0
	beq.s	Done932
	cmp.b	#$0a,d0
	beq.s	Done932X	
	
	lea	1(a0),a0
	move.b	d0,(a1)+
	bra.s	Fill932

Done932:
	move.l	a0,Pointer
	move.l	a1,Destination
	bra.w	MainLoop

Done932X:
	clr.w	InstrBeen
	bra.s	Done932

;-----------------------------------------------------------------

CheckForRegister:
	lea	RBlock,a0
	bra.s	SearchIO

CheckForOpCode:
	lea	OBlock,a0
	bra.s	SearchIO

CheckForInstruction:
	lea	IBlock,a0

SearchIO:	
	move.l	(a0)+,a2	

	cmp.l	#-1,a2
	beq.s	NoIO

	lea	Work,a1

CheckMoreIO:
	moveq	#0,d0
	moveq	#0,d1

	move.b	(a1)+,d0
	move.b	(a2)+,d1
	beq.s	GotZeroIO

	tst.b	d0
	beq.s	GotZeroIO

	cmp.b	d0,d1
	bne.s	SearchIO
	bra.s	CheckMoreIO

GotZeroIO:
	add.w	d0,d1
	tst.w	d1
	bne.s	SearchIO

	moveq	#1,d6

NoIO:
	rts

;-----------------------------------------------------------------

WordUpperCase:
	lea	Work,a0
WorkUC:
	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	DoneUC

	cmp.b	#'a',d0
	blo.s	WorkUC
	cmp.b	#'z',d0
	bhi.s	WorkUC

	sub.b	#'a'-'A',d0
	move.b	d0,-1(a0)

	bra.s	WorkUC

DoneUC:
	rts

;-----------------------------------------------------------------

GetWord:
	bsr	ClearBuffers

	move.l	Pointer,a0
	cmp.b	#-1,(a0)
	bne.s	DoProgram

	move.w	#1,DoneFlag
	bra.s	Vekk

DoProgram:
	clr.w	OneByte
	lea	Store,a1
Until:
	moveq	#0,d0
	move.b	(a0),d0

	move.b	d0,$dff180

	cmp.b	#'_',d0
	beq.s	FillStore

	cmp.b	#'0',d0
	blt.s	OneByteWord
	cmp.b	#'z',d0
	bhi.s	OneByteWord

	cmp.b	#'9',d0
	ble.w	FillStore

	cmp.b	#'A',d0
	blt.s	OneByteWord
	cmp.b	#'Z',d0
	blt.w	FillStore
	
	cmp.b	#'a',d0
	blt.s	OneByteWord
	cmp.b	#'z',d0
	ble.w	FillStore

OneByteWord:
	cmp.l	#Store,a1
	bne.s	JustABlock

	move.w	#1,OneByte

	move.b	d0,(a1)+
	addq.l	#$1,a0

JustABlock:
	move.l	a0,Pointer
	bsr	CopyStoreWork
Vekk:	rts

FillStore:
	addq.l	#$1,a0
	move.b	d0,(a1)+
	bra.s	Until

;-----------------------------------------------------------------

CheckByte:
	lea	BlockBytes,a2
ChkBlk:
	moveq	#0,d1
	move.b	(a2)+,d1
	
	tst.b	d1
	bmi.s	NotABlocker

	cmp.b	d0,d1
	beq.s	FoundBlock
	bra.s	ChkBlk

FoundBlock:
	moveq	#1,d6			; Current = d0

NotABlocker:
	rts

;-----------------------------------------------------------------

ClearBuffers:
	lea	Work,a0
	lea	Store,a1
	move.w	#119,d7
ClrB:
	clr.b	(a0)+
	clr.b	(a1)+
	dbf	d7,ClrB
	rts

;-----------------------------------------------------------------

CopyStoreWork:
	lea	Store,a0
	lea	Work,a1
CopySW:
	move.b	(a0)+,(a1)+
	bne.s	CopySW
	rts

;-----------------------------------------------------------------

InitPrg:
	lea	Instructions,a0
	lea	IBlock,a1
	move.l	a0,(a1)+

LoopI:
	tst.b	(a0)+
	bmi.s	DoneI
	bne.s	LoopI
	move.l	a0,(a1)+
	bra.s	LoopI
DoneI:

;-----------------------------------------------------------------

	lea	OpCodes,a0
	lea	OBlock,a1
	move.l	a0,(a1)+

LoopO:
	tst.b	(a0)+
	bmi.s	DoneO
	bne.s	LoopO
	move.l	a0,(a1)+
	bra.s	LoopO
DoneO:

;-----------------------------------------------------------------

	lea	Registers,a0
	lea	RBlock,a1
	move.l	a0,(a1)+

LoopR:
	tst.b	(a0)+
	bmi.s	DoneR
	bne.s	LoopR
	move.l	a0,(a1)+
	bra.s	LoopR
DoneR:
	rts

;-----------------------------------------------------------------

CLR:		blk.l	15,0

IBlock:		blk.l	124,0
		dc.l	-1

Instructions:
	DC.B	"ABCD",0
	DC.B	"ADD",0
	DC.B	"ADDA",0
	DC.B	"ADDI",0
	DC.B	"ADDQ",0
	DC.B	"ADDX",0
	DC.B	"AND",0
	DC.B	"ANDI",0
	DC.B	"ASL",0
	DC.B	"ASR",0
	DC.B	"BRA",0
	DC.B	"BHI",0
	DC.B	"BHS",0
	DC.B	"BLS",0
	DC.B	"BCC",0
	DC.B	"BNE",0
	DC.B	"BEQ",0	
	DC.B	"BVC",0
	DC.B	"BVS",0
	DC.B	"BPL",0
	DC.B	"BMI",0
	DC.B	"BGE",0
	DC.B	"BLT",0
	DC.B	"BGT",0
	DC.B	"BLE",0
	DC.B	"BLO",0
	DC.B	"BCHG",0
	DC.B	"BCLR",0
	DC.B	"BSET",0
	DC.B	"BSR",0
	DC.B	"BTST",0
	DC.B	"CHK",0
	DC.B	"CLR",0
	DC.B	"CMP",0
	DC.B	"CMPA",0
	DC.B	"CMPI",0
	DC.B	"CMPM",0
	DC.B	"DBRA",0
	DC.B	"DBHI",0
	DC.B	"DBLS",0
	DC.B	"DBCC",0
	DC.B	"DBNE",0
	DC.B	"DBEQ",0	
	DC.B	"DBVC",0
	DC.B	"DBVS",0
	DC.B	"DBPL",0
	DC.B	"DBMI",0
	DC.B	"DBGE",0
	DC.B	"DBLT",0
	DC.B	"DBGT",0
	DC.B	"DBLE",0
	DC.B	"DBT",0
	DC.B	"DBF",0
	DC.B	"DIVS",0
	DC.B	"DIVU",0
	DC.B	"EOR",0
	DC.B	"EORI",0
	DC.B	"EXG",0
	DC.B	"EXT",0
	DC.B	"ILLEGAL",0
	DC.B	"JMP",0
	DC.B	"JSR",0
	DC.B	"LEA",0
	DC.B	"LINK",0
	DC.B	"LSL",0
	DC.B	"LSR",0
	DC.B	"MOVE",0
	DC.B	"MOVEA",0
	DC.B	"MOVEC",0
	DC.B	"MOVEM",0
	DC.B	"MOVEP",0
	DC.B	"MOVEQ",0
	DC.B	"MOVES",0
	DC.B	"MULS",0
	DC.B	"MULU",0
	DC.B	"NBCD",0
	DC.B	"NEG",0
	DC.B	"NEGX",0
	DC.B	"NOP",0
	DC.B	"NOT",0
	DC.B	"OR",0
	DC.B	"ORI",0
	DC.B	"PEA",0
	DC.B	"RESET",0
	DC.B	"ROL",0
	DC.B	"ROR",0
	DC.B	"ROXL",0
	DC.B	"ROXR",0
	DC.B	"RTD",0
	DC.B	"RTE",0
	DC.B	"RTR",0
	DC.B	"RTS",0
	DC.B	"SBCD",0
	DC.B	"SHI",0
	DC.B	"SLS",0
	DC.B	"SCC",0
	DC.B	"SNE",0
	DC.B	"SEQ",0	
	DC.B	"SVC",0
	DC.B	"SVS",0
	DC.B	"SPL",0
	DC.B	"SMI",0
	DC.B	"SGE",0
	DC.B	"SLT",0
	DC.B	"SGT",0
	DC.B	"SLE",0
	DC.B	"ST",0
	DC.B	"SF",0
	DC.B	"STOP",0	
	DC.B	"SUB",0
	DC.B	"SUBA",0
	DC.B	"SUBI",0
	DC.B	"SUBQ",0
	DC.B	"SUBX",0
	DC.B	"SWAP",0
	DC.B	"TAS",0
	DC.B	"TRAP",0	
	DC.B	"TRAPV",0
	DC.B	"TST",0
	DC.B	"UNLK",0
	DC.B	"SR",0
	DC.B	"USP",0
	DC.B	"CCR",0
	DC.B	-1
	even

OBlock:		blk.l	40,0
		dc.l	-1

OpCodes:
	DC.B	"ALIGN",0
	DC.B	"BLK",0
	DC.B	"BLK",0
	DC.B	"BLK",0
	DC.B	"CNOP",0
	DC.B	"DC",0
	DC.B	"DC",0
	DC.B	"DC",0
	DC.B	"DS",0
	DC.B	"DS",0
	DC.B	"DS",0
	DC.B	"ENDIF",0
	DC.B	"ENDM",0
	DC.B	"EQU",0
	DC.B	"ELSE",0
	DC.B	"EVEN",0	
	DC.B	"END",0
	DC.B	"GLOBL",0
	DC.B	"IF",0
	DC.B	"INCBIN",0
	DC.B	"INCLUDE",0
	DC.B	"LIST",0
	DC.B	"LOAD",0
	DC.B	"MACRO",0
	DC.B	"NLIST",0
	DC.B	"ODD",0
	DC.B	"ORG",0
	DC.B	"PAGE",0
	DC.B	"PLEN",0
	DC.B	"PWID",0
	DC.B	"PINIT",0
	DC.B	"DATA",0
	DC.B	"DATA_C",0
	DC.B	"BSS",0
	DC.B	"BSS_C",0
	DC.B	"CODE",0
	DC.B	"CODE_C",0
	DC.B	"SECTION",0
	DC.B	"EXTERN",0
	DC.B	-1
	even

BlockBytes:	dc.b	$09,$0a," #$;,-+*/.(",0
		even

RBlock:		blk.l	17,0
		dc.l	-1

Registers:
	DC.B	"D0",0
	DC.B	"D1",0
	DC.B	"D2",0
	DC.B	"D3",0
	DC.B	"D4",0
	DC.B	"D5",0
	DC.B	"D6",0
	DC.B	"D7",0
	DC.B	"A0",0
	DC.B	"A1",0
	DC.B	"A2",0
	DC.B	"A3",0
	DC.B	"A4",0
	DC.B	"A5",0
	DC.B	"A6",0
	DC.B	"A7",0
	dc.b	-1
	even

Work:		blk.b	120,0		; Line to work with

Store:		blk.b	120,0		; Copy of 'Work', but is not
					; made UpperCase
					; This is what will be stored
					; in 'Fine' when finished
					; working with 'Work'-line.

Destination:	dc.l	0
Pointer:	dc.l	0

FileName:	blk.b	80,0
		even

FileNameS:	blk.b	80,0
		even

InstrBeen:	dc.w	0
OneByte:	dc.w	0
DoneFlag:	dc.w	0
LastSeen:	dc.b	0
		even

Label:		blk.b	80,0
