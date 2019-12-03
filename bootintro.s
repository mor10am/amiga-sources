;-------------------------------------------------------------------------
; Bootintro by Pushead (mortena@ifi.uio.no)                       12/11/92
;-------------------------------------------------------------------------

	org	$30000
	load	$30000

	incdir	"df1:bin/"

; Exec

OpenLibrary:		equ	-552
FindResident:		equ	-96

; Graphics

OpenFont:		equ	-72

;-----------------------------------------------------------------------

WRAST:	MACRO
W\@1:	cmp.b	#\1,$06(a5)
	bne.s	W\@1
	ENDM

;-----------------------------------------------------------------------

S:
	move.l	4.w,a6
	move.l	#END-START,d0
	move.l	#$1,d1
	jsr	-198(a6)
	tst.l	d0
	beq.s	EXIT

	move.l	d0,a1
	move.l	a1,42(a6)
	move.w	#END-START,d7
	lea	START,a0
MMM:	move.b	(a0)+,(a1)+
	dbf	d7,MMM

	clr.l	d1
	lea	34(a6),a0
	move.w	#22,d0
L1:	add.w	(a0)+,d1
	dbf	d0,L1
	not.w	d1
	move.w	d1,82(a6)

	lea	$fc0000,a0
	move.l	4(a0),a0
	jmp	(a0)	

;-------------------------------------------------------------------------

START:
	move.l	4.w,a6
	lea	START(pc),a0
	move.l	a0,42(a6)
	
	movem.l	d0-d7/a0-a6,-(a7)

	lea	gfx(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,a6

	lea	STRUCT(pc),a0
	lea	FONT(pc),a1
	move.l	a1,(a0)
	jsr	OpenFont(a6)
	
	move.l	d0,a4
	beq.w	EXIT

	lea	$22(a4),a4
	move.l	(a4),a4
		
	lea	$dff000,a5	

	move.w	$1c(a5),$70000
	move.w	$02(a5),$70002
	or.w	#$8000,$70000
	or.w	#$8000,$70002
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$96(a5)

	lea	COPPER(pc),a0
	lea	$40000,a1
FILL:	move.l	(a0)+,(a1)+
	bne.s	FILL

	lea	-4(a1),a1

	move.l	a1,$45100
	add.w	#$6,$45102
	clr.b	$45104
	
	move.l	#$2807fffe,d0
	move.w	#263,d7
FILL2:	move.l	d0,(a1)+
	move.l	#$01800000,(a1)+
	move.l	#$01080000,(a1)+
	move.l	#$01000000,(a1)+
	add.l	#$d80000,d0
	move.l	d0,(a1)+
	add.l	#$280000,d0
	dbf	d7,FILL2

	move.l	#$fffffffe,(a1)

	lea	$50000,a0
	move.w	#183,d7
CLR:	move.l	#$0,(a0)+
	dbf	d7,CLR

	lea	SINUS(pc),a0
	lea	$45000,a1
	lea	$45080,a2
	move.w	#63,d7
S1:	move.b	(a0),(a1)+
	move.b	(a0)+,-(a2)
	dbf	d7,S1

	lea	$40(a2),a0
	lea	$40(a2),a1
	move.w	#127,d7
S2:	move.b	-(a0),(a1)+
	not.b	-1(a1)
	subq.b	#1,-1(a1)
	dbf	d7,S2

	lea	$51000,a0
	move.w	#100,d0		; zoom
	move.w	#100,d1		; Z

	move.w	#255,d7
MAKE:	moveq	#-3,d6
ONE:	moveq	#0,d5
	move.w	d6,d5
	muls	d0,d5
	divs	d1,d5
	move.w	d5,(a0)+

	addq.w	#1,d6
	cmp.w	#5,d6
	bne.s	ONE
	add.w	#11,d0
	dbf	d7,MAKE

	lea	TEXT(pc),a0
	lea	PTR(pc),a1
	move.l	a0,(a1)
	
	move.w	#$87c0,$96(a5)

	move.l	#$40000,$80(a5)
	clr.w	$88(a5)

;----------------------------------------------------------------------

MOUSE:	WRAST	$ff
	WRAST	$2b
;--

	bsr.w	BARS
	bsr.w	SCROLL
	bsr.s	STRETCH
	
;--
	bra.s	MOUSE

;----------------------------------------------------------------------

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$96(a5)

	move.w	$70000,$9a(a5)
	move.w	$70002,$96(a5)

	move.l	38(a6),$80(a5)
	clr.w	$88(a5)

	movem.l	(a7)+,d0-d7/a0-a6

EXIT:
	rts

;-------------------------------------------------------------------------

STRETCH:
	moveq	#0,d0
	lea	$45000,a0		; sinus
	lea	$51000,a1		; stretch tab

	lea	SPTR(pc),a2
	move.b	(a2),d0
	add.b	#$4,(a2)

	move.b	(a0,d0.w),d0
	mulu	#$10,d0

	add.w	d0,a1			; values of size

	move.w	#6,d7
DOIT:
	moveq	#0,d1
	moveq	#0,d2
	move.w	(a1)+,d1
	add.w	#125,d1

	move.w	d1,d2
	mulu	#20,d2

	move.l	$45100,a2		; copperliste
	add.l	d2,a2

	move.w	#$0002,4(a2)
	move.w	#$1200,8(a2)	

	move.w	(a1),d2
	add.w	#125,d2
CMPR:	cmp.w	d1,d2
	beq.s	NEXT

	lea	20(a2),a2
	move.w	#$ffd8,4(a2)
	move.w	#$1200,8(a2)	
	addq.w	#1,d1
	bra.s	CMPR

NEXT:	dbf	d7,DOIT
	rts
	
;-------------------------------------------------------------------------

SCROLL:
	lea	COUNT(pc),a0
	subq.w	#1,(a0)
	bne.s	BLIT

	move.w	#8,(a0)
	
	lea	PTR(pc),a0
	move.l	(a0),a1

SEARCH:
	moveq	#0,d0
	move.b	(a1)+,d0
	bne.s	PASTE

	lea	TEXT(pc),a1
	bra.s	SEARCH

PASTE:
	move.l	a1,(a0)

	sub.b	#$20,d0
	lea	(a4,d0.w),a3

	lea	$50028,a2
	move.w	#8,d7
PST:	move.b	(a3),(a2)
	lea	$2a(a2),a2
	lea	$c0(a3),a3
	dbf	d7,PST
BLIT:
	move.l	#$50000,$50(a5)
	move.l	#$4fffe,$54(a5)
	move.l	#-1,$44(a5)
	move.l	#$f9f00000,$40(a5)
	clr.l	$64(a5)
	move.w	#[9*64]+21,$58(a5)
	rts

;-------------------------------------------------------------------------

BARS:
	move.l	$45100,a0
	move.w	#263,d7
CLRB:	clr.w	(a0)
	clr.w	4(a0)
	clr.w	8(a0)
	lea	20(a0),a0
	dbf	d7,CLRB

	moveq	#0,d0
	moveq	#0,d2
	lea	$45000,a0		; sinus
	lea	BB(pc),a3

	move.b	$45104,d0		; sin ptr
	addq.b	#$1,$45104

	move.w	#15,d7
LOOP:
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	mulu	#20,d1

	move.l	$45100,a1		; copper bar dest (copper)
	add.l	d1,a1

	lea	BAR(pc),a2
	move.w	(a3),d2
	mulu	#14,d2
	add.l	d2,a2
	
	move.w	#6,d6
COPY:	move.w	(a2)+,(a1)
	lea	20(a1),a1
	dbf	d6,COPY

	addq.w	#1,(a3)
	andi.w	#3,(a3)

	addq.b	#$4,d0
	dbf	d7,LOOP
	rts

;-------------------------------------------------------------------------

		odd
gfx:		dc.b	'graph'
dos:		dc.b	'ics.library',0
font:		dc.b	'topaz.font',0		

text:		dc.b	"Bootintro by Pushead -- "
		dc.b	0

SPTR:		dc.b	0
		even
		
PTR:		dc.l	0
COUNT:		dc.w	1

STRUCT:		dc.l	0
		dc.w	8
		dc.b	0
		dc.b	0

COPPER:
	dc.w	$008e,$2681,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0180,$0000,$0182,$07bd
	dc.w	$0100,$0000,$0108,$0002
	dc.w	$00e0,$0005,$00e2,$0000
	dc.l	0

SINUS:	dc.b	$80,$83,$86,$89,$8d,$90,$93,$96
	dc.b	$99,$9c,$9f,$a2,$a5,$a8,$ab,$ae
	dc.b	$b1,$b4,$b6,$b9,$bc,$bf,$c1,$c4
	dc.b	$c7,$c9,$cc,$ce,$d1,$d3,$d5,$d8
	dc.b	$da,$dc,$de,$e0,$e2,$e4,$e6,$e8
	dc.b	$ea,$eb,$ed,$ee,$f0,$f1,$f3,$f4
	dc.b	$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fc
	dc.b	$fc,$fd,$fd,$fe,$fe,$fe,$fe,$fe

BB:	dc.w	0

BAR:	dc.w	$001,$014,$047,$07a,$047,$014,$001
	dc.w	$100,$410,$740,$a70,$740,$410,$100
	dc.w	$001,$104,$407,$70a,$407,$104,$001
	dc.w	$100,$401,$704,$a07,$704,$401,$100
END:
