DeclareModule EditSubject
  
  Declare Open()
  
EndDeclareModule

Module EditSubject

  Enumeration 300
    #winAddSubject
    #btnOk
    #btnCancel
    #cmbSubject
    #strSubject
  EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(#winAddSubject,Locale::TranslatedString(108))
    SetGadgetText(#btnOk,Locale::TranslatedString(0))
    SetGadgetText(#btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure LoadSubjects()
  
    Define DBID.i
    Define Criteria.s
    Define iLoop.i = 0
    
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "PhotoData.s3db","","")
  
    Criteria = "Select * FROM Subject ORDER BY PDB_Title ASC;"
  
    If DatabaseQuery(DBID, Criteria)
    
      While NextDatabaseRow(DBID) ; Loop for each records
      
        AddGadgetItem(#cmbSubject,iLoop,GetDatabaseString(DBID, 1))
        SetGadgetItemData(#cmbSubject, iLoop,GetDatabaseLong(DBID, 0))
        iLoop = iLoop + 1
        
      Wend
  
      FinishDatabaseQuery(DBID)
    
    EndIf
  
  EndProcedure 
  
  Procedure.i EditSubject()
    
    Define Criteria.s
    Define Subject_ID.i = GetGadgetItemData(#cmbSubject,GetGadgetState(#cmbSubject))
    Define Subject.s = ReplaceString(GetGadgetText(#strSubject),"'","''")
    
    Criteria = "UPDATE Subject SET PDB_Title = '" + Subject + "' WHERE Subject_ID = " + Str(Subject_ID) +";"
    DatabaseUpdate(App::PhotoDB, Criteria) 
    ProcedureReturn #True
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    OpenWindow(#winAddSubject, 0, 0, 270, 110, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    ButtonGadget(#btnOk, 110, 70, 70, 25, "")
    ButtonGadget(#btnCancel, 190, 70, 70, 25, "")
    ComboBoxGadget(#cmbSubject, 10, 10, 250, 20)
    StringGadget(#strSubject, 10, 40, 250, 20, "")   
    StickyWindow(#winAddSubject,#True)
    ShowFormTexts()    
    LoadSubjects()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
              
            Case #cmbSubject
              
              SetGadgetText(#strSubject,GetGadgetText(#cmbSubject))
          
            Case #btnOk
              
              EditSubject()
              CloseWindow(#winAddSubject)
              Quit = #True
          
            Case #btnCancel
            
              CloseWindow(#winAddSubject)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 66
; Folding = j-
; EnableXP