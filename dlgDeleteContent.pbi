;{ ==Code Header Comment==============================
;         Name/title: dlgDeleteContent.pbi
;    Executable name: N/A
;            Version: 1.0.0
;    Original Author: Collectordave
;     Translation by: 
;        Create date: 05\Feb\2017
;  Previous releases: 
;  This Release Date: 05\Feb\2017 
;   Operating system: Windows  [X]GUI
;   Compiler version: PureBasic 5.6B2 (x64)
;          Copyright: (C)2017
;            License: Credit Only
;          Libraries: 
;      English Forum: 
;       French Forum: 
;       German Forum: 
;   Tested platforms: Windows
;        Description: Include module to delete content in Photodb
; ====================================================
;.......10........20........30........40........50........60........70........80
;}
DeclareModule DeleteContent
  
  Declare Open()
  
EndDeclareModule

Module DeleteContent
  
  Global winDeleteContent.i,cmbContent.i,btnOk.i,btnCancel.i

  Procedure ShowFormTexts()
    
    SetWindowTitle(winDeleteContent,Locale::TranslatedString(103))
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
  
  Procedure.i DeleteContent()
    
    Define Criteria.s
    Define Content.i = GetGadgetItemData(cmbContent,GetGadgetState(cmbContent))
    
    Criteria = "DELETE FROM Content WHERE Content_ID = " + Str(Content) +";"
    DatabaseUpdate(App::PhotoDB, Criteria) 
    ProcedureReturn #True
    
  EndProcedure
  
  Procedure Open()
  
    Define Quit.i = #False 
  
    winDeleteContent = OpenWindow(#PB_Any, 0, 0, 270, 80, "", #PB_Window_TitleBar | #PB_Window_WindowCentered)
    btnOk = ButtonGadget(#PB_Any, 110, 40, 70, 25, "")
    btnCancel = ButtonGadget(#PB_Any, 190, 40, 70, 25, "")
    cmbContent = ComboBoxGadget(#PB_Any, 10, 10, 250, 20)
    StickyWindow(winDeleteContent,#True)
    ShowFormTexts()   
    LoadContents()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case btnOk
              
              DeleteContent()
              App::RecordDeleted = #True
              CloseWindow(winDeleteContent)
              Quit = #True
          
            Case btnCancel
            
              CloseWindow(winDeleteContent)
              Quit = #True
           
          EndSelect 
        
      EndSelect    
          
    Until Quit = #True
    
  EndProcedure  

EndModule
; IDE Options = PureBasic 5.60 beta 6 (Windows - x64)
; CursorPosition = 44
; FirstLine = 35
; Folding = f+
; EnableXP