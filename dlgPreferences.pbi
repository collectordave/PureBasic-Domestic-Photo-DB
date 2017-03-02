DeclareModule Preferences
  
  Declare Open()
  
EndDeclareModule

Module Preferences

Enumeration 500 
  #winPreferences
  #txtLanguage
  #strLanguage
  #btnSelectLanguage
  #txtImageFolder
  #strImageFolder
  #btnSelectFolder
  #txtSlideShow
  #spnTime 
  #txtOnAdd
  #optCopy
  #optMove  
  #txtPrintSize
  #strSingle
  #btnOk
  #btnCancel
EndEnumeration

Procedure ShowFormTexts()
  
  SetWindowTitle(#winPreferences,Locale::TranslatedString(52))

  SetGadgetText(#txtLanguage,Locale::TranslatedString(135))
  SetGadgetText(#btnSelectLanguage,"...")
  GadgetToolTip(#btnSelectLanguage, Locale::TranslatedString(114))
  SetGadgetText(#txtImageFolder, Locale::TranslatedString(115))
  SetGadgetText(#btnSelectFolder,"...")
  GadgetToolTip(#btnSelectFolder, Locale::TranslatedString(116))
  SetGadgetText(#txtSlideShow, Locale::TranslatedString(117))
  SetGadgetText(#txtOnAdd, Locale::TranslatedString(118)) 
  SetGadgetText(#OptCopy, Locale::TranslatedString(20))   
  SetGadgetText(#OptMove, Locale::TranslatedString(136))   
  SetGadgetText(#btnOk,Locale::TranslatedString(0))
  SetGadgetText(#btnCancel,Locale::TranslatedString(3))
  
EndProcedure

Procedure Open()

  Define Quit.i = #False
  Define SelectedPath.s
  
  OpenWindow(#winPreferences, 0, 0, 340, 180, "", #PB_Window_Tool | #PB_Window_WindowCentered)
  TextGadget(#txtLanguage, 5, 10, 60, 20, "", #PB_Text_Right)
  StringGadget(#strLanguage, 70, 10, 110, 20, "")
  ButtonGadget(#btnSelectLanguage, 180, 10, 20, 20, "...")
  GadgetToolTip(#btnSelectLanguage, "")
  TextGadget(#txtImageFolder, 10, 40, 170, 20, "")
  StringGadget(#strImageFolder, 10, 60, 300, 20, "")
  ButtonGadget(#btnSelectFolder, 310, 60, 20, 20, "...")
  GadgetToolTip(#btnSelectFolder, "")
  TextGadget(#txtSlideShow, 195, 10, 80, 20, "", #PB_Text_Right)
  SpinGadget(#spnTime, 280, 10, 40, 20, 1, 10, #PB_Spin_Numeric)
  TextGadget(#txtOnAdd, 10, 95, 60, 20, "", #PB_Text_Right)
  OptionGadget(#optCopy, 100, 90, 70, 20, "")
  OptionGadget(#optMove, 175, 90, 70, 20, "") 
  TextGadget(#txtPrintSize, 10, 120, 100, 20, "Thumbnail Size", #PB_Text_Right) 
  StringGadget(#strSingle, 120, 120, 60, 20, "75mm") 
  ButtonGadget(#btnOk, 170, 150, 70, 25, "")
  ButtonGadget(#btnCancel, 260, 150, 70, 25, "")
  StickyWindow(#winPreferences,#True)
  
  ShowFormTexts()
  SetGadgetText(#strLanguage,App::Language)
  SetGadgetState(#spnTime,App::SlideTime)
  SetGadgetText(#strImageFolder,App::BaseFolder) 
  If App::Move = #True
    SetGadgetState(#optMove,#True) 
  Else
    SetGadgetState(#optCopy,#True)
  EndIf  
  
  
  Repeat
  
    Event = WaitWindowEvent()
    
    Select event


    Case #PB_Event_Gadget
      Select EventGadget()
          
        Case #btnOk
          
          App::Language = GetGadgetText(#strLanguage)
          App::BaseFolder = GetGadgetText(#strImageFolder)
          App::SlideTime = GetGadgetState(#spnTime)
          App::Move = GetGadgetState(#optMove)
          App::ThumbSize = Val(GetGadgetText(#strSingle))
          App::Writepreferences("PhotoDB")
          CloseWindow(#winPreferences)
          Quit = #True
          
        Case #btnCancel
          
          CloseWindow(#winPreferences)
          Quit = #True   
          
        Case #btnSelectFolder

          SelectedPath = PathRequester(Locale::TranslatedString(119), App::#DefaultFolder)
          If SelectedPath
            SetGadgetText(#strImageFolder,SelectedPath)
          EndIf
          
        Case #btnSelectLanguage
          
          Locale::SelectLanguage()
          App::Language = Locale::AppLanguage
          SetGadgetText(#strLanguage,Locale::AppLanguage)
          Locale::Initialise()
          ShowFormTexts()
          
      EndSelect
      
  EndSelect
  
Until Quit = #True

EndProcedure

EndModule
; IDE Options = PureBasic 5.60 Beta 1 (Windows - x64)
; CursorPosition = 8
; Folding = 8
; EnableXP