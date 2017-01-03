DeclareModule SelectDate
  

  Declare.i Open()
  
EndDeclareModule

Module SelectDate
  
  Global SelectedDate.i
  
  Enumeration 350
    #Windate
    #Calendar
    #btnOk
    #btnCancel
  EndEnumeration
  
  Procedure ShowFormTexts()
    
    SetWindowTitle(#Windate,Locale::TranslatedString(100))
    SetGadgetText(#btnOk,Locale::TranslatedString(0))
    SetGadgetText(#btnCancel,Locale::TranslatedString(3))   
    
  EndProcedure
   
  
  Procedure.i Open()
    
    Define Date.i 
    Define Quit.i = #False
    
    OpenWindow(#Windate, 50, 50, 270, 250, "")
    CalendarGadget(#Calendar, 10, 10, 250, 200)
    ButtonGadget(#btnOk, 110, 220, 70, 25, "")
    ButtonGadget(#btnCancel, 190, 220, 70, 25, "")   
    ShowFormTexts()
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select  EventGadget()
          
        Case #Calendar
          SelectedDate = GetGadgetState(#Calendar)
          
        Case #btnOk

           CloseWindow(#Windate)
           Quit = #True
           ProcedureReturn SelectedDate
           
        Case #btnCancel
          
          CloseWindow(#Windate)
          Quit = #True
          ProcedureReturn -1
          
      EndSelect      
          
    Until Quit = #True
    
  EndProcedure
  
  EndModule  
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 37
; FirstLine = 16
; Folding = -
; EnableXP
; EnableUnicode