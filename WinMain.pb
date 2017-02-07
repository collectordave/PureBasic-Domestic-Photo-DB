;{ ==Code Header Comment==============================
;         Name/title: WinMain.pb
;    Executable name: N/A
;            Version: 1.0.0
;    Original Author: Collectordave
;
;     Translation by: 
;        Create date: 05\Feb\2017
;  Previous releases: 
;  This Release Date: 05\Feb\2017 
;   Operating system: Windows  [X]GUI
;   Compiler version: PureBasic 5.6B2 (x64)
;          Copyright: (C)2017
;            License: Credit Only
;          Libraries: 
;      English Forum: 
;       French Forum: 
;       German Forum: 
;   Tested platforms: Windows
;        Description: Main File For PhotoDB
; ====================================================
;.......10........20........30........40........50........60........70........80
;}
EnableExplicit

;Using Statements
UsePNGImageDecoder()
UseJPEGImageDecoder()
UseSQLiteDatabase()

;Include Files
IncludeFile "Locale.pbi"
IncludeFile "App.pbi"
IncludeFile "DCTool.pbi"
IncludeFile "ImageViewer.pbi"
IncludeFile "dlgPreferences.pbi"
IncludeFile "dlgSelectDate.pbi"
IncludeFile "dlgAddPhoto.pbi"
IncludeFile "dlgNewSubject.pbi"
IncludeFile "dlgEditSubject.pbi"
IncludeFile "dlgDeleteSubject.pbi"
IncludeFile "dlgNewContent.pbi"
IncludeFile "dlgEditContent.pbi"
IncludeFile "dlgDeleteContent.pbi"
IncludeFile "dlgSearch.pbi"
IncludeFile "dlgAddContent.pbi"
IncludeFile "CDPrint.pbi"

;Get Applcation variables
App::ReadPreferences("PhotoDB")

If Not App::FileExists(GetCurrentDirectory() + "PhotoDB")
  App::Writepreferences("PhotoDB") 
EndIf
APP::ReadPreferences("PhotoDB")

;Select Language For This Programme If Not set
If App::Language = ""
  Locale::AppLanguage = "English" ;Default
  Locale::Initialise()
  Locale::SelectLanguage()
  App::Language = Locale::AppLanguage
  App::Writepreferences("PhotoDB")  
Else
  Locale::AppLanguage = App::Language
EndIf
Locale::Initialise()

;Main Menu Enumeration
Enumeration 50  ;MainForm
  ;Main Window
  #WinMain
  #WinToolBar
  #WinMainmnu
  #txtStatus  
  #btnFirst  
  #btnPrevious
  #btnNext 
  #btnLast
  #mnuAddPhoto
  #mnuAddSubject
  #mnuEditSubject
  #mnuDeleteSubject
  #mnuAddContent
  #mnuEditContent  
  #mnuDeleteContent
  #mnuSearch
  #mnuPreferences
  #mnuPrintItem
  #mnuPrintThumbs
  #mnuExit
  #mnuHelp
  #mnuAbout
  #frmImages
  #btnViewImage
  #btnSlideShow
  #ImageContainer
  #imgPhoto
  #imgFirst
  #imgPrevious
  #imgNext
  #imgLast
  #imgSelect
  #imgAdd
  #imgSearch
  #imgPrefs
  #imgExit
  #imgHelp
  #frmDetail
  #txtSubject
  #strSubject
  #txtYear
  #strYear
  #txtMonth
  #strMonth
  #frmContent
  #lstContent
  #btnAdd
  #btnRemove
  #frmSelected
  #lstSelected
  #btnPreview
  #btnExport
  #btnClear 
EndEnumeration

;Global Variables
Global IconBar.i,PrintControl.i 
Global Dim FileNames.s(0)
Global Dim PrintThese.s(0)

;Fonts Etc
Global StatusFont.i

;Database Variables
Global SelectClause.s,FromClause.s,OrderClause.s,CurrentRow.i,TotalRows.i,Criteria.s,PhotoID.i

;local variables
Define Event.i,TempCriteria.s

;Setup Main Select Clause
SelectClause = "SELECT DISTINCT Photos.Photo_ID,Photos.PDB_FileName,Photos.PDB_Year,Photos.PDB_Month,Photos.PDB_Thumb,Subject.PDB_Title,PhotoContent.photo_ID"
FromClause = " FROM Photos LEFT JOIN Subject ON Photos.SubJect_ID = Subject.Subject_ID LEFT JOIN PhotoContent ON Photos.Photo_ID = PhotoContent.photo_ID"
Criteria = ""

CurrentRow = 1

;Font For Status Display
StatusFont = LoadFont(#PB_Any,"Comic Sans MS", 14)

Procedure ShowFormTexts()
  
  ;Window Title
  SetWindowTitle(#WinMain,Locale::TranslatedString(104))
  SetGadgetText(#txtStatus,"Photograph" + " 0 " + Locale::TranslatedString(125) + " 0 " + Locale::TranslatedString(126))
  SetIconBarGadgetItemText(IconBar,Locale::TranslatedString(127),0,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar,Locale::TranslatedString(29),1,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar,Locale::TranslatedString(52),2,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar,"Select For Printing",3,#IconBarText_ToolTip)   
  SetIconBarGadgetItemText(IconBar,Locale::TranslatedString(16),4,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar,Locale::TranslatedString(58),5,#IconBarText_ToolTip)  

  
  ;Menu
  If IsMenu(#WinMainmnu)
    FreeMenu(#WinMainmnu)
  EndIf
  CreateMenu(#WinMainmnu, WindowID(#WinMain))
  MenuTitle(Locale::TranslatedString(128))
  MenuItem(#mnuAddPhoto, Locale::TranslatedString(127))
  MenuItem(#mnuSearch, Locale::TranslatedString(29))
  MenuBar()
  MenuItem(#mnuPreferences, Locale::TranslatedString(52))
  MenuBar()
  OpenSubMenu("Print")
    MenuItem(#mnuPrintItem, "This Photo")
    MenuItem(#mnuPrintThumbs, "Thumbnails")
  CloseSubMenu()
  MenuBar()
  MenuItem(#mnuExit, Locale::TranslatedString(16))
  MenuTitle(Locale::TranslatedString(121))
  MenuItem(#mnuAddSubject, Locale::TranslatedString(127))
  MenuItem(#mnuEditSubject, Locale::TranslatedString(17))   
  MenuItem(#mnuDeleteSubject, Locale::TranslatedString(21))   
  MenuTitle(Locale::TranslatedString(122))
  MenuItem(#mnuAddContent, Locale::TranslatedString(127))
  MenuItem(#mnuEditContent, Locale::TranslatedString(17))   
  MenuItem(#mnuDeleteContent, Locale::TranslatedString(21)) 
  MenuTitle(Locale::TranslatedString(58))
  MenuItem(#mnuHelp, Locale::TranslatedString(129))
  MenuItem(#mnuAbout, Locale::TranslatedString(62))
  
  ResizeIconBarGadget(IconBar, #PB_Ignore, #IconBar_Auto)  
  
  ;Images
  SetGadgetText(#frmImages,Locale::TranslatedString(130))
  SetGadgetText(#btnViewImage,Locale::TranslatedString(55))
  SetGadgetText(#btnSlideShow,Locale::TranslatedString(131))
  
  ;Photograph Detail
  SetGadgetText(#frmDetail,Locale::TranslatedString(132))
  GadgetToolTip(#frmDetail,Locale::TranslatedString(133))
  SetGadgetText(#txtSubject,Locale::TranslatedString(121))
  SetGadgetText(#txtYear,Locale::TranslatedString(123))
  SetGadgetText(#txtMonth,Locale::TranslatedString(124))
  
  ;Content
  SetGadgetText(#frmContent,Locale::TranslatedString(59))
  SetGadgetText(#btnAdd,Locale::TranslatedString(127))
  SetGadgetText(#btnRemove,Locale::TranslatedString(134))

EndProcedure

Procedure SelectForPrint()
  
  Define SearchString.s,iLoop.i
  Define j.i
  
  iLoop = ArraySize(PrintThese())
  
  SearchString = "Select * FROM Photos WHERE Photo_ID = " + Str(PhotoID)
  DatabaseQuery(App::PhotoDB, SearchString)
  FirstDatabaseRow(App::PhotoDB)
  PrintThese(iLoop) = GetDatabaseString(App::PhotoDB,DatabaseColumnIndex(App::PhotoDB,"PDB_FileName"))
  
  ReDim PrintThese(iLoop + 1)
  
  FinishDatabaseQuery(App::PhotoDB)
  
  ClearGadgetItems(#lstSelected)
  For j = 0 To iLoop
    AddGadgetItem(#lstSelected,-1,GetFilePart(PrintThese(j)))
  Next
  
EndProcedure

Procedure ClearGadgets()
  
  SetGadgetText(#strYear,"")
  SetGadgetText(#strMonth,"") 
  SetGadgetText(#strSubject,"")
  SetGadgetState(#imgPhoto,0)
  ClearGadgetItems(#lstContent)
  
EndProcedure

Procedure CheckRecords()
  
  ;Sort out the navigation buttons
  If TotalRows < 2
    
    ;Only one record so it is the first and the last
    DisableGadget(#btnLast, #True)     ;No move last as allready there
    DisableGadget(#btnNext, #True)     ;No next record as this is the last record
    DisableGadget(#btnFirst, #True)    ;No first record as this is the first record
    DisableGadget(#btnPrevious, #True) ;No previous record as this is the first record
    
  ElseIf CurrentRow = 1
    ;On the first row with more than one selected
    DisableGadget(#btnLast, 0)     ;Can move to last record
    DisableGadget(#btnNext, 0)     ;Can move to next record
    DisableGadget(#btnFirst, #True)    ;No first record as this is the first record
    DisableGadget(#btnPrevious, #True) ;No previous record as this is the first record
    
  ElseIf  CurrentRow = TotalRows
    
    ;If on the last record
    DisableGadget(#btnLast, #True)     ;No move last as allready there
    DisableGadget(#btnNext, #True)     ;No next record as this is the last record
    DisableGadget(#btnFirst, 0)    ;Can still move to first record
    DisableGadget(#btnPrevious, 0) ;Can still move to previous record
    
  Else
    
    ;Somewhere in the middle of the selected records
    DisableGadget(#btnLast, 0)     ;Can move to last record
    DisableGadget(#btnNext, 0)     ;Can move to next record
    DisableGadget(#btnFirst, 0)    ;Can move to first record
    DisableGadget(#btnPrevious, 0) ;Can move to previous record
    
  EndIf

  ;Show the user what is going on
  If TotalRows > 0
    SetGadgetText(#txtStatus,"Photograph " + Str(CurrentRow) + " " + Locale::TranslatedString(125) + " " + Str(TotalRows) + " Selected")
  Else
    SetGadgetText(#txtStatus,"Photograph" + " 0 " + Locale::TranslatedString(125) + " 0 " + Locale::TranslatedString(126)) 
  EndIf

EndProcedure

Procedure DisplayContent()
  
  Define SearchString.s
  Define iLoop.i = 0
  
  ClearGadgetItems(#lstContent)
  
  SearchString = "Select PhotoContent.Content_ID,Content.PDB_Title from PhotoContent LEFT Join Content on PhotoContent.Content_ID = Content.Content_ID WHERE PhotoContent.Photo_ID = " + Str(PhotoID)

  DatabaseQuery(App::PhotoDB, SearchString)
  While NextDatabaseRow(App::PhotoDB) ; Loop for each records
    AddGadgetItem(#lstContent,iLoop,GetDatabaseString(App::PhotoDB, 1))
    SetGadgetItemData(#lstContent, iLoop,GetDatabaseLong(App::PhotoDB, 0))    
    iLoop = iLoop + 1
  Wend

  FinishDatabaseQuery(App::PhotoDB)
  
EndProcedure

Procedure RemoveContent()
  
  Define DeleteString.s
  Define ContentID.i
  
  ContentID = GetGadgetItemData(#lstContent,GetGadgetState(#lstContent))
  
  If ContentID > -1
    
    DeleteString = "DELETE FROM PhotoContent WHERE Photo_ID = " + Str(PhotoID) + " AND Content_ID = " + Str(ContentID)
    DatabaseUpdate(App::PhotoDB, DeleteString) 
    
  EndIf
  
EndProcedure

Procedure GetImageFromDB()
  
  Define PictureSize.i,Picture.i,x.i,y.i
  
  PictureSize = DatabaseColumnSize(App::PhotoDB, DatabaseColumnIndex(App::PhotoDB,"PDB_Thumb"))

  Picture = AllocateMemory(PictureSize)
  GetDatabaseBlob(App::PhotoDB, DatabaseColumnIndex(App::PhotoDB,"PDB_Thumb"), Picture, PictureSize)
  CatchImage(54, Picture, PictureSize)
  FreeMemory(Picture)
  x = (200 - ImageWidth(54))/2
  y = (200 - ImageHeight(54))/2
  ResizeGadget(#imgPhoto,x,y,ImageWidth(54),ImageHeight(54))
  SetGadgetState(#imgPhoto,ImageID(54))
    
EndProcedure

Procedure DisplayRecord()
  
  Define SearchString.s,SMonth.s
  Define DBYear.i,DBMonth.i
  
  SearchString = SelectClause + Fromclause + Criteria + " ORDER BY PDB_Year ASC " + " LIMIT 1 OFFSET " + Str(CurrentRow -1)

  DatabaseQuery(App::PhotoDB, SearchString)

  If FirstDatabaseRow(App::PhotoDB)

    PhotoID = GetDatabaseLong(App::PhotoDB,DatabaseColumnIndex(App::PhotoDB,"Photo_ID"))
    DBYear =  GetDatabaseLong(App::PhotoDB, DatabaseColumnIndex(App::PhotoDB, "PDB_Year"))
    SetGadgetText(#strYear,Str(DBYear))
    DBMonth =  GetDatabaseLong(App::PhotoDB, DatabaseColumnIndex(App::PhotoDB, "PDB_Month")) 
    SMonth = App::NumberToMonth(DBMonth)
    SetGadgetText(#strMonth,SMonth) 
    SetGadgetText(#strSubject,GetDatabaseString(App::PhotoDB, DatabaseColumnIndex(App::PhotoDB, "PDB_Title")))
    GetImageFromDB()
    DisplayContent()
    FinishDatabaseQuery(App::PhotoDB)
    
  EndIf 
  
EndProcedure

Procedure GetTotalRecords()
  
  Define iLoop.i
  Define GetTotal.s,SearchString.s
  
  ;Find out how many records will be returned
  TotalRows = 0
  SearchString = SelectClause + Fromclause + Criteria + " ORDER BY PDB_Year ASC "
  
  If DatabaseQuery(App::PhotoDB, SearchString)
    
    While NextDatabaseRow(App::PhotoDB)

      TotalRows = TotalRows + 1
      
    Wend
    
    FinishDatabaseQuery(App::PhotoDB)  
    
  Else
    Debug DatabaseError()
  EndIf
  
  ;Populate FileName Array for Image Viewer
  Dim FileNames(0)
  ReDim FileNames(TotalRows)
  ;SearchString = SelectClause + Fromclause + Criteria
  iLoop = 0
  If DatabaseQuery(App::PhotoDB, SearchString)
    
    While NextDatabaseRow(App::PhotoDB)
      
      FileNames(iLoop) = GetDatabaseString(App::PhotoDB, DatabaseColumnIndex(App::PhotoDB,"PDB_FileName"))
      iLoop = iLoop + 1
      
    Wend
    
    FinishDatabaseQuery(App::PhotoDB)
    
  EndIf
  
EndProcedure

Procedure.d CalculateAspectRatio(OriginalWidth.d,OriginalHeight.d,MaximinWidth.d,MaximumHeight.d)
  
  Define Ratio1.d,Ratio2.d,Aspect.d
  
  Ratio1 = MaximinWidth/OriginalWidth
  Ratio2 = MaximumHeight/OriginalHeight
  
  If Ratio1 < Ratio2
    Aspect = Ratio1
  Else
    Aspect = Ratio2
  EndIf

  ProcedureReturn Aspect

EndProcedure

Procedure PrintPhoto()
  
  ;Define PageHeight.i,PageWidth.i
  
  Define Maxheight.i,MaxWidth.i,MaxPheight.i,MaxPWidth.i,PictureHeight.i,PictureWidth.i    
  Define Startx.i,Starty.i,PageHeight.i,PageWidth.i,MinimumX.i
  Define PictureSize.i,Picture.i,adjustedheight.i,adjustedwidth.i
  Define SearchString.s,iLoop.i,Filename.s
  ;Define PrintOrientation.i
  ;Define ImageOrientation.i
  Define Aspect.d
  
  ;Get Photograph FileName
  SearchString = "Select * FROM Photos WHERE Photo_ID = " + Str(PhotoID)
  DatabaseQuery(App::PhotoDB, SearchString)
    FirstDatabaseRow(App::PhotoDB)
    Filename = GetDatabaseString(App::PhotoDB,DatabaseColumnIndex(App::PhotoDB,"PDB_FileName"))
  FinishDatabaseQuery(App::PhotoDB)
  
  ;Check Photograph still exists on computer
  If Not App::FileExists(Filename)
    
    MessageRequester(Locale::TranslatedString(104),"Photograph Not Found!",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
    ProcedureReturn #False
    
  EndIf
  
  ;Open The Print Controller
  If  CDPrint::Open("PhotoDB",CDPrint::#Preview) ;Can Be CDPrint::#NoPreview as well
      
    ;Get Printable Page Dimensions And Margins
    PageHeight = CDPrint::Printer\Height - 20 ; PageSetup::TopMargin - PageSetup::BottomMargin
    PageWidth = CDPrint::Printer\Width - 20 ; Pagesetup::LeftMargin - Pagesetup::RightMargin

    Startx = 10 ;Pagesetup::LeftMargin
    Starty = 10 ;PageSetup::TopMargin
  
    ;Load the photograph
    Picture = LoadImage(#PB_Any,Filename)
  
    If CDPrint::Printer\Height > CDPrint::Printer\Width
      MaxHeight = PageHeight
      MaxWidth = PageWidth 
    Else
      MaxHeight = PageWidth
      MaxWidth = PageHeight   
    EndIf
  
    If ImageHeight(Picture) > ImageWidth(Picture)
      MaxPHeight = ImageHeight(Picture)
      MaxPWidth = ImageWidth(Picture)   
      CDPrint::AddPage(CDPrint::#Portrait)   
    Else
      MaxPHeight = ImageWidth(Picture)
      MaxPWidth = ImageHeight(Picture)   
      CDPrint::AddPage(CDPrint::#Landscape) 
    EndIf 
  
    ;Now Calculate The Aspect Ratio
    Aspect = CalculateAspectRatio(MaxPWidth,MaxPHeight,MaxWidth,MaxHeight)
  
    adjustedwidth = ImageWidth(Picture) * Aspect
    adjustedheight = ImageHeight(Picture) * Aspect

    ;Print the image
    CDPrint::PrintImageFromFile(Filename,Startx,Starty,adjustedwidth,adjustedheight)
  
    ;Finish The Print Job
    CDPrint::Finished()
    
  EndIf
  
EndProcedure

Procedure PrintThumbNails()
  
  Define Startx.i,Starty.i,PageHeight.i,PageWidth.i,MinimumX.i
  Define Picture.i,iLoop.i,Orientation.i
  Define PictureSize.i,Picture.i,adjustedheight.i,adjustedwidth.i
    
  Startx = 10 ;Pagesetup::LeftMargin
  Starty = 10 ;PageSetup::TopMargin 
  
  ;Open The Print Controller
  If CDPrint::Open("PhotoDB",CDPrint::#Preview) ;Can Be CDPrint::#NoPreview as well
    PageHeight = CDPrint::Printer\Height - 20 ; PageSetup::TopMargin - PageSetup::BottomMargin
    PageWidth = CDPrint::Printer\Width - 20 ; Pagesetup::LeftMargin - Pagesetup::RightMargin   
  
    If Pageheight > PageWidth
      Orientation = CDPrint::#Portrait
    Else
      Orientation = CDPrint::#Landscape
    EndIf
  
    ;Add First Page
    CDPrint::AddPage(Orientation)  

    For iLoop = 0 To ArraySize(PrintThese()) - 1

      If App::FileExists(PrintThese(iLoop))

        Picture = LoadImage(#PB_Any,PrintThese(iLoop))
    
        If Picture > 0
          adjustedheight = (App::ThumbSize * ImageHeight(Picture)) /ImageWidth(Picture)
          adjustedwidth = App::ThumbSize

          If adjustedheight > App::ThumbSize
            adjustedwidth = (App::ThumbSize * ImageWidth(Picture)) / ImageHeight(Picture)
            adjustedheight = App::ThumbSize
          EndIf
          CDPrint::PrintImageFromFile(PrintThese(iLoop),Startx,Starty,adjustedwidth,adjustedheight) 
        
          If (Startx + (App::ThumbSize * 2) + 5) < PageWidth
            Startx = Startx + App::ThumbSize + 5
          Else
            Startx = 10
            If (Starty + (App::ThumbSize * 2) + 5) < PageHeight      
              Starty = starty + App::ThumbSize + 5
            Else
              CDPrint::AddPage(Orientation)
              Startx = 10
              Starty = 10
            EndIf
         
          EndIf

        EndIf
    
      Else
    
        MessageRequester(Locale::TranslatedString(104),"Photograph Not Found!",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
    
      EndIf
    
    Next

    ;Finish The Print Job
    CDPrint::Finished() 

  EndIf
  
EndProcedure

Procedure ExportImages()
  
  Define InitialPath.s,Path.s
  
  InitialPath = "C:\"   ; set initial path to display (could also be blank)
  Path = PathRequester("Please choose your path", InitialPath)
  If Path
    MessageRequester("Information", "You have selected the following path:"+Chr(10)+Path, 0)
  Else
    MessageRequester("Information", "The requester was canceled.", 0) 
  EndIf


  
EndProcedure

CatchImage(#imgFirst,?FirstPhoto)
CatchImage(#imgPrevious,?PreviousPhoto)
CatchImage(#imgNext,?NextPhoto)
CatchImage(#imgLast,?LastPhoto)
CatchImage(#imgAdd,?ToolBarAdd)
CatchImage(#imgSearch,?ToolBarSearch)
CatchImage(#imgPrefs,?ToolBarPreferences)
CatchImage(#imgExit,?ToolBarExit)
CatchImage(#imgHelp,?ToolBarHelp)
CatchImage(#imgSelect,?ToolBarSelect)

;Main Window
OpenWindow(#WinMain, 0, 0, 710, 336, "", #PB_Window_SystemMenu| #PB_Window_ScreenCentered)

IconBar = IconBarGadget(0, 0, WindowWidth(#WinMain),20,#IconBar_Default,#WinMain) 
AddIconBarGadgetItem(IconBar, "", #imgAdd)
AddIconBarGadgetItem(IconBar, "", #imgSearch)
AddIconBarGadgetItem(IconBar, "", #imgPrefs)
IconBarGadgetDivider(IconBar)
AddIconBarGadgetItem(IconBar, "", #imgSelect)
IconBarGadgetDivider(IconBar)
AddIconBarGadgetItem(IconBar, "", #imgExit)
IconBarGadgetSpacer(IconBar)
AddIconBarGadgetItem(IconBar, "", #imgHelp)
ResizeIconBarGadget(IconBar, #PB_Ignore, #IconBar_Auto)  
SetIconBarGadgetColor(IconBar, 1, RGB(176,224,230))
TextGadget(#txtStatus, 65,305, 580, 32, "",#PB_Text_Center|#PB_Text_Border)
SetGadgetFont(#txtStatus, FontID(StatusFont))

;Move window to centre screen at the top
ResizeWindow(#WinMain,#PB_Ignore,5,#PB_Ignore,#PB_Ignore)
  
;Images
FrameGadget(#frmImages, 5, 42, 210, 262, "")
ButtonGadget(#btnViewImage, 10, 272, 70, 25, "")
ButtonGadget(#btnSlideShow, 140, 272, 70, 25, "")
ContainerGadget(#ImageContainer, 10, 55, 200, 200)
SetGadgetColor(#ImageContainer, #PB_Gadget_BackColor,RGB(0,0,0))
ImageGadget(#imgPhoto, 0, 0, 200, 200, 0)
CloseGadgetList()
  
;Photograph Detail
FrameGadget(#frmDetail, 220, 42, 290, 80, "")
GadgetToolTip(#frmDetail, "")
TextGadget(#txtSubject, 225, 65, 50, 20, "", #PB_Text_Right)
StringGadget(#strSubject, 280, 65, 220, 20, "")
TextGadget(#txtYear, 225, 95, 50, 20, "", #PB_Text_Right)
StringGadget(#strYear, 280, 95, 50, 20, "")
TextGadget(#txtMonth, 300, 95, 70, 20, "", #PB_Text_Right)
StringGadget(#strMonth, 380, 95, 80, 20, "")
 
;Content
FrameGadget(#frmContent, 220, 130, 290, 174,"")
ListViewGadget(#lstContent, 230, 150, 270, 114)
ButtonGadget(#btnAdd, 230, 272, 70, 25,"")
ButtonGadget(#btnRemove, 430, 272, 70, 25,"")

;Selected Files
FrameGadget(#frmSelected, 520, 42, 180, 262, " Selected ")
ListViewGadget(#lstSelected, 525, 60, 170, 200)
ButtonGadget(#btnPreview, 525, 272, 50, 25,"Preview")
ButtonGadget(#btnExport, 585, 272, 50, 25,"Export")
ButtonGadget(#btnClear, 645, 272, 50, 25,"Clear")

;Navigation Buttons
ButtonImageGadget(#btnFirst, 0, 305, 32, 32, ImageID(#imgFirst))
ButtonImageGadget(#btnPrevious, 31, 305, 32, 32, ImageID(#imgPrevious))
ButtonImageGadget(#btnNext, 646, 305, 32, 32, ImageID(#imgNext))
ButtonImageGadget(#btnLast, 678, 305, 32, 32, ImageID(#imgLast))

ShowFormTexts()

;Open The Photo Database
App::PhotoDB = OpenDatabase(#PB_Any,"PhotoData.s3db","","")
ClearGadgets()

Repeat
  
  Event = WaitWindowEvent() 
  
      Select Event
      
        Case   #PB_Event_CloseWindow
      
          End
      
        Case #PB_Event_Menu
      
          Select EventMenu() 
          
            Case #mnuAddPhoto
           
              TempCriteria.s = AddPhoto::Open()
              If AddPhoto::OkPressed = #True
                Criteria = TempCriteria
                ClearGadgets()
                GetTotalRecords()
                CurrentRow = 1
                CheckRecords()
                DisplayRecord()   
              EndIf
     
            Case #mnuPreferences
          
              Preferences::Open()
              Locale::Initialise()
              ShowFormTexts()
          
            Case   #mnuPrintItem
              
              If TotalRows > 0

                PrintPhoto()
                
              EndIf
              
            Case  #mnuPrintThumbs      
              
              If ArraySize(printthese()) > 0
                PrintThumbNails()
              Else
                MessageRequester(Locale::TranslatedString(104),"No Photograghs Selected",#PB_MessageRequester_Ok|#PB_MessageRequester_Info)
              EndIf              
           
            Case #mnuExit

              End
          
            Case #mnuAddSubject
          
              NewSubject::Open()
          
            Case #mnuEditSubject
          
              EditSubject::Open()
          
            Case #mnuDeleteSubject
          
              DeleteSubject::Open()
           
            Case #mnuAddContent
          
              NewContent::Open()
          
            Case #mnuEditContent
          
              EditContent::Open()
          
            Case #mnuDeleteContent
          
              DeleteContent::Open()
              DisplayContent()
          
            Case #mnuSearch
          
              TempCriteria = SearchWin::Open()

              If Len(TempCriteria) > 0
                Criteria = TempCriteria
                ClearGadgets()
                GetTotalRecords()
                CurrentRow = 1
                CheckRecords()
                DisplayRecord()
              EndIf
            
          EndSelect
        
        Case #PB_Event_Gadget
        
          Select EventGadget()
            
            Case #btnFirst
          
              CurrentRow = 1
              CheckRecords()
              DisplayRecord()
            
            Case #btnPrevious
          
              If CurrentRow > 1
                CurrentRow = CurrentRow - 1
                CheckRecords()
                DisplayRecord()
              EndIf          
          
            Case #btnNext

              If CurrentRow < TotalRows
                CurrentRow = CurrentRow + 1
                CheckRecords()
                DisplayRecord()
              EndIf
          
            Case #btnLast
                    
              CurrentRow = TotalRows
              CheckRecords()
              DisplayRecord()
          
            Case #btnViewImage
              
              If TotalRows > 0
                Dim TempArray.s(0)
                TempArray(0) = FileNames(CurrentRow - 1)
                ImageViewer::Open(TempArray())
              EndIf
              
            Case   #btnSlideShow
              
              If TotalRows > 0
                ImageViewer::Open(FileNames())
              EndIf
              
            Case #btnAdd

              AddContent::Open(PhotoID)
              DisplayContent()
          
            Case #btnRemove

              RemoveContent()          
              ClearGadgets()
              GetTotalRecords()
              If CurrentRow > TotalRows
                CurrentRow = TotalRows
              EndIf
              CheckRecords()
              DisplayRecord()
              
            Case #btnPreview 
              
              If ArraySize(printthese()) > 0
                PrintThumbNails()
              Else
                MessageRequester(Locale::TranslatedString(104),"No Photograghs Selected",#PB_MessageRequester_Ok|#PB_MessageRequester_Info)
              EndIf
              
            Case #btnExport
              
              If ArraySize(printthese()) > 0
                ExportImages()
              Else
                MessageRequester(Locale::TranslatedString(104),"No Photograghs Selected",#PB_MessageRequester_Ok|#PB_MessageRequester_Info)
              EndIf
                            
            Case #btnClear
              
              ClearGadgetItems(#lstSelected)
              ReDim PrintThese(0)
              
            Case IconBar ;Toolbar event
             
              Select EventData() ;For each button on toolbar
              
                Case 0

                  TempCriteria.s = AddPhoto::Open()
                  If AddPhoto::OkPressed = #True
                    Criteria = TempCriteria
                    ClearGadgets()
                    GetTotalRecords()
                    CurrentRow = 1
                    CheckRecords()
                    DisplayRecord()   
                  EndIf
              
                Case 1
              
                  TempCriteria = SearchWin::Open()

                  If Len(TempCriteria) > 0
                    Criteria = TempCriteria
                    ClearGadgets()
                    GetTotalRecords()
                    CurrentRow = 1
                    CheckRecords()
                    DisplayRecord()
                  EndIf
              
                Case 2
 
                  Preferences::Open()
                  Locale::Initialise()
                  ShowFormTexts()
              
                Case 3
                  
                  If TotalRows > 0
                    SelectForPrint()
                  EndIf
                
                 Case 4

                  End
                
                Case 5
              
                  Debug Locale::TranslatedString(58) ;Help
              
              EndSelect           
            
          EndSelect  
          
      EndSelect
      
    
ForEver  
  
DataSection
  FirstPhoto: 
    IncludeBinary "Resultset_first.png"
  PreviousPhoto: 
    IncludeBinary "Resultset_previous.png"
  NextPhoto: 
    IncludeBinary "Resultset_next.png"
  LastPhoto: 
    IncludeBinary "Resultset_last.png"
  ToolBarAdd:
    IncludeBinary "Add.png" 
  ToolBarSearch:
    IncludeBinary "Search.png"
  ToolBarPreferences:
    IncludeBinary "Preferences.png" 
  ToolBarExit:
    IncludeBinary "Exit.png"  
  ToolBarOk:
    IncludeBinary "Ok.png" 
  ToolBarCancel:
    IncludeBinary "Cancel.png"  
  ToolBarHelp:
    IncludeBinary "Help.png"    
  ToolBarSelect:
    IncludeBinary "SelectImage.png"      
    
  EndDataSection
; IDE Options = PureBasic 5.60 Beta 1 (Windows - x64)
; CursorPosition = 19
; Folding = Bw0
; EnableXP
; EnableUnicode