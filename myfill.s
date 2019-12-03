	org	$40000
	load	$40000
s:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr.l	InitProgram

	lea	$dff000,a6

	move.w	#$7fff,d0
	move.w	#$8000,d1

	move.w	$02(a6),OldDMA
	move.w	$1c(a6),OldINT
	or.w	d1,OldDMA
	or.w	d1,OldINT
	move.w	d0,$96(a6)
	move.w	d0,$9a(a6)
	move.w	#$8000+$200+$100+$80+$40,$96(a6)
	move.w	#$c010,$9a(a6)

	move.l	$6c.w,OldLEV3Vector
	move.l	#NewLEV3Vector,$6c.w

	move.l	#Copper,$80(a6)
	clr.w	$88(a6)

Mouse:
	btst	#6,$bfe001
	bne.s	Mouse

	move.l	4,a5
	move.l	156(a5),a1
	move.l	50(a1),$80(a6)
	clr.w	$88(a6)

	move.w	#$7fff,d0
	move.w	d0,$96(a6)
	move.w	d0,$9a(a6)
	move.w	OldDMA,$96(a6)
	move.w	OldINT,$9a(a6)

	move.l	OldLEV3Vector,$6c.w

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

OldDMA:		dc.w	0
OldINT:		dc.w	0
OldLEV3Vector:	dc.l	0

NewLEV3Vector:
	btst	#4,$1e(a6)
	beq.s	NoRequest

	movem.l	d0-d7/a0-a6,-(a7)

	bsr.s	LineDraw
	move.w	#$000,$dff180

	movem.l	(a7)+,d0-d7/a0-a6

NoRequest:
	move.w	#$0010,$9c(a6)
	rte

LineDraw:

**************************************************************

; Double Buffering and Clear Screen

*************************************************************

	move.l	#Plane1,d0
	move.l	#Plane2,Screen
	move.l	#Plane2,$54(a6)

	eor.w	#1,Flag
	bne.s	DoubleBuffering

	move.l	#Plane2,d0
	move.l	#Plane1,Screen
	move.l	#Plane1,$54(a6)

DoubleBuffering:
	move.w	d0,Lo1
	swap	d0
	move.w	d0,Hi1

	move.l	#$01000000,$40(a6)
	clr.w	$66(a6)
	move.w	#[256*64]+20,$58(a6)

w1:	btst	#14,$02(a6)
	bne.s	w1

**************************************************************

; Rotate Points

**************************************************************

	movem.l	CLR,d0-d7

	lea	Object,a0
	move.w	(a0)+,d7

	lea	Rotated,a1

	lea	Sinus,a2
	lea	Sinus+512,a3

	move.w	Xangle,d0
	move.w	Yangle,d1
	move.w	Zangle,d2
RotLoop:

	move.w	(a0)+,X
	move.w	(a0)+,Y
	move.w	(a0)+,Z

********** Rotasjon rundt X-aksen ***************************

	moveq	#0,d3
	moveq	#0,d4
	move.w	(a2,d0.w),d3	; Sinus
	move.w	(a3,d0.w),d4	; Cosinus
	ext.l	d3
	ext.l	d4

	moveq	#0,d5
	moveq	#0,d6
	move.w	Y,d5
	move.w	Z,d6
	muls	d4,d5
	muls	d3,d6
	sub.l	d6,d5
	asr.l	#8,d5
	asr.l	#3,d5
	move.w	d5,NY

	moveq	#0,d5
	moveq	#0,d6
	move.w	Y,d5
	move.w	Z,d6
	muls	d3,d5
	muls	d4,d6
	add.l	d6,d5
	asr.l	#8,d5
	asr.l	#3,d5
	move.w	d5,Z

********** Rotasjon rundt Y-aksen ***************************

	move.w	NY,Y

	moveq	#0,d3
	moveq	#0,d4
	move.w	(a2,d1.w),d3	; Sinus
	move.w	(a3,d1.w),d4	; Cosinus
	ext.l	d3
	ext.l	d4

	moveq	#0,d5
	moveq	#0,d6
	move.w	X,d5
	move.w	Z,d6
	muls	d4,d5
	muls	d3,d6
	sub.l	d6,d5
	asr.l	#8,d5
	asr.l	#3,d5
	move.w	d5,NX

	moveq	#0,d5
	moveq	#0,d6
	move.w	X,d5
	move.w	Z,d6
	muls	d3,d5
	muls	d4,d6
	add.l	d6,d5
	asr.l	#8,d5
	asr.l	#3,d5
	move.w	d5,NZ

********** Rotasjon rundt Z-aksen ***************************

	move.w	NX,X

	moveq	#0,d3
	moveq	#0,d4
	move.w	(a2,d2.w),d3	; Sinus
	move.w	(a3,d2.w),d4	; Cosinus
	ext.l	d3
	ext.l	d4

	moveq	#0,d5
	moveq	#0,d6
	move.w	X,d5
	move.w	Y,d6
	muls	d4,d5
	muls	d3,d6
	sub.l	d6,d5
	asr.l	#8,d5
	asr.l	#3,d5
	move.w	d5,NX

	moveq	#0,d5
	moveq	#0,d6
	move.w	X,d5
	move.w	Y,d6
	muls	d3,d5
	muls	d4,d6
	add.l	d6,d5
	asr.l	#8,d5
	asr.l	#3,d5
	move.w	d5,NY

	move.w	NX,(a1)+
	move.w	NY,(a1)+
	move.w	NZ,(a1)+

	dbf	d7,RotLoop

	add.w	#$7fa,Xangle
	add.w	#$000,Yangle
	add.w	#$010,Zangle
	and.w	#$7fe,Xangle
	and.w	#$7fe,Yangle
	and.w	#$7fe,Zangle

**************************************************************

; Convert from 3D to 2D

**************************************************************

	lea	Object,a0
	move.w	(a0),d7

	lea	Rotated,a0
	lea	Converted,a1

	moveq	#0,d6
	move.w	Zoom,d6
ConvertLoop:
	movem.l	CLR,d0-d2

	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2

	add.w	#750,d2	
	tst.w	d2
	bne.s	NotNULL

	move.w	#1,d2

NotNULL:
	muls	d6,d0
	muls	d6,d1
	divs	d2,d0
	divs	d2,d1

	add.w	#159,d0
	add.w	#127,d1

	move.w	d0,(a1)+
	move.w	d1,(a1)+

	dbra	d7,ConvertLoop

	move.l	#-1,$44(a6)
	move.l	#$ffff8000,$72(a6)
	move.w	#$28,$60(a6)
	move.w	#$28,$66(a6)

	lea	Object,a0
	move.w	(a0),d7
	sub.w	#1,d7

	lea	Converted,a0	
	move.l	Screen,a1
LineLoop:
	movem.l	CLR,d0-d3

	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	6(a0),d3
	add.l	#$4,a0

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
	or.w	#$b5a,d0
	move.w	d0,$40(a6)
	move.w	d4,$42(a6)

	move.l	d1,$48(a6)
	move.l	d1,$54(a6)

	lsl.w	#6,d3
	add.w	#2,d3
	move.w	d3,$58(a6)
	
w2:	btst	#14,$02(a6)
	bne.s	w2

	dbf	d7,LineLoop

	bra.s	FindLittle_Big

Octant:
	dc.b	[0*4]+3
	dc.b	[4*4]+3
	dc.b	[2*4]+3
	dc.b	[5*4]+3
	dc.b	[1*4]+3
	dc.b	[6*4]+3
	dc.b	[3*4]+3
	dc.b	[7*4]+3
even

****************************************************************

; Fill Object

****************************************************************

FindLittle_Big:
	lea	Converted,a0
	lea	Object,a2
	move.w	(a2),d7

	movem.l	CLR,d0-d2

	moveq	#$0000,d0
	move.w	#$8000,d1
Search:
	move.w	2(a0),d2
	cmp.w	d2,d0
	bge.s	Skip1
	move.w	d2,d0
Skip1:
	cmp.w	d2,d1
	bmi.s	Skip2
	move.w	d2,d1
Skip2:
	addq.w	#$4,a0
	dbf	d7,Search

	bsr.s	SetPixels

	move.w	d2,d3
	sub.w	d1,d2		; Fill Size
	subq.w	#1,d2
	beq.s	NoFill		; If FillSize=0 then don't fill.

	subq.w	#1,d3		; Fill From BottomPoint-1
	move.w	d1,d3
	lsl.w	#3,d1
	lsl.w	#5,d3
	add.w	d3,d1
	add.l	a1,d1

	move.l	#$09f0000a,$40(a6)
	clr.l	$64(a6)

	move.l	d1,$50(a6)
	move.l	d1,$54(a6)

	lsl.w	#6,d2
	add.w	#20,d2
	move.w	d2,$58(a6)

w3:	btst	#14,$02(a6)
	bne.s	w3

NoFill:
	rts

SetPixels:
	lea	Converted,a0
	lea	Object,a2
	move.w	(a2),d7
	subq.w	#1,d7
SetPixLoop:
	moveq	#0,d3
	move.w	2(a0),d3
	cmp.w	d0,d3
	beq.s	Next
	cmp.w	d1,d3
	beq.s	Next

	move.w	(a0),d4

	move.w	d3,d5
	lsl.w	#3,d3
	lsl.w	#5,d5
	add.w	d5,d3

	move.w	d4,d5
	lsr.w	#3,d4
	add.w	d4,d3
	not.w	d5

	bchg	d5,(a1,d3.w)

Next:
	addq.w	#$4,a0
	dbf	d7,SetPixLoop
	rts

InitProgram:
	move.l	#Plane1,d0
	move.w	d0,Lo1
	swap	d0
	move.w	d0,Hi1

	rts

Copper:
	dc.w	$0c01,$ff00
	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0100,$0000

	dc.w	$00e0
Hi1:	dc.w	$0000
	dc.w	$00e2
Lo1:	dc.w	$0000
	dc.w	$2c01,$ff00,$0100,$1200
	dc.w	$ffdf,$fffe
	dc.w	$2c01,$ff00,$0100,$0000
	dc.w	$009c,$8010

	dc.w	$ffff,$fffe

CLR:		blk.l	15,0
Zoom:		dc.w	140


Object:		dc.w	4	; Antall punkter

		dc.w	-40,-40,040
		dc.w	040,-40,040
		dc.w	040,040,040
		dc.w	-40,040,040
		dc.w	-40,-40,040

Rotated:	blk.w	[64*3],0
Converted:	blk.w	[64*2],0

X:		dc.w	0
Y:		dc.w	0
Z:		dc.w	0
NX:		dc.w	0
NY:		dc.w	0
NZ:		dc.w	0

Xangle:		dc.w	0
Yangle:		dc.w	0
Zangle:		dc.w	0

Sinus:		incbin	"VectorSinus"

Flag:		dc.w	0
Screen:		dc.l	0
Bottom:		dc.l	0
Plane1:		blk.b	[256*40],240
Plane2:		blk.b	[256*40],15
