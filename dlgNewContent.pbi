DeclareModule NewContent
  
  Declare Open()
  
EndDeclareModule

Module NewContent
  
  Global winAddContent.i,strContent.i,btnOk,btnCancel
;Enumeration PhotoDB 450
;  #winAddContent
;  #btnOk
;  #btnCancel
;  #strContent
;EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(winAddContent,Locale::TranslatedString(109))
    SetGadgetText(btnOk,Locale::TranslatedString(0))
    SetGadgetText(btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure.i SaveContent()
    
    Define Criteria.s
    Define Content.s = ReplaceString(GetGadgetText(strContent),"'","''")

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
  
    winAddContent = OpenWindow(#PB_Any, 0, 0, 270, 80, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    btnOk = ButtonGadget(#PB_Any, 110, 40, 70, 25, "")
    btnCancel = ButtonGadget(#PB_Any, 190, 40, 70, 25, "")
    strContent = StringGadget(#PB_Any, 10, 10, 250, 20, "")
    StickyWindow(winAddContent,#True)
    ShowFormTexts()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case btnOk

             If SaveContent() = #True
                CloseWindow(winAddContent)
                Quit = #True
              EndIf
          
            Case btnCancel
            
              CloseWindow(winAddContent)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.60 beta 6 (Windows - x64)
; CursorPosition = 83
; FirstLine = 31
; Folding = z
; EnableXP