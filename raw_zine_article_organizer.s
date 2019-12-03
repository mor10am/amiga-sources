
pr_CLI:			equ	$ac		; RunBack process
pr_MsgPort:		equ	$5c
pr_CurrentDir:		equ	$98

ln_Pri:			equ	9

CUSTOMSCREEN:		equ	$000f		; Screen
SCREENQUIET:		equ	$0100

HIRES:			equ	$8000

WINDOWDEPTH:		equ	$0004		; Window
BACKDROP:		equ	$0100
BORDERLESS:		equ	$0800
ACTIVATE:		equ	$1000

MOUSEBUTTONS:		equ	$00000008	; IDCMP
GADGETUP:		equ	$00000040
RAWKEY:			equ	$00000400
DISKINSERTED:		equ	$00008000
DISKREMOVED:		equ	$00010000
VANILLAKEY:		equ	$00200000

GADGHIMAGE:		equ	$0002		; Gadget
GADGIMAGE:		equ	$0004

RELVERIFY:		equ	$0001
GADGIMMIDIATE:		equ	$0002

BOOLGADGET:		equ	$0001

VPORT:			equ	44
RPORT:			equ	50
UPORT:			equ	86

INTUIMESSAGE:		equ	28
USERDATA:		equ	40

SIG:			equ	15

CODE:			equ	20

io_Device:		equ	20
io_Unit:		equ	24
io_Command:		equ	28
io_Flags:		equ	30
io_Error:		equ	31
io_Actual:		equ	32
io_Length:		equ	36
io_Data:		equ	40
io_Offset:		equ	44

CMD_WRITE:		equ	3

pr_WindowPtr:		equ	184

RT_FILEREQ:		equ	0
RT_REQINFO:		equ	1
RT_FONTREQ:		equ	2

RT_FLAGS:		equ	$08
RT_DIR:			equ	$10

FREQB_SAVE:		equ	1
FREQB_NOFILES:		equ	8

READMODE:		equ	-2
FILETYPE:		equ	4
FILESTRING:		equ	8
FILELENGTH:		equ	124

MY_SIZE:		equ	272
MY_NEXT:		equ	0
MY_PREV:		equ	4
MY_NAME:		equ	8
MY_LENGTH:		equ	268

MEMF_CLEAR:		equ	$10000
MEMF_PUBLIC:		equ	$01

MODE_OLD:		equ	1005
MODE_NEW:		equ	1006

LF:			equ	10
TAB:			equ	9

;--------------------------------------------------------------------------

	incdir	"include:"
	include	"misc/lvooffsets.i"

	section	InitRunBack,code

;--------------------------------------------------------------------------

rb_RUNBACK:
	sub.l	a1,a1
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	move.l	d0,a4

	moveq	#0,d0
	tst.l	pr_CLI(a4)
	bne.s	rb_FROMCLI

	lea	pr_MsgPort(a4),a0
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a4),a0
	jsr	_LVOGetMsg(a6)

rb_FROMCLI:
	move.l	d0,d7

	lea	rb_DOSNAME(pc),a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq.s	rb_EXIT1

	move.l	d0,a5
	exg	a5,a6

	move.l	pr_CurrentDir(a4),d1
	jsr	_LVODupLock(a6)
	move.l	d0,rb_CURRENTDIR

	exg	a5,a6
	jsr	_LVOForbid(a6)

	move.l	#rb_PROGNAME,d1
	moveq	#0,d2
	move.b	ln_Pri(a4),d2
	lea	rb_RUNBACK-4(pc),a0
	move.l	(a0),d3
	clr.l	(a0)
	move.l	#4000,d4
	exg	a5,a6
	jsr	_LVOCreateProc(a6)

	exg	a5,a6
	jsr	_LVOPermit(a6)

	move.l	a5,a1
	jsr	_LVOCloseLibrary(a6)

rb_EXIT1:
	tst.l	d7
	beq.s	rb_EXIT2

	jsr	_LVOForbid(a6)

	move.l	d7,a1
	jsr	_LVOReplyMsg(a6)

rb_EXIT2:
	moveq	#0,d0
	rts

rb_DOSNAME:		dc.b	"dos.library",0
			even

;=========================================================================

	section	Program,code

MAIN:
	move.l	4.w,a6
	sub.l	a1,a1
	jsr	_LVOFindTask(a6)
	move.l	d0,MYPROCESS

	bsr.l	MAINPROGRAM

	move.l	4.w,a6
	jsr	_LVOForbid(a6)

	move.l	DOSBASE,a6
	move.l	rb_CURRENTDIR(pc),d1
	jsr	_LVOUnLock(a6)

	lea	MAIN-4(pc),a0
	move.l	a0,d1
	lsr.l	#2,d1
	jsr	_LVOUnLoadSeg(a6)
	moveq	#0,d0
	rts

MYPROCESS:		dc.l	0

rb_CURRENTDIR:		dc.l	0
rb_PROGNAME:		dc.b	"R.A.W. Article Organizer Task",0
			even

;==========================================================================

MAINPROGRAM:
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

	lea	DFLNAME,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)

	move.l	d0,DFLBASE
	beq.w	EXITPRG

;--

	move.l	DFLBASE,a6
	lea	TEXTATTR,a0
	jsr	_LVOOpenDiskFont(a6)

	move.l	d0,TEXTFONT

;--

	move.l	INTBASE,a6
	lea	OSARGS,a0
	jsr	_LVOOpenScreen(a6)

	move.l	d0,SCREEN
	beq.w	EXITPRG

;--

	move.l	SCREEN,SCRPTR
	move.l	SCREEN,SCRPTR2

	move.l	INTBASE,a6
	lea	OWARGS,a0
	jsr	_LVOOpenWindow(a6)

	move.l	d0,WINDOW
	beq.w	EXITPRG

	move.l	INTBASE,a6
	lea	STATWIN,a0
	jsr	_LVOOpenWindow(a6)

	move.l	d0,WINDOW2
	beq.w	EXITPRG

;--

	move.l	4.w,a6
	sub.l	a1,a1
	jsr	_LVOFindTask(a6)

	move.l	d0,PROCSTRUCT
	move.l	d0,a0
	move.l	pr_WindowPtr(a0),OLDPTR
	move.l	WINDOW,pr_WindowPtr(a0)

	move.l	d0,WRITEPORT+$10

	lea	WRITEPORT,a1
	jsr	_LVOAddPort(a6)

	move.w	#1,HASPORT

	lea	WRITEREQ,a0
	move.l	WINDOW2,io_Data(a0)
	move.l	#48,io_Length(a0)

	move.l	4.w,a6
	lea	CONNAME,a0
	move.l	#0,d0
	lea	WRITEREQ,a1
	move.l	#0,d1
	jsr	_LVOOpenDevice(a6)

	move.l	d0,CONERROR
	bne.w	EXITPRG

;--

	move.l	WINDOW,a0
	move.l	UPORT(a0),USERPORT
	move.l	RPORT(a0),RASTPORT

	move.l	SCREEN,a0
	lea	VPORT(a0),a0
	move.l	a0,VIEWPORT

;--

	tst.l	TEXTFONT
	beq.s	NOFONT

	move.l	GFXBASE,a6
	move.l	RASTPORT,a1
	move.l	TEXTFONT,a0
	jsr	_LVOSetFont(a6)

NOFONT:
	move.l	GFXBASE,a6
	move.l	VIEWPORT,a0
	lea	NEWCOLORS,a1
	move.l	#4,d0
	jsr	_LVOLoadRGB4(a6)

;--

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	lea	GADGET1,a1
	move.l	#-1,d0
	jsr	_LVOAddGadget(a6)

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	lea	GADGET4,a1
	move.l	#-1,d0
	jsr	_LVOAddGadget(a6)

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	lea	GADGET5,a1
	move.l	#-1,d0
	jsr	_LVOAddGadget(a6)

	move.l	INTBASE,a6
	lea	GADGET1,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.w	#1,HASGADGETS

;--

	move.l	INTBASE,a6
	move.l	RASTPORT,a0
	lea	ITEXT,a1
	move.l	#0,d0
	move.l	#208,d1
	jsr	_LVOPrintIText(a6)

;--------------------------------------------------------------------------

	moveq	#1,d0
	moveq	#0,d7
	move.l	USERPORT,a0
	move.b	SIG(a0),d7
	bra.s	NEXTSHIFT
SIGLOOP:
	lsl.l	#1,d0
NEXTSHIFT:
	dbf	d7,SIGLOOP

	move.l	d0,SIGN

;--------------------------------------------------------------------------

	lea	READYTXT,a0
	bsr.w	PRINT

;--------------------------------------------------------------------------

GETMESSAGE:
	bsr.s	WAITMSG		; Wait for keystroke/mousebutton/GADGETUP

	move.l	MESSAGE,a0
	lea	CODE(a0),a0

	cmp.l	#GADGETUP,(a0)
	beq.s	CHECKGADGET
	bra.s	GETMESSAGE

;--------------------------------------------------------------------------

EXITPRG:
	bsr.w	CLEANUP
	moveq	#0,d0
	rts

;--------------------------------------------------------------------------

CHKMOUSE:
	move.l	REQBASE,a6
	lea	HIDDEN,a1
	lea	HIDBUT,a2
	sub.l	a3,a3
	sub.l	a4,a4
	sub.l	a0,a0
	jsr	_LVOrtEZRequestA(a6)
	bra	GETMESSAGE

;--------------------------------------------------------------------------

WAITMSG:
	move.l	4.w,a6
	move.l	SIGN,d0
	jsr	_LVOWait(a6)

	and.l	SIGN,d0
	cmp.l	SIGN,d0
	bne.w	WAITMSG

	move.l	USERPORT,a0
	jsr	_LVOGetMsg(a6)

	move.l	d0,MESSAGE
	rts

;--------------------------------------------------------------------------

CHECKGADGET:
	move.l	MESSAGE,a0
	move.l	INTUIMESSAGE(a0),a0
	move.l	USERDATA(a0),a0
	jmp	(a0)

;--------------------------------------------------------------------------

G_QUIT:
	move.l	REQBASE,a6
	lea	QUITTXT,a1
	lea	ASKTXT,a2
	sub.l	a3,a3
	sub.l	a4,a4
	sub.l	a0,a0
	jsr	_LVOrtEZRequestA(a6)
	
	tst.l	d0
	beq	GETMESSAGE
	bra.w	EXITPRG

;--

CLEARBUFFERS:
	lea	ARTICLES,a0
	lea	FILENAME,a1
	lea	FULLNAME,a2
	move.w	#255,d7
CLOOP:	clr.b	(a0)+
	clr.b	(a1)+
	clr.b	(a2)+
	dbf	d7,CLOOP
	rts

G_MAKE:
	bsr.s	CLEARBUFFERS

	clr.l	FIRST
	clr.w	NOFILES

	move.l	INTBASE,a6
	lea	GADGET1,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	jsr	_LVOOffGadget(a6)

	lea	GADGET4,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	jsr	_LVOOffGadget(a6)

;--------------------------------------------------

	move.l	REQBASE,a6
	move.l	#RT_FILEREQ,d0
	sub.l	a0,a0
	jsr	_LVOrtAllocRequestA(a6)

	move.l	d0,REQ
	beq.w	EXITPRG

	move.l	REQ,a1
	move.l	#FREQB_NOFILES,RT_FLAGS(a1)
	lea	FILENAME,a2
	lea	REQTITLE,a3
	sub.l	a0,a0
	jsr	_LVOrtFileRequestA(a6)

	tst.l	d0
	beq.w	OUTFREE

	move.l	REQBASE,a6
	move.l	REQ,a1
	jsr	_LVOrtFreeRequest(a6)

;--------------------------------------------------

	move.l	REQ,a0
	move.l	RT_DIR(a0),a0
	lea	ARTICLES,a1
CPDIR:	move.b	(a0)+,(a1)+
	bne.s	CPDIR

	move.l	a1,DUMMY

	move.l	DOSBASE,a6
	move.l	#ARTICLES,d1
	move.l	#READMODE,d2
	jsr	_LVOLock(a6)

	move.l	d0,LOCKSAVE
	beq.w	ABORT1

	move.l	d0,d1
	move.l	#FILEINFO,d2
	jsr	_LVOExamine(a6)

	move.l	DUMMY,a1
	lea	-2(a1),a1
	cmp.b	#':',(a1)+
	beq.s	BUILD

	move.b	#'/',(a1)

BUILD:
	move.l	DOSBASE,a6
	move.l	LOCKSAVE,d1
	move.l	#FILEINFO,d2
	jsr	_LVOExNext(a6)

	tst.l	d0
	beq.w	BUILTSTRUCT

	lea	FILEINFO,a0
	tst.l	FILETYPE(a0)
	bpl.s	BUILD

	move.l	4.w,a6
	move.l	#MY_SIZE,d0
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	jsr	_LVOAllocMem(a6)

	tst.l	d0
	beq.w	NOMEMORY

	move.l	d0,a0

	tst.l	FIRST
	bne.s	ENTERDATA

	movem.l	d0-d7/a0-a6,-(a7)
	lea	BUILDTXT,a0
	bsr	PRINT
	movem.l	(a7)+,d0-d7/a0-a6

	move.l	a0,FIRST
	move.l	a0,PREVIOUS

	lea	MY_NAME(a0),a1
	bsr	COPYNAME

	lea	FILEINFO,a1
	move.l	FILELENGTH(a1),MY_LENGTH(a0)

	addq.w	#1,NOFILES
	bra.w	BUILD

ENTERDATA:
	move.l	PREVIOUS,a1
	move.l	a0,MY_NEXT(a1)
	move.l	a1,MY_PREV(a0)
	move.l	a0,PREVIOUS

	lea	MY_NAME(a0),a1
	bsr	COPYNAME

	lea	FILEINFO,a1
	move.l	FILELENGTH(a1),MY_LENGTH(a0)

	addq.w	#1,NOFILES
	bra.w	BUILD

;--------------------------------------------------

BUILTSTRUCT:
	move.l	REQBASE,a6
	move.l	#RT_FILEREQ,d0
	sub.l	a0,a0
	jsr	_LVOrtAllocRequestA(a6)

	move.l	d0,REQ
	beq.w	CLEANMEMORY

	move.l	REQ,a1
	lea	FILENAME,a2
	lea	REQTITLE,a3
	sub.l	a0,a0
	jsr	_LVOrtFileRequestA(a6)

	tst.l	d0
	beq.w	OUTFREE

;----------------------------------------------------------------------

	moveq	#0,d1
	lea	ARTICLES,a0
CNTL:	addq.w	#1,d1
	tst.b	(a0)+
	bne.s	CNTL
	subq.w	#1,d1

	move.w	d1,SKIPPATH

;----------------------------------------------------------------------

	lea	FULLNAME,a1

	move.l	REQ,a0
	move.l	RT_DIR(a0),a0
DIRLOOP:
	move.b	(a0)+,(a1)+
	bne.s	DIRLOOP

	lea	-2(a1),a1
	cmp.b	#':',(a1)+
	beq.s	GOONDIR

	move.b	#'/',(a1)+

GOONDIR:
	lea	FILENAME,a0
FNLOOP:
	move.b	(a0)+,(a1)+
	bne.s	FNLOOP

	bra	OPENSAVE

;----------------------------------------------------------------------

OUTFREE:
	move.l	REQBASE,a6
	move.l	REQ,a1
	jsr	_LVOrtFreeRequest(a6)
	bra	ABORT2

;----------------------------------------------------------------------

OPENSAVE:
	move.l	REQBASE,a6
	move.l	REQ,a1
	jsr	_LVOrtFreeRequest(a6)

	move.l	DOSBASE,a6
	move.l	#FULLNAME,d1
	move.l	#MODE_NEW,d2
	jsr	_LVOOpen(a6)

	move.l	d0,SAVELOCK
	beq.w	ABORT3

;----------------------------------------------------------------------

DOSORTING:
	moveq	#0,d0
	move.w	NOFILES,d0
	beq.w	NOCANDO

	lsl.l	#3,d0

	move.l	4.w,a6
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	jsr	_LVOAllocMem(a6)

	move.l	d0,FILELIST
	beq.w	NOMEMORY

	lea	SORTTXT,a0
	bsr	PRINT

;----------------------------------------------------------------------

	moveq	#0,d0
	move.w	SKIPPATH,d0
	move.l	FILELIST,a1

	moveq	#0,d7
	move.w	NOFILES,d7
	subq.w	#1,d7
BLOOP:
	move.l	FIRST,a0
	move.l	a0,(a1)+

	lea	MY_NAME(a0),a2
	lea	(a2,d0.w),a2

	move.w	#3,d6
NAMELOOP:
	move.b	(a2)+,(a1)+
	dbf	d6,NAMELOOP

	move.l	MY_NEXT(a0),FIRST
	dbf	d7,BLOOP

	bsr	SORTFILELIST

;----------------------------------------------------------------------

	lea	OFFTXT,a0
	bsr	PRINT

	moveq	#0,d0
	move.w	NOFILES,d0
	mulu	#12,d0
	move.l	d0,OFFSETSIZE

	move.l	FILELIST,a0
	move.l	OFFSETSIZE,d0

	move.w	SKIPPATH,d1

	move.w	NOFILES,d7
	subq.w	#1,d7
OFFLOOP:
	move.l	(a0)+,a1
	lea	4(a0),a0		; skip name in FILELIST

	lea	OFFSETDATA,a2
	move.l	d0,(a2)+
	add.l	MY_LENGTH(a1),d0
	move.l	MY_LENGTH(a1),(a2)+
	lea	MY_NAME(a1),a1
	lea	(a1,d1.w),a1

	move.w	#3,d6
FNAMEL:	move.b	(a1)+,(a2)+
	dbf	d6,FNAMEL

	movem.l	d0-d7/a0-a6,-(a7)

	move.l	DOSBASE,a6
	move.l	SAVELOCK,d1
	move.l	#OFFSETDATA,d2
	move.l	#12,d3
	jsr	_LVOWrite(a6)

	movem.l	(a7)+,d0-d7/a0-a6

	dbf	d7,OFFLOOP	

;----------------------------------------------------------------------

	move.l	FILELIST,a0

	move.w	NOFILES,d7
	subq.w	#1,d7
PROCLOOP:	
	move.l	(a0)+,a1
	lea	4(a0),a0
	
	move.l	a7,OLDSTACK

	movem.l	d0-d7/a0-a6,-(a7)

	move.l	4.w,a6
	move.l	MY_LENGTH(a1),d0
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	jsr	_LVOAllocMem(a6)

	move.l	d0,DUMMY
	beq.w	ABORT4

	movem.l	(a7)+,d0-d7/a0-a6

	movem.l	d0-d7/a0-a6,-(a7)

	move.l	DOSBASE,a6
	lea	MY_NAME(a1),a1
	move.l	a1,d1
	move.l	#MODE_OLD,d2
	jsr	_LVOOpen(a6)

	move.l	d0,DUMLOCK

	movem.l	(a7)+,d0-d7/a0-a6

	movem.l	d0-d7/a0-a6,-(a7)
	lea	PROCTXT,a0
	bsr	PRINT
	movem.l	(a7)+,d0-d7/a0-a6

	movem.l	d0-d7/a0-a6,-(a7)
	lea	MY_NAME(a1),a0
	bsr	PRINT

	lea	TERMINATE,a0
	bsr	PRINT
	movem.l	(a7)+,d0-d7/a0-a6

	movem.l	d0-d7/a0-a6,-(a7)

	move.l	DOSBASE,a6
	move.l	DUMLOCK,d1
	move.l	DUMMY,d2
	move.l	MY_LENGTH(a1),d3
	jsr	_LVORead(a6)

	movem.l	(a7)+,d0-d7/a0-a6

	movem.l	d0-d7/a0-a6,-(a7)

	move.l	DOSBASE,a6
	move.l	SAVELOCK,d1
	move.l	DUMMY,d2
	move.l	MY_LENGTH(a1),d3
	jsr	_LVOWrite(a6)

	movem.l	(a7)+,d0-d7/a0-a6

	movem.l	d0-d7/a0-a6,-(a7)

	move.l	4.w,a6
	move.l	MY_LENGTH(a1),d0
	move.l	DUMMY,a1
	jsr	_LVOFreeMem(a6)

	movem.l	(a7)+,d0-d7/a0-a6

	dbf	d7,PROCLOOP

;----------------------------------------------------------------------

	move.l	DOSBASE,a6
	move.l	SAVELOCK,d1
	jsr	_LVOClose(a6)

	lea	FREETXT,a0
	bsr	PRINT

AB4EXIT:
	moveq	#0,d0
	move.w	NOFILES,d0
	lsl.l	#3,d0

	move.l	4.w,a6
	move.l	FILELIST,a1
	jsr	_LVOFreeMem(a6)

	bra	CLEANMEMORY

;--------------------------------------------------------------------------

OUTMAKE:
	move.l	INTBASE,a6
	lea	GADGET1,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	jsr	_LVOOnGadget(a6)

	lea	GADGET4,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	jsr	_LVOOnGadget(a6)

	move.l	INTBASE,a6
	lea	GADGET1,a0
	move.l	WINDOW,a1
	sub.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	lea	READYTXT,a0
	bsr	PRINT

	bra.w	GETMESSAGE

;--------

ABORT1:
	lea	NOLOCK,a0
	bsr	PRINT
	bra.s	OUTMAKE

ABORT2:
	lea	FILENOT,a0
	bsr	PRINT
	bra	CLEANMEMORY

ABORT3:
	lea	SAVENOT,a0
	bsr	PRINT
	bra	CLEANMEMORY

ABORT4:
	move.l	OLDSTACK,a7

	lea	NOMEM2,a0
	bsr	PRINT

	move.l	DOSBASE,a6
	move.l	SAVELOCK,d1
	jsr	_LVOClose(a6)
	bra	AB4EXIT


NOCANDO:
	lea	NOFIL,a0
	bsr	PRINT
	bra.w	OUTMAKE

;--------------------------------------------------------------------------

NOMEMORY:
	lea	NOMEM,a0
	bsr	PRINT

CLEANMEMORY:
	move.l	FIRST,a0
	
	tst.l	FIRST
	beq.s	DONEMEM

	move.l	MY_NEXT(a0),FIRST

	move.l	4.w,a6
	move.l	a0,a1
	move.l	#MY_SIZE,d0
	jsr	_LVOFreeMem(a6)

	bra.s	CLEANMEMORY

DONEMEM:
	bra.w	OUTMAKE	

;--------------------------------------------------------------------------

COPYNAME:
	lea	ARTICLES,a2
CPART:	move.b	(a2)+,(a1)+
	bne.s	CPART

	lea	-1(a1),a1
	
	lea	FILEINFO,a2
	lea	FILESTRING(a2),a2

CPSTR:	move.b	(a2)+,(a1)+
	bne.s	CPSTR

	lea	MY_NAME(a0),a1
	bsr	UCASESTRING

	movem.l	d0-d7/a0-a6,-(a7)

	move.l	a0,-(a7)
	lea	APPENDTXT,a0
	bsr	PRINT
	move.l	(a7)+,a0

	lea	MY_NAME(a0),a0
	bsr	PRINT

	lea	TERMINATE,a0
	bsr	PRINT

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;--------------------------------------------------------------------------

UCASESTRING:
	move.b	(a1),d0
	beq.s	DONECASE

	cmp.b	#'a',d0
	blt.s	OKCASE
	cmp.b	#'z',d0
	bgt.s	OKCASE

	sub.b	#32,d0

OKCASE:
	move.b	d0,(a1)+
	bra.s	UCASESTRING
	
DONECASE:
	rts	

;--------------------------------------------------------------------------

SORTFILELIST:
	movem.l	d0-d7/a0-a6,-(a7)

	move.w	NOFILES,d6
	subq.w	#1,d6

RESETLOOP:
	move.l	FILELIST,a0			; Addresses
	lea	4(a0),a1			; Filenames ( 4 bytes)

	move.l	FILELIST,a2
	lea	8(a2),a2
	lea	4(a2),a3

	moveq	#0,d0
	move.w	NORESET,d0
	lsl.l	#3,d0

	add.l	d0,a0
	add.l	d0,a1
	add.l	d0,a2
	add.l	d0,a3

	move.w	NORESET,NOBIGGER

SORTLOOP:
	move.l	(a1),d0
	move.l	(a3),d1
	cmp.l	d0,d1
	bge.s	INC2

	move.l	d1,(a1)
	move.l	d0,(a3)

	move.l	(a0),d0
	move.l	(a2),d1
	move.l	d1,(a0)
	move.l	d0,(a2)
	bra.s	RESETLOOP	

DONESORT:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

INC2:
	lea	8(a2),a2
	lea	8(a3),a3
	
	addq.w	#1,NOBIGGER
	cmp.w	NOBIGGER,d6	
	bgt.s	SORTLOOP

	addq.w	#1,NORESET
	cmp.w	NORESET,d6
	bgt.s	RESETLOOP

	bra.s	DONESORT

NORESET:		dc.w	0
NOBIGGER:		dc.w	0

;------------------------------------------------------------------------------


PRINT:
	move.l	4.w,a6
	lea	WRITEREQ,a1
	move.l	#WRITEPORT,14(a1)
	move.w	#CMD_WRITE,io_Command(a1)
	move.l	#-1,io_Length(a1)
	move.l	a0,io_Data(a1)
	jsr	_LVODoIO(a6)
	rts

;--------------------------------------------------------------------------

CLEANUP:
	bsr.s	REMGADS
	bsr.s	SETWINPTR
	bsr.s	CLOSEDEV
	bsr.s	CLOSEPORT
	bsr.w	CLOSESTAT
	bsr.w	CLOSEWIN
	bsr.w	CLOSESCR
	bsr.w	CLOSEFNT
	bsr.w	CLOSEDFL
	bsr.w	CLOSEREQ
	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT
	bsr.w	CLOSEDOS
NOPE:	rts

;--

SETWINPTR:
	tst.l	OLDPTR
	beq.s	NOPE

	move.l	PROCSTRUCT,a0
	move.l	OLDPTR,pr_WindowPtr(a0)
	rts

;--

REMGADS:
	tst.w	HASGADGETS
	beq.s	NOPE

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	lea	GADGET1,a1
	jsr	_LVORemoveGList(a6)
	rts

;--

CLOSEPORT:
	tst.w	HASPORT
	beq.s	NOPE

	move.l	4.w,a6
	lea	WRITEPORT,a1
	jsr	_LVORemPort(a6)
	rts

;--

CLOSEDEV:
	tst.l	CONERROR
	bne.s	NOPE

	move.l	4.w,a6
	lea	WRITEREQ,a1
	jsr	_LVOCloseDevice(a6)
	rts

;--

CLOSESTAT:
	tst.l	WINDOW2
	beq.s	NOPE

	move.l	INTBASE,a6
	move.l	WINDOW2,a0
	jsr	_LVOCloseWindow(a6)
	rts

;--

CLOSEWIN:
	tst.l	WINDOW
	beq.w	NOPE

	move.l	INTBASE,a6
	move.l	WINDOW,a0
	jsr	_LVOCloseWindow(a6)
	rts

;--

CLOSESCR:
	tst.l	SCREEN
	beq.w	NOPE

	move.l	INTBASE,a6
	move.l	SCREEN,a0
	jsr	_LVOCloseScreen(a6)
	rts

;--

CLOSEFNT:
	tst.l	TEXTFONT
	beq.w	NOPE

	move.l	GFXBASE,a6
	move.l	TEXTFONT,a1
	jsr	_LVOCloseFont(a6)
	rts

;--

CLOSEDFL:
	tst.l	DFLBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	DFLBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

;--

CLOSEREQ:
	tst.l	REQBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	REQBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

;--

CLOSEINT:
	tst.l	INTBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	INTBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

;--

CLOSEGFX:
	tst.l	GFXBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	GFXBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

;--

CLOSEDOS:
	tst.l	DOSBASE
	beq.w	NOPE

	move.l	4.w,a6
	move.l	DOSBASE,a1
	jsr	_LVOCloseLibrary(a6)
	rts

;--

;--------------------------------------------------------------------------

PROCSTRUCT:		dc.l	0
OLDPTR:			dc.l	0

GFXBASE:		dc.l	0
INTBASE:		dc.l	0
DOSBASE:		dc.l	0
REQBASE:		dc.l	0
DFLBASE:		dc.l	0
CONERROR:		dc.l	0

DOSNAME:		dc.b	"dos.library",0
INTNAME:		dc.b	"intuition.library",0
GFXNAME:		dc.b	"graphics.library",0
DFLNAME:		dc.b	"diskfont.library",0
REQNAME:		dc.b	"reqtools.library",0
CONNAME:		dc.b	"console.device",0
			even

;--------------------------------------------------------------------------

WRITEREQ:
	blk.b	20,0			; io_Message
	dc.l	0			; io_Device
	dc.l	0			; io_Unit
	dc.w	0			; io_Command
	dc.b	0			; io_Flags
	dc.b	0			; io_Error
	dc.l	0			; io_Actual
	dc.l	0			; io_Length
	dc.l	0			; io_Data
	dc.l	0			; io_Offset

HASPORT:		dc.w	0

WRITEPORT:
	dc.l	0			; Succ
	dc.l	0			; Pred
	dc.b	0			; Type
	dc.b	0			; Pri
	dc.l	0			; Name
	dc.b	0			; Flags
	dc.b	0			; SigBit
	dc.l	0			; SigTask
	blk.b	14,0			; MsgList

;--------------------------------------------------------------------------

VIEWPORT:		dc.l	0
RASTPORT:		dc.l	0
USERPORT:		dc.l	0
WINPORT:		dc.l	0

IDCMP:			dc.l	0
MESSAGE:		dc.l	0
SIGN:			dc.l	0

;--------------------------------------------------------------------------

SCREEN:			dc.l	0

OSARGS:
	dc.w	0,0				; LeftEdge, TopEdge
	dc.w	640,256				; Width, Height
	dc.w	2				; Depth
	dc.b	3,2				; DetailPen, BlockPen
	dc.w	HIRES				; ViewModes
	dc.w	CUSTOMSCREEN			; Type
	dc.l	TEXTATTR			; Font
	dc.l	RAWTITLE			; Title
	dc.l	NULL				; Gadgets
	dc.l	NULL				; CustomBitmap

RAWTITLE:		dc.b	"RAW Article Organizer v1.0",0
			even

;--------------------------------------------------------------------------

WINDOW:		dc.l	0

OWARGS:
	dc.w	0,0			; LeftEdge, TopEdge
	dc.w	640,256			; Width, Height
	dc.b	1,0			; DetailPen, BlockPen
	dc.l	GADGETUP		; IDCMPFlags
	dc.l	BACKDROP+BORDERLESS+ACTIVATE		; Flags
	dc.l	NULL			; FirstGadget
	dc.l	NULL			; CheckMark
	dc.l	NULL			; Title
SCRPTR:	dc.l	0			; Screen
	dc.l	NULL			; Bitmap
	dc.w	640,256			; MinWidth, MinHeight
	dc.w	640,256			; MaxWidth, MaxHeight
	dc.w	CUSTOMSCREEN		; Type		

;--

WINDOW2:		dc.l	0

STATWIN:
	dc.w	0,32			; LeftEdge, TopEdge
	dc.w	640,166			; Width, Height
	dc.b	2,3			; DetailPen, BlockPen
	dc.l	NULL			; IDCMPFlags
	dc.l	WINDOWDEPTH		; Flags
	dc.l	NULL			; FirstGadget
	dc.l	NULL			; CheckMark
	dc.l	STATUSTXT		; Title
SCRPTR2:dc.l	0			; Screen
	dc.l	NULL			; Bitmap
	dc.w	640,166			; MinWidth, MinHeight
	dc.w	640,166			; MaxWidth, MaxHeight
	dc.w	CUSTOMSCREEN		; Type		

STATUSTXT:	dc.b	"Status",0
		even

;--------------------------------------------------------------------------

TEXTFONT:	dc.l	0

TEXTATTR:
	dc.l	FONTNAME
	dc.w	8
	dc.b	0
	dc.b	0

FONTNAME:	dc.b	"topaz.font",0
		even

;--------------------------------------------------------------------------

NEWCOLORS:		dc.w	$888,$ba9,$444,$fff

;--------------------------------------------------------------------------

HASGADGETS:		dc.w	0

UNSELBORDER:
	dc.w	0,0			; LeftEdge, TopEdge
	dc.b	3,0			; FrontPen, BackPen
	dc.b	0			; DrawMode
	dc.b	3			; Count
	dc.l	UNSELXY1		; XY
	dc.l	UNSEL2			; NextBorder	

UNSELXY1:
	dc.w	000,016
	dc.w	000,000
	dc.w	128,000

UNSEL2:
	dc.w	0,0			; LeftEdge, TopEdge
	dc.b	2,0			; FrontPen, BackPen
	dc.b	0			; DrawMode
	dc.b	3			; Count
	dc.l	UNSELXY2		; XY
	dc.l	NULL			; NextBorder	

UNSELXY2:
	dc.w	000,016
	dc.w	128,016
	dc.w	128,000

;--

SELBORDER:
	dc.w	0,0			; LeftEdge, TopEdge
	dc.b	2,0			; FrontPen, BackPen
	dc.b	0			; DrawMode
	dc.b	3			; Count
	dc.l	SELXY1			; XY
	dc.l	SEL2			; NextBorder	

SELXY1:
	dc.w	000,016
	dc.w	000,000
	dc.w	128,000

SEL2:
	dc.w	0,0			; LeftEdge, TopEdge
	dc.b	3,0			; FrontPen, BackPen
	dc.b	0			; DrawMode
	dc.b	3			; Count
	dc.l	SELXY2			; XY
	dc.l	NULL			; NextBorder	

SELXY2:
	dc.w	000,016
	dc.w	128,016
	dc.w	128,000

;--

GADGET1:
	dc.l	GADGET4			; NextGadget
	dc.w	8,12			; LeftEdge, TopEdge
	dc.w	128,16			; Width, Height
	dc.w	GADGHIMAGE		; Flags
	dc.w	RELVERIFY+GADGIMMIDIATE	; Activation
	dc.w	BOOLGADGET		; GadgetType
	dc.l	UNSELBORDER		; GadgetRender
	dc.l	SELBORDER		; SelectRender
	dc.l	GTEXT1			; GadgetText
	dc.l	NULL			; MutualExclude
	dc.l	NULL			; SpecialInfo
	dc.w	0			; GadgetID
	dc.l	G_QUIT			; UserData

GTEXT1:
	dc.b	1,0			; FrontPen, BackPen
	dc.b	0,0			; DrawMode, KludgeFill100
	dc.w	48,4			; LeftEdge, TopEdge
	dc.l	NULL			; Font
	dc.l	GLINE1			; Text
	dc.l	NULL			; Next

GLINE1:		dc.b	"Quit",0
		even

;--

GADGET4:
	dc.l	GADGET5			; NextGadget
	dc.w	488,12			; LeftEdge, TopEdge
	dc.w	128,16			; Width, Height
	dc.w	GADGHIMAGE		; Flags
	dc.w	RELVERIFY+GADGIMMIDIATE	; Activation
	dc.w	BOOLGADGET		; GadgetType
	dc.l	UNSELBORDER		; GadgetRender
	dc.l	SELBORDER		; SelectRender
	dc.l	GTEXT4			; GadgetText
	dc.l	NULL			; MutualExclude
	dc.l	NULL			; SpecialInfo
	dc.w	0			; GadgetID
	dc.l	G_MAKE			; UserData

GTEXT4:
	dc.b	1,0			; FrontPen, BackPen
	dc.b	0,0			; DrawMode, KludgeFill100
	dc.w	28,4			; LeftEdge, TopEdge
	dc.l	NULL			; Font
	dc.l	GLINE4			; Text
	dc.l	NULL			; Next

GLINE4:		dc.b	"Make File",0
		even

;--

GADGET5:
	dc.l	NULL			; NextGadget
	dc.w	630,250			; LeftEdge, TopEdge
	dc.w	10,5			; Width, Height
	dc.w	NULL			; Flags
	dc.w	RELVERIFY+GADGIMMIDIATE	; Activation
	dc.w	BOOLGADGET		; GadgetType
	dc.l	NULL			; GadgetRender
	dc.l	NULL			; SelectRender
	dc.l	NULL			; GadgetText
	dc.l	NULL			; MutualExclude
	dc.l	NULL			; SpecialInfo
	dc.w	0			; GadgetID
	dc.l	CHKMOUSE		; UserData

;--

ITEXT:
	dc.b	1,0			; FrontPen, BackPen
	dc.b	0,0			; DrawMode, KludgeFill100
	dc.w	0,0			; LeftEdge, TopEdge
	dc.l	NULL			; Font
	dc.l	LINE1			; Text
	dc.l	ITEXT2			; Next

LINE1:		dc.b	"RAW Article Organizer v1.0",0
		even

;--

ITEXT2:
	dc.b	1,0			; FrontPen, BackPen
	dc.b	0,0			; DrawMode, KludgeFill100
	dc.w	0,9			; LeftEdge, TopEdge
	dc.l	NULL			; Font
	dc.l	LINE2			; Text
	dc.l	ITEXT3			; Next

LINE2:		dc.b	'by Morten "Pushead" Amundsen',0
		even

;--

ITEXT3:
	dc.b	1,0			; FrontPen, BackPen
	dc.b	0,0			; DrawMode, KludgeFill100
	dc.w	0,18			; LeftEdge, TopEdge
	dc.l	NULL			; Font
	dc.l	LINE3			; Text
	dc.l	ITEXT4			; Next

LINE3:		dc.b	"Copyright (c) February 1993 by Pure Metal Coders",0
		even

;--

ITEXT4:
	dc.b	1,0			; FrontPen, BackPen
	dc.b	0,0			; DrawMode, KludgeFill100
	dc.w	0,27			; LeftEdge, TopEdge
	dc.l	NULL			; Font
	dc.l	LINE4			; Text
	dc.l	NULL			; Next

LINE4:		dc.b	"All Rights Reserved",0
		even

;---------------------------------------------------------------------------

OFFSETDATA:		blk.b	12,0

SKIPPATH:		dc.w	0

SAVELOCK:		dc.l	0
OFFSETSIZE:		dc.l	0

NOFILES:		dc.w	0
FILELIST:		dc.l	0

OLDSTACK:		dc.l	0

DUMLOCK:		dc.l	0
DUMMY:			dc.l	0
FIRST:			dc.l	0
PREVIOUS:		dc.l	0

LOCKSAVE:		dc.l	0
			cnop	0,4
FILEINFO:		blk.l	260,0

REQ:			dc.l	0
ARTICLES:		blk.b	256,0
FILENAME:		blk.b	256,0
FULLNAME:		blk.b	256,0
REQTITLE:		dc.b	"R.A.O. Filerequester",0
			even

READYTXT:		dc.b	"Ready.",10,0
FILENOT:		dc.b	"** ERROR! No Filename Or Unknown Path!",10,0
SAVENOT:		dc.b	"** ERROR! Could Not Open File!",10,0
NOLOCK:			dc.b	"** ERROR! Could Not Get Lock On Path!",10,0
NOMEM:			dc.b	"** ERROR! Could Not Allocate Memory For "
			dc.b	"Structure!",10,0
NOMEM2:			dc.b	"** ERROR! Could Not Allocate Memory For "
			dc.b	"File!",10,0
NOFIL:			dc.b	"** ERROR! Directory Was Empty!",10,0
BUILDTXT:		dc.b	"Building Structure...",10,0
OFFTXT:			dc.b	"Calculating And Saving Offset-table...",10,0
SORTTXT:		dc.b	"Sorting Article Structure...",10,0
FREETXT:		dc.b	"Freeing Structure Memory...",10,10,0
APPENDTXT:		dc.b	'APPENDING: "',0
PROCTXT:		dc.b	'PROCESSING: "',0
TERMINATE:		dc.b	'"',10,0

QUITTXT:		dc.b	"Finished Organizing The Articles?",0
ASKTXT:			dc.b	"Yes|No",0

HIDDEN:		dc.b	"Hidden text, ",10	
		dc.b	"Regards, Pushead",0
HIDBUT:		dc.b	"So Long, And Thanks For All The Fish!",0
