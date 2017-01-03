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
Enumeration MainForm
  ;Main Window
  #WinMain
  #WinToolBar
  #WinMainmnu
  #txtStatus
  #btnFirst
  #btnPrevious
  #btnNext 
  #btnLast
  ;Window Menu
  #mnuAddPhoto
  #mnuAddSubject
  #mnuEditSubject
  #mnuDeleteSubject
  #mnuAddContent
  #mnuEditContent  
  #mnuDeleteContent
  #mnuSearch
  #mnuPreferences
  #mnuExit
  #mnuHelp
  #mnuAbout
  ;Image Gadgets
  #frmImages
  #btnViewImage
  #btnSlideShow
  #ImageContainer
  #imgPhoto
  ;Detail Gadgets
  #frmDetail
  #txtSubject
  #strSubject
  #txtYear
  #strYear
  #txtMonth
  #strMonth
  ;Content
  #frmContent
  #lstContent
  #btnAdd
  #btnRemove
EndEnumeration

;Global Variables
Global IconBar.i
Global Dim FileNames.s(0)

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
  SetIconBarGadgetItemText(IconBar,Locale::TranslatedString(16),3,#IconBarText_ToolTip)
   SetIconBarGadgetItemText(IconBar,Locale::TranslatedString(58),4,#IconBarText_ToolTip) 
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
    ;DisableGadget(cntCatalogs,#False)
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
  
  SearchString = SelectClause + Fromclause + Criteria + " LIMIT 1 OFFSET " + Str(CurrentRow -1)

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
  SearchString = SelectClause + Fromclause + Criteria
  
  If DatabaseQuery(App::PhotoDB, SearchString)
    
    While NextDatabaseRow(App::PhotoDB)

      TotalRows = TotalRows + 1
      
    Wend
    
    FinishDatabaseQuery(App::PhotoDB)  
    
  EndIf
  
  ;Populate FileName Array for Image Viewer
  Dim FileNames(0)
  ReDim FileNames(TotalRows)
  SearchString = SelectClause + Fromclause + Criteria
  iLoop = 0
  If DatabaseQuery(App::PhotoDB, SearchString)
    
    While NextDatabaseRow(App::PhotoDB)
      
      FileNames(iLoop) = GetDatabaseString(App::PhotoDB, DatabaseColumnIndex(App::PhotoDB,"PDB_FileName"))
      iLoop = iLoop + 1
      
    Wend
    
    FinishDatabaseQuery(App::PhotoDB)
    
  EndIf
  
EndProcedure

CatchImage(0,?FirstPhoto)
CatchImage(1,?PreviousPhoto)
CatchImage(2,?NextPhoto)
CatchImage(3,?LastPhoto)
CatchImage(4,?ToolBarAdd)
CatchImage(5,?ToolBarSearch)
CatchImage(6,?ToolBarPreferences)
CatchImage(7,?ToolBarExit)
CatchImage(8,?ToolBarHelp)

;Main Window
OpenWindow(#WinMain, 0, 0, 515, 360, "", #PB_Window_SystemMenu| #PB_Window_ScreenCentered)
;Just needed as placeholders so iconbar resizes ready for menu
CreateMenu(#WinMainmnu, WindowID(#WinMain))
MenuTitle("test")

IconBar = IconBarGadget(0, 0, WindowWidth(#WinMain),20,#IconBar_Default,#WinMain) 
AddIconBarGadgetItem(IconBar, "", 4)
AddIconBarGadgetItem(IconBar, "", 5)
AddIconBarGadgetItem(IconBar, "", 6)
IconBarGadgetDivider(IconBar)
AddIconBarGadgetItem(IconBar, "", 7)
IconBarGadgetSpacer(IconBar)
AddIconBarGadgetItem(IconBar, "", 8)
ResizeIconBarGadget(IconBar, #PB_Ignore, #IconBar_Auto)  
SetIconBarGadgetColor(IconBar, 1, RGB(176,224,230))
TextGadget(#txtStatus, 65,305, 385, 32, "",#PB_Text_Center|#PB_Text_Border)
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
TextGadget(#txtMonth, 340, 95, 70, 20, "", #PB_Text_Right)
StringGadget(#strMonth, 420, 95, 80, 20, "")
 
;Content
FrameGadget(#frmContent, 220, 130, 290, 174,"")
ListViewGadget(#lstContent, 230, 150, 270, 114)
ButtonGadget(#btnAdd, 230, 272, 70, 25,"")
ButtonGadget(#btnRemove, 430, 272, 70, 25,"")

;Navigation Buttons
ButtonImageGadget(#btnFirst, 0, 305, 32, 32, ImageID(0))
ButtonImageGadget(#btnPrevious, 31, 305, 32, 32, ImageID(1))
ButtonImageGadget(#btnNext, 451, 305, 32, 32, ImageID(2))
ButtonImageGadget(#btnLast, 482, 305, 32, 32, ImageID(3))
 
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
          
          Criteria = SearchWin::Open()
          ClearGadgets()
          GetTotalRecords()
          CurrentRow = 1
          CheckRecords()
          DisplayRecord()

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
          
          Dim TempArray.s(0)
          TempArray(0) = FileNames(CurrentRow - 1)
          ImageViewer::Open(TempArray())
          
        Case   #btnSlideShow

          ImageViewer::Open(FileNames())
          
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
              
              Criteria = SearchWin::Open()
              ClearGadgets()
              GetTotalRecords()
              CurrentRow = 1
              CheckRecords()
              DisplayRecord()
              
            Case 2
 
              Preferences::Open()
              Locale::Initialise()
              ShowFormTexts()
              
            Case 3

              End
                
            Case 4
              
              ;Debug Locale::TranslatedString(58) Help
              
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
 EndDataSection
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 571
; FirstLine = 399
; Folding = A-
; EnableXP
; EnableUnicode