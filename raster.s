	org	$40000
	load	$40000
s:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr.l	InitPrg

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
	move.w	#$c000+$10,$9a(a6)

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

	bsr.s	Raster

	movem.l	(a7)+,d0-d7/a0-a6

NoRequest:
	move.w	#$0010,$9c(a6)
	rte

Raster:
	lea	$dff000,a6
	move.l	#Block+6,$54(a6)
	move.l	#$01000000,$40(a6)
	move.w	#$0006,$66(a6)
	move.w	#[100*64]+1,$58(a6)

wblt:	btst	#14,$02(a6)
	bne.s	wblt
	
	lea	Block+6,a0
	lea	Block,a1

	move.l	#-1,$44(a6)
	move.l	#$09f00000,$40(a6)

	move.w	Ypos,d0

	move.w	#2,d7
Loop2:
	move.w	d0,d1
	lsl.w	#3,d1
	add.l	a1,d1

	move.l	a1,$50(a6)
	move.l	d1,$54(a6)
	move.w	#[9*64]+1,$58(a6)

wblt2:	btst	#14,$02(a6)
	bne.s	wblt2

	add.w	#2,d0

	dbra	d7,Loop2

Adder:	add.w	#4,Ypos
	cmp.w	#90,Ypos
	blt.s	Ok
	move.w	#-4,Adder+2
Ok:	rts

InitPrg:
	lea	block,a0
	move.l	#$2c21fffe,d0
	move.l	#$01800000,d1
	move.w	#99,d7
Loop:
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	add.l	#$01000000,d0
	dbra	d7,Loop
	
	rts

Copper:
	dc.w	$0c01,$ff00

	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0100,$0000

block:	blk.l	[100*2],$01fe01fe

	dc.w	$ffdf,$fffe
	dc.w	$0000,$8010
	dc.w	$ffff,$fffe

Color:	dc.w	$111,$333,$555,$777,$999,$777,$555,$333,$111

Ypos:	dc.w	0
