DeclareModule DeleteSubject
  
  Declare Open()
  
EndDeclareModule

Module DeleteSubject
  
  Global winDeleteSubject.i,cmbSubject.i,btnOk.i,btnCancel.i 

  Procedure ShowFormTexts()
    
    SetWindowTitle(winDeleteSubject,Locale::TranslatedString(106))
    SetGadgetText(btnOk,Locale::TranslatedString(0))
    SetGadgetText(btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure LoadSubjects()
  
    Define Criteria.s
    Define iLoop.i = 0
  
    Criteria = "Select * FROM Subject ORDER BY PDB_Title ASC;"
  
    If DatabaseQuery(App::PhotoDB, Criteria)
    
      While NextDatabaseRow(App::PhotoDB) ; Loop for each records
      
        AddGadgetItem(cmbSubject,iLoop,GetDatabaseString(App::PhotoDB, 1))
        SetGadgetItemData(cmbSubject, iLoop,GetDatabaseLong(App::PhotoDB, 0))
        iLoop = iLoop + 1
        
      Wend
  
      FinishDatabaseQuery(App::PhotoDB)
    
    EndIf
  
  EndProcedure 
  
  Procedure.i DeleteSubject()
    
    Define Criteria.s
    Define Subject.i = GetGadgetItemData(cmbSubject,GetGadgetState(cmbSubject))
    
    Criteria = "DELETE FROM Subject WHERE Subject_ID = " + Str(Subject) +";"
    DatabaseUpdate(App::PhotoDB, Criteria) 
    ProcedureReturn #True
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    winDeleteSubject = OpenWindow(#PB_Any, 0, 0, 270, 80, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    btnOk = ButtonGadget(#PB_Any, 110, 40, 70, 25, "")
    btnCancel = ButtonGadget(#PB_Any, 190, 40, 70, 25, "")
    cmbSubject = ComboBoxGadget(#PB_Any, 10, 10, 250, 20)
    StickyWindow(winDeleteSubject,#True)
    ShowFormTexts()  
    LoadSubjects()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case btnOk
              App::RecordDeleted = #True
              DeleteSubject()
              CloseWindow(winDeleteSubject)
              Quit = #True
          
            Case btnCancel
            
              CloseWindow(winDeleteSubject)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.60 beta 6 (Windows - x64)
; CursorPosition = 9
; Folding = z-
; EnableXP