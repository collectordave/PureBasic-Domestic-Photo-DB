﻿EnableExplicit

DeclareModule AddPhoto
  
  Global PhotoFileName.s
  Global OkPressed.i = #False
  Declare.s Open()
  
EndDeclareModule

Module AddPhoto
  
  UseJPEGImageDecoder() 
  UseJPEGImageEncoder()
  Define Quit.i = #False 
 
  Global SelDate.i,Subject_ID.i
 
  Enumeration 300
    #WinAddPhoto
    #txtSelectPhoto
    #btnSelectPhoto
    #strPhotoFolder
    #txtSelectSubject
    #cmbSubject
    #txtDate
    #StrDate
    #btnSelectDate
    #btnOk
    #btnCancel
  EndEnumeration

  Procedure ShowFormTexts()
  
    SetWindowTitle(#WinAddPhoto,Locale::TranslatedString(97))
    SetGadgetText(#txtSelectPhoto,Locale::TranslatedString(98))
    SetGadgetText(#txtSelectSubject,Locale::TranslatedString(99))
    SetGadgetText(#txtDate,Locale::TranslatedString(100))
    SetGadgetText(#btnOk,Locale::TranslatedString(0))
    SetGadgetText(#btnCancel,Locale::TranslatedString(3))  
  
  EndProcedure

  Procedure LoadSubjects()
  
    Define DBID.i
    Define Criteria.s
    Define iLoop.i = 1
  
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "PhotoData.s3db","","")
  
    Criteria = "Select * FROM Subject ORDER BY PDB_Title ASC;"
    
    AddGadgetItem(#cmbSubject,0,"None")
    SetGadgetItemData(#cmbSubject, 0,0)
    
    If DatabaseQuery(DBID, Criteria)
    
      While NextDatabaseRow(DBID) ; Loop for each records
      
        AddGadgetItem(#cmbSubject,iLoop,GetDatabaseString(DBID, 1))
        SetGadgetItemData(#cmbSubject, iLoop,GetDatabaseLong(DBID, 0))
        iLoop = iLoop + 1
        
      Wend
  
      FinishDatabaseQuery(DBID)
    
    EndIf
  
  EndProcedure  
 
  Procedure.i AddPhotoToDB()
    
    Structure ImageData
      *address
      size.i
    EndStructure
    
    Define ImageToSave.i,RetVal.i
    Define AspectRatioWidth.f,AspectRatioHeight.f
    Define ImageFolder.s,PhotoSaveFileName.s,Criteria.s
    
    ;Check Photo Not In Database
    
    ;Resize Image To Thumbnail size
    ImageToSave = LoadImage(#PB_Any, PhotoFileName)
    AspectRatioWidth = 200/ImageWidth(ImageToSave)
    AspectRatioHeight = 200/ImageHeight(ImageToSave)   
    If AspectRatioWidth < AspectRatioHeight
      ResizeImage(ImageToSave,ImageWidth(ImageToSave) * AspectRatioWidth,ImageHeight(ImageToSave) * AspectRatioWidth)
    Else
      ResizeImage(ImageToSave,ImageWidth(ImageToSave) * AspectRatioHeight,ImageHeight(ImageToSave) * AspectRatioHeight)
    EndIf
    newImg = EncodeImage(ImageToSave,#PB_ImagePlugin_JPEG)
    NewImgSize = MemorySize(newImg)
    
    ;Folder For Image
    ImageFolder = App::BaseFolder + Str(Year(SelDate)) + " " + App::NumberToMonth(Month(SelDate)) + " - " + GetGadgetText(#cmbSubject)
    App::CheckCreatePath(ImageFolder)
    PhotoSaveFileName = ImageFolder + App::#Pathsep + GetFilePart(PhotoFileName)

    If App::Move = #True
      RenameFile(PhotoFileName, PhotoSaveFileName) ;Move The Photograph
    Else   
      CopyFile(PhotoFileName, PhotoSaveFileName) ;Copy The Photograph
    EndIf
   
    ;Add record To database
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "PhotoData.s3db","","")
    SetDatabaseBlob(DBID, 0, NewImg, NewImgSize)
    Criteria = "INSERT INTO Photos (Subject_ID,PDB_FileName,PDB_Year,PDB_Month,PDB_Thumb) VALUES (" + Str(Subject_ID) + ",'" + PhotoSaveFileName + "'," + Str(Year(SelDate)) + "," + Str(Month(SelDate)) + ",?);"
    DatabaseUpdate(DBID, Criteria)     
    
    Criteria = "SELECT MAX(Photo_ID) FROM Photos;"
    DatabaseQuery(App::PhotoDB, Criteria)
    FirstDatabaseRow(App::PhotoDB)
    RetVal = GetDatabaseLong(App::PhotoDB,0)
    FinishDatabaseQuery(App::PhotoDB)

    CloseDatabase(DBID)
    
    ProcedureReturn RetVal
    
  EndProcedure

  Procedure.s Open()
    
    Define RetString.s
    
    OpenWindow(#WinAddPhoto, 0, 0, 430, 170, "", #PB_Window_Tool | #PB_Window_WindowCentered)
    TextGadget(#txtSelectPhoto, 10, 40, 120, 20, "", #PB_Text_Right)
    ButtonGadget(#btnSelectPhoto, 400, 40, 20, 20, "...")
    StringGadget(#strPhotoFolder, 135, 40, 265, 20, "")
    TextGadget(#txtSelectSubject, 10, 70, 160, 20, "", #PB_Text_Right)
    ComboBoxGadget(#cmbSubject, 180, 70, 240, 20)
    TextGadget(#txtDate, 10, 100, 160, 20, "", #PB_Text_Right)
    StringGadget(#StrDate, 180, 100, 140, 20, "")
    ButtonGadget(#btnSelectDate, 320, 100, 20, 20, "...")
    ButtonGadget(#btnOk, 260, 140, 70, 20, "")
    ButtonGadget(#btnCancel, 350, 140, 70, 20, "")
    StickyWindow(#WinAddPhoto,#True)
    ShowFormTexts()
    LoadSubjects()
    
    Repeat
      Event = WaitWindowEvent()

      Select event

        Case #PB_Event_Gadget
          Select EventGadget()
            
            Case #btnOk
              
              RetString = " WHERE Photos.Photo_ID = " + Str(AddPhotoToDB())
              OkPressed = #True
              CloseWindow(#WinAddPhoto)           
              Quit = #True

            Case #btnCancel
              
              RetString = ""
              CloseWindow(#WinAddPhoto)           
              Quit = #True
            
            Case #btnSelectPhoto
            
              PhotoFileName = OpenFileRequester(Locale::TranslatedString(101), App::#DefaultFolder,"Image (*.jpg)|*.jpg", 0) 
              SetGadgetText(#strPhotoFolder,PhotoFileName)
            
            Case #cmbSubject
            
              Subject_ID = GetGadgetItemData(#cmbSubject,GetGadgetState(#cmbSubject))
              
            Case #btnSelectDate
            
              SelDate = SelectDate::Open()
              If SelDate > -1
                SetGadgetText(#StrDate,Str(Day(SelDate)) + " " + App::NumberToMonth(Month(SelDate)) + " " + Str(Year(Seldate)))
              EndIf
          
          EndSelect
          
      EndSelect
  
    Until Quit = #True
    
    ProcedureReturn RetString
    
  EndProcedure

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 154
; FirstLine = 110
; Folding = z-
; EnableXP