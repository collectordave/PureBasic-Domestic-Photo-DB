DeclareModule NewSubject
  
  Declare Open()
  
EndDeclareModule

Module NewSubject

Enumeration 300
  #winAddSubject
  #btnOk
  #btnCancel
  #strSubject
EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(#winAddSubject,Locale::TranslatedString(112))
    SetGadgetText(#btnOk,Locale::TranslatedString(0))
    SetGadgetText(#btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure.i SaveSubject()
    
    Define Criteria.s
    Define Subject.s = ReplaceString(GetGadgetText(#strSubject),"'","''")

    Criteria = "SELECT * FROM Subject WHERE PDB_Title = '" + Subject +"';"
    If DatabaseQuery(App::PhotoDB, Criteria)
      
      If FirstDatabaseRow(App::PhotoDB)
        
        App::Message(Locale::TranslatedString(110)," Subject Allready Exists!",App::#OkOnly|App::#WarningIcon)
        FinishDatabaseQuery(App::PhotoDB)
        ProcedureReturn #False
        
      Else
        
        FinishDatabaseQuery(App::PhotoDB)
        Criteria = "INSERT INTO Subject (PDB_Title) VALUES ('"  + Subject +"');"
        DatabaseUpdate(App::PhotoDB, Criteria) 
        ProcedureReturn #True
      
      EndIf  
      
    EndIf
    
    ProcedureReturn #False
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    OpenWindow(#winAddSubject, 0, 0, 270, 80, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    ButtonGadget(#btnOk, 110, 40, 70, 25, "")
    ButtonGadget(#btnCancel, 190, 40, 70, 25, "")
    StringGadget(#strSubject, 10, 10, 250, 20, "")
    StickyWindow(#winAddSubject,#True)
    ShowFormTexts()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case #btnOk

             If SaveSubject() = #True
                CloseWindow(#winAddSubject)
                Quit = #True
              EndIf
          
            Case #btnCancel
            
              CloseWindow(#winAddSubject)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 56
; FirstLine = 51
; Folding = -
; EnableXP