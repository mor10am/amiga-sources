;------------------------------------------------------------------------------
; MEMORY USAGE V1.01                                         mortena@ifi.uio.no
; by Morten Amundsen                                                22-Feb-1993
;------------------------------------------------------------------------------

EXECBASE:		equ	4
NULL:			equ	0

STACK_SIZE:		equ	4096

;------------------------------------------------------------------------------
;	MACROS
;------------------------------------------------------------------------------

; "CALL A LIBRARY FUNCTION"
; Result = CALL(LibraryOffset,LibraryBase)

CALL:		MACRO
		move.l	a6,-(a7)
		move.l	\2,a6				; LibraryBase
		jsr	_LVO\1(a6)			; LibraryOffset
		move.l	(a7)+,a6
		ENDM

;------------------------------------------------------------------------------

; "OPEN A LIBRARY"
; LibraryBase = OPENLIB(LibraryNamePointer,LibraryVersion,LibraryBase)

OPENLIB:	MACRO
		lea	\1,a1				; LibraryNamePointer
		move.l	\2,d0				; LibraryVersion
		CALL	OpenLibrary,EXECBASE
		move.l	d0,\3				; LibraryBase
		ENDM

;------------------------------------------------------------------------------

; "CLOSE A LIBRARY"
; CLOSELIB(LibraryBase)

CLOSELIB:	MACRO					; CLOSELIBRARY
		move.l	\1,a1				; LibraryBase
		CALL	CloseLibrary,EXECBASE
		ENDM
	
;------------------------------------------------------------------------------

	incdir	"RAM:"
	include	"LVOoffsets.s"

	incdir	"INCLUDE:"
	include	"intuition/intuition.i"
	include	"exec/memory.i"
	include	"exec/tasks.i"
	include	"devices/timer.i"

;------------------------------------------------------------------------------
;	PROGRAM START
;------------------------------------------------------------------------------

	section	PROGRAM,code

S:	jmp	STARTPROG

	dc.b	"  MemoryUsage v1.01 by PUSHEAD (mortena@ifi.uio.no) "	
	even

STARTPROG:
	movem.l	d0-d7/a0-a6,-(a7)

	lea	MY_TASKNAME,a1
	CALL	FindTask,EXECBASE

	tst.l	d0
	bne.w	EXITPRG

	OPENLIB	DOSNAME,NULL,DOSBASE
	beq.w	EXITPRG
	OPENLIB	INTNAME,NULL,INTBASE
	beq.w	EXITPRG

	move.l	#nw_SIZE,d0				; Allocate memory
	move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1		; for NewWindow
	CALL	AllocMem,EXECBASE			; Structure

	move.l	d0,MY_NEWWINDOW
	beq.w	EXITPRG

	bsr.w	INITWINDOW
	move.l	MY_NEWWINDOW,a0
	CALL	OpenWindow,INTBASE

	move.l	d0,MY_WINDOW
	beq.w	EXITPRG

	move.l	d0,a0
	move.l	wd_RPort(a0),MY_RASTPORT
	move.l	wd_UserPort(a0),MY_USERPORT

	move.l	#STACK_SIZE,d0
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	CALL	AllocMem,EXECBASE

	move.l	d0,STACKPTR
	beq.w	EXITPRG

	move.l	#TC_SIZE,d0
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	CALL	AllocMem,EXECBASE
	
	move.l	d0,MY_TASK
	beq.w	EXITPRG

	move.l	MY_TASK,a0
	move.b	#NT_TASK,LN_TYPE(a0)
	move.l	#MY_TASKNAME,LN_NAME(a0)
	move.l	STACKPTR,TC_SPLOWER(a0)
	move.l	STACKPTR,d0
	add.l	#STACK_SIZE,d0
	move.l	d0,TC_SPUPPER(a0)
	move.l	d0,TC_SPREG(a0)

	move.l	MY_TASK,a1
	move.l	#WRITEMEMORY,a2
	sub.l	a3,a3
	CALL	AddTask,EXECBASE

	move.l	MY_TASK,a1
	moveq	#-50,d0
	CALL	SetTaskPri,EXECBASE

	bsr.w	GETMEMORYUSAGE

USERLOOP:
	tst.w	ENDFLAG
	bne.s	EXITPRG

	move.l	MY_USERPORT,a0
	CALL	WaitPort,EXECBASE

MESSAGELOOP:
	move.l	MY_USERPORT,a0
	CALL	GetMsg,EXECBASE

	move.l	d0,MY_MESSAGE
	beq.s	USERLOOP

	move.l	d0,a0
	move.l	im_Class(a0),d0

	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	REPLYMESSAGE

	move.w	#1,ENDFLAG

REPLYMESSAGE:
	move.l	MY_MESSAGE,a1
	CALL	ReplyMsg,EXECBASE
	bra.s	MESSAGELOOP

EXITPRG:
	bsr.s	CLEANUP

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;------------------------------------------------------------------------------
;	CLEANUP SUB-ROUTINES
;------------------------------------------------------------------------------

CLEANUP:
	bsr.s	CLOSEMYTASK
	bsr.s	CLSTASKMEM
	bsr.s	CLOSESTACK
	bsr.w	CLOSEWIN
	bsr.w	CLOSEWINMEM
	bsr.w	CLOSEINT
	bsr.s	CLOSEDOS
NOTOPEN:
	rts

;------------------------------------------------------------------------------

CLOSEMYTASK:
	tst.l	MY_TASK
	beq.s	NOTOPEN

	bsr.w	TASKTERMINATE
	rts

REMOVETASK:
	tst.l	MY_TASK
	beq.s	NOTOPEN

	move.l	MY_TASK,a1
	CALL	RemTask,EXECBASE
	rts

CLSTASKMEM:
	tst.l	MY_TASK
	beq.s	NOTOPEN

	move.l	#TC_SIZE,d0
	move.l	MY_TASK,a1
	CALL	FreeMem,EXECBASE
	rts

CLOSESTACK:
	tst.l	STACKPTR
	beq.s	NOTOPEN

	move.l	#STACK_SIZE,d0
	move.l	STACKPTR,a1
	CALL	FreeMem,EXECBASE
	rts

;------------------------------------------------------------------------------

CLOSEDOS:
	tst.l	DOSBASE
	beq.s	NOTOPEN

	CLOSELIB DOSBASE
	rts

CLOSEINT:
	tst.l	INTBASE
	beq.w	NOTOPEN

	CLOSELIB INTBASE
	rts

;------------------------------------------------------------------------------

CLOSEPRT:
	move.l	#PORTNAME,a1
	CALL	FindPort,EXECBASE
	tst.l	d0
	beq.w	NOTOPEN

	move.l	d0,a1
	CALL	RemPort,EXECBASE
	rts

CLOSESIG:
	tst.l	MYSIGNAL
	bmi.w	NOTOPEN

	move.l	MYSIGNAL,d0
	CALL	FreeSignal,EXECBASE
	rts

CLOSEDEV:
	tst.l	ERROR
	bne.w	NOTOPEN

	lea	TIMERREQUEST,a1
	CALL	CloseDevice,EXECBASE
	rts

;------------------------------------------------------------------------------

CLOSEWIN:
	tst.l	MY_WINDOW
	beq.w	NOTOPEN

	move.l	MY_WINDOW,a0
	CALL	CloseWindow,INTBASE
	rts

CLOSEWINMEM:
	tst.l	MY_NEWWINDOW
	beq.w	NOTOPEN

	move.l	MY_NEWWINDOW,a1
	move.l	#nw_SIZE,d0
	CALL	FreeMem,EXECBASE
	rts


;------------------------------------------------------------------------------
;	MEMORY TASK
;------------------------------------------------------------------------------

TASKTERMINATE:
	bsr.w	CLOSEPRT
	bsr.w	CLOSESIG
	bsr.s	CLOSEDEV
	bsr.w	REMOVETASK
	clr.l	MY_TASK
	rts

WRITEMEMORY:
	sub.l	a1,a1
	CALL	FindTask,EXECBASE
	move.l	d0,THISTASK

	moveq	#-1,d0
	CALL	AllocSignal,EXECBASE
	move.l	d0,MYSIGNAL
	bmi.w	EXITPRG

	lea	TIMEPORT,a1
	move.l	#PORTNAME,LN_NAME(a1)
	move.b	#0,LN_PRI(a1)
	move.b	#NT_MSGPORT,LN_TYPE(a1)
	move.b	#PA_SIGNAL,MP_FLAGS(a1)
	move.b	d0,MP_SIGBIT(a1)
	move.l	THISTASK,MP_SIGTASK(a1)
	CALL	AddPort,EXECBASE

	lea	TIMERREQUEST,a1
	move.b	#NT_MESSAGE,LN_TYPE(a1)
	move.l	#TIMEPORT,MN_REPLYPORT(a1)

	lea	TIMNAME,a0
	move.l	#UNIT_VBLANK,d0
	lea	TIMERREQUEST,a1
	moveq	#0,d1
	CALL	OpenDevice,EXECBASE

	move.l	d0,ERROR
	bne.w	EXITPRG

TIMERLOOP:
	lea	TIMERREQUEST,a1
	move.l	#TIMEPORT,MN_REPLYPORT(a1)
	move.w	#MN_SIZE,MN_LENGTH(a1)
	move.w	#TR_ADDREQUEST,IO_COMMAND(a1)
	lea	TIMEVALUES,a0
	move.l	#2,TV_SECS(a0)
	move.l	#0,TV_MICRO(a0)
	CALL	DoIO,EXECBASE

	bsr.w	GETMEMORYUSAGE
	bra.s	TIMERLOOP

NOTASK:
	rts

;-----------------------------------------------------------------------------

GETMEMORYUSAGE:
	move.l	#MEMF_PUBLIC,d1
	CALL	AvailMem,EXECBASE

	cmp.l	MY_LASTMEMORY,d0
	beq.s	DONEMEMORY

	move.l	d0,MY_LASTMEMORY

	bsr.s	HEXDEC

	move.l	MY_WINDOW,a0
	lea	MY_MEMTEXT,a1
	sub.l	a2,a2
	CALL	SetWindowTitles,INTBASE

DONEMEMORY:
	rts

HEXDEC:
	lea	MY_MEMORY+9,a0

	moveq	#0,d1	
	moveq	#0,d2

	divu	#10000,d0
	move.w	d0,d1
	clr.w	d0
	swap	d0

	move.w	#3,d7
DEC1:
	bsr.s	DECIMAL
	move.b	d2,-(a0)
	dbf	d7,DEC1

	moveq	#0,d0
	move.w	d1,d0

	move.w	#4,d7
DEC2:
	bsr.s	DECIMAL
	move.b	d2,-(a0)
	dbf	d7,DEC2

	lea	MY_MEMORY,a0
STRIP:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#'0',d0
	bne.s	DONEDEC

	move.b	#' ',-1(a0)
	bra.s	STRIP

DONEDEC:
	rts

DECIMAL:
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,d2
	clr.w	d0
	swap	d0
	rts	

;------------------------------------------------------------------------------
;	DIFFERENT KIND OF INITIALIZATIONS
;------------------------------------------------------------------------------

INITWINDOW:
	move.l	MY_NEWWINDOW,a0
	move.w	#0,nw_LeftEdge(a0)	
	move.w	#0,nw_TopEdge(a0)
	move.w	#225,nw_Width(a0)

	move.l	INTBASE,a1
	move.l	ib_ActiveScreen(a1),a1
	move.l	sc_Font(a1),a1
	move.w	ta_YSize(a1),d0
	addq.w	#2,d0
	move.w	d0,nw_Height(a0)

	move.b	#0,nw_DetailPen(a0)
	move.b	#1,nw_BlockPen(a0)
	move.l	#IDCMP_CLOSEWINDOW,nw_IDCMPFlags(a0)
	move.l	#WFLG_DRAGBAR+WFLG_CLOSEGADGET+WFLG_DEPTHGADGET,nw_Flags(a0)
	move.l	#NULL,nw_FirstGadget(a0)
	move.l	#NULL,nw_CheckMark(a0)
	move.l	#MY_MEMTEXT,nw_Title(a0)
	move.l	#NULL,nw_Screen(a0)
	move.l	#NULL,nw_BitMap(a0)
	move.w	#NULL,nw_MinWidth(a0)
	move.w	#NULL,nw_MinHeight(a0)
	move.w	#NULL,nw_MaxWidth(a0)
	move.w	#NULL,nw_MaxHeight(a0)
	move.w	#WBENCHSCREEN,nw_Type(a0)
	rts

;------------------------------------------------------------------------------
;	VARIABLES
;------------------------------------------------------------------------------

	section	VARIABLES,data_p

ERROR:			dc.l	0
DOSBASE:		dc.l	0
INTBASE:		dc.l	0
DOSNAME:		dc.b	"dos.library",0
INTNAME:		dc.b	"intuition.library",0
TIMNAME:		dc.b	"timer.device",0
			even

MYSIGNAL:		dc.l	0
THISTASK:		dc.l	0

			cnop	0,4
TIMERREQUEST:		blk.b	32,0
TIMEVALUES:		dc.b	8,0

			cnop	0,4
TIMEPORT:		blk.b	34,0

PORTNAME:		dc.b	"MU_PORT",0

ENDFLAG:		dc.w	0
STACKPTR:		dc.l	0

MY_TASK:		dc.l	0
MY_USERPORT:		dc.l	0
MY_MESSAGE:		dc.l	0

MY_RASTPORT:		dc.l	0
MY_WINDOW:		dc.l	0
MY_NEWWINDOW:		dc.l	0

MY_LASTMEMORY:		dc.l	0

MY_ITEXT:
			dc.b	1,0
			dc.b	0,0
			dc.w	6,11
			dc.l	NULL
			dc.l	MY_MEMTEXT
			dc.l	NULL

MY_MEMTEXT:		dc.b	"Memory: "
MY_MEMORY:		dc.b	"000000000",0
			even

MY_TASKNAME:		dc.b	"MemUsage v1.0",0
