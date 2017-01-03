DeclareModule NewContent
  
  Declare Open()
  
EndDeclareModule

Module NewContent

Enumeration 300
  #winAddContent
  #btnOk
  #btnCancel
  #strContent
EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(#winAddContent,Locale::TranslatedString(109))
    SetGadgetText(#btnOk,Locale::TranslatedString(0))
    SetGadgetText(#btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure.i SaveContent()
    
    Define Criteria.s
    Define Content.s = ReplaceString(GetGadgetText(#strContent),"'","''")

    Criteria = "SELECT * FROM Content WHERE PDB_Title = '" + Content +"';"
    If DatabaseQuery(App::PhotoDB, Criteria)
      
      If FirstDatabaseRow(App::PhotoDB)
        
        App::Message(Locale::TranslatedString(110)," Content Allready Exists!",App::#OkOnly|App::#WarningIcon)
        FinishDatabaseQuery(App::PhotoDB)
        ProcedureReturn #False
        
      Else
        
        FinishDatabaseQuery(App::PhotoDB)
        Criteria = "INSERT INTO Content (PDB_Title) VALUES ('"  + Content +"');"
        DatabaseUpdate(App::PhotoDB, Criteria) 
        ProcedureReturn #True
      
      EndIf  
      
    EndIf
    
    ProcedureReturn #False
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    OpenWindow(#winAddContent, 0, 0, 270, 80, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    ButtonGadget(#btnOk, 110, 40, 70, 25, "")
    ButtonGadget(#btnCancel, 190, 40, 70, 25, "")
    StringGadget(#strContent, 10, 10, 250, 20, "")
    StickyWindow(#winAddContent,#True)
    ShowFormTexts()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case #btnOk

             If SaveContent() = #True
                CloseWindow(#winAddContent)
                Quit = #True
              EndIf
          
            Case #btnCancel
            
              CloseWindow(#winAddContent)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 56
; FirstLine = 10
; Folding = 4
; EnableXP