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

	bsr.s	Parallax

	movem.l	(a7)+,d0-d7/a0-a6

NoRequest:
	move.w	#$0010,$9c(a6)
	rte

Parallax:
	bsr.s	Para1
	bsr.s	Para2
	bsr.L	Para3
	bsr.L	Para4
	bsr.L	Para5
	bsr.L	Para6
	bsr.L	Para7

	sub.w	#$11,Scroll8
	bge.s	NoReset8
	move.w	#$ff,Scroll8
NoReset8:
	rts

Para1:
	sub.w	#$1,Delay1
	bne.s	NoReset1
	move.w	#$8,Delay1

	sub.w	#$11,Scroll1
	bge.s	NoReset1
	move.w	#$ff,Scroll1
NoReset1:
	rts

Para2:
	sub.w	#$1,Delay2
	bne.s	NoReset2
	move.w	#$7,Delay2

	sub.w	#$11,Scroll2
	bge.s	NoReset2
	move.w	#$ff,Scroll2
NoReset2:
	rts

Para3:
	sub.w	#$1,Delay3
	bne.s	NoReset3
	move.w	#$6,Delay3

	sub.w	#$11,Scroll3
	bge.s	NoReset3
	move.w	#$ff,Scroll3
NoReset3:
	rts

Para4:
	sub.w	#$1,Delay4
	bne.s	NoReset4
	move.w	#$5,Delay4

	sub.w	#$11,Scroll4
	bge.s	NoReset4
	move.w	#$ff,Scroll4
NoReset4:
	rts

Para5:
	sub.w	#$1,Delay5
	bne.s	NoReset5
	move.w	#$4,Delay5

	sub.w	#$11,Scroll5
	bge.s	NoReset5
	move.w	#$ff,Scroll5
NoReset5:
	rts

Para6:
	sub.w	#$1,Delay6
	bne.s	NoReset6
	move.w	#$3,Delay6

	sub.w	#$11,Scroll6
	bge.s	NoReset6
	move.w	#$ff,Scroll6
NoReset6:
	rts

Para7:
	sub.w	#$1,Delay7
	bne.s	NoReset7
	move.w	#$2,Delay7

	sub.w	#$11,Scroll7
	bge.s	NoReset7
	move.w	#$ff,Scroll7
NoReset7:
	rts

InitPrg:
	move.l	#PlaxGrass,d0
	move.w	d0,Lo1a
	move.w	d0,Lo1b
	move.w	d0,Lo1c
	move.w	d0,Lo1d
	move.w	d0,Lo1e
	move.w	d0,Lo1f
	move.w	d0,Lo1g
	move.w	d0,Lo1h
	swap	d0
	move.w	d0,Hi1a
	move.w	d0,Hi1b
	move.w	d0,Hi1c
	move.w	d0,Hi1d
	move.w	d0,Hi1e
	move.w	d0,Hi1f
	move.w	d0,Hi1g
	move.w	d0,Hi1h
	swap	d0
	add.l	#40,d0

	move.w	d0,Lo2a
	move.w	d0,Lo2b
	move.w	d0,Lo2c
	move.w	d0,Lo2d
	move.w	d0,Lo2e
	move.w	d0,Lo2f
	move.w	d0,Lo2g
	move.w	d0,Lo2h
	swap	d0
	move.w	d0,Hi2a
	move.w	d0,Hi2b
	move.w	d0,Hi2c
	move.w	d0,Hi2d
	move.w	d0,Hi2e
	move.w	d0,Hi2f
	move.w	d0,Hi2g
	move.w	d0,Hi2h
	swap	d0
	add.l	#40,d0

	move.w	d0,Lo3a
	move.w	d0,Lo3b
	move.w	d0,Lo3c
	move.w	d0,Lo3d
	move.w	d0,Lo3e
	move.w	d0,Lo3f
	move.w	d0,Lo3g
	move.w	d0,Lo3h
	swap	d0
	move.w	d0,Hi3a
	move.w	d0,Hi3b
	move.w	d0,Hi3c
	move.w	d0,Hi3d
	move.w	d0,Hi3e
	move.w	d0,Hi3f
	move.w	d0,Hi3g
	move.w	d0,Hi3h
	rts

Copper:
	dc.w	$0c01,$ff00

	dc.w	$008e,$2c91,$0090,$2cb1,$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0050,$010a,$0050

	dc.w	$0180,$0000,$0182,$00c0,$0184,$00a0,$0186,$0090
	dc.w	$0188,$0080,$018a,$0060,$018c,$0050,$018e,$00cc

	dc.w	$0100,$0000

	dc.w	$7f01,$ff00
	dc.w	$00e0
Hi1a:	dc.w	$0000
	dc.w	$00e2
Lo1a:	dc.w	$0000
	dc.w	$00e4
Hi2a:	dc.w	$0000
	dc.w	$00e6
Lo2a:	dc.w	$0000
	dc.w	$00e8
Hi3a:	dc.w	$0000
	dc.w	$00ea
Lo3a:	dc.w	$0000
	dc.w	$8001,$ff00,$0100,$3200,$0102
Scroll1:dc.w	$0000

	dc.w	$8201,$ff00
	dc.w	$00e0
Hi1b:	dc.w	$0000
	dc.w	$00e2
Lo1b:	dc.w	$0000
	dc.w	$00e4
Hi2b:	dc.w	$0000
	dc.w	$00e6
Lo2b:	dc.w	$0000
	dc.w	$00e8
Hi3b:	dc.w	$0000
	dc.w	$00ea
Lo3b:	dc.w	$0000
	dc.w	$0102
Scroll2:dc.w	$0000

	dc.w	$8601,$ff00
	dc.w	$00e0
Hi1c:	dc.w	$0000
	dc.w	$00e2
Lo1c:	dc.w	$0000
	dc.w	$00e4
Hi2c:	dc.w	$0000
	dc.w	$00e6
Lo2c:	dc.w	$0000
	dc.w	$00e8
Hi3c:	dc.w	$0000
	dc.w	$00ea
Lo3c:	dc.w	$0000
	dc.w	$0102
Scroll3:dc.w	$0000

	dc.w	$8c01,$ff00
	dc.w	$00e0
Hi1d:	dc.w	$0000
	dc.w	$00e2
Lo1d:	dc.w	$0000
	dc.w	$00e4
Hi2d:	dc.w	$0000
	dc.w	$00e6
Lo2d:	dc.w	$0000
	dc.w	$00e8
Hi3d:	dc.w	$0000
	dc.w	$00ea
Lo3d:	dc.w	$0000
	dc.w	$0102
Scroll4:dc.w	$0000

	dc.w	$9401,$ff00
	dc.w	$00e0
Hi1e:	dc.w	$0000
	dc.w	$00e2
Lo1e:	dc.w	$0000
	dc.w	$00e4
Hi2e:	dc.w	$0000
	dc.w	$00e6
Lo2e:	dc.w	$0000
	dc.w	$00e8
Hi3e:	dc.w	$0000
	dc.w	$00ea
Lo3e:	dc.w	$0000
	dc.w	$0102
Scroll5:dc.w	$0000

	dc.w	$9e01,$ff00
	dc.w	$00e0
Hi1f:	dc.w	$0000
	dc.w	$00e2
Lo1f:	dc.w	$0000
	dc.w	$00e4
Hi2f:	dc.w	$0000
	dc.w	$00e6
Lo2f:	dc.w	$0000
	dc.w	$00e8
Hi3f:	dc.w	$0000
	dc.w	$00ea
Lo3f:	dc.w	$0000
	dc.w	$0102
Scroll6:dc.w	$0000

	dc.w	$aa01,$ff00
	dc.w	$00e0
Hi1g:	dc.w	$0000
	dc.w	$00e2
Lo1g:	dc.w	$0000
	dc.w	$00e4
Hi2g:	dc.w	$0000
	dc.w	$00e6
Lo2g:	dc.w	$0000
	dc.w	$00e8
Hi3g:	dc.w	$0000
	dc.w	$00ea
Lo3g:	dc.w	$0000
	dc.w	$0102
Scroll7:dc.w	$0000

	dc.w	$b801,$ff00
	dc.w	$00e0
Hi1h:	dc.w	$0000
	dc.w	$00e2
Lo1h:	dc.w	$0000
	dc.w	$00e4
Hi2h:	dc.w	$0000
	dc.w	$00e6
Lo2h:	dc.w	$0000
	dc.w	$00e8
Hi3h:	dc.w	$0000
	dc.w	$00ea
Lo3h:	dc.w	$0000
	dc.w	$0102
Scroll8:dc.w	$0000

	dc.w	$c801,$ff00,$0100,$0000

	dc.w	$ffdf,$fffe
	dc.w	$009c,$8010
	dc.w	$ffff,$fffe

PlaxGrass:	incbin	"Grass"

Delay1:		dc.w	8
Delay2:		dc.w	7
Delay3:		dc.w	6
Delay4:		dc.w	5
Delay5:		dc.w	4
Delay6:		dc.w	3
Delay7:		dc.w	2
