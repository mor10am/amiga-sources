//-------------------------------------------------------------------
//
// "Program Manager" by Morten Amundsen
// Copyright © 1996. All rights reserved.
//
// Project Start: 01 Mar 1996, 16:51:31
//
// Developed in SAS/C 6.50
//
//-------------------------------------------------------------------

/// includes

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <intuition/IntuitionBase.h>
#include <intuition/screens.h>
#include <devices/timer.h>
#include <dos/dosextens.h>
#include <dos/dos.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <utility/tagitem.h>
#include <libraries/gadtools.h>
#include <graphics/text.h>
#include <libraries/commodities.h>
#include <clib/commodities_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/dos_protos.h>

///
/// prototypes

// no internal (sas/c) ctrl-c checking

void __regargs __chkabort(void);

void __regargs __chkabort(void)
{
}

void FreeResources(void);
void RenderMainWindow(void);
BOOL BuildPreferences(void);
BOOL MakeCx(void);
BOOL CreateGadgets(void);
BOOL CalcGUI(void);
void StartTimer(ULONG, ULONG);
WORD MousePosisiton(void);
APTR LoadPrefs(void);
void FreePrefs(void);
void SetTime(void);
void SetupMenu(void);

///
/// defines

#define MODE_DOWN 1             // taskbar is down
#define MODE_UP 2               // taskbar is up
#define MODE_MENU 3             // taskbar menu has been activated
#define MODE_LOADING 4          // program manager is currently loading

#define POP_MICROS 300000
#define TIMEOUT_SECS 10

#define GUISPACE 2

#define GAD_START 1
#define GAD_CLOCK 2

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct GadToolsBase *GadToolsBase;
struct DiskFontBase *DiskFontBase;
struct CxBase *CxBase;

APTR Prefs;

APTR  vi;
struct DrawInfo *drawinfo;

struct Window *managerwin;
struct IntuiMessage *winmessage;
struct MsgPort *winport;
ULONG winsigset;
struct Screen *wbscreen;
struct DrawInfo *drawinfo;
UWORD scrheight, scrwidth;
UWORD fillpen, shinepen, darkpen;
WORD currpos;

struct MsgPort *timerport;
struct timerequest *timerio;
ULONG timesigset;
BOOL timeropen = FALSE;

UWORD gadheight, winheight, fontheight;

struct TextAttr TopazAttr={"topaz.font",8,0,FPF_ROMFONT};
struct TextFont *TopazFont;

struct TextAttr WBAttr;
struct TextFont *WBFont;
STRPTR fontname;

struct TextAttr *PManAttr;
struct TextFont *PManFont;

UWORD menumode = MODE_DOWN;

struct Gadget *gad;
struct Gadget *glist = NULL;
struct Gadget *startgad, *clockgad;

struct NewGadget StartGadget={0,0,0,0,"Programs",0,GAD_START,PLACETEXT_IN,0,0};
struct NewGadget ClockGadget={0,0,0,0,NULL,0,GAD_CLOCK,0,0,0};
struct IntuiText DummyIT;

CxObj *pmanbroker;
struct MsgPort *pmancxport;
ULONG pmansigset;

struct NewBroker newbroker = {
  NB_VERSION,
  "PManager",
  "PManager v1.0 by Morten Amundsen, 1996",
  "Win95 style program manager",
  0,
  0,
  0,
  0,
  0
};

///

/// void SetTime()

void
SetTime(void)
{
  struct tm *timeptr;
  time_t t;
  char *s = "       ";

  if (time(&t) != -1)
  {
    timeptr = localtime(&t);
    strftime(s, 6, "%H:%M", timeptr);
    GT_SetGadgetAttrs(clockgad, managerwin, NULL, GTTX_Text, s,
                                                  GTTX_FrontPen,(UBYTE)shinepen,
                                                 TAG_DONE);
  }
}

///

/// BOOL PrepareTimer()

BOOL PrepareTimer(void)
{
  if (timerport = CreateMsgPort())
  {
    timesigset = 1<<timerport->mp_SigBit;

    if (timerio = (struct timerequest *)
          CreateIORequest(timerport, sizeof(struct timerequest)))
    {
      if (!OpenDevice("timer.device", UNIT_MICROHZ, (struct IORequest *) timerio, 0L))
      {
        timeropen = TRUE;
      }
    }
  }
  return(timeropen);
}

///
/// void StartTimer(seconds, micros)

void
StartTimer(ULONG seconds, ULONG micros)
{
  timerio->tr_node.io_Command = TR_ADDREQUEST;
  timerio->tr_time.tv_secs = seconds;
  timerio->tr_time.tv_micro = micros;
  SendIO((struct IORequest *) timerio);
}

///

/// BOOL BuildPreferences()

BOOL
BuildPreferences(void)
{
  BOOL retval = FALSE;

  Prefs = LoadPrefs();
  retval = TRUE;

  return(retval);
}  
///
/// APTR LoadPrefs()

APTR
LoadPrefs(void)
{
  struct FileInfoBlock *fileib;
  BPTR lock;
  APTR prefs = NULL;

  if (fileib = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, TAG_DONE))
  {
    if (lock = Open("PMan.prefs", MODE_OLDFILE))
    {
      if (ExamineFH(lock, fileib))
      {
        if (prefs = AllocVec(fileib->fib_Size, MEMF_ANY))
        {
          if (!Read(lock, prefs, fileib->fib_Size) == fileib->fib_Size)
          {
            FreeVec(prefs);
            prefs = NULL;
          }
        }
      }
      Close(lock);
    }
    FreeDosObject(DOS_FIB, fileib);
  }
  return(prefs);
}

///
/// void FreePrefs()

void
FreePrefs(void)
{
  if (Prefs) FreeVec(Prefs);
  Prefs = NULL;
}

///

/// BOOL MakeCx()

BOOL
MakeCx(void)
{
  BOOL retval = FALSE;

  if (pmancxport = CreateMsgPort())
  {
    newbroker.nb_Port = pmancxport;

    if (pmanbroker = CxBroker(&newbroker, NULL))
    {
      pmansigset = 1<<pmancxport->mp_SigBit;
      ActivateCxObj(pmanbroker, TRUE);
      retval = TRUE;
    }
  return(retval);
  }
}

///

/// WORD MousePosition()

WORD
MousePosition(void)
{
  ULONG iblock;
  WORD ypos;

  iblock = LockIBase(0L);

  if (IntuitionBase->FirstScreen->Flags & WBENCHSCREEN)
    ypos = IntuitionBase->FirstScreen->MouseY;
  else ypos = -1;

  UnlockIBase(iblock);

  return(ypos);
}

///
/// BOOL CalcGUI()

BOOL
CalcGUI(void)
{
  BOOL retval = FALSE;

  if (wbscreen = LockPubScreen("Workbench"))
  {
    if (vi = GetVisualInfo(wbscreen, TAG_DONE))
    {
      if (drawinfo = GetScreenDrawInfo(wbscreen))
      {
        WBAttr.ta_YSize = wbscreen->Font->ta_YSize;
        WBAttr.ta_Style = wbscreen->Font->ta_Style;
        WBAttr.ta_Flags = wbscreen->Font->ta_Flags;

        if (fontname = AllocVec(32L, MEMF_ANY | MEMF_CLEAR))
        {
          CopyMem(wbscreen->Font->ta_Name, fontname, 30L);

          WBAttr.ta_Name = fontname;

          if (WBFont = OpenDiskFont(&WBAttr))
          {
            PManAttr = &WBAttr;
            PManFont = WBFont;
          }
          else
          {
            TopazFont = OpenFont(&TopazAttr);

            PManAttr = &TopazAttr;
            PManFont = TopazFont;
          }

          shinepen = drawinfo->dri_Pens[SHINEPEN];
          darkpen = drawinfo->dri_Pens[SHADOWPEN];
          fillpen = drawinfo->dri_Pens[FILLPEN];

          scrwidth = wbscreen->Width;
          scrheight = wbscreen->Height;

          fontheight = PManFont->tf_YSize;
          gadheight = fontheight+(GUISPACE*2);
          winheight = gadheight+(GUISPACE*2);

          StartGadget.ng_LeftEdge = GUISPACE*2;
          StartGadget.ng_TopEdge = GUISPACE;

          DummyIT.ITextFont = PManAttr;
          DummyIT.IText = "Programs";

          StartGadget.ng_Width = GUISPACE*16+IntuiTextLength(&DummyIT);
          StartGadget.ng_Height = gadheight;

          DummyIT.IText = "555555";
          ClockGadget.ng_Height = gadheight;
          ClockGadget.ng_Width = GUISPACE*2+IntuiTextLength(&DummyIT);
          ClockGadget.ng_TopEdge = GUISPACE;
          ClockGadget.ng_LeftEdge = scrwidth-ClockGadget.ng_Width-GUISPACE*2;

          retval = TRUE;
        }
      }
    }
  }
  return(retval);
}

///
/// BOOL CreateGadgets()

BOOL
CreateGadgets(void)
{
  BOOL retval = FALSE;

  if (gad = CreateContext(&glist))
  {
    StartGadget.ng_TextAttr = PManAttr;
    StartGadget.ng_VisualInfo = vi;

    ClockGadget.ng_TextAttr = PManAttr;
    ClockGadget.ng_VisualInfo = vi;

    gad = startgad = CreateGadget(BUTTON_KIND, gad, &StartGadget, TAG_DONE);
    gad = clockgad = CreateGadget(TEXT_KIND, gad, &ClockGadget, GTTX_Border, TRUE,
                                                                TAG_DONE);

    if (gad) retval = TRUE;
  }
  return(retval);
}

///
/// void RenderMainWindow()

void
RenderMainWindow(void)
{
  if (managerwin->Height > 1)
  {
    SetAPen(managerwin->RPort, fillpen);
    RectFill(managerwin->RPort, 0, 0, managerwin->Width, managerwin->Height);

    DrawBevelBox(managerwin->RPort, 0, 0, managerwin->Width, managerwin->Height,
                                          GT_VisualInfo, vi,
                                          TAG_DONE);

    RefreshGadgets(glist, managerwin, NULL);
    GT_RefreshWindow(managerwin, NULL);
  }
  else
  {
    Move(managerwin->RPort, 0, 0);
    SetAPen(managerwin->RPort, shinepen);
    Draw(managerwin->RPort, scrwidth, 0);
  }
}

///

/// void SetupMenu()

void
SetupMenu(void)
{


  Wait(SIGBREAKF_CTRL_D);
}

///

/// void FreeResources()

void
FreeResources(void)
{
  if (timeropen) CloseDevice((struct IORequest *) timerio);

  DeleteIORequest((struct IORequest *) timerio);
  DeleteMsgPort(timerport);

  if (managerwin) CloseWindow(managerwin);

  FreeGadgets(glist);

  if (vi) FreeVisualInfo(vi);
  if (drawinfo) FreeScreenDrawInfo(wbscreen, drawinfo);
  if (wbscreen) UnlockPubScreen(NULL, wbscreen);

  if (PManFont) CloseFont(PManFont);
  if (fontname) FreeVec(fontname);

  if (Prefs) FreePrefs();

  if (pmanbroker) DeleteCxObj(pmanbroker);
  if (pmancxport) DeleteMsgPort(pmancxport);

  CloseLibrary((struct Library *) IntuitionBase);
  CloseLibrary((struct Library *) GfxBase);
  CloseLibrary((struct Library *) GadToolsBase);
  CloseLibrary((struct Library *) DiskFontBase);
  CloseLibrary((struct Library *) CxBase);
}

///

/// void main(void)

void
main(void)
{

  BOOL exitflag = FALSE;
  ULONG signals, currsig;

  if ((IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 39L)) &&
      (GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 39L)) &&
      (GadToolsBase = (struct GadToolsBase *) OpenLibrary ("gadtools.library", 39L)) &&
      (DiskFontBase = (struct DiskFontBase *) OpenLibrary ("diskfont.library", 39L)) &&
      (CxBase = (struct CxBase *) OpenLibrary("commodities.library", 39L)))
  {
    if (BuildPreferences())
    {
      if (MakeCx())
      {
        if (PrepareTimer())
        {
          if (CalcGUI())
          {
            if (CreateGadgets())
            {
               if (managerwin = OpenWindowTags(NULL, WA_Left, 0,
                                                     WA_Top, scrheight,
                                                     WA_Width, scrwidth,
                                                     WA_Height, 1,
                                                     WA_Borderless, TRUE,
                                                     WA_SmartRefresh, TRUE,
                                                     WA_RMBTrap, TRUE,
                                                     WA_IDCMP,IDCMP_NEWSIZE | IDCMP_GADGETUP,
                                                     WA_Gadgets, glist,
                                                     TAG_DONE))
               {
                 winsigset = 1<<managerwin->UserPort->mp_SigBit;

                 RenderMainWindow();

                 GT_RefreshWindow(managerwin, NULL);

                 while (!exitflag)
                 {
                   signals = SIGBREAKF_CTRL_C | winsigset;

                   switch(menumode)
                   {
                     case MODE_DOWN:
                       signals = signals | timesigset;
                       StartTimer(0, POP_MICROS);
                       break;

                     case MODE_UP:
                       signals = signals | timesigset;
                       StartTimer(0, POP_MICROS);
                       break;

                     case MODE_MENU:
                       signals = signals | timesigset;
                       StartTimer(TIMEOUT_SECS, 0);
                       break;

                     case MODE_LOADING:
                       break;
                   }

                   currsig = Wait(signals);

                   if (currsig & timesigset)
                   {
                     switch(menumode)
                     {
                       case MODE_UP:
                         currpos = MousePosition();

                         if (currpos < scrheight-winheight)
                         {
                           ChangeWindowBox(managerwin, 0, scrheight-1,
                                                       scrwidth, 1);

                           menumode = MODE_DOWN;
                         }
                         break;

                       case MODE_DOWN:
                         currpos = MousePosition();

                         if (currpos == scrheight-1)
                         {
                           ChangeWindowBox(managerwin, 0, scrheight-winheight,
                                                       scrwidth, winheight);

                           SetTime();

                           menumode = MODE_UP;
                         }
                         break;

                       case MODE_MENU:
                         SetupMenu();

                         menumode = MODE_UP;
                         break;
                     }
                   }
                   else if (currsig & winsigset)
                   {
                     while (winmessage = GT_GetIMsg(managerwin->UserPort))
                     {
                       switch(winmessage->Class)
                       {
                         case IDCMP_NEWSIZE:
                           RenderMainWindow();
                           break;

                         case IDCMP_GADGETUP:
                           menumode = MODE_MENU;
                           break;
                       }

                       GT_ReplyIMsg(winmessage);
                     }
                   }
                   else if (currsig & SIGBREAKF_CTRL_C)
                     exitflag = TRUE;
                 }
               }
               AbortIO((struct IORequest *) timerio);
               WaitIO((struct IORequest *) timerio);
             }
           }
         }
       }
     }
   }
 FreeResources();
}

///
