## Conventions:
# if position is an argument, it's always 𝕩.
# if color is an argument, it's always 𝕗.
# if function has no intended output, output 𝕩, it makes chaining look nicer.

⟨draw, image, texture, monitor, window, mouse
 font, color, key, # obj (removed obj temporarily for push, because i don't like the current version of it)
 _bitwise, rayffi⟩⇐  

rayFFI ⇐ •Import "rayffi.bqn"

IsInt ← {𝕩⊣(⌈⟜=𝕩)!˜" has to be int"∾˜𝕨⊣"𝕩"}

_bitwise ⇐ {
  _into ← {𝕗_𝕣⁼𝕩: 𝕗⊸×⊸+˜´𝕩; 𝕗|⌊∘÷⟜𝕗⍟(↕1+·⌊𝕗⋆⁼1⌈⊢)𝕩}
  𝕗{_𝕣:(𝔽´⌈○≠↑¨⋈)⌾(2 _into)}
}
NeedsWindow ← {𝕊:𝕩⊣"Expected window to be open"!window.isOpen}

image ← {
  # TODO: remember to check if file exists before running.
  Load   ⇐ {𝕊strPath   : NeedsWindow@ ⋄ ⊑rayFFI.LoadImage𝕩∾@} # ⊑ is used because LoadImage outputs image‿strPath for unknown reasons.
  Unload ⇐ {𝕊image     : NeedsWindow@ ⋄ @⊣rayFFI.UnloadImage𝕩}
  _with  ⇐ {𝔽_𝕣 strPath: NeedsWindow@ ⋄ Unload 𝔽 Load𝕩}
}
texture ← {
  # TODO: remember to check if file exists before running.
  Load   ⇐ {𝕊strPath: NeedsWindow@ ⋄   rayFFI.LoadTexture𝕩∾@} # Load texture from file into GPU memory (VRAM)
  Unload ⇐ {𝕊texture: NeedsWindow@ ⋄ @⊣rayFFI.UnloadImage𝕩}
  _with  ⇐ {𝔽_𝕣 strPath: NeedsWindow@ ⋄r←𝔽˜x←Load𝕩⋄ Unload x ⋄ r}
}
mouse ← {
  GetPos     ⇐rayFFI.GetMousePosition⟨⟩⊣NeedsWindow
  WheelMoved ⇐rayFFI.GetMouseWheelMove⟨⟩⊣NeedsWindow
}
monitor ← {
  ⟨Selected ⋄ Count ⋄ RefreshRate ⋄ Size
   Sizemm ⋄ Name⟩⇐
  Selected    ← rayFFI.GetCurrentMonitor∘⟨⟩
  Count       ← rayFFI.GetMonitorCount∘⟨⟩
  RefreshRate ← rayFFI.GetMonitorRefreshRate
  Size        ← (rayFFI.GetMonitorWidth ∾ rayFFI.GetMonitorHeight)
  Sizemm      ← (rayFFI.GetMonitorPhysicalWidth ∾ rayFFI.GetMonitorPhysicalHeight)
  Name        ← rayFFI.GetMonitorName
  
  ⟨RefreshRate, Size, Sizemm, Name⟩{𝕏@⊸≢◶Selected‿{
      𝕩⊣(⊑𝕩∊↕Count@)!˜"Invalid monitor 𝕩, can only be @ for currently selected monitor or a monitor number; ( 𝕩∊↕monitor.Count@ ) v ( 𝕩≡@ )"
    }}¨↩
  ⟨Selected ⋄ Count ⋄ RefreshRate ⋄ Size
   Sizemm ⋄ Name⟩ {𝕏⊣NeedsWindow}¨↩
}

window ← {
  ⟨_openAs ⋄ SetIcon ⋄ fps ⋄ GetSize
   ShouldClose ⋄ isOpen ⋄ Open ⋄ Close⟩⇐
  isOpen ← 0
  fps⇐{
    Get ⇐ rayFFI.GetFPS∘⟨⟩NeedsWindow
    Set ⇐ {
      NeedsWindow@
      (𝕩=⌈0⌈𝕩)!˜"FPS has to be a positive int"
      𝕩⊣rayFFI.SetTargetFPS𝕩
    }
  }
  Open ← {𝕨𝕊 title: scale←𝕨⊣1
    (¬isOpen)!˜"The window cannot be opened twice"
    (scale≡0⌈1⌊scale)!˜"Scale can only be between 0 and 1"
    ((⟨⟩⊸≡∨⟨2⟩⊸≡)≢scale)!˜"Scale can be a scaler (⟨⟩≢≢𝕨) or length two list (⟨2⟩≡≢𝕨)"
    rayFFI.InitWindow 0‿0∾<𝕩∾@
    isOpen↩1
    rayFFI.SetWindowPosition 0‿42 # 42 here is the window header size (might be windows only)
    rayFFI.SetWindowSize monitor.Size∘@⊸× scale
    fps.Set monitor.RefreshRate@
    𝕩⊣rayFFI.SetWindowState 4
  }
  GetSize ←{𝕤
    NeedsWindow@
    ⟨rayFFI.GetScreenWidth⟨⟩
     rayFFI.GetScreenHeight⟨⟩⟩
  }
  ShouldClose ← 0≠rayFFI.WindowShouldClose∘⟨⟩∘NeedsWindow
  Close ← {
    NeedsWindow@
    rayFFI.CloseWindow⟨⟩
    𝕩⊣isOpen↩0
  }
  _openAs ← {𝕨 App _𝕣 title: scale←𝕨⊣1
    scale(Close⊢𝔽⊣Open)𝕩
  }
  # TODO: Needs to test input for image
  SetIcon ← {𝕊image: NeedsWindow@ ⋄ rayFFI.SetWindowIcon𝕩}
  
  # NOTE: Every bit registers one state (use it with bit masks)
  # By default all flags are set to 0
  configFlags ⇐{⟨
    fullscreen       # Set to run program in fullscreen
    resizable        # Set to allow resizable window
    undecorated      # Set to disable window decoration (frame and buttons)
    transparent      # Set to allow transparent framebuffer
    msaa_4x          # Set to try enabling MSAA 4X
    vSYNC            # Set to try enabling V-Sync on GPU
    hidden           # Set to hide window
    alwaysRun        # Set to allow windows running while minimized
    minimized        # Set to minimize window (iconify)
    maximized        # Set to maximize window (expanded to monitor)
    unfocused        # Set to window non focused
    awaysOnTop       # Set to window always on top
    highDPI          # Set to support HighDPI
    mousePassthrough # Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    interlaced       # Set to try enabling interlaced video format (for V3D)
  ⟩⇐2⋆1⊸+⌾(⊑⌽)1+↕15}
}

draw ← {
  ⟨Start     ⋄ End        ⋄ _withCanvas_
   _Circle   ⋄ _Rectangle ⋄ _Text_   ⋄ _Line
  Background ⋄ _Texture_  ⋄ _Ellipse ⋄ _EllipseOutline
  ⟩⇐
  Background ← {𝕊r‿g‿b‿a:
    NeedsWindow@
    (∧´𝕩∊↕256)!˜"ClearBackground only accepts ints in the range 0-255 inclusive"
    rayFFI.ClearBackground 𝕩
  }
  Start ← ⊢⊣rayFFI.BeginDrawing∘⟨⟩∘NeedsWindow
  End   ← ⊢⊣rayFFI.EndDrawing  ∘⟨⟩∘NeedsWindow
  _withCanvas_ ← {𝕨Func _𝕣_ Func_Returning_A_Color𝕩:
    Start@
    Background 𝕨𝔾𝕩
    ⊣⟜End𝕨𝔽𝕩
  }
  _Circle ← {radius ⟨r,g,b,a⟩_𝕣 posX‿posY :
    NeedsWindow@
    "Circle only accepts ints as args"!∧´⌊⊸=n←𝕩∾𝕨∾𝕗
    "Incorrect amount of arguments"!7=≠n
    rayFFI.DrawCircle ⌊𝕩∾𝕨‿𝕗
  }
  _Rectangle ← {width‿height ⟨r,g,b,a⟩_𝕣 posX‿posY :
    NeedsWindow@
    "Rectangle only accepts ints as args"!∧´⌈⊸=𝕩∾𝕨∾𝕗
    rayFFI.DrawRectangle⌊(𝕩∾𝕨)∾<𝕗
  }
  _Text_ ← {text ⟨r,g,b,a⟩_𝕣_ fontSize ⟨posX,posY⟩:
    NeedsWindow@
    rayFFI.DrawText (𝕨∾@)<⊸∾⌊𝕩∾𝕘‿𝕗
  }
  _Line ← { #TODO add asserts
    ⟨r,g,b,a⟩_𝕣 startPos‿endPos:
      NeedsWindow@
      rayFFI.DrawLine (∾𝕩)∾<𝕗;
    thickness ⟨r,g,b,a⟩ _𝕣 startPos‿endPos:
      NeedsWindow@
      rayFFI.DrawLineEx 𝕩∾𝕨∾<𝕗
  }
  _Texture_ ← {scale‿rotation color _𝕣_ texture pos:
    NeedsWindow@
    rayFFI.DrawTextureEx⟨texture,pos,rotation,scale,color⟩
  }
  _Ellipse ← {width‿height ⟨r,g,b,a⟩_𝕣 posX‿posY :
    NeedsWindow@
    "Ellipse only accepts ints as args"!∧´⌈⊸=𝕩∾𝕗
    rayffi.DrawEllipse (𝕩∾𝕨)∾<𝕗
  }
  _EllipseOutline ← {width‿height ⟨r,g,b,a⟩_𝕣 posX‿posY :
    NeedsWindow@
    "EllipseOutline only accepts ints as args"!∧´⌈⊸=𝕩∾𝕗
    rayffi.DrawEllipseLines (𝕩∾𝕨)∾<𝕗
  }
}

font ← { # TODO: This is untested, please test this later
  Load ⇐ rayFFI.LoadFontEx∘{
    𝕊fontFilePath:
      ⟨𝕩∾@, 40, ≍@, 0⟩; # fontSize fontChars glyphCount # use NULL for fontChars and 0 for glyphCount to load the default character set
    charactersYouCanUse 𝕊 fontFilePath:
      ⟨𝕩∾@, 40, 𝕨-@, ≠𝕨⟩
  }NeedsWindow
  LoadBQN ⇐ {𝕊fontSize: # Sorce of font and chars: https://dzaima.github.io/BQN386/
    chars ← "⎕⍞∆⍙ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_^⌹⍳⍴!%*+,-<=>?|~⊢⊣⌷≤≥≠∨∧÷×∊↑↓○⌈⌊⊂⊃∩∪⊥⊤⍱⍲⍒⍋⍉⌽⊖⍟⍕⍎⍪≡≢⍷⍸⊆⊇⍧⍮√ϼ…¨⍨⌸⍁⍩ᑈᐵ⌶/\&.@∘⌺⍫⍣⍢⍤⍛⍡⍥⍠0123456789¯∞⍬#⍺⍵⍶⍹∇{}:⋄←→+-×÷⋆√⌊⌈∧∨¬|=≠≤<>≥≡≢⊣⊢⥊∾≍⋈↑↓↕⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔`˜˘¨⁼⌜´˝˙∘⊸⟜○⌾⎉⚇⍟⊘◶⎊π‿∞‿@↩←⇐→,⋄𝕨𝕩𝔽𝔾𝕎𝕏𝕗𝕘𝕊𝕤ℝ𝕣⦃⦄⟨⟩"
    rayFFI.LoadFontEx ⟨"BQN386.ttf"∾@, 𝕩, chars-@, ≠chars⟩
  }NeedsWindow
}

color ← {
  hex ⇐ {
    From ⇐ 16⊸×⊸+˜´∘⌽˘·(∾"0A"+⟜↕¨10‿6)⊸⊐˘∘‿2⥊⊢
  }
  exact⇐{
    white⇐4⥊255 ⋄ black⇐¯4↑255
    [red ‿green  ‿blue
     cyan‿magenta‿yellow]⇐255×1∾˜¨⍉(-↕3)⌽⌜⋈⟜¬3↑1
  
  }
  lightgreen ⇐ 144‿238‿144‿255
  darkgreen  ⇐ 0‿100‿0‿255
  lightred   ⇐ 255‿102‿102‿255
  darkred    ⇐ 139‿0‿0‿255
  lightblue  ⇐ 173‿216‿230‿255
  darkblue   ⇐ 0‿0‿139‿255
  orange     ⇐ 255‿165‿0‿255
  brown      ⇐ 165‿42‿42‿255
  green      ⇐ 0‿255‿0‿255
  white      ⇐ 4⥊255
  black      ⇐ ¯4↑255
  red        ⇐ 230‿41‿55‿255
  yellow     ⇐ 255‿255‿0‿255
  cyan       ⇐ 0‿255‿255‿255
  magenta    ⇐ 255‿0‿255‿255
  pink       ⇐ 255‿192‿203‿255
  purple     ⇐ 128‿0‿128‿255
  teal       ⇐ 0‿128‿128‿255
  navy       ⇐ 0‿0‿128‿255
  lavender   ⇐ 230‿230‿250‿255
  gold       ⇐ 255‿215‿0‿255
  silver     ⇐ 192‿192‿192‿255
  blue       ⇐ 0‿121‿241‿255
  skyBlue    ⇐ 102‿191‿255‿255
  gray       ⇐ 128‿128‿128‿255
  lightGray  ⇐ 200‿200‿200‿255
  darkGray   ⇐ 70‿78‿81‿255
}
key ← {
  ⟨IsPressed, GetPressed⟩⇐
  IsPressed ← {𝕊 key:
    NeedsWindow@
    0≠rayFFI.IsKeyPressed @-˜⍟>𝕩
  }⚇0
  GetPressed ← {𝕤  # Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
    NeedsWindow@
    rayFFI.GetKeyPressed⟨⟩
  }
  # consider switching to `letter-@` when possible.

  # vars           Keycodes   Keys
  kNULL           ⇐ 0        # NULL, used for no key pressed
  # Alphanumeric keys
  kAPOSTROPHE    ⇐ 39       # '
  kCOMMA         ⇐ 44       # ,
  kMINUS         ⇐ 45       # -
  kPERIOD        ⇐ 46       # .
  kSLASH         ⇐ 47       # /
  kZERO          ⇐ 48       # 0
  kONE           ⇐ 49       # 1
  kTWO           ⇐ 50       # 2
  kTHREE         ⇐ 51       # 3
  kFOUR          ⇐ 52       # 4
  kFIVE          ⇐ 53       # 5
  kSIX           ⇐ 54       # 6
  kSEVEN         ⇐ 55       # 7
  kEIGHT         ⇐ 56       # 8
  kNINE          ⇐ 57       # 9
  kSEMICOLON     ⇐ 59       # ;
  kEQUAL         ⇐ 61       # =
  kA             ⇐ 65       # A | a
  kB             ⇐ 66       # B | b
  kC             ⇐ 67       # C | c
  kD             ⇐ 68       # D | d
  kE             ⇐ 69       # E | e
  kF             ⇐ 70       # F | f
  kG             ⇐ 71       # G | g
  kH             ⇐ 72       # H | h
  kI             ⇐ 73       # I | i
  kJ             ⇐ 74       # J | j
  kK             ⇐ 75       # K | k
  kL             ⇐ 76       # L | l
  kM             ⇐ 77       # M | m
  kN             ⇐ 78       # N | n
  kO             ⇐ 79       # O | o
  kP             ⇐ 80       # P | p
  kQ             ⇐ 81       # Q | q
  kR             ⇐ 82       # R | r
  kS             ⇐ 83       # S | s
  kT             ⇐ 84       # T | t
  kU             ⇐ 85       # U | u
  kV             ⇐ 86       # V | v
  kW             ⇐ 87       # W | w
  kX             ⇐ 88       # X | x
  kY             ⇐ 89       # Y | y
  kZ             ⇐ 90       # Z | z
  kLEFT_BRACKET  ⇐ 91       # [
  kBACKSLASH     ⇐ 92       # '\'
  kRIGHT_BRACKET ⇐ 93       # ]
  kGRAVE         ⇐ 96       # `
  # Function keys
  kSPACE         ⇐ 32       # Space
  kESCAPE        ⇐ 256      # Esc
  kENTER         ⇐ 257      # Enter
  kTAB           ⇐ 258      # Tab
  kBACKSPACE     ⇐ 259      # Backspace
  kINSERT        ⇐ 260      # Ins
  kDELETE        ⇐ 261      # Del
  kRIGHT         ⇐ 262      # Cursor right
  kLEFT          ⇐ 263      # Cursor left
  kDOWN          ⇐ 264      # Cursor down
  kUP            ⇐ 265      # Cursor up
  kPAGE_UP       ⇐ 266      # Page up
  kPAGE_DOWN     ⇐ 267      # Page down
  kHOME          ⇐ 268      # Home
  kEND           ⇐ 269      # End
  kCAPS_LOCK     ⇐ 280      # Caps lock
  kSCROLL_LOCK   ⇐ 281      # Scroll down
  kNUM_LOCK      ⇐ 282      # Num lock
  kPRINT_SCREEN  ⇐ 283      # Print screen
  kPAUSE         ⇐ 284      # Pause
  kF1            ⇐ 290      # F1
  kF2            ⇐ 291      # F2
  kF3            ⇐ 292      # F3
  kF4            ⇐ 293      # F4
  kF5            ⇐ 294      # F5
  kF6            ⇐ 295      # F6
  kF7            ⇐ 296      # F7
  kF8            ⇐ 297      # F8
  kF9            ⇐ 298      # F9
  kF10           ⇐ 299      # F10
  kF11           ⇐ 300      # F11
  kF12           ⇐ 301      # F12
  kLEFT_SHIFT    ⇐ 340      # Shift left
  kLEFT_CONTROL  ⇐ 341      # Control left
  kLEFT_ALT      ⇐ 342      # Alt left
  kLEFT_SUPER    ⇐ 343      # Super left
  kRIGHT_SHIFT   ⇐ 344      # Shift right
  kRIGHT_CONTROL ⇐ 345      # Control right
  kRIGHT_ALT     ⇐ 346      # Alt right
  kRIGHT_SUPER   ⇐ 347      # Super right
  kKB_MENU       ⇐ 348      # KB menu
  # Keypad keys
  kKP_0          ⇐ 320      # Keypad 0
  kKP_1          ⇐ 321      # Keypad 1
  kKP_2          ⇐ 322      # Keypad 2
  kKP_3          ⇐ 323      # Keypad 3
  kKP_4          ⇐ 324      # Keypad 4
  kKP_5          ⇐ 325      # Keypad 5
  kKP_6          ⇐ 326      # Keypad 6
  kKP_7          ⇐ 327      # Keypad 7
  kKP_8          ⇐ 328      # Keypad 8
  kKP_9          ⇐ 329      # Keypad 9
  kKP_DECIMAL    ⇐ 330      # Keypad .
  kKP_DIVIDE     ⇐ 331      # Keypad /
  kKP_MULTIPLY   ⇐ 332      # Keypad *
  kKP_SUBTRACT   ⇐ 333      # Keypad -
  kKP_ADD        ⇐ 334      # Keypad +
  kKP_ENTER      ⇐ 335      # Keypad Enter
  kKP_EQUAL      ⇐ 336      # Keypad =
  kBACK          ⇐ 4        # Android back button
  kMENU          ⇐ 82       # Android menu button
  kVOLUME_UP     ⇐ 24       # Android volume up button
  kVOLUME_DOWN   ⇐ 25       # Android volume down button
}

drawCopy ← draw