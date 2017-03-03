
DeclareModule SearchWin
  
  Declare.s Open()
  
EndDeclareModule

Module SearchWin
  
  
  Global winSearchCriteria.i,cmbSearchSubject.i,txtSearchSubject.i,cmbSearchContent.i,txtSearchContent.i,txtSearchYear.i
  Global strSearchYear.i,txtSearchMonth.i,cmbSearchMonth.i,btnSearchOk.i,btnSearchCancel.i
  ;Enumeration PhotoDB 50
    ;#winSearchCriteria
    ;#cmbSearchSubject
    ;#txtSearchSubject
    ;#cmbSearchContent
    ;#txtSearchContent
    ;#txtSearchYear
  ;  #strSearchYear
  ;  #txtSearchMonth
  ;  #cmbSearchMonth
  ;  #btnSearchOk
  ;  #btnSearchCancel
  ;EndEnumeration

  Procedure ShowFormTexts()
    
    SetWindowTitle(winSearchCriteria,Locale::TranslatedString(120))
    SetGadgetText(txtSearchSubject,Locale::TranslatedString(121))
    SetGadgetText(txtSearchContent,Locale::TranslatedString(122))
    SetGadgetText(txtSearchYear,Locale::TranslatedString(123))
    SetGadgetText(txtSearchMonth,Locale::TranslatedString(124))
    SetGadgetText(btnSearchOk,Locale::TranslatedString(0))
    SetGadgetText(btnSearchCancel,Locale::TranslatedString(3))   
    
  EndProcedure
  
  Procedure LoadSubjects()
  
    Define DBID.i
    Define Criteria.s
    Define iLoop.i = 1
  
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "PhotoData.s3db","","")
  
    Criteria = "Select * FROM Subject ORDER BY PDB_Title ASC;"
    
    AddGadgetItem(cmbSearchSubject,0,"None")
    SetGadgetItemData(cmbSearchSubject, 0,0)
    
    If DatabaseQuery(DBID, Criteria)
    
      While NextDatabaseRow(DBID) ; Loop for each records
      
        AddGadgetItem(cmbSearchSubject,iLoop,GetDatabaseString(DBID, 1))
        SetGadgetItemData(cmbSearchSubject, iLoop,GetDatabaseLong(DBID, 0))
        iLoop = iLoop + 1
        
      Wend
  
      FinishDatabaseQuery(DBID)
    
    EndIf
  
  EndProcedure  
  
  Procedure LoadContents()
  
    Define DBID.i
    Define Criteria.s
    Define iLoop.i = 1
    
    AddGadgetItem(cmbSearchContent,0,"None")
    SetGadgetItemData(cmbSearchContent, 0,0)   
    
    DBID = OpenDatabase(#PB_Any,GetCurrentDirectory() + "PhotoData.s3db","","")
  
    Criteria = "Select * FROM Content ORDER BY PDB_Title ASC;"
  
    If DatabaseQuery(DBID, Criteria)
    
      While NextDatabaseRow(DBID) ; Loop for each records
        
        If GetDatabaseString(DBID, 1) <> "Default"
          
          AddGadgetItem(cmbSearchContent,iLoop,GetDatabaseString(DBID, 1))
          SetGadgetItemData(cmbSearchContent, iLoop,GetDatabaseLong(DBID, 0))
          iLoop = iLoop + 1
          
        EndIf
        
      Wend
  
      FinishDatabaseQuery(DBID)
    
    EndIf
  
  EndProcedure 
  
  Procedure LoadMonths()
    
    AddGadgetItem(cmbSearchMonth,0,"None")
    SetGadgetItemData(cmbSearchMonth, 0,0)
    AddGadgetItem(cmbSearchMonth,1,Locale::TranslatedString(85))
    SetGadgetItemData(cmbSearchMonth, 1,1)
    AddGadgetItem(cmbSearchMonth,2,Locale::TranslatedString(86))
    SetGadgetItemData(cmbSearchMonth, 2,2)
    AddGadgetItem(cmbSearchMonth,3,Locale::TranslatedString(87))
    SetGadgetItemData(cmbSearchMonth, 3,3)
    AddGadgetItem(cmbSearchMonth,4,Locale::TranslatedString(88))
    SetGadgetItemData(cmbSearchMonth, 4,4)
    AddGadgetItem(cmbSearchMonth,5,Locale::TranslatedString(89))
    SetGadgetItemData(cmbSearchMonth, 5,5)
    AddGadgetItem(cmbSearchMonth,6,Locale::TranslatedString(90))
    SetGadgetItemData(cmbSearchMonth, 6,6)
    AddGadgetItem(cmbSearchMonth,7,Locale::TranslatedString(91))
    SetGadgetItemData(cmbSearchMonth, 7,7)
    AddGadgetItem(cmbSearchMonth,8,Locale::TranslatedString(92))
    SetGadgetItemData(cmbSearchMonth, 8,8)
    AddGadgetItem(cmbSearchMonth,9,Locale::TranslatedString(93))
    SetGadgetItemData(cmbSearchMonth, 9,9)
    AddGadgetItem(cmbSearchMonth,10,Locale::TranslatedString(94))
    SetGadgetItemData(cmbSearchMonth, 10,10)
    AddGadgetItem(cmbSearchMonth,11,Locale::TranslatedString(95))
    SetGadgetItemData(cmbSearchMonth, 11,11)
    AddGadgetItem(cmbSearchMonth,12,Locale::TranslatedString(96))
    SetGadgetItemData(cmbSearchMonth, 12,12)
                                             
  EndProcedure
  
  Procedure.s BuildQueryString()
    
    Define Built.i = #False
    Define QueryString.s
    
    QueryString = " WHERE "
    
    ;Subject
    If GetGadgetItemData(cmbSearchSubject,GetGadgetState(cmbSearchSubject)) > 0
      QueryString = QueryString + " Photos.Subject_ID = " + Str(GetGadgetItemData(cmbSearchSubject,GetGadgetState(cmbSearchSubject)))
      Built = #True
    EndIf
    
    ;Content
    If GetGadgetItemData(cmbSearchContent,GetGadgetState(cmbSearchContent)) > 0
      If Built = #True
         
        QueryString = QueryString + " AND PhotoContent.Content_ID = " + Str(GetGadgetItemData(cmbSearchContent,GetGadgetState(cmbSearchContent)))
 
      Else
         
        QueryString = QueryString + " PhotoContent.Content_ID = " + Str(GetGadgetItemData(cmbSearchContent,GetGadgetState(cmbSearchContent)))
        Built = #True
         
      EndIf
    EndIf
    
    ;Year
    If Val(Trim(GetGadgetText(strSearchYear))) => 1900 And Val(Trim(GetGadgetText(strSearchYear))) <= Year(Date())
      
      If Built = #True
         
        QueryString = QueryString + " AND Photos.PDB_Year = " + Trim(GetGadgetText(strSearchYear))
 
      Else
       
        QueryString = QueryString + " Photos.PDB_Year = " + Trim(GetGadgetText(strSearchYear))
        Built = #True
         
      EndIf
      
    EndIf    
    
    ;Month Of Year
    If GetGadgetItemData(cmbSearchMonth,GetGadgetState(cmbSearchMonth)) > 0
      If Built = #True
         
        QueryString = QueryString + " AND Photos.PDB_Month = " + Str(GetGadgetItemData(cmbSearchMonth,GetGadgetState(cmbSearchMonth)))
 
      Else
       
        QueryString = QueryString + " Photos.PDB_Month = " + Str(GetGadgetItemData(cmbSearchMonth,GetGadgetState(cmbSearchMonth)))
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
    
    winSearchCriteria = OpenWindow(#PB_Any, 0, 0, 360, 150, Locale::TranslatedString(120), #PB_Window_SystemMenu|#PB_Window_WindowCentered)
    cmbSearchSubject = ComboBoxGadget(#PB_Any, 100, 10, 250, 20)
    txtSearchSubject = TextGadget(#PB_Any, 10, 10, 80, 20, Locale::TranslatedString(121), #PB_Text_Right)
    cmbSearchContent = ComboBoxGadget(#PB_Any, 100, 40, 250, 20)
    txtSearchContent = TextGadget(#PB_Any, 10, 40, 80, 20, Locale::TranslatedString(122), #PB_Text_Right)
    txtSearchYear = TextGadget(#PB_Any, 30, 70, 60, 20, Locale::TranslatedString(123), #PB_Text_Right)
    strSearchYear = StringGadget(#PB_Any, 100, 70, 50, 20, "")
    txtSearchMonth = TextGadget(#PB_Any, 170, 70, 60, 20, Locale::TranslatedString(124), #PB_Text_Right)
    cmbSearchMonth = ComboBoxGadget(#PB_Any, 240, 70, 110, 20)
    btnSearchOk = ButtonGadget(#PB_Any, 180, 110, 70, 25, Locale::TranslatedString(0))
    btnSearchCancel = ButtonGadget(#PB_Any, 280, 110, 70, 25, Locale::TranslatedString(3))
    LoadSubjects()
    SetGadgetState(cmbSearchSubject, 0)  
    LoadContents()
    SetGadgetState(cmbSearchContent, 0)    
    LoadMonths()
    ShowFormTexts()
  
    StickyWindow(winSearchCriteria,#True)
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event

        Case #PB_Event_Gadget
          
          Select  EventGadget()
          
            Case btnSearchOk
              
                RetVal =  BuildQueryString()
                CloseWindow(winSearchCriteria)
                Quit = #True
          
            Case btnSearchCancel
              
              RetVal = ""
              CloseWindow(winSearchCriteria)
              Quit = #True

          EndSelect 
        
      EndSelect    
      
    Until Quit = #True
    ProcedureReturn RetVal
    
  EndProcedure

EndModule
; IDE Options = PureBasic 5.60 beta 6 (Windows - x64)
; CursorPosition = 239
; FirstLine = 225
; Folding = --
; EnableXP