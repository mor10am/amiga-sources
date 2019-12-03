	org	$40000
	load	$40000
s:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	$80,OldTrap
	move.l	#NewTrap,$80

	trap	#0

	move.l	OldTrap,$80

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

NewTrap:
	movem.l	d0-d7/a0-a6,-(a7)
	move.w	#$2700,sr

	bsr.L	InitProgram

	lea	$dff000,a6

	move.w	#$7fff,d0
	move.w	#$8000,d1

	move.w	$02(a6),OldDMA
	move.w	$1c(a6),OldINT
	or.w	d1,OldDMA
	or.w	d1,OldINT
	move.w	d0,$96(a6)
	move.w	d0,$9a(a6)
	move.w	#$8000+$400+$200+$100+$80+$40,$96(a6)
	move.w	#$c000+$10,$9a(a6)

	move.l	$6c.w,OldLEV3Vector
	move.l	#NewLEV3Vector,$6c.w

	move.l	#Copper,$80(a6)

	move.w	#$2000,sr

Mouse:
	btst	#6,$bfe001
	bne.s	Mouse

	move.w	#$2700,sr

	move.l	4,a5
	move.l	156(a5),a1
	move.l	38(a1),$80(a6)

	move.w	#$7fff,d0
	move.w	d0,$96(a6)
	move.w	d0,$9a(a6)
	move.w	OldDMA,$96(a6)
	move.w	OldINT,$9a(a6)

	move.w	#$400,$96(a6)

	move.l	OldLEV3Vector,$6c.w

	move.w	#$2000,sr

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rte

OldDMA:		dc.w	0
OldINT:		dc.w	0
OldLEV3Vector:	dc.l	0
OldTrap:	dc.l	0

NewLEV3Vector:
	movem.l	d0-d7/a0-a6,-(a7)


	bsr.s	LineWriter


	movem.l	(a7)+,d0-d7/a0-a6

NoRequest:
	move.w	#$0010,$9c(a6)
	rte

LineWriter:

*******************************************
*** DoubleBuffering and Screen Clearing ***
*******************************************

	move.l	#Plane1,d0
	move.l	#Plane2,Screen
	move.l	#Plane2+[34*40],Bottom

	eor.w	#$1,Flag
	beq.s	DoubleBuffer
	
	move.l	#Plane2,d0
	move.l	#Plane1,Screen
	move.l	#Plane1+[34*40],Bottom

DoubleBuffer:
	move.w	d0,Lo1
	swap	d0
	move.w	d0,Hi1

	move.l	Screen,$54(a6)
	move.l	#-1,$44(a6)
	move.l	#$01000000,$40(a6)
	clr.w	$66(a6)
	move.w	#[18*64]+20,$58(a6)

	move.l	a7,OldStack
	move.l	Bottom,a7
	movem.l	CLR,d0-d7/a0-a6
	blk.l	13,$48e7fffe
	move.l	OldStack,a7

*******************************************
*** LineWriter                          ***
*******************************************

	lea	$dff000,a6
	move.l	#$ffff8000,$72(a6)
	move.w	#$28,$60(a6)
	move.w	#$28,$66(a6)

	tst.w	DoneConv
	beq.s	JumpMakeLetter

	subq.w	#1,Delay
	bgt.s	JumpMakeLetter
	move.w	#200,Delay

	bsr.L	FillNewtext
	clr.w	DoneConv
	move.w	#1,StepNr

JumpMakeLetter:
	lea	FromLetter,a3
	lea	ToLetter,a4

	move.w	#9,d5
MakeLoop:
	move.l	(a3)+,a0
	move.l	(a4)+,a1	

	bsr.L	MakeLetter

	move.l	Screen,a1
	lea	DummyObject,a2

	move.w	Points,d7
DrawObject:
	movem.l	CLR,d0-d3

	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2),d2
	move.w	2(a2),d3

	add.w	Xpos,d0
	add.w	Xpos,d2

	bsr.s	LineDraw

	dbf	d7,DrawObject
	add.w	#32,Xpos

	dbf	d5,MakeLoop
	clr.w	Xpos

	addq.w	#$1,StepNr
	cmp.w	#65,StepNr
	bne.s	Done
	move.w	#64,StepNr

	move.w	#1,DoneConv
Done:
	rts

FillNewText:
	move.l	TextAdd,a0
	lea	LetterTab,a1
	lea	ToLetter,a2
	lea	FromLetter,a3

	moveq	#9,d5
FillText:
	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	bne.s	OkLetter
	move.l	#Text,a0
	bra.s	FillText

OkLetter:
	lsl.w	#2,d0
	move.l	(a2),(a3)+
	move.l	(a1,d0),(a2)+
	dbf	d5,FillText
	move.l	a0,TextAdd

	rts

LineDraw:
**************************************************************

; 	Finn riktig oktant for linjen.

;	D0 = X1
;	D1 = Y1
; 	D2 = X2
;	D3 = Y2

;	D4 = oktant

**************************************************************

	moveq	#0,d4

	sub.w	d1,d3
	bge.s	Y2BiggerY1

	neg.w	d3
	bset	#2,d4	
Y2BiggerY1:
	sub.w	d0,d2
	bge.s	X2BiggerX1
	
	neg.w	d2
	bset	#1,d4
X2BiggerX1:
	cmp.w	d2,d3
	bge.s	DxLessDy

	exg	d2,d3
	bset	#0,d4
DxLessDy:
	move.b	Octant(pc,d4),d4

**************************************************************

	add.w	d2,d2
	move.w	d2,$62(a6)
	
	sub.w	d3,d2
	bge.s	NoSIGN
	
	bset	#6,d4
NoSIGN:
	move.w	d2,$52(a6)

	sub.w	d3,d2
	move.w	d2,$64(a6)

	move.w	d1,d2
	lsl.w	#3,d1
	lsl.w	#5,d2
	add.w	d2,d1

	ror.l	#4,d0
	lsl.w	#1,d0
	add.w	d0,d1
	add.l	a1,d1

	swap	d0
	or.w	#$bca,d0
	move.w	d0,$40(a6)
	move.w	d4,$42(a6)

	move.l	d1,$48(a6)
	move.l	d1,$54(a6)

	tst.w	d3
	bne.s	CalcBlitSize

	moveq	#1,d3

CalcBlitSize:
	lsl.w	#6,d3
	add.w	#2,d3
	move.w	d3,$58(a6)
	
w2:	btst	#14,$02(a6)
	bne.s	w2

	rts

Octant:
	dc.b	[0*4]+1
	dc.b	[4*4]+1
	dc.b	[2*4]+1
	dc.b	[5*4]+1
	dc.b	[1*4]+1
	dc.b	[6*4]+1
	dc.b	[3*4]+1
	dc.b	[7*4]+1

MakeLetter:
	lea	DummyObject,a2
	move.w	Points,d7

	moveq	#$00,d3
	move.w	StepNr,d3
	bne.s	StepNotZero
	moveq	#1,d3

StepNotZero:
	addq.w	#1,d7

StepLoop:
	moveq	#$00,d0
	moveq	#$00,d1

	move.w	(a0)+,d0
	move.w	(a1)+,d1

	move.w	d0,d2

	sub.w	d0,d1

	muls	d3,d1
	asr.w	#6,d1

	add.w	d2,d1

	move.w	d1,(a2)+

	moveq	#$00,d0
	moveq	#$00,d1

	move.w	(a0)+,d0
	move.w	(a1)+,d1

	move.w	d0,d2

	sub.w	d0,d1

	muls	d3,d1
	asr.w	#6,d1

	add.w	d2,d1
	move.w	d1,(a2)+

	dbf	d7,StepLoop
	rts

StepNr:	dc.w	1

InitProgram:
	move.l	#Plane1,d0
	move.w	d0,Lo1
	swap	d0
	move.w	d0,Hi1

	lea	LetterA,a0
SubLoop:
	sub.w	#100,(a0)+
	sub.w	#67,(a0)+
	cmp.l	#LastItem,a0
	bne.s	SubLoop

	rts

Copper:
	dc.w	$009c,$8010
	dc.w	$0c01,$ff00

	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0102,$0001,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000
	dc.w	$0182,$07ad
	dc.w	$0100,$0000

	dc.w	$ffdf,$fffe
	dc.w	$0901,$ff00
	dc.w	$00e0
Hi1:	dc.w	$0000
	dc.w	$00e2
Lo1:	dc.w	$0000
	dc.w	$0a01,$ff00,$0100,$1200
	dc.w	$2c01,$ff00,$0100,$0000
	dc.w	$ffff,$fffe

OldStack:	dc.l	0
CLR:		blk.l	15,0

Points:		dc.w	6-1

LetterA:
		dc.w	100,100
		dc.w	115,067
		dc.w	123,083
		dc.w	107,083
		dc.w	123,083
		dc.w	130,100
		dc.w	130,100
LetterB:
		dc.w	100,100
		dc.w	100,067
		dc.w	130,075
		dc.w	100,083
		dc.w	130,091
		dc.w	100,100
		dc.w	100,100
LetterC:
		dc.w	130,075
		dc.w	123,067
		dc.w	100,067
		dc.w	100,100
		dc.w	123,100
		dc.w	130,092
		dc.w	130,092
LetterD:
		dc.w	100,067
		dc.w	100,100
		dc.w	123,100
		dc.w	130,092
		dc.w	130,075
		dc.w	123,067
		dc.w	100,067
LetterE:
		dc.w	130,100
		dc.w	100,100
		dc.w	100,084
		dc.w	115,084
		dc.w	100,084
		dc.w	100,067
		dc.w	130,067
LetterF:
		dc.w	130,067
		dc.w	130,067
		dc.w	100,067
		dc.w	100,084
		dc.w	115,084
		dc.w	100,084
		dc.w	100,100
LetterG:
		dc.w	115,084
		dc.w	130,084
		dc.w	130,100
		dc.w	100,100
		dc.w	100,067
		dc.w	123,067
		dc.w	130,075
LetterH:
		dc.w	100,067
		dc.w	100,100
		dc.w	100,084
		dc.w	130,084
		dc.w	130,067
		dc.w	130,100
		dc.w	130,100
LetterI:
		dc.w	107,100
		dc.w	123,100
		dc.w	115,100
		dc.w	115,067
		dc.w	123,067
		dc.w	107,067
		dc.w	107,067
LetterJ:
		dc.w	100,067
		dc.w	130,067
		dc.w	130,092
		dc.w	123,100
		dc.w	107,100
		dc.w	100,092
		dc.w	100,092
LetterK:
		dc.w	100,100
		dc.w	100,067
		dc.w	100,084
		dc.w	130,067
		dc.w	100,084
		dc.w	130,100
		dc.w	130,100
LetterL:
		dc.w	100,067
		dc.w	100,075
		dc.w	100,092
		dc.w	100,100
		dc.w	107,100
		dc.w	123,100
		dc.w	130,100
LetterM:
		dc.w	130,100
		dc.w	130,084
		dc.w	130,067
		dc.w	115,084
		dc.w	100,067
		dc.w	100,084
		dc.w	100,100
LetterN:
		dc.w	100,100
		dc.w	100,084
		dc.w	100,067
		dc.w	115,084
		dc.w	130,100
		dc.w	130,084
		dc.w	130,067
LetterO:
		dc.w	100,084
		dc.w	107,100
		dc.w	123,100
		dc.w	130,084
		dc.w	123,067
		dc.w	107,067
		dc.w	100,084
LetterP:
		dc.w	100,100
		dc.w	100,067
		dc.w	123,067
		dc.w	130,072
		dc.w	130,078
		dc.w	123,084
		dc.w	100,084
LetterQ:
		dc.w	130,100
		dc.w	100,100
		dc.w	100,067
		dc.w	130,067
		dc.w	130,100
		dc.w	123,092
		dc.w	119,088
LetterR:
		dc.w	100,100
		dc.w	100,067
		dc.w	100,067
		dc.w	130,075
		dc.w	100,084
		dc.w	130,100
		dc.w	130,100
LetterS:
		dc.w	100,100
		dc.w	130,100
		dc.w	130,084
		dc.w	100,084
		dc.w	100,067
		dc.w	130,067
		dc.w	130,067
LetterT:
		dc.w	100,067
		dc.w	130,067
		dc.w	115,067
		dc.w	115,075
		dc.w	115,084
		dc.w	115,091
		dc.w	115,100
LetterU:
		dc.w	100,067
		dc.w	100,092
		dc.w	107,100
		dc.w	123,100
		dc.w	130,092
		dc.w	130,067
		dc.w	130,067
LetterV:
		dc.w	115,100
		dc.w	130,067
		dc.w	115,100
		dc.w	100,067
		dc.w	115,100
		dc.w	130,067
		dc.w	115,100
LetterW:
		dc.w	100,067
		dc.w	100,100
		dc.w	115,084
		dc.w	130,100
		dc.w	130,067
		dc.w	130,100
		dc.w	130,067
LetterX:
		dc.w	100,100
		dc.w	130,067
		dc.w	130,067
		dc.w	115,083
		dc.w	100,067
		dc.w	100,067
		dc.w	130,100
LetterY:
		dc.w	115,100
		dc.w	115,083
		dc.w	100,067
		dc.w	115,083
		dc.w	130,067
		dc.w	115,083
		dc.w	115,100
LetterZ:
		dc.w	100,067
		dc.w	100,067
		dc.w	130,067
		dc.w	130,067
		dc.w	100,100
		dc.w	100,100
		dc.w	130,100
Space:
		dc.w	115,100
		dc.w	115,100
		dc.w	115,100
		dc.w	115,100
		dc.w	115,100
		dc.w	115,100
		dc.w	115,100
Punktum:
		dc.w	113,100
		dc.w	117,100
		dc.w	117,096
		dc.w	113,096
		dc.w	113,100
		dc.w	117,100
		dc.w	117,096
LastItem:

Xpos:		dc.w	0
Ypos:		dc.w	0

LetterTab:
		blk.l	$2e,Space
		dc.l	Punktum
		blk.l	$12,Space
		dc.l	LetterA,LetterB,LetterC,LetterD,LetterE
		dc.l	LetterF,LetterG,LetterH,LetterI,LetterJ
		dc.l	LetterK,LetterL,LetterM,LetterN,LetterO
		dc.l	LetterP,LetterQ,LetterR,LetterS,LetterT
		dc.l	LetterU,LetterV,LetterW,LetterX,LetterY
		dc.l	LetterZ

FromLetter:	blk.l	10,Space
ToLetter:	blk.l	10,Space

Text:
		DC.B	"  SHADOW  "
		DC.B	"  SYSTEMS "
		DC.B	" PRESENTS "
		DC.B	"A NEW COOL"
		DC.B	"   DEMO   "
		DC.B	" FROM THE "
		DC.B	"INNER CORE"
		DC.B	"    OF    "
		DC.B	"  NORWAY  "
		DC.B	"CODING...."
		DC.B	" PUSHEAD  "
		DC.B	"   AND    "
		DC.B	"DOC MENTAL"
		DC.B	"GRAPHICS.."
		DC.B	" PUSHEAD  "
		DC.B	"MUSIC....."
		DC.B	"   OMEN   "
		DC.B	"WE ARE THE"
		DC.B	"NEW ELITE."
		dc.b	"          "
		dc.b	0

even
TextAdd:	dc.l	Text

Delay:		dc.w	1
DoneConv:	dc.w	0
Flags:		blk.w	10,0
DummyObject:	blk.w	[20*2],0

Flag:		dc.w	0
Screen:		dc.l	Plane1
Bottom:		dc.l	Plane1+[36*40]
Plane1:		blk.b	[36*40],$0
Plane2:		blk.b	[36*40],$0
e:
