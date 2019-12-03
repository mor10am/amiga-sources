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
	clr.w	$88(a6)

	clr.l	$144(a6)

	move.w	#$2000,sr

Mouse:
	btst	#6,$bfe001
	bne.s	Mouse

	move.w	#$2700,sr

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

	bsr.s	LinePrg

	movem.l	(a7)+,d0-d7/a0-a6

NoRequest:
	move.w	#$0010,$9c(a6)
	rte

HiddenFlag:	dc.w	0

LinePrg:
	move.l	#Plane1,d0
	move.l	#Plane1a,d1

	move.l	#Plane2,Screen
	move.l	#Plane2a,Screen2

	eor.w	#1,Flag
	bne.s	DBuffer

	move.l	#Plane2,d0
	move.l	#Plane2a,d1

	move.l	#Plane1,Screen
	move.l	#Plane1a,Screen2

DBuffer:
	move.w	d0,lo	
	swap	d0
	move.w	d0,hi

	move.w	d1,loa
	swap	d1
	move.w	d1,hia

	lea	$dff000,a6
	move.l	#-1,$44(a6)
	move.l	#$ffff8000,$72(a6)
	move.w	#$28,$60(a6)

	move.l	Screen,$54(a6)
	move.l	#$01000000,$40(a6)
	clr.w	$66(a6)
	move.w	#[512*64]+20,$58(a6)

	lea	Points,a0
	lea	Rotated,a1
	lea	Sinus,a2
	lea	Sinus+1024,a3

	move.w	Xangle(pc),d0
	move.w	Yangle(pc),d1
	move.w	Zangle(pc),d2

	move.w	Antall,d7
RotateLoop:
	move.w	(a0)+,Xp
	move.w	(a0)+,Yp
	move.w	(a0)+,Zp

****** X rotasjon *********

	move.w	Yp(PC),d3
	move.w	Zp(PC),d4
	move.w	(a2,d0.w),d5
	move.w	(a3,d0.w),d6
	muls	d6,d3
	muls	d5,d4
	sub.l	d4,d3
	asl.l	#1,d3
	swap	d3
	move.w	d3,Ny

	move.w	Yp(PC),d3
	move.w	Zp(PC),d4
	muls	d5,d3
	muls	d6,d4
	add.l	d4,d3
	asl.l	#1,d3
	swap	d3
	move.w	d3,Nz

****** Y rotasjon *********

	move.w	Xp(PC),d3
	move.w	Nz(PC),d4
	move.w	(a2,d1.w),d5
	move.w	(a3,d1.w),d6
	muls	d6,d3
	muls	d5,d4
	sub.l	d4,d3
	asl.l	#1,d3
	swap	d3
	move.w	d3,Nx

	move.w	Xp(PC),d3
	move.w	Nz(PC),d4
	muls	d5,d3
	muls	d6,d4
	add.l	d4,d3
	asl.l	#1,d3
	swap	d3
	move.w	d3,4(a1)

****** Z rotasjon *********

	move.w	Nx(PC),d3
	move.w	Ny(PC),d4
	move.w	(a2,d2.w),d5
	move.w	(a3,d2.w),d6
	muls	d6,d3
	muls	d5,d4
	sub.l	d4,d3
	asl.l	#1,d3
	swap	d3
	move.w	d3,(a1)

	move.w	Nx(PC),d3
	move.w	Ny(PC),d4
	muls	d5,d3
	muls	d6,d4
	add.l	d4,d3
	asl.l	#1,d3
	swap	d3
	move.w	d3,2(a1)

	addq.l	#$6,a1
	dbf	d7,RotateLoop

All_Rotated:
	add.w	#$008,Xangle
	add.w	#$00e,Yangle
	add.w	#$020,Zangle

	and.w	#$ffe,Xangle
	and.w	#$ffe,Yangle
	and.w	#$ffe,Zangle

	bra.l	Convert

Xangle:		dc.w	0
Yangle:		dc.w	0
Zangle:		dc.w	0

Xp:		dc.w	0
Yp:		dc.w	0
Zp:		dc.w	0
Nx:		dc.w	0
Ny:		dc.w	0
Nz:		dc.w	0

NextSurface:	dc.w	0

Convert:
	lea	Rotated,a0
	lea	Converted,a1

	moveq	#0,d2
	move.w	Zoom,d6
	move.w	Antall,d7
ConvertLoop:
	moveq	#0,d0
	moveq	#0,d1
	
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2

	add.w	#1500,d2
	bne.s	NoNULL

	moveq	#1,d2

NoNULL:
	muls	d6,d0
	muls	d6,d1
	divs	d2,d0
	divs	d2,d1
	add.w	#159,d0
	add.w	#127,d1

	move.w	d0,(a1)+
	move.w	d1,(a1)+

	dbf	d7,ConvertLoop

DisplaySurfaces:
	movem.l	CLR,d0-d7

wb:	btst	#14,$02(a6)
	bne.s	wb

	move.w	#$28,$66(a6)

	lea	Converted,a0
	lea	Lines+2,a1	
	lea	Lines,a2
CheckHidden:
	move.w	(a2),d6
	beq.L	NoMoreSurfaces

	addq.w	#1,d6
	lsl.w	#1,d6
	addq.w	#$4,d6
	move.w	d6,NextSurface	

	move.w	(a1),d0
	lsl.w	#2,d0
	move.w	2(a1),d1
	lsl.w	#2,d1
	move.w	4(a1),d2
	lsl.w	#2,d2

	move.w	(a0,d1.w),d3
	sub.w	(a0,d0.w),d3	; DX¹

	move.w	(a0,d2.w),d4
	sub.w	(a0,d1.w),d4	; DX²

	move.w	2(a0,d1.w),d5
	sub.w	2(a0,d0.w),d5	; DY¹

	move.w	2(a0,d2.w),d6
	sub.w	2(a0,d1.w),d6	; DY²

	muls	d3,d6
	muls	d4,d5
	sub.l	d6,d5
	bge.L	HiddenSurface

DrawSurface:
	move.w	(a2),d7
	subq.w	#1,d7

	move.w	(a2),d6
	lsl.w	#1,d6
	addq.w	#4,d6
	move.w	(a2,d6.w),d6

DrawLines:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3

	move.w	(a1)+,d4
	lsl.w	#2,d4
	move.w	(a1),d5
	lsl.w	#2,d5

	move.w	(a0,d4.w),d0
	move.w	2(a0,d4.w),d1
	move.w	(a0,d5.w),d2
	move.w	2(a0,d5.w),d3

	tst.w	d0
	blt.s	HiddenSurface
	cmp.w	#319,d0
	bgt.s	HiddenSurface

	tst.w	d1
	blt.s	HiddenSurface
	cmp.w	#255,d1
	bgt.s	HiddenSurface

	tst.w	d2
	blt.s	HiddenSurface
	cmp.w	#319,d2
	bgt.s	HiddenSurface

	tst.w	d3
	blt.s	HiddenSurface
	cmp.w	#255,d3
	bgt.s	HiddenSurface

	move.l	a1,-(a7)

	btst	#0,d6
	beq.s	NextPlane

	move.l	Screen,a1
	bsr.s	DrawThisLine

NextPlane:
	btst	#1,d6
	beq.s	NotPlane2

	move.l	Screen2,a1
	bsr.s	DrawThisLine
	
NotPlane2:
	move.l	(a7)+,a1

	dbf	d7,DrawLines
	
HiddenSurface:
	moveq	#0,d6
	move.w	NextSurface,d6
	add.l	d6,a2
	move.l	a2,a1
	addq.w	#$2,a1
	bra.L	CheckHidden

NoMoreSurfaces:
;bra.s	a
	move.l	Screen,a5
	add.l	#[462*40],a5
	move.l	a5,$50(a6)
	move.l	a5,$54(a6)
	
	move.l	#$09f00012,$40(a6)
	clr.l	$64(a6)
	move.w	#[412*64]+20,$58(a6)

wb3:	btst	#14,$02(a6)
	bne.s	wb3
a:		
	rts

DrawThisLine:
	movem.l	d0-d7/a0-a6,-(a7)

**************************************************************

; 	Finn riktig oktant for linjen.

;	D0 = X¹
;	D1 = Y¹
; 	D2 = X²
;	D3 = Y²

;	D4 = oktant

**************************************************************

	moveq	#1,d5

	cmp.w	d1,d3
	bmi.s	Ok_DrawDir

	exg	d0,d2
	exg	d1,d3

Ok_DrawDir:
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

	tst.w	d3
	beq.s	wb2

	move.w	d2,d5
	divu	d3,d5

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

	sub.w	d5,d3
	bmi.s	wb2

	addq.w	#1,d3
	lsl.w	#6,d3
	add.w	#2,d3
	move.w	d3,$58(a6)

wb2:	btst	#14,$02(a6)
	bne.s	wb2
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

Octant:
	dc.b	[0*4]+3
	dc.b	[4*4]+3
	dc.b	[2*4]+3
	dc.b	[5*4]+3
	dc.b	[1*4]+3
	dc.b	[6*4]+3
	dc.b	[3*4]+3
	dc.b	[7*4]+3

InitProgram:
	move.l	#Plane1,d0
	move.w	d0,lo
	swap	d0
	move.w	d0,hi

	lea	sinus,a0
	lea	sin2,a1
	move.w	#2047,d7
copy:	move.w	(a0)+,(a1)+
	dbf	d7,copy

	rts

Copper:
	dc.w	$0c01,$ff00
	dc.w	$0100,$0000

	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$068e,$0184,$046c,$0186,$024a

	dc.w	$00e0
hi:	dc.w	$0000
	dc.w	$00e2
lo:	dc.w	$0000
	dc.w	$00e4
hia:	dc.w	$0000
	dc.w	$00e6
loa:	dc.w	$0000
	dc.w	$2c01,$ff00,$0100,$2200
	dc.w	$ffdf,$fffe
	dc.w	$2c01,$ff00,$0100,$0000

	dc.w	$009c,$8010
	dc.w	$ffff,$fffe

OldStack:	dc.l	0
CLR:		blk.l	15,0

Antall:		dc.w	8-1

Points:
		dc.w	-90,-90,-90	; 0
		dc.w	090,-90,-90	; 1
		dc.w	090,090,-90	; 2
		dc.w	-90,090,-90	; 3

		dc.w	-90,-90,090	; 4
		dc.w	090,-90,090	; 5
		dc.w	090,090,090	; 6
		dc.w	-90,090,090	; 7

Lines:
		dc.w	4,0,1,2,3,0,$01
		dc.w	4,4,7,6,5,4,$01

		dc.w	4,5,6,2,1,5,$02
		dc.w	4,4,0,3,7,4,$02

		dc.w	4,4,5,1,0,4,$03
		dc.w	4,7,3,2,6,7,$03
		
		dc.w	$0000

Rotated:	blk.w	[8*64],0
Converted:	blk.w	[2*64],0

Zoom:		dc.w	750

Flag:		dc.w	0
Screen:		dc.l	Plane1
Screen2:	dc.l	Plane1a

Plane1:		blk.b	[256*40],0
Plane1a:	blk.b	[256*40],0

Plane2:		blk.b	[256*40],0
Plane2a:	blk.b	[256*40],0

Sinus:		incbin	"VectorSinus"
Sin2:		blk.b	4096,0
