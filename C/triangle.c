//-------------------------------------------------------------------
// "Sierpinski Triangle" by Morten Amundsen (15 Mar 1996, 18:02:30)
//-------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <intuition/intuition.h>
#include <dos/dosextens.h>
#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

void FreeAll(void);

#define WIDTH 640       // window width and height
#define HEIGHT 256

int   x1=0, y1=0,   // initial coords
      x2=WIDTH/4, y2=HEIGHT,
      x3=WIDTH, y3=HEIGHT,
      px, py;

struct Library *IntuitionBase, *GfxBase;
struct Window *win;

void
FreeAll(void)
{
  if (win) CloseWindow(win);

  CloseLibrary(GfxBase);
  CloseLibrary(IntuitionBase);
}

void
main(void)
{
  int i;

  if ((IntuitionBase = (struct Library *) OpenLibrary("intuition.library", 39)) &&
      (GfxBase = (struct Library *) OpenLibrary("graphics.library", 39)))
  {
    if (win = OpenWindowTags(NULL,  WA_Left, 0,
                                    WA_Top, 0,
                                    WA_InnerWidth, WIDTH,
                                    WA_InnerHeight, HEIGHT,
                                    WA_GimmeZeroZero, TRUE,
                                    WA_DragBar, TRUE,
                                    WA_DepthGadget, TRUE,
                                    WA_RMBTrap, TRUE,
                                    TAG_DONE))
    {
      px = rand() % WIDTH;        // calc first point (random)
      py = rand() % HEIGHT;

      for (i=0;i<50000;i++)       // iterate 50000 times
      {
        switch(rand() % 3)
        {
          case 0:                 // move towards (x¹, y¹)
            px = px+((x1-px)/2);
            py = py+((y1-py)/2);
            break;
          
          case 1:                 // move towards (x², y²)
            px = px+((x2-px)/2);
            py = py+((y2-py)/2);
            break;

          case 2:                 // move towards (x³, y³)
            px = px+((x3-px)/2);
            py = py+((y3-py)/2);
            break;
        }
        WritePixel(win->RPort, px, py);   // write pixel of new (px,py)
      }
      Wait(SIGBREAKF_CTRL_C);   
    }
  }
  FreeAll();
}
