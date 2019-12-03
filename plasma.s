	org	$40000
	load	$40000
s:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr.l	Init
	move.w	#$0020,$dff096

	move.l	$80,OldTrap
	move.l	#NewTrap,$80
	
WaitTrap:
	cmp.b	#$80,$dff006
	bne	WaitTrap

	move.l	#Copper,$dff080
	move.l	#Copper1,$dff084
	clr.w	$dff088

	trap	#0

	move.l	OldTrap,$80
	move.w	#$8020,$dff096

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts	

NewTrap:
	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#$2700,sr
	movem.l	CLR,d0-d7/a0-a6

	move.w	#$8400,$dff096
wait:
	cmp.b	#$2c,$dff006
	bne	wait

;	move.w	#$600,$dff180
	bsr.s	Plasma
;	move.w	#$000,$dff180

	btst	#6,$bfe001
	beq	Exit
	btst	#2,$dff016
	bne	wait

Exit:
	move.w	#$0400,$dff096

	movem.l	(a7)+,d0-d7/a0-a6
	rte

Plasma:
	move.l	#Block1,a3
	move.l	#Copper2,$dff084

	eor.w	#1,Flag
	beq.s	DoubleBuffer

	move.l	#Block2,a3
	move.l	#Copper1,$dff084
DoubleBuffer:
	move.l	a3,a4
	add.l	#6,a3

	moveq	#0,d0
	moveq	#0,d1

	lea	$dff000,a6
	move.l	#-1,$44(a6)
	move.l	#$000000d6,$64(a6)
	move.l	#$09f00000,$40(a6)

	lea	sinus,a0
	lea	ColorCycle,a1

	move.b	Yadd1,d0
	move.b	Yadd2,d1

	move.w	#51,d7
DoLoop:
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0),d2
	move.b	(a0,d1),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	add.l	a1,d2

	addq.b	#$02,d0
	addq.b	#$04,d1

	move.l	d2,$50(a6)
	move.l	a3,$54(a6)
	move.w	#[160*64]+1,$58(a6)
	nop
	nop

	add.l	#$4,a3

	dbra	d7,DoLoop

	add.b	#$03,Yadd1
	add.b	#$fe,Yadd2

	moveq	#0,d0
	moveq	#0,d1

	lea	sinus2,a0
	move.b	Xadd1,d0
	move.b	Xadd2,d1

	move.w	#159,d7
DoLoop2:
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0),d2
	move.b	(a0,d1),d3
	add.w	d3,d2
	lsr.w	#1,d2
	add.b	#$17,d2
	bset	#0,d2

	addq.b	#$06,d0
	addq.b	#$01,d1

	move.b	d2,1(a4)
	add.l	#$d8,a4
	dbra	d7,DoLoop2

	add.b	#$ff,Xadd1
	add.b	#$02,Xadd2

	

	rts

Init:
	move.l	#plane,d1
	move.w	d1,lo
	swap	d1
	move.w	d1,hi

	lea	Block1,a0
	move.w	#$2d21,d0
	move.w	#159,d7
Loop1:
	move.w	d0,(a0)+
	move.w	#$fffe,(a0)+

	move.w	#51,d6
Inner1:
	move.l	#$01820000,(a0)+
	dbra	d6,Inner1

	move.l	#$01820000,(a0)+

	add.w	#$100,d0
	dbra	d7,Loop1

	move.w	d0,(a0)+
	move.w	#$ff00,(a0)+
	move.l	#$01000000,(a0)+

	lea	Block2,a0
	move.w	#$2d21,d0
	move.w	#159,d7
Loop2:
	move.w	d0,(a0)+
	move.w	#$fffe,(a0)+

	move.w	#51,d6
Inner2:
	move.l	#$01820fff,(a0)+
	dbra	d6,Inner2

	move.l	#$01820000,(a0)+

	add.w	#$100,d0
	dbra	d7,Loop2

	move.w	d0,(a0)+
	move.w	#$ff00,(a0)+
	move.l	#$01000000,(a0)+

	rts

copper:
	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0180,$0000
	dc.w	$0100,$0000
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$00e0
hi:	dc.w	$0000
	dc.w	$00e2
lo:	dc.w	$0000
	dc.w	$2c01,$ff00,$0100,$1200
	
	dc.w	$008a,$0000

Copper1:
Block1:	blk.l	8642,$01fe01fe	
	dc.w	$ffff,$fffe

Copper2:
Block2:	blk.l	8642,$01fe01fe	
	dc.w	$ffff,$fffe


OldTrap:	dc.l	0
Clr:		blk.l	15,0

Yadd1:		dc.b	0
Yadd2:		dc.b	0
Xadd1:		dc.b	0
Xadd2:		dc.b	0

Flag:		dc.w	0
Update:		dc.l	Block1
Plane:		blk.b	[162*40],-1
ColorCycle:	incbin	"ColorCycle"
Sinus:		incbin	"Sinus128"
Sinus2:		incbin	"Sinus32"
