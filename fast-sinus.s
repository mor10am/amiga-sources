	jmp	s
	org	$30000
	load	$30000
s:

OneWord:	MACRO

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$8000,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$4000,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$2000,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$1000,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$800,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$400,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$200,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$100,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$80,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$40,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$20,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$10,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$8,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$4,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$2,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		move.w	(a0,d0.w),d2
		move.w	(a0,d1.w),d3
		add.w	d3,d2
		and.w	#$fffe,d2
		add.w	d6,d0
		add.w	d7,d1
		and.w	d5,d0
		and.w	d5,d1
		move.w	#$1,$44(a6)
		move.w	(a3,d2.w),d3
		add.w	a1,d3
		move.w	d3,$4e(a6)
		move.w	d3,$56(a6)
		move.w	a2,$52(a6)
		move.w	d4,$58(a6)

		addq.w	#$2,a1
		addq.w	#$2,a2
	
		ENDM

	movem.l	d0-d7/a0-a6,-(a7)

	lea	SysBlock(pc),a0

	move.l	4.w,a6
	move.l	156(a6),a1
	move.l	38(a1),12(a0)

	move.l	$80,(a0)
	move.l	$6c,4(a0)
	move.l	#NewTrap,$80

	trap	#0

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#$00,d0
	rts

NewTrap:
	bsr	Init
	lea	SysBlock(pc),a0

	lea	$dff000,a6

	move.w	#$2700,sr
	move.w	$1c(a6),8(a0)
	move.w	$02(a6),10(a0)
	or.w	#$8000,8(a0)
	or.w	#$8000,10(a0)
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)

	move.l	#Copper,$80(a6)
	clr.w	$88(a6)
	move.l	#Interrupt,$6c

	move.w	#$c020,$9a(a6)
	move.w	#$87c0,$96(a6)

	clr.l	$144(a6)

	move.w	#$2000,sr
Wait:
	btst	#6,$bfe001
	bne	Wait

	move.w	#$2700,sr

	lea	$dff000,a6

	move.w	#$3fff,$9c(a6)

	move.l	4(a0),$6c
	move.l	(a0),$80
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	8(a0),$9a(a6)
	move.w	10(a0),$96(a6)

	move.l	12(a0),$80(a6)

	rte


SysBlock:	blk.b	16,0

Interrupt:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr	SinScroll
	move.w	#$000,$dff180
IntExit:
	move.w	#$0020,$dff09c
	movem.l	(a7)+,d0-d7/a0-a6
	rte

SinScroll:
	lea	$dff000,a6

	move.l	#View1,d0
	move.l	#View2,Screen
	move.l	#View2+[144*40],Bottom
	move.l	#View2,$54(a6)

	not.w	ScrFlag
	bne	Scr2

	move.l	#View2,d0
	move.l	#View1,Screen
	move.l	#View1+[144*40],Bottom
	move.l	#View1,$54(a6)

Scr2:
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1

	move.l	#$01000000,$40(a6)
	clr.w	$66(a6)
	move.w	#[72*64]+20,$58(a6)

	move.l	a7,OldStack
	movem.l	CLR,d0-d7/a0-a6
	move.l	Bottom,a7
	blk.l	48,$48e7fffe
	move.l	OldStack,a7
	
	lea	$dff000,a6
	move.l	#$ffffffff,$44(a6)

	sub.w	#1,counter
	bne.s	ScrollMemory
	move.w	#4,counter

	move.l	#$00260028,$64(a6)
	move.l	#$09f00000,$40(a6)	

	move.l	textadd,a0
	lea	fontaddresses,a1
search:
	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	bne.s	SetLetter
	move.l	#text,a0
	bra.s	search

SetLetter:
	lsl.w	#2,d0
	move.l	(a1,d0),$50(a6)
	move.l	#ScrMem+40,$54(a6)
	move.w	#[6*64]+1,$58(a6)
	nop
	nop

ScrollMemory:
	clr.l	$64(a6)
	move.l	#$e9f00000,$40(a6)
	move.l	#ScrMem,$50(a6)
	move.l	#ScrMem-2,$54(a6)
	move.w	#[6*64]+21,$58(a6)
	nop
	nop

	lea	Sinus,a0

	move.w	YAdd1,d0
	move.w	YAdd2,d1

	move.l	Screen,a1
	lea	ScrMem,a2
	lea	MulTab,a3

	move.w	#[6*64]+1,d4
	move.w	#$7ff,d5
	move.w	#$008,d6
	move.w	#$006,d7

	move.l	#-1,$44(a6)

	move.l	#$0dfc0000,$40(a6)
	move.l	#$00280026,$64(a6)
	move.w	#$0026,$62(a6)

	move.l	#s,$4c(a6)
	move.l	#s,$50(a6)
	move.l	#s,$54(a6)

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

	add.w	#$008,YAdd1
	and.w	d5,Yadd1
	add.w	#$7f6,YAdd2
	and.w	d5,Yadd2

	rts

Init:
	move.l	#View1,d0
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1

	rts

Copper:
	dc.w	$0c01,$ff00
	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000,$0108,$0000,$010a,$0000
	dc.w	$0180,$0600,$0182,$0fff
	dc.w	$00e0
hi1:	dc.w	$0000
	dc.w	$00e2
lo1:	dc.w	$0000

	dc.w	$2c01,$ff00,$0100,$1200

	dc.w	$bc01,$ff00,$0100,$0000

	dc.w	$ffdf,$fffe
	dc.w	$ffff,$fffe

OldStack:	dc.l	0
CLR:		blk.l	16,0
counter:	dc.w	4

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


Sinus:		incbin	"1024-128Sinus"

YAdd1:		dc.w	0
YAdd2:		dc.w	0
		dc.w	0
ScrMem:		blk.b	[6*42],0

View1:		blk.b	10240,$f0
View2:		blk.b	10240,$0f
Bottom:		dc.l	View1+[144*40]
Screen:		dc.l	View1
ScrFlag:	dc.w	0

MulTab:		incbin	"multab.tab"
