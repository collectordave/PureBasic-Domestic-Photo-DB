DeclareModule ImageViewer
  
  Declare Open(Array Filenames.s(1))  
  
EndDeclareModule

Module ImageViewer
  
  Global AspectRatioWidth.f,AspectRatioHeight.f
  
  Global ImageToView.i
  
  Enumeration 200
    #BackWindow
    #ShowImage
  EndEnumeration

  Procedure ShowImage(FileName.s)
    
  If FileName

      ImageToView = LoadImage(#PB_Any, FileName)
      If ImageToView > 0
        
        ;Calculate Aspect Ratios
        AspectRatioWidth = DesktopWidth(0)/ImageWidth(ImageToView)
        AspectRatioHeight = DesktopHeight(0)/ImageHeight(ImageToView)
        
        ;Use The Smallest
        If AspectRatioWidth < AspectRatioHeight
          ResizeImage(ImageToView,ImageWidth(ImageToView) * AspectRatioWidth,ImageHeight(ImageToView) * AspectRatioWidth)
        Else
          ResizeImage(ImageToView,ImageWidth(ImageToView) * AspectRatioHeight,ImageHeight(ImageToView) * AspectRatioHeight)
        EndIf
 
        ;x and y position for the Image Gadget
        x = DesktopWidth(0)/2-ImageWidth(ImageToView)/2
        y = DesktopHeight(0)/2-ImageHeight(ImageToView)/2
        ResizeGadget(#ShowImage,x,y,ImageWidth(ImageToView),ImageHeight(ImageToView))
        SetGadgetState(#ShowImage,ImageID(ImageToView))
      
      EndIf
      
    EndIf
    
  EndProcedure

  Procedure Open(Array Filenames.s(1))
    
    Define Quit.i = #False
    Protected iLoop.i = 0
    ExamineDesktops()
    
    ;Open a whole screen black window as background
    OpenWindow(#BackWindow,0,0,DesktopWidth(0),DesktopHeight(0),"", #PB_Window_BorderLess)
    SetWindowColor(#BackWindow,0) 
    ImageGadget(#ShowImage,  0, 0, DesktopWidth(0),DesktopHeight(0), 0) 
    AddKeyboardShortcut(#BackWindow,#PB_Shortcut_F11,25)
    AddWindowTimer(#BackWindow, 11, App::SlideTime * 1000)

    ShowImage(Filenames(iLoop)) ;Show First Or Only Image
    
    Repeat
      
      Event = WaitWindowEvent()
      Select Event
          
        Case #PB_Event_RightClick  
          
          CloseWindow(#BackWindow)         
          Quit = #True 
          
        Case #PB_Event_Menu
              
          Select EventMenu()
              
            Case 25
              
              CloseWindow(#BackWindow)
              Quit = #True 
              
          EndSelect
              
        Case #PB_Event_Timer 
          
          If ArraySize(FileNames()) > 1
            If ArraySize(FileNames()) > iLoop
              iLoop = iLoop + 1
              ShowImage(Filenames(iLoop)) 
            Else
              CloseWindow(#BackWindow)
              Quit = #True
            EndIf
          EndIf    
          
      EndSelect
          
    Until Quit = #True 
    
  EndProcedure
  

     
EndModule
; IDE Options = PureBasic 5.60 Beta 3 (Windows - x64)
; CursorPosition = 60
; FirstLine = 47
; Folding = -
; EnableXP