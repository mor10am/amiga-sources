s:
	movem.l	d0-d7/a0-a6,-(a7)

	bsr.l	Initprogram		; Init NICE

	move.l	4,a6			; Open DOS library
	lea	Dos,a1
	moveq	#0,d0
	jsr	-408(a6)
	tst.l	d0
	beq.s	MainExit

	move.l	d0,DosBase		; Save DOS Base address
	moveq	#0,d0

	move.l	DosBase,a6		; Open NICE Window
	move.l	#Window,d1
	move.l	#1005,d2
	jsr	-30(a6)
	tst.l	d0
	beq.s	CloseDOS

	move.l	d0,handle		; Window Handle
	moveq	#0,d0

	move.l	DosBase,a6		; Output Startmessage
	move.l	handle,d1
	move.l	#BEGIN,d2
	move.l	#BEGINend-BEGIN,d3
	jsr	-48(a6)

Operations:
	tst.w	ExitFlag		; Test if finished
	bne.s	CloseSystem

	bsr.w	WritePROMPT		; Write Prompt
	bra.w	GetCommand		; Get Command

CloseSystem:
	tst.w	AnythingLoaded
	beq.s	CloseWindow

	bsr.w	FreeAllMemory

CloseWindow:
	move.l	DosBase,a6		; Close Window
	move.l	handle,d1
	jsr	-36(a6)

CloseDOS:				; Close Dos library
	move.l	4,a6
	move.l	DosBase,a1
	jsr	-414(a6)

MainExit:				; Exit NICE
	movem.l	(a7)+,d0-d7/a0-a6
	moveq	#0,d0
	rts

InitProgram:
	lea	Pointers,a0		; Make Pointer table to
	lea	Commands,a1		; M68000 and Seka commands
	moveq	#0,d0
	move.w	#151,d7
MakePoint:
	move.l	a1,(a0)+
	add.l	#$8,a1
	dbra	d7,MakePoint	
	
	rts


OutputHELP:				; Help Screen
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#HELP,d2
	move.l	#HELPend-HELP,d3
	jsr	-48(a6)

	rts

OutputCREDITS:				; Credits Screen
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#CREDITS,d2
	move.l	#CREDITSend-CREDITS,d3
	jsr	-48(a6)

	rts

WritePROMPT:				; prompt sign
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#PROMPT,d2
	move.l	#PROMPTend-PROMPT,d3
	jsr	-48(a6)

	rts

GetCommand:
	bsr.w	ClearCommandBuffer	; Clear Command buffer

	move.l	DosBase,a6		; Read in new command
	move.l	Handle,d1
	move.l	#CommandBuffer,d2
	move.l	#80,d3
	jsr	-42(a6)

	lea	CommandBuffer,a0	; Check if just RETURN
	cmp.b	#$0a,(a0)
	bne.s	CheckCommand

	bsr.L	ClearWindow		; ...then clear screen

	bra.s	Return			; Get next command

CheckCommand:
	bsr.s	MakeCommandUpperCase	; command uppercase

	moveq	#0,d0
	moveq	#0,d1
	lea	NiceCommands,a0		; Evaluate command
	move.l	CommandBuffer,d0
Evaluate:
	moveq	#0,d2
	move.l	(a0)+,d2
	cmp.l	d0,d2
	beq.s	OKcommand
	add.w	#1,d1
	cmp.l	#WrongCommand,a0
	bne.s	Evaluate

	bsr.s	UnknownCommand		; Not legal
Return:
	bra.w	Operations		; Get new command

OKcommand:
	lsl.w	#2,d1
	lea	Routines,a0
	move.l	(a0,d1.w),a1
	jsr	(a1)			; Jump to command subrout.
	
	bra.w	Operations		; get new command

ClearCommandBuffer:			; Clear command buffer
	lea	CommandBuffer,a0
	move.w	#79,d7
CLRloop:
	clr.b	(a0)+
	dbra	d7,CLRloop
	rts

MakeCommandUpperCase:			; uppercase
	lea	CommandBuffer,a0
UCase:
	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#$0a,d0
	beq.w	AllUpperCase

	cmp.b	#97,d0
	blt.s	NextLetter
	cmp.b	#122,d0
	bgt.s	NextLetter
	sub.b	#32,d0
NextLetter:
	move.b	d0,(a0)+
	bra.s	UCase

AllUpperCase:
	rts

UnknownCommand:				; unknown command
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#UNKNOWN,d2
	move.l	#UNKNOWNend-UNKNOWN,d3
	jsr	-48(a6)
	rts

OutputMESSAGE:				; hidden text
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#MESSAGE,d2
	move.l	#MESSAGEend-MESSAGE,d3
	jsr	-48(a6)
	rts

ExitNICE:				; set exitflag; finished
	move.w	#1,ExitFlag
	rts

LoadProgram:				; load program
	tst.w	AnythingLoaded		; Check if first time
	beq.s	NothingLoaded

	bsr.w	FreeAllMemory		; free all memory

NothingLoaded:
	bsr.w	PrepareFile

	tst.w	Nothing_Typed
	bne.L	DoNothing

	move.l	Dosbase,a6		; open file
	move.l	#CommandBuffer,d1
	move.l	#1005,d2
	jsr	-30(a6)
	tst.l	d0
	beq.w	FileNotFound

	move.l	d0,Filehandle

	move.l	#CommandBuffer,d1	; get file lock
	move.l	#-2,d2
	jsr	-84(a6)

	move.l	d0,FileLock

	move.l	FileLock,d1		; examine file
	move.l	#InfoBlock,d2
	jsr	-102(a6)

	lea	InfoBlock,a0		; get filelength
	move.l	124(a0),FileLength

	move.l	FileLock,d1		; unlock file
	jsr	-90(a6)

	move.l	4,a6			; alloc mem for file
	move.l	FileLength,d0
	add.l	#8,d0
	move.l	#$10000,d1
	jsr	-198(a6)	
	tst.l	d0
	beq.L	NoMemory1

	move.l	d0,SekaBuffer

	move.l	FileLength,d0		; alloc mem for buffer
	add.l	#1024,d0
	move.l	#$10000,d1
	jsr	-198(a6)
	tst.l	d0
	beq.s	NoMemory2

	move.l	d0,NICEBuffer
	move.l	d0,NICEpointer

	move.l	DosBase,a6		; read file
	move.l	filehandle,d1
	move.l	SekaBuffer,d2
	move.l	FileLength,d3
	jsr	-42(a6)
	moveq	#0,d0

	move.w	#1,BufOK
	move.w	#1,AnythingLoaded

	bsr.w	HasBeenLoaded		; output ok message

	move.l	SekaBuffer,a0		; set end sign of file
	add.l	FileLength,a0
	clr.b	(a0)

CFile:
	bsr.w	CloseFile
DoNothing:
	rts

NoMemory2:				; free memory
	move.l	SekaBuffer,a1
	move.l	FileLength,d0
	add.l	#8,d0
	jsr	-210(a6)
NoMemory1:
	bsr.s	NoMemory
	clr.w	BufOk
	clr.w	AnythingLoaded
	clr.w	ProgramNICE
	bra.s	CFile

FreeAllMemory:				; free memory
	move.l	4,a6

	move.l	SekaBuffer,a1
	move.l	FileLength,d0
	add.l	#8,d0
	jsr	-210(a6)

	move.l	NICEBuffer,a1
	move.l	FileLength,d0
	add.l	#1024,d0
	jsr	-210(a6)
	rts

NoMemory:				; no mem message
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#NOMEM,d2
	move.l	#NOMEMend-NOMEM,d3
	jsr	-48(a6)
	rts

FileNotFound:				; file not found message
	clr.w	BufOk
	clr.w	AnythingLoaded
	bsr.s	File_Not_Found
	rts

HasBeenLoaded:				; loading ok
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#LOADED,d2
	move.l	#LOADEDend-LOADED,d3
	jsr	-48(a6)
	rts

CloseFile:				; close file
	move.l	DosBase,a6
	move.l	FileHandle,d1
	jsr	-36(a6)
	rts

PrepareFile:				; PREPARE FILE
	bsr.s	PromptFilename		; ask for filename
	bsr.s	FillBuffer		; get filename

	tst.w	Nothing_Typed
	bne.s	NoRemove	

	bsr.w	RemoveCR		; remove CR ($0a)
NoRemove:
	rts

PrepareFileSave:			; PREPARE FILE
	bsr.s	PromptFilename		; ask for filename
	bsr.s	FillBuffer		; get filename

	tst.w	Nothing_Typed
	bne.s	NoRemove2	

	bsr.w	RemoveCRNice		; remove CR ($0a) and
NoRemove2:
	rts				; add '.nic'

File_Not_Found:				; file not found message
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#NOTFOUND,d2
	move.l	#NOTFOUNDend-NOTFOUND,d3
	jsr	-48(a6)
	rts

ClearWindow:				; clear window
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#CLEAR,d2
	move.l	#CLEARend-CLEAR,d3
	jsr	-48(a6)
	rts

PromptFileName:				; ask for filename
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#FILENAME,d2
	move.l	#FILENAMEend-FILENAME,d3
	jsr	-48(a6)
	rts

FillBuffer:				; get filename
	bsr.w	ClearCommandBuffer	; clear command buffer

	move.l	DosBase,a6		; read keyboard
	move.l	Handle,d1
	move.l	#CommandBuffer,d2
	move.l	#80,d3
	jsr	-42(a6)

	lea	CommandBuffer,a0
	cmp.b	#$0a,(a0)
	bne.s	FileName_Entered

	bsr.L	User_Break

	move.w	#1,Nothing_Typed
	bra.s	Return_To_CheckFlag
Filename_Entered:
	clr.w	Nothing_Typed

Return_To_CheckFlag:
	rts

RemoveCR:				; remove CR ($0a)
	lea	CommandBuffer,a0
CRloop:
	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#$0a,d0
	bne.s	LegalChar

	move.b	#'.',(a0)+
	move.b	#'s',(a0)+
	move.b	#0,(a0)
	bra.s	Removed	
LegalChar:
	move.b	d0,(a0)+
	bra.s	CRloop
Removed:
	rts

RemoveCRNICE:				; remove CR ($0a) and
	lea	CommandBuffer,a0	; add '.nic'
CRloop2:
	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#$0a,d0
	bne.s	LegalChar2

	move.b	#'.',(a0)+
	move.b	#'n',(a0)+
	move.b	#'i',(a0)+
	move.b	#'c',(a0)+
	move.b	#0,(a0)
	bra.s	Removed2
LegalChar2:
	move.b	d0,(a0)+
	bra.s	CRloop2
Removed2:
	rts

SaveNICEProgram:			; Save NICE program

	tst.w	ProgramNICE		; Is it NICE
	beq.L	NoSave			; ...NO!
	
	bsr.w	PrepareFileSave		; YES! Prepare file

	tst.w	Nothing_Typed
	bne.s	OpenError

	move.l	DosBase,a6		; Open for write
	move.l	#CommandBuffer,d1
	move.l	#1006,d2
	jsr	-30(a6)
	move.l	d0,WriteHandle

	move.l	WriteHandle,d1		; Write file
	move.l	NICEbuffer,d2
	move.l	NICELength,d3
	jsr	-48(a6)

	bsr.s	HasBeenSaved		; Ok saving

	move.l	WriteHandle,d1		; close file
	jsr	-36(a6)

OpenError:
	rts

User_Break:
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#BREAK,d2
	move.l	#BREAKend-BREAK,d3
	jsr	-48(a6)
	rts

HasBeenSaved:				; Ok saving message
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#SAVED,d2
	move.l	#SAVEDend-SAVED,d3
	jsr	-48(a6)
	rts

NoSave:					; Not NICE message
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#NOTNICED,d2
	move.l	#NOTNICEDend-NOTNICED,d3
	jsr	-48(a6)
	rts

NoBuffer:				; nothing loaded
	move.l	DosBase,a6
	move.l	handle,d1
	move.l	#NOBUF,d2
	move.l	#NOBUFend-NOBUF,d3
	jsr	-48(a6)
	rts

MakeNICE:				; Make Sekafile NICE
	tst.w	BufOK			; Anything Loaded?
	beq.s	NoBuffer		; ...NO!

	move.w	#1,ProgramNICE		; YES! Do NICE

	move.l	SekaBuffer,a0
	move.l	NicePointer,a1
NICELoop:
	bsr.L	Clear_ConvertBuffer
	bsr.L	Fill_ConvertBuffer

	lea	ConvertBuffer,a2
	tst.b	(a2)
	bne.s	Read_Word

	tst.w	NICE_Done
	beq.s	NICELoop
	bra.L	NICE_Finished

Read_Word:
	bsr.L	Clear_Word
	lea	Word,a3
Read_Char:
	moveq	#0,d0
	move.b	(a2),d0
	
	tst.b	d0
	beq.L	Check_Word
	cmp.b	#$09,d0
	beq.L	Check_Word
	cmp.b	#$0a,d0
	beq.L	Check_Word
	cmp.b	#' ',d0
	beq.L	Check_Word
	cmp.b	#',',d0
	beq.L	Check_Word
	cmp.b	#'#',d0
	beq.L	Check_Word
	cmp.b	#'$',d0
	beq.L	Check_Word
	cmp.b	#':',d0
	beq.L	Check_Word
	cmp.b	#';',d0
	beq.L	Check_Word
	cmp.b	#'.',d0
	beq.L	Check_Word
	cmp.b	#'(',d0
	beq.L	Check_Word
	cmp.b	#')',d0
	beq.L	Check_Word
	cmp.b	#'-',d0
	beq.L	Check_Word
	cmp.b	#'+',d0
	beq.L	Check_Word
	cmp.b	#'/',d0
	beq.L	Check_Word
	cmp.b	#'[',d0
	beq.L	Check_Word
	cmp.b	#']',d0
	beq.L	Check_Word
	cmp.b	#'"',d0
	beq.L	Check_Word
	cmp.b	#39,d0
	beq.L	Check_Word

	move.b	(a2)+,(a3)+
	bra.L	Read_Char

Insert_Word:
	lea	Word,a3
Insert_It:
	tst.b	(a3)
	beq.s	Inserted

	moveq	#0,d0
	move.b	(a3)+,d0
	move.b	d0,$dff180
	move.b	d0,(a1)+
	bra.s	Insert_It
	
Inserted:
	moveq	#0,d0
	move.b	(a2),d0

	tst.b	d0
	beq.L	End_Of_Line
	cmp.b	#$09,d0
	beq.L	Skip_Char
	cmp.b	#$0a,d0
	beq.L	New_Line
	cmp.b	#' ',d0
	beq.L	Insert_This
	cmp.b	#'(',d0
	beq.L	Insert_This
	cmp.b	#')',d0
	beq.L	Insert_This
	cmp.b	#'[',d0
	beq.L	Insert_This
	cmp.b	#']',d0
	beq.L	Insert_This
	cmp.b	#'/',d0
	beq.L	Insert_This
	cmp.b	#'-',d0
	beq.L	Insert_This
	cmp.b	#'+',d0
	beq.L	Insert_This
	cmp.b	#',',d0
	beq.L	Insert_This
	cmp.b	#'#',d0
	beq.L	Insert_This	;Label_Address
	cmp.b	#'$',d0
	beq.L	Insert_This	;Address
	cmp.b	#':',d0
	beq.L	Colon
	cmp.b	#';',d0
	beq.L	Fill_Until
	cmp.b	#'*',d0
	beq.L	Fill_Until
	cmp.b	#'.',d0
	beq.L	Notation
	cmp.b	#'"',d0
	beq.L	Insert_And_Until_Next
	cmp.b	#39,d0
	beq.L	Insert_And_Until_Next

Test_Finished:
	tst.w	NICE_done
	beq.L	Read_Word
	bra.L	NICE_Finished

Check_Word:
	lea	Word,a3
	tst.b	(a3)
	bne.s	Cont_Check

	bra.L	Inserted

Cont_Check:
	bsr.L	Make_Word_UpperCase

	lea	Pointers,a4
Com_Loop:
	cmp.l	#PointEnd,a4
	bge.s	Has_To_Be_Label

	lea	Word,a3
	move.l	(a4),a5

	moveq	#0,d0
	moveq	#0,d1

Loop_Search:
	move.b	(a3)+,d0
	move.b	(a5)+,d1

	tst.b	d0
	beq.s	Check_If_D1_NULL

Check_Them:
	cmp.b	d0,d1
	bne.s	No_Match
	bra.s	Loop_Search

No_Match:
	addq.w	#$4,a4	
	bra.s	Com_Loop

Check_If_D1_NULL:
	tst.b	d1
	bne.s	Check_Them
	bra.s	Has_To_Be_Command

Has_To_Be_Label:
	lea	Word+1,a3
LowCaseLoop:
	moveq	#0,d0
	move.b	(a3),d0
	tst.b	d0
	beq.s	Done_LowCase

	cmp.b	#'_',d0
	beq.s	NextLowCase

	cmp.b	#'A',d0
	blt.s	NextLowCase
	cmp.b	#'Z',d0
	bgt.s	NextLowCase

	add.b	#32,d0

NextLowCase:
	move.b	d0,(a3)+
	bra.s	LowCaseLoop

Done_LowCase:
	bra.L	Insert_Word

Has_To_Be_Command:
	lea	Word,a3
Find_End:
	tst.b	(a3)+
	bne.s	Find_End

	move.l	a3,a4
	sub.l	#$1,a3

Find_Beginning:
	move.b	-(a3),-(a4)
	cmp.l	#Word-1,a3
	bne.s	Find_Beginning

	move.b	#$09,(a4)

	lea	Word,a3
Find_End2:
	tst.b	(a3)
	beq.s	Found_End2
	add.l	#$1,a3
	bra.s	Find_End2

Found_End2:
	cmp.b	#'.',(a2)
	bne.s	Insert_TAB

	move.b	(a2)+,(a3)+
	moveq	#0,d0
	move.b	(a2)+,d0
	bsr.l	Make_Char_LowCase
	move.b	d0,(a3)+

Insert_TAB:
	cmp.b	#$0a,(a2)
	beq.s	Skip_TAB

	move.b	#$09,(a3)+

Skip_TAB:
	bra.L	Insert_Word

Nice_Finished:
	move.b	#$0a,(a1)+
	move.l	NICEbuffer,a4
	sub.l	a4,a1
	move.l	a1,NICElength

	rts

Make_Word_UpperCase:
	lea	Word,a3
UCaseLoop:
	tst.b	(a3)
	beq.s	Word_UpperCase

	moveq	#0,d0
	move.b	(a3),d0

	cmp.b	#'a',d0
	blt.s	Next_Char
	cmp.b	#'z',d0
	bgt.s	Next_Char
	sub.b	#32,d0
Next_Char:
	move.b	d0,(a3)+
	bra.s	UCaseLoop

Word_UpperCase:
	rts

Fill_Until:
	move.b	#$09,(a1)+
	move.b	(a2)+,(a1)+
LoopUntil:
	moveq	#0,d0
	move.b	(a2)+,d0
	cmp.b	#$0a,d0
	beq.s	OutLoop
	move.b	d0,(a1)+
	bra.s	LoopUntil
OutLoop:
	move.b	#$0a,(a1)+
	bra.L	Test_Finished

Colon:	
	move.b	(a2)+,(a1)+
	cmp.b	#$0a,(a2)
	beq.s	No_CR_insert
	move.b	#$0a,(a1)+
No_CR_Insert:
	bra.L	Test_Finished

Skip_Char:
	add.l	#$1,a2
	bra.L	Test_Finished

End_Of_Line:
	cmp.b	#$09,-(a1)
	bne.s	Set_In_CR

	bra.s	Set_It

Notation:
	move.b	(a2)+,(a1)+
	moveq	#0,d0
	move.b	(a2)+,d0
	bsr.s	Make_Char_LowCase
	move.b	d0,(a1)+
	bra.l	Test_Finished

Set_In_CR:
	add.l	#$1,a1
Set_It:
	move.b	#$0a,(a1)+
	bra.L	NICEloop

Insert_This:
	move.b	(a2)+,(a1)+
	bra.L	Test_Finished

New_Line:
	move.b	(a2)+,(a1)+
	bra.L	Test_Finished

	moveq	#0,d0
Number_Of_CR:
	cmp.b	#$0a,(a2)+
	bne.s	Insert_Found_CR
	addq.w	#1,d0
	bra.s	Number_Of_CR

Insert_Found_CR:
	cmp.w	#2,d0
	ble.s	Ok_Antall
	move.w	#2,d0
Ok_antall:
	subq.w	#1,d0
Insert_Found:
	move.b	#$0a,(a1)+
	dbra	d0,Insert_Found
	bra.L	Test_finished

Insert_And_Until_Next:
	moveq	#0,d1
	move.b	(a2)+,d1
	move.b	d1,(a1)+
Insert_Until:
	moveq	#0,d0
	move.b	(a2)+,d0
	move.b	d0,(a1)+
	cmp.b	d0,d1
	bne.s	Insert_Until
	bra.L	Test_Finished

Make_Char_LowCase:
	cmp.b	#'A',d0
	blt.s	No_LowCase
	cmp.b	#'Z',d0
	bgt.s	No_LowCase
	add.b	#32,d0
No_LowCase:
	rts

Fill_ConvertBuffer:
	lea	ConvertBuffer,a2
FillLoop:
	tst.b	(a0)
	bne.s	Test_CR

	move.w	#1,Nice_Done
	bra.s	ConvertBuffer_Filled

Test_CR:
	cmp.b	#$0a,(a0)
	beq.s	ConvertBuffer_Filled

	move.b	(a0)+,(a2)+
	bra.s	FillLoop

ConvertBuffer_Filled:
	add.l	#$1,a0
	rts


Clear_ConvertBuffer:
	lea	ConvertBuffer,a2
	move.w	#159,d7
CLRConv:
	clr.b	(a2)+
	dbf	d7,CLRConv
	rts

Clear_Word:
	lea	Word,a3
	move.w	#79,d7
CLRWord:
	clr.b	(a3)+
	dbf	d7,CLRWord
	rts

*************************************************************

ConvertBuffer:	blk.b	160,0	; Temp Buffer for Converting
				; from Seka to NICE
Word:		blk.b	80,0	

NICE_Done:	dc.w	0




************************************************************

; DOS

DosBase:	dc.l	0
Dos:		dc.b	'dos.library',0
even

************************************************************

; 0 - no exit : 1 - exit NICE

ExitFlag:	dc.w	0

************************************************************

; Window

Handle:		dc.l	0
Window:		dc.b	'CON:0/0/640/256/AmigaNICE v1.0',0
even

************************************************************

; Output Messages

BEGIN:
	dc.b	$0c
	dc.b	10,13
	dc.b	"                                 "
	dc.b	"AmigaNICE v1.0",10,13
	dc.b	"                         "
	dc.b	"Seka Program Layout Optimizer",10,10,13
	dc.b	"                         "
	dc.b	"A Program By Morten Amundsen",10,13
	dc.b	"              "
	dc.b	"This Program Is Not Protected By Any Copyright Laws"
	dc.b	10,13
	dc.b	"                         "
	dc.b	"Type HELP For Instructions Menu",10,10,10,13
	dc.b	0
BEGINend:
even

CREDITS:
	dc.b	$0c
	dc.b	10,13
	dc.b	"AmigaNICE v1.0 was coded in assembly language "
	dc.b	"by Morten Amundsen.",10,10,13
	dc.b	"This program was inspired by the NICE-program "
	dc.b	"which is on the Computer Net",10,13
	dc.b	"at Oslo University.",10,10,13

	dc.b	"Hello to Tommy Rivrud, Morten Brenna, "
	dc.b	"Geir Vegard Lie and all other friends!",10,10,13
CREDITSend:
even

HELP:
	dc.b	$0c
	dc.b	10,13
	dc.b	"AmigaNICE Commands:",10,10,13
	dc.b	"    HELP ........... Help Menu",10,13
	dc.b	"    LOAD ........... Load Seka Program",10,13
	dc.b	"    SAVE ........... Save NICE Program",10,13
	dc.b	"    NICE ........... Make It NICE",10,13
	dc.b	"    CRED ........... Credits",10,13
	dc.b	"    EXIT ........... Exit AmigaNICE",10,10,13
	dc.b	0
HELPend:
even



CLEAR:	dc.b	$0c,0
CLEARend:
even

FILENAME:
	dc.b	"Filename: ",0
FILENAMEend:
even

NOMEM:
		dc.b	"** ERROR! Not Enough Memory!",10,10,13,0
NOMEMend:
even

NOTNICED:
		dc.b	"** ERROR! Program Is Not NICED",10,10,13,0
NOTNICEDend:
even

PROMPT:
	dc.b	'>',0
PROMPTend:
even

UNKNOWN:
	dc.b	"** ERROR! Unknown Command!",10,10,13,0
UNKNOWNend:
even

NOTFOUND:
	dc.b	"** ERROR! File Not Found!",10,10,13,0
NOTFOUNDend:
even

BREAK:
	dc.b	"** USER BREAK!",10,10,13,0
BREAKend:
even

LOADED:
	dc.b	"Loading Was Successful!",10,10,13,0
LOADEDend:
even

SAVED:
	dc.b	"Saving Was Successful!",10,10,13,0
SAVEDend:
even

NOBUF:
	dc.b	"** ERROR! Program Buffer Is Empty!",10,10,13,0
NOBUFend:
even

MESSAGE:
dc.b	$0c
dc.b	"Some message..."
dc.b	10,10,10,13
dc.b	0
MESSAGEend:
even

**************************************************************

; Program Declares

BufOK:		dc.w	0	; 1 = Ok to make Seka NICE

WriteHandle:	dc.l	0	; Write file Handle
Filehandle:	dc.l	0	; Read file Handle

ProgramNICE:	dc.w	0	; 1 = Program is now NICE
AnythingLoaded:	dc.w	0	; 1 = Seka file has been loaded
				;     FreeAllMem is LEGAL

FileLength:	dc.l	0	; Seka Filelength
NICELength:	dc.l	0	; NICE Filelength

FileLock:	dc.l	0	; File Lock
cnop	0,4
InfoBlock:	blk.b	260,0	; File Lock InfoBlock

SekaBuffer:	dc.l	0	; Pointer to Seka Buffer
NICEBuffer:	dc.l	0	; Pointer to NICE Buffer
NICEPointer:	dc.l	0	; Pointer to Current NICE pos.

CommandBuffer:	blk.b	80,0	; Command Buffer

Nothing_Typed:	dc.w	0

***************************************************************

Routines:			; NICE Routines
	dc.l	ExitNICE
	dc.l	OutputHELP
	dc.l	LoadProgram
	dc.l	MakeNICE
	dc.l	SaveNICEProgram
	dc.l	OutputCredits
	dc.l	OutputMessage

NiceCommands:			; Legal NICE Commands
	dc.b	"EXIT"
	dc.b	"HELP"
	dc.b	"LOAD"
	dc.b	"NICE"
	dc.b	"SAVE"
	dc.b	"CRED"
	dc.b	"FUCK"
WrongCommand:			; WrongCommand reached, and
even				; there has been typed an
				; unknown command

*****************************************************************

Pointers:	blk.l	152,0	; Pointer table to commands
PointEnd:

COMMANDS:			; M68000 commands
	dc.b	"ABCD",0,0,0,0
	dc.b	"ADD",0,0,0,0,0
	dc.b	"ADDA",0,0,0,0
	dc.b	"ADDI",0,0,0,0
	dc.b	"ADDQ",0,0,0,0
	dc.b	"ADDX",0,0,0,0
	dc.b	"AND",0,0,0,0,0
	dc.b	"ANDI",0,0,0,0
	dc.b	"ASL",0,0,0,0,0
	dc.b	"ASR",0,0,0,0,0
	dc.b	"BCC",0,0,0,0,0
	dc.b	"BCS",0,0,0,0,0
	dc.b	"BEQ",0,0,0,0,0
	dc.b	"BGE",0,0,0,0,0
	dc.b	"BGT",0,0,0,0,0
	dc.b	"BHI",0,0,0,0,0
	dc.b	"BLE",0,0,0,0,0
	dc.b	"BLS",0,0,0,0,0
	dc.b	"BLT",0,0,0,0,0
	dc.b	"BMI",0,0,0,0,0
	dc.b	"BNE",0,0,0,0,0
	dc.b	"BPL",0,0,0,0,0
	dc.b	"BVC",0,0,0,0,0
	dc.b	"BVS",0,0,0,0,0
	dc.b	"BRA",0,0,0,0,0
	dc.b	"BCHG",0,0,0,0
	dc.b	"BCLR",0,0,0,0
	dc.b	"BSET",0,0,0,0
	dc.b	"BSR",0,0,0,0,0
	dc.b	"BTST",0,0,0,0
	dc.b	"CHK",0,0,0,0,0
	dc.b	"CLR",0,0,0,0,0
	dc.b	"CMP",0,0,0,0,0
	dc.b	"CMPA",0,0,0,0
	dc.b	"CMPI",0,0,0,0
	dc.b	"CMPM",0,0,0,0
	dc.b	"DBCC",0,0,0,0
	dc.b	"DBCS",0,0,0,0
	dc.b	"DBEQ",0,0,0,0
	dc.b	"DBGE",0,0,0,0
	dc.b	"DBGT",0,0,0,0
	dc.b	"DBHI",0,0,0,0
	dc.b	"DBLE",0,0,0,0
	dc.b	"DBLS",0,0,0,0
	dc.b	"DBLT",0,0,0,0
	dc.b	"DBMI",0,0,0,0
	dc.b	"DBNE",0,0,0,0
	dc.b	"DBPL",0,0,0,0
	dc.b	"DBRA",0,0,0,0
	dc.b	"DBVC",0,0,0,0
	dc.b	"DBVS",0,0,0,0
	dc.b	"DBF",0,0,0,0,0
	dc.b	"DBT",0,0,0,0,0
	dc.b	"DIVS",0,0,0,0
	dc.b	"DIVU",0,0,0,0
	dc.b	"EOR",0,0,0,0,0
	dc.b	"EORI",0,0,0,0
	dc.b	"EXG",0,0,0,0,0
	dc.b	"EXT",0,0,0,0,0
	dc.b	"ILLEGAL",0
	dc.b	"JMP",0,0,0,0,0
	dc.b	"JSR",0,0,0,0,0
	dc.b	"LEA",0,0,0,0,0
	dc.b	"LINK",0,0,0,0
	dc.b	"LSL",0,0,0,0,0
	dc.b	"LSR",0,0,0,0,0
	dc.b	"MOVE",0,0,0,0
	dc.b	"MOVEA",0,0,0
	dc.b	"MOVEC",0,0,0
	dc.b	"MOVEM",0,0,0
	dc.b	"MOVEP",0,0,0
	dc.b	"MOVEQ",0,0,0
	dc.b	"MOVES",0,0,0
	dc.b	"MULS",0,0,0,0
	dc.b	"MULU",0,0,0,0
	dc.b	"NBCD",0,0,0,0
	dc.b	"NEG",0,0,0,0,0
	dc.b	"NEGX",0,0,0,0
	dc.b	"NOP",0,0,0,0,0
	dc.b	"NOT",0,0,0,0,0
	dc.b	"OR",0,0,0,0,0,0
	dc.b	"ORI",0,0,0,0,0
	dc.b	"PEA",0,0,0,0,0
	dc.b	"RESET",0,0,0
	dc.b	"ROL",0,0,0,0,0
	dc.b	"ROR",0,0,0,0,0
	dc.b	"ROXL",0,0,0,0
	dc.b	"ROXR",0,0,0,0
	dc.b	"RTD",0,0,0,0,0
	dc.b	"RTE",0,0,0,0,0
	dc.b	"RTR",0,0,0,0,0
	dc.b	"RTS",0,0,0,0,0
	dc.b	"SBCD",0,0,0,0
	dc.b	"SCC",0,0,0,0,0
	dc.b	"SCS",0,0,0,0,0
	dc.b	"SEQ",0,0,0,0,0
	dc.b	"SGE",0,0,0,0,0
	dc.b	"SGT",0,0,0,0,0
	dc.b	"SHI",0,0,0,0,0
	dc.b	"SLE",0,0,0,0,0
	dc.b	"SLS",0,0,0,0,0
	dc.b	"SLT",0,0,0,0,0
	dc.b	"SMI",0,0,0,0,0
	dc.b	"SNE",0,0,0,0,0
	dc.b	"SPL",0,0,0,0,0
	dc.b	"SVC",0,0,0,0,0
	dc.b	"SVS",0,0,0,0,0
	dc.b	"SF",0,0,0,0,0,0
	dc.b	"ST",0,0,0,0,0,0
	dc.b	"STOP",0,0,0,0
	dc.b	"SUB",0,0,0,0,0
	dc.b	"SUBA",0,0,0,0
	dc.b	"SUBI",0,0,0,0
	dc.b	"SUBQ",0,0,0,0
	dc.b	"SUBX",0,0,0,0
	dc.b	"SWAP",0,0,0,0
	dc.b	"TAS",0,0,0,0,0
	dc.b	"TRAP",0,0,0,0
	dc.b	"TRAPV",0,0,0
	dc.b	"TST",0,0,0,0,0
	dc.b	"UNLK",0,0,0,0
	dc.b	"ALIGN",0,0,0
	dc.b	"BLK",0,0,0,0,0
	dc.b	"CODE",0,0,0,0
	dc.b	"CNOP",0,0,0,0
	dc.b	"DC",0,0,0,0,0,0
	dc.b	"DS",0,0,0,0,0,0
	dc.b	"ENDIF",0,0,0
	dc.b	"ENDM",0,0,0,0
	dc.b	"EQU",0,0,0,0,0
	dc.b	"ELSE",0,0,0,0
	dc.b	"EVEN",0,0,0,0
	dc.b	"END",0,0,0,0,0
	dc.b	"GLOBL",0,0,0
	dc.b	"IF",0,0,0,0,0,0
	dc.b	"INCBIN",0,0
	dc.b	"LIST",0,0,0,0
	dc.b	"LOAD",0,0,0,0
	dc.b	"MACRO",0,0,0
	dc.b	"NLIST",0,0,0
	dc.b	"ODD",0,0,0,0,0
	dc.b	"ORG",0,0,0,0,0
	dc.b	"PAGE",0,0,0,0
	dc.b	"PLEN",0,0,0,0
	dc.b	"PWID",0,0,0,0
	dc.b	"PINIT",0,0,0
	dc.b	"SECTION",0
	dc.b	"BSS",0,0,0,0,0
	dc.b	"BCC_C",0,0,0
	dc.b	"CODE",0,0,0,0
	dc.b	"CODE_C",0,0
	dc.b	">EXTERN",0
	dc.b	"D0",0,0,0,0,0,0
	dc.b	"D1",0,0,0,0,0,0
	dc.b	"D2",0,0,0,0,0,0
	dc.b	"D3",0,0,0,0,0,0
	dc.b	"D4",0,0,0,0,0,0
	dc.b	"D5",0,0,0,0,0,0
	dc.b	"D6",0,0,0,0,0,0
	dc.b	"D7",0,0,0,0,0,0
	dc.b	"A0",0,0,0,0,0,0
	dc.b	"A1",0,0,0,0,0,0
	dc.b	"A2",0,0,0,0,0,0
	dc.b	"A3",0,0,0,0,0,0
	dc.b	"A4",0,0,0,0,0,0
	dc.b	"A5",0,0,0,0,0,0
	dc.b	"A6",0,0,0,0,0,0
	dc.b	"A7",0,0,0,0,0,0
Label:		
