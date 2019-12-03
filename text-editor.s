;--------------------------------------------------------------------------
; AssemblerText v0.0                                                 16-Feb-93
; by Morten Amundsen                                        mortena@ifi.uio.no
;-----------------------------------------------------------------------------

TAB:			equ	09
LF:			equ	10
CR:			equ	13
SPC:			equ	32

;-----------------------------------------------------------------------------

VPORT:			equ	44
RPORT:			equ	84
UPORT:			equ	86

IO_DEVICE:		equ	20

;-----------------------------------------------------------------------------

PR_WINDOWPTR:		equ	184			; PROCESS

;-----------------------------------------------------------------------------

RT_FILEREQ:		equ	0			; REQTOOLS
RT_REQINFO:		equ	1
RT_FONTREQ:		equ	2

REQPOS_CENTERSCR:	equ	2

TAG_END:		equ	0
TAG_USER:		equ	$80000000
RT_TAGBASE:		equ	TAG_USER
RT_REQPOS:		equ	TAG_USER+3

;-----------------------------------------------------------------------------

TF_YSIZE:		equ	20
TF_LOCHAR:		equ	32			; TEXTFONT
TF_HICHAR:		equ	33
TF_CHARDATA:		equ	34
TF_MODULO:		equ	38

;-----------------------------------------------------------------------------

MEMF_CHIP:		equ	$00002			; ALLOCMEM
MEMF_FAST:		equ	$00004
MEMF_PUBLIC:		equ	$00001
MEMF_CLEAR:		equ	$10000
MEMF_LARGEST:		equ	$20000

;-----------------------------------------------------------------------------

CLASS:			equ	20			; INTUIMESSAGE
CODE:			equ	24
QUALIFIER:		equ	26
IADDRESS:		equ	28

BUFSIZE:		equ	15

IE_CLASS:		equ	4
IE_CODE:		equ	6
IE_QUALIFIER:		equ	8
IE_POSITION:		equ	10

IECLASS_RAWKEY:		equ	1

;-----------------------------------------------------------------------------

MAXLINE:		equ	25			; Textlines
MAXCHAR:		equ	77			; Chars pr. line

BITMAP:			equ	4			; RASTPORT

BPL1:			equ	8			; BITMAP
BPL2:			equ	12

;-----------------------------------------------------------------------------

HIRES:			equ	$8000			; SCREEN
CUSTOMSCREEN:		equ	$000F

;-----------------------------------------------------------------------------

WINDOWSIZING:		equ	$0001			; WINDOW
WINDOWDRAG:		equ	$0002
WINDOWDEPTH:		equ	$0004
WINDOWCLOSE:		equ	$0008

SIZEBRIGHT:		equ	$0010
SIZEBBOTTOM:		equ	$0020

REFRESHBITS:		equ	$00C0
SMART_REFRESH:		equ	$0000
SIMPLE_REFRESH:		equ	$0040
SUPER_BITMAP:		equ	$0080
OTHER_REFRESH:		equ	$00C0

BACKDROP:		equ	$0100
REPMOUSE:		equ	$0200
GIMMEZEROZERO:		equ	$0400
BORDERLESS:		equ	$0800
ACTIVE:			equ	$1000

RMBTRAP:		equ	$00010000
NOCAREREFRESH:		equ	$00020000

;-----------------------------------------------------------------------------

SIZEVERIFY:		equ	$00000001		; IDCMP Classes
NEWSIZE:		equ	$00000002
REFRESHWINDOW:		equ	$00000004
MOUSEBUTTONS:		equ	$00000008
MOUSEMOVE:		equ	$00000010
GADGETDOWN:		equ	$00000020
GADGETUP:		equ	$00000040
REQSET:			equ	$00000080
MENUPICK:		equ	$00000100
CLOSEWIN:		equ	$00000200
RAWKEY:			equ	$00000400
REQVERIFY:		equ	$00000800
REQCLEAR:		equ	$00001000
MENUVERIFY:		equ	$00002000
NEWPREFS:		equ	$00004000
DISKINSERTED:		equ	$00008000
DISKREMOVED:		equ	$00010000
WBENCHMESSAGE:		equ	$00020000
ACTIVEWINDOW:		equ	$00040000
INACTIVEWINDOW:		equ	$00080000
DELTAMOVE:		equ	$00100000
VANILLAKEY:		equ	$00200000
INTUITICKS:		equ	$00400000

;-----------------------------------------------------------------------------

MENUENABLED:		equ	$0001			; MENU

CHECKIT:		equ	$0001
ITEMTEXT:		equ	$0002
COMMSEQ:		equ	$0004
MENUTOGGLE:		equ	$0008
ITEMENABLED:		equ	$0010
HIGHFLAGS:		equ	$00C0
HIGHIMAGE:		equ	$0000
HIGHCOMP:		equ	$0040

HIGHBOX:		equ	$0080
HIGHNONE:		equ	$00C0

CHECKED:		equ	$0100

MENUHOT:		equ	$0001			; IDCMP Codes
MENUCANCEL:		equ	$0002
MENUWAITING:		equ	$0003

MENUNULL:		equ	$FFFF

;-----------------------------------------------------------------------------

GADGHIGHBITS:		equ	$0003			; GADGET

GADGHCOMP:		equ	$0000
GADGHBOX:		equ	$0001
GADGHIMAGE:		equ	$0002
GADGHNONE:		equ	$0003
GADGIMAGE:		equ	$0004

GRELBOTTOM:		equ	$0008
GRELRIGHT:		equ	$0010
GRELWIDTH:		equ	$0020
GRELHEIGHT:		equ	$0040

SELECTED:		equ	$0080
GADGDISABLED:		equ	$0100

RELVERIFY:		equ	$0001
GADGIMMIDIATE:		equ	$0002
ENDGADGET:		equ	$0004
FOLLOWMOUSE:		equ	$0008

RIGHTBORDER:		equ	$0010
LEFTBORDER:		equ	$0020
TOPBORDER:		equ	$0040
BOTTOMBORDER:		equ	$0080

TOGGLESELECT:		equ	$0100
STRINGCENTER:		equ	$0200
STRINGRIGHT:		equ	$0400
LONGINT:		equ	$0800
ALTKEYMAP:		equ	$1000
BOOLEXTEND:		equ	$2000

GADGETTYPE:		equ	$FC00
SYSGADGET:		equ	$8000
SCRGADGET:		equ	$4000
GZZGADGET:		equ	$2000
REQGADGET:		equ	$1000

SIZING:			equ	$0010
WDRAGGING:		equ	$0020
SDRAGGING:		equ	$0030
WUPFONT:		equ	$0040
SUPFONT:		equ	$0050
WDOWNBACK:		equ	$0060
SDOWNBACK:		equ	$0070
CLOSEG:			equ	$0080

BOOLGADGET:		equ	$0001
GADGET0002:		equ	$0002
PROPGADGET:		equ	$0003
STRGADGET:		equ	$0004

;-----------------------------------------------------------------------------

VPOT:			equ	4
VBODY:			equ	8

AUTOKNOB:		equ	$0001			; PROPINFO

FREEHORIZ:		equ	$0002
FREEVERT:		equ	$0004
PROPBORDERLESS:		equ	$0008
KNOBHIT:		equ	$0100

KNOBHMIN:		equ	6
KNOBVMIN:		equ	4
MAXBODY:		equ	$FFFF
MAXPOT:			equ	$FFFF

;-----------------------------------------------------------------------------

JAM1:			equ	0			; TEXT
JAM2:			equ	1
COMPLEMENT:		equ	2
INVERSVID:		equ	4

;-----------------------------------------------------------------------------

	incdir	"include:"
	include	"misc/lvooffsets.i"

;-----------------------------------------------------------------------------

	section	"CODE",code

S:
	movem.l	d0-d7/a0-a6,-(a7)

;-----------------------------------------------------------------------------
;	OPEN LIBRARIES
;-----------------------------------------------------------------------------



	move.l	4.w,a6
	lea	DOSNAME,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)

	move.l	d0,DOSBASE
	beq.w	EXITPRG

	lea	INTNAME,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)

	move.l	d0,INTBASE
	beq.w	EXITPRG

	lea	GFXNAME,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)

	move.l	d0,GFXBASE
	beq.w	EXITPRG

	lea	REQNAME,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)

	move.l	d0,REQBASE
	beq.w	EXITPRG

;-----------------------------------------------------------------------------
;	OPEN CONSOLE DEVICE (GET "console.library" POINTER)
;-----------------------------------------------------------------------------

	move.l	4.w,a6
	lea	CONNAME,a0
	lea	STRUCT,a1
	moveq	#-1,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)

	move.l	d0,ERROR
	bne.w	EXITPRG

	lea	STRUCT,a0
	move.l	IO_DEVICE(a0),CONBASE

;-----------------------------------------------------------------------------
;	OPEN SCREEN AND WINDOW
;-----------------------------------------------------------------------------

	move.l	INTBASE,a6
	lea	OSARGS,a0
	jsr	_LVOOpenScreen(a6)

	move.l	d0,SCREEN
	beq.w	EXITPRG

	lea	OWARGS,a0
	jsr	_LVOOpenWindow(a6)

	move.l	d0,WINDOW
	beq.w	EXITPRG

;-----------------------------------------------------------------------------
;	SELECT WINDOW TO DISPLAY REQUESTER IN
;-----------------------------------------------------------------------------

	move.l	4.w,a6
	sub.l	a1,a1
	jsr	_LVOFindTask(a6)

	move.l	d0,a0
	move.l	a0,PROCESS
	move.l	PR_WINDOWPTR(a0),OLDWPTR
	move.l	WINDOW,PR_WINDOWPTR(a0)

;-----------------------------------------------------------------------------
;	SETUP OUR APPLICATION MENUS
;-----------------------------------------------------------------------------

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	lea	MENUPROJ,a1
	jsr	_LVOSetMenuStrip(a6)

	move.l	#1,HASMENUS

;-----------------------------------------------------------------------------
;	SETUP OUR APPLICATION DRAG-BAR
;-----------------------------------------------------------------------------

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	lea	DRAGBAR,a1
	moveq	#-1,d0
	jsr	_LVOAddGadget(a6)

	lea	DRAGBAR,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	#1,HASDRAG

	bsr.w	KNOBREFRESH

;-----------------------------------------------------------------------------
;	FIND PORTS AND PLANES
;-----------------------------------------------------------------------------

	move.l	WINDOW,a0
	move.l	UPORT(a0),USERPORT

	move.l	SCREEN,a0
	lea	VPORT(a0),a1
	move.l	a1,VIEWPORT
	lea	RPORT(a0),a1
	move.l	a1,RASTPORT

	move.l	BITMAP(a1),a1
	move.l	BPL1(a1),TPLANE			; Text Plane
	move.l	BPL2(a1),CPLANE			; Cursor Plane
	add.l	#[11*80],TPLANE
	add.l	#[11*80],CPLANE

;-----------------------------------------------------------------------------
;	OPEN THE BUILT-IN "topaz.font" (8)
;-----------------------------------------------------------------------------

	move.l	GFXBASE,a6
	lea	TEXTATTR,a0
	jsr	_LVOOpenFont(a6)

	move.l	d0,TEXTFONT
	beq.w	EXITPRG

	move.l	RASTPORT,a1
	move.l	TEXTFONT,a0
	jsr	_LVOSetFont(a6)

	move.l	TEXTFONT,a0
	move.w	TF_YSIZE(a0),YSIZE
	move.b	TF_LOCHAR(a0),LOCHAR
	move.b	TF_HICHAR(a0),HICHAR
	move.l	TF_CHARDATA(a0),CHARDATA
	move.w	TF_MODULO(a0),MODULO

;-----------------------------------------------------------------------------
;	TOUCH UP THE SCREENS COLORS
;-----------------------------------------------------------------------------

	move.l	GFXBASE,a6
	move.l	VIEWPORT,a0
	lea	COLORS,a1
	moveq	#4,d0
	jsr	_LVOLoadRGB4(a6)

;-----------------------------------------------------------------------------
;	ALLOCATE DEFAULT 64K MEMORY FOR TEXT BUFFER
;-----------------------------------------------------------------------------

	move.l	4.w,a6
	move.l	MEMSIZE,d0
	move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)

	move.l	d0,BUFPOINTER
	beq.w	EXITPRG

;-----------------------------------------------------------------------------
;	LAST MINUTE INITIALIZTIONS
;-----------------------------------------------------------------------------

	bsr	SETCURSOR
	bsr.w	UPDATEMEMUSE

	move.l	CPLANE,a0			; Outline the STATUSLINE
	add.l	#[26*9*80],a0
	move.w	#79,d7
REVLOOP:
	not.b	(a0)+
	not.b	$4F(a0)
	not.b	$9F(a0)
	not.b	$EF(a0)
	not.b	$13F(a0)
	not.b	$18F(a0)
	not.b	$1DF(a0)
	not.b	$22F(a0)
	dbf	d7,REVLOOP

;-----------------------------------------------------------------------------
;	HERE'S OUR MAIN MESSAGE LOOP
;-----------------------------------------------------------------------------

GETMESSAGES:
	tst.w	ENDFLAG				; Exit if this flag=TRUE
	bne.s	EXITPRG

	move.l	4.w,a6
	move.l	USERPORT,a0
	jsr	_LVOWaitPort(a6)			; Wait for IDCMP on Window

GETNEXT:
	move.l	USERPORT,a0
	jsr	_LVOGetMsg(a6)			; Get the IDCMP message

	move.l	d0,MESSAGE
	beq.s	GETMESSAGES			; Was it really a message?

	move.l	d0,a0
	move.l	CLASS(a0),d0			; message class?

	cmp.l	#MENUPICK,d0
	beq.w	MENUSELECT
	cmp.l	#RAWKEY,d0
	beq.w	GETRAWKEY
	cmp.l	#GADGETDOWN,d0
	beq.w	NEWTEXTOUTPUT
	cmp.l	#GADGETUP,d0
	beq.w	NEWTEXTOUTPUT

REPLYIT:
	move.l	4.w,a6
	move.l	MESSAGE,a1
	jsr	_LVOReplyMsg(a6)			; reply the message
	bra.s	GETNEXT

;-----------------------------------------------------------------------------
;	THIS PROGRAM IS NOW EXITING!!!
;-----------------------------------------------------------------------------

REPEXIT:
	move.l	4.w,a6
	move.l	MESSAGE,a1
	jsr	_LVOReplyMsg(a6)

EXITPRG:
	bsr.s	CLEANUP

	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;==============================================================================

CLEANUP:
	bsr.s	CLEANMEM
	bsr.s	CLOSEFNT
	bsr.s	REMGADGE
	bsr.w	REMSTRIP
	bsr.w	RESTOREREQ
	bsr.w	CLOSEWIND
	bsr.s	CLOSECON
	bsr.w	CLOSESCR
	bsr.w	CLOSEREQ
	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT
	bsr.w	CLOSEDOS
NOPE:	rts

;-----------------------------------------------------------------------------
;	CLOSE FONT
;-----------------------------------------------------------------------------

CLOSEFNT:
	tst.l	TEXTFONT
	beq.s	NOPE

	move.l	GFXBASE,a6
	move.l	TEXTFONT,a1
	jsr	_LVOCloseFont(a6)
	rts

;-----------------------------------------------------------------------------
;	FREE THE MEMORY ALLOCATED BY THE TEXTBUFFER
;-----------------------------------------------------------------------------

CLEANMEM:
	tst.l	BUFPOINTER
	beq.s	NOPE

	move.l	4.w,a6
	move.l	BUFPOINTER,a1
	move.l	MEMSIZE,d0
	jsr	_LVOFreeMem(a6)
	rts

;-----------------------------------------------------------------------------
;	CLOSE "console.library"
;-----------------------------------------------------------------------------

CLOSECON:
	tst.l	ERROR
	bne.s	NOPE

	move.l	4.w,a6
	lea	STRUCT,a1
	jsr	_LVOCloseDevice(a6)
	rts	

;-----------------------------------------------------------------------------
;	REMOVE THE DRAG-BAR
;-----------------------------------------------------------------------------

REMGADGE:
	tst.l	HASDRAG
	beq.s	NOPE

	move.l	INTBASE,a6
	lea	DRAGBAR,a0
	move.l	WINDOW,a1
	jsr	_LVORemoveGadget(a6)
	rts

;-----------------------------------------------------------------------------
;	REMOVE THE MENUS
;-----------------------------------------------------------------------------

REMSTRIP:
	tst.l	HASMENUS
	beq.s	NOPE

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	jsr	_LVOClearMenuStrip(a6)
	rts

;-----------------------------------------------------------------------------
;	RESTORE WINDOW PTR IN PROCESS STRUCT
;-----------------------------------------------------------------------------

RESTOREREQ:
	tst.l	PROCESS
	beq.w	NOPE

	tst.l	OLDWPTR
	beq.w	NOPE

	move.l	PROCESS,a0
	move.l	OLDWPTR,PR_WINDOWPTR(a0)
	rts

;-----------------------------------------------------------------------------
;	CLOSE OUR WINDOW AND SCREEN
;-----------------------------------------------------------------------------

CLOSEWIND:
	tst.l	WINDOW
	beq.w	NOPE

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	jsr	_LVOCloseWindow(a6)
	rts

CLOSESCR:
	tst.l	SCREEN
	beq.w	NOPE

	move.l	INTBASE,a6
	move.l	SCREEN,a0
	jsr	_LVOCloseScreen(a6)
	rts

;-----------------------------------------------------------------------------
;	CLOSE "graphics", "intuition", "reqtools" AND "dos" LIBRARIES
;-----------------------------------------------------------------------------

CLOSEREQ:
	tst.l	REQBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	REQBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts	

CLOSEGFX:
	tst.l	GFXBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	GFXBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

CLOSEINT:
	tst.l	INTBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	INTBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

CLOSEDOS:
	tst.l	DOSBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	DOSBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;	YOU SELECTED A MENU, OR AT LEAST PRESSED RIGHT MB
;-----------------------------------------------------------------------------

MENUSELECT:
	moveq	#0,d0
	move.l	MESSAGE,a0
	move.w	CODE(a0),d0

	move.l	INTBASE,a6
	lea	MENUPROJ,a0
	jsr	_LVOItemAddress(a6)

	move.l	d0,ITEMNUMBER
	beq.w	REPLYIT

	lea	MENUJUMPS,a0

SEARCHITEM:
	move.l	(a0),d1
	beq.s	NOITEM

	cmp.l	d0,d1
	beq.s	GOTITEM

	lea	8(a0),a0
	bra.s	SEARCHITEM

GOTITEM:
	move.l	4(a0),a0
	jsr	(a0)

NOITEM:
	bra.w	REPLYIT

;----------------------------------------------------------------------------
;	WRITE A LINE (a0=TEXTPOINTER), (d0=X) and (d1=Y)
;----------------------------------------------------------------------------

OUTPUTLINE:
	mulu	#[9*80],d1
	add.w	d0,d1

	move.l	TPLANE,a1
	add.w	d1,a1

	move.w	MODULO,d3

SEARCHCHAR:
	moveq	#0,d2
	move.b	(a0)+,d2

	cmp.b	#TAB,d2
	beq.s	ADDTAB
	cmp.b	#LF,d2
	beq.s	DONEOUTPUT

	sub.b	#SPC,d2

	move.l	CHARDATA,a2
	lea	(a2,d2.w),a2

	move.b	(a2),(a1)+
	lea	(a2,d3.w),a2
	move.b	(a2),$4F(a1)
	lea	(a2,d3.w),a2
	move.b	(a2),$9F(a1)
	lea	(a2,d3.w),a2
	move.b	(a2),$EF(a1)
	lea	(a2,d3.w),a2
	move.b	(a2),$13F(a1)
	lea	(a2,d3.w),a2
	move.b	(a2),$18F(a1)
	lea	(a2,d3.w),a2
	move.b	(a2),$1DF(a1)
	lea	(a2,d3.w),a2
	move.b	(a2),$22F(a1)
	bra.s	SEARCHCHAR

DONEOUTPUT:
	rts

ADDTAB:
	add.l	TABSIZE,d0
	move.l	TABSIZE,d1
	neg.w	d1
	and.w	d1,d0
	bra.w	OUTPUTLINE

;----------------------------------------------------------------------------
;	A KEY WAS PRESSED AND THIS ROUTINE PROCESSES IT...
;----------------------------------------------------------------------------

GETRAWKEY:
	lea	INPUTEVENT,a0
	move.l	MESSAGE,a1

	move.b	#IECLASS_RAWKEY,IE_CLASS(a0)
	move.w	CODE(a1),IE_CODE(a0)
	move.w	QUALIFIER(a1),IE_QUALIFIER(a0)
	move.l	IADDRESS(a1),IE_POSITION(a0)

	move.l	CONBASE,a6
	lea	KEYBUFFER,a1
	move.l	#BUFSIZE,d1
	sub.l	a2,a2
	jsr	_LVORawKeyConvert(a6)

	move.w	d0,NOCHARS			; No ANSI-Sequence produced
	beq.w	REPLYIT

	bsr.s	PROCESSKEYS
	bra.w	REPLYIT

;---------------------------------------------------------------------------

PROCESSKEYS:
	lea	KEYBUFFER,a0
	cmp.b	#$9b,(a0)
	beq.w	ANSISEQ

	moveq	#0,d0
	moveq	#0,d3
	move.b	(a0),d0
	sub.w	#SPC,d0

	move.l	CHARDATA,a0
	lea	(a0,d0.w),a0

	move.w	MODULO,d3

	moveq	#0,d1
	moveq	#0,d2
	move.w	CURSORX,d1
	move.w	CURSORY,d2

	move.l	TPLANE,a1
	add.w	d1,a1

	mulu	#[9*80],d2
	add.w	d2,a1

	move.b	(a0),(a1)
	lea	(a0,d3.w),a0
	move.b	(a0),$50(a1)
	lea	(a0,d3.w),a0
	move.b	(a0),$A0(a1)
	lea	(a0,d3.w),a0
	move.b	(a0),$F0(a1)
	lea	(a0,d3.w),a0
	move.b	(a0),$140(a1)
	lea	(a0,d3.w),a0
	move.b	(a0),$190(a1)
	lea	(a0,d3.w),a0
	move.b	(a0),$1E0(a1)
	lea	(a0,d3.w),a0
	move.b	(a0),$230(a1)

	bsr.s	UPDATEMEMUSE
	rts

;---------------------------------------------------------------------------

UPDATEMEMUSE:
	move.l	MEMSIZE,d0
	sub.l	BYTEUSE,d0

	lea	SFREE+7,a0
	bsr.s	BIGCONVERT

	lea	SBYTES+7,a0
	move.l	BYTEUSE,d0
	bsr.s	BIGCONVERT

	bsr.w	SETSTATUSLINE	
	rts

;---------------------------------------------------------------------------

BIGCONVERT:
	divu	#1000,d0
	move.w	d0,d2
	clr.w	d0
	swap	d0

	move.w	#2,d7
B1LOOP:
	bsr.w	HEXDEC
	move.b	d1,-(a0)
	dbf	d7,B1LOOP

	moveq	#0,d0
	move.w	d2,d0

	move.w	#3,d7
B2LOOP:
	bsr.w	HEXDEC
	move.b	d1,-(a0)
	dbf	d7,B2LOOP
	rts

;---------------------------------------------------------------------------

ANSISEQ:
	lea	1(a0),a0

	cmp.b	#'A',(a0)
	beq.s	CURSORUP
	cmp.b	#'B',(a0)
	beq.s	CURSORDOWN
	cmp.b	#'C',(a0)
	beq.w	CURSORRIGHT
	cmp.b	#'D',(a0)
	beq.w	CURSORLEFT
	rts

;-----------------------------------------------------------------------------

CURSORUP:
	tst.w	CURSORY
	beq.s	CHECK_TOP

	bsr	SETCURSOR
	subq.w	#1,CURSORY
	bsr.w	SETCURSOR

	subq.w	#1,CURRENTLINE
	bsr.w	UPDATECLINE

NO_UP:
	rts

CHECK_TOP:
	tst.w	TOPLINE
	beq.s	NO_UP

	subq.w	#1,TOPLINE
	bsr.w	KNOBREFRESH
	subq.w	#1,CURRENTLINE
	bsr.w	UPDATECLINE
	rts

;-----------------------------------------------------------------------------

CURSORDOWN:
	cmp.w	#MAXLINE,CURSORY
	beq.s	CHECK_BOTTOM

	bsr	SETCURSOR
	addq.w	#1,CURSORY
	bsr.w	SETCURSOR

	addq.w	#1,CURRENTLINE
	bsr.s	UPDATECLINE

NO_DOWN:
	rts

CHECK_BOTTOM:
	move.w	TOTALLINES,d0
	sub.w	#MAXLINE,d0
	bmi.s	NO_DOWN

	cmp.w	TOPLINE,d0
	beq.s	NO_DOWN

	addq.w	#1,TOPLINE
	bsr.w	KNOBREFRESH
	addq.w	#1,CURRENTLINE
	bsr.s	UPDATECLINE

	rts

;-----------------------------------------------------------------------------

CURSORLEFT:
	tst.w	CURSORX
	beq.s	NO_LEFT

	bsr.w	SETCURSOR
	subq.w	#1,CURSORX
	bsr.s	SETCURSOR

	subq.w	#1,COLUMN
	bsr.s	UPDATECOLUMN

NO_LEFT:
	rts

;-----------------------------------------------------------------------------

CURSORRIGHT:
	cmp.w	#MAXCHAR,CURSORX
	beq.s	NO_RIGHT

	bsr.s	SETCURSOR
	addq.w	#1,CURSORX
	bsr.s	SETCURSOR

	addq.w	#1,COLUMN
	bsr.s	UPDATECOLUMN

NO_RIGHT:
	rts

;-----------------------------------------------------------------------------

UPDATECLINE:
	moveq	#0,d0
	move.w	CURRENTLINE,d0

	lea	SLINE+5,a0
	move.w	#4,d7
LILOOP:
	bsr.s	HEXDEC
	move.b	d1,-(a0)
	dbf	d7,LILOOP

	bsr.w	SETSTATUSLINE
	rts

;-----------------------------------------------------------------------------

UPDATECOLUMN:
	moveq	#0,d0
	move.w	COLUMN,d0
	
	lea	SCOL+3,a0
	move.w	#2,d7
COLOOP:
	bsr.s	HEXDEC
	move.b	d1,-(a0)
	dbf	d7,COLOOP

	bsr.s	SETSTATUSLINE
	rts

;-----------------------------------------------------------------------------

HEXDEC:
	moveq	#0,d1
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,d1
	clr.w	d0
	swap	d0
	rts

;-----------------------------------------------------------------------------
;	SETCURSOR
;-----------------------------------------------------------------------------

SETCURSOR:
	moveq	#0,d1
	move.w	CURSORY,d1
	mulu	#9,d1
	add.w	#$2c+12+9,d1

WAITBEAM:
	move.l	GFXBASE,a6
	jsr	_LVOVBeamPos(a6)
	cmp.w	d0,d1
	bgt.s	WAITBEAM	

	moveq	#0,d0
	moveq	#0,d1
	move.w	CURSORX,d0
	move.w	CURSORY,d1

	move.l	CPLANE,a0
	add.w	d0,a0

	mulu	#[9*80],d1
	add.w	d1,a0

	not.b	(a0)
	not.b	$50(a0)
	not.b	$A0(a0)
	not.b	$F0(a0)
	not.b	$140(a0)
	not.b	$190(a0)
	not.b	$1E0(a0)
	not.b	$230(a0)
	rts

;-----------------------------------------------------------------------------
;	UPDATE STAUSLINE
;-----------------------------------------------------------------------------

SETSTATUSLINE:
	moveq	#0,d0				; Xpos
	move.w	#26,d1				; Ypos
	lea	STATLINE,a0			; Text Pointer
	bsr	OUTPUTLINE
	rts

;-----------------------------------------------------------------------------
;	YOU FIDDLED WITH THE DRAG-BAR	
;-----------------------------------------------------------------------------

NEWTEXTOUTPUT:
	lea	PROPINFO,a0
	move.w	VPOT(a0),VERTPOT
	move.w	VBODY(a0),VERTBODY
	bsr.w	NEWTOPLINE

	move.w	TOPLINE,d0
	add.w	CURSORY,d0
	move.w	d0,CURRENTLINE
	bsr.w	UPDATECLINE

	bra.w	REPLYIT

;-----------------------------------------------------------------------------
;	INITIALIZE THE DRAG-BAR SIZE AND POSITION
;-----------------------------------------------------------------------------

KNOBREFRESH:
	moveq	#0,d0
	moveq	#0,d1

	move.w	TOTALLINES,d0
	sub.w	VISIBLELINES,d0
	bge.s	OKHIDDEN

	moveq	#0,d0

OKHIDDEN:
	move.w	d0,HIDDEN

	move.w	TOPLINE,d1
	cmp.w	d0,d1
	ble.s	FINDVERT

	move.w	d0,TOPLINE

FINDVERT:	
	tst.w	HIDDEN
	beq.w	SETMAXBODY

	moveq	#0,d0
	moveq	#0,d1

	move.w	VISIBLELINES,d0
	sub.w	OVERLAP,d0
	mulu	#MAXBODY,d0

	move.w	TOTALLINES,d1
	sub.w	OVERLAP,d1

	divu	d1,d0
	move.w	d0,VERTBODY
	bra.s	FINDPOT

SETMAXBODY:
	move.w	#MAXBODY,VERTBODY

FINDPOT:
	tst.w	HIDDEN
	beq.s	SETNULLPOT

	moveq	#0,d0

	move.w	TOPLINE,d0
	mulu	#MAXPOT,d0
	divu	HIDDEN,d0
	
	move.w	d0,VERTPOT
	bra.s	SETPROP

SETNULLPOT:
	clr.w	VERTPOT

SETPROP:
	moveq	#0,d2
	moveq	#0,d4

	move.l	INTBASE,a6
	lea	DRAGBAR,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	move.l	#AUTOKNOB+FREEVERT,d0
	moveq	#NULL,d1
	move.w	VERTPOT,d2
	moveq	#NULL,d3
	move.w	VERTBODY,d4
	moveq	#-1,d5
	jsr	_LVONewModifyProp(a6)

	rts

;---------------------------------------------------------------------------
;	THE SCREEN HAS SCROLLED AND A NEW TOPLINE FOR THE TEXT IS CALCED
;---------------------------------------------------------------------------

NEWTOPLINE:
	moveq	#0,d0
	moveq	#0,d1

	move.w	TOTALLINES,d0
	sub.w	VISIBLELINES,d0
	bge.s	OKHIDDEN2

	moveq	#0,d0

OKHIDDEN2:
	move.w	d0,HIDDEN

	mulu	VERTPOT,d0
	move.w	#MAXPOT,d1
	lsr.w	#1,d1
	add.w	d1,d0
	divu	#MAXPOT,d0

	move.w	d0,TOPLINE
	rts	

;-----------------------------------------------------------------------------
;	PROJECT (Quit)
;-----------------------------------------------------------------------------

SUBQUIT:
	move.w	#1,ENDFLAG
	rts

;-----------------------------------------------------------------------------
;	PROJECT (Load)
;-----------------------------------------------------------------------------

SUBLOAD:
	rts

;-----------------------------------------------------------------------------
;	ENVIRONMENT (Color)
;-----------------------------------------------------------------------------

SUBCOLOR:
	move.l	REQBASE,a6
	move.l	#RT_REQINFO,d0
	sub.l	a0,a0
	jsr	_LVOrtAllocRequestA(a6)

	move.l	d0,ALLOCREQ
	beq.s	NOCOLOR

	move.l	REQBASE,a6
	lea	COLORTITLE,a2
	move.l	ALLOCREQ,a3
	lea	TAGCENTER,a0
	jsr	_LVOrtPaletteRequestA(a6)

	move.l	REQBASE,a6
	move.l	ALLOCREQ,a1
	jsr	_LVOrtFreeRequest(a6)

NOCOLOR:
	rts

;-----------------------------------------------------------------------------

SUBCUSTOM:
	move.l	REQBASE,a6
	move.l	#RT_REQINFO,d0
	sub.l	a0,a0
	jsr	_LVOrtAllocRequestA(a6)

	move.l	d0,ALLOCREQ
	beq.s	NOCUSTOM

	move.l	REQBASE,a6
	lea	TABSIZE,a1
	lea	TABTITLE,a2
	move.l	ALLOCREQ,a3
	lea	TAGCENTER,a0
	jsr	_LVOrtGetLongA(a6)

	move.l	REQBASE,a6
	move.l	ALLOCREQ,a1
	jsr	_LVOrtFreeRequest(a6)

NOCUSTOM:
	rts

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;	VARIABLES
;-----------------------------------------------------------------------------

	section	"DATA",data

KEY:			dc.b	0
FUNC:			dc.b	0

ENDFLAG:		dc.w	0

TABSIZE:		dc.l	8
TABTITLE:		dc.b	"Enter TAB Size",0
			even

YSIZE:			dc.w	0
LOCHAR:			dc.b	0
HICHAR:			dc.b	0
CHARDATA:		dc.l	0
MODULO:			dc.w	0

TEXTFONT:		dc.l	0

TEXTATTR:
			dc.l	TOPAZ
			dc.w	8
			dc.b	0,0

TOPAZ:			dc.b	"topaz.font",0
			even

;---------------------------------------------------------------------------

PROCESS:		dc.l	0
OLDWPTR:		dc.l	0

RASTPORT:		dc.l	0
VIEWPORT:		dc.l	0
USERPORT:		dc.l	0
MESSAGE:		dc.l	0

TPLANE:			dc.l	0
CPLANE:			dc.l	0

STRUCT:			blk.l	20,0

ERROR:			dc.l	-1
CONBASE:		dc.l	0
DOSBASE:		dc.l	0
GFXBASE:		dc.l	0
INTBASE:		dc.l	0
REQBASE:		dc.l	0

REQNAME:		dc.b	"reqtools.library",0
INTNAME:		dc.b	"intuition.library",0
GFXNAME:		dc.b	"graphics.library",0
DOSNAME:		dc.b	"dos.library",0
CONNAME:		dc.b	"console.device",0
			even

;-----------------------------------------------------------------------------

INPUTEVENT:
			dc.l	0	; NextEvent
			dc.b	0	; Class
			dc.b	0	; SubClass
			dc.w	0	; Code
			dc.w	0	; Qualifier
			dc.l	0	; Position
			blk.b	20,0

NOCHARS:		dc.w	0
KEYBUFFER:		blk.b	15,0
			even

;-----------------------------------------------------------------------------

TAGCENTER:
	dc.l	RT_REQPOS,REQPOS_CENTERSCR
	dc.l	TAG_END


ALLOCREQ:		dc.l	0			; Ptr to req. struct

;-----------------------------------------------------------------------------

COLORTITLE:		dc.b	"Modify Colors...",0
			even


COLORS:			dc.w	$988	; 000
			dc.w	$001	; 001
			dc.w	$CBB	; 010
			dc.w	$668	; 011

;-----------------------------------------------------------------------------

OSARGS:			dc.w	0,0		; LeftEdge, TopEdge
			dc.w	640,256		; Width, Height
			dc.w	2		; Depth
			dc.b	0,1		; DetailPen, BlockPen
			dc.w	HIRES		; ViewModes
			dc.w	CUSTOMSCREEN	; Type
			dc.l	TEXTATTR	; Font
			dc.l	BUFFERNAME	; DefaultTitle
			dc.l	NULL		; Gadgets
			dc.l	NULL		; CustomBitmap

BUFFERNAME:		dc.b	"The Ultimate 680x0 Assembly Word "
			dc.b	"Processor",0
			even

OWARGS:			dc.w	0,0		; LeftEdge, TopEdge
			dc.w	640,256		; Width, Height
			dc.b	2,1		; DetailPen, BlockPen
			dc.l	MENUPICK+RAWKEY+GADGETDOWN+GADGETUP	; IDCMPFlags
			dc.l	BACKDROP+BORDERLESS+ACTIVE	; Flags
			dc.l	NULL		; FirstGadget
			dc.l	NULL		; CheckMark
			dc.l	NULL		; Title
SCREEN:			dc.l	0		; Screen
			dc.l	NULL		; Bitmap
			dc.w	0,0		; MinWidth, MinHeight
			dc.w	0,0		; MaxWidth, MaxHeight
			dc.w	CUSTOMSCREEN	; Type

WINDOW:			dc.l	0

;-----------------------------------------------------------------------------

BYTEUSE:		dc.l	0
CURRENTLINE:		dc.w	0
COLUMN:			dc.w	0

STATLINE:
		dc.b	" Line: "			; 7
SLINE:		dc.b	"00000"				; 5
		dc.b	"  Column: "			; 10
SCOL:		dc.b	"000"				; 3
		dc.b	"  |  Bytes Used: "		; 9
SBYTES:		dc.b	"0000000"			; 7
		dc.b	" | Free: "
SFREE:		dc.b	"0000000"
		dc.b	10
		even

;-----------------------------------------------------------------------------

CURSORX:		dc.w	0
CURSORY:		dc.w	0

BUFPOINTER:		dc.l	0		; Text pointer
MEMSIZE:		dc.l	[128*1024]

MAXLINES:		dc.w	0
CURLINE:		dc.w	0

;-----------------------------------------------------------------------------

HIDDEN:			dc.w	0	; MAX(TotalLines-VisibleLines, 0)

VISIBLELINES:		dc.w	25
TOTALLINES:		dc.w	100
TOPLINE:		dc.w	0
OVERLAP:		dc.w	1

VERTBODY:		dc.w	0
VERTPOT:		dc.w	0

HASDRAG:		dc.l	0

DRAGBAR:
			dc.l	NULL		; NextGadget
			dc.w	626,11		; LeftEdge, TopEdge
			dc.w	14,233		; Width, Height
			dc.w	GADGHNONE	; Flags
			dc.w	RELVERIFY+GADGIMMIDIATE	; Activation
			dc.w	PROPGADGET	; GadgetType
			dc.l	AUTOKNIM	; GadgetRender
			dc.l	NULL		; SelectRender
			dc.l	NULL		; GadgetText
			dc.l	NULL		; MutualExclude
			dc.l	PROPINFO	; SpecialInfo
			dc.w	0		; GadgetID
			dc.l	0		; UserData

PROPINFO:
			dc.w	AUTOKNOB+FREEVERT	; Flags
			dc.w	0,0		; HorizPot, VertPot
			dc.w	0,MAXBODY	; HorizBody, VertBody
			dc.w	0,0		; CWidth, CHeight
			dc.w	0,0		; HPotRes, VPotRes
			dc.w	0,0		; LeftBorder, TopBorder

AUTOKNIM:
			dc.w	0,0		; LeftEdge, TopEdge
			dc.w	0,0		; Width, Height
			dc.w	0		; Depth
			dc.l 	0		; ImageData
			dc.b	0		; PlanePick
			dc.b	0		; PlaneOnOff
			dc.l	0		; NextImage

;-----------------------------------------------------------------------------
;	MENU
;-----------------------------------------------------------------------------

ITEMNUMBER:		dc.l	0
HASMENUS:		dc.l	0

;-----------------------------------------------------------------------------
;	PROJECT MENU
;-----------------------------------------------------------------------------

MENUPROJ:		dc.l	MENUENV		; NextMenu
			dc.w	0,0		; LeftEdge, TopEdge
			dc.w	79,10		; Width, Height
			dc.w	MENUENABLED	; Flags
			dc.l	PROJECT		; MenuName
			dc.l	QUITITEM	; FirstItem
			dc.w	0,0		; JazzX, JazzY
			dc.w	0,0		; BeatX, BeatY

PROJECT:		dc.b	"Project",0
			even

;----------------------------------------------------------------------------

QUITITEM:
			dc.l	NULL		; NextItem
			dc.w	0,0		; LeftEdge, TopEdge
			dc.w	120,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+COMMSEQ	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	QUITI		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	"q"		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

QUITI:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	QUITTXT		; Text
			dc.l	NULL		; NextText

QUITTXT:		dc.b	"Quit",0
			even

;-----------------------------------------------------------------------------
;	ENVIRONMENT MENU
;-----------------------------------------------------------------------------

MENUENV:		dc.l	NULL		; NextMenu
			dc.w	80,0		; LeftEdge, TopEdge
			dc.w	99,10		; Width, Height
			dc.w	MENUENABLED	; Flags
			dc.l	ENVIR		; MenuName
			dc.l	COLORITEM	; FirstItem
			dc.w	0,0		; JazzX, JazzY
			dc.w	0,0		; BeatX, BeatY

ENVIR:			dc.b	"Environment",0
			even

COLORITEM:
			dc.l	TABITEM		; NextItem
			dc.w	0,0		; LeftEdge, TopEdge
			dc.w	120,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+COMMSEQ	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	COLORI		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	"c"		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

COLORI:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	COLORTXT	; Text
			dc.l	NULL		; NextText

COLORTXT:		dc.b	"Color...",0
			even

;-----------------------------------------------------------------------------

TABITEM:
			dc.l	NULL		; NextItem
			dc.w	0,9		; LeftEdge, TopEdge
			dc.w	120,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	TABI		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	NULL		; Command
			even
			dc.l	TSIZEI1		; SubItem
			dc.w	NULL		; NextSelect

TABI:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	TABTXT		; Text
			dc.l	NULL		; NextText

TABTXT:			dc.b	"TAB Size",0
			even


;-----------------------------------------------------------------------------

TSIZEI1:
			dc.l	TSIZEI2		; NextItem
			dc.w	90,3		; LeftEdge, TopEdge
			dc.w	64,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+CHECKIT	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	TS1		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	NULL		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

TS1:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	T1TXT		; Text
			dc.l	NULL		; NextText

T1TXT:			dc.b	"      1",0
			even

;---------

TSIZEI2:
			dc.l	TSIZEI4		; NextItem
			dc.w	90,12		; LeftEdge, TopEdge
			dc.w	64,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+CHECKIT	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	TS2		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	NULL		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

TS2:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	T2TXT		; Text
			dc.l	NULL		; NextText

T2TXT:			dc.b	"      2",0
			even

;---------

TSIZEI4:
			dc.l	TSIZEI6		; NextItem
			dc.w	90,21		; LeftEdge, TopEdge
			dc.w	64,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+CHECKIT	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	TS4		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	NULL		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

TS4:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	T4TXT		; Text
			dc.l	NULL		; NextText

T4TXT:			dc.b	"      4",0
			even

;---------

TSIZEI6:
			dc.l	TSIZEI8		; NextItem
			dc.w	90,30		; LeftEdge, TopEdge
			dc.w	64,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+CHECKIT	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	TS6		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	NULL		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

TS6:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	T6TXT		; Text
			dc.l	NULL		; NextText

T6TXT:			dc.b	"      6",0
			even

;---------

TSIZEI8:
			dc.l	CUSTOMITEM	; NextItem
			dc.w	90,39		; LeftEdge, TopEdge
			dc.w	64,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+CHECKIT	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	TS8		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	NULL		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

TS8:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	T8TXT		; Text
			dc.l	NULL		; NextText

T8TXT:			dc.b	"      8",0
			even

;-----------------------------------------------------------------------------

CUSTOMITEM:
			dc.l	NULL		; NextItem
			dc.w	90,48		; LeftEdge, TopEdge
			dc.w	64,9		; Width, Height
			dc.w	ITEMENABLED+ITEMTEXT+HIGHCOMP+COMMSEQ	; Flags
			dc.l	NULL		; MutualExclude
			dc.l	CUSTI		; ItemFill
			dc.l	NULL		; SelectFill
			dc.b	"t"		; Command
			even
			dc.l	NULL		; SubItem
			dc.w	NULL		; NextSelect

CUSTI:
			dc.b	1,0		; FrontPen, BackPen
			dc.b	COMPLEMENT,0	; DrawMode, KludgeFill100
			dc.w	0,0		; LeftEdge, TopEdge
			dc.l	NULL		; Font
			dc.l	CUSTTXT		; Text
			dc.l	NULL		; NextText

CUSTTXT:		dc.b	"TAB",0
			even


;-----------------------------------------------------------------------------
;	MENU JUMP TABLE
;-----------------------------------------------------------------------------

MENUJUMPS:
	dc.l	QUITITEM,SUBQUIT		; ItemAddress, ItemExecute
	dc.l	COLORITEM,SUBCOLOR
	dc.l	CUSTOMITEM,SUBCUSTOM
	dc.l	NULL,NULL

;-----------------------------------------------------------------------------
