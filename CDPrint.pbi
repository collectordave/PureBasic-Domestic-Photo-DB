;{ ==Code Header Comment==============================
;         Name/title: CDPrint.pbi
;    Executable name: N/A
;            Version: 1.0.0
;    Original Author: Collectordave
;Heavily Modyfied By: infratec
;     Translation by: 
;        Create date: 05\Feb\2017
;  Previous releases: 
;  This Release Date: 05\Feb\2017 
;   Operating system: Windows  [X]GUI
;   Compiler version: PureBasic 5.6B2 (x64)
;          Copyright: (C)2017
;            License: GNUGPL
;          Libraries: 
;      English Forum: 
;       French Forum: 
;       German Forum: 
;   Tested platforms: Windows
;        Description: Include module for print and print Preview
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
CompilerEndIf


DeclareModule CDPrint
 
  EnableExplicit
 
  Enumeration
    #NoPreview
    #Preview
    #Portrait
    #Landscape
  EndEnumeration   
 
  Structure Information
    Height.i                ;mm
    Width.i                 ;mm
    TopPrinterMargin.i      ;mm
    LeftPrinterMargin.i     ;mm
    BottomPrinterMargin.i   ;mm
    RightPrinterMargin.i    ;mm
    HorizontalResolution.d  ;dpmm
    VerticalResolution.d    ;dpmm
  EndStructure
 
  Global Printer.Information
 
  ;Declare CDPrintEvents(Event)
  Declare Open(JobName.s,Mode.i = #Preview)
  Declare AddPage(Orientation.i)
  Declare Finished()
  Declare PrintLine(Startx.i,Starty.i,Endx.i,Endy.i,LineWidth.i,Color.i=$FF000000)
  Declare PrintBox(X1.i,Y1.i,X2.i,Y2.i,Width.i,Color.i=$FF000000)
  Declare PrintText(Startx,Starty,Font.s,Size.i,Text.s,Color.i=$FF000000)
  Declare PrintImage(Image.i,Topx.i,Topy.i,Width.i,Height.i,Transparency.i=255)
  Declare PrintImageFromFile(Image.s,Topx.i,Topy.i,Width.i,Height.i,Transparency.i=255)
  Declare PrintCanvas(Canvas.i,Topx.i,Topy.i,Width.i=0,Height.i=0,Transparency.i=255)
  Declare.f GettextWidthmm(text.s,FName.s,FSize.f)
  Declare.f GettextHeightmm(text.s,FName.s,FSize.f)
 
EndDeclareModule

Module CDPrint
 
  Enumeration
    #PrintType_Box
    #PrintType_Line
    #PrintType_Text
    #PrintType_Image
    #PrintType_Canvas
  EndEnumeration
 
  Structure PageContentStructure
    Type.i
    x1.i
    y1.i
    x2.i
    y2.i
    Width.i
    Font$
    FontSize.i
    Text$
    Color.i
    Flags.i
    Image.i
  EndStructure
 
  Structure PageStructure
    Orientation.i
    List PageData.PageContentStructure()
  EndStructure
 
  Structure ShowPreviewStructure
    Window.i
    btnPrint.i
    btnClose.i
    spnPageSelect.i
    imgPreview.i
    PreviewImage.i
    ClearImage.i
  EndStructure
 
  Structure SetPagesTPrintStructure
    Window.i
    cntRange.i
    optAll.i
    optRange.i
    optSelected.i
    strRange.i
    strSelected.i
    btnOk.i
    btnCancel.i
    RetVal.i
  EndStructure
 
  Global PrintJob.s
  Global PrintMode.i
  Global CurrentPage.i
  Global PageNo.i
  Global TotalPages.i
  Global PrinterOrientation.i
  Global Dim PageRange.i(0)
  Global GraphicScale.f
  ;Global TextScale.f
 
  Global SetPagesToPrint.SetPagesTPrintStructure
  Global ShowPreview.ShowPreviewStructure
 
  Global NewMap PageToPrint.PageStructure()
 
 
  Macro FileExists(filename)
    Bool(FileSize(fileName) > -1)
  EndMacro
 
 
  Procedure CleanUp()
   
    Debug "CleanUp"
   
    ForEach PageToPrint()
      ForEach PageToPrint()\PageData()
        If PageToPrint()\PageData()\Type = #PrintType_Image
          FreeImage(PageToPrint()\PageData()\Image)
        EndIf
      Next
    Next
    ClearMap(PageToPrint())
   
  EndProcedure
 
 
  Procedure PrintPage(PageID.i, Mode.i)
   
    Protected Font.i, Left.i, Top.i, TextSize.f, DrawingOk.i, Scale.f
   
    If FindMapElement(PageToPrint(), Str(PageID))     
     
      If Mode = #Preview
        DrawingOk = StartVectorDrawing(ImageVectorOutput(ShowPreview\PreviewImage))
        Scale = GraphicScale
      Else
        DrawingOk = StartVectorDrawing(PrinterVectorOutput(#PB_Unit_Millimeter))
        Scale = 1.0
      EndIf
     
      If DrawingOk
        ;Clear Page Image
        If Mode = #Preview
          DrawVectorImage(ImageID(ShowPreview\ClearImage))
        EndIf
       
        ;If Printer and Page orientation different rotate
        If PageToPrint()\Orientation <> PrinterOrientation
          RotateCoordinates(0 , 0 , -90 )
          If Mode = #Preview
            TranslateCoordinates(-ImageHeight(ShowPreview\PreviewImage) , 0 )
          Else
            TranslateCoordinates( -Printer\Height , 0 )
          EndIf
        EndIf
       
        ForEach PageToPrint()\PageData()
         
          Select PageToPrint()\PageData()\Type
            Case #PrintType_Line
              MovePathCursor(PageToPrint()\PageData()\x1 * Scale.f, PageToPrint()\PageData()\y1 * Scale.f)
              AddPathLine(PageToPrint()\PageData()\x2 * Scale.f, PageToPrint()\PageData()\y2 * Scale.f, #PB_Path_Default)
              VectorSourceColor(PageToPrint()\PageData()\Color)
              StrokePath(PageToPrint()\PageData()\Width * Scale.f, #PB_Path_RoundCorner)       
             
            Case #PrintType_Box
              AddPathBox(PageToPrint()\PageData()\x1 * Scale.f, PageToPrint()\PageData()\y1 * Scale.f, (PageToPrint()\PageData()\x2 - PageToPrint()\PageData()\x1) * Scale.f, (PageToPrint()\PageData()\y2 - PageToPrint()\PageData()\y1) * Scale.f)
              VectorSourceColor(PageToPrint()\PageData()\Color)
              StrokePath(PageToPrint()\PageData()\Width * Scale.f)
             
            Case #PrintType_Image
              If IsImage(PageToPrint()\PageData()\Image)
                MovePathCursor(PageToPrint()\PageData()\x1 * Scale.f, PageToPrint()\PageData()\y1 * Scale.f)
                DrawVectorImage(ImageID(PageToPrint()\PageData()\Image),Alpha(PageToPrint()\PageData()\Color),PageToPrint()\PageData()\x2 * Scale.f,PageToPrint()\PageData()\y2 * Scale.f)
              EndIf 
             
            Case #PrintType_Text
              Font = LoadFont(#PB_Any, PageToPrint()\PageData()\Font$, PageToPrint()\PageData()\FontSize)
              TextSize = PageToPrint()\PageData()\FontSize * 0.352777778 ;Convert Font Points To mm
              VectorFont(FontID(Font), TextSize)
              VectorSourceColor(PageToPrint()\PageData()\Color)
              MovePathCursor(PageToPrint()\PageData()\x1, PageToPrint()\PageData()\y1)
              DrawVectorText(PageToPrint()\PageData()\Text$)
              FreeFont(Font)
             
          EndSelect
         
        Next
       
        StopVectorDrawing()
      EndIf
     
      If Mode = #Preview
        ;Show Image Centred
        SetGadgetState(ShowPreview\imgPreview, ImageID(ShowPreview\PreviewImage)) 
        Left = (540 - GadgetWidth(ShowPreview\imgPreview)) / 2
        Top = ((500 - GadgetHeight(ShowPreview\imgPreview)) / 2 ) + 30
        ResizeGadget(ShowPreview\imgPreview, Left, Top, #PB_Ignore, #PB_Ignore)
      EndIf
     
    EndIf
   
  EndProcedure
 
 
  Procedure SetPagesToPrint_CloseWindow()
   
    Protected iLoop.i
   
    CloseWindow(SetPagesToPrint\Window)
    If EventData() = #True
      Debug "Printing"
      StartPrinting(PrintJob)
      For iLoop = 0 To ArraySize(PageRange()) - 1
        Debug PageRange(iLoop)
        PrintPage(PageRange(iLoop), #NoPreview)
        If iLoop < ArraySize(PageRange()) - 1
          NewPrinterPage()
        EndIf
      Next iLoop
      StopPrinting()
    EndIf
    CleanUp()
   
  EndProcedure
 
 
  Procedure SetPagesToPrint_btnOk()
   
    Protected StartPage.i, EndPage.i, iLoop.i, PageCount.i
   
    If GetGadgetState(SetPagesToPrint\optAll)
     
      ReDim PageRange(TotalPages)
      For iLoop = 0 To TotalPages -1
        PageRange(iLoop) = iLoop + 1
        Debug PageRange(iLoop)
      Next
     
    ElseIf GetGadgetState(SetPagesToPrint\optSelected)
     
      PageCount = CountString(GetGadgetText(SetPagesToPrint\strSelected), ",") + 1
      ReDim PageRange(PageCount)
      For iLoop = 1 To PageCount
        If Val(StringField(GetGadgetText(SetPagesToPrint\strSelected), iLoop, ",")) <= TotalPages
          PageRange(iLoop - 1) = Val(StringField(GetGadgetText(SetPagesToPrint\strSelected), iLoop, ","))
        Else
          PageRange(iLoop - 1) = 0
        EndIf
      Next
     
    ElseIf GetGadgetState(SetPagesToPrint\optRange)
     
      PageCount = 0
      StartPage = Val(StringField(GetGadgetText(SetPagesToPrint\strRange),1,"-"))
      EndPage = Val(StringField(GetGadgetText(SetPagesToPrint\strRange),2,"-"))
      If EndPage > TotalPages 
        EndPage = TotalPages
      EndIf
      ReDim PageRange(Endpage-Startpage + 1)
      For iLoop = 0 To ArraySize(PageRange())
        Pagerange(iLoop) = StartPage + PageCount
        PageCount = PageCount + 1
      Next iLoop
     
    EndIf
   
    PostEvent(#PB_Event_CloseWindow, SetPagesToPrint\Window, 0, 0, #True)
   
  EndProcedure
 
  Procedure SetPagesToPrint_btnCancel()
    PostEvent(#PB_Event_CloseWindow, SetPagesToPrint\Window, 0, 0, #False)
  EndProcedure
 
 
  Procedure SetPagesToPrint()
   
    SetPagesToPrint\Window = OpenWindow(#PB_Any, 0, 0, 250, 150, "What To Print", #PB_Window_TitleBar | #PB_Window_Tool|#PB_Window_WindowCentered)
    SetPagesToPrint\cntRange = ContainerGadget(#PB_Any, 10, 10, 230, 100)
    SetPagesToPrint\optAll = OptionGadget(#PB_Any, 10, 10, 70, 20, "All")
    SetPagesToPrint\optRange = OptionGadget(#PB_Any, 10, 40, 70, 20, "Range")
    SetPagesToPrint\optSelected = OptionGadget(#PB_Any, 10, 70, 70, 20, "Selected")
    SetPagesToPrint\strRange = StringGadget(#PB_Any, 100, 40, 130, 20, "")
    GadgetToolTip(SetPagesToPrint\strRange, "Enter a single range of pages to print. For example 5-12") 
    SetPagesToPrint\strSelected = StringGadget(#PB_Any, 100, 70, 130, 20, "")
    GadgetToolTip(SetPagesToPrint\strSelected, "Enter page numbers separated by commas. Example 2,6,9") 
    CloseGadgetList()
    SetPagesToPrint\btnOk = ButtonGadget(#PB_Any, 90, 120, 70, 25, "Ok")
    SetPagesToPrint\btnCancel = ButtonGadget(#PB_Any, 170, 120, 70, 25, "Cancel")
   
    ;Select all as default
    SetGadgetState(SetPagesToPrint\optAll, #True)
   
   
    BindEvent(#PB_Event_CloseWindow, @SetPagesToPrint_CloseWindow(), SetPagesToPrint\Window)   
    BindGadgetEvent(SetPagesToPrint\btnOk, @SetPagesToPrint_btnOk())
    BindGadgetEvent(SetPagesToPrint\btnCancel, @SetPagesToPrint_btnCancel())
   
  EndProcedure
 
 
  Procedure ShowPreview_CloseWindow()
    CloseWindow(ShowPreview\Window)
    If EventData() = #False
      CleanUp()
    EndIf
   
    If IsImage(ShowPreview\PreviewImage)
      FreeImage(ShowPreview\PreviewImage)
    EndIf
   
    If IsImage(ShowPreview\ClearImage)
      FreeImage(ShowPreview\ClearImage)
    EndIf
  EndProcedure
 
 
  Procedure ShowPreview_spnPageSelect()
    If GetGadgetState(ShowPreview\spnPageSelect) > PageNo
      CurrentPage = PageNo
    ElseIf GetGadgetState(ShowPreview\spnPageSelect) < 1
      CurrentPage = 1
    Else
      CurrentPage = GetGadgetState(ShowPreview\spnPageSelect)
    EndIf
    SetGadgetState(ShowPreview\spnPageSelect,CurrentPage)
    PrintPage(CurrentPage, #Preview)
  EndProcedure
 
 
  Procedure ShowPreview_btnPrint()
    SetPagesToPrint()
    PostEvent(#PB_Event_CloseWindow, ShowPreview\Window, 0, 0, #True)
  EndProcedure
 
 
  Procedure ShowPreview_btnClose()
    PostEvent(#PB_Event_CloseWindow, ShowPreview\Window, 0, 0, #False)
  EndProcedure
 
 
  Procedure ShowPreview()
   
    Protected TPageHeight.i, TPageWidth.i
   
   
    ;Scale Factors For Image
    TPageHeight = Printer\Height * 2.834645669 ;mm To Points
    TPageWidth = Printer\Width * 2.834645669
   
    If Printer\Height > Printer\Width.i
      GraphicScale.f = 500/Printer\Height
      ;TextScale.f = 500/TPageHeight.i
    Else
      GraphicScale.f = 500/Printer\Width
      ;TextScale.f = 500/TPagewidth.i
    EndIf
   
    ;Create the image for the page
    ShowPreview\PreviewImage = CreateImage(#PB_Any, Printer\Width * GraphicScale.f,Printer\Height * GraphicScale.f, 32,RGB(255,255,255))
    ShowPreview\ClearImage = CreateImage(#PB_Any, Printer\Width * GraphicScale.f,Printer\Height * GraphicScale.f, 32,RGB(255,255,255))
   
    ;Open The Preview Window
    ShowPreview\Window = OpenWindow(#PB_Any, #PB_Ignore,#PB_Ignore, 540, 535, "Print Preview - " + PrintJob)
    ShowPreview\spnPageSelect = SpinGadget(#PB_Any, 490, 0, 50, 25, 0, 1000,#PB_Spin_Numeric)
    SetGadgetState (ShowPreview\spnPageSelect, 1)
    ShowPreview\imgPreview = ImageGadget(#PB_Any, 5, 5, 50, 50,  0,#PB_Image_Raised)
    ShowPreview\btnPrint = ButtonGadget(#PB_Any, 0, 0, 70, 20, "Print")
    ShowPreview\btnClose = ButtonGadget(#PB_Any, 80, 0, 70, 20, "Close")   
   
    BindGadgetEvent(ShowPreview\spnPageSelect, @ShowPreview_spnPageSelect(), #PB_EventType_Change)
    BindGadgetEvent(ShowPreview\btnPrint, @ShowPreview_btnPrint())
    BindGadgetEvent(ShowPreview\btnClose, @ShowPreview_btnClose())
   
    BindEvent(#PB_Event_CloseWindow, @ShowPreview_CloseWindow(), ShowPreview\Window)
   
    ;Set Page Counter To Zero And Create first Page Image
    CurrentPage = 1   
    PrintPage(CurrentPage, #Preview)
   
  EndProcedure
 
  Procedure GetPrinterInfo()
   
    Protected printer_DC.i
   
    CompilerSelect #PB_Compiler_OS
       
      CompilerCase #PB_OS_MacOS
       
        ;The vectordrawing functions print correctly on the MAC so simply set all to zero
        Printer\Width = 0
        Printer\Height = 0
        Printer\TopPrinterMargin = 0
        Printer\LeftPrinterMargin = 0
        Printer\BottomPrinterMargin = 0
        Printer\RightPrinterMargin = 0
       
      CompilerCase   #PB_OS_Linux   
       
        ;Not Defined Yet
       
      CompilerCase   #PB_OS_Windows   
       
        Protected HDPmm.d, VDPmm.d
       
        printer_DC = StartDrawing(PrinterOutput())
        If printer_DC
          HDPmm = GetDeviceCaps_(printer_DC,#LOGPIXELSX) / 25.4
          VDPmm = GetDeviceCaps_(printer_DC,#LOGPIXELSY) / 25.4
          Printer\Width = GetDeviceCaps_(printer_DC,#PHYSICALWIDTH) / HDPmm
          Printer\Height = GetDeviceCaps_(printer_DC,#PHYSICALHEIGHT) / VDPmm
          Printer\TopPrinterMargin = GetDeviceCaps_(printer_DC,#PHYSICALOFFSETY) / VDPmm
          Printer\LeftPrinterMargin = GetDeviceCaps_(printer_DC,#PHYSICALOFFSETX) / HDPmm
          Printer\BottomPrinterMargin = 0
          Printer\RightPrinterMargin = 0
         
          StopDrawing()
        EndIf
       
    CompilerEndSelect
   
  EndProcedure
 
  Procedure.f GettextWidthmm(text.s,FName.s,FSize.f)
   
    Protected TextSize.f, TextWidth.f, Font.i
   
    Font = LoadFont(#PB_Any,FName, FSize)    ;Load Font In Points
    TextSize = FSize * 0.352777778           ;Convert Font Points To mm
    VectorFont(FontID(Font), TextSize )      ;Use Font In mm Size
    TextWidth = VectorTextWidth(text,#PB_VectorText_Visible) ;Width of text In mm
    FreeFont(Font)
   
    ProcedureReturn TextWidth
   
  EndProcedure
 
  Procedure.f GettextHeightmm(text.s,FName.s,FSize.f)
   
    Protected TextSize.f, TextHeight.f, Font.i
   
    Font = LoadFont(#PB_Any, FName, FSize)    ;Load Font In Points
    TextSize = FSize * 0.352777778            ;Convert Font Points To mm
    VectorFont(FontID(Font), TextSize)        ;Use Font In mm Size
    TextHeight = VectorTextHeight(text,#PB_VectorText_Visible) ;Height of text In mm
    FreeFont(Font)
   
    ProcedureReturn TextHeight
   
  EndProcedure
 
 
 
  Procedure.i Open(JobName.s, Mode.i = #Preview)
   
    Protected Result.i
   
    ;Select Printer And Paper Etc
    If PrintRequester()

      ;Get Page Width,Height And Margins
      GetPrinterInfo()
     
      PrintJob = JobName
      PrintMode = Mode
     
      If Printer\Height > Printer\Width
        PrinterOrientation = #Portrait
      Else
        PrinterOrientation = #Landscape
      EndIf
     
      ;Create Print Job Database
      PageNo = 0
      CurrentPage = 0
     
      ;CleanUp()
     
      Result = #True
     
    EndIf   
   
    ProcedureReturn Result
   
  EndProcedure
 
  Procedure AddPage(Orientation.i)
   
    PageNo = PageNo + 1
   
    Debug "AddPage: " + Str(PageNo)
   
    If AddMapElement(PageToPrint(), Str(PageNo))
      PageToPrint()\Orientation = Orientation
    EndIf
   
  EndProcedure
 
  Procedure PrintLine(X1.i,Y1.i,X2.i,Y2.i,Width.i,Color.i=$FF000000)
   
    If AddElement(PageToPrint()\PageData())
      PageToPrint()\PageData()\Type = #PrintType_Line
      PageToPrint()\PageData()\x1 = X1
      PageToPrint()\PageData()\y1 = Y1
      PageToPrint()\PageData()\x2 = X2
      PageToPrint()\PageData()\y2 = Y2
      PageToPrint()\PageData()\Width = Width
      PageToPrint()\PageData()\Color = Color
    EndIf
   
  EndProcedure
 
  Procedure PrintBox(X1.i,Y1.i,X2.i,Y2.i,Width.i,Color.i=$FF000000)
   
    If AddElement(PageToPrint()\PageData())
      PageToPrint()\PageData()\Type = #PrintType_Box
      PageToPrint()\PageData()\x1 = X1
      PageToPrint()\PageData()\y1 = Y1
      PageToPrint()\PageData()\x2 = X2
      PageToPrint()\PageData()\y2 = Y2
      PageToPrint()\PageData()\Width = Width
      PageToPrint()\PageData()\Color = Color
    EndIf
   
  EndProcedure
 
  Procedure PrintText(X1.i,Y1.i,Font.s,Size.i,Text.s,Color.i=$FF000000)
   
    If AddElement(PageToPrint()\PageData())
      PageToPrint()\PageData()\Type = #PrintType_Text
      PageToPrint()\PageData()\x1 = X1
      PageToPrint()\PageData()\y1 = Y1
      PageToPrint()\PageData()\Font$ = Font
      PageToPrint()\PageData()\FontSize = Size
      PageToPrint()\PageData()\Text$ = Text
      PageToPrint()\PageData()\Color = Color
    EndIf 
   
  EndProcedure
  
  Procedure PrintImage(Image.i,X1.i,Y1.i,X2.i,Y2,Transparency.i=255)
   
    If AddElement(PageToPrint()\PageData())
      PageToPrint()\PageData()\Type = #PrintType_Image
      PageToPrint()\PageData()\x1 = X1
      PageToPrint()\PageData()\y1 = Y1
      PageToPrint()\PageData()\x2 = X2
      PageToPrint()\PageData()\y2 = Y2
      PageToPrint()\PageData()\Image = Image
      PageToPrint()\PageData()\Color = RGBA(0, 0, 0, Transparency)
    EndIf
   
  EndProcedure
 
 
  Procedure PrintImageFromFile(Image.s,X1.i,Y1.i,X2.i,Y2,Transparency.i=255)
   
    Protected Img.i
   
    Img = LoadImage(#PB_Any, Image)
    If Img
      PrintImage(Img, X1,Y1,X2,Y2,Transparency)
    EndIf
   
  EndProcedure
  
  Procedure PrintCanvas(Canvas.i,X1.i,Y1.i,X2.i=0,Y2=0,Transparency.i=255)
   
    Protected Img.i
   
    If IsGadget(Canvas)
      If StartDrawing(CanvasOutput(Canvas))
        Img = GrabDrawingImage(#PB_Any, 0, 0, GadgetWidth(Canvas), GadgetHeight(Canvas))
        If X2 = 0
          X2 = GadgetWidth(Canvas)
        EndIf
        If Y2 = 0
          Y2 = GadgetHeight(Canvas)
        EndIf
        PrintImage(Img, X1,Y1,X2,Y2,Transparency)
        StopDrawing()
      EndIf
    EndIf
   
  EndProcedure 
 
  Procedure Finished()
   
    Protected iLoop.i
   
    TotalPages = PageNo
   
    If PrintMode = #NoPreview
     
      SetPagesToPrint()
     
    Else
      ShowPreview()
    EndIf   
   
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.60 Beta 1 (Windows - x64)
; CursorPosition = 9
; Folding = -----
; EnableXP