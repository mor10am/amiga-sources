;--------------------------------------------------------------------
; Animation Sequence Editor
; by Morten Amundsen
;
; Programmed in PhxAss V4.25, Copyright (C) Frank Wille 1991-1995
;--------------------------------------------------------------------
;
; Torsdag, 30. November 1995, kl. 15:06
;
;	- Program will require AmigaOS V39+ and MC68020+
;
; Søndag,  3. Desember 1995, kl. 18:21
;
;	- Handling of window signals (mainloop)
;	- Open/Close windows (plus rendering of bevelboxes and texts)
;	- Create/Free gadgets (plus font sensitive layout)
;
; Mandag,  4. Desember 1995, kl. 22:28
;
;	- Started work on GUI + plus some small subroutines
;
; Fredag,  8. Desember 1995, kl. 00:01
;
;	- Remade the window-handling, from a table of windows to
;	  a linked list.
;	- When a window is closed, it will remember it's last position
;	  the next time it pops up.
;	- All control windows will have a system allocated IDCMP port,
;	  while all Stamp-windows will be given a shared port.
;
; Søndag, 17. Desember 1995, kl. 00:57
;
;	- Started working on subroutines for the "Add File or Sequence..."
;	  window.
;
; Mandag, 18. Desember 1995, kl. 02:33
;
;	- GUI for "Files & Sequences", "Add File or Sequence..." and
;	  "Insert File or Sequence..." are now finished (layout+render).
;
; Tirsdag, 19. Desember 1995, kl. 00:53
;
;	- It is now possible to add a file (no sequences yet). These
;	  files will be shown in the "Files & Sequences" listview.
;	  When selected, the "Insert..." gadget will be enabled.
;
;--------------------------------------------------------------------

	MACHINE	68020

OSVERSION:	equ	39			; kick version

;--------------------------------------------------------------------

NAME:	MACRO
	dc.b	"ASE"
	ENDM

VER:	MACRO
	dc.b	"1"
	ENDM

REV:	MACRO
	dc.b	"0"
	ENDM

DATE:	MACRO
	dc.b	"(29.11.95)"
	ENDM

VERSTR:	MACRO
	dc.b	"$VER: "
	NAME
	dc.b	" "
	VER
	dc.b	"."
	REV
	dc.b	" "
	DATE
	dc.b	10,13,0
	ENDM

;--------------------------------------------------------------------

	include	"misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"exec/execbase.i"
	include	"exec/memory.i"
	include	"dos/dosextens.i"
	include	"graphics/gfxbase.i"
	include	"graphics/text.i"
	include	"intuition/intuition.i"
	include	"libraries/gadtools.i"
	include	"libraries/asl.i"

;--------------------------------------------------------------------
; string=TOUPPER(string)
;   d0           ax
;--------------------------------------------------------------------

TOUPPER:	MACRO
		move.l	\1,d1
		beq.s	\@TO2

\@TO1:		move.b	(\1),d0
		beq.s	\@TO2

		cmp.b	#'a',d0
		blo.s	\@TO3
		cmp.b	#'z',d0
		bhi.s	\@TO3

		sub.b	#'a'-'A',d0

\@TO3:		move.b	d0,(\1)+
		bra.s	\@TO1

\@TO2:		move.l	d1,d0
		ENDM

;--------------------------------------------------------------------
; dest=STRCPY(source,dest)
;  d0           ax     ax
;--------------------------------------------------------------------

STRCPY:		MACRO

		move.l	\2,d1
		beq.s	\@SC2

\@SC1:		move.b	(\1)+,(\2)+
		bne.s	\@SC1
		
\@SC2:		move.l	d1,d0
		ENDM

;--------------------------------------------------------------------
; result=STRCMP(source,dest)
;   d0            ax    ax
;--------------------------------------------------------------------

STRCMP:		MACRO

		moveq	#0,d0

\@SP1:		move.b	(\1)+,d1
		move.b	(\2)+,d2

		cmp.b	d1,d2
		bne.s	\@SP2

		tst.b	d1
		bne.s	\@SP1
		bra.s	\@SP3

\@SP2:		moveq	#1,d0
\@SP3:
		ENDM

;--------------------------------------------------------------------
; length=STRLEN(string)
;   d0            ax
;--------------------------------------------------------------------

STRLEN:		MACRO

		moveq	#0,d0

		cmp.l	#NULL,\1
		beq.s	\@SL1

\@SL2:		tst.b	(\1)+
		beq.s	\@SL1
		addq.l	#1,d0
		bra.s	\@SL2

\@SL1:	
		ENDM

;--------------------------------------------------------------------
; GUI layout constants

MAGIC:		equ	5
BEVBORDER:	equ	2*MAGIC
GUISPACE:	equ	2
SEPHEIGHT:	equ	2

;--------------------------------------------------------------------

MAXNAME:	equ	64		; max length of names

;--------------------------------------------------------------------
; File/Sequence structure
;--------------------------------------------------------------------

; name of file or sequence will be located in LN_NAME

 STRUCTURE	fseq,0
	STRUCT	fseq_Node,LN_SIZE
	APTR	fseq_Path		; path of file or sequence
	STRUCT	fseq_SeqList,MLH_SIZE	; list of frames in sequence
	ULONG	fseq_Entries		; entries=0 for single file
	ULONG	fseq_Start		; lowest number of sequence
	LABEL	fseq_SIZEOF

; types (LN_TYPE of 'fseq'-structure)

FSEQID_FILE:	equ	0		; entry is file
FSEQID_SEQ:	equ	1		; ---"---- sequence

;--------------------------------------------------------------------
; window IDs
;--------------------------------------------------------------------

TYPE_CTRL:	equ	0	; ASE system control window
TYPE_STAMP:	equ	1	; File/Sequence/Anim stamp window

 STRUCTURE	ase,0
	STRUCT	ase_Node,LN_SIZE
	APTR	ase_WindowTags	; Taglist for new window
	APTR	ase_Window	; ptr to already opened window
	ULONG	ase_WindowWidth
	ULONG	ase_WindowHeight
	APTR	ase_RastPort
	APTR	ase_UserPort
	APTR	ase_Message
	ULONG	ase_SigSet
	APTR	ase_Gad		; gadget context
	APTR	ase_NewGadgets	; list of gadgetstructs for this window
	APTR	ase_GadgetTags	; list of taglists
	APTR	ase_GadgetTypes	; list of gadgettypes
	APTR	ase_GadList	; list of created gadgets
	UWORD	ase_UpdFlag	; update GUI fields (0 = update)
	UWORD	ase_ReCalc	; recalc GUI layout (0 = calc new layout)
	APTR	ase_Layout	; subroutine to layout gadgets etc.
	APTR	ase_Render	; subroutine to render bevelbox and texts etc.
	APTR	ase_Update	; subroutine to update misc. stuff in GUI
	APTR	ase_IDCMP	; subroutine to IDCMP handler
	LABEL	ase_SIZEOF

;--------------------------------------------------------------------
; bevelbox struct
;--------------------------------------------------------------------

 STRUCTURE	bev,0
	UWORD	bev_topedge
	UWORD	bev_leftedge
	UWORD	bev_width
	UWORD	bev_height
	LABEL	bev_SIZEOF

;--------------------------------------------------------------------
;
;             FGUI
;            /    \
;        FAGUI    FIGUI
;
;--------------------------------------------------------------------
; "Files & Sequences" GUI gadgets

FGAD_FSEQLIST:	equ	0		; files and sequences listview
FGAD_SELFSEQ:	equ	1		; selected file or sequence name
FGAD_ADDFSEQ:	equ	2		; add file or sequence to list
FGAD_DELFSEQ:	equ	3		; delete file or sequence from list
FGAD_INSFSEQ:	equ	4		; insert file or sequence in anim
FGAD_NOGADS:	equ	5

;--------------------------------------------------------------------
; "Add File or Sequence..." GUI gadgets

FAGAD_FSEQ:	equ	0		; add either file or sequence
FAGAD_GETFILE:	equ	1		; get filename button (filereq)
FAGAD_FILENAME:	equ	2		; name of file to add
FAGAD_GETPATH:	equ	3		; get sequence path button
FAGAD_PATHNAME:	equ	4		; name of sequence path
FAGAD_PATTERN:	equ	5		; sequence pattern
FAGAD_RANGE:	equ	6		; range of sequence
FAGAD_GETRANGE:	equ	7		; get range button
FAGAD_SEQNAME:	equ	8		; user defined name of sequence
FAGAD_ADD:	equ	9		; add file or sequence to list
FAGAD_CANCEL:	equ	10		; cancel operation
FAGAD_NOGADS:	equ	11

;--------------------------------------------------------------------
; "Insert File or Sequence..." GUI gadgets

FIGAD_FSEQ:	equ	0		; name of file/sequence to insert
FIGAD_PART:	equ	1		; insert whole or part of sequence
FIGAD_SEQSTART:	equ	2		; part of sequence start
FIGAD_SSNUM:	equ	3		; display start number
FIGAD_SEQEND:	equ	4		; part of sequence end
FIGAD_SENUM:	equ	5		; display end number
FIGAD_INSPOS:	equ	6		; pos in anim to insert file/seq
FIGAD_AFTER:	equ	7		; after pos slider
FIGAD_AFTERNUM:	equ	8		; after pos number display
FIGAD_INSREV:	equ	9		; insert sequence reversed
FIGAD_INSERT:	equ	10		; insert file/sequence into anim
FIGAD_CANCEL:	equ	11		; cancel insert operation
FIGAD_NOGADS:	equ	12

;--------------------------------------------------------------------
; error codes
;--------------------------------------------------------------------

ERR_NOERR:	equ	0
ERR_CPU:	equ	1
ERR_MEM:	equ	2

;--------------------------------------------------------------------

	XDEF	_main
	XDEF	_DOSBase
	XDEF	_GfxBase
	XDEF	_IntuitionBase
	XDEF	_GadToolsBase
	XDEF	_AslBase

_main:	movem.l	d0-d7/a0-a6,-(a7)

;--------------------------------------------------------------------
; Is program being runned from icon?
;--------------------------------------------------------------------

	sub.l	a1,a1
	EXEC	FindTask
	move.l	d0,a4

	moveq	#0,d0

	tst.l	pr_CLI(a4)
	bne.s	.CLI

	lea	pr_MsgPort(a4),a0
	EXEC	WaitPort
	lea	pr_MsgPort(a4),a0
	EXEC	GetMsg
.CLI:	move.l	d0,_WBMsg

;--------------------------------------------------------------------
; open libraries
;--------------------------------------------------------------------

	move.l	#0,ErrorCode

	OPENLIB	DOSName,OSVERSION,_DOSBase
	beq.s	EXIT
	OPENLIB	GfxName,OSVERSION,_GfxBase
	beq.s	EXIT
	OPENLIB	IntuitionName,OSVERSION,_IntuitionBase
	beq.s	EXIT
	OPENLIB	GadToolsName,OSVERSION,_GadToolsBase
	beq.s	EXIT
	OPENLIB AslName,OSVERSION,_AslBase
	beq.s	EXIT

;--------------------------------------------------------------------
; check if machine is equipped with MC68020+
;--------------------------------------------------------------------

	move.l	4.w,a0
	move.w	AttnFlags(a0),d0
	move.l	#ERR_CPU,ErrorCode
	btst	#AFB_68020,d0
	beq	EXIT

;--------------------------------------------------------------------
; get font sizes etc. (calc gadget height)
;--------------------------------------------------------------------

	lea	TopazAttr,a0			; open topaz font
	move.l	a0,_TopazAttr
	CALL	OpenFont,_GfxBase
	move.l	d0,_TopazFont

	sub.l	a0,a0
	CALL	LockPubScreen,_IntuitionBase	; lock pubscreen, so we can
	move.l	d0,_Screen			; get screen data
	beq.s	CLEAN

	move.l	d0,a0

	moveq	#0,d0
	move.b	sc_BarHeight(a0),d0
	move.w	d0,TitleHeight			; Titlebar height

	move.b	sc_WBorLeft(a0),d0
	move.w	d0,WBorderWidth			; window border (left)
	move.b	sc_WBorBottom(a0),d0
	move.w	d0,WBorderBottom

	move.l	sc_Font(a0),a0			; make a copy of this shit
	move.l	a0,_ScrAttr			; some day!!!
	CALL	OpenFont,_GfxBase		; open screen font
	move.l	d0,_ScrFont

	move.l	d0,a0
	move.w	tf_YSize(a0),d0
	move.w	d0,FontHeight
	add.w	#MAGIC*2,d0
	move.w	d0,GadgetHeight
	move.w	tf_Baseline(a0),FontBHeight	; from top of font to baseline

	move.w	tf_XSize(a0),FontWidth

	move.l	_Screen,a0
	sub.l	a1,a1
	CALL	GetVisualInfoA,_GadToolsBase
	move.l	d0,_VisualInfo

	sub.l	a0,a0
	move.l	_Screen,a1
	CALL	UnlockPubScreen,_IntuitionBase

	SETTAG	#BevelTags,GT_VisualInfo,_VisualInfo
	SETTAG	#BevelRecTags,GT_VisualInfo,_VisualInfo

;--------------------------------------------------------------------
; allocate asl requesters
;--------------------------------------------------------------------

	move.l	#ERR_MEM,ErrorCode

	move.l	#ASL_FileRequest,d0
	sub.l	a0,a0
	CALL	AllocAslRequest,_AslBase
	move.l	d0,_FAGUI_FileRequest
	beq.s	EXIT

	move.l	#ASL_FileRequest,d0
	sub.l	a0,a0
	CALL	AllocAslRequest,_AslBase
	move.l	d0,_FAGUI_PathRequest
	beq.s	EXIT

;--------------------------------------------------------------------
; init window structures and open control windows
;--------------------------------------------------------------------

	lea	FSeqList,a0
	NEWLIST	a0

	bsr	INIT_WINDOWS		; init window/gadget structures
	move.l	#ERR_MEM,ErrorCode
	beq	EXIT

	lea	FGUI_Title,a0
	bsr	OPEN_GUI		; open "Files & Sequences" GUI window
	beq	CLEAN

;--------------------------------------------------------------------

	move.l	#0,ErrorCode

MAIN_LOOP:
	tst.w	ExitFlag		; check if we should exit prg
	bne	EXIT

	move.l	#SIGBREAKF_CTRL_C,d0	; always check ^C

	lea	WindowList,a0		; list of defined windows
.LOOP:	TSTNODE	a0,a1
	beq.s	.WAIT

	or.l	ase_SigSet(a1),d0	; window signals to Wait() for...
	move.l	a1,a0
	bra.s	.LOOP

.WAIT:	EXEC	Wait			; wait for signals
	move.l	d0,d1

	and.l	#SIGBREAKF_CTRL_C,d1	; was ^C pressed?
	beq.s	NO_CTRL_C

	move.w	#1,ExitFlag		; yes, exit!

NO_CTRL_C:
	lea	WindowList,a0
IDCMP_LOOP:
	TSTNODE	a0,a1
	beq.s	MAIN_LOOP

	move.l	d0,d1

	and.l	ase_SigSet(a1),d1	; check which window got the signal
	beq	IDCMP_NEXT

	movem.l	d0/d7/a0/a1,-(a7)
	move.l	a1,a5

MSG_LOOP:
	move.l	ase_UserPort(a5),a0
	cmp.l	#NULL,a0
	beq.s	MSG_DONE

	CALL	GT_GetIMsg,_GadToolsBase
	move.l	d0,ase_Message(a5)	; get message from window
	beq.s	MSG_DONE

	move.l	ase_IDCMP(a5),a2	; if "this" window gave a signal,
	cmp.l	#NULL,a2		; branch to its IDCMP handler (if any)
	beq.s	MSG_NEXT

	move.l	a5,-(a7)
	jsr	(a2)			; jsr to the IDCMP handler
					; d0 = IntuiMessage
					; a5 = ASE structure
	move.l	(a7)+,a5

MSG_NEXT:
	move.l	ase_Message(a5),a1	; reply to message if hasn't already
	cmp.l	#NULL,a1		; been replied to
	beq.s	MSG_LOOP
	
	CALL	GT_ReplyIMsg,_GadToolsBase
	move.l	#0,ase_Message(a5)
	bra.s	MSG_LOOP

MSG_DONE:
	movem.l	(a7)+,d0/d7/a0/a1

IDCMP_NEXT:
	move.l	a1,a0			; check next window in linked list
	bra.s	IDCMP_LOOP

;--------------------------------------------------------------------
; program exit
;--------------------------------------------------------------------

CLEAN:	move.l	#0,ErrorCode		; exit with no error

EXIT:	tst.l	ErrorCode
	beq.s	OK_EXIT

	tst.l	_DOSBase
	beq	OK_EXIT

	move.l	ErrorCode,d0
	subq.w	#1,d0
	lea	ErrPtrs,a0
	move.l	(a0,d0.w*4),d1
	CALL	PutStr,_DOSBase		; print errror-code text

	move.l	#LFTxt,d1
	CALL	PutStr,_DOSBase

;--------------------------------------------------------------------

OK_EXIT:
	bsr.w	CLOSE_WINDOWS
	bsr.w	FREE_FONTS
	bsr.w	FREE_VISUALINFO

	bsr.w	FREE_FAGUI_FREQ
	bsr.w	FREE_FAGUI_SREQ

	bsr.w	FREE_FSEQLIST

	bsr.w	CLOSEDOS
	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT
	bsr.w	CLOSEGAD
	bsr.w	CLOSEASL

	tst.l	_WBMsg
	beq.s	.OUT

	EXEC	Forbid
	move.l	_WBMsg,a1
	EXEC	ReplyMsg
	EXEC	Permit

.OUT:	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;--------------------------------------------------------------------

CLOSEDOS:
	tst.l	_DOSBase
	beq.s	.NOT

	CLOSELIB _DOSBase
.NOT:	rts

CLOSEGFX:
	tst.l	_GfxBase
	beq.s	.NOT

	CLOSELIB _GfxBase
.NOT:	rts

CLOSEINT:
	tst.l	_IntuitionBase
	beq.s	.NOT

	CLOSELIB _IntuitionBase
.NOT:	rts

CLOSEGAD:
	tst.l	_GadToolsBase
	beq.s	.NOT

	CLOSELIB _GadToolsBase
.NOT:	rts

CLOSEASL:
	tst.l	_AslBase
	beq.s	.NOT

	CLOSELIB _AslBase
.NOT:	rts

;--------------------------------------------------------------------

FREE_FAGUI_FREQ:
	tst.l	_FAGUI_FileRequest
	beq.s	.NOT

	move.l	_FAGUI_FileRequest,a0
	CALL	FreeAslRequest,_AslBase
.NOT:	rts

FREE_FAGUI_SREQ:
	tst.l	_FAGUI_PathRequest
	beq.s	.NOT

	move.l	_FAGUI_PathRequest,a0
	CALL	FreeAslRequest,_AslBase
.NOT:	rts

;--------------------------------------------------------------------

FREE_FSEQLIST:

.LOOP:	lea	FSeqList,a0
	TSTLIST	a0
	beq.s	.DONE

	move.l	MLH_HEAD(a0),a1

	bsr.w	REM_FSEQNODE

	bra.s	.LOOP
.DONE:	rts

REM_FSEQNODE:					; a1 = node
	move.l	a1,a4

	REMOVE

	move.l	LN_NAME(a4),a1			; file name
	cmp.l	#NULL,a1
	beq.s	.N1

	EXEC	FreeVec

.N1:	move.l	fseq_Path(a4),a1		; path name
	cmp.l	#NULL,a1
	beq.s	.N2

	EXEC	FreeVec

.N2:	move.l	a4,a1
	EXEC	FreeVec
	rts

;--------------------------------------------------------------------

CLOSE_WINDOWS:
	lea	WindowList,a4			; linked list of windows
	TSTNODE	a4,a5
	beq.s	.NOT

	bsr.w	REMOVE_WINDOW			; remove & close window

	bra	CLOSE_WINDOWS
.NOT:	rts

;--------------------------------------------------------------------

REMOVE_WINDOW:
	move.l	a5,a1				; remove window node
	REMOVE

	bsr	CLOSE_GUI			; close window
						; a5=ASE structure

	move.l	LN_NAME(a5),a1
	cmp.l	#NULL,a1
	beq.s	.NOT1

	EXEC	FreeVec				; free windowname buffer mem

.NOT1:	move.l	a5,a1
	EXEC	FreeVec				; free structure mem
	rts

;--------------------------------------------------------------------

CLOSE_GUI:
	bsr.w	EMPTY_USERPORT

	tst.l	ase_Window(a5)			; is window open?
	beq.s	FREE_GADS			; no!

	moveq	#0,d3
	moveq	#0,d4
	move.l	ase_Window(a5),a0
	move.w	wd_LeftEdge(a0),d3
	move.w	wd_TopEdge(a0),d4
	SETTAG	ase_WindowTags(a5),WA_Left,d3		; get last x/y
	SETTAG	ase_WindowTags(a5),WA_Top,d4		; position of window
							; before we close it

	move.l	ase_Window(a5),a0
	CALL	CloseWindow,_IntuitionBase
	move.l	#0,ase_Window(a5)			; reset struct values
	move.l	#0,ase_UserPort(a5)
	move.l	#0,ase_SigSet(a5)
	move.l	#0,ase_RastPort(a5)

FREE_GADS:
	tst.w	ExitFlag
	beq.s	.NFREE

.FREE:	move.l	ase_Gad(a5),a0				; gads in this window?
	cmp.l	#NULL,a0
	beq.s	.OUT

	CALL	FreeGadgets,_GadToolsBase
	move.l	#0,ase_Gad(a5)
.OUT:	rts

.NFREE:	cmp.b	#TYPE_STAMP,LN_TYPE(a5)
	beq.s	.FREE
	rts

;--------------------------------------------------------------------

EMPTY_USERPORT:
	move.l	ase_Message(a5),d0		; unreplied message?
	bne.s	.REPLY				; yes! reply

.LOOP:	move.l	ase_UserPort(a5),a0		; strip port of messages
	cmp.l	#NULL,a0			; that has not been replied
	beq.s	.DONE				; to.

	CALL	GT_GetIMsg,_GadToolsBase
	tst.l	d0
	beq.s	.DONE

.REPLY:	move.l	d0,a1
	CALL	GT_ReplyIMsg,_GadToolsBase
	move.l	#0,ase_Message(a5)
	bra.s	.LOOP

.DONE:	rts

;--------------------------------------------------------------------

FREE_FONTS:
	tst.l	_ScrFont
	beq.s	.NOT1

	move.l	_ScrFont,a1
	CALL	CloseFont,_GfxBase

.NOT1:	tst.l	_TopazFont
	beq.s	.NOT2

	move.l	_TopazFont,a1
	CALL	CloseFont,_GfxBase
.NOT2:	rts

;--------------------------------------------------------------------

FREE_VISUALINFO:
	tst.l	_VisualInfo
	beq.s	.NOT

	move.l	_VisualInfo,a0
	CALL	FreeVisualInfo,_GadToolsBase
.NOT:	rts

;--------------------------------------------------------------------
; allocate and initialize window ASE structures
;--------------------------------------------------------------------

INIT_WINDOWS:
	lea	WindowList,a0			; initialize list header
	NEWLIST	a0

; "Files & Sequences" GUI window -----------------------------------

	move.l	#ase_SIZEOF,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec			; node memory
	tst.l	d0
	beq	INIT_OUT

	lea	WindowList,a0
	move.l	d0,a1
	ADDTAIL					; add node to list

	move.l	a1,a2				; a2 = ASE node

	move.l	#MAXNAME,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,LN_NAME(a2)			; buffer for window name
	beq.s	INIT_OUT

	move.l	d0,a0
	lea	FGUI_Title,a1
	STRCPY	a1,a0				; copy window title to node

	move.b	#TYPE_CTRL,LN_TYPE(a2)		; this is a control window!

	move.l	#FGUI_Window,ase_WindowTags(a2)
	move.l	#HANDLE_FGUI,ase_IDCMP(a2)

	move.l	#FGUI_GadStructs,ase_NewGadgets(a2)
	move.l	#FGUI_GadTags,ase_GadgetTags(a2)
	move.l	#FGUI_GadTypes,ase_GadgetTypes(a2)
	move.l	#FGUI_GadgetList,ase_GadList(a2)

	move.l	#LAYOUT_FGUI,ase_Layout(a2)
	move.l	#RENDER_FGUI,ase_Render(a2)
	move.l	#UPDATE_FGUI,ase_Update(a2)

; "Add File or Sequence..." GUI window ---------------------------------

	move.l	#ase_SIZEOF,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	tst.l	d0
	beq.s	INIT_OUT

	lea	WindowList,a0
	move.l	d0,a1
	ADDTAIL

	move.l	a1,a2					; a2 = ASE node

	move.l	#MAXNAME,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,LN_NAME(a2)
	beq.s	INIT_OUT

	move.l	d0,a0
	lea	FAGUI_Title,a1
	STRCPY	a1,a0

	move.b	#TYPE_CTRL,LN_TYPE(a2)

	move.l	#FAGUI_Window,ase_WindowTags(a2)
	move.l	#HANDLE_FAGUI,ase_IDCMP(a2)

	move.l	#FAGUI_GadStructs,ase_NewGadgets(a2)
	move.l	#FAGUI_GadTags,ase_GadgetTags(a2)
	move.l	#FAGUI_GadTypes,ase_GadgetTypes(a2)
	move.l	#FAGUI_GadgetList,ase_GadList(a2)

	move.l	#LAYOUT_FAGUI,ase_Layout(a2)
	move.l	#RENDER_FAGUI,ase_Render(a2)
	move.l	#UPDATE_FAGUI,ase_Update(a2)

; "Insert File or Sequence..." GUI window ---------------------------------

	move.l	#ase_SIZEOF,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	tst.l	d0
	beq.s	INIT_OUT

	lea	WindowList,a0
	move.l	d0,a1
	ADDTAIL

	move.l	a1,a2					; a2 = ASE node

	move.l	#MAXNAME,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,LN_NAME(a2)
	beq.s	INIT_OUT

	move.l	d0,a0
	lea	FIGUI_Title,a1
	STRCPY	a1,a0

	move.b	#TYPE_CTRL,LN_TYPE(a2)

	move.l	#FIGUI_Window,ase_WindowTags(a2)
	move.l	#HANDLE_FIGUI,ase_IDCMP(a2)

	move.l	#FIGUI_GadStructs,ase_NewGadgets(a2)
	move.l	#FIGUI_GadTags,ase_GadgetTags(a2)
	move.l	#FIGUI_GadTypes,ase_GadgetTypes(a2)
	move.l	#FIGUI_GadgetList,ase_GadList(a2)

	move.l	#LAYOUT_FIGUI,ase_Layout(a2)
	move.l	#RENDER_FIGUI,ase_Render(a2)
	move.l	#UPDATE_FIGUI,ase_Update(a2)

	moveq	#1,d0
INIT_OUT:
	rts

;--------------------------------------------------------------------
; open window routine (layout and create gadgets, plus render bevel/itext)
;--------------------------------------------------------------------

OPEN_GUI:				; a0 = GUI Window Title
	lea	WindowList,a1
	TSTLIST	a1
	beq.s	NO_OPEN2

FIND_GUI_OPEN:				; check to see if a window with that
	TSTNODE	a1,a5			; name (a0) is defined.
	beq.s	NO_OPEN2

	move.l	a0,a2
	move.l	LN_NAME(a5),a3
	STRCMP	a2,a3			; compare names...
	beq.s	OPEN_THIS_GUI		; if same, open!

NEXT_GUI_OPEN:
	move.l	a5,a1
	bra.s	FIND_GUI_OPEN

OPEN_THIS_GUI:
	move.l	_ScrFont,_Font		; use screen default font
	move.l	_ScrAttr,_TextAttr	; if GUI will exceed screenheight,
					; font will be set to Topaz

	tst.l	ase_Window(a5)
	bne	OPEN_DONE		; window is already open

	tst.w	ase_ReCalc(a5)
	bne.s	NO_GADS			; recalc layout? No!

	move.l	ase_Layout(a5),a0
	cmp.l	#NULL,a0
	beq.s	.NO_LAYOUT

	tst.l	ase_Gad(a5)
	beq.s	.NFREE

	movem.l	d0/d1/a0/a1,-(a7)
	move.l	ase_Gad(a5),a0
	CALL	FreeGadgets,_GadToolsBase
	move.l	#0,ase_Gad(a5)
	movem.l	(a7)+,d0/d1/a0/a1

.NFREE:	jsr	(a0)			; layout gadgets (font sensitive)

.NO_LAYOUT:
	tst.l	ase_NewGadgets(a5)	; does this window have gadgets?
	beq.s	NO_GADS

	lea	ase_Gad(a5),a0
	CALL	CreateContext,_GadToolsBase

	move.l	ase_NewGadgets(a5),a1
	move.l	ase_GadgetTags(a5),a2
	move.l	ase_GadgetTypes(a5),a3
	move.l	ase_GadList(a5),a4

.LOOP:	move.l	d0,a0			; gadget = NULL => error!
	beq	NO_OPEN

	move.l	(a3)+,d0		; gadget type
	
	move.l	(a1)+,d1		; new gadget structure
	beq	NO_GADS			; new gad = NULL => done!

	move.l	(a2)+,d2		; taglist

	movem.l	a1/a2,-(a7)
	move.l	d1,a1
	move.l	d2,a2

	move.l	_VisualInfo,gng_VisualInfo(a1)
	move.l	_TextAttr,gng_TextAttr(a1)

	CALL	CreateGadgetA,_GadToolsBase
	movem.l	(a7)+,a1/a2

	move.l	d0,(a4)+		; set created gadget into list
	bra	.LOOP

NO_GADS:
	tst.l	ase_WindowTags(a5)
	beq	NO_OPEN			; there's no taglist defined for
					; this window

	SETTAG	ase_WindowTags(a5),WA_Gadgets,ase_Gad(a5)
	SETTAG	ase_WindowTags(a5),WA_Width,ase_WindowWidth(a5)
	SETTAG	ase_WindowTags(a5),WA_Height,ase_WindowHeight(a5)

	sub.l	a0,a0
	move.l	ase_WindowTags(a5),a1
	CALL	OpenWindowTagList,_IntuitionBase
	move.l	d0,ase_Window(a5)
	beq	NO_OPEN			; failed to open window

	move.l	d0,a0
	move.l	wd_RPort(a0),ase_RastPort(a5)
	move.l	wd_UserPort(a0),a1
	move.l	a1,ase_UserPort(a5)

	moveq	#0,d0
	move.b	MP_SIGBIT(a1),d1
	bset	d1,d0
	move.l	d0,ase_SigSet(a5)		; signal to wait for...

	move.l	ase_RastPort(a5),a1
	move.l	_Font,a0
	CALL	SetFont,_GfxBase

	tst.l	ase_Gad(a5)
	beq.s	.NOGAD

	move.l	ase_Window(a5),a0
	sub.l	a1,a1
	CALL	GT_RefreshWindow,_GadToolsBase	; refresh gadgets in window

.NOGAD:	move.l	ase_Render(a5),a0
	cmp.l	#NULL,a0
	beq.s	.NORENDER

	jsr	(a0)			; render bevelboxes and text etc.

.NORENDER:
	move.l	ase_Update(a5),a0
	cmp.l	#NULL,a0
	beq.s	OPEN_DONE

	tst.w	ase_UpdFlag(a5)
	bne.s	OPEN_DONE

	jsr	(a0)

OPEN_DONE:
	moveq	#1,d0
	rts

NO_OPEN:
	move.l	ase_Gad(a5),a0
	cmp.l	#NULL,a0
	beq.s	NO_OPEN2

	CALL	FreeGadgets,_GadToolsBase
	move.l	#0,ase_Gad(a5)
	move.w	#0,ase_ReCalc(a5)

NO_OPEN2:
	moveq	#0,d0
	rts

;--------------------------------------------------------------------
; layout FGUI
;--------------------------------------------------------------------

LAYOUT_FGUI:					; a5 = ASE structure
	movem.l	d0-d7/a0-a6,-(a7)

	moveq	#0,d0

	moveq	#0,d5				; d5 = current topedge
	move.w	TitleHeight,d5
	add.w	#MAGIC+BEVBORDER,d5

	moveq	#0,d6				; d6 = leftmost gadget position
	add.w	WBorderWidth,d6
	add.w	#MAGIC,d6
	add.w	#BEVBORDER,d6

; "Files & Sequences" listview

	lea	FGUI_FSeqS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	lea	ListViewText,a1
	bsr	CALCITEXT
	move.w	d0,gng_Width(a0)
	move.w	d0,d4				; d4 = width of listview

	move.w	FontHeight,d1
	mulu	#10,d1
	add.w	#GUISPACE*2,d1
	move.w	d1,gng_Height(a0)
	move.w	d1,d3				; d3 = height of listview
	add.w	d3,d5

; "Selected File or Sequence" text

	lea	FGUI_SelFSeqS,a0
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	d4,gng_Width(a0)
	move.w	GadgetHeight,gng_Height(a0)

; "Add File or Sequence" button

	lea	FGUI_AddFSeqS,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d4,d0
	lsr.w	#1,d0
	sub.w	#GUISPACE,d0
	move.w	d0,gng_Width(a0)

; "Delete File or Sequence" button

	lea	FGUI_DelFSeqS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	d0,gng_Width(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d6,d1
	add.w	d0,d1
	add.w	#GUISPACE*2,d1
	move.w	d1,gng_LeftEdge(a0)

; "Insert File or Sequence" button

	lea	FGUI_InsFSeqS,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	d4,gng_Width(a0)
	move.w	GadgetHeight,gng_Height(a0)

; bevelbox around gadget group

	lea	FGUI_BevelBox1,a0
	add.w	GadgetHeight,d5
	add.w	#BEVBORDER,d5

	move.w	TitleHeight,d1
	add.w	#MAGIC,d1
	move.w	d1,bev_topedge(a0)
	move.w	d6,d0
	sub.w	#BEVBORDER,d0
	move.w	d0,bev_leftedge(a0)
	move.w	d4,d0
	add.w	#BEVBORDER*2,d0
	move.w	d0,bev_width(a0)
	move.w	d5,d0
	sub.w	d1,d0
	move.w	d0,bev_height(a0)

; window height

	add.w	#MAGIC,d5
	add.w	WBorderBottom,d5
	move.l	d5,ase_WindowHeight(a5)

; window width

	move.w	WBorderWidth,d0
	add.w	d0,d0
	add.w	d0,d4
	add.w	#(BEVBORDER*2)+(MAGIC*2),d4
	move.l	d4,ase_WindowWidth(a5)

;	moveq	#0,d6				; center window on screen
;	moveq	#0,d7
;
;	move.l	_Screen,a0
;	move.w	sc_Width(a0),d6
;	move.w	sc_Height(a0),d7
;
;	sub.w	d5,d7
;	lsr.w	#1,d7
;
;	sub.w	d4,d6
;	lsr.w	#1,d6
;
;	move.l	ase_WindowTags(a5),a4
;	SETTAG	a4,WA_Left,d6
;	SETTAG	a4,WA_Top,d7

	move.w	#1,ase_ReCalc(a5)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; render FGUI
;--------------------------------------------------------------------

RENDER_FGUI:				; a5 = ASE structure
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	ase_RastPort(a5),a0
	lea	FGUI_BevelBox1,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; Update misc. stuff in "Files & Sequences" GUI
;--------------------------------------------------------------------

UPDATE_FGUI:
	movem.l	d0-d7/a0-a6,-(a7)

; update the "files & sequences" listview

	lea	FSeqList,a0
	TSTLIST	a0
	bne.s	.NOTEMPTY

	lea	FSeqList,a0
	NEWLIST	a0

.NOTEMPTY:
	move.l	ase_GadList(a5),a0
	move.l	#FGAD_FSEQLIST,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	AttachFSeqTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

; clear the text-display under the listview

	SETTAG	#FillTextTags,GTTX_Text,#NULL

	move.l	ase_GadList(a5),a0
	move.l	#FGAD_SELFSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	FillTextTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

; clear current selected file/sequence node pointer

	move.l	#NULL,_CurrFSeqNode

; disable the "Insert..." gadget

	move.l	ase_GadList(a5),a0
	move.l	#FGAD_INSFSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	DisableTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; handle FGUI IDCMP messages
;--------------------------------------------------------------------

HANDLE_FGUI:
						; d0=IntuiMessage
	move.l	d0,a0				; a5=ASE structure

	move.l	im_Class(a0),d0

	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	FGUI_NOT_CLOSEWINDOW

	move.w	#1,ExitFlag
	bra	HANDLE_FGUI_DONE

FGUI_NOT_CLOSEWINDOW:
	cmp.l	#IDCMP_GADGETUP,d0
	bne.s	FGUI_NOT_GADGETUP

	move.l	im_IAddress(a0),a1
	move.l	gg_UserData(a1),a2
	cmp.l	#NULL,a2
	beq.s	HANDLE_FGUI_DONE

; d0 = IDCMP code
; a0 = IntuiMessage
; a1 = Gadget

	jsr	(a2)
	bra.s	HANDLE_FGUI_DONE

FGUI_NOT_GADGETUP:

HANDLE_FGUI_DONE:
	rts

;--------------------------------------------------------------------
; Show selected file or sequence in text-display gadget
;--------------------------------------------------------------------

SUB_FGUI_SELECT:
	lea	FSeqList,a2
	TSTLIST	a2
	beq.s	NO_FSEQ_SEL

	move.w	im_Code(a0),d7

	lea	FSeqList,a0
.LOOP:	TSTNODE	a0,a0
	dbf	d7,.LOOP

	move.l	a0,_CurrFSeqNode		; current selected node

	move.l	LN_NAME(a0),a3
	SETTAG	#FillTextTags,GTTX_Text,a3

; fill the text-display gadget with name of file/sequence

	move.l	ase_GadList(a5),a0
	move.l	#FGAD_SELFSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	FillTextTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

; enable the "Insert..." gadget

	move.l	ase_GadList(a5),a0
	move.l	#FGAD_INSFSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	EnableTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

NO_FSEQ_SEL:
	rts

;--------------------------------------------------------------------
; Open "Add File or Sequence..." GUI Window
;--------------------------------------------------------------------

SUB_FGUI_ADD:				; a5 = ASE structure
	moveq	#0,d4
	moveq	#0,d5
	move.l	ase_Window(a5),a0
	move.w	wd_LeftEdge(a0),d4
	move.w	wd_TopEdge(a0),d5
	SETTAG	#FAGUI_Window,WA_Left,d4
	SETTAG	#FAGUI_Window,WA_Top,d5

	bsr.w	CLOSE_GUI

	lea	FAGUI_Title,a0
	bsr.w	OPEN_GUI
	rts

;--------------------------------------------------------------------
; Delete added file/sequence node from FSeq-list
;--------------------------------------------------------------------

SUB_FGUI_DEL:
	tst.l	_CurrFSeqNode
	beq.s	NO_FSEQ_DEL

	move.l	ase_GadList(a5),a0
	moveq	#FGAD_FSEQLIST,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	DetachFSeqTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	move.l	_CurrFSeqNode,a1
	bsr.w	REM_FSEQNODE

	move.l	#NULL,_CurrFSeqNode

	move.l	ase_GadList(a5),a0
	moveq	#FGAD_FSEQLIST,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	AttachFSeqTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	lea	FillTextTags,a3
	SETTAG	a3,GTTX_Text,NULL

	move.l	ase_GadList(a5),a0
	moveq	#FGAD_SELFSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	move.l	ase_GadList(a5),a0
	moveq	#FGAD_INSFSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	DisableTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

NO_FSEQ_DEL:
	rts

;--------------------------------------------------------------------
; Open "Insert File or Sequence..." GUI Window
;--------------------------------------------------------------------

SUB_FGUI_INSERT:			; a5 = ASE structure
	moveq	#0,d4
	moveq	#0,d5
	move.l	ase_Window(a5),a0
	move.w	wd_LeftEdge(a0),d4
	move.w	wd_TopEdge(a0),d5
	SETTAG	#FIGUI_Window,WA_Left,d4
	SETTAG	#FIGUI_Window,WA_Top,d5

	bsr.w	CLOSE_GUI

	lea	FIGUI_Title,a0
	bsr.w	OPEN_GUI
	rts

;--------------------------------------------------------------------
; layout FAGUI
;--------------------------------------------------------------------

LAYOUT_FAGUI:
	movem.l	d0-d7/a0-a6,-(a7)

	lea	ListViewText,a1
	bsr	CALCITEXT
	move.w	d0,d4				; d4=GUI width inside bevelbox

	moveq	#0,d5
	move.w	TitleHeight,d5
	add.w	#MAGIC+BEVBORDER,d5		; current topedge

; bevelbox around all gadgets in GUI

	lea	FAGUI_BevelBox1,a0
	move.w	d5,d0
	sub.w	#BEVBORDER,d0
	move.w	d0,bev_topedge(a0)

	move.w	WBorderWidth,d6
	add.w	#MAGIC+BEVBORDER,d6		; leftmost leftedge
	move.w	d6,d0
	sub.w	#BEVBORDER,d0
	move.w	d0,bev_leftedge(a0)

; "select file or sequence" cycle gadget

	lea	FAGUI_FSeqS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d4,gng_Width(a0)

; bevelbox to separate cyclegadget and "file" group

	lea	FAGUI_BevelBox2,a0
	add.w	GadgetHeight,d5
	add.w	#MAGIC,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	d4,bev_width(a0)
	move.w	#SEPHEIGHT,bev_height(a0)

; "light" next to "File" intuitext (bevelbox)

	lea	FAGUI_BevelBox3,a0
	add.w	#MAGIC+SEPHEIGHT,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	FontBHeight,d0
	move.w	d0,bev_height(a0)
	add.w	d0,d0
	move.w	d0,bev_width(a0)

; "File" intuitext

	lea	FAGUI_FileIText,a0
	move.w	d5,it_TopEdge(a0)
	move.w	d6,d1
	add.w	d0,d1
	add.w	#MAGIC,d1
	move.w	d1,it_LeftEdge(a0)

; "Get filename requester" button

	lea	FAGUI_GetFileS,a0
	add.w	FontHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	lea	FAGAD_GetTxt,a1
	bsr	CALCITEXT
	add.w	#MAGIC*4,d0
	move.w	d0,gng_Width(a0)

; "Name of file to add" string

	lea	FAGUI_FileNameS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d6,d1
	add.w	d0,d1
	add.w	#GUISPACE,d1
	move.w	d1,gng_LeftEdge(a0)
	add.w	#GUISPACE,d0
	move.w	d4,d1
	sub.w	d0,d1
	move.w	d1,gng_Width(a0)

; "bevelbox to separate "file" group and "sequence" group

	lea	FAGUI_BevelBox4,a0
	add.w	GadgetHeight,d5
	add.w	#MAGIC,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	d4,bev_width(a0)
	move.w	#SEPHEIGHT,bev_height(a0)

; "light" next to "Sequence" intuitext (bevelbox)

	lea	FAGUI_BevelBox5,a0
	add.w	#MAGIC+SEPHEIGHT,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	FontBHeight,d0
	move.w	d0,bev_height(a0)
	add.w	d0,d0
	move.w	d0,bev_width(a0)

; "Sequence" intuitext

	lea	FAGUI_SeqIText,a0
	move.w	d5,it_TopEdge(a0)
	move.w	d6,d1
	add.w	d0,d1
	add.w	#MAGIC,d1
	move.w	d1,it_LeftEdge(a0)

; "get pathname" button

	lea	FAGUI_GetPathS,a0
	add.w	FontHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	lea	FAGAD_PathTxt,a1
	bsr	CALCITEXT
	add.w	#MAGIC*4,d0
	move.w	d0,gng_Width(a0)

; "path name of sequence to add" string

	lea	FAGUI_PathNameS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d6,d1
	add.w	d0,d1
	add.w	#GUISPACE,d1
	move.w	d1,gng_LeftEdge(a0)
	add.w	#GUISPACE,d0
	move.w	d4,d1
	sub.w	d0,d1
	move.w	d1,gng_Width(a0)

; "pattern of sequence" string

	lea	FAGUI_PatternS,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	lea	FAGAD_PatTxt,a1
	bsr.w	CALCITEXT
	add.w	FontWidth,d0
	add.w	d6,d0
	move.w	d0,gng_LeftEdge(a0)
	move.w	d4,d1
	add.w	d6,d1
	sub.w	d0,d1
	move.w	d1,gng_Width(a0)

; "range of sequence" text

	lea	FAGUI_RangeS,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d0,gng_LeftEdge(a0)
	move.w	d0,d3
	lea	FAGAD_GetRngTxt,a1
	bsr.w	CALCITEXT
	add.w	#MAGIC*4,d0
	move.w	d1,d2
	sub.w	d0,d2
	sub.w	#GUISPACE,d2
	move.w	d2,gng_Width(a0)

; "get range" button

	lea	FAGUI_GetRangeS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d0,gng_Width(a0)
	add.w	d3,d2
	add.w	#GUISPACE,d2
	move.w	d2,gng_LeftEdge(a0)	

; "user defined name of sequence" string

	lea	FAGUI_PatternS,a0
	lea	FAGUI_SeqNameS,a1
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a1)
	move.w	gng_LeftEdge(a0),gng_LeftEdge(a1)
	move.w	gng_Width(a0),gng_Width(a1)
	move.w	gng_Height(a0),gng_Height(a1)

; "bevelbox to separate "file" group and "sequence" group from "ctrl" group

	lea	FAGUI_BevelBox6,a0
	add.w	GadgetHeight,d5
	add.w	#MAGIC,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	d4,bev_width(a0)
	move.w	#SEPHEIGHT,bev_height(a0)

; "add" button

	lea	FAGUI_AddS,a0
	add.w	#MAGIC+SEPHEIGHT,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d4,d0
	lsr.w	#2,d0
	move.w	d0,gng_Width(a0)

; "cancel" button

	lea	FAGUI_CancelS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	d4,d1
	add.w	d6,d1
	sub.w	d0,d1
	move.w	d1,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d0,gng_Width(a0)

;--------------------------------------------------------------------

	add.w	GadgetHeight,d5
	add.w	#BEVBORDER,d5

	lea	FAGUI_BevelBox1,a0
	move.w	d5,d0
	sub.w	bev_topedge(a0),d0
	move.w	d0,bev_height(a0)
	move.w	d4,d0
	add.w	#BEVBORDER*2,d0
	move.w	d0,bev_width(a0)

	add.w	#MAGIC,d5
	add.w	WBorderBottom,d5
	move.l	d5,ase_WindowHeight(a5)

	move.w	WBorderWidth,d1
	add.w	d1,d1
	add.w	#(2*MAGIC)+(2*BEVBORDER),d1
	add.w	d1,d4
	move.l	d4,ase_WindowWidth(a5)

	move.w	#1,ase_ReCalc(a5)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; render FAGUI
;--------------------------------------------------------------------

RENDER_FAGUI:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	ase_RastPort(a5),a0
	lea	FAGUI_BevelBox1,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FAGUI_BevelBox2,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FAGUI_BevelBox3,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FAGUI_BevelBox4,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FAGUI_BevelBox5,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FAGUI_BevelBox6,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FAGUI_FileIText,a1
	moveq	#0,d0
	moveq	#0,d1
	CALL	PrintIText,_IntuitionBase

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; Update misc. stuff in "Add File or Sequence..." GUI
;--------------------------------------------------------------------

UPDATE_FAGUI:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr.w	SUB_FAGUI_UPDATE_TYPE
	bsr.w	SUB_FAGUI_PRINT_PATTERN

	lea	AddFileName,a0
	move.b	#0,(a0)

	bsr.w	SUB_FAGUI_PRINT_FILENAME

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; handle FAGUI IDCMP messages
;--------------------------------------------------------------------

HANDLE_FAGUI:				; a5 = ASE structure
	move.l	d0,a0

	move.l	im_Class(a0),d0

	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	FAGUI_NOT_CLOSEWINDOW

	bsr.w	CLOSE_GUI			; Close "Add..." GUI

	lea	FGUI_Title,a0
	bsr.w	OPEN_GUI			; Open "Files & Sequences" GUI
	rts

;--------------------------------------------------------------------

FAGUI_NOT_CLOSEWINDOW:
	cmp.l	#IDCMP_GADGETUP,d0
	bne.s	FAGUI_NOT_GADGETUP

	move.l	im_IAddress(a0),a1
	move.l	gg_UserData(a1),a2
	cmp.l	#NULL,a2
	beq.s	HANDLE_FAGUI_DONE

; d0 = IDCMP code
; a0 = IntuiMessage
; a1 = Gadget

	jmp	(a2)

;--------------------------------------------------------------------

FAGUI_NOT_GADGETUP:
	rts

HANDLE_FAGUI_DONE:
	rts

;--------------------------------------------------------------------
; get filetype to add to "Files & Sequences" list from cycle gadget
;--------------------------------------------------------------------

SUB_FAGUI_UPDATE_TYPE:
	moveq	#0,d7
	move.w	AddType,d7

	lea	ActCycleTags,a3
	SETTAG	a3,GTCY_Active,d7

	move.l	ase_GadList(a5),a0
	moveq	#FAGAD_FSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	cmp.w	#FSEQID_SEQ,d7
	beq.s	SUB_FAGUI_TYPESEQ
	bra.s	SUB_FAGUI_TYPEFILE

SUB_FAGUI_TYPE:				; a5 = ASE structure
					; a0 = IntuiMessage

	move.w	im_Code(a0),d0
	beq.s	SUB_FAGUI_TYPEFILE

SUB_FAGUI_TYPESEQ:
	move.w	#FSEQID_SEQ,AddType

	lea	SequenceAddGadList,a0
	move.l	a5,a1
	bsr.w	ENABLE_GADLIST

	lea	FileAddGadList,a0
	move.l	a5,a1
	bsr.w	DISABLE_GADLIST

	lea	FAGUI_BevelBox5,a0
	move.l	a5,a1
	moveq	#3,d0
	bsr.w	FILL_BEVELBOX

	lea	FAGUI_BevelBox3,a0
	move.l	a5,a1
	moveq	#0,d0
	bsr.w	FILL_BEVELBOX
	rts

SUB_FAGUI_TYPEFILE:
	move.w	#FSEQID_FILE,AddType

	lea	FileAddGadList,a0
	move.l	a5,a1
	bsr.w	ENABLE_GADLIST

	lea	SequenceAddGadList,a0
	move.l	a5,a1
	bsr.w	DISABLE_GADLIST

	lea	FAGUI_BevelBox3,a0
	move.l	a5,a1
	moveq	#3,d0
	bsr.w	FILL_BEVELBOX

	lea	FAGUI_BevelBox5,a0
	move.l	a5,a1
	moveq	#0,d0
	bsr.w	FILL_BEVELBOX
	rts

;--------------------------------------------------------------------
; request filename of picture-file
;--------------------------------------------------------------------

SUB_FAGUI_GETFILENAME:				; a5 = ASE structure
	lea	ASLFileReqTags,a3
	SETTAG	a3,ASLFR_TitleText,#AddFileReqTitle
	SETTAG	a3,ASLFR_Window,ase_Window(a5)

	move.l	_FAGUI_FileRequest,a0
	lea	ASLFileReqTags,a1
	CALL	AslRequest,_AslBase
	tst.l	d0
	beq.s	NO_FAGUI_FREQ

	move.l	_FAGUI_FileRequest,a0
	move.l	fr_Drawer(a0),a1
	lea	AddFilePath,a2
	STRCPY	a1,a2

	move.l	d0,a1
	lea	AddFileName,a2
	STRCPY	a1,a2

	move.l	d0,d1
	move.l	fr_File(a0),d2
	move.l	#108,d3
	CALL	AddPart,_DOSBase

SUB_FAGUI_PRINT_FILENAME:
	lea	FillStringTags,a3
	SETTAG	a3,GTST_String,#AddFileName
	move.l	ase_GadList(a5),a0
	moveq	#FAGAD_FILENAME,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	lea	AddFileName,a0
	bsr.w	CHECK_FILE_EXIST
	bne.s	NO_FAGUI_FREQ

	lea	AddFileName,a0
	move.b	#0,(a0)
	bra.s	SUB_FAGUI_PRINT_FILENAME

NO_FAGUI_FREQ:
	rts

;--------------------------------------------------------------------
; input of filename from string gadget
;--------------------------------------------------------------------

SUB_FAGUI_FILENAME:
	move.l	gg_SpecialInfo(a1),a1
	move.l	si_Buffer(a1),a1
	lea	AddFileName,a2
	STRCPY	a1,a2

	lea	AddFileName,a0
	bsr.w	CHECK_FILE_EXIST
	bne.s	.OK

	lea	AddFileName,a0
	move.b	#0,(a0)
	bra.s	SUB_FAGUI_PRINT_FILENAME

.OK:	rts

;--------------------------------------------------------------------
; get sequence pattern string from string gadget
;--------------------------------------------------------------------

SUB_FAGUI_PATTERN:				; a1 = gadget
	move.l	gg_SpecialInfo(a1),a1
	move.l	si_Buffer(a1),a1
	lea	SequencePattern,a2
	STRCPY	a1,a2
	rts

SUB_FAGUI_PRINT_PATTERN:
	lea	FillStringTags,a3
	SETTAG	a3,GTST_String,#SequencePattern
	move.l	ase_GadList(a5),a0
	move.l	#FAGAD_PATTERN,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
	rts
;--------------------------------------------------------------------
; Get sequence path 'button'
;--------------------------------------------------------------------

SUB_FAGUI_GETPATHNAME:
	lea	ASLPathReqTags,a3
	SETTAG	a3,ASLFR_TitleText,#AddPathReqTitle
	SETTAG	a3,ASLFR_Window,ase_Window(a5)

	move.l	_FAGUI_PathRequest,a0
	lea	ASLPathReqTags,a1
	CALL	AslRequest,_AslBase
	tst.l	d0
	beq.s	NO_FAGUI_SREQ

	move.l	_FAGUI_PathRequest,a0
	move.l	fr_Drawer(a0),a1
	lea	AddSequencePath,a2
	STRCPY	a1,a2

	lea	FillStringTags,a3
	SETTAG	a3,GTST_String,#AddSequencePath
	move.l	ase_GadList(a5),a0
	moveq	#FAGAD_PATHNAME,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

NO_FAGUI_SREQ:
	rts

;--------------------------------------------------------------------
; add file or sequence to 'files & sequences' list
;--------------------------------------------------------------------

SUB_FAGUI_ADD:
	cmp.w	#FSEQID_FILE,AddType
	beq.s	SUB_FAGUI_ADD_FILE

SUB_FAGUI_ADD_SEQUENCE:
	rts

;--------------------------------------------------------------------

SUB_FAGUI_ADD_FILE:
	lea	AddFileName,a0			; file to add
	tst.b	(a0)
	beq.s	NO_ADD_FILE			; string is empty: no adding

	move.l	a0,a2				; a2 = beg of path
	move.l	a0,d1
	CALL	FilePart,_DOSBase		; locate beg of filename
	move.l	d0,a3				; a3 = beg of filename

	cmp.l	a2,a3
	beq.s	.NODIR

	cmp.b	#'/',-1(a3)
	bne.s	.NODIR

	move.b	#0,-1(a3)

.NODIR:

; alloc memory for structure and filename/pathname strings

	move.l	#fseq_SIZEOF,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,a4				; a4 = fseq structure
	beq.s	ADD_FILE_FAIL

	move.l	#109,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	tst.l	d0				; filename
	beq.s	ADD_FILE_FAIL

	move.l	d0,LN_NAME(a4)

	move.l	#109,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	tst.l	d0				; pathname
	beq.s	ADD_FILE_FAIL

	move.l	d0,fseq_Path(a4)

; copy names to strings

	move.l	a3,a0
	move.l	LN_NAME(a4),a1
	STRCPY	a0,a1
	move.b	#0,(a3)				; copy filename to LN_NAME

	tst.b	(a2)
	beq.s	NO_PATHNAME

	move.l	a2,a0
	move.l	fseq_Path(a4),a1
	STRCPY	a0,a1

; initialize FSEQ structure

NO_PATHNAME:
	move.b	#FSEQID_FILE,LN_TYPE(a4)
	move.l	#NULL,fseq_SeqList(a4)
	move.l	#0,fseq_Entries(a4)
	move.l	#0,fseq_Start(a4)

	lea	FSeqList,a0
	TSTLIST	a0
	bne.s	.NOTEMPTY

	NEWLIST	a0

.NOTEMPTY:
	lea	FSeqList,a0
	move.l	a4,a1
	ADDTAIL

;--------------------------------------------------------------------
;
; processing of file to make a stamp out of it, can possibly be done
; about here
;
;
;
;
;--------------------------------------------------------------------

	bsr.w	CLOSE_GUI			; Close "Add..." GUI

	lea	FGUI_Title,a0
	bsr.w	OPEN_GUI			; Open "Files & Sequences" GUI

NO_ADD_FILE:
	rts

;--------------------------------------------------------------------

ADD_FILE_FAIL:
	cmp.l	#NULL,a4
	beq.s	.REQ

	move.l	LN_NAME(a4),a1
	cmp.l	#NULL,a1
	beq.s	.NOT1

	EXEC	FreeVec

.NOT1:	move.l	fseq_Path(a4),a1
	cmp.l	#NULL,a1
	beq.s	.NOT2

	EXEC	FreeVec

.NOT2:	move.l	a4,a1
	EXEC	FreeVec

.REQ:	lea	ErrTxt_MEM,a0
	bsr.w	DISPLAY_REQUESTER
	rts

;--------------------------------------------------------------------
; Layout "Insert File or Sequence..." GUI
;--------------------------------------------------------------------

LAYOUT_FIGUI:
	movem.l	d0-d7/a0-a6,-(a7)

	lea	ListViewText,a1
	bsr	CALCITEXT
	move.w	d0,d4				; d4=GUI width inside bevelbox

	moveq	#0,d5
	move.w	TitleHeight,d5
	add.w	#MAGIC+BEVBORDER,d5		; d5 = current topedge

; bevelbox around all gadgets in GUI

	lea	FIGUI_BevelBox1,a0
	move.w	d5,d0
	sub.w	#BEVBORDER,d0
	move.w	d0,bev_topedge(a0)

	move.w	WBorderWidth,d6
	add.w	#MAGIC+BEVBORDER,d6		; d6 = leftmost leftedge
	move.w	d6,d0
	sub.w	#BEVBORDER,d0
	move.w	d0,bev_leftedge(a0)

; "name of file/sequence to insert" text

	lea	FIGUI_FSeqS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	d4,gng_Width(a0)
	move.w	GadgetHeight,gng_Height(a0)

; "light" left of the "Sequence Size" text

	lea	FIGUI_BevelBox5,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	FontBHeight,d0
	move.w	d0,bev_height(a0)
	add.w	d0,d0
	move.w	d0,bev_width(a0)
	add.w	#MAGIC,d0

; "Sequence Size" IText

	lea	FIGUI_SeqSizeIText,a0
	move.w	d5,it_TopEdge(a0)
	add.w	d6,d0
	move.w	d0,it_LeftEdge(a0)

; "insert whole or part of sequence" cycle

	lea	FIGUI_PartS,a0
	add.w	FontHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	d4,gng_Width(a0)
	move.w	GadgetHeight,gng_Height(a0)

; "part of sequence start" slider

	lea	FIGAD_SeqSTxt,a1
	bsr.w	CALCITEXT
	add.w	FontWidth,d0
	move.w	d0,d1
	add.w	d6,d1			; d1 = leftedge of slider

	lea	DispWidthText,a1
	bsr.w	CALCITEXT
	add.w	#MAGIC*4,d0
	move.w	d0,d2			; d2 = num display width

	lea	FIGUI_SeqStartS,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d1,gng_LeftEdge(a0)
	move.w	d4,d0
	sub.w	d2,d0
	sub.w	d1,d0
	add.w	d6,d0
	sub.w	#MAGIC,d0
	move.w	d0,gng_Width(a0)

; "part of sequence start display" number

	lea	FIGUI_SSNumS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d2,gng_Width(a0)
	move.w	d1,d3
	add.w	d0,d3
	add.w	#MAGIC,d3
	move.w	d3,gng_LeftEdge(a0)

; "part of sequence start" slider

	lea	FIGUI_SeqEndS,a0
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d1,gng_LeftEdge(a0)
	move.w	d0,gng_Width(a0)

; "part of sequence end display" number

	lea	FIGUI_SENumS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d2,gng_Width(a0)
	move.w	d1,d3
	add.w	d0,d3
	add.w	#MAGIC,d3
	move.w	d3,gng_LeftEdge(a0)

; separate

	lea	FIGUI_BevelBox2,a0
	add.w	GadgetHeight,d5
	add.w	#MAGIC,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	d4,bev_width(a0)
	move.w	#SEPHEIGHT,bev_height(a0)

; "light" left of the "Insert Position" text

	lea	FIGUI_BevelBox6,a0
	add.w	#SEPHEIGHT+MAGIC,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	FontBHeight,d0
	move.w	d0,bev_height(a0)
	add.w	d0,d0
	move.w	d0,bev_width(a0)
	add.w	#MAGIC,d0

; "Insert Position" IText

	lea	FIGUI_InsPosIText,a0
	move.w	d5,it_TopEdge(a0)
	add.w	d6,d0
	move.w	d0,it_LeftEdge(a0)

; "position in anim to insert file/seq" cycle

	lea	FIGUI_InsertPosS,a0
	add.w	FontHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	d4,gng_Width(a0)
	move.w	GadgetHeight,gng_Height(a0)

; "after frame number" slider

	lea	FIGUI_AfterS,a0
	lea	FIGUI_SeqEndS,a1
	add.w	GadgetHeight,d5
	add.w	#GUISPACE,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	gng_LeftEdge(a1),gng_LeftEdge(a0)
	move.w	gng_Width(a1),gng_Width(a0)
	move.w	gng_Height(a1),gng_Height(a0)

; "after frame number display" number

	lea	FIGUI_AftNumS,a0
	lea	FIGUI_SENumS,a1
	move.w	d5,gng_TopEdge(a0)
	move.w	gng_LeftEdge(a1),gng_LeftEdge(a0)
	move.w	gng_Width(a1),gng_Width(a0)
	move.w	gng_Height(a1),gng_Height(a0)

; separate

	lea	FIGUI_BevelBox3,a0
	add.w	GadgetHeight,d5
	add.w	#MAGIC,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	d4,bev_width(a0)
	move.w	#SEPHEIGHT,bev_height(a0)

; "insert sequence reversed" checkbox

	lea	FIGUI_ReverseS,a0
	add.w	#SEPHEIGHT+MAGIC,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	FontHeight,d0
	move.w	d0,gng_Height(a0)
	add.w	d0,d0
	move.w	d0,gng_Width(a0)

; separate

	lea	FIGUI_BevelBox4,a0
	add.w	FontHeight,d5
	add.w	#MAGIC,d5
	move.w	d5,bev_topedge(a0)
	move.w	d6,bev_leftedge(a0)
	move.w	d4,bev_width(a0)
	move.w	#SEPHEIGHT,bev_height(a0)

; "insert file/sequence into anim" button

	lea	FIGUI_InsertS,a0
	add.w	#SEPHEIGHT+MAGIC,d5
	move.w	d5,gng_TopEdge(a0)
	move.w	d6,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d4,d0
	lsr.w	#2,d0
	move.w	d0,gng_Width(a0)

; "cancel" button

	lea	FIGUI_CancelS,a0
	move.w	d5,gng_TopEdge(a0)
	move.w	d4,d1
	add.w	d6,d1
	sub.w	d0,d1
	move.w	d1,gng_LeftEdge(a0)
	move.w	GadgetHeight,gng_Height(a0)
	move.w	d0,gng_Width(a0)

;--------------------------------------------------------------------

	add.w	GadgetHeight,d5
	add.w	#BEVBORDER,d5

	lea	FIGUI_BevelBox1,a0
	move.w	d5,d0
	sub.w	bev_topedge(a0),d0
	move.w	d0,bev_height(a0)
	move.w	d4,d0
	add.w	#BEVBORDER*2,d0
	move.w	d0,bev_width(a0)

	add.w	#MAGIC,d5
	add.w	WBorderBottom,d5
	move.l	d5,ase_WindowHeight(a5)

	move.w	WBorderWidth,d1
	add.w	d1,d1
	add.w	#(2*MAGIC)+(2*BEVBORDER),d1
	add.w	d1,d4
	move.l	d4,ase_WindowWidth(a5)

	move.w	#1,ase_ReCalc(a5)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; Render "Insert File or Sequence..." GUI
;--------------------------------------------------------------------

RENDER_FIGUI:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	ase_RastPort(a5),a0
	lea	FIGUI_BevelBox1,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FIGUI_BevelBox2,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FIGUI_BevelBox3,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FIGUI_BevelBox4,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FIGUI_BevelBox5,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	move.l	ase_RastPort(a5),a0
	lea	FIGUI_BevelBox6,a1
	move.w	bev_leftedge(a1),d0
	move.w	bev_topedge(a1),d1
	move.w	bev_width(a1),d2
	move.w	bev_height(a1),d3
	lea	BevelRecTags,a1
	CALL	DrawBevelBoxA,_GadToolsBase

	lea	FIGUI_BevelBox6,a0
	move.l	a5,a1
	moveq	#3,d0
	bsr.w	FILL_BEVELBOX

	move.l	ase_RastPort(a5),a0
	lea	FIGUI_SeqSizeIText,a1
	moveq	#0,d0
	moveq	#0,d1
	CALL	PrintIText,_IntuitionBase

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; Update misc. stuff in "Insert File or Sequence..." GUI
;--------------------------------------------------------------------

UPDATE_FIGUI:
	movem.l	d0-d7/a0-a6,-(a7)

; display name of file or sequence

	move.l	_CurrFSeqNode,a3
	SETTAG	#FillTextTags,GTTX_Text,LN_NAME(a3)

	move.l	ase_GadList(a5),a0
	move.l	#FIGAD_FSEQ,d0
	move.l	(a0,d0.w*4),a0
	move.l	ase_Window(a5),a1
	sub.l	a2,a2
	lea	FillTextTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

; check if we're inserting a file or a sequence

	move.l	_CurrFSeqNode,a3
	cmp.b	#FSEQID_FILE,LN_TYPE(a3)
	beq.s	FIUPD_FILE

FIUPD_SEQ:
	lea	FIGUI_BevelBox3,a0
	move.l	a5,a1
	moveq	#3,d0
	bsr.w	FILL_BEVELBOX

	lea	InsertFSeqGadList,a0
	move.l	a5,a1
	bsr.w	ENABLE_GADLIST
	bra.s	FIUPD_DONE

FIUPD_FILE:
	lea	InsertFSeqGadList,a0
	move.l	a5,a1
	bsr.w	DISABLE_GADLIST

FIUPD_DONE:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------
; Handle "Insert File or Sequence..." GUI IDCMP Messages
;--------------------------------------------------------------------

HANDLE_FIGUI:
	move.l	d0,a0

	move.l	im_Class(a0),d0

	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	FIGUI_NOT_CLOSEWINDOW

	bsr.w	FIGUI_DONE
	bra	HANDLE_FIGUI_DONE

FIGUI_NOT_CLOSEWINDOW:
	cmp.l	#IDCMP_GADGETUP,d0
	bne.s	FIGUI_NOT_GADGETUP


	bra.s	HANDLE_FIGUI_DONE

FIGUI_NOT_GADGETUP:


HANDLE_FIGUI_DONE:
	rts

;--------------------------------------------------------------------

FIGUI_DONE:
	bsr.w	CLOSE_GUI		; Close "Insert..." GUI

	lea	FGUI_Title,a0
	bsr.w	OPEN_GUI		; Open "Files & Sequences" GUI
	rts

;--------------------------------------------------------------------
; GLOBALE SUBROUTINES
;
;--------------------------------------------------------------------
; calculate length of string (IntuText)
;--------------------------------------------------------------------

CALCITEXT:					; a1=string
	movem.l	d1/a0/a1,-(a7)
	lea	ITextStruct,a0
	move.l	a1,it_IText(a0)
	move.l	_Font,it_ITextFont(a0)
	CALL	IntuiTextLength,_IntuitionBase
	movem.l	(a7)+,d1/a0/a1
	rts

;--------------------------------------------------------------------
; disable all gadgets in a given list of gadget IDs
;--------------------------------------------------------------------


DISABLE_GADLIST:				; a0=list of gads to affect
						; a1=ASE structure

	movem.l	d2-d7/a2-a6,-(a7)

	move.l	ase_GadList(a1),a4
	move.l	ase_Window(a1),a5

.LOOP:	move.l	(a0)+,d0
	bmi.s	.DONE

	move.l	a0,-(a7)
	move.l	(a4,d0.w*4),a0
	move.l	a5,a1
	sub.l	a2,a2
	lea	DisableTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
	move.l	(a7)+,a0
	bra.s	.LOOP

.DONE:	movem.l	(a7)+,d2-d7/a2-a6
	rts

;--------------------------------------------------------------------
; enable all gadgets in a given list of gadget IDs
;--------------------------------------------------------------------

ENABLE_GADLIST:					; a0=list of gads to affect
						; a1=ASE structure

	movem.l	d2-d7/a2-a6,-(a7)

	move.l	ase_GadList(a1),a4
	move.l	ase_Window(a1),a5

.LOOP:	move.l	(a0)+,d0
	bmi.s	.DONE

	move.l	a0,-(a7)
	move.l	(a4,d0.w*4),a0
	move.l	a5,a1
	sub.l	a2,a2
	lea	EnableTags,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
	move.l	(a7)+,a0
	bra.s	.LOOP

.DONE:	movem.l	(a7)+,d2-d7/a2-a6
	rts

;--------------------------------------------------------------------
; fill bevelbox with color=d0 (pen number)
;--------------------------------------------------------------------

FILL_BEVELBOX:					; a0 = bevelbox to fill
						; a1 = ASE structure
						; d0 = pen number to use
	movem.l	d2-d7/a2-a6,-(a7)

	moveq	#0,d6
	moveq	#0,d7

	move.l	a0,a4
	move.l	a1,a5
	move.b	d0,d6

	move.l	ase_RastPort(a5),a0
	CALL	GetAPen,_GfxBase
	move.b	d0,d7				; last pen

	move.l	ase_RastPort(a5),a1
	move.l	d6,d0
	CALL	SetAPen,_GfxBase		; set new pen

	move.l	ase_RastPort(a5),a1

	move.w	bev_leftedge(a4),d0
	move.w	d0,d2
	add.w	bev_width(a4),d2
	subq.w	#1,d2

	move.w	bev_topedge(a4),d1
	move.w	d1,d3
	add.w	bev_height(a4),d3
	subq.w	#1,d3

	addq.w	#2,d0				; adjust size of field
	subq.w	#2,d2				; to fit inside bevelbox

	addq.w	#1,d1
	subq.w	#1,d3

	CALL	RectFill,_GfxBase

	move.l	ase_RastPort(a5),a1		; set old pen
	move.l	d7,d0
	CALL	SetAPen,_GfxBase
	
	movem.l	(a7)+,d2-d7/a2-a6
	rts

;--------------------------------------------------------------------
; check if file exists
;--------------------------------------------------------------------

CHECK_FILE_EXIST:			; a0=filename
	cmp.l	#NULL,a0
	beq.s	.SET

	tst.b	(a0)
	beq.s	.SET

	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open,_DOSBase
	tst.l	d0
	beq.s	.FAIL

	move.l	d0,d1
	CALL	Close,_DOSBase
.SET:	moveq	#1,d0
	rts

.FAIL:	lea	ErrTxt_FileNotFound,a0
	bsr.w	DISPLAY_REQUESTER

	moveq	#0,d0
	rts

;--------------------------------------------------------------------
; display info requester
;--------------------------------------------------------------------

DISPLAY_REQUESTER:				; a0=requester body text
	move.l	a0,-(a7)			; a5=ASE structure

	move.l	ase_Window(a5),a0
	lea	BusyPointTags,a1
	CALL	SetWindowPointerA,_IntuitionBase	; busy pointer

	lea	EasyRequester,a1
	move.l	(a7)+,es_TextFormat(a1)
	move.l	ase_Window(a5),a0
	sub.l	a2,a2
	sub.l	a3,a3
	CALL	EasyRequestArgs,_IntuitionBase

	move.l	ase_Window(a5),a0
	lea	DefPointTags,a1
	CALL	SetWindowPointerA,_IntuitionBase	; default pointer

	bsr.w	EMPTY_USERPORT			; all IDCMP messages gotten
	rts					; while requester is up, are
						; removed, so that they are
						; not processed in mainloop

;--------------------------------------------------------------------

	section	"Data",data

ExitFlag:	dc.w	0
ErrorCode:	dc.l	0

_WBMsg:		dc.l	0

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
_IntuitionBase:	dc.l	0
_GadToolsBase:	dc.l	0
_AslBase:	dc.l	0
AslName:	dc.b	"asl.library",0
GadToolsName:	dc.b	"gadtools.library",0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
IntuitionName:	dc.b	"intuition.library",0
		VERSTR
ProgramTitle:	NAME
		dc.b	" "
		dc.b	"V"
		VER
		dc.b	"."
		REV
		dc.b	" by Morten Amundsen. Copyright (C) 1996",0
		even

;--------------------------------------------------------------------
; error code strings
;--------------------------------------------------------------------

ErrPtrs:		dc.l	ErrTxt_CPU
			dc.l	ErrTxt_MEM

LFTxt:			dc.b	10,0
ErrTxt_CPU:		dc.b	"Program requires MC68020+",0
ErrTxt_MEM:		dc.b	"Unable to allocate memory!",0
ErrTxt_FileNotFound:	dc.b	"File not found!",0
			even

;--------------------------------------------------------------------
; list of windows + misc. global stuff
;--------------------------------------------------------------------

WindowList:	dcb.b	MLH_SIZE,0

_Screen:	dc.l	0
_VisualInfo:	dc.l	0

TitleHeight:	dc.w	0			; height of title bar
WBorderWidth:	dc.w	0			; width of window border
WBorderBottom:	dc.w	0			; height of bottom win border
GadgetHeight:	dc.w	0			; height of gadgets
FontHeight:	dc.w	0			; height of used font
FontWidth:	dc.w	0
FontBHeight:	dc.w	0			; height to bline of used font

BusyPointTags:	dc.l	WA_BusyPointer,TRUE
		dc.l	TAG_DONE

DefPointTags:	dc.l	WA_Pointer,NULL
		dc.l	WA_BusyPointer,FALSE
		dc.l	TAG_DONE

BevelTags:	dc.l	GT_VisualInfo,0		; tags used for bevelboxes
		dc.l	TAG_DONE

BevelRecTags:	dc.l	GT_VisualInfo,0		; tags used for bevelboxes
		dc.l	GTBB_Recessed,TRUE
		dc.l	TAG_DONE

DisableTags:	dc.l	GA_Disabled,TRUE
		dc.l	TAG_DONE

EnableTags:	dc.l	GA_Disabled,FALSE
		dc.l	TAG_DONE

ActCycleTags:	dc.l	GTCY_Active,0
		dc.l	TAG_DONE

FillStringTags:	dc.l	GTST_String,0
		dc.l	TAG_DONE

FillTextTags:	dc.l	GTTX_Text,0
		dc.l	TAG_DONE

_FAGUI_FileRequest:	dc.l	0
_FAGUI_PathRequest:	dc.l	0

ASLFileReqTags:		dc.l	ASLFR_Window,0
			dc.l	ASLFR_TitleText,0
			dc.l	ASLFR_SleepWindow,TRUE
			dc.l	ASLFR_RejectIcons,TRUE
			dc.l	TAG_DONE	

ASLPathReqTags:		dc.l	ASLFR_Window,0
			dc.l	ASLFR_TitleText,0
			dc.l	ASLFR_SleepWindow,TRUE
			dc.l	ASLFR_RejectIcons,TRUE
			dc.l	ASLFR_DrawersOnly,TRUE
			dc.l	TAG_DONE	

EasyRequester:	dc.l	es_SIZEOF
		dc.l	0
		dc.l	ReqTitle
		dc.l	0
		dc.l	ReqGadCont

ReqTitle:	NAME
		dc.b	" "
		VER
		dc.b	"."
		REV
		dc.b	0

ReqGadCont:	dc.b	"Continue",0
		even

_Font:		dc.l	0
_TextAttr:	dc.l	0

_TopazFont:	dc.l	0
_TopazAttr:	dc.l	0
_ScrFont:	dc.l	0
_ScrAttr:	dc.l	0

TopazAttr:	dc.l	TopazName
		dc.w	8
		dc.b	0,FPF_ROMFONT

TopazName:	dc.b	"topaz.font",0
		even

ITextStruct:	dcb.b	it_SIZEOF,0

ListViewText:	dcb.b	32,"a"
		dc.b	0
DispWidthText:	dcb.b	9,"4"
		dc.b	0
		even

;--------------------------------------------------------------------
; "Files & Sequences" GUI data area
;--------------------------------------------------------------------

AddType:		dc.w	FSEQID_FILE	; set by cycle gadget in
						; "Add file or sequence..."
						; FSEQID_FILE or FSEQID_SEQ

FileAddGadList:		dc.l	FAGAD_GETFILE
			dc.l	FAGAD_FILENAME
			dc.l	-1

SequenceAddGadList:	dc.l	FAGAD_GETPATH
			dc.l	FAGAD_PATHNAME
			dc.l	FAGAD_PATTERN
			dc.l	FAGAD_GETRANGE
			dc.l	FAGAD_SEQNAME
			dc.l	-1

InsertFSeqGadList:	dc.l	FIGAD_PART
			dc.l	FIGAD_SEQSTART
			dc.l	FIGAD_SEQEND
			dc.l	-1

AddFileName:		dcb.b	109,0
AddFilePath:		dcb.b	109,0
AddSequencePath:	dcb.b	109,0

SequencePattern:	dcb.b	65,0
RangeString:		dcb.b	90,0
FSeqEntryName:		dcb.b	65,0
			cnop	0,2

AddFileReqTitle:	dc.b	"Select File...",0
AddPathReqTitle:	dc.b	"Select Path...",0
			dc.b	0
			even

;--------------------------------------------------------------------

DetachFSeqTags:		dc.l	GTLV_Labels,~0
			dc.l	TAG_DONE

AttachFSeqTags:		dc.l	GTLV_Labels,FSeqList
			dc.l	TAG_DONE

_CurrFSeqNode:		dc.l	0		; addr of selected file/seq node

FSeqList:		dcb.b	MLH_SIZE,0	; list of files and seqs

;--------------------------------------------------------------------
; "Files & Sequences" GUI window
;--------------------------------------------------------------------

FGUI_Window:		dc.l	WA_Top,0
			dc.l	WA_Left,0
			dc.l	WA_Width,0
			dc.l	WA_Height,0
			dc.l	WA_Gadgets,0
			dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_GADGETUP
			dc.l	WA_Title,FGUI_Title
			dc.l	WA_ScreenTitle,ProgramTitle
			dc.l	WA_DragBar,TRUE
			dc.l	WA_DepthGadget,TRUE
			dc.l	WA_CloseGadget,TRUE
			dc.l	WA_Activate,TRUE
;			dc.l	WA_NewLookMenus,TRUE
			dc.l	TAG_DONE

FGUI_Title:		dc.b	"Files & Sequences",0
			even

;--------------------------------------------------------------------
; bevelboxes
;--------------------------------------------------------------------

FGUI_BevelBox1:		dcb.b	bev_SIZEOF,0

;--------------------------------------------------------------------
; texts
;--------------------------------------------------------------------




;--------------------------------------------------------------------
; gadgets
;--------------------------------------------------------------------

FGUI_GadgetList:	dcb.l	FGAD_NOGADS,0

FGUI_GadTypes:		dc.l	LISTVIEW_KIND
			dc.l	TEXT_KIND
			dc.l	BUTTON_KIND
			dc.l	BUTTON_KIND
			dc.l	BUTTON_KIND

FGUI_GadTags:		dc.l	FGUI_FSeqTags
			dc.l	FGUI_SelFSeqTags
			dc.l	FGUI_AddFSeqTags
			dc.l	FGUI_DelFSeqTags
			dc.l	FGUI_InsFSeqTags

FGUI_FSeqTags:		dc.l	GTLV_Labels,NULL
			dc.l	TAG_DONE
FGUI_SelFSeqTags:	dc.l	GTTX_Border,TRUE
			dc.l	GTTX_Text,NULL
			dc.l	TAG_DONE
FGUI_AddFSeqTags:	dc.l	TAG_DONE
FGUI_DelFSeqTags:	dc.l	TAG_DONE
FGUI_InsFSeqTags:	dc.l	TAG_DONE

FGUI_GadStructs:	dc.l	FGUI_FSeqS
			dc.l	FGUI_SelFSeqS
			dc.l	FGUI_AddFSeqS
			dc.l	FGUI_DelFSeqS
			dc.l	FGUI_InsFSeqS
			dc.l	0

; "Files & Sequences" listview

FGUI_FSeqS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FGAD_FSEQLIST	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FGUI_SELECT	; gng_UserData

; "Selected File/Sequence" text

FGUI_SelFSeqS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FGAD_SELFSEQ	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

; "Add File/Sequence" button

FGUI_AddFSeqS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FGAD_AddFSeqTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FGAD_ADDFSEQ	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FGUI_ADD	; gng_UserData

FGAD_AddFSeqTxt:	dc.b	"Add...",0
			even

; "Delete File/Sequence" button

FGUI_DelFSeqS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FGAD_DelFSeqTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FGAD_DELFSEQ	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FGUI_DEL	; gng_UserData

FGAD_DelFSeqTxt:	dc.b	"Delete...",0
			even

; "Insert File/Sequence" button

FGUI_InsFSeqS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FGAD_InsFSeqTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FGAD_INSFSEQ	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FGUI_INSERT	; gng_UserData

FGAD_InsFSeqTxt:	dc.b	"Insert...",0
			even

;--------------------------------------------------------------------
; "add file or sequence" GUI window
;--------------------------------------------------------------------

FAGUI_Window:		dc.l	WA_Top,0
			dc.l	WA_Left,0
			dc.l	WA_Width,0
			dc.l	WA_Height,0
			dc.l	WA_Gadgets,0
			dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_GADGETUP
			dc.l	WA_Title,FAGUI_Title
			dc.l	WA_ScreenTitle,ProgramTitle
			dc.l	WA_DragBar,TRUE
			dc.l	WA_DepthGadget,TRUE
			dc.l	WA_CloseGadget,TRUE
			dc.l	WA_Activate,TRUE
			dc.l	TAG_DONE

FAGUI_Title:		dc.b	"Add File or Sequence...",0
			even

;--------------------------------------------------------------------
; bevelboxes
;--------------------------------------------------------------------

FAGUI_BevelBox1:	dcb.b	bev_SIZEOF,0
FAGUI_BevelBox2:	dcb.b	bev_SIZEOF,0
FAGUI_BevelBox3:	dcb.b	bev_SIZEOF,0
FAGUI_BevelBox4:	dcb.b	bev_SIZEOF,0
FAGUI_BevelBox5:	dcb.b	bev_SIZEOF,0
FAGUI_BevelBox6:	dcb.b	bev_SIZEOF,0

;--------------------------------------------------------------------
; texts
;--------------------------------------------------------------------

FAGUI_FileIText:	dc.b	2			; it_FrontPen
			dc.b	0			; it_backPen
			dc.b	0			; it_DrawMode
			dc.b	0			; it_KludgeFill00
			dc.w	0			; it_LeftEdge
			dc.w	0			; it_TopEdge
			dc.l	0			; it_ITextFont
			dc.l	FAGUI_FileTextStr	; it_IText
			dc.l	FAGUI_SeqIText		; it_NextText

FAGUI_FileTextStr:	dc.b	"File",0
			even

FAGUI_SeqIText:		dc.b	2			; it_FrontPen
			dc.b	0			; it_backPen
			dc.b	0			; it_DrawMode
			dc.b	0			; it_KludgeFill00
			dc.w	0			; it_LeftEdge
			dc.w	0			; it_TopEdge
			dc.l	0			; it_ITextFont
			dc.l	FAGUI_SeqTextStr	; it_IText
			dc.l	0			; it_NextText

FAGUI_SeqTextStr:	dc.b	"Sequence",0
			even

;--------------------------------------------------------------------
; gadgets
;--------------------------------------------------------------------

FAGUI_GadgetList:	dcb.l	FAGAD_NOGADS,0

FAGUI_GadTypes:		dc.l	CYCLE_KIND
			dc.l	BUTTON_KIND
			dc.l	STRING_KIND
			dc.l	BUTTON_KIND
			dc.l	STRING_KIND
			dc.l	STRING_KIND
			dc.l	TEXT_KIND
			dc.l	BUTTON_KIND
			dc.l	STRING_KIND
			dc.l	BUTTON_KIND
			dc.l	BUTTON_KIND

FAGUI_GadTags:		dc.l	FAGUI_FSeqTags
			dc.l	FAGUI_GetFileTags
			dc.l	FAGUI_FileNameTags
			dc.l	FAGUI_GetPathTags
			dc.l	FAGUI_PathNameTags
			dc.l	FAGUI_PatternTags
			dc.l	FAGUI_RangeTags
			dc.l	FAGUI_GetRangeTags
			dc.l	FAGUI_SeqNameTags
			dc.l	FAGUI_AddTags
			dc.l	FAGUI_CancelTags

FAGUI_FSeqTags:		dc.l	GTCY_Labels,FAGAD_FSeqLabPtr
			dc.l	TAG_DONE
FAGUI_GetFileTags:	dc.l	TAG_DONE
FAGUI_FileNameTags:	dc.l	GTST_MaxChars,108
			dc.l	TAG_DONE
FAGUI_GetPathTags:	dc.l	GA_Disabled,TRUE
			dc.l	TAG_DONE
FAGUI_PathNameTags:	dc.l	GTST_MaxChars,108
			dc.l	GA_Disabled,TRUE
			dc.l	TAG_DONE
FAGUI_PatternTags:	dc.l	GA_Disabled,TRUE
			dc.l	TAG_DONE
FAGUI_RangeTags:	dc.l	GTTX_Border,TRUE
			dc.l	GTTX_Text,NULL
			dc.l	TAG_DONE
FAGUI_GetRangeTags:	dc.l	GA_Disabled,TRUE
			dc.l	TAG_DONE
FAGUI_SeqNameTags:	dc.l	GA_Disabled,TRUE
			dc.l	TAG_DONE
FAGUI_AddTags:		dc.l	TAG_DONE
FAGUI_CancelTags:	dc.l	TAG_DONE

FAGUI_GadStructs:	dc.l	FAGUI_FSeqS
			dc.l	FAGUI_GetFileS
			dc.l	FAGUI_FileNameS
			dc.l	FAGUI_GetPathS
			dc.l	FAGUI_PathNameS
			dc.l	FAGUI_PatternS
			dc.l	FAGUI_RangeS
			dc.l	FAGUI_GetRangeS
			dc.l	FAGUI_SeqNameS
			dc.l	FAGUI_AddS
			dc.l	FAGUI_CancelS
			dc.l	0

; "Select either Files or Sequences" cycle

FAGUI_FSeqS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_FSEQ	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FAGUI_TYPE	; gng_UserData

FAGAD_FSeqLabPtr:	dc.l	FAGAD_FSeqLabFTxt
			dc.l	FAGAD_FSeqLabSTxt
			dc.l	0

FAGAD_FSeqLabFTxt:	dc.b	"File",0
FAGAD_FSeqLabSTxt:	dc.b	"Sequence",0
			even

; "get filename" button

FAGUI_GetFileS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_GetTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_GETFILE	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FAGUI_GETFILENAME	; gng_UserData

FAGAD_GetTxt:		dc.b	"Get",0
			even

; "path of sequence to add" string

FAGUI_FileNameS:	dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_FILENAME	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FAGUI_FILENAME	; gng_UserData

; "get pathname" button

FAGUI_GetPathS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_PathTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_GETPATH	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FAGUI_GETPATHNAME	; gng_UserData

FAGAD_PathTxt:		dc.b	"Path",0
			even

; "name of sequence path" string

FAGUI_PathNameS:	dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_PATHNAME	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

; "pattern of sequence" string

FAGUI_PatternS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_PatTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_PATTERN	; gng_GadgetID
			dc.l	PLACETEXT_LEFT	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FAGUI_PATTERN	; gng_UserData

FAGAD_PatTxt:		dc.b	"Pattern",0
			even

; "range of sequence" text

FAGUI_RangeS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_RangeTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_RANGE	; gng_GadgetID
			dc.l	PLACETEXT_LEFT	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FAGAD_RangeTxt:		dc.b	"Range",0
			even

; "get range of sequence" button

FAGUI_GetRangeS:	dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_GetRngTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_GETRANGE	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FAGAD_GetRngTxt:	dc.b	"Get",0
			even

; "user defined name of sequence" string

FAGUI_SeqNameS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_SNameTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_SEQNAME	; gng_GadgetID
			dc.l	PLACETEXT_LEFT	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FAGAD_SNameTxt:		dc.b	"Name",0
			even

; "add" button

FAGUI_AddS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_AddTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_ADD	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	SUB_FAGUI_ADD	; gng_UserData

FAGAD_AddTxt:		dc.b	"Add",0
			even

; "cancel" button

FAGUI_CancelS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FAGAD_CancelTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FAGAD_CANCEL	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FAGAD_CancelTxt:	dc.b	"Cancel",0
			even

;--------------------------------------------------------------------
; "Insert file or sequence into animation" GUI window
;--------------------------------------------------------------------

FIGUI_Window:		dc.l	WA_Top,0
			dc.l	WA_Left,0
			dc.l	WA_Width,0
			dc.l	WA_Height,0
			dc.l	WA_Gadgets,0
			dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_GADGETUP
			dc.l	WA_Title,FIGUI_Title
			dc.l	WA_ScreenTitle,ProgramTitle
			dc.l	WA_DragBar,TRUE
			dc.l	WA_DepthGadget,TRUE
			dc.l	WA_CloseGadget,TRUE
			dc.l	WA_Activate,TRUE
			dc.l	TAG_DONE

FIGUI_Title:		dc.b	"Insert File or Sequence...",0
			even

;--------------------------------------------------------------------
; bevelboxes
;--------------------------------------------------------------------

FIGUI_BevelBox1:	dcb.b	bev_SIZEOF,0
FIGUI_BevelBox2:	dcb.b	bev_SIZEOF,0
FIGUI_BevelBox3:	dcb.b	bev_SIZEOF,0
FIGUI_BevelBox4:	dcb.b	bev_SIZEOF,0
FIGUI_BevelBox5:	dcb.b	bev_SIZEOF,0
FIGUI_BevelBox6:	dcb.b	bev_SIZEOF,0

;--------------------------------------------------------------------
; texts
;--------------------------------------------------------------------

FIGUI_SeqSizeIText:	dc.b	2			; it_FrontPen
			dc.b	0			; it_backPen
			dc.b	0			; it_DrawMode
			dc.b	0			; it_KludgeFill00
			dc.w	0			; it_LeftEdge
			dc.w	0			; it_TopEdge
			dc.l	0			; it_ITextFont
			dc.l	FIGUI_SeqSizeTextStr	; it_IText
			dc.l	FIGUI_InsPosIText	; it_NextText

FIGUI_SeqSizeTextStr:	dc.b	"Sequence Size",0
			even

FIGUI_InsPosIText:	dc.b	2			; it_FrontPen
			dc.b	0			; it_backPen
			dc.b	0			; it_DrawMode
			dc.b	0			; it_KludgeFill00
			dc.w	0			; it_LeftEdge
			dc.w	0			; it_TopEdge
			dc.l	0			; it_ITextFont
			dc.l	FIGUI_InsPosTextStr	; it_IText
			dc.l	0			; it_NextText

FIGUI_InsPosTextStr:	dc.b	"Insert Position",0
			even


;--------------------------------------------------------------------
; gadgets
;--------------------------------------------------------------------

FIGUI_GadgetList:	dcb.l	FIGAD_NOGADS,0

FIGUI_GadTypes:		dc.l	TEXT_KIND
			dc.l	CYCLE_KIND
			dc.l	SLIDER_KIND
			dc.l	NUMBER_KIND
			dc.l	SLIDER_KIND
			dc.l	NUMBER_KIND
			dc.l	CYCLE_KIND
			dc.l	SLIDER_KIND
			dc.l	NUMBER_KIND
			dc.l	CHECKBOX_KIND
			dc.l	BUTTON_KIND
			dc.l	BUTTON_KIND

FIGUI_GadTags:		dc.l	FIGUI_FSeqTags
			dc.l	FIGUI_PartTags
			dc.l	FIGUI_SeqStartTags
			dc.l	FIGUI_SSNumTags
			dc.l	FIGUI_SeqEndTags
			dc.l	FIGUI_SENumTags
			dc.l	FIGUI_InsertPosTags
			dc.l	FIGUI_AfterTags
			dc.l	FIGUI_AftNumTags
			dc.l	FIGUI_ReverseTags
			dc.l	FIGUI_InsertTags
			dc.l	FIGUI_CancelTags

FIGUI_FSeqTags:		dc.l	GTTX_Border,TRUE
			dc.l	GTTX_Text,NULL
			dc.l	TAG_DONE
FIGUI_PartTags:		dc.l	GTCY_Labels,FIGAD_PartLabPtr
			dc.l	TAG_DONE
FIGUI_SeqStartTags:	dc.l	GTSL_Min,0
			dc.l	GTSL_Max,0
			dc.l	GTSL_Level,0
			dc.l	GA_Immediate,TRUE
			dc.l	TAG_DONE
FIGUI_SSNumTags:	dc.l	GTNM_Number,0
			dc.l	TAG_DONE
FIGUI_SeqEndTags:	dc.l	GTSL_Min,0
			dc.l	GTSL_Max,0
			dc.l	GTSL_Level,0
			dc.l	GA_Immediate,TRUE
			dc.l	TAG_DONE
FIGUI_SENumTags:	dc.l	GTNM_Number,0
			dc.l	TAG_DONE
FIGUI_InsertPosTags:	dc.l	GTCY_Labels,FIGAD_InsLabPtr
			dc.l	TAG_DONE
FIGUI_AfterTags:	dc.l	GTSL_Min,0
			dc.l	GTSL_Max,0
			dc.l	GTSL_Level,0
			dc.l	GA_Immediate,TRUE
			dc.l	TAG_DONE
FIGUI_AftNumTags:	dc.l	GTNM_Number,0
			dc.l	TAG_DONE
FIGUI_ReverseTags:	dc.l	GTCB_Scaled,TRUE
			dc.l	TAG_DONE
FIGUI_InsertTags:	dc.l	TAG_DONE
FIGUI_CancelTags:	dc.l	TAG_DONE

FIGUI_GadStructs:	dc.l	FIGUI_FSeqS
			dc.l	FIGUI_PartS
			dc.l	FIGUI_SeqStartS
			dc.l	FIGUI_SSNumS
			dc.l	FIGUI_SeqEndS
			dc.l	FIGUI_SENumS
			dc.l	FIGUI_InsertPosS
			dc.l	FIGUI_AfterS
			dc.l	FIGUI_AftNumS
			dc.l	FIGUI_ReverseS
			dc.l	FIGUI_InsertS
			dc.l	FIGUI_CancelS
			dc.l	0

; "name of File or Sequence to insert" text

FIGUI_FSeqS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_FSEQ	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

; "insert whole or part of sequence" cycle

FIGUI_PartS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_PART	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_PartLabPtr:	dc.l	FIGAD_WholeTxt
			dc.l	FIGAD_PartTxt
			dc.l	0

FIGAD_WholeTxt:		dc.b	"Whole",0
FIGAD_PartTxt:		dc.b	"Part",0
			even

; "sequence start" slider

FIGUI_SeqStartS:	dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FIGAD_SeqSTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_SEQSTART	; gng_GadgetID
			dc.l	PLACETEXT_LEFT	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_SeqSTxt:		dc.b	"Start",0
			even

; "sequence start display" number

FIGUI_SSNumS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_SSNUM	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

; "sequence end" slider

FIGUI_SeqEndS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FIGAD_SeqETxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_SEQEND	; gng_GadgetID
			dc.l	PLACETEXT_LEFT	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_SeqETxt:		dc.b	"End",0
			even

; "sequence end display" number

FIGUI_SENumS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_SENUM	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

; "insert position of sequence in anim" cycle

FIGUI_InsertPosS:	dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_INSPOS	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_InsLabPtr:	dc.l	FIGAD_InsTopTxt
			dc.l	FIGAD_InsBotTxt
			dc.l	FIGAD_InsAftTxt
			dc.l	0

FIGAD_InsTopTxt:	dc.b	"Top",0
FIGAD_InsBotTxt:	dc.b	"Bottom",0
FIGAD_InsAftTxt:	dc.b	"After",0
			even

; "after frame number" slider

FIGUI_AfterS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FIGAD_AfterTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_AFTER	; gng_GadgetID
			dc.l	PLACETEXT_LEFT	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_AfterTxt:		dc.b	"After",0
			even

; "after frame number display" number

FIGUI_AftNumS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	0		; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_AFTERNUM	; gng_GadgetID
			dc.l	0		; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

; "insert sequence reversed" checkbox

FIGUI_ReverseS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FIGAD_RevTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_INSREV	; gng_GadgetID
			dc.l	PLACETEXT_RIGHT	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_RevTxt:		dc.b	"Reverse Sequence",0
			even

; "insert file/sequence" button

FIGUI_InsertS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FIGAD_InsertTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_INSERT	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_InsertTxt:	dc.b	"Insert",0
			even

; "cancel insert operation" button

FIGUI_CancelS:		dc.w	0		; gng_LeftEdge
			dc.w	0		; gng_TopEdge
			dc.w	0		; gng_Width
			dc.w	0		; gng_Height
			dc.l	FIGAD_CancelTxt	; gng_GadgetText
			dc.l	0		; gng_TextAttr
			dc.w	FIGAD_CANCEL	; gng_GadgetID
			dc.l	PLACETEXT_IN	; gng_Flags
			dc.l	0		; gng_VisualInfo
			dc.l	0		; gng_UserData

FIGAD_CancelTxt:	dc.b	"Cancel",0
			even
