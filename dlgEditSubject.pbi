DeclareModule EditSubject
  
  Declare Open()
  
EndDeclareModule

Module EditSubject
  
  Global winEditSubject.i,strSubject.i,cmbSubject.i,btnOk.i,btnCancel
  
;  Enumeration PhotoDB 350
;   ; #winAddSubject
;    #btnOk
;    #btnCancel
;    #cmbSubject
;    #strSubject
;  EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(winEditSubject,Locale::TranslatedString(108))
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
  
  Procedure.i EditSubject()
    
    Define Criteria.s
    Define Subject_ID.i = GetGadgetItemData(cmbSubject,GetGadgetState(cmbSubject))
    Define Subject.s = ReplaceString(GetGadgetText(strSubject),"'","''")
    
    Criteria = "UPDATE Subject SET PDB_Title = '" + Subject + "' WHERE Subject_ID = " + Str(Subject_ID) +";"
    DatabaseUpdate(App::PhotoDB, Criteria) 
    ProcedureReturn #True
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    winEditSubject = OpenWindow(#PB_Any, 0, 0, 270, 110, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    btnOk = ButtonGadget(#PB_Any, 110, 70, 70, 25, "")
    btnCancel = ButtonGadget(#PB_Any, 190, 70, 70, 25, "")
    cmbSubject = ComboBoxGadget(#PB_Any, 10, 10, 250, 20)
    strSubject = StringGadget(#PB_Any, 10, 40, 250, 20, "")   
    StickyWindow(winEditSubject,#True)
    ShowFormTexts()    
    LoadSubjects()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
              
            Case cmbSubject
              
              SetGadgetText(strSubject,GetGadgetText(cmbSubject))
          
            Case btnOk
              
              EditSubject()
              CloseWindow(winEditSubject)
              Quit = #True
          
            Case btnCancel
            
              CloseWindow(winEditSubject)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.60 beta 6 (Windows - x64)
; CursorPosition = 86
; FirstLine = 71
; Folding = 8-
; EnableXP