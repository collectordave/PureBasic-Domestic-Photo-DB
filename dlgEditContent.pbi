DeclareModule EditContent
  
  Declare Open()
  
EndDeclareModule

Module EditContent

Enumeration 300
  #winEditContent
  #btnOk
  #btnCancel
  #cmbContent
  #strContent
EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(#winEditContent,Locale::TranslatedString(107))
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
  
  Procedure.i EditContent()
    
    Define Criteria.s
    Define Content_ID.i = GetGadgetItemData(#cmbContent,GetGadgetState(#cmbContent))
    Define Content.s = ReplaceString(GetGadgetText(#strContent),"'","''")
    
    Criteria = "UPDATE Content SET PDB_Title = '" + Content + "' WHERE Content_ID = " + Str(Content_ID) +";"
    DatabaseUpdate(App::PhotoDB, Criteria) 
    ProcedureReturn #True
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    OpenWindow(#winEditContent, 0, 0, 270, 110, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    ButtonGadget(#btnOk, 110, 70, 70, 25, "")
    ButtonGadget(#btnCancel, 190, 70, 70, 25, "")
    ComboBoxGadget(#cmbContent, 10, 10, 250, 20)
    StringGadget(#strContent, 10, 40, 250, 20, "")   
    StickyWindow(#winEditContent,#True)
    ShowFormTexts()
    LoadContents()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
              
            Case #cmbContent
              
              SetGadgetText(#strContent,GetGadgetText(#cmbContent))
          
            Case #btnOk
              
              EditContent()
              CloseWindow(#winEditContent)
              Quit = #True
          
            Case #btnCancel
            
              CloseWindow(#winEditContent)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 70
; FirstLine = 47
; Folding = r-
; EnableXP