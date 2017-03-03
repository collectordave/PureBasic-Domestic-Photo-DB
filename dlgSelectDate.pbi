DeclareModule SelectDate
  
  Declare.i Open()
  
EndDeclareModule

Module SelectDate
  
  Global Windate.i,Calendar.i,btnOk.i,btnCancel
  
  Global SelectedDate.i
  
  Procedure ShowFormTexts()
    
    SetWindowTitle(Windate,Locale::TranslatedString(100))
    SetGadgetText(btnOk,Locale::TranslatedString(0))
    SetGadgetText(btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
     
  Procedure.i Open()
    
    Define Date.i 
    Define Quit.i = #False
    
    Windate = OpenWindow(#PB_Any, 50, 50, 270, 250, "")
    Calendar = CalendarGadget(#PB_Any, 10, 10, 250, 200)
    btnOk = ButtonGadget(#PB_Any, 110, 220, 70, 25, "")
    btnCancel = ButtonGadget(#PB_Any, 190, 220, 70, 25, "")   
    ShowFormTexts()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select  EventGadget()
          
        Case Calendar
          
          SelectedDate = GetGadgetState(Calendar)
          
        Case btnOk

           CloseWindow(Windate)
           Quit = #True
           ProcedureReturn SelectedDate
           
        Case btnCancel
          
          CloseWindow(Windate)
          Quit = #True
          ProcedureReturn -1
          
      EndSelect      
          
    Until Quit = #True
    
  EndProcedure
  
  EndModule  
; IDE Options = PureBasic 5.60 beta 6 (Windows - x64)
; CursorPosition = 11
; Folding = 8
; EnableXP
; EnableUnicode