; Note that this code won't work as-is, but you'll have to put the pieces in
; where you want them in your program... init, cleanup and handler-code.
; NOTE: the "EventIO" could be made with CreateIORequest, but I've made it
; manually...

UnChain	= 1				; unchain input stream? (1 = yes!)

;-----------------
; init Input handler
;-----------------

	CALL	CreateMsgPort,_ExecBase
	move.l	d0,_EventPort
	beq.w	EXITPRG

	move.l	d0,a1
	move.l	#IPortName,LN_NAME(a1)
	CALL	AddPort,_ExecBase

	lea	EventIO,a0
	move.b	#NT_MESSAGE,LN_TYPE(a0)
	move.w	#IOSTD_SIZE,MN_LENGTH(a0)
	move.l	_EventPort,MN_REPLYPORT(a0)

	lea	InputName,a0
	moveq	#0,d0
	lea	EventIO,a1
	moveq	#0,d1
	move.l	_EventPort,MN_REPLYPORT(a1)
	CALL	OpenDevice,_ExecBase

	bsr.w	ADD_INPUT_HANDLER

;---------------------------------------------------------------------
; remove input-handler from system
;---------------------------------------------------------------------

	bsr.w	REMOVE_INPUT

;-----------------------------------------------------------------------------

REMOVE_INPUT:
	tst.b	INP
	beq.s	REM_IPORT

	bsr.w	REM_INPUT_HANDLER

	lea	EventIO,a1
	CALL	CloseDevice,_ExecBase

REM_IPORT:
	tst.l	_EventPort
	beq.s	.NOT

	move.l	_EventPort,a1
	CALL	RemPort,_ExecBase

	move.l	_EventPort,a0
	CALL	DeleteMsgPort,_ExecBase
.NOT:	rts

REM_INPUT_HANDLER:
	lea	EventIO,a1
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	move.l	#MyHandler,IO_DATA(a1)
	CALL	DoIO,_ExecBase
	clr.b	INP
	rts

ADD_INPUT_HANDLER:
	lea	EventIO,a1
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	move.l	#MyHandler,IO_DATA(a1)
	CALL	DoIO,_ExecBase
	move.b	#1,INP
	rts

;------------------------------------------------------------------------------
; the input-handler itself...
;------------------------------------------------------------------------------

HANDLERCODE:
	move.l	a2,-(a7)

PROCESSNEXT:
	sub.l	a2,a2
	move.l	a0,a1
	
	moveq	#0,d0
	move.b	ie_Class(a1),d0

	cmp.b	#IECLASS_RAWKEY,d0
	beq.w	RAWKEY_EVENT
	cmp.b	#IECLASS_RAWMOUSE,d0
	beq.s	RAWMOUSE_EVENT

	move.l	a1,a2

NEXTEVENT:
	move.l	(a1),a1
	move.l	a1,d0
	bne.s	PROCESSNEXT

NOHANDLE:
	move.l	a0,d0
	move.l	(a7)+,a2

EXIT_HANDLER:
	rts

	IF	Unchain
UNCHAIN:
	move.l	a2,d0
	bne.s	UNCHAIN2
	move.l	(a1),a0
	rts

UNCHAIN2:
	move.l	(a1),(a2)
	rts
	ENDIF

RAWMOUSE_EVENT:
	IF	Unchain
	bsr.s	UNCHAIN
	ENDIF

; handle mouse-event here, a1=IntuiMessage

	bra.s	NEXTEVENT

;------------------------------------------------------------------------------

RAWKEY_EVENT:
	IF	Unchain
	bsr.s	UNCHAIN
	ENDIF

; handle key-stroke here, a1=IntuiMessage

	bra.w	NEXTEVENT

;------------------------------------------------------------------------------
; data area
;------------------------------------------------------------------------------

InputName:		dc.b	"input.device",0
			even

;-------------------------
; Input Handler Data
;-------------------------

INP:			dc.b	0			; has input-handler...
			even

EventIO:		blk.b	IOSTD_SIZE,0
_EventPort:		dc.l	0

MyHandler:		dc.l	0,0
			dc.b	0,64
			dc.l	HandlerName
			dc.l	0
			dc.l	HANDLERCODE

HandlerName:		dc.b	"INIT_INPUTHANDLER",0
IPortName:		dc.b	"INIT_INPUTPORT",0
			even
