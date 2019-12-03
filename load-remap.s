;--------------------------------------------------------------------
; Load and remap any picture type via datatypes and scale picture
; to size of window rastport, then blit to window.
;
; by Morten Amundsen
; Tirsdag,  2. Januar 1996, kl. 23:20
;--------------------------------------------------------------------

	include "misc/lvooffsets.i"
	include	"misc/macros.i"
	include	"exec/memory.i"
	include	"dos/dosextens.i"
	include	"dos/rdargs.i"
	include	"intuition/screens.i"
	include	"intuition/intuition.i"
	include	"intuition/gadgetclass.i"
	include	"graphics/scale.i"
	include	"graphics/rastport.i"
	include	"datatypes/datatypes.i"
	include	"datatypes/datatypesclass.i"
	include	"datatypes/pictureclass.i"

;--------------------------------------------------------------------

	XDEF	_main
	XDEF	_DOSBase
	XDEF	_GfxBase
	XDEF	_IntuitionBase

	section	"dt_code",code

;--------------------------------------------------------------------

_main:	OPENLIB	DOSName,39,_DOSBase
	beq.s	EXIT
	OPENLIB GfxName,39,_GfxBase
	beq.s	EXIT
	OPENLIB IntuitionName,39,_IntuitionBase
	beq.s	EXIT

	sub.l	a0,a0
	lea	NewWindowTags,a1
	CALL	OpenWindowTagList,_IntuitionBase
	move.l	d0,_PictureWnd

	move.l	d0,a0
	move.l	wd_UserPort(a0),_UserPort

;--------------------------------------------------------------------

MAIN_LOOP:
	tst.w	ExitFlag
	bne.s	EXIT

	move.l	_UserPort,a0
	EXEC	WaitPort

MSG_LOOP:
	move.l	_UserPort,a0
	EXEC	GetMsg
	move.l	d0,a1
	move.l	a1,d0
	beq.s	MAIN_LOOP

	move.l	im_Class(a1),d0
	
	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	REPLY_MSG

	move.w	#1,ExitFlag

REPLY_MSG:
	EXEC	ReplyMsg
	bra.s	MSG_LOOP

;--------------------------------------------------------------------

EXIT:	bsr.w	CLOSE_WINDOW

	bsr.w	CLOSE_DOSLIB
	bsr.w	CLOSE_GFXLIB
	bsr.w	CLOSE_INTUILIB
	moveq	#0,d0
	rts

;--------------------------------------------------------------------

CLOSE_WINDOW:
	tst.l	_PictureWnd
	beq.s	.NOT

	move.l	_PictureWnd,a0
	CALL	CloseWindow,_IntuitionBase
.NOT:	rts


CLOSE_DOSLIB:
	tst.l	_DOSBase
	beq.s	.NOT

	CLOSELIB _DOSBase
.NOT:	rts

CLOSE_GFXLIB:
	tst.l	_GfxBase
	beq.s	.NOT

	CLOSELIB _GfxBase
.NOT:	rts

CLOSE_INTUILIB:
	tst.l	_IntuitionBase
	beq.s	.NOT

	CLOSELIB _IntuitionBase
.NOT:	rts

;--------------------------------------------------------------------
	section	"dt_data",data

_DOSBase:	dc.l	0
_IntuitionBase:	dc.l	0
_GfxBase:	dc.l	0

DOSName:	dc.b	"dos.library",0
GfxName:	dc.b	"graphics.library",0
IntuitionName:	dc.b	"intuition.library",0
		cnop	0,2

ExitFlag:	dc.w	0
_PictureWnd:	dc.l	0
_UserPort:	dc.l	0

NewWindowTags:	dc.l	WA_Left,0
		dc.l	WA_Top,0
		dc.l	WA_InnerWidth,320
		dc.l	WA_InnerHeight,256
		dc.l	WA_DragBar,TRUE
		dc.l	WA_DepthGadget,TRUE
		dc.l	WA_CloseGadget,TRUE
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW
		dc.l	WA_Title,NewWindowTitle
		dc.l	TAG_DONE

NewWindowTitle:	dc.b	"Datatypes",0
		even
