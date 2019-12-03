;-----------------------------------------------------------------------------
; BenchKeyz Mk.II						   29-Apr-1995
; by Morten Amundsen
;
; Coded in AsmOne 1.25
;-----------------------------------------------------------------------------

VERSION	= 39						; kick version
WB	= 0						; wb startup (0=no)

;-----------------------------------------------------------------------------

NAME:	MACRO
	dc.b	"benchkeyz "
	ENDM

VER:	MACRO
	dc.b	"1"
	ENDM

REV:	MACRO
	dc.b	"0"
	ENDM

DATE:	MACRO
	dc.b	"(29.4.95)"
	ENDM

VERSTR:	MACRO
	dc.b	"$VER: "
	NAME
	VER
	dc.b	"."
	REV
	dc.b	" "
	DATE
	dc.b	10,13,0
	ENDM

;-----------------------------------------------------------------------------

	incdir	"include:"
	include	"misc/lvooffsets.i"
	include	"misc/macros.i"

    include 'exec/types.i'
    include 'intuition/intuition.i'
    include 'intuition/classes.i'
    include 'intuition/classusr.i'
    include 'intuition/imageclass.i'
    include 'intuition/gadgetclass.i'
    include 'libraries/gadtools.i'
    include 'graphics/displayinfo.i'
    include 'graphics/gfxbase.i'

	include	"libraries/reqtools.i"
	include	"exec/memory.i"
	include	"libraries/commodities.i"

OpenScreenTagList    EQU    -612
OpenWindowTagList    EQU    -606
CloseScreen          EQU    -66
CloseWindow          EQU    -72
PrintIText           EQU    -216
LockPubScreen        EQU    -510
UnlockPubScreen      EQU    -516
SetMenuStrip         EQU    -264
ClearMenuStrip       EQU    -54
GetVisualInfoA       EQU    -126
FreeVisualInfo       EQU    -132
CreateContext        EQU    -114
CreateGadgetA        EQU    -30
GT_RefreshWindow     EQU    -84
FreeGadgets          EQU    -36
CreateMenusA         EQU    -48
LayoutMenusA         EQU    -66
FreeMenus            EQU    -54
OpenDiskFont         EQU    -30
CloseFont            EQU    -78
DrawBevelBoxA        EQU    -120
FreeClass            EQU    -714
NewObjectA           EQU    -636
DisposeObject        EQU    -642
TextLength           EQU    -54
CopyMem              EQU    -624
FindTagItem          EQU    -30
IntuiTextLength      EQU    -330
Forbid               EQU    -132
Permit               EQU    -138

GD_ITEMS                               EQU    0
GD_TITLES                              EQU    1
GD_COMMSEQ                             EQU    2
GD_UPDATE                              EQU    3

BKeyz_CNT    EQU    4

 STRUCTURE	bk,0
	STRUCT	bk_Node,LN_SIZE
	APTR	bk_MenuItem
	UWORD	bk_PrefsNum
	LABEL	bk_SIZEOF

;----------------------------------------------------------------------------

	XDEF	_main

_main:	movem.l	d0-d7/a0-a6,-(a7)

	IF WB
	bsr.w	FIND_WBMSG
	ENDIF

	OPENLIB	DOSName,VERSION,_DOSBase
	beq.w	EXIT
	OPENLIB	GfxName,VERSION,_GfxBase
	beq.w	EXIT
	OPENLIB	CxName,VERSION,_CxBase
	beq.w	EXIT
	OPENLIB	GadToolsName,VERSION,_GadToolsBase
	beq.w	EXIT
	OPENLIB	IntuitionName,VERSION,_IntuitionBase
	beq.w	EXIT
	OPENLIB	ReqToolsName,38,_ReqToolsBase

; open reqtools handle

	tst.l	_ReqToolsBase
	beq.s	CHECK_WBTASK

	moveq	#RT_REQINFO,d0
	sub.l	a0,a0
	CALL	rtAllocRequestA,_ReqToolsBase
	move.l	d0,_ReqInfo

; check to see if workbench is running

CHECK_WBTASK:
	lea	WBName,a0
	EXEC	FindTask		; find 'Workbench' task
	tst.l	d0
	bne.s	LOAD_PREFS

	tst.l	_ReqInfo
	beq.w	EXIT

	lea	ERR_NoWB,a1
	lea	TXT_Continue,a2
	move.l	_ReqInfo,a3
	sub.l	a4,a4
	lea	REQ_Tags,a0
	CALL	rtEZRequestA,_ReqToolsBase
	bra.w	EXIT

; load preference file

LOAD_PREFS:











; get menustrip(menuitem) information

GET_MENUSTRIP:
	lea	WBName,a0
	CALL	LockPubScreen,_IntuitionBase
	move.l	d0,_WBScreen
	beq.w	EXIT

	moveq	#0,d7

	bsr.w	GET_WBWINDOW
	tst.w	d7
	bne.s	.UNLCK

	move.l	a0,_WBWindow
	move.l	wd_MenuStrip(a0),_MenuStrip	; ...get its menustrip
	bne.s	.STEAL

	moveq	#1,d7
	bra.w	.UNLCK

.STEAL:	bsr.w	COPY_MENUSTRIP			; snapshot!
	bne.s	.UNLCK

	moveq	#1,d7

.UNLCK:	lea	WBName,a0
	move.l	_WBScreen,a1
	CALL	UnlockPubScreen,_IntuitionBase

	tst.w	d7
	bne.w	EXIT

; apply changes to menustrip (prefs file)

	move.l	_WBWindow,a0
	CALL	ClearMenuStrip,_IntuitionBase

	move.l	_WBScreen,a0
	sub.l	a1,a1
	CALL	GetVisualInfoA,_GadToolsBase
	move.l	d0,_VInfo

	move.l	_MenuStrip,a0
	move.l	d0,a1
	sub.l	a2,a2
	CALL	LayoutMenusA,_GadToolsBase

	move.l	_WBWindow,a0
	move.l	_MenuStrip,a1
	CALL	SetMenuStrip,_IntuitionBase

	move.l	_VInfo,a0
	CALL	FreeVisualInfo,_GadToolsBase

; initialize and setup cx broker

	move.l	#NewBroker_SIZEOF,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,_NewBroker
	beq.w	EXIT

	EXEC	CreateMsgPort
	move.l	d0,_CxPort
	beq.w	EXIT

	move.l	d0,a0
	
	moveq	#0,d0
	moveq	#0,d1
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	move.l	d0,CxSigSet

	move.l	_NewBroker,a0
	move.b	#NB_VERSION,nb_Version(a0)
	move.l	#Broker_Name,nb_Name(a0)
	move.l	#Broker_Title,nb_Title(a0)
	move.l	#Broker_Descr,nb_Descr(a0)
	move.l	_CxPort,nb_Port(a0)
	move.w	#COF_SHOW_HIDE,nb_Flags(a0)
	move.w	#NBU_UNIQUE!NBU_NOTIFY,nb_Unique(a0)
	moveq	#0,d0
	CALL	CxBroker,_CxBase
	move.l	d0,_CxBroker
	beq.w	EXIT

	move.l	_CxBroker,a0
	moveq	#TRUE,d0
	CALL	ActivateCxObj,_CxBase

; init listview setup screen and open window

	bsr.w	SetupScreen
	bne.w	EXIT

	bsr.w	OpenBKeyzWindow
	bne.w	CLOSE_SCREEN

; the mainloop of benchkeyz

MAINLOOP:
	tst.w	ExitFlag
	bne.w	CLOSE_ALL

	move.l	#SIGBREAKF_CTRL_C,d0
	or.l	CxSigSet,d0

	tst.l	WndSigSet
	beq.s	.WAIT

	or.l	WndSigSet,d0

.WAIT:	EXEC	Wait

	move.l	d0,d1
	and.l	CxSigSet,d1
	bne.w	COMMODITY_EVENT
	
	move.l	d0,d1
	and.l	#SIGBREAKF_CTRL_C,d1
	bne.w	CLOSE_ALL

	tst.l	WndSigSet
	beq.s	MAINLOOP

	move.l	d0,d1
	and.l	WndSigSet,d1
	beq.s	MAINLOOP

WINDOWLOOP:
	tst.l	_WindowPort
	beq.s	MAINLOOP

	move.l	_WindowPort,a0
	CALL	GT_GetIMsg,_GadToolsBase
	move.l	d0,_IMessage
	beq.s	MAINLOOP

	move.l	d0,a0
	move.l	im_Class(a0),d0

	cmp.l	#IDCMP_GADGETUP,d0
	bne.s	NOT_GADGETUP

	move.l	im_IAddress(a0),a1
	move.w	gg_GadgetID(a1),d0

	cmp.w	#GD_ITEMS,d0
	beq.w	PICK_MENUITEM
	cmp.w	#GD_TITLES,d0
	beq.w	PICK_MENUTITLE
	cmp.w	#GD_COMMSEQ,d0
	beq.w	SET_COMMSEQ
	cmp.w	#GD_UPDATE,d0
	beq.w	UPDATE_LISTS
	bra.s	WREPLY

NOT_GADGETUP:
	cmp.l	#IDCMP_CHANGEWINDOW,d0
	bne.s	NOT_CHANGEWINDOW

	move.l	im_IDCMPWindow(a0),a0
	move.w	wd_LeftEdge(a0),BKeyzLeft
	move.w	wd_TopEdge(a0),BKeyzTop
	bra.s	WREPLY

NOT_CHANGEWINDOW:
	cmp.l	#IDCMP_MENUPICK,d0
	bne.s	NOT_MENUPICK


	bra.w	WREPLY

NOT_MENUPICK:
	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	WREPLY

	bsr.w	CloseBKeyzWindow
	bra.w	WINDOWLOOP

WREPLY:	move.l	_IMessage,a1
	CALL	GT_ReplyIMsg,_GadToolsBase
	bra.w	WINDOWLOOP

;----------------------------------------------------------------------------

GET_WBWINDOW:
	move.l	_WBScreen,a0
	move.l	sc_FirstWindow(a0),a0
.LOOP:	move.l	wd_Flags(a0),d0
	and.l	#WFLG_WBENCHWINDOW,d0		; find workbench window

	tst.l	d0
	bne.s	.WB

	move.l	wd_NextWindow(a0),a0
	cmp.l	#NULL,a0
	bne.w	.LOOP

	moveq	#1,d7
.WB:	rts

;---------------------------------------------------------------------------

PICK_MENUTITLE:
	moveq	#0,d0
	move.w	im_Code(a0),d0
	move.w	LastTitle,d1
	cmp.w	d0,d1
	beq.w	.NOT

	move.w	d0,LastTitle

	lea	ActTitleTag,a0
	move.l	d0,ti_Data(a0)

	move.l	d0,-(a7)
	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	DetachTag,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
	move.l	(a7)+,d0

	move.l	_MenuLists,a4
	mulu	#LH_SIZE,d0
	lea	(a4,d0.w),a4
	move.l	a4,_CurrentList

	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	SetListTag,a3
	move.l	a4,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	lea	BKeyzGadgets,a0
	move.l	8(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	ShowKeyTag,a3
	move.l	#NULL,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
	
	move.l	#NULL,_Selected

.NOT:	bra.w	WREPLY

;----------------------------------------------------------------------------

PICK_MENUITEM:
	move.w	im_Code(a0),d7
	move.l	_CurrentList,a0
	TSTLIST
	beq.s	.EMPTY

.LOOP:	TSTNODE	a0,a0
	beq.s	.EMPTY
	dbf	d7,.LOOP

	move.l	a0,a4
	move.l	a4,_Selected

	move.l	bk_MenuItem(a4),a4
	move.w	mi_Flags(a4),d0
	and.w	#COMMSEQ,d0
	beq.s	.EMPTY

	lea	BKeyzGadgets,a0
	move.l	8(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	ShowKeyTag,a3
	lea	mi_Command(a4),a4
	move.l	a4,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
	bra.s	.ACTIVATE

.EMPTY:
	lea	BKeyzGadgets,a0
	move.l	8(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	ShowKeyTag,a3
	move.l	#NULL,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

.ACTIVATE:
	lea	BKeyzGadgets,a0
	move.l	8(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	CALL	ActivateGadget,_IntuitionBase
	bra.w	WREPLY

;-------------------------------------------------------------------------

SET_COMMSEQ:
	tst.l	_Selected
	beq.w	.NOT

	move.l	a0,_IntuiMessage

;-------------------------------------------------------

	moveq	#0,d7
	bsr.w	GET_WBWINDOW
	tst.w	d7
	bne.w	.EXIT

	move.l	_WBWindow,a2
	cmp.l	a0,a2
	beq.w	.OKWB

	move.l	_Selected,a1
	move.w	bk_PrefsNum(a1),CurrPrefs	; menu item to recieve commseq

	move.l	a0,_WBWindow
	move.l	wd_MenuStrip(a0),_MenuStrip	; ...get its menustrip

	lea	BKeyzGadgets,a0
	move.l	4(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	CycleClearTag,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	bsr.w	COPY_MENUSTRIP
	beq.w	.EXIT

;	bsr.w	CURRENT_LIST
;					move.l	#NULL,_Selected
;					move.w	#-1,LastTitle

	move.w	CurrPrefs,d0
	move.w	NMenus,d7
	subq.w	#1,d7
	move.l	_MenuLists,a0
.FITEM:	TSTLIST
	beq.s	.NLIST

	move.l	a0,a1

.LITEM:	TSTNODE	a1,a1
	beq.s	.NLIST

;	cmp.w	bk_PrefsNum(a1),d0	

	move.w	bk_PrefsNum(a1),d1
	cmp.w	d1,d0
	beq.s	.OKNODE

	bra.s	.LITEM

.NLIST:	lea	LH_SIZE(a0),a0
	dbf	d7,.FITEM

	lea	BKeyzGadgets,a0
	move.l	4(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	CycleTag,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	SetListTag,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	move.l	#NULL,_Selected
	move.w	#-1,LastTitle
	bra.w	.NOT

.OKNODE:
	move.l	a1,_Selected
	move.l	a0,_CurrentList

	lea	BKeyzGadgets,a0
	move.l	4(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	CycleTag,a3

	moveq	#0,d6
	move.w	NMenus,d6
	sub.w	#1,d6
	sub.w	d7,d6

	move.l	d6,ti_Data(a3)	

	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	SetListTag,a3
	move.l	_CurrentList,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

;-------------------------------------------------------------

.OKWB:	move.l	_IntuiMessage,a0
	move.l	im_IAddress(a0),a0
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_Buffer(a0),a0
	tst.b	(a0)
	beq.w	.CLEAR
	cmp.b	#' ',(a0)
	beq.w	.CLEAR

	move.b	(a0),d0

	move.l	_Selected,a0
	move.l	bk_MenuItem(a0),a1
	or.w	#COMMSEQ,mi_Flags(a1)
	move.b	d0,mi_Command(a1)

	move.l	LN_NAME(a0),a1
.LOOP:	cmp.b	#'(',(a1)
	beq.s	.REPLACE
	tst.b	(a1)
	beq.s	.NEW

	lea	1(a1),a1
	bra.s	.LOOP

.NEW:	cmp.b	#' ',-1(a1)
	beq.s	.SKIP

	move.b	#' ',(a1)+

.SKIP:	move.b	#'(',(a1)+
	move.b	d0,(a1)+
	move.b	#')',(a1)+
	move.b	#$0,(a1)
	bra.s	.CONT

.REPLACE:
	move.b	d0,1(a1)

.CONT:	bsr.w	LAYOUT_MENUS

	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	SetListTag,a3
	move.l	_CurrentList,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	ShowKeyTag,a3
	move.l	_Selected,a4
	move.l	bk_MenuItem(a4),a4
	lea	mi_Command(a4),a4
	move.l	a4,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
.NOT:	bra.w	WREPLY


.CLEAR:	move.l	_Selected,a0
	move.l	LN_NAME(a0),a1
.LOOP2:	cmp.b	#'(',(a1)
	beq.s	.OK
	tst.b	(a1)+
	bne.s	.LOOP2
	bra.s	.SET

.OK:	move.b	#$0,(a1)

.SET:	move.l	bk_MenuItem(a0),a1
	and.w	#~COMMSEQ,mi_Flags(a1)
	move.b	#$0,mi_Command(a1)

	bsr.w	LAYOUT_MENUS

	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	SetListTag,a3
	move.l	_CurrentList,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
	bra.w	WREPLY

.EXIT:	move.w	#1,ExitFlag
	bra.w	WREPLY

;-------------------------------------------------------------------------

LAYOUT_MENUS:
	move.l	_WBWindow,a0
	CALL	ClearMenuStrip,_IntuitionBase

	move.l	_WBScreen,a0
	sub.l	a1,a1
	CALL	GetVisualInfoA,_GadToolsBase
	move.l	d0,_VInfo

	move.l	_MenuStrip,a0
	move.l	d0,a1
	sub.l	a2,a2
	CALL	LayoutMenusA,_GadToolsBase

	move.l	_WBWindow,a0
	move.l	_MenuStrip,a1
	CALL	SetMenuStrip,_IntuitionBase

	move.l	_VInfo,a0
	CALL	FreeVisualInfo,_GadToolsBase
	rts

;----------------------------------------------------------------------------

UPDATE_LISTS:
	lea	BKeyzGadgets,a0
	move.l	4(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	CycleClearTag,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	bsr.w	COPY_MENUSTRIP
	beq.s	.EXIT

	bsr.w	CURRENT_LIST
	move.l	#NULL,_Selected

	lea	BKeyzGadgets,a0
	move.l	4(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	CycleTag,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

	move.w	#-1,LastTitle
 	bra.w	WREPLY

.EXIT:	move.w	#1,ExitFlag
	bra.w	WREPLY

;----------------------------------------------------------------------------

COMMODITY_EVENT:
	move.l	_CxPort,a0
	EXEC	GetMsg
	move.l	d0,_CxMessage
	beq.w	MAINLOOP

	move.l	d0,a0
	CALL	CxMsgID,_CxBase
	move.l	d0,_CxID

	move.l	_CxMessage,a0
	CALL	CxMsgType,_CxBase

	cmp.l	#CXM_IEVENT,d0
	bne.s	NOT_IEVENT




	bra.s	CREPLY

NOT_IEVENT:
	cmp.l	#CXM_COMMAND,d0
	bne.s	CREPLY

	bsr.w	CHECK_CXCOMMAND

CREPLY:	move.l	_CxMessage,a1
	EXEC	ReplyMsg
	bra.s	COMMODITY_EVENT

;----------------------------------------------------------------------------

CHECK_CXCOMMAND:
	move.l	_CxID,d0

	cmp.l	#CXCMD_DISABLE,d0
	beq.s	CX_DISABLE
	cmp.l	#CXCMD_ENABLE,d0
	beq.s	CX_ENABLE
	cmp.l	#CXCMD_KILL,d0
	beq.s	CX_KILL
	cmp.l	#CXCMD_UNIQUE,d0
	beq.s	CX_UNIQUE
	cmp.l	#CXCMD_APPEAR,d0
	beq.s	CX_APPEAR
	cmp.l	#CXCMD_DISAPPEAR,d0
	beq.s	CX_DISAPPEAR
	rts

CX_DISABLE:
	move.l	_CxBroker,a0
	moveq	#FALSE,d0
	CALL	ActivateCxObj,_CxBase
	rts

CX_ENABLE:
	move.l	_CxBroker,a0
	moveq	#TRUE,d0
	CALL	ActivateCxObj,_CxBase
	rts

CX_KILL:
	move.w	#1,ExitFlag
	rts

CX_UNIQUE:
	bra.w	CX_APPEAR

CX_APPEAR:
	bsr.w	OpenBKeyzWindow
	beq.s	.OK

	move.w	#1,ExitFlag

.OK:	rts

CX_DISAPPEAR:
	bsr.w	CloseBKeyzWindow
	rts

;----------------------------------------------------------------------------

; close all opened and allocated resources

CLOSE_ALL:
	tst.l	BKeyzWnd
	beq.s	CLOSE_SCREEN

	bsr.w	CloseBKeyzWindow

CLOSE_SCREEN:
	bsr.w	CloseDownScreen

EXIT:	bsr.w	CLEAN
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

;-----------------------------------------------------------------------------

	IF WB

FIND_WBMSG:
	sub.l	a1,a1
	CALLEXEC FindTask
	move.l	d0,a4

	moveq	#0,d0

	tst.l	pr_CLI(a4)
	bne.s	.CLI

	lea	pr_MsgPort(a4),a0
	CALLEXEC WaitPort
	lea	pr_MsgPort(a4),a0
	CALLEXEC GetMsg
.CLI:	move.l	d0,_WBMsg
	rts

REPLY_WBMSG:
	tst.l	_WBMsg
	beq.s	.NOT

	move.l	_WBMsg,a1
	CALLEXEC ReplyMsg
.NOT:	rts

	ENDIF

;-----------------------------------------------------------------------------

CLEAN:	bsr.w	FREE_CYCLE
	bsr.w	FREE_LISTS

	bsr.w	REMOVE_CX
	bsr.w	FREE_CXPORT
	bsr.w	FREE_BROKERMEM

	bsr.w	CLOSEDOS
	bsr.w	CLOSEGFX
	bsr.w	CLOSEINT
	bsr.w	CLOSEREQ
	bsr.w	CLOSECX
	bsr.w	CLOSEGAD

	IF WB
	bsr.s	REPLY_WBMSG
	ENDIF
	rts

REMOVE_CX:
	tst.l	_CxBroker
	beq.s	.NOT

	move.l	_CxBroker,a0
	CALL	DeleteCxObjAll,_CxBase
.NOT:	rts

FREE_BROKERMEM:
	tst.l	_NewBroker
	beq.s	.NOT

	move.l	_NewBroker,a1
	EXEC	FreeVec
.NOT:	rts

FREE_CXPORT:
	tst.l	_CxPort
	beq.s	.NOT

.LOOP:	move.l	_CxPort,a0
	EXEC	GetMsg
	tst.l	d0
	beq.s	.FREE

	move.l	d0,a1
	EXEC	ReplyMsg
	bra.s	.LOOP

.FREE:	move.l	_CxPort,a0
	EXEC	DeleteMsgPort
.NOT:	rts

CLOSECX:
	tst.l	_CxBase
	beq.s	.NOT

	CLOSELIB _CxBase
.NOT:	rts

CLOSEREQ:
	tst.l	_ReqToolsBase
	beq.s	.NOT

	tst.l	_ReqInfo
	beq.s	.LIB

	move.l	_ReqInfo,a1
	CALL	rtFreeRequest,_ReqToolsBase

.LIB:	CLOSELIB _ReqToolsBase
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

;----------------------------------------------------------------------------

FREE_CYCLE:
	tst.l	_StringBuffer
	beq.s	.NOT1

	move.l	_StringBuffer,a1
	EXEC	FreeVec

	move.l	#NULL,_StringBuffer

.NOT1:	tst.l	_CycleBuffer
	beq.s	.NOT

	move.l	_CycleBuffer,a1
	EXEC	FreeVec

	move.l	#NULL,_CycleBuffer
.NOT:	rts

;----------------------------------------------------------------------------

COPY_MENUSTRIP:
	move.l	d7,-(a7)

	bsr.w	INITIALIZE_CYCLE		; init cycle gadget
	beq.w	FAIL




	bsr.w	ALLOCATE_LISTS			; allocate menu-item lists
	beq.w	FAIL

	moveq	#0,d7
	move.w	NMenus,d6
	subq.w	#1,d6
	moveq	#-1,d5
	move.l	_MenuLists,a2
	move.l	_MenuStrip,a3	
STEAL_LOOP:					; a2 = menulist ptr
						; a3 = menustrip (header ptr)
						; a4 = current menu-item
						; a5 = current alloc'd struct
						; a6 = item basename

	move.l	mu_FirstItem(a3),a4
	bsr.w	BUILD_MENU
	beq.s	FAIL

	lea	LH_SIZE(a2),a2
	move.l	mu_NextMenu(a3),a3
	dbf	d6,STEAL_LOOP

	move.l	_MenuLists,a0
	move.l	a0,_CurrentList

	move.l	(a7)+,d7
	moveq	#1,d0
	rts

FAIL:	move.l	(a7)+,d7
	moveq	#0,d0
	rts

;----------------------------------------------------------------------------

BUILD_MENU:
	move.l	a3,-(a7)

BUILD_LOOP:
	move.l	a4,a3

	move.w	mi_Flags(a4),d0
	and.w	#ITEMTEXT,d0
	tst.w	d0
	beq.w	STEAL_NEXTITEM

	bsr.w	ALLOCATE_STRUCT
	beq.w	FAILED

	move.l	a2,a0
	move.l	a5,a1
	ADDTAIL

	addq.w	#1,d5
	move.w	d5,bk_PrefsNum(a5)

	move.l	mi_ItemFill(a4),a0
	move.l	it_IText(a0),a0
	move.l	LN_NAME(a5),a1
	lea	BaseName,a6
.LOOP:	move.b	(a0),(a1)+
	move.b	(a0)+,(a6)+
	bne.s	.LOOP

	moveq	#0,d7

	move.l	mi_SubItem(a4),a6
	cmp.l	#NULL,a6
	beq.s	NO_SUBITEM

	moveq	#1,d7

	move.l	a6,a4

SUBITEM_LOOP:
	move.b	#'/',-1(a1)
	
	move.l	mi_ItemFill(a4),a0
	move.l	it_IText(a0),a0
.LOOP:	move.b	(a0)+,(a1)+
	bne.s	.LOOP

NO_SUBITEM:
	move.w	mi_Flags(a4),d0
	and.w	#COMMSEQ,d0
	beq.s	NO_COMMSEQ

	move.b	#' ',-1(a1)
	move.b	#'(',(a1)+
	move.b	mi_Command(a4),(a1)+
	move.b	#')',(a1)+
	move.b	#$0,(a1)

NO_COMMSEQ:	
	move.l	a4,bk_MenuItem(a5)

	tst.w	d7
	beq.s	STEAL_NEXTITEM

	move.l	mi_NextItem(a4),a4
	cmp.l	#NULL,a4
	beq.s	STEAL_NEXTITEM

	bsr.w	ALLOCATE_STRUCT
	beq.w	FAILED

	move.l	a2,a0
	move.l	a5,a1
	ADDTAIL

	addq.w	#1,d5
	move.w	d5,bk_PrefsNum(a5)

	lea	BaseName,a0
	move.l	LN_NAME(a5),a1
.LOOP:	move.b	(a0)+,(a1)+
	bne.s	.LOOP
	bra.s	SUBITEM_LOOP

STEAL_NEXTITEM:
	move.l	mi_NextItem(a3),a4
	cmp.l	#NULL,a4
	bne.w	BUILD_LOOP

	moveq	#1,d0

FAILED:	move.l	(a7)+,a3
	tst.w	d0
	rts

;-----------------------------------------------------------------------------

ALLOCATE_STRUCT:
	move.l	a6,-(a7)

	move.l	#bk_SIZEOF,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	beq.s	.FAIL

	move.l	d0,a5

	move.l	#64,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	beq.s	.FAIL

	move.l	d0,LN_NAME(a5)
.FAIL:	move.l	(a7)+,a6
	tst.l	d0
	rts

;----------------------------------------------------------------------------

ALLOCATE_LISTS:
	bsr.w	FREE_LISTS

	moveq	#0,d0
	move.w	NMenus,d0
	mulu	#LH_SIZE,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,_MenuLists
	beq.s	.FAIL

	moveq	#0,d7
	move.w	NMenus,d7
	subq.w	#1,d7
	move.l	d0,a2
.LOOP:	move.l	a2,a3
	NEWLIST	a3
	lea	LH_SIZE(a2),a2
	dbf	d7,.LOOP

	moveq	#1,d0
	rts

.FAIL:	moveq	#0,d0
	rts

FREE_LISTS:
	tst.l	_MenuLists
	beq.s	.NOT

	move.l	_MenuLists,a4
	move.w	NMenus,d7
	subq.w	#1,d7
.LOOP:	move.l	a4,a0

	bsr.w	FREE_STRUCTS

	lea	LH_SIZE(a4),a4
	dbf	d7,.LOOP

	move.l	_MenuLists,a1
	EXEC	FreeVec
	
	move.l	#NULL,_MenuLists
	move.l	#NULL,_CurrentList
.NOT:	rts

FREE_STRUCTS:
	TSTLIST	a0
	beq.s	.NOT

	move.l	(a0),a1
	move.l	a1,Dummy1
	move.l	LN_NAME(a1),Dummy2

	move.l	a0,-(a7)

	REMOVE

	tst.l	Dummy2
	beq.s	.STR

	move.l	Dummy2,a1
	EXEC	FreeVec

.STR:	tst.l	Dummy1
	beq.s	.NEXT

	move.l	Dummy1,a1
	EXEC	AllocVec

.NEXT:	move.l	(a7)+,a0
	bra.s	FREE_STRUCTS

.NOT:	move.l	#NULL,Dummy1
	move.l	#NULL,Dummy2
	rts

;--------------------------------------------------------------------------

INITIALIZE_CYCLE:
	bsr.w	FREE_CYCLE	

	move.l	_MenuStrip,a0
	moveq	#1,d7
.LOOP:	move.l	mu_NextMenu(a0),a0		; count menus-titles
	cmp.l	#NULL,a0
	beq.s	.DONE

	addq.w	#1,d7
	bra.s	.LOOP	

.DONE:	move.l	d7,d6
	move.w	d7,NMenus

	addq.w	#1,d6
	lsl.w	#2,d6				; mem for pointers

	move.l	d6,d0
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,_CycleBuffer
	beq.w	.FAIL

	move.l	d7,d0
	mulu	#48,d0				; mem for strings
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	EXEC	AllocVec
	move.l	d0,_StringBuffer
	beq.w	.FAIL

	move.l	_CycleBuffer,a0			; insert pointers
	move.l	_StringBuffer,a1
	move.w	d7,d6
	subq.w	#1,d6
.LOOP2:	move.l	a1,(a0)+
	lea	48(a1),a1
	dbf	d6,.LOOP2	

	move.l	_MenuStrip,a0			; copy names into cycle-gad
	move.l	_CycleBuffer,a1
	subq.w	#1,d7
.LOOP3:	move.l	mu_MenuName(a0),a2
	cmp.l	#NULL,a2
	beq.s	.NEXT

	move.l	(a1)+,a3
	move.w	#47-1,d6
.LOOP4:	move.b	(a2)+,(a3)+
	beq.s	.NEXT
	dbf	d6,.LOOP4

.NEXT:	move.l	mu_NextMenu(a0),a0
	dbf	d7,.LOOP3

	lea	CycleTag,a0			; insert pointer to buffer
	move.l	_CycleBuffer,ti_Data(a0)

	moveq	#1,d0
	rts

.FAIL:	moveq	#0,d0
	rts

;----------------------------------------------------------------------------
*
*  Source machine generated by GadToolsBox V2.0b
*  which is (c) Copyright 1991-1993 Jaba Development
*
*  GUI Designed by : Morten Amundsen
*

Scr:
    DC.L    0
VisualInfo:
    DC.L    0
PubScreenName:
    DC.L    0
BKeyzWnd:
    DC.L    0
BKeyzGList:
    DC.L    0
BKeyzMenus:
    DC.L    0
MTags0:
    DC.L    GTMN_FrontPen,1,TAG_DONE
MTags1:
    DC.L    GTMN_TextAttr,topaz8,TAG_DONE
BKeyzGadgets:
    DCB.L    4,0
BufNewGad:
    DC.W    0,0,0,0
    DC.L    0,0
    DC.W    0
    DC.L    0,0,0
TD:
    DC.L    TAG_DONE
BKeyzLeft:
    DC.W    167
BKeyzTop:
    DC.W    36
BKeyzWidth:
    DC.W    328
BKeyzHeight:
    DC.W    134

BKeyzGTypes:
    DC.W    LISTVIEW_KIND
    DC.W    CYCLE_KIND
    DC.W    STRING_KIND
    DC.W    BUTTON_KIND

BKeyzNGads:
    DC.W    5,14,308,104
    DC.L    ITEMSText,0
    DC.W    GD_ITEMS
    DC.L    PLACETEXT_ABOVE,0,0
    DC.W    69,115,244,14
    DC.L    0,0
    DC.W    GD_TITLES
    DC.L    0,0,0
    DC.W    6,115,29,14
    DC.L    COMMSEQText,0
    DC.W    GD_COMMSEQ
    DC.L    0,0,0
    DC.W    38,115,28,14
    DC.L    UPDATEText,0
    DC.W    GD_UPDATE
    DC.L    PLACETEXT_IN,0,0

BKeyzGTags:
    DC.L    GTLV_ShowSelected,0
    DC.L    TAG_DONE
CycleTag:
    DC.L    GTCY_Labels,NULL			; TITLESLabels
    DC.L    GTCY_Active,0
    DC.L    TAG_DONE
    DC.L    GTST_MaxChars,1
    DC.L    TAG_DONE
    DC.L    TAG_DONE

ITEMSText:
    DC.B    'Menu Items',0

COMMSEQText:
    DC.B    '',0

UPDATEText:
    DC.B    'U',0
    CNOP    0,2

;TITLESLabels:
;    DC.L    TITLESLab0
;    DC.L    TITLESLab1
;    DC.L    TITLESLab2
;    DC.L    TITLESLab3
;    DC.L    0

;TITLESLab0:    DC.B    'Workbench',0
;TITLESLab1:    DC.B    'Window',0
;TITLESLab2:    DC.B    'Icons',0
;TITLESLab3:    DC.B    'Tools',0
;    CNOP    0,2

topaz8:
    DC.L    topazFName8
    DC.W    8
    DC.B    $00,$01

topazFName8:
    DC.B    'topaz.font',0
    CNOP    0,2

BKeyzWindowTags:
BKeyzL:
    DC.L    WA_Left,0
BKeyzT:
    DC.L    WA_Top,0
BKeyzW:
    DC.L    WA_Width,0
BKeyzH:
    DC.L    WA_Height,0
    DC.L    WA_IDCMP,IDCMP_CHANGEWINDOW!LISTVIEWIDCMP!CYCLEIDCMP!STRINGIDCMP!BUTTONIDCMP!IDCMP_MENUPICK!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
    DC.L    WA_Flags,WFLG_NEWLOOKMENUS!WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_CLOSEGADGET!WFLG_SMART_REFRESH
BKeyzWG:
    DC.L    WA_Gadgets,0
    DC.L    WA_Title,BKeyzWTitle
BKeyzSC:
    DC.L    WA_PubScreen,0
    DC.L    TAG_DONE

BKeyzWTitle:
    DC.B    'BenchKeyz ',0
    BLK.B   64,0
    CNOP    0,2

BKeyzNewMenu0:
    DC.B    NM_TITLE,0
    DC.L    BKeyzMName0
    DC.L    0
    DC.W    0
    DC.L    0,0

BKeyzNewMenu1:
    DC.B    NM_ITEM,0
    DC.L    BKeyzMName1
    DC.L    0
    DC.W    0
    DC.L    0,0

BKeyzNewMenu2:
    DC.B    NM_ITEM,0
    DC.L    NM_BARLABEL,0
    DC.W    0
    DC.L    0,0

BKeyzNewMenu3:
    DC.B    NM_ITEM,0
    DC.L    BKeyzMName3
    DC.L    0
    DC.W    0
    DC.L    0,0

BKeyzNewMenu4:
    DC.B    NM_ITEM,0
    DC.L    BKeyzMName4
    DC.L    0
    DC.W    0
    DC.L    0,0

BKeyzNewMenu5:
    DC.B    NM_ITEM,0
    DC.L    NM_BARLABEL,0
    DC.W    0
    DC.L    0,0

BKeyzNewMenu6:
    DC.B    NM_ITEM,0
    DC.L    BKeyzMName6
    DC.L    0
    DC.W    0
    DC.L    0,0

    DC.B    NM_END,0
    DC.L    0,0
    DC.W    0
    DC.L    0,0

BKeyzMName0:
    DC.B    'Project',0

BKeyzMName1:
    DC.B    'Save Prefs...',0

BKeyzMName3:
    DC.B    'About...',0

BKeyzMName4:
    DC.B    'Hide',0

BKeyzMName6:
    DC.B    'Quit',0
    CNOP    0,2

SetupScreen
    movem.l d1-d3/a0-a2/a6,-(sp)
    move.l  _IntuitionBase,a6
    move.l  PubScreenName,a0
    jsr     LockPubScreen(a6)
    move.l  d0,Scr
    tst.l   d0
    beq     SError
    move.l  Scr,a0
    move.l  _GadToolsBase,a6
    lea.l   TD,a1
    jsr     GetVisualInfoA(a6)
    move.l  d0,VisualInfo
    tst.l   d0
    beq     VError
    moveq   #0,d0
SDone:
    movem.l (sp)+,d1-d3/a0-a2/a6
    rts
SError:
    moveq   #1,d0
    bra.s   SDone
VError:
    moveq   #2,d0
    bra.s   SDone

CloseDownScreen:
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _GadToolsBase,a6
    move.l  VisualInfo,a0
    cmpa.l  #0,a0
    beq.s   NoVis
    jsr     FreeVisualInfo(a6)
    move.l  #0,VisualInfo
NoVis:
    move.l  _IntuitionBase,a6
    suba.l  a0,a0
    move.l  Scr,a1
    cmpa.l  #0,a1
    beq.s   NoScr
    jsr     UnlockPubScreen(a6)
    move.l  #0,Scr
NoScr:
    movem.l (sp)+,d0-d1/a0-a1/a6
    rts

OpenBKeyzWindow:
    movem.l d1-d4/a0-a4/a6,-(sp)
    move.l  Scr,a0
    moveq   #0,d3
    moveq   #0,d2
    move.b  sc_WBorLeft(a0),d2
    move.l  sc_Font(a0),a1
    move.w  ta_YSize(a1),d3
    addq.w  #1,d3
    move.b  sc_WBorTop(a0),d0
    ext.w   d0
    add.w   d0,d3
    move.l  _GadToolsBase,a6
    lea.l   BKeyzGList,a0
    jsr     CreateContext(a6)
    move.l  d0,a3
    tst.l   d0
    beq     BKeyzCError
    movem.w d2-d3,-(sp)
    moveq   #0,d3
    lea.l   BKeyzGTags,a4
BKeyzGL:
    move.l  _SysBase,a6
    lea.l   BKeyzNGads,a0
    move.l  d3,d0
    mulu    #gng_SIZEOF,d0
    add.l   d0,a0
    lea.l   BufNewGad,a1
    moveq   #gng_SIZEOF,d0
    jsr     CopyMem(a6)
    lea.l   BufNewGad,a0
    move.l  VisualInfo,gng_VisualInfo(a0)
    move.l  #topaz8,gng_TextAttr(a0)
    move.w  gng_LeftEdge(a0),d0
    add.w   (sp),d0
    move.w  d0,gng_LeftEdge(a0)
    move.w  gng_TopEdge(a0),d0
    add.w   2(sp),d0
    move.w  d0,gng_TopEdge(a0)
    move.l  _GadToolsBase,a6
    lea.l   BKeyzGTypes,a0
    moveq   #0,d0
    move.l  d3,d1
    asl.l   #1,d1
    add.l   d1,a0
    move.w  (a0),d0
    move.l  a3,a0
    lea.l   BufNewGad,a1
    move.l  a4,a2
    jsr     CreateGadgetA(a6)
    tst.l   d0
    bne.s    BKeyzCOK
    movem.w (sp)+,d2-d3
    bra     BKeyzGError
BKeyzCOK:
    move.l  d0,a3
    move.l  d3,d0
    asl.l   #2,d0
    lea.l   BKeyzGadgets,a0
    add.l   d0,a0
    move.l  a3,(a0)
BKeyzTL:
    tst.l   (a4)
    beq.s   BKeyzDN
    addq.w  #8,a4
    bra.s   BKeyzTL
BKeyzDN:
    addq.w  #4,a4
    addq.w  #1,d3
    cmp.w   #BKeyz_CNT,d3
    bmi     BKeyzGL
    movem.w (sp)+,d2-d3
    move.l  BKeyzGList,BKeyzWG+4
    move.l  _GadToolsBase,a6
    lea.l   BKeyzNewMenu0,a0
    lea.l   MTags0,a1
    jsr     CreateMenusA(a6)
    move.l  d0,BKeyzMenus
    tst.l   d0
    beq     BKeyzMError
    move.l  d0,a0
    move.l  VisualInfo,a1
    lea.l   MTags1,a2
    jsr     LayoutMenusA(a6)
    move.l  Scr,BKeyzSC+4
    moveq   #0,d0
    move.w  BKeyzLeft,d0
    move.l  d0,BKeyzL+4
    move.w  BKeyzTop,d0
    move.l  d0,BKeyzT+4
    move.w  BKeyzWidth,d0
    move.l  d0,BKeyzW+4
    move.w  BKeyzHeight,d0
    add.w   d3,d0
    move.l  d0,BKeyzH+4
    move.l  _IntuitionBase,a6
    suba.l  a0,a0
    lea.l   BKeyzWindowTags,a1
    jsr     OpenWindowTagList(a6)
    move.l  d0,BKeyzWnd
    tst.l   d0
    beq     BKeyzWError
    move.l   BKeyzWnd,a0
    move.l   BKeyzMenus,a1
    jsr      SetMenuStrip(a6)
    move.l  _GadToolsBase,a6
    move.l  BKeyzWnd,a0
    suba.l  a1,a1
    jsr     GT_RefreshWindow(a6)

	moveq	#0,d0
	moveq	#0,d1
	move.l	BKeyzWnd,a0
	move.l	wd_UserPort(a0),a0
	move.l	a0,_WindowPort
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	move.l	d0,WndSigSet

	bsr.w	CURRENT_LIST

	lea	BKeyzGadgets,a0
	move.l	4(a0),a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	ActTitleTag,a3
	CALL	GT_SetGadgetAttrsA,_GadToolsBase

    moveq   #0,d0
BKeyzDone:
    movem.l (sp)+,d1-d4/a0-a4/a6
    rts
BKeyzCError:
    moveq   #1,d0
    bra.s   BKeyzDone
BKeyzGError:
    moveq   #2,d0
    bra.s   BKeyzDone
BKeyzMError:
    moveq   #3,d0
    bra.s   BKeyzDone
BKeyzWError:
    moveq   #4,d0
    bra.s   BKeyzDone

CURRENT_LIST:
	tst.l	_MenuLists
	beq.s	.NOT

	move.l	_CurrentList,a4
	TSTLIST	a4
	bne.s	.OK

	move.l	#NULL,a4

.OK:	move.l	BKeyzGadgets,a0
	move.l	BKeyzWnd,a1
	sub.l	a2,a2
	lea	SetListTag,a3
	move.l	a4,ti_Data(a3)
	CALL	GT_SetGadgetAttrsA,_GadToolsBase
.NOT:	rts

;---------------------------------------------------------------------------

CloseBKeyzWindow:
    movem.l d0-d1/a0-a2/a6,-(sp)
    move.l   _IntuitionBase,a6
    move.l   BKeyzMenus,a0
    cmpa.l   #0,a0
    beq      BKeyzNMenu
    move.l   BKeyzWnd,a0
    jsr      ClearMenuStrip(a6)
    move.l   _GadToolsBase,a6
    move.l   BKeyzMenus,a0
    jsr      FreeMenus(a6)
    move.l   #0,BKeyzMenus
BKeyzNMenu:

; START of code not generated by gadtoolsbox

	tst.l	BKeyzWnd
	beq.s	BKeyzNWnd

.LOOP:	move.l	_WindowPort,a0
	CALL	GT_GetIMsg,_GadToolsBase
	tst.l	d0
	beq.s	.CLOSE

	move.l	d0,a1
	CALL	GT_ReplyIMsg,_GadToolsBase
	bra.s	.LOOP

.CLOSE:	move.l	BKeyzWnd,a0
	move.l	#NULL,d0
	CALL	ModifyIDCMP,_IntuitionBase

	move.l	BKeyzWnd,a0
	move.l	#NULL,wd_UserPort(a0)

	move.l	#0,_WindowPort
	move.l	#0,WndSigSet

; END of code not generated by gadtoolsbox

    move.l  _IntuitionBase,a6
    move.l  BKeyzWnd,a0
    jsr     CloseWindow(a6)
    move.l  #0,BKeyzWnd

BKeyzNWnd:
    move.l  _GadToolsBase,a6
    move.l  BKeyzGList,a0
    cmpa.l  #0,a0
    beq     BKeyzNGad
    jsr     FreeGadgets(a6)
    move.l  #0,BKeyzGList

BKeyzNGad:
    movem.l (sp)+,d0-d1/a0-a2/a6
    rts

;----------------------------------------------------------------------------

	section	"Data",data

	IF WB
_WBMsg:		dc.l	0
	ENDIF

;---------------------------------------------------------------------------

ExitFlag:	dc.w	0

_ReqInfo:	dc.l	0		; reqtools handle (RT_REQINFO)
_VInfo:		dc.l	0		; VisualInfo
_WBScreen:	dc.l	0		; Workbench screen
_WBWindow:	dc.l	0		; Workbench window
_WindowPort:	dc.l	0		; Window's userport
WndSigSet:	dc.l	0		; window-ports signal
_MenuStrip:	dc.l	0		; Workbench window menustrip
_ILock:		dc.l	0		; Intuition lock
_IMessage:	dc.l	0		; intuimessage

_NewBroker:	dc.l	0
_CxBroker:	dc.l	0
CxSigSet:	dc.l	0
_CxID:		dc.l	0
_CxPort:	dc.l	0
_CxMessage:	dc.l	0

_DOSBase:	dc.l	0
_GfxBase:	dc.l	0
_IntuitionBase:	dc.l	0
_GadToolsBase:	dc.l	0
_ReqToolsBase:	dc.l	0
_CxBase:	dc.l	0
DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
GadToolsName:	dc.b	"gadtools.library",0
IntuitionName:	dc.b	"intuition.library",0
ReqToolsName:	dc.b	"reqtools.library",0
CxName:		dc.b	"commodities.library",0
		VERSTR

;---------------------------------------------------------------------------

WBName:		dc.b	"Workbench",0

ERR_NoWB:	dc.b	"Workbench task is not running.",0
TXT_Continue:	dc.b	"Continue",0
		even

REQ_Tags:	dc.l	RT_ReqPos,REQPOS_CENTERSCR
		dc.l	RTEZ_ReqTitle,Broker_Name
		dc.l	TAG_DONE

Broker_Title:	NAME
		VER
		dc.b	"."
		REV
		dc.b	" by Morten Amundsen"
		dc.b	0

Broker_Name:	NAME
		dc.b	0

Broker_Descr:	dc.b	"WB menu shortcut replacement tool",0
		cnop	0,2

;----------------------------------------------------------------------------

HasPrefs:	dc.w	0	; 0=no prefs loaded, 1=prefs loaded
CurrPrefs:	dc.w	0	; current prefs number
PrefsSize:	dc.w	0	; number of items in prefs file
MenuSize:	dc.w	0	; number of items in MenuStrip
PrefsPtr:	dc.l	0	; prefs file buffer

;----------------------------------------------------------------------------

Dummy1:		dc.l	0
Dummy2:		dc.l	0

DetachTag:	dc.l	GTLV_Labels,NULL
		dc.l	TAG_DONE

SetListTag:	dc.l	GTLV_Labels,NULL
		dc.l	GTLV_ShowSelected,0
		dc.l	TAG_DONE

ShowKeyTag:	dc.l	GTST_String,NULL
		dc.l	TAG_DONE

ActTitleTag:	dc.l	GTCY_Active,0
		dc.l	TAG_DONE

CycleClearTag:	dc.l	GTCY_Labels,NULL
		dc.l	TAG_DONE

LastTitle:	dc.w	0
_CurrentList:	dc.l	0	; current menu list
_Selected:	dc.l	0	; current menu-item node
_IntuiMessage:	dc.l	0

NMenus:		dc.w	0	; number of menus

_CycleBuffer:	dc.l	0	; pointers to cycle gadget strings
_StringBuffer:	dc.l	0	; cycle gadget strings
_MenuLists:	dc.l	0	; list structs for menus

BaseName:	blk.b	64,0	; base name buffer of sub-items

;----------------------------------------------------------------------------
