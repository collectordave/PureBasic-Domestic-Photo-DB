DeclareModule AddContent
  
  Declare Open(PhotoID.i)
  
EndDeclareModule

Module AddContent

Enumeration 300
  #winAddContent
  #btnOk
  #btnCancel
  #cmbContent
EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(#winAddContent,Locale::TranslatedString(102))
    SetGadgetText(#btnOk,Locale::TranslatedString(0))
    SetGadgetText(#btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
   Procedure LoadContents()
  
    Define DBID.i
    Define Criteria.s
    Define iLoop.i = 0
    
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "PhotoData.s3db","","")
  
    Criteria = "Select * FROM Content ORDER BY PDB_Title ASC;"
  
    If DatabaseQuery(DBID, Criteria)
    
      While NextDatabaseRow(DBID) ; Loop for each records
      
        If GetDatabaseString(DBID, 1) <> "Default"
          
          AddGadgetItem(#cmbContent,iLoop,GetDatabaseString(DBID, 1))
          SetGadgetItemData(#cmbContent, iLoop,GetDatabaseLong(DBID, 0))
          iLoop = iLoop + 1
          
        EndIf
        
      Wend
  
      FinishDatabaseQuery(DBID)
    
    EndIf
  
  EndProcedure 
  
  Procedure AddContent(PhotoID.i)
    
    Define Criteria.s
    Define Content.i = GetGadgetItemData(#cmbContent,GetGadgetState(#cmbContent))
    
    Criteria = "INSERT INTO PhotoContent (Photo_ID,Content_ID) VALUES (" + Str(PhotoID) + "," + Str(Content) + ");"
    DatabaseUpdate(App::PhotoDB, Criteria) 
     
  EndProcedure
  
  Procedure Open(PhotoID.i)
  
    Define Quit.i = #False 
    
    OpenWindow(#winAddContent, 0, 0, 270, 80, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    ButtonGadget(#btnOk, 110, 40, 70, 25, "")
    ButtonGadget(#btnCancel, 190, 40, 70, 25, "")
    ComboBoxGadget(#cmbContent, 10, 10, 250, 20)
    StickyWindow(#winAddContent,#True)
    ShowFormTexts()   
    LoadContents()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case #btnOk

              AddContent(PhotoID)
              CloseWindow(#winAddContent)
              Quit = #True
          
            Case #btnCancel
            
              CloseWindow(#winAddContent)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 67
; FirstLine = 30
; Folding = 4-
; EnableXP