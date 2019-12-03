	org	$40000
	load	$40000
s:
	move.l	$80,OldTrap		; Save old Trap #0
	move.l	#NewTrap,$80		; New Trap #0
	
	trap	#0

	move.l	OldTrap,$80		; Get back old Trap #0
	rts

OldTrap:	dc.l	0

NewTrap:
	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#$7fff,d0
	move.w	#$8000,d1

	move.w	$dff01c,OldInt		; Get old interrupts

	move.w	d0,$dff09a		; Shut off all interrupts
	or.w	d1,OldInt

	move.l	$68,OldLevel2		; Save old Level 2 Int.
	move.l	#NewLevel2,$68		; New Level 2 Int.

	move.w	#$c008,$dff09a		; Enable Level 2 Int.

MainLoop:
	btst	#6,$bfe001
	bne.s	MainLoop

	move.w	#$7fff,$dff09a		; Shut off all interrupts
	
	move.l	OldLevel2,$68		; Get back old Level 2 Int.

	move.w	OldInt,$dff09a		; Enable old interrupts

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rte

OldInt:		dc.w	0
OldLevel2:	dc.l	0

NewLevel2:
	movem.l	d0-d7/a0-a6,-(a7)

	btst	#3,$dff01f		; Request for Level 2?
	beq.s	NoRequest

	bsr.s	Get_RAW_Key

NoRequest:
	move.w	#$8,$dff09c		; Request has been served
	movem.l	(a7)+,d0-d7/a0-a6
	rte

Get_RAW_Key:
	moveq	#0,d0
	move.b	$bfed01,d0		; CIAA ICR => 0 when read
	move.b	$bfec01,d0		; Read keyboard
	move.b	#$d0,$bfee01		

	moveq	#$50,d1
Delay:	dbf	d1,Delay

	ror.b	#1,d0			; Convert RAW key to
	not.b	d0			; correct keycodes

	move.b	d0,Key

	move.b	#$90,$bfee01
	rts

Key:		dc.b	0
