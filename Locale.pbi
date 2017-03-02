;{ ==Code Header Comment==============================
;         Name/title: Locale.pbi
;    Executable name: N/A
;            Version: 1.0.0
;    Original Author: Collectordave
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
;        Description: Include module to control multilanguages
; ====================================================
;.......10........20........30........40........50........60........70........80
;}
UsePNGImageDecoder()
UseSQLiteDatabase()

DeclareModule Locale

  
  ;Default language variable
  Global AppLanguage.s
  
  ;All The Phrases In Array
  Global Dim TranslatedString.s(0)
  
  Declare Initialise()
  Declare SelectLanguage()
  Declare FetchAvailableLanguages()
  
  ;Available Languages
  Global Dim Available.s(0)

;Error Variables
Global ER_0001.s
  
EndDeclareModule

Module Locale
  
  Global ProjectTitle.s
    
  Procedure FetchAvailableLanguages()
    
    Define iLoop.i = 0
    Define Criteria.s
    
    Criteria = "SELECT * From Language ORDER BY LT_Title;"
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "Resources\" + ProjectTitle +".Lng","","")  
    DatabaseQuery(DBID,Criteria)
    FirstDatabaseRow(DBID)
    Available(iLoop) = GetDatabaseString(DBID, DatabaseColumnIndex(DBID,"LT_Title"))
    iLoop = iLoop + 1
    ReDim  Available(iLoop)
    While NextDatabaseRow(DBID)
      Available(iLoop) = GetDatabaseString(DBID,DatabaseColumnIndex(DBID,"LT_Title"))
      iLoop = iLoop + 1 
      ReDim  Available(iLoop)     
    Wend
    FinishDatabaseQuery(DBID)    
  
EndProcedure 

  Procedure AssignStrings(Language.s)
    
  Define iLoop.i = 0
  Define Criteria.s,SearchLanguage.s
  
  SearchLanguage = "LT_" + AppLanguage

  Criteria = "SELECT * From Phrases ORDER BY Phrase_ID;"

  DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "Resources\" + ProjectTitle +".Lng","","")   
 
  GetTotal.s = "Select Count(*) FROM Phrases;" 
 
  DatabaseQuery(DBID, GetTotal.s)
  FirstDatabaseRow(DBID)
  TotalRows.i = Val(GetDatabaseString(DBID,0)) ;Store this in the TotalRows variable
  FinishDatabaseQuery(DBID) ;free the query
  ReDim TranslatedString.s(TotalRows - 1)
  DatabaseQuery(DBID,Criteria)
  FirstDatabaseRow(DBID)
  TranslatedString(iLoop) = GetDatabaseString(DBID, DatabaseColumnIndex(DBID,SearchLanguage))
  iLoop = iLoop + 1
  While NextDatabaseRow(DBID)
    TranslatedString(iLoop) = GetDatabaseString(DBID,DatabaseColumnIndex(DBID,SearchLanguage))
    iLoop = iLoop + 1 
  Wend
  FinishDatabaseQuery(DBID)
 
EndProcedure

  Procedure GetProjectFile()
    
    Define Folder.s,FileName.s
    
    Folder = GetCurrentDirectory() + "Resources\"

    If ExamineDirectory(0, Folder, "*.lng")

      While NextDirectoryEntry(0)

        FileName = DirectoryEntryName(0)
        If DirectoryEntryType(0) = #PB_DirectoryEntry_File
          ;Project Title
          ProjectTitle = GetFilePart(DirectoryEntryName(0),#PB_FileSystem_NoExtension)
        EndIf
      Wend
      FinishDirectory(0)
    EndIf
    
    EndProcedure

  Procedure Initialise()

    GetProjectFile()
    FetchAvailableLanguages()
    AssignStrings(Locale::AppLanguage)
    
  EndProcedure
  
  Procedure.i GetImageFromDB(Language.s)
    
   Define LDB.i 
   Define RetVal.i
   LDB = OpenDatabase(#PB_Any,GetCurrentDirectory() + "Resources\" + ProjectTitle +".Lng","","")     
   If DatabaseQuery(LDB, "SELECT LT_Flag FROM Language WHERE LT_Title ='" + Language + "';")
      
      FirstDatabaseRow(LDB)
      pictureSize = DatabaseColumnSize(LDB, 0)
      *picture = AllocateMemory(pictureSize)
      GetDatabaseBlob(LDB, 0, *picture, pictureSize)
      RetVal = CatchImage(#PB_Any, *picture, pictureSize)
      FinishDatabaseQuery(LDB)
      FreeMemory(*picture)
      
    EndIf
  
  If retval <> 0
    ProcedureReturn retval
  Else
    ProcedureReturn -1
  EndIf  
  
EndProcedure

  Procedure SelectLanguage()
    
    Define dlgChooseLanguage.i, btnOk.i, imgcmb.i
    
    dlgChooseLanguage = OpenWindow(#PB_Any, 0, 0, 160, 100, "Select Language", #PB_Window_Tool | #PB_Window_ScreenCentered)
    cmbLanguage = ComboBoxGadget(#PB_Any, 10, 30, 140, 20,#PB_ComboBox_Image)
    btnOk = ButtonGadget(#PB_Any, 90, 60, 60, 30, "Ok")
    StickyWindow(dlgChooseLanguage,#True)
    
    ;Load Languages
    For iLoop = 0 To ArraySize(Available())-1
      If IsImage(imgcmb)
        FreeImage(imgcmb)
      EndIf
   ;   imgcmb = LoadImage(#PB_Any,GetCurrentDirectory() + "Resources\"  + Available(iLoop) + ".png")
      
      imgcmb = GetImageFromDB(Available(iLoop))

      If imgcmb > 0
        AddGadgetItem(cmbLanguage,iLoop,Available(iLoop),ImageID(imgcmb))
      Else
        AddGadgetItem(cmbLanguage,iLoop,Available(iLoop))        
      EndIf  
      SetGadgetItemData(cmbLanguage,iLoop,iLoop)
    Next iLoop
    SetGadgetState(cmbLanguage,0)    
    
    Repeat
         Event = WaitWindowEvent() 
      Select event

        Case #PB_Event_Gadget
          Select EventGadget()
              
            Case btnOk
              
              AppLanguage = Available(GetGadgetItemData(cmbLanguage,GetGadgetState(cmbLanguage)))             
              AssignStrings(AppLanguage)  
              CloseWindow(dlgChooseLanguage)
              Break
              
          EndSelect
      EndSelect
      
    ForEver
    
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.60 Beta 1 (Windows - x64)
; CursorPosition = 18
; Folding = n8
; EnableXP
; EnableUnicode