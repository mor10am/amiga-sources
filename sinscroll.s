
s:

OneWord:	MACRO
		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$80008000,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$40004000,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$20002000,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$10001000,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$08000800,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$04000400,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$02000200,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop


		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$01000100,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00800080,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00400040,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00200020,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00100010,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop


		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00080008,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00040004,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00020002,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		moveq	#0,d2
		moveq	#0,d3
		move.b	(a0,d0),d2
		move.b	(a0,d1),d3
		add.w	d3,d2
		lsr.w	#1,d2
		move.w	d2,d3
		lsl.w	#3,d2
		lsl.w	#5,d3
		add.w	d3,d2

		moveq	#0,d4
		move.w	d2,d4
		add.w	d6,d4
		add.l	a1,d4

		add.b	yspd1,d0
		add.b	yspd2,d1

		move.l	#$00010001,$44(a6)
		move.l	d4,$4c(a6)
		move.l	a2,$50(a6)
		move.l	d4,$54(a6)
		move.w	#[6*64]+1,$58(a6)
		nop
		nop

		addq.l	#$2,d6
		addq.l	#$2,a2

		ENDM

	movem.l	d0-d7/a0-a6,-(a7)

	bsr.l	Init

	move.l	$80,OldTrap
	move.l	#NewTrap,$80
	
WaitTrap:
	cmp.b	#$80,$dff006
	bne	WaitTrap

	move.l	#Copper,$dff084
	clr.w	$dff08a

	trap	#0

	move.l	OldTrap,$80

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts	

NewTrap:
	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#$2700,sr
	movem.l	CLR,d0-d7/a0-a6

	move.w	#$8400,$dff096
wait:
	cmp.b	#$ff,$dff006
	bne	wait

	move.w	#$600,$dff180
	bsr.s	SinusScroll
	move.w	#$000,$dff180

	btst	#6,$bfe001
	beq	Exit
	btst	#2,$dff016
	bne	wait

Exit:
	move.w	#$0400,$dff096
	movem.l	(a7)+,d0-d7/a0-a6
	rte

SinusScroll:
	move.l	#Plane1,d0
	move.l	#Plane2,Screen
	move.l	#Plane2+[118*40],Bottom

	eor.w	#1,Flag
	beq.s	DoubleBuffer

	move.l	#Plane2,d0
	move.l	#Plane1,Screen
	move.l	#Plane2,Bottom
DoubleBuffer:
	move.w	d0,lo	
	swap	d0
	move.w	d0,hi

	move.l	a7,OldStack
	movem.l	CLR,d0-d7/a0-a6
	move.l	Bottom,a7
	move.l	Screen,$dff054
	move.l	#-1,$dff044
	clr.w	$dff066
	move.l	#$01000000,$dff040
	move.w	#[60*64]+20,$dff058
	blk.l	39,$48e7fffe
	move.l	OldStack,a7

	move.w	#$060,$dff180

	lea	$dff000,a6

	sub.w	#1,ScrollDelay
	bne.s	ScrollMemory
	move.w	#4,ScrollDelay

	move.l	#$00260028,$64(a6)
	move.w	#$09f0,$40(a6)

	move.l	textadd,a0
	lea	Fontaddresses,a1
Search:
	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	bne.s	SetupThisLetter

	move.l	#Text,a0
	bra.s	Search

SetupThisLetter:
	move.l	a0,textadd
	lsl.w	#2,d0
	move.l	(a1,d0),$50(a6)
	move.l	#Memory+40,$54(a6)
	move.w	#[6*64]+1,$58(a6)
	nop
	nop
	
ScrollMemory:
	move.w	#$e9f0,$40(a6)	
	clr.l	$64(a6)
	move.l	#Memory,$50(a6)
	move.l	#Memory-2,$54(a6)
	move.w	#[7*64]+21,$58(a6)
	nop
	nop

	move.w	#$06,$dff180

	move.w	#$26,$62(a6)
	move.l	#$00280026,$64(a6)
	move.w	#$0dfc,$40(a6)

	moveq	#0,d0
	moveq	#0,d1

	lea	sinus,a0
	move.b	Yadd1,d0
	move.b	Yadd2,d1

	move.l	Screen,a1
	lea	memory,a2

	moveq	#0,d6

	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord
	OneWord

	add.b	#$ff,yadd1
	add.b	#$ff,yadd2

Finished:
	rts

Yspd1:		dc.b	1
Yspd2:		dc.b	$ff

Init:
	move.l	#plane1,d0
	move.w	d0,lo
	swap	d0
	move.w	d0,hi

	rts

copper:
	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0100,$0000
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$06

	dc.w	$00e0
hi:	dc.w	$0000
	dc.w	$00e2
lo:	dc.w	$0000
	dc.w	$2c01,$ff00,$0100,$1200
	dc.w	$a201,$ff00,$0100,$0000

	dc.w	$ffdf,$fffe
	dc.w	$ffff,$fffe

OldStack:	dc.l	0
OldTrap:	dc.l	0
Clr:		blk.l	15,0

textadd:	dc.l	text

text:	
	DC.B	"PUSHEAD OF SHADOW SYSTEMS ... "
	DC.B	0
 even

FontAddresses:
	blk.l	32,Font+0
	dc.l	Font+0,Font+2,Font+4,Font+6,Font+8
	dc.l	Font+10,Font+12,Font+14,Font+16,Font+18
	dc.l	Font+20,Font+22,Font+24,Font+26,Font+28
	dc.l	Font+30,Font+32,Font+34,Font+36,Font+38
	dc.l	Font+240,Font+242,Font+244,Font+246,Font+248
	dc.l	Font+250,Font+252,Font+254,Font+256,Font+258
	dc.l	Font+260,Font+262,Font+264,Font+266,Font+268
	dc.l	Font+270,Font+272,Font+274,Font+276,Font+278
	dc.l	Font+480,Font+482,Font+484,Font+486,Font+488
	dc.l	Font+490,Font+492,Font+494,Font+496,Font+498
	dc.l	Font+500,Font+502,Font+504,Font+506,Font+508
	dc.l	Font+510,Font+512,Font+514,Font+516,Font+518
	dc.l	Font+720,Font+722,Font+724,Font+726,Font+728
	dc.l	Font+266,Font+268
	dc.l	Font+270,Font+272,Font+274,Font+276,Font+278
	dc.l	Font+480,Font+482,Font+484,Font+486,Font+488
	dc.l	Font+490,Font+492,Font+494,Font+496,Font+498
	dc.l	Font+500,Font+502,Font+504,Font+506,Font+508
	dc.l	Font+510,Font+512,Font+514,Font+516
	dc.l	Font+730,Font+732,Font+734,Font+736
	blk.l	40,Font+0

Font:		incbin	"Font.bmap"

Flag:		dc.w	0
Screen:		dc.l	Plane1
Bottom:		dc.l	Plane2
Plane1:		blk.b	[118*40],240
Plane2:		blk.b	[118*40],15

ScrollDelay:	dc.w	4
		dc.w	0
Memory:		blk.b	[7*42],0

Yadd1:		dc.b	0
Yadd2:		dc.b	0

Sinus:		incbin	"sinus128"
e:
