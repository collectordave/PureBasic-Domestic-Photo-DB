DeclareModule DeleteSubject
  
  Declare Open()
  
EndDeclareModule

Module DeleteSubject

Enumeration 300
  #winAddSubject
  #btnOk
  #btnCancel
  #cmbSubject
EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(#winAddSubject,Locale::TranslatedString(106))
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
  
  Procedure.i DeleteSubject()
    
    Define Criteria.s
    Define Subject.i = GetGadgetItemData(#cmbSubject,GetGadgetState(#cmbSubject))
    
    Criteria = "DELETE FROM Subject WHERE Subject_ID = " + Str(Subject) +";"
    DatabaseUpdate(App::PhotoDB, Criteria) 
    ProcedureReturn #True
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    OpenWindow(#winAddSubject, 0, 0, 270, 80, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    ButtonGadget(#btnOk, 110, 40, 70, 25, "")
    ButtonGadget(#btnCancel, 190, 40, 70, 25, "")
    ComboBoxGadget(#cmbSubject, 10, 10, 250, 20)
    StickyWindow(#winAddSubject,#True)
    ShowFormTexts()  
    LoadSubjects()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case #btnOk
              
              DeleteSubject()
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
; CursorPosition = 64
; FirstLine = 13
; Folding = 4-
; EnableXP