DeclareModule SearchWin
  
  Declare.s Open()
  
EndDeclareModule

Module SearchWin


Enumeration 400
  #winSearchCriteria
  #cmbSubject
  #txtSubject
  #cmbContent
  #txtContent
  #txtYear
  #strYear
  #txtMonth
  #cmbMonth
  #btnOk
  #btnCancel
EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(#winSearchCriteria,Locale::TranslatedString(120))
    SetGadgetText(#txtSubject,Locale::TranslatedString(121))
    SetGadgetText(#txtContent,Locale::TranslatedString(122))
    SetGadgetText(#txtYear,Locale::TranslatedString(123))
    SetGadgetText(#txtMonth,Locale::TranslatedString(124))
    SetGadgetText(#btnOk,Locale::TranslatedString(0))
    SetGadgetText(#btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure LoadSubjects()
  
    Define DBID.i
    Define Criteria.s
    Define iLoop.i = 1
  
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "PhotoData.s3db","","")
  
    Criteria = "Select * FROM Subject ORDER BY PDB_Title ASC;"
    
    AddGadgetItem(#cmbSubject,0,"None")
    SetGadgetItemData(#cmbSubject, 0,0)
    
    If DatabaseQuery(DBID, Criteria)
    
      While NextDatabaseRow(DBID) ; Loop for each records
      
        AddGadgetItem(#cmbSubject,iLoop,GetDatabaseString(DBID, 1))
        SetGadgetItemData(#cmbSubject, iLoop,GetDatabaseLong(DBID, 0))
        iLoop = iLoop + 1
        
      Wend
  
      FinishDatabaseQuery(DBID)
    
    EndIf
  
  EndProcedure  
  
  Procedure LoadContents()
  
    Define DBID.i
    Define Criteria.s
    Define iLoop.i = 1
    
    AddGadgetItem(#cmbContent,0,"None")
    SetGadgetItemData(#cmbContent, 0,0)   
    
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
  
  Procedure LoadMonths()
    
    AddGadgetItem(#cmbMonth,0,"None")
    SetGadgetItemData(#cmbMonth, 0,0)
    AddGadgetItem(#cmbMonth,1,Locale::TranslatedString(85))
    SetGadgetItemData(#cmbMonth, 1,1)
    AddGadgetItem(#cmbMonth,2,Locale::TranslatedString(86))
    SetGadgetItemData(#cmbMonth, 2,2)
    AddGadgetItem(#cmbMonth,3,Locale::TranslatedString(87))
    SetGadgetItemData(#cmbMonth, 3,3)
    AddGadgetItem(#cmbMonth,4,Locale::TranslatedString(88))
    SetGadgetItemData(#cmbMonth, 4,4)
    AddGadgetItem(#cmbMonth,5,Locale::TranslatedString(89))
    SetGadgetItemData(#cmbMonth, 5,5)
    AddGadgetItem(#cmbMonth,6,Locale::TranslatedString(90))
    SetGadgetItemData(#cmbMonth, 6,6)
    AddGadgetItem(#cmbMonth,7,Locale::TranslatedString(91))
    SetGadgetItemData(#cmbMonth, 7,7)
    AddGadgetItem(#cmbMonth,8,Locale::TranslatedString(92))
    SetGadgetItemData(#cmbMonth, 8,8)
    AddGadgetItem(#cmbMonth,9,Locale::TranslatedString(93))
    SetGadgetItemData(#cmbMonth, 9,9)
    AddGadgetItem(#cmbMonth,10,Locale::TranslatedString(94))
    SetGadgetItemData(#cmbMonth, 10,10)
    AddGadgetItem(#cmbMonth,11,Locale::TranslatedString(95))
    SetGadgetItemData(#cmbMonth, 11,11)
    AddGadgetItem(#cmbMonth,12,Locale::TranslatedString(96))
    SetGadgetItemData(#cmbMonth, 12,12)
                                             
  EndProcedure
  
  Procedure.s BuildQueryString()
    
    Define Built.i = #False
    Define QueryString.s
    
    QueryString = " WHERE "
    
    ;Subject
    If GetGadgetItemData(#cmbSubject,GetGadgetState(#cmbSubject)) > 0
      QueryString = QueryString + " Photos.Subject_ID = " + Str(GetGadgetItemData(#cmbSubject,GetGadgetState(#cmbSubject)))
      Built = #True
    EndIf
    
    ;Content
    If GetGadgetItemData(#cmbContent,GetGadgetState(#cmbContent)) > 0
      If Built = #True
         
        QueryString = QueryString + " AND PhotoContent.Content_ID = " + Str(GetGadgetItemData(#cmbContent,GetGadgetState(#cmbContent)))
 
      Else
         
        QueryString = QueryString + " PhotoContent.Content_ID = " + Str(GetGadgetItemData(#cmbContent,GetGadgetState(#cmbContent)))
        Built = #True
         
      EndIf
    EndIf
    
    ;Year
    If Val(Trim(GetGadgetText(#strYear))) => 1900 And Val(Trim(GetGadgetText(#strYear))) <= Year(Date())
      
      If Built = #True
         
        QueryString = QueryString + " AND Photos.PDB_Year = " + Trim(GetGadgetText(#strYear))
 
      Else
       
        QueryString = QueryString + " Photos.PDB_Year = " + Trim(GetGadgetText(#strYear))
        Built = #True
         
      EndIf
      
    EndIf    
    
    ;Month Of Year
    If GetGadgetItemData(#cmbMonth,GetGadgetState(#cmbMonth)) > 0
      If Built = #True
         
        QueryString = QueryString + " AND Photos.PDB_Month = " + Str(GetGadgetItemData(#cmbMonth,GetGadgetState(#cmbMonth)))
 
      Else
       
        QueryString = QueryString + " Photos.PDB_Month = " + Str(GetGadgetItemData(#cmbMonth,GetGadgetState(#cmbMonth)))
        Built = #True
         
      EndIf
    EndIf   
    
    If Built = #True
      QueryString = QueryString; + ";"
   Else
      QueryString = ""
    EndIf
        
    ProcedureReturn QueryString      
      
  EndProcedure
    
  Procedure.s Open()
  
    Define Quit.i
    Define RetVal.s = ""
    
    OpenWindow(#winSearchCriteria, 0, 0, 360, 150, Locale::TranslatedString(120), #PB_Window_SystemMenu|#PB_Window_WindowCentered)
    ComboBoxGadget(#cmbSubject, 100, 10, 250, 20)
    TextGadget(#txtSubject, 10, 10, 80, 20, Locale::TranslatedString(121), #PB_Text_Right)
    ComboBoxGadget(#cmbContent, 100, 40, 250, 20)
    TextGadget(#txtContent, 10, 40, 80, 20, Locale::TranslatedString(122), #PB_Text_Right)
    TextGadget(#txtYear, 30, 70, 60, 20, Locale::TranslatedString(123), #PB_Text_Right)
    StringGadget(#strYear, 100, 70, 50, 20, "")
    TextGadget(#txtMonth, 170, 70, 60, 20, Locale::TranslatedString(124), #PB_Text_Right)
    ComboBoxGadget(#cmbMonth, 240, 70, 110, 20)
    ButtonGadget(#btnOk, 180, 110, 70, 25, Locale::TranslatedString(0))
    ButtonGadget(#btnCancel, 280, 110, 70, 25, Locale::TranslatedString(3))
    LoadSubjects()
    SetGadgetState(#cmbSubject, 0)  
    LoadContents()
    SetGadgetState(#cmbContent, 0)    
    LoadMonths()
    ShowFormTexts()
  
    StickyWindow(#winSearchCriteria,#True)
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case #btnOk
              
                RetVal =  BuildQueryString()
                CloseWindow(#winSearchCriteria)
                Quit = #True
          
            Case #btnCancel
              
              RetVal = ""
              CloseWindow(#winSearchCriteria)
              Quit = #True
              
            Case #cmbSubject
              
              ;Debug  GetGadgetItemData(#cmbSubject,GetGadgetState(#cmbSubject))
              ;Debug GetGadgetState(#cmbSubject)
              ;Debug CountGadgetItems(#cmbSubject)
              ;Debug GetGadgetText(#cmbSubject)
              ;For iLoop = 0 To CountGadgetItems(#cmbSubject)
              ;  Debug GetGadgetItemText(#cmbSubject, iLoop - 1)
              ;Next iLoop  
              
            Case #cmbMonth
              
             ;Debug  GetGadgetItemData(#cmbMonth,GetGadgetState(#cmbMonth))
              
          EndSelect 
        
      EndSelect    
      
    Until Quit = #True
    ProcedureReturn RetVal
    
  EndProcedure

EndModule
; IDE Options = PureBasic 5.60 Beta 1 (Windows - x64)
; CursorPosition = 238
; FirstLine = 65
; Folding = D+
; EnableXP