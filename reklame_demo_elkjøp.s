	org	$3a000
	load	$3a000
s:

e_OneWord:	MACRO
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$8000,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$4000,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$2000,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$1000,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$800,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$400,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$200,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$100,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$80,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$40,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$20,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$10,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$8,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$4,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$2,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d3
	add.l	a3,d3
	move.l	d3,$4c(a6)
	move.l	a2,$50(a6)
	move.l	d3,$54(a6)
	move.w	#$1,$44(a6)
	move.w	#[13*64]+1,$58(a6)
	add.b	d4,d0
	add.b	d5,d1

	addq.l	#$2,a2
	addq.l	#$2,a3

	ENDM

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
	move.w	#$8000+$400+$200+$100+$80+$40+$20,$96(a6)
	move.w	#$c000+$10,$9a(a6)

	clr.l	$148(a6)
	clr.l	$150(a6)
	clr.l	$158(a6)
	clr.l	$160(a6)
	clr.l	$168(a6)
	clr.l	$170(a6)
	clr.l	$178(a6)

	move.l	$6c.w,OldLEV3Vector
	move.l	#NewLEV3Vector,$6c.w

	move.l	#Copper,$80(a6)
	clr.w	$88(a6)

	clr.l	$144(a6)

	move.w	#$2000,sr

Mouse:
	cmp.b	#$64,$dff006
	bne.s	Mouse

	tst.w	ja
	bne.s	jesus

	bsr.l	MouseDriver

	btst	#6,$bfe001
	bne.s	Mouse
jesus:
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

ja:		dc.w	0

OldDMA:		dc.w	0
OldINT:		dc.w	0
OldLEV3Vector:	dc.l	0
OldTrap:	dc.l	0

NewLEV3Vector:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr.l	MasterDriver
	bsr.L	RotateLogo
	bsr.L	c_Scroller
;	move.w	#$000,$dff180

	movem.l	(a7)+,d0-d7/a0-a6

NoRequest:
	move.w	#$0010,$9c(a6)
	rte

MasterDriver:
	move.l	MasterPoint,a0
	move.l	(a0),a0
MasterLoop:
	move.l	(a0)+,a1
	cmpa.l	#$0,a1
	beq.s	ContinueReklame

	movem.l	a0/a1,-(a7)
	jsr	(a1)
	movem.l	(a7)+,a0/a1

	bra.s	MasterLoop

ContinueReklame:
	rts

MouseDriver:
	move.l	MousePoint,a0
	move.l	(a0),a0
MouseLoop:
	move.l	(a0)+,a1
	cmpa.l	#$0,a1
	beq.s	ContinueMouse

	movem.l	a0/a1,-(a7)
	jsr	(a1)
	movem.l	(a7)+,a0/a1

	bra.s	MouseLoop

ContinueMouse:
	rts

g_Rasters:
	tst.w	g_fg
	beq.l	g_NewRoutine
	cmp.w	#1,g_fg
	beq.L	g_AddUp
	cmp.w	#2,g_fg
	beq.L	g_Waite
	cmp.w	#3,g_fg
	beq.L	g_AddDown
g_Begin:
	lea	$dff000,a6
	move.l	#-1,$44(a6)
	move.w	#$0006,$66(a6)
	move.l	#$01000000,$40(a6)
	move.l	#SprBlk+6,$54(a6)
	move.w	#[121*64]+1,$58(a6)

g_w1:	btst	#14,$02(a6)
	bne.s	g_w1

	tst.w	g_fg
	beq.L	g_Jepp

	move.w	#$09f0,$40(a6)
	move.w	#$0000,$64(a6)

	moveq	#0,d0
	moveq	#0,d1

	lea	e_sinus,a0
	move.b	g_yadd1,d0
	move.b	g_yadd2,d1

	lea	g_addertab,a1
	lea	sprblk+6,a2
	lea	g_ColTab,a3
	move.w	g_antall,d7
g_LoopIt:
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2
	move.w	(a1,d2.w),d2
	add.l	a2,d2
	
	move.l	(a3)+,$50(a6)
	move.l	d2,$54(a6)
	move.w	#[7*64]+1,$58(a6)

	add.b	#$04,d0
	add.b	#$06,d1

	cmp.l	#g_ColEnd,a3
	blt.s	g_Ok_NextCol
	move.l	#g_ColTab,a3

g_Ok_NextCol:
	dbf	d7,g_LoopIt

	add.b	#$02,g_yadd1
	add.b	#$03,g_yadd2

g_Jepp:
	rts

g_AddUp:
	subq.w	#1,g_delay
	bne.l	g_begin
	move.w	#10,g_delay
	add.w	#1,g_antall
	cmp.w	#32,g_antall
	blt.l	g_begin
	move.w	#2,g_fg
	bra.l	g_begin

g_Waite:
	subq.w	#1,g_bigdel
	bne.l	g_begin
	move.w	#3,g_fg
	bra.l	g_begin

g_AddDown:
	subq.w	#1,g_delay
	bne.l	g_begin
	move.w	#10,g_delay
	subq.w	#1,g_antall
	bge.l	g_begin

	move.w	#0,g_fg
	bra.l	g_begin

g_NewRoutine:
	move.w	#1,g_fg
	move.w	#1,g_antall
	move.w	#700,g_bigdel
	move.l	#MasterTable+60,MasterPoint
	rts

g_InitProgram:
	clr.w	mod1
	clr.w	mod2
	clr.w	planes

	lea	sprblk,a0
	move.l	#$8621fffe,d0
	move.w	#120,d7
g_InLoop:
	move.l	d0,(a0)+
	move.l	#$01800000,(a0)+
	add.l	#$01000000,d0
	dbf	d7,g_InLoop

	move.l	d0,(a0)+
	move.l	#$01800000,(a0)+

	move.w	#5,d7
g_CLoop:
	move.l	#$01fe01fe,(a0)+
	move.l	#$01fe01fe,(a0)+
	dbf	d7,g_Cloop

	lea	g_addertab,a0
	moveq	#0,d0
	move.w	#127,d7
g_Addloop:
	move.w	d0,(a0)+
	add.w	#8,d0
	dbf	d7,g_AddLoop

	move.l	#MasterTable+52,MasterPoint	

	rts

h_Double_Buffer4:
	move.l	#PlayField1,d0
	move.l	#PlayField2,Screen
	move.l	#h_Olds2,h_OldBobs

	eor.w	#1,flag
	beq.s	h_DB4

	move.l	#PlayField2,d0
	move.l	#PlayField1,Screen
	move.l	#h_Olds1,h_OldBobs
h_DB4:
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1
	rts

h_TheEnd:
	bsr.s	h_Double_Buffer4

	tst.w	h_fl
	beq.L	h_ResetSystem

	cmp.w	#1,h_fl
	beq.L	h_MaskIn
	cmp.w	#2,h_fl
	beq.L	h_PlayIt
	cmp.w	#3,h_fl
	beq.L	h_MaskOut
h_Ok_do:
	lea	$dff000,a6
	clr.w	$46(a6)
	move.l	#$00240024,$62(a6)
	move.w	#$0024,$66(a6)
	move.l	#$01000000,$40(a6)

	move.l	h_oldbobs,a0
	move.w	#5,d7
h_clrem:
	move.l	(a0)+,$54(a6)
	move.w	#[13*64]+2,$58(a6)

h_w1:	btst	#14,$02(a6)
	bne.s	h_w1

	dbf	d7,h_clrem

	moveq	#0,d0
	moveq	#0,d1

	lea	e_sinus,a0
	move.b	h_yadd1,d0
	move.b	h_yadd2,d1

	lea	h_adds,a1
	lea	h_xpositions,a2
	lea	h_letterads,a3
	move.l	h_oldbobs,a4
	move.l	screen,a5
	move.w	#5,d7
h_setem:
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0,d0.w),d2
	move.b	(a0,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2
	lsl.w	#1,d2

	move.w	(a1,d2.w),d2
	add.l	a5,d2

	move.w	(a2)+,d3
	ror.l	#4,d3
	lsl.w	#1,d3
	add.w	d3,d2
	swap	d3
	or.w	#$dfc,d3
	move.w	d3,$40(a6)

	move.l	d2,(a4)+

	move.l	d2,$4c(a6)
	move.l	d2,$54(a6)
	move.l	(a3)+,$50(a6)

	move.w	#[13*64]+2,$58(a6)

	add.b	#$fc,d0
	add.b	#$07,d1

	dbf	d7,h_setem

	add.b	#$03,h_yadd1
	add.b	#$ff,h_yadd2

	rts

h_ResetSystem:
	move.w	#1,h_fl
	add.w	#1,i_drives
	cmp.w	#2,i_drives
	beq.s	i_reset
	move.l	#MasterTable+68,MasterPoint
	rts

i_reset:
	move.w	#1,ja	
	rts

h_maskin:
	move.l	h_maskpoint1,a0
	move.w	(a0)+,$44(a6)
	move.l	a0,h_maskpoint1
	cmp.l	#h_maskend1,h_maskpoint1
	bne.l	h_Ok_Do
	move.w	#2,h_fl
	move.l	#h_mask1,h_maskpoint1
	bra.l	h_ok_do

h_playit:
	subq.w	#1,h_maskdel
	bne.l	h_ok_do
	move.w	#3,h_fl
	move.w	#700,h_maskdel
	bra.l	h_ok_do

h_maskout:
	move.l	h_maskpoint2,a0
	move.w	(a0)+,$44(a6)
	move.l	a0,h_maskpoint2
	cmp.l	#h_maskend2,h_maskpoint2
	bne.l	h_Ok_Do
	move.w	#0,h_fl
	move.w	#h_mask2,h_maskpoint2
	bra.l	h_ok_do

h_InitProgram:
	move.w	#97,ypos

	clr.w	mod1
	clr.w	mod2
	move.w	#$1200,planes

	lea	sprblk,a0
	lea	h_colors,a1
	move.l	#$8021fffe,d0
	move.w	#127,d7
h_cfade:
	move.l	d0,(a0)+
	move.w	#$0182,(a0)+
	move.w	(a1)+,(a0)+
	add.l	#$01000000,d0
	dbf	d7,h_cfade

	lea	h_adds,a0
	moveq	#0,d0
	move.w	#127,d7
h_addloop:
	move.w	d0,(a0)+
	add.w	#40,d0
	dbf	d7,h_addloop

	move.l	#PlayField1,d0
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1

	move.l	#MasterTable+64,MasterPoint

	rts

e_SinusScroll:
	move.l	Screen,$dff054
	move.l	#$01000000,$dff040
	clr.w	$dff066
	move.w	#[65*64]+20,$dff058

	move.l	a7,OldStack
	move.l	Bottom,a7
	movem.l	CLR,d0-d7/a0-a6
	blk.l	42,$48e7fffe
	move.l	OldStack,a7

	lea	$dff000,a6
	move.l	#-1,$44(a6)

	subq.w	#1,e_Scr
	bne.s	e_ScrollIt
	move.w	#8,e_Scr

	move.l	e_textadd,a0
	lea	a_fontblk,a1
e_Search:
	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	bne.s	e_Setup

	move.l	#e_text,e_textadd
	move.l	#MasterTable+36,MasterPoint
	bra.l	e_Done

e_Setup:
	move.l	a0,e_textadd

	lsl.w	#2,d0
	move.l	(a1,d0.w),$50(a6)
	move.l	#e_memory+40,$54(a6)
	move.w	#$09f0,$40(a6)
	move.l	#$00260028,$64(a6)
	move.w	#[13*64]+1,$58(a6)
	nop
	nop

e_ScrollIt:
	move.l	#e_memory,$50(a6)
	move.l	#e_memory-2,$54(a6)
	move.w	#$e9f0,$40(a6)
	clr.l	$64(a6)
	move.w	#[14*64]+21,$58(a6)
	nop
	nop
	
	moveq	#0,d0
	moveq	#0,d1

	move.w	#$0dfc,$40(a6)
	move.w	#$0026,$62(a6)
	move.l	#$00280026,$64(a6)
	move.w	#-1,$46(a6)

	lea	e_sinus,a0
	lea	e_yadds,a1
	lea	e_memory,a2
	move.l	Screen,a3

	move.b	e_yadd1,d0
	move.b	e_yadd2,d1

	moveq	#$01,d4
	moveq	#$01,d5

	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord
	e_OneWord

	add.b	#$ff,e_yadd1
	add.b	#$fe,e_yadd2

e_Done:
	rts

PrepareSinScrProgram:
	clr.w	mod1
	clr.w	mod2
	move.w	#$1200,planes

	lea	cols,a0
	move.w	#$0c64,6(a0)

	move.l	#PlayField1,d0
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1

	lea	e_Yadds,a0
	moveq	#0,d0
	move.w	#114,d7
e_Yloop:
	move.w	d0,(a0)+
	add.l	#40,d0
	dbf	d7,e_Yloop

	move.l	#MasterTable+32,MasterPoint
	rts

f_Double_Buffer3:
	move.l	#PlayField1,d0
	move.l	#f_Olds2,f_OldBobs

	move.l	#PlayField2+[128*40*0],a0
	move.l	#PlayField2+[128*40*1],a1
	move.l	#PlayField2+[128*40*2],a2

	eor.w	#1,Flag
	beq.s	f_DB3

	move.l	#PlayField2,d0
	move.l	#f_Olds1,f_OldBobs

	move.l	#PlayField1+[128*40*0],a0
	move.l	#PlayField1+[128*40*1],a1
	move.l	#PlayField1+[128*40*2],a2
f_DB3:
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1
	swap	d0
	add.l	#[128*40],d0
	move.w	d0,lo2
	swap	d0
	move.w	d0,hi2
	swap	d0
	add.l	#[128*40],d0
	move.w	d0,lo3
	swap	d0
	move.w	d0,hi3
	rts

f_RGBbobs:
	cmp.w	#1,f_flg
	beq.L	f_FadeIn
	cmp.w	#2,f_flg
	beq.L	f_Warten
	cmp.w	#3,f_flg
	beq.L	f_FadeOut
f_Begin:
	bsr.L	f_Double_Buffer3

	lea	$dff000,a6
	move.l	#-1,$44(a6)
	move.l	#$00240000,$60(a6)
	move.l	#$00000024,$64(a6)
	move.l	#$01000000,$40(a6)

	move.l	f_OldBobs,a3
	move.w	f_Antall,d7
f_Cloop:
	move.l	(a3)+,$54(a6)
	move.w	#[13*64]+2,$58(a6)

f_w1:	btst	#14,$02(a6)
	bne.s	f_w1

	dbf	d7,f_Cloop

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	lea	e_sinus,a3
	move.b	f_xadd1,d0
	move.b	f_xadd2,d1
	move.b	f_yadd1,d2
	move.b	f_yadd2,d3

	move.l	f_OldBobs,a4
	lea	e_Yadds,a5

	move.w	f_Antall,d7
f_Sloop:
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.b	(a3,d0.w),d4
	move.b	(a3,d1.w),d5
	add.w	d5,d4
	lsr.w	#1,d4	

	move.b	(a3,d2.w),d5
	move.b	(a3,d3.w),d6
	add.w	d6,d5
	lsr.w	#1,d5
	lsl.w	#1,d5

	move.w	(a5,d5.w),d5
	add.l	a0,d5
	add.l	#12,d5

	ror.l	#4,d4
	lsl.w	#1,d4
	add.w	d4,d5
	swap	d4
	move.w	d4,$42(a6)
	or.w	#$fca,d4
	move.w	d4,$40(a6)

	move.l	d5,$48(a6)
	move.l	d5,$54(a6)

	move.l	f_Bob,$4c(a6)
	move.l	f_Mask,$50(a6)

	move.w	#[13*64]+2,$58(a6)
	move.l	d5,(a4)+

	exg	a0,a2
	exg	a2,a1

	add.b	#$09,d0
	add.b	#$05,d1
	add.b	#$03,d2
	add.b	#$f8,d3

	dbf	d7,f_Sloop

	add.b	#$fe,f_xadd1
	add.b	#$03,f_xadd2
	add.b	#$ff,f_yadd1
	add.b	#$02,f_yadd2

	rts

f_FadeIn:
	subq.w	#1,f_rgbdel
	bne.L	f_Begin
	move.w	#3,f_rgbdel

	movem.l	CLR,d0-d6

	lea	cols+2,a0
	lea	f_rgbfade,a1
	move.w	#7,d7
f_LoopIn:
	move.w	(a1),d0
	cmp.w	(a0),d0
	beq.s	f_Ok_Next

	move.w	#$1,d6

	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2

	move.w	(a1),d3
	move.w	d3,d4
	move.w	d3,d5

	and.w	#$000f,d0
	and.w	#$000f,d3
	and.w	#$00f0,d1
	and.w	#$00f0,d4
	and.w	#$0f00,d2
	and.w	#$0f00,d5

f_DoB:
	cmp.w	d0,d3
	beq.s	f_DoG
	add.w	#$0001,d0
f_DoG:
	cmp.w	d1,d4
	beq.s	f_DoR
	add.w	#$0010,d1
f_DoR:
	cmp.w	d2,d5
	beq.s	f_DoOR
	add.w	#$0100,d2
f_DoOR:
	or.w	d1,d0
	or.w	d2,d0

	move.w	d0,(a0)
f_Ok_Next:
	add.l	#$4,a0
	add.l	#$2,a1
	dbf	d7,f_LoopIn

	tst.w	d6
	bne.l	f_Begin

	move.w	#$2,f_flg
	bra.l	f_Begin

f_Warten:
	subq.w	#1,f_Wrt
	bne.l	f_Begin
	move.w	#$3,f_flg
	move.w	#700,f_Wrt
	bra.l	f_begin

f_FadeOut:
	subq.w	#1,f_rgbdel
	bne.l	f_Begin
	move.w	#3,f_rgbdel

	movem.l	CLR,d0-d3
	moveq	#0,d6

	lea	cols+2,a0
	move.w	#7,d7
f_LoopOut:
	tst.w	(a0)
	beq.s	f_Ok_Next2

	move.w	#$1,d6

	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2

	and.w	#$000f,d0
	and.w	#$00f0,d1
	and.w	#$0f00,d2

f_Ok_R:
	tst.w	d0
	beq.s	f_Ok_G
	subq.w	#1,d0
f_Ok_G:
	tst.w	d1
	beq.s	f_Ok_B
	sub.w	#$10,d1
f_Ok_B:
	tst.w	d2
	beq.s	f_Ok_OR
	sub.w	#$100,d2
f_Ok_OR:
	or.w	d1,d0
	or.w	d2,d0

	move.w	d0,(a0)
f_Ok_Next2:
	add.l	#$4,a0
	dbf	d7,f_LoopOut

	tst.w	d6
	bne.l	f_Begin


	lea	$dff000,a6
	move.w	#$0024,$66(a6)
	move.l	#$01000000,$40(a6)

	move.l	#f_Olds1,a3
	move.w	f_Antall,d7
f_Cloop2:
	move.l	(a3)+,$54(a6)
	move.w	#[13*64]+2,$58(a6)

f_w12:	btst	#14,$02(a6)
	bne.s	f_w12

	dbf	d7,f_Cloop2

	move.l	#f_Olds2,a3
	move.w	f_Antall,d7
f_Cloop3:
	move.l	(a3)+,$54(a6)
	move.w	#[13*64]+2,$58(a6)

f_w13:	btst	#14,$02(a6)
	bne.s	f_w13

	dbf	d7,f_Cloop3

	move.l	#MasterTable+44,MasterPoint
	move.w	#1,f_flg

	rts

FadeOutSprites:
	subq.w	#1,sprdel
	bne.l	ikkefade
	move.w	#3,sprdel

	movem.l	CLR,d0-d7

	lea	cols+$46,a0
	move.w	#2,d7
sploop:
	tst.w	(a0)
	beq.s	donextsp

	move.w	#$1,d6

	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2

	and.w	#$00f,d0
	and.w	#$0f0,d1
	and.w	#$f00,d2

spB:	tst.w	d0
	beq.s	spG
	sub.w	#$001,d0
spG:	tst.w	d1
	beq.s	spR
	sub.w	#$010,d1
spR:	tst.w	d2
	beq.s	spOR
	sub.w	#$100,d2
spOR:
	or.w	d1,d0
	or.w	d2,d0

	move.w	d0,(a0)
donextsp:
	addq.l	#$4,a0
	dbf	d7,sploop

	tst.w	d6
	bne.s	ikkefade

	move.l	#MasterTable+48,MasterPoint
ikkefade:
	rts

f_InitProgram:
	clr.w	mod1
	clr.w	mod2
	move.w	#$3200,planes

	lea	cols,a0
	clr.w	6(a0)
	clr.w	10(a0)
	clr.w	14(a0)
	clr.w	18(a0)
	clr.w	22(a0)
	clr.w	26(a0)
	clr.w	30(a0)

	move.l	#PlayField1+[128*40*0],d0
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1

	move.l	#PlayField1+[128*40*1],d0
	move.w	d0,lo2
	swap	d0
	move.w	d0,hi2

	move.l	#PlayField1+[128*40*2],d0
	move.w	d0,lo3
	swap	d0
	move.w	d0,hi3

	move.l	#MasterTable+40,MasterPoint
	rts


prepareBalls:
	lea	cols,a0
	move.w	#$000,6(a0)

	move.w	#117,ypos
	move.w	#350,Zoom

	clr.w	Xangle
	clr.w	Yangle
	clr.w	Zangle

	move.l	#PlayField1,d0
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1
	swap	d0
	add.l	#40,d0
	move.w	d0,lo2
	swap	d0
	move.w	d0,hi2
	swap	d0
	add.l	#40,d0
	move.w	d0,lo3
	swap	d0
	move.w	d0,hi3

	move.l	#$01000000,$dff040
	clr.w	$dff066

	move.l	#PlayField1+[128*40],$dff054
	move.w	#[130*64]+20,$dff058

	move.l	a7,OldStack
	movem.l	CLR,d0-d7/a0-a6
	move.l	#PlayField1+[128*40*3],a7
	blk.l	86,$48e7fffe

	move.l	#PlayField2+[128*40],$dff054
	move.w	#[130*64]+20,$dff058

	move.l	#PlayField2+[128*40*3],a7
	blk.l	86,$48e7fffe

	move.l	OldStack,a7

	bsr.l	InitBallProgram

	move.w	#$50,mod1
	move.w	#$50,mod2
	move.w	#$3200,planes

	lea	cols,a0
	move.w	#$aef,6(a0)
	move.w	#$7cd,10(a0)
	move.w	#$5ac,14(a0)
	move.w	#$37a,18(a0)
	move.w	#$259,22(a0)
	move.w	#$147,26(a0)
	move.w	#$026,30(a0)

	move.l	#MasterTable+16,MasterPoint
	rts

AddBallPointers:
	add.w	#$012,Xangle
	add.w	#$000,Yangle
	add.w	#$006,Zangle
	and.w	#$7fe,Xangle
	and.w	#$7fe,Yangle
	and.w	#$7fe,Zangle
	rts

FadeOutBalls:
	lea	Cols+2,a0
	movem.l	CLR,d0-d7

	move.w	#7,d7
BallsOut:
	tst.w	(a0)
	beq.s	NextBO

	move.w	#$1,d6

	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2

	and.w	#$f00,d0
	and.w	#$0f0,d1
	and.w	#$00f,d2

BRo:
	tst.w	d0
	beq.s	BGo
	sub.w	#$100,d0
BGo:
	tst.w	d1
	beq.s	BBo
	sub.w	#$010,d1
BBo:
	tst.w	d2
	beq.s	Bor
	sub.w	#$001,d2
Bor:
	or.w	d1,d0
	or.w	d2,d0

	move.w	d0,(a0)

NextBO:
	addq.l	#$4,a0
	dbf	d7,BallsOut

	tst.w	d6
	bne.s	IkkeNoeNytt

	move.w	#800,BallsWait
	move.l	#MasterTable+20,MasterPoint

IkkeNoeNytt:
	rts

PrepareVertical:
	lea	$dff000,a6
	move.w	#$0024,$66(a6)
	move.l	#$01000000,$40(a6)

	lea	b_Olds1,a0
	lea	b_Olds2,a1

	move.w	b_NoBobs,d7
b_ClrLoop2:
	move.l	(a0)+,$54(a6)
	move.w	#[15*3*64]+2,$58(a6)

b_w12:	btst	#14,$02(a6)
	bne.s	b_w12

	move.l	(a1)+,$54(a6)
	move.w	#[15*3*64]+2,$58(a6)

b_w13:	btst	#14,$02(a6)
	bne.s	b_w13

	dbf	d7,b_ClrLoop2

	move.w	#-$0028,mod1
	move.w	#-$0028,mod2
	move.w	#$4200,planes

	move.l	#PlayField1,d0
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1
	swap	d0
	add.l	#40,d0
	move.w	d0,lo2
	swap	d0
	move.w	d0,hi2
	swap	d0
	add.l	#40,d0
	move.w	d0,lo3
	swap	d0
	move.w	d0,hi3
	swap	d0
	add.l	#40,d0
	move.w	d0,lo4
	swap	d0
	move.w	d0,hi4

	move.l	#MasterTable+24,MasterPoint
	move.l	#MouseTable+4,MousePoint
	rts

d_Vertical:
	cmp.w	#$1,d_ToDo
	beq.L	d_FadeIn
	cmp.w	#$2,d_ToDo
	beq.L	d_WaitVert
	cmp.w	#$3,d_ToDo
	beq.L	d_FadeOut
d_DoRasters:
	lea	$dff000,a6

d_BeamDown:
	cmp.b	#$7d,$06(a6)
	bne.s	d_BeamDown

	lea	PlayField1,a2

	move.l	#-1,$44(a6)
	move.l	#$01000000,$40(a6)
	move.l	#$00240000,$60(a6)
	move.l	#$00000000,$64(a6)
	move.l	a2,$54(a6)
	move.w	#[1*4*64]+20,$58(a6)

d_w2:	btst	#14,$02(a6)
	bne.s	d_w2

	move.w	#$0024,$66(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.b	d_xadd1,d0
	move.b	d_xadd2,d1

	lea	d_Sinus,a1
	lea	d_Img,a3	
	lea	d_Mask,a4

	move.w	#62,d7
d_VertLoop:
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a1,d0.w),d2
	move.b	(a1,d1.w),d3
	add.w	d3,d2
	lsr.w	#1,d2

	ror.l	#4,d2
	lsl.w	#1,d2
	move.w	d2,d3
	add.l	a2,d3
	addq.w	#4,d3

	swap	d2
	move.w	d2,$42(a6)
	or.w	#$fca,d2
	move.w	d2,$40(a6)

	move.l	d3,$48(a6)
	move.l	d3,$54(a6)
	
	move.l	a3,$4c(a6)
	move.l	a4,$50(a6)

	moveq	#0,d2
	move.b	$06(a6),d2
	add.b	#$2,d2
d_Beam:
	cmp.b	$06(a6),d2
	bne.s	d_Beam

	move.w	#[1*4*64]+2,$58(a6)

	add.b	#$05,d0
	add.b	#$ff,d1

	dbf	d7,d_VertLoop

	add.b	#$ff,d_xadd1
	add.b	#$02,d_xadd2

	rts

d_FadeIn:
	subq.w	#1,d_FadeDelay
	bne.s	d_NotIn
	move.w	#$4,d_FadeDelay

	lea	Cols+2,a0
	lea	d_FadeVert,a1

	movem.l	CLR,d0-d7

	move.w	#15,d7
d_LoopIn:
	move.w	(a0),d0
	move.w	(a1),d3
	cmp.w	d0,d3
	beq.s	d_NextIn

	move.w	#$1,d6

	move.w	d0,d1
	move.w	d1,d2

	move.w	d3,d4
	move.w	d4,d5

	and.w	#$f00,d0
	and.w	#$f00,d3
	and.w	#$0f0,d1
	and.w	#$0f0,d4
	and.w	#$00f,d2
	and.w	#$00f,d5

d_RI:
	cmp.w	d0,d3
	beq.s	d_GI
	add.w	#$100,d0
d_GI:	cmp.w	d1,d4
	beq.s	d_BI
	add.w	#$010,d1
d_BI:	cmp.w	d2,d5
	beq.s	d_ORI
	add.w	#$001,d2
d_ORI:
	or.w	d1,d0
	or.w	d2,d0

	move.w	d0,(a0)
d_NextIn:
	addq.l	#$4,a0
	addq.l	#$2,a1
	dbf	d7,d_LoopIn

	tst.w	d6
	bne.s	d_NotIn

	move.w	#$2,d_ToDo

d_NotIn:
	bra.L	d_DoRasters

d_WaitVert:
	subq.w	#1,d_VertWait
	bne.s	d_NotNextRout
	move.w	#700,d_VertWait
	move.w	#$3,d_ToDo
	move.w	#$2,d_FadeDelay
d_NotNextRout:
	bra.L	d_DoRasters

d_FadeOut:
	subq.w	#1,d_FadeDelay
	bne.l	d_NotOut
	move.w	#2,d_FadeDelay

	lea	Cols+2,a0
	movem.l	CLR,d0-d7

	move.w	#15,d7
d_LoopOut:
	tst.w	(a0)
	beq.s	d_NextOut

	move.w	#$1,d6

	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2

	and.w	#$f00,d0
	and.w	#$0f0,d1
	and.w	#$00f,d2

d_RO:
	tst.w	d0
	beq.s	d_GO
	sub.w	#$100,d0
d_GO:	tst.w	d1
	beq.s	d_BO
	sub.w	#$010,d1
d_BO:	tst.w	d2
	beq.s	d_ORO
	subq.w	#$001,d2
d_ORO:
	or.w	d1,d0
	or.w	d2,d0

	move.w	d0,(a0)

d_NextOut:
	addq.l	#$4,a0
	dbf	d7,d_LoopOut

	tst.w	d6
	bne.s	d_NotOut

	lea	$dff000,a6
	move.l	#-1,$44(a6)
	move.l	#$01000000,$40(a6)
	clr.w	$66(a6)
	move.l	#PlayField1,$54(a6)
	move.w	#[1*4*64]+20,$58(a6)

d_w22:	btst	#14,$02(a6)
	bne.s	d_w22

	move.w	#1,d_ToDo

	move.l	#MasterTable+28,MasterPoint
	move.l	#MouseTable,MousePoint
	rts

d_NotOut:
	bra.L	d_DoRasters

VectorBalls:
	tst.w	BallsWait
	bne.s	SubWait

	bsr.L	FadeOutBalls
	bra.s	DoYpos

SubWait:
	subq.w	#1,BallsWait

DoYPOS:
	subq.w	#1,b_YposDel
	bne.s	b_GetPointers
	move.w	#3,b_YposDel

	tst.w	ypos
	beq.s	b_GetPointers
	subq.w	#1,ypos

b_GetPointers:
	move.w	Xangle,Xuse
	move.w	Yangle,Yuse
	move.w	Zangle,Zuse

	lea	$dff000,a6
	move.l	#-1,$44(a6)
	move.l	#$00240000,$60(a6)
	move.l	#$00000024,$64(a6)
	move.l	#$01000000,$40(a6)

	move.l	b_OldBobs,a0
	move.w	b_NoBobs,d7
b_ClrLoop:
	move.l	(a0)+,$54(a6)
	move.w	#[15*3*64]+2,$58(a6)

b_w1:	btst	#14,$02(a6)
	bne.s	b_w1

	dbf	d7,b_ClrLoop

	movem.l	CLR,d0-d7

	move.w	Xuse,d0
	move.w	Yuse,d1
	move.w	Zuse,d2

	lea	b_HashTable,a0
	lea	Sinus,a2
	lea	Sinus+512,a3
	lea	b_Object,a5

	move.w	b_NoBobs,d7
b_rotLoop:
	move.w	(a5)+,X
	move.w	(a5)+,Y
	move.w	(a5)+,Z

	bsr.L	DoRotasjon

b_HashBalls:
	subq.w	#8,d4

	cmp.w	#128,d4
	blt.s	OK_BallY

	move.w	#128,d4

Ok_BallY:
	sub.w	#1408,d5
	lsr.w	#1,d5
	lsl.w	#5,d5

b_CheckPlace:
	cmp.w	#$8000,(a0,d5.w)
	beq.s	b_FoundPlace

	addq.w	#$4,d5
	bra.s	b_CheckPlace

b_FoundPlace:
	move.w	d3,(a0,d5.w)
	move.w	d4,2(a0,d5.w)

	dbf	d7,b_rotLoop

OrganizeHash:
	lea	b_HashTable,a0
	lea	b_NewObject,a1
	moveq	#0,d0
	moveq	#0,d1

	move.w	b_NoBobs,d7
OrgLoop:
	moveq	#0,d2
	add.w	d0,d2
	add.w	d1,d2
	cmp.w	#$8000,(a0,d2.w)
	beq.s	NextBlock

	move.w	(a0,d2.w),(a1)+
	move.w	#$8000,(a0,d2.w)
	move.w	2(a0,d2.w),(a1)+
	move.w	#$8000,2(a0,d2.w)
	addq.w	#4,d1
	dbf	d7,OrgLoop
	bra.s	b_SetupBalls

NextBlock:
	add.w	#32,d0
	moveq	#0,d1
	bra.s	OrgLoop

b_SetupBalls:
	move.l	Screen,a0
	move.l	b_OldBobs,a1
	lea	b_AdderTab,a4
	lea	b_NewObjectEND,a5

	move.w	b_NoBobs,d7
b_setloop:
	moveq	#0,d3
	moveq	#0,d4

	move.w	-(a5),d4
	move.w	-(a5),d3	

	lsl.w	#1,d4
	move.w	(a4,d4.w),d4

	ror.l	#4,d3
	lsl.w	#1,d3
	add.w	d3,d4
	add.l	a0,d4

	swap	d3
	move.w	d3,$42(a6)
	or.w	#$fca,d3
	move.w	d3,$40(a6)

	move.l	d4,(a1)+

	move.l	d4,$48(a6)
	move.l	d4,$54(a6)

	move.l	b_Bob,$4c(a6)
	move.l	b_Mask,$50(a6)
	move.w	#[15*3*64]+2,$58(a6)	

	dbf	d7,b_setLoop

	rts

Double_Buffer2:
	move.l	#PlayField1,d0
	move.l	#PlayField2,Screen
	move.l	#b_Olds2,b_OldBobs

	eor.w	#1,Flag
	beq.s	DoubleBuffer2

	move.l	#PlayField2,d0
	move.l	#PlayField1,Screen
	move.l	#b_Olds1,b_OldBobs

DoubleBuffer2:
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1
	swap	d0
	add.l	#40,d0
	move.w	d0,lo2
	swap	d0
	move.w	d0,hi2
	swap	d0
	add.l	#40,d0
	move.w	d0,lo3
	swap	d0
	move.w	d0,hi3
	rts

InitBallProgram:
	lea	b_AdderTab,a0
	moveq	#0,d0
	move.w	#128,d7
b_AdLoop:
	move.w	d0,(a0)+
	add.w	#120,d0
	dbf	d7,b_adloop

	rts

c_Scroller:
	bsr.s	c_Repeat
	nop
c_Repeat:
	lea	$dff000,a6
	move.l	#-1,$44(a6)

	subq.w	#1,c_Bredde
	bne.L	c_DoScroll	

	move.l	#$00240050,$64(a6)
	move.l	#$09f00000,$40(a6)

	lea	c_FontTab,a1
	lea	c_SizeTab,a2

	move.l	c_textpointer,a0
c_Search:
	moveq	#0,d0
	move.b	(a0)+,d0

	tst.b	d0
	bne.s	c_Ok_Letter

	move.l	#c_text,a0
	move.b	(a0)+,d0
c_Ok_Letter:
	move.l	a0,c_TextPointer

	lsl.w	#1,d0
	move.w	(a2,d0),c_Bredde
	cmp.w	#32,c_Bredde
	ble.s	c_Ok_Bredde

	move.w	#32,c_Bredde

c_Ok_Bredde:
	lsl.w	#1,d0
	move.l	(a1,d0),$50(a6)
	move.l	#c_Scrplane+80,$54(a6)
	move.w	#[20*64]+2,$58(a6)
	nop
	nop

c_DoScroll:
	move.l	#c_ScrPlane,$50(a6)
	move.l	#c_ScrPlane-2,$54(a6)
	clr.l	$64(a6)
	move.l	#$f9f00000,$40(a6)
	move.w	#[21*64]+42,$58(a6)
	nop
	nop

	rts

Double_Buffer1:
	move.l	#PlayField1,d0
	move.l	#PlayField2,Screen
	move.l	#PlayField2+[128*40],Bottom

	eor.w	#1,Flag
	beq.s	DoubleBuffer1

	move.l	#PlayField2,d0
	move.l	#PlayField1,Screen
	move.l	#PlayField1+[128*40],Bottom

DoubleBuffer1:
	move.w	d0,Lo1
	swap	d0
	move.w	d0,Hi1
	rts

MoveSprites:
	lea	SprBlk+7,a0
	move.w	#41,d7
MvLoop:
	addq.b	#$2,(a0)
	addq.l	#$8,a0
	addq.b	#$1,(a0)
	addq.l	#$8,a0
	addq.b	#$3,(a0)
	addq.l	#$8,a0
	dbf	d7,MvLoop
	rts

RotateLogo:
	subq.w	#1,Ldelay
	bne.L	OkPointer
	move.w	#1,Ldelay

	move.l	RotPointer,a0
	lea	Block,a1

	move.l	#Elkjop,d0

	move.w	#70,d7
RLoop:
	moveq	#0,d1
	move.w	(a0)+,d1

	tst.w	d1
	bge.s	OkLine

	moveq	#0,d1

OkLine:
	add.l	d0,d1

	move.w	d1,6(a1)
	swap	d1
	move.w	d1,10(a1)
	swap	d1
	add.l	#40,d1
	move.w	d1,14(a1)
	swap	d1
	move.w	d1,18(a1)

	add.l	#20,a1

	dbf	d7,RLoop

	move.l	a0,RotPointer
	cmp.l	#RotEnd,RotPointer
	blt.s	OkPointer
	move.l	#RotTab,RotPointer

	sub.w	#1,AntR
	bne.s	OkPointer
	move.w	#2,AntR

	move.w	#150,Ldelay
OkPointer:
	rts

SetupRotScroll:
	move.l	#a_Text,a_TextPoint
	move.w	#$8,a_ScrollDelay
	clr.w	mod1
	clr.w	mod2
	clr.w	scr
	clr.w	pri
	move.w	#$68d,Cols+6
	move.w	#$1200,planes

	move.l	#MasterTable+4,MasterPoint
	rts


a_RotScroll:
	lea	$dff000,a6
	move.l	#-1,$44(a6)

	tst.w	a_ScrollDel
	beq.s	a_DoScroll

	subq.w	#1,a_ScrollDel
	bra.L	a_Rotate

a_DoScroll:
	sub.w	#1,a_ScrollDelay
	bne.s	a_Scroll_Rotate
	move.w	#8,a_ScrollDelay
	
	move.l	a_TextPoint,a0
a_Search:
	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	bne.s	a_SetupThis

	move.l	#MasterTable+8,MasterPoint

	move.l	#a_Text,a_TextPoint
	bra.s	a_Rotate

a_SetupThis:
	move.l	a0,a_TextPoint

	cmp.b	#$10,d0
	bne.s	a_ALetter

	move.w	#250,a_ScrollDel
	bra.s	a_Search

a_ALetter:
	lsl.w	#2,d0
	lea	a_FontBlk,a0

	move.l	(a0,d0.w),$50(a6)
	move.l	#a_ScrMem+40,$54(a6)
	move.l	#$00260028,$64(a6)
	move.l	#$09f00000,$40(a6)
	move.w	#[13*64]+1,$58(a6)
	nop
	nop

a_Scroll_Rotate:
	move.l	#a_ScrMem,$50(a6)
	move.l	#a_ScrMem-2,$54(a6)
	clr.l	$64(a6)
	move.l	#$e9f00000,$40(a6)
	move.w	#[14*64]+21,$58(a6)
	nop
	nop

a_Rotate:
	move.l	#$01000000,$40(a6)
	clr.w	$66(a6)
	move.l	Screen,a0
	add.l	#[57*40],a0
	move.l	a0,$54(a6)
	move.w	#[14*64]+20,$58(a6)

a_w1:	btst	#14,$02(a6)
	bne.s	a_w1

	move.w	#$0024,$60(a6)
	move.l	#$00260024,$64(a6)
	move.w	#$0000,$46(a6)

	move.l	a_TabPoint,a0
	lea	a_ScrMem,a1
	move.l	Screen,a2
	add.l	#[57*40],a2

	move.w	#19,d7
a_RotateLoop:
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0

	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$8000,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#$1,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$4000,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#2,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$2000,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#3,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$1000,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#4,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$800,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#5,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$400,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#6,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$200,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#7,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$100,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	subq.w	#8,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$80,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	sub.w	#9,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$40,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	sub.w	#10,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$20,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	sub.w	#11,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$10,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	sub.w	#12,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$8,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	sub.w	#13,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$4,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	sub.w	#14,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$2,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	sub.w	#15,d0
	ror.l	#4,d0
	lsl.w	#1,d0
	move.w	d0,d1
	swap	d0
	or.w	#$0bfa,d0
	move.w	d0,$40(a6)	
	add.l	a2,d1
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.l	a1,$50(a6)
	move.w	#$1,$44(a6)
	move.w	#[13*64]+2,$58(a6)

	add.l	#$2,a1
	dbf	d7,a_RotateLoop

	move.l	a0,a_TabPoint
	cmp.l	#a_SinEnd,a_TabPoint
	blt.s	a_OkPointer
	move.l	#a_SinTab,a_TabPoint
a_OkPointer:
	rts

AddLinePointers:
	rts

DrawTheLines:
	move.w	#$fff,Cols+6

	move.l	Screen,$dff054
	move.l	#$01000000,$dff040
	clr.w	$dff066
	move.w	#[65*64]+20,$dff058

	move.l	a7,OldStack
	move.l	Bottom,a7
	movem.l	CLR,d0-d7/a0-a6
	blk.l	42,$48e7fffe
	move.l	OldStack,a7

	lea	$dff000,a6
	move.l	#-1,$44(a6)
	move.w	#$8000,$74(a6)
	move.w	#$28,$60(a6)
	move.w	#$28,$66(a6)

	tst.w	LineLong
	beq.s	CalcLineLooks

	subq.w	#1,LineLong
	move.w	#$ffff,$72(a6)
	bra.s	DrawThem

CalcLineLooks:
	move.l	LinePointer,a2
	move.w	(a2)+,$72(a6)
	move.l	a2,LinePointer
	cmp.l	#LineEnd,a2
	blt.s	DrawThem

	move.l	#LineTable,LinePointer
	move.w	#700,LineLong
	move.l	#MasterTable+12,MasterPoint
	bra.L	Ok_Ypos

Drawthem:
	lea	Object,a0
	move.l	Screen,a1
DrawLoop:
	move.w	(a0)+,X
	move.w	(a0)+,Y
	move.w	(a0)+,Z

	cmp.w	#$8000,(a0)
	beq.L	New_Start_Point
	cmp.w	#$8001,(a0)
	beq.s	ObjectDrawn

	bsr.L	Rotate_Convert
	move.w	d3,X1
	move.w	d4,Y1

	move.w	(a0),X
	move.w	2(a0),Y
	move.w	4(a0),Z

	bsr.L	Rotate_Convert
	move.w	d3,X2
	move.w	d4,Y2
	
	movem.l	CLR,d0-d3

	move.w	X1,d0
	move.w	Y1,d1
	move.w	X2,d2
	move.w	Y2,d3

	cmp.w	d0,d2
	bne.s	DrawLine
	cmp.w	d1,d3
	bne.s	DrawLine
	bra.s	NoLine

DrawLine:
	bsr.s	Line_Draw
NoLine:
	bra.L	DrawLoop

ObjectDrawn:
	add.w	#$006,Xangle
	add.w	#$000,Yangle
	add.w	#$014,Zangle
	and.w	#$7fe,Xangle
	and.w	#$7fe,Yangle
	and.w	#$7fe,Zangle

	tst.w	Ypos
	beq.s	Ok_Ypos

	subq.w	#1,Ydelay
	bne.s	Ok_Ypos
	move.w	#3,YDelay

	subq.w	#1,Ypos
Ok_Ypos:
	rts

New_Start_Point:
	add.l	#$2,a0
	bra.L	DrawLoop

Line_Draw:
	movem.l	CLR,d0-d3

	move.w	X1,d0
	move.w	Y1,d1
	move.w	X2,d2
	move.w	Y2,d3

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

Rotate_Convert:
	lea	Sinus,a2
	lea	Sinus+512,a3

	move.w	Xangle,d0
	move.w	Yangle,d1
	move.w	Zangle,d2

DoRotasjon:
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

**************************************************************

; Convert from 3D to 2D

**************************************************************

	movem.l	CLR,d3-d6

	move.w	Zoom,d6

	move.w	NX,d3
	move.w	NY,d4
	move.w	NZ,d5

	add.w	#1500,d5	
	tst.w	d5
	bne.s	NotNULL

	moveq	#1,d5

NotNULL:
	muls	d6,d3
	muls	d6,d4
	divs	d5,d3
	divs	d5,d4

	and.l	#$ffff,d3
	and.l	#$ffff,d4

	add.w	#159,d3
	add.w	#63,d4
	add.w	Ypos,d4

	rts

InitProgram:
	move.l	#c_ScrPlane,d0
	move.w	d0,c_lo
	swap	d0
	move.w	d0,c_hi

	move.l	#Sprite,d0
	move.w	d0,Slo1
	swap	d0
	move.w	d0,Shi1

	move.l	#NULL,d0
	move.w	d0,Slo2
	swap	d0
	move.w	d0,Shi2
	move.l	#NULL,d0
	move.w	d0,Slo3
	swap	d0
	move.w	d0,Shi3
	move.l	#NULL,d0
	move.w	d0,Slo4
	swap	d0
	move.w	d0,Shi4
	move.l	#NULL,d0
	move.w	d0,Slo5
	swap	d0
	move.w	d0,Shi5
	move.l	#NULL,d0
	move.w	d0,Slo6
	swap	d0
	move.w	d0,Shi6
	move.l	#NULL,d0
	move.w	d0,Slo7
	swap	d0
	move.w	d0,Shi7
	move.l	#NULL,d0
	move.w	d0,Slo8
	swap	d0
	move.w	d0,Shi8

	move.l	#PlayField1,d0
	move.w	d0,Lo1
	swap	d0
	move.w	d0,Hi1

	lea	Block,a0
	move.l	#Elkjop,d1

	move.l	#$3001ff00,d0
	move.w	#70,d7
BlkLoop:
	move.l	d0,(a0)+
	move.w	#$00e2,(a0)+
	move.w	d1,(a0)+
	move.w	#$00e0,(a0)+
	swap	d1
	move.w	d1,(a0)+
	swap	d1
	add.l	#40,d1
	move.w	#$00e6,(a0)+
	move.w	d1,(a0)+
	move.w	#$00e4,(a0)+
	swap	d1
	move.w	d1,(a0)+
	swap	d1
	add.l	#40,d1

	add.l	#$01000000,d0
	dbf	d7,BlkLoop

	moveq	#0,d0
	lea	SprBlk,a0
	lea	SprRnd,a1
	move.b	#$81,d0
	move.w	#125,d7
InSprLoop:
	move.b	d0,(a0)+
	move.b	#$21,(a0)+
	move.w	#$fffe,(a0)+
	move.w	#$0140,(a0)+
	move.b	d0,(a0)+
	move.b	(a1)+,(a0)+
	addq.b	#$1,d0
	dbf	d7,InSprLoop

	rts

j_PrepareSprites:
	moveq	#0,d0
	lea	SprBlk,a0
	lea	SprRnd,a1
	move.b	#$81,d0
	move.w	#125,d7
InSprLoopA:
	move.b	d0,(a0)+
	move.b	#$21,(a0)+
	move.w	#$fffe,(a0)+
	move.w	#$0140,(a0)+
	move.b	d0,(a0)+
	move.b	(a1)+,(a0)+
	addq.b	#$1,d0
	dbf	d7,InSprLoopA

	move.l	#$01fe01fe,(a0)+
	move.l	#$01fe01fe,(a0)+

	move.l	#MasterTable+72,MasterPoint

	rts

FadeInSprites:
	subq.w	#1,j_del
	bne.L	j_shit
	move.w	#3,j_del

	lea	cols+$46,a0
	lea	j_sprcol,a1

	movem.l	CLR,d0-d7
	move.w	#3,d7
j_loop:
	move.w	(a0),d0
	cmp.w	(a1),d0
	beq.s	j_AddNext

	move.w	#1,d6

	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2

	move.w	(a1),d3
	move.w	d3,d4
	move.w	d3,d5

	and.w	#$00f,d0
	and.w	#$00f,d3
	and.w	#$0f0,d1
	and.w	#$0f0,d4
	and.w	#$f00,d2
	and.w	#$f00,d5

j_B:
	cmp.w	d0,d3
	beq.s	j_G
	addq.w	#$1,d0
j_G:
	cmp.w	d1,d4
	beq.s	j_R
	add.w	#$10,d1
j_R:
	cmp.w	d2,d5
	beq.s	j_OR
	add.w	#$100,d2
j_OR:
	or.w	d1,d0
	or.w	d2,d0
	move.w	d0,(a0)

j_AddNext:
	add.l	#$4,a0
	add.l	#$2,a1

	dbf	d7,j_loop

	tst.w	d6
	bne.s	j_Shit

	move.l	#MasterTable,MasterPoint

j_Shit:
	rts

Copper:
	dc.w	$0c01,$ff00
	dc.w	$008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0028,$010a,$0028

	dc.w	$0124
Shi2:	dc.w	$0000
	dc.w	$0126
Slo2:	dc.w	$0000
	dc.w	$0128
Shi3:	dc.w	$0000
	dc.w	$012a
Slo3:	dc.w	$0000
	dc.w	$012c
Shi4:	dc.w	$0000
	dc.w	$012e
Slo4:	dc.w	$0000
	dc.w	$0130
Shi5:	dc.w	$0000
	dc.w	$0132
Slo5:	dc.w	$0000
	dc.w	$0134
Shi6:	dc.w	$0000
	dc.w	$0136
Slo6:	dc.w	$0000
	dc.w	$0138
Shi7:	dc.w	$0000
	dc.w	$013a
Slo7:	dc.w	$0000
	dc.w	$013c
Shi8:	dc.w	$0000
	dc.w	$013e
Slo8:	dc.w	$0000

	dc.w	$0180,$00a0
	dc.w	$0182,$0fff,$0184,$000c,$0186,$0bbb

	dc.w	$2fdf,$fffe,$0100,$2200

Block:	blk.l	[71*5],$01fe01fe
	dc.w	$7701,$ff00,$0100,$0000
	dc.w	$7b21,$fffe,$0180,$000d
	dc.w	$7d21,$fffe,$0180,$0000

	dc.w	$0120
Shi1:	dc.w	$0000
	dc.w	$0122
Slo1:	dc.w	$0000
	dc.w	$0142,$ff00

	dc.w	$0108
mod1:	dc.w	$0000,$010a
mod2:	dc.w	$0000
	dc.w	$0102
scr:	dc.w	$0000,$0104
pri:	dc.w	$0000

Cols:
dc.w	$0180,$0000
dc.w	$0182,$0000,$0184,$0000,$0186,$0000,$0188,$0000
dc.w	$018a,$0000,$018c,$0000,$018e,$0000
dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000,$0198,$0000
dc.w	$019a,$0000,$019c,$0000,$019e,$0000
dc.w	$01a0,$0000,$01a2,$0fff,$01a4,$0bbb,$01a6,$0888,$01a8,$0000
dc.w	$01aa,$0000,$01ac,$0000,$01ae,$0000
dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000,$01b8,$0000
dc.w	$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$00e0
hi1:	dc.w	$0000
	dc.w	$00e2
lo1:	dc.w	$0000
	dc.w	$00e4
hi2:	dc.w	$0000
	dc.w	$00e6
lo2:	dc.w	$0000
	dc.w	$00e8
hi3:	dc.w	$0000
	dc.w	$00ea
lo3:	dc.w	$0000
	dc.w	$00ec
hi4:	dc.w	$0000
	dc.w	$00ee
lo4:	dc.w	$0000
	dc.w	$00f0
hi5:	dc.w	$0000
	dc.w	$00f2
lo5:	dc.w	$0000
	dc.w	$8001,$ff00,$0100
Planes:	dc.w	$1200
	
SprBlk:	blk.l	[2*128],$01fe01fe

	dc.w	$ffdf,$fffe
	dc.w	$0001,$ff00,$0100,$0000
	dc.w	$0180,$000d
	dc.w	$0221,$fffe,$0180,$00a0

	dc.w	$0108,$0004,$010a,$0004
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0182,$0fff

	dc.w	$00e0
c_hi:	dc.w	$0000
	dc.w	$00e2
c_lo:	dc.w	$0000
	dc.w	$1001,$ff00,$0100,$9200
	dc.w	$2401,$ff00,$0100,$0000

	dc.w	$009c,$8010
	dc.w	$ffff,$fffe

*********************************
*** Master Interrupt Routines ***
*********************************

MasterPoint:	dc.l	MasterTable
MasterTable:	dc.l	Rutiner3,Rutiner1,Rutiner2,Rutiner4
		dc.l	Rutiner5,Rutiner6,OnlySprites
		dc.l	Rutiner7,Rutiner8
		dc.l	Rutiner9,Rutiner10
		dc.l	Rutiner11,Rutiner12
		dc.l	Rutiner13
		dc.l	Nothing
		dc.l	Rutiner14,Rutiner15
		dc.l	Rutiner16,Rutiner17

Rutiner1:
	dc.l	MoveSprites
	dc.l	Double_Buffer1
	dc.l	a_RotScroll
	dc.l	0

Rutiner2:
	dc.l	MoveSprites
	dc.l	Double_Buffer1	
	dc.l	DrawTheLines

	dc.l	0

Rutiner3:
	dc.l	MoveSprites
	dc.l	SetupRotScroll
	dc.l	0

Rutiner4:
	dc.l	MoveSprites
	dc.l	PrepareBalls
	dc.l	0

Rutiner5:
	dc.l	MoveSprites
	dc.l	AddBallPointers
	dc.l	Double_Buffer2
	dc.l	VectorBalls
	dc.l	0

Rutiner6:
	dc.l	MoveSprites
	dc.l	PrepareVertical
	dc.l	0

OnlySprites:
	dc.l	MoveSprites
	dc.l	0

Rutiner7:
	dc.l	MoveSprites
	dc.l	PrepareSinScrProgram
	dc.l	0

Rutiner8:
	dc.l	MoveSprites
	dc.l	Double_Buffer1
	dc.l	e_SinusScroll
	dc.l	0

Rutiner9:
	dc.l	MoveSprites
	dc.l	f_initProgram
	dc.l	0

Rutiner10:
	dc.l	MoveSprites
	dc.l	f_RGBbobs
	dc.l	0

Rutiner11:
	dc.l	MoveSprites
	dc.l	FadeOutSprites
	dc.l	0

Rutiner12:
	dc.l	g_initprogram
	dc.l	0

Rutiner13:
	dc.l	g_Rasters
	dc.l	0

Nothing:
	dc.l	0

Rutiner14:
	dc.l	h_initprogram
	dc.l	0

Rutiner15:
	dc.l	h_TheEnd
	dc.l	0

Rutiner16:
	dc.l	j_PrepareSprites
	dc.l	0

Rutiner17:
	dc.l	MoveSprites
	dc.l	FadeInSprites
	dc.l	0

**********************************
*** Master Mouse-Loop Routines ***
**********************************

MousePoint:	dc.l	MouseTable
MouseTable:	dc.l	Mouse1,Mouse2

Mouse1:	
	dc.l	0

Mouse2:
	dc.l	d_Vertical
	dc.l	0

*****************
*** RotScroll ***
*****************

a_ScrollDel:	dc.w	0
a_ScrollDelay:	dc.w	8
a_Textpoint:	dc.l	a_text

a_text:
	dc.b	"         "
	DC.B	"COMMODORE AMIGA   ",$10
	DC.B	"                     "
	DC.B	"...OG DU TRODDE IKKE DATAMASKINER KLARTE "
	DC.B	"ANNET ENN KJEDLIG TEKSTBEHANDLING OG REGNSKAP!!"
	DC.B	"                     "
	DC.B	"DER TOK DU FEIL!!! ",$10
	DC.B	"                        "
	DC.B	0
even

a_FontBlk:
		blk.l	33,a_Font+1052
		dc.l	a_Font+556
		blk.l	5,a_Font+1052
		dc.l	a_Font+1044,a_Font+1040,a_Font+1042
		blk.l	2,a_Font+1052
		dc.l	a_Font+554,a_Font+1046,a_Font+552
		dc.l	a_Font+1052
		dc.l	a_Font+532,a_Font+534,a_Font+536,a_Font+538
		dc.l	a_Font+540,a_Font+542,a_Font+544,a_Font+546
		dc.l	a_Font+548,a_Font+550
		dc.l	a_Font+1048,a_Font+1050
		blk.l	3,a_Font+1052
		dc.l	a_Font+558
		dc.l	a_Font+1052
		dc.l	a_Font+0,a_Font+2,a_Font+4,a_Font+6,a_Font+8
		dc.l	a_Font+10,a_Font+12,a_Font+14,a_Font+16,a_Font+18
		dc.l	a_Font+20,a_Font+22,a_Font+24,a_Font+26,a_Font+28
		dc.l	a_Font+30,a_Font+32,a_Font+34,a_Font+36,a_Font+38
		dc.l	a_Font+520,a_Font+522,a_Font+524,a_Font+526
		dc.l	a_Font+528,a_Font+530
		blk.l	37,a_Font+1052

		dc.w	0
a_ScrMem:	blk.b	[14*42],0
a_TabPoint:	dc.l	a_Sintab+[640*0]
a_Font:		incbin	"PIC/13x13font.blt"
a_SinTab:	incbin	"RotX.tab"
a_SinEnd:

*******************
*** VectorLines ***
*******************

CLR:		blk.l	15,0
OldStack:	dc.l	0

LineLong:	dc.w	700
LineTable:
		blk.w	5,$ffff
		blk.w	5,$7fff
		blk.w	5,$3fff
		blk.w	5,$1fff
		blk.w	5,$fff
		blk.w	5,$7ff
		blk.w	5,$3ff
		blk.w	5,$1ff
		blk.w	5,$ff
		blk.w	5,$7f
		blk.w	5,$3f
		blk.w	5,$1f
		blk.w	5,$f
		blk.w	5,$7
		blk.w	5,$3
		blk.w	5,$1
		blk.w	5,$0
LineEnd:

LinePointer:	dc.l 	LineTable

X:		dc.w	0
Y:		dc.w	0
Z:		dc.w	0
NX:		dc.w	0
NY:		dc.w	0
NZ:		dc.w	0
X1:		dc.w	0
Y1:		dc.w	0
X2:		dc.w	0
Y2:		dc.w	0

Xangle:		dc.w	0
Yangle:		dc.w	0
Zangle:		dc.w	0
Xuse:		dc.w	0
Yuse:		dc.w	0
Zuse:		dc.w	0

Ypos:		dc.w	97
YDelay:		dc.w	4
Zoom:		dc.w	300

Object:
		dc.w	-32,-32,-32+16
		dc.w	032,-32,-32+16
		dc.w	032,032,-32+16
		dc.w	-32,032,-32+16
		dc.w	-32,-32,-32+16
		dc.w	$8000
		dc.w	-32,-32,032+16
		dc.w	032,-32,032+16
		dc.w	032,032,032+16
		dc.w	-32,032,032+16
		dc.w	-32,-32,032+16
		dc.w	$8000
		dc.w	-32,-32,-32+16
		dc.w	-32,-32,032+16
		dc.w	$8000
		dc.w	032,-32,-32+16
		dc.w	032,-32,032+16
		dc.w	$8000
		dc.w	-32,032,-32+16
		dc.w	-32,032,032+16
		dc.w	$8000
		dc.w	032,032,-32+16
		dc.w	032,032,032+16
		dc.w	$8001

********************
*** Plain Scroll ***
********************

c_Bredde:	dc.w	1

c_Text:	
	dc.b	"Commodore Amiga 500  ...  ELKJØP Reklame  ...  "
	dc.b	"Laget Av Morten Amundsen  ...  "
	dc.b	0
even

c_TextPointer:	dc.l	c_Text

c_FontTab:
		blk.l	$21,c_Font+[20*40*8]+32
		dc.l	c_Font+[20*40*6]+32,c_Font+[20*40*6]+36
		dc.l	c_Font+[20*40*8]+32,c_Font+[20*40*7]+0
		dc.l	c_Font+[20*40*7]+4,c_Font+[20*40*7]+8
		dc.l	c_Font+[20*40*7]+32,c_Font+[20*40*7]+12
		dc.l	c_Font+[20*40*7]+16
		dc.l	c_Font+[20*40*8]+36,c_Font+[20*40*7]+28
		dc.l	c_Font+[20*40*7]+36
		dc.l	c_Font+[20*40*7]+24,c_Font+[20*40*8]+0
		dc.l	c_Font+[20*40*7]+20
		dc.l	c_Font+[20*40*5]+32,c_Font+[20*40*5]+36
		dc.l	c_Font+[20*40*6]+0,c_Font+[20*40*6]+4
		dc.l	c_Font+[20*40*6]+8,c_Font+[20*40*6]+12
		dc.l	c_Font+[20*40*6]+16,c_Font+[20*40*6]+20
		dc.l	c_Font+[20*40*6]+24,c_Font+[20*40*6]+28
		dc.l	c_Font+[20*40*8]+4,c_Font+[20*40*8]+8
		blk.l	3,c_Font+[20*40*8]+36
		dc.l	c_Font+[20*40*8]+12,c_Font+[20*40*8]+36
		dc.l	c_Font+0,c_Font+4,c_Font+8,c_Font+12,c_Font+16
		dc.l	c_Font+20,c_Font+24,c_Font+28,c_Font+32
		dc.l	c_Font+36
		dc.l	c_Font+[20*40]+0,c_Font+[20*40]+4,c_Font+[20*40]+8
		dc.l	c_Font+[20*40]+12,c_Font+[20*40]+16
		dc.l	c_Font+[20*40]+20,c_Font+[20*40]+24
		dc.l	c_Font+[20*40]+28,c_Font+[20*40]+32
		dc.l	c_Font+[20*40]+36
		dc.l	c_Font+[20*40*2]+0,c_Font+[20*40*2]+4
		dc.l	c_Font+[20*40*2]+8,c_Font+[20*40*2]+12
		dc.l	c_Font+[20*40*2]+16,c_Font+[20*40*2]+20
		blk.l	6,c_Font+[20*40*8]+36
		dc.l	c_Font+[20*40*2]+36
		dc.l	c_Font+[20*40*3]+0
		dc.l	c_Font+[20*40*3]+4,c_Font+[20*40*3]+8
		dc.l	c_Font+[20*40*3]+12,c_Font+[20*40*3]+16
		dc.l	c_Font+[20*40*3]+20
		dc.l	c_Font+[20*40*3]+24,c_Font+[20*40*3]+28
		dc.l	c_Font+[20*40*3]+32,c_Font+[20*40*3]+36
		dc.l	c_Font+[20*40*4]+0
		dc.l	c_Font+[20*40*4]+4,c_Font+[20*40*4]+8
		dc.l	c_Font+[20*40*4]+12,c_Font+[20*40*4]+16
		dc.l	c_Font+[20*40*4]+20
		dc.l	c_Font+[20*40*4]+24,c_Font+[20*40*4]+28
		dc.l	c_Font+[20*40*4]+32,c_Font+[20*40*4]+36
		dc.l	c_Font+[20*40*5]+0
		dc.l	c_Font+[20*40*5]+4,c_Font+[20*40*5]+8
		dc.l	c_Font+[20*40*5]+12,c_Font+[20*40*5]+16
		blk.l	$4a,c_Font+[20*40*8]+36
		dc.l	c_Font+[20*40*2]+32,c_Font+[20*40*2]+24
		blk.l	17,c_Font+[20*40*8]+36
		dc.l	c_Font+[20*40*2]+28
		blk.l	12,c_Font+[20*40*8]+36
		dc.l	c_Font+[20*40*5]+28,c_Font+[20*40*5]+20
		blk.l	17,c_Font+[20*40*8]+36
		dc.l	c_Font+[20*40*5]+24

c_SizeTab:	blk.w	$21,10
		dc.w	7,12,10,23,27,30,8,8,8
		dc.w	10,12,8,14,8,18
		dc.w	27,15,22,24,24,23,25,21,25,25
		dc.w	8,8,10,10,10,20,10
		dc.w	32,26,32,32,25,22,32,32,12,14
		dc.w	32,24,33,32,33,30,33,31,24,28
		dc.w	32,32,33,32,32,28
		blk.w	6,10
		dc.w	23,26,25,26,25,16
		dc.w	26,25,12,12
		dc.w	27,12,33,25,25
		dc.w	25,25,21,19
		dc.w	16,24,25,32,23,24,21
		blk.w	$4a,10
		dc.w	33,31
		blk.w	17,10
		dc.w	33
		blk.w	12,10
		dc.w	24,33
		blk.w	17,10
		dc.w	25

c_Font:		incbin	"PIC/BodoniFont.bmp"

c_ScrPlane:	blk.b	[21*84],0

*******************
*** VectorBalls ***
*******************

BallsWait:	dc.w	800

b_YposDel:	dc.w	4

b_Object:
		dc.w	-32,-32,-32
		dc.w	-16,-32,-32
		dc.w	-32,-16,-32
		dc.w	-16,-16,-32

		dc.w	-32,-32,-16
		dc.w	-16,-32,-16
		dc.w	-32,-16,-16
		dc.w	-16,-16,-16

b_NoBobs:	dc.w	8-1

b_Bob:		dc.l	Image
b_Mask:		dc.l	Image+[15*3*4]

b_OldBobs:	dc.l	b_Olds1
b_Olds1:	blk.l	64,PlayField1
b_Olds2:	blk.l	64,PlayField2

Image:		incbin	"PIC/vecbob.blt"

b_NewObject:	blk.w	[8*2],0
b_NewObjectEND:

b_AdderTab:	blk.w	129,0

********************
*** Verical Bars ***
********************

d_ToDo:		dc.w	1
d_FadeDelay:	dc.w	4
d_VertWait:	dc.w	700

d_FadeVert:
		dc.w	$0000,$0ee0,$0ca0,$0a60
		dc.w	$0840,$0620,$0410,$0200
		dc.w	$0ffc,$07ee,$05cd,$04ab
		dc.w	$038a,$0169,$0157,$0036

d_xadd1:	dc.b	0
d_xadd2:	dc.b	0

d_sinus:	incbin	"sinus255.tab"
d_img:		incbin	"pic/goldblue.blt"
d_mask:		blk.l	4,$ffff0000

********************
*** Sinus Scroll ***
********************

e_text:
		dc.b	"THIS IS EASY!!!"
		DC.B	"                    "
		DC.B	"BUY AN IBM PC AND SEE IF IT CAN DO "
		DC.B	"ALL THIS...!!"
		DC.B	"                    "
		dc.b	0
even

e_textadd:	dc.l	e_text

e_yadd1:	dc.b	64
e_yadd2:	dc.b	64

e_Scr:		dc.w	8
e_Yadds:	blk.l	115,0
e_sinus:	incbin	"sinus114.tab"
		dc.w	0
e_Memory:	blk.b	[14*42],0

****************
*** RGB bobs ***
****************

f_rgbdel:	dc.w	3
f_flg:		dc.w	1
f_wrt:		dc.w	700

f_rgbfade:	dc.w	$000,$00f,$0f0,$0ff,$f00,$f0f,$ff0,$fff

f_antall:	dc.w	32-1

f_xadd1:	dc.b	0
f_xadd2:	dc.b	0
f_yadd1:	dc.b	64
f_yadd2:	dc.b	64

f_bob:		dc.l	f_Image
f_mask:		dc.l	f_Image+[13*4]
f_image:	incbin	"pic/rgb.bmp"
f_OldBobs:	dc.l	f_Olds1
f_Olds1:	blk.l	32,PlayField1
f_Olds2:	blk.l	32,PlayField2

********************
*** Sprites Fade ***
********************

sprdel:		dc.w	25
j_sprcol:	dc.w	$fff,$bbb,$888
j_del:		dc.w	3
i_drives:	dc.w	0

***************
*** Rasters ***
***************

g_bigdel:	dc.w	700
g_delay:	dc.w	10
g_fg:		dc.w	1


g_antall:		dc.w	1-1
g_coltab:
		dc.l	g_color1,g_color2,g_color3,g_color4
		dc.l	g_color5,g_color6,g_color7,g_color8
		dc.l	g_color9,g_color10
g_colend:

g_color1:	dc.w	$333,$777,$999,$bbb,$999,$777,$333
g_color2:	dc.w	$303,$707,$909,$b0b,$909,$707,$303
g_color3:	dc.w	$300,$700,$900,$b00,$900,$700,$300
g_color4:	dc.w	$003,$007,$009,$00b,$009,$007,$003
g_color5:	dc.w	$330,$770,$990,$bb0,$990,$770,$330
g_color6:	dc.w	$033,$077,$099,$0bb,$099,$077,$033
g_color7:	dc.w	$003,$057,$579,$79b,$579,$057,$003
g_color8:	dc.w	$300,$750,$975,$b97,$975,$750,$300
g_color9:	dc.w	$300,$705,$957,$b79,$957,$705,$300
g_color10:	dc.w	$003,$507,$759,$97b,$579,$507,$003

g_yadd1:	dc.b	0
g_yadd2:	dc.b	0
g_addertab:	blk.w	128,0

********************
*** The End text ***
********************

h_maskdel:	dc.w	700
h_fl:		dc.w	1

h_colors:	incbin	"colors.tab"

h_xpositions:	dc.w	111,125,139
		dc.w	167,181,195

h_LetterAds:	dc.l	a_Font+38,a_Font+14,a_font+8
		dc.l	a_font+8,a_Font+26,a_font+6

h_maskpoint1:	dc.l	h_mask1

h_mask1:
		blk.w	5,$0000
		blk.w	5,$0001
		blk.w	5,$0003
		blk.w	5,$0007
		blk.w	5,$000f
		blk.w	5,$001f
		blk.w	5,$003f
		blk.w	5,$007f
		blk.w	5,$00ff
		blk.w	5,$01ff
		blk.w	5,$03ff
		blk.w	5,$07ff
		blk.w	5,$0fff
		blk.w	5,$1fff
		blk.w	5,$3fff
		blk.w	5,$7fff
		blk.w	5,$ffff
h_maskend1:

h_maskpoint2:	dc.l	h_mask2

h_mask2:
		blk.w	5,$ffff
		blk.w	5,$7fff
		blk.w	5,$3fff
		blk.w	5,$1fff
		blk.w	5,$0fff
		blk.w	5,$07ff
		blk.w	5,$03ff
		blk.w	5,$01ff
		blk.w	5,$00ff
		blk.w	5,$007f
		blk.w	5,$003f
		blk.w	5,$001f
		blk.w	5,$000f
		blk.w	5,$0007
		blk.w	5,$0003
		blk.w	5,$0001
		blk.w	5,$0000
h_maskend2:

h_yadd1:	dc.b	0
h_yadd2:	dc.b	0

h_oldbobs:	dc.l	h_olds1
h_olds1:	blk.l	6,playfield1
h_olds2:	blk.l	6,playfield2

h_adds:		blk.w	128,0


*********************
*** Main Routines ***
*********************

Ldelay:		dc.w	150
AntR:		dc.w	2
RotPointer:	dc.l	RotTab

Flag:		dc.w	0
Screen:		dc.l	PlayField1
Bottom:		dc.l	PlayField1+[128*40]
PlayField1:	blk.b	[128*40*5],0
PlayField2:	blk.b	[128*40*5],0

NULL:		dc.l	0
Elkjop:		incbin	"PIC/elkjop.blt"
RotTab:		incbin	"RotY.tab"
RotEnd:
SprRnd:		incbin	"SprRnd.tab"
Sprite:		incbin	"Sprite.tab"
Sinus:		incbin	"VectorSinus"

*** VectorBalls HashSort-Table ***
b_HashTable:	blk.w	[32*2*256],$8000
