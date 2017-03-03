DeclareModule EditContent
  
  Declare Open()
  
EndDeclareModule

Module EditContent
  
    Global winEditContent.i,cmbContent.i,strContent.i,btnOk.i,btnCancel.i

  Procedure ShowFormTexts()
    
    SetWindowTitle(winEditContent,Locale::TranslatedString(107))
    SetGadgetText(btnOk,Locale::TranslatedString(0))
    SetGadgetText(btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure LoadContents()
  

    Define Criteria.s
    Define iLoop.i = 0
  
    Criteria = "Select * FROM Content ORDER BY PDB_Title ASC;"
  
    If DatabaseQuery(App::PhotoDB, Criteria)
    
      While NextDatabaseRow(App::PhotoDB) ; Loop for each records
        
        If GetDatabaseString(App::PhotoDB, 1) <> "Default"
          
          AddGadgetItem(cmbContent,iLoop,GetDatabaseString(App::PhotoDB, 1))
          SetGadgetItemData(cmbContent, iLoop,GetDatabaseLong(App::PhotoDB, 0))
          iLoop = iLoop + 1
          
        EndIf
        
      Wend
  
      FinishDatabaseQuery(App::PhotoDB)
    
    EndIf
  
  EndProcedure 
  
  Procedure.i EditContent()
    
    Define Criteria.s
    Define Content_ID.i = GetGadgetItemData(cmbContent,GetGadgetState(cmbContent))
    Define Content.s = ReplaceString(GetGadgetText(strContent),"'","''")
    
    Criteria = "UPDATE Content SET PDB_Title = '" + Content + "' WHERE Content_ID = " + Str(Content_ID) +";"
    DatabaseUpdate(App::PhotoDB, Criteria) 
    ProcedureReturn #True
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    winEditContent = OpenWindow(#PB_Any, 0, 0, 270, 110, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    btnOk = ButtonGadget(#PB_Any, 110, 70, 70, 25, "")
    btnCancel = ButtonGadget(#PB_Any, 190, 70, 70, 25, "")
    cmbContent = ComboBoxGadget(#PB_Any, 10, 10, 250, 20)
    strContent = StringGadget(#PB_Any, 10, 40, 250, 20, "")   
    StickyWindow(winEditContent,#True)
    ShowFormTexts()
    LoadContents()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
              
            Case cmbContent
              
              SetGadgetText(strContent,GetGadgetText(cmbContent))
          
            Case btnOk
              
              EditContent()
              CloseWindow(winEditContent)
              Quit = #True
          
            Case btnCancel
            
              CloseWindow(winEditContent)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.60 beta 6 (Windows - x64)
; CursorPosition = 9
; Folding = --
; EnableXP