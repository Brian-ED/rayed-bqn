## Conventions:
# if position is an argument, it's always 𝕩.
# if color is an argument, it's always 𝕗.
# if function has no intended output, output 𝕩, it makes chaining look nicer.

isLinux ← ¬⊑•SH⎊1 "lsb_release"‿"-i"

⟨draw, image, texture, monitor, window, mouse
 font, color, key, _bitwise, rayffi, NeedsWindow⟩⇐

rayFFI ← •Import "rayffi.bqn"
IsInt ← {𝕩⊣(⌈⟜=𝕩)!˜" has to be int"∾˜𝕨⊣"𝕩"}

pointer ⇐ {
  MovePtr8 ⇐ {b←256⋆↕8 ⋄ -⟜(256×≥⟜128) 256|⌊÷⟜b 𝕨+´b×256|𝕩}
  ⟨readI8
   make⟩ ⇐ {𝕊:⟨
    @•FFI""‿"bqn_readI8Arr"‿">a"‿("𝕨>"∾rayffi.ptr)    # write to ptr
    @•FFI"a"‿"bqn_makeI8Vec"‿"𝕨>u64"‿(">"∾rayffi.ptr) # materialize
  ⟩}⍟isLinux@‿@
}
_bitwise ← {
  _into ← {𝕗_𝕣⁼𝕩: 𝕗⊸×⊸+˜´𝕩; 𝕗|⌊∘÷⟜𝕗⍟(↕1+·⌊𝕗⋆⁼1⌈⊢)𝕩}
  𝕗{_𝕣:(𝔽´⌈○≠↑¨⋈)⌾(2 _into)}
}
NeedsWindow ← {window.isOpen?𝕩;!"Expected window to be open"}

image ← {
  # TODO: remember to check if file exists before running.
  Load   ⇐ {𝕊strPath   : NeedsWindow@ ⋄ rayFFI.LoadImage𝕩∾@} # ⊑ is used because LoadImage outputs image‿strPath for unknown reasons.
  Unload ⇐ {𝕊image     : NeedsWindow@ ⋄ @⊣rayFFI.UnloadImage𝕩}
  _with  ⇐ {𝔽_𝕣 strPath: NeedsWindow@ ⋄ Unload 𝔽 Load𝕩}

  New ⇐ {
    NeedsWindow@
    l pointer.ReadI8˜ptr←rayffi.MemAlloc≠l←⥊𝕩
    ptr<⊸∾(¯1↓≢𝕩)∾1∾pixelFormat.uncompressed_r8g8b8a8
  }⍟isLinux
}
texture ← {
  # TODO: remember to check if file exists before running.
  Load      ⇐ {𝕊strPath: NeedsWindow@ ⋄   rayFFI.LoadTexture𝕩∾@} # Load texture from file into GPU memory (VRAM)
  Unload    ⇐ {𝕊texture: NeedsWindow@ ⋄ @⊣rayFFI.UnloadTexture𝕩}
  #FromImage ⇐ {𝕊image: 
  #}
  
  #_with ⇐ {𝔽_𝕣 strPath: NeedsWindow@
  #  (Unload⊢𝔽⟜𝕩)Load⚇1 𝕘
  #}
}
mouse ← {
  GetPos     ⇐ rayFFI.GetMousePosition⟨⟩⊣NeedsWindow
  WheelMoved ⇐ rayFFI.GetMouseWheelMove⟨⟩⊣NeedsWindow
  button ⇐ {
    left‿right‿middle‿side‿extra‿forward‿back ⇐ ↕7
  }
  cursor ⇐ { # Mouse cursor
    default       ⇐ 0   # Default pointer shape                                        
    arrow         ⇐ 1   # Arrow shape                                                  
    ibeam         ⇐ 2   # Text writing cursor shape                                    
    crosshair     ⇐ 3   # Cross shape                                                  
    pointing_hand ⇐ 4   # Pointing hand cursor                                         
    resize_ew     ⇐ 5   # Horizontal resize/move arrow shape                           
    resize_ns     ⇐ 6   # Vertical resize/move arrow shape                             
    resize_nwse   ⇐ 7   # Top-left to bottom-right diagonal resize/move arrow shape    
    resize_nesw   ⇐ 8   # The top-right to bottom-left diagonal resize/move arrow shape
    resize_all    ⇐ 9   # The omnidirectional resize/move cursor shape                 
    not_allowed   ⇐ 10  # The operation-not-allowed shape                              
  }
}
monitor ← {
  ⟨Selected ⋄ Count
   RefreshRate ⋄ Size
   Sizemm ⋄ Name⟩⇐
  Selected    ← rayFFI.GetCurrentMonitor∘⟨⟩
  Count       ← rayFFI.GetMonitorCount∘⟨⟩
  RefreshRate ← rayFFI.GetMonitorRefreshRate
  Size        ← rayFFI.GetMonitorWidth ∾ rayFFI.GetMonitorHeight
  Sizemm      ← rayFFI.GetMonitorPhysicalWidth ∾ rayFFI.GetMonitorPhysicalHeight
  Name        ← rayFFI.GetMonitorName
  notAMonitorErr ← "Invalid monitor 𝕩, can only be @ for currently selected monitor or a monitor number; ( 𝕩∊↕monitor.Count@ ) v ( 𝕩≡@ )"
  AddMonitorCheck ← {𝕏@⊸≢◶Selected‿{𝕩⊣notAMonitorErr!⊑𝕩∊↕Count@}}
  ⟨RefreshRate, Size, Sizemm, Name
  ⟩AddMonitorCheck¨↩
  ⟨Selected ⋄ Count ⋄ RefreshRate ⋄ Size
   Sizemm ⋄ Name⟩ {𝕏⊣NeedsWindow}¨↩
}

window ← {
  ⟨_openAs ⋄ SetIcon ⋄ fps ⋄ GetSize
   ShouldClose ⋄ isOpen ⋄ Open ⋄ Close⟩⇐
  isOpen ← 0
  fps ← {
    Get ⇐ rayFFI.GetFPS⟨⟩⊣NeedsWindow
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
  ShouldClose ← rayFFI.WindowShouldClose⟨⟩⊣NeedsWindow
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
  configFlags ⇐{
    fLAG_VSYNC_HINT               ⇐ 64     # Set to try enabling V-Sync on GPU
    fLAG_FULLSCREEN_MODE          ⇐ 2      # Set to run program in fullscreen
    fLAG_WINDOW_RESIZABLE         ⇐ 4      # Set to allow resizable window
    fLAG_WINDOW_UNDECORATED       ⇐ 8      # Set to disable window decoration (frame and buttons)
    fLAG_WINDOW_HIDDEN            ⇐ 128    # Set to hide window
    fLAG_WINDOW_MINIMIZED         ⇐ 512    # Set to minimize window (iconify)
    fLAG_WINDOW_MAXIMIZED         ⇐ 1024   # Set to maximize window (expanded to monitor)
    fLAG_WINDOW_UNFOCUSED         ⇐ 2048   # Set to window non focused
    fLAG_WINDOW_TOPMOST           ⇐ 4096   # Set to window always on top
    fLAG_WINDOW_ALWAYS_RUN        ⇐ 256    # Set to allow windows running while minimized
    fLAG_WINDOW_TRANSPARENT       ⇐ 16     # Set to allow transparent framebuffer
    fLAG_WINDOW_HIGHDPI           ⇐ 8192   # Set to support HighDPI
    fLAG_WINDOW_MOUSE_PASSTHROUGH ⇐ 16384  # Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    fLAG_MSAA_4X_HINT             ⇐ 32     # Set to try enabling MSAA 4X
    fLAG_INTERLACED_HINT          ⇐ 65536  # Set to try enabling interlaced video format (for V3D)
  }
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
    "Circle only accepts ints as args"!(∧´⌈⊸=∨∞=|)n←𝕩∾𝕨∾𝕗
    "Incorrect amount of arguments"!7=≠n
    rayFFI.DrawCircle ⌊𝕩∾𝕨‿𝕗
  }
  _Rectangle ← {width‿height ⟨r,g,b,a⟩_𝕣 posX‿posY :
    NeedsWindow@
    "Rectangle only accepts ints as args"!(∧´⌈⊸=∨∞=|)𝕩∾𝕨∾𝕗
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
    ((∧´⌈⊸=∨∞=|)𝕩)!˜"Ellipse only accepts ints as args"
    (∧´𝕗∊↕256)!˜"𝕗 _Ellipse: 𝕗 (color) only accepts ints in the range 0-255 inclusive"
    rayffi.DrawEllipse (𝕩∾𝕨)∾<𝕗
  }
  _EllipseOutline ← {width‿height ⟨r,g,b,a⟩_𝕣 posX‿posY :
    NeedsWindow@
    ((∧´⌈⊸=∨∞=|)𝕩∾𝕗)!˜"EllipseOutline only accepts ints as args"
    (∧´𝕗∊↕256)!˜"𝕗 _Ellipse: 𝕗 (color) only accepts ints in the range 0-255 inclusive"
    rayffi.DrawEllipseLines (𝕩∾𝕨)∾<𝕗
  }
}
font ← { # TODO: This is untested, please test this later
  Load ⇐ rayFFI.LoadFontEx{
    𝕊fontFilePath:
      ⟨𝕩∾@, 40, ≍@, 0⟩; # fontSize fontChars glyphCount # use NULL for fontChars and 0 for glyphCount to load the default character set
    charactersAllowed 𝕊 fontFilePath:
      ⟨𝕩∾@, 40, 𝕨-@, ≠𝕨⟩
  }⟜NeedsWindow
  LoadBQN ⇐ {𝕊fontSize: # Sorce of font and chars: https://dzaima.github.io/BQN386/
    NeedsWindow@
    chars ← •FChars "src/chars.txt"
    rayFFI.LoadFontEx ⟨"BQN386.ttf"∾@, 𝕩, chars-@, ≠chars⟩
  }
}

color ← {
  FromHex ⇐ 16⊸×⊸+˜´∘⌽˘·(∾"0A"+⟜↕¨10‿6)⊸⊐˘∘‿2⥊⊢
  exact⇐{
    white ⇐ 4⥊255 ⋄ black ⇐ ¯4↑255
    [red ‿green  ‿blue
     cyan‿magenta‿yellow] ⇐ 255×1∾˜¨⍉(-↕3)⌽⌜⋈⟜¬3↑1
  }
  beige       ⇐ 211‿176‿131‿255
  black       ⇐ 0  ‿0  ‿0  ‿255
  transparent ⇐ 0  ‿0  ‿0  ‿0
  blue        ⇐ 0  ‿121‿241‿255
  brown       ⇐ 127‿106‿79 ‿255
  cyan        ⇐ 0  ‿255‿255‿255
  darkGray    ⇐ 80 ‿80 ‿80 ‿255
  darkblue    ⇐ 0  ‿82 ‿172‿255
  darkbrown   ⇐ 76 ‿63 ‿47 ‿255
  darkgreen   ⇐ 0  ‿117‿44 ‿255
  darkpurple  ⇐ 112‿31 ‿126‿255
  darkred     ⇐ 139‿0  ‿0  ‿255
  gold        ⇐ 255‿203‿0  ‿255
  gray        ⇐ 130‿130‿130‿255
  green       ⇐ 0  ‿228‿48 ‿255
  lavender    ⇐ 230‿230‿250‿255
  lightGray   ⇐ 200‿200‿200‿255
  lightblue   ⇐ 173‿216‿230‿255
  lightgreen  ⇐ 144‿238‿144‿255
  lightred    ⇐ 255‿102‿102‿255
  lime        ⇐ 0  ‿158‿47 ‿255
  magenta     ⇐ 255‿  0‿255‿255
  maroon      ⇐ 190‿33 ‿55 ‿255
  navy        ⇐ 0  ‿0  ‿128‿255
  orange      ⇐ 255‿161‿0  ‿255
  pink        ⇐ 255‿109‿194‿255
  purple      ⇐ 200‿122‿255‿255
  raywhite    ⇐ 245‿245‿245‿255
  red         ⇐ 230‿41 ‿55 ‿255
  silver      ⇐ 192‿192‿192‿255
  skyblue     ⇐ 102‿191‿255‿255
  teal        ⇐ 0  ‿128‿128‿255
  violet      ⇐ 135‿60 ‿190‿255
  white       ⇐ 255‿255‿255‿255
  yellow      ⇐ 253‿249‿0  ‿255
}
key ← {
  IsPressed ⇐ {𝕊 key:
    rayFFI.IsKeyPressed @-˜⍟<𝕩
  }⚇0⊣NeedsWindow

  # These funcs are queues, call multiple times if needed. Returns 0 when the queue is empty
  PressedKey ⇐ {𝕤  # Get key pressed (keycode)
    rayFFI.GetKeyPressed⟨⟩
  }⚇0⊣NeedsWindow
  PressedChar ⇐ {𝕤
    rayffi.GetcharPressed⟨⟩
  }⚇0⊣NeedsWindow
  # Keyboard keys (US keyboard layout)
  # NOTE: Use GetKeyPressed() to allow redefining
  # required keys for alternative layouts

  # consider switching to `letter-@` when possible.

  # vars           Keycodes   Keys
  null          ⇐ 0        # NULL, used for no key pressed
  # Alphanumeric keys
  apostrophe    ⇐ 39       # '
  comma         ⇐ 44       # ,
  minus         ⇐ 45       # -
  period        ⇐ 46       # .
  slash         ⇐ 47       # /
  zero          ⇐ 48       # 0
  one           ⇐ 49       # 1
  two           ⇐ 50       # 2
  three         ⇐ 51       # 3
  four          ⇐ 52       # 4
  five          ⇐ 53       # 5
  six           ⇐ 54       # 6
  seven         ⇐ 55       # 7
  eight         ⇐ 56       # 8
  nine          ⇐ 57       # 9
  semicolon     ⇐ 59       # ;
  equal         ⇐ 61       # =
  a             ⇐ 65       # A | a
  b             ⇐ 66       # B | b
  c             ⇐ 67       # C | c
  d             ⇐ 68       # D | d
  e             ⇐ 69       # E | e
  f             ⇐ 70       # F | f
  g             ⇐ 71       # G | g
  h             ⇐ 72       # H | h
  i             ⇐ 73       # I | i
  j             ⇐ 74       # J | j
  k             ⇐ 75       # K | k
  l             ⇐ 76       # L | l
  m             ⇐ 77       # M | m
  n             ⇐ 78       # N | n
  o             ⇐ 79       # O | o
  p             ⇐ 80       # P | p
  q             ⇐ 81       # Q | q
  r             ⇐ 82       # R | r
  s             ⇐ 83       # S | s
  t             ⇐ 84       # T | t
  u             ⇐ 85       # U | u
  v             ⇐ 86       # V | v
  w             ⇐ 87       # W | w
  x             ⇐ 88       # X | x
  y             ⇐ 89       # Y | y
  z             ⇐ 90       # Z | z
  left_bracket  ⇐ 91       # [
  backslash     ⇐ 92       # '\'
  right_bracket ⇐ 93       # ]
  grave         ⇐ 96       # `
  # Function keys
  space         ⇐ 32       # Space
  escape        ⇐ 256      # Esc
  enter         ⇐ 257      # Enter
  tab           ⇐ 258      # Tab
  backspace     ⇐ 259      # Backspace
  insert        ⇐ 260      # Ins
  delete        ⇐ 261      # Del
  right         ⇐ 262      # Cursor right
  left          ⇐ 263      # Cursor left
  down          ⇐ 264      # Cursor down
  up            ⇐ 265      # Cursor up
  page_up       ⇐ 266      # Page up
  page_down     ⇐ 267      # Page down
  home          ⇐ 268      # Home
  end           ⇐ 269      # End
  caps_lock     ⇐ 280      # Caps lock
  scroll_lock   ⇐ 281      # Scroll down
  num_lock      ⇐ 282      # Num lock
  print_screen  ⇐ 283      # Print screen
  pause         ⇐ 284      # Pause
  f1            ⇐ 290      # F1
  f2            ⇐ 291      # F2
  f3            ⇐ 292      # F3
  f4            ⇐ 293      # F4
  f5            ⇐ 294      # F5
  f6            ⇐ 295      # F6
  f7            ⇐ 296      # F7
  f8            ⇐ 297      # F8
  f9            ⇐ 298      # F9
  f10           ⇐ 299      # F10
  f11           ⇐ 300      # F11
  f12           ⇐ 301      # F12
  left_shift    ⇐ 340      # Shift left
  left_control  ⇐ 341      # Control left
  left_alt      ⇐ 342      # Alt left
  left_super    ⇐ 343      # Super left
  right_shift   ⇐ 344      # Shift right
  right_control ⇐ 345      # Control right
  right_alt     ⇐ 346      # Alt right
  right_super   ⇐ 347      # Super right
  kb_menu       ⇐ 348      # KB menu
  # Keypad keys
  kp_0          ⇐ 320      # Keypad 0
  kp_1          ⇐ 321      # Keypad 1
  kp_2          ⇐ 322      # Keypad 2
  kp_3          ⇐ 323      # Keypad 3
  kp_4          ⇐ 324      # Keypad 4
  kp_5          ⇐ 325      # Keypad 5
  kp_6          ⇐ 326      # Keypad 6
  kp_7          ⇐ 327      # Keypad 7
  kp_8          ⇐ 328      # Keypad 8
  kp_9          ⇐ 329      # Keypad 9
  kp_decimal    ⇐ 330      # Keypad .
  kp_divide     ⇐ 331      # Keypad /
  kp_multiply   ⇐ 332      # Keypad *
  kp_subtract   ⇐ 333      # Keypad -
  kp_add        ⇐ 334      # Keypad +
  kp_enter      ⇐ 335      # Keypad Enter
  kp_equal      ⇐ 336      # Keypad =
  back          ⇐ 4        # Android back button
  menu          ⇐ 82       # Android menu button
  volume_up     ⇐ 24       # Android volume up button
  volume_down   ⇐ 25       # Android volume down button
}

traceLogLevel ⇐ { # Trace log level
  all     ⇐ 0  # Display all logs                                                                   
  trace   ⇐ 1  # Trace logging, intended for internal use only                                      
  debug   ⇐ 2  # Debug logging, used for internal debugging, it should be disabled on release builds
  info    ⇐ 3  # Info logging, used for program execution info                                      
  warning ⇐ 4  # Warning logging, used on recoverable failures                                      
  error   ⇐ 5  # Error logging, used on unrecoverable failures                                      
  fatal   ⇐ 6  # Fatal logging, used to abort program: exit(EXIT_FAILURE)                           
  none    ⇐ 7  # Disable logging                                                                    
}

gamepadButton ⇐ { # Gamepad buttons
  unknown          ⇐ 0   # Unknown button, just for error checking                               
  left_face_up     ⇐ 1   # Gamepad left DPAD up button                                           
  left_face_right  ⇐ 2   # Gamepad left DPAD right button                                        
  left_face_down   ⇐ 3   # Gamepad left DPAD down button                                         
  left_face_left   ⇐ 4   # Gamepad left DPAD left button                                         
  right_face_up    ⇐ 5   # Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)                 
  right_face_right ⇐ 6   # Gamepad right button right (i.e. PS3: Square, Xbox: X)                
  right_face_down  ⇐ 7   # Gamepad right button down (i.e. PS3: Cross, Xbox: A)                  
  right_face_left  ⇐ 8   # Gamepad right button left (i.e. PS3: Circle, Xbox: B)                 
  left_trigger_1   ⇐ 9   # Gamepad top/back trigger left (first), it could be a trailing button  
  left_trigger_2   ⇐ 10  # Gamepad top/back trigger left (second), it could be a trailing button 
  right_trigger_1  ⇐ 11  # Gamepad top/back trigger right (one), it could be a trailing button   
  right_trigger_2  ⇐ 12  # Gamepad top/back trigger right (second), it could be a trailing button
  middle_left      ⇐ 13  # Gamepad center buttons, left one (i.e. PS3: Select)                   
  middle           ⇐ 14  # Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)         
  middle_right     ⇐ 15  # Gamepad center buttons, right one (i.e. PS3: Start)                   
  left_thumb       ⇐ 16  # Gamepad joystick pressed button left                                  
  right_thumb      ⇐ 17  # Gamepad joystick pressed button right                                 
}
gamepadAxis ⇐ { # Gamepad axis
  left_x        ⇐ 0  # Gamepad left stick X axis                          
  left_y        ⇐ 1  # Gamepad left stick Y axis                          
  right_x       ⇐ 2  # Gamepad right stick X axis                         
  right_y       ⇐ 3  # Gamepad right stick Y axis                         
  left_trigger  ⇐ 4  # Gamepad back trigger left, pressure level: [1..-1] 
  right_trigger ⇐ 5  # Gamepad back trigger right, pressure level: [1..-1]
}
materialMapIndex ⇐ { # Material map index
  albedo     ⇐ 0   # Albedo material (same as: MATERIAL_MAP_DIFFUSE)     
  metalness  ⇐ 1   # Metalness material (same as: MATERIAL_MAP_SPECULAR) 
  normal     ⇐ 2   # Normal material                                     
  roughness  ⇐ 3   # Roughness material                                  
  occlusion  ⇐ 4   # Ambient occlusion material                          
  emission   ⇐ 5   # Emission material                                   
  height     ⇐ 6   # Heightmap material                                  
  cubemap    ⇐ 7   # Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)   
  irradiance ⇐ 8   # Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  prefilter  ⇐ 9   # Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP) 
  brdf       ⇐ 10  # Brdf material                                       
}
shaderLocationIndex ⇐ { # Shader location index
  vertex_position   ⇐ 0   # Shader location: vertex attribute: position                                     
  vertex_texcoord01 ⇐ 1   # Shader location: vertex attribute: texcoord01                                   
  vertex_texcoord02 ⇐ 2   # Shader location: vertex attribute: texcoord02                                   
  vertex_normal     ⇐ 3   # Shader location: vertex attribute: normal                                       
  vertex_tangent    ⇐ 4   # Shader location: vertex attribute: tangent                                      
  vertex_color      ⇐ 5   # Shader location: vertex attribute: color                                        
  matrix_mvp        ⇐ 6   # Shader location: matrix uniform: model-view-projection                          
  matrix_view       ⇐ 7   # Shader location: matrix uniform: view (camera transform)                        
  matrix_projection ⇐ 8   # Shader location: matrix uniform: projection                                     
  matrix_model      ⇐ 9   # Shader location: matrix uniform: model (transform)                              
  matrix_normal     ⇐ 10  # Shader location: matrix uniform: normal                                         
  vector_view       ⇐ 11  # Shader location: vector uniform: view                                           
  color_diffuse     ⇐ 12  # Shader location: vector uniform: diffuse color                                  
  color_specular    ⇐ 13  # Shader location: vector uniform: specular color                                 
  color_ambient     ⇐ 14  # Shader location: vector uniform: ambient color                                  
  map_albedo        ⇐ 15  # Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)    
  map_metalness     ⇐ 16  # Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
  map_normal        ⇐ 17  # Shader location: sampler2d texture: normal                                      
  map_roughness     ⇐ 18  # Shader location: sampler2d texture: roughness                                   
  map_occlusion     ⇐ 19  # Shader location: sampler2d texture: occlusion                                   
  map_emission      ⇐ 20  # Shader location: sampler2d texture: emission                                    
  map_height        ⇐ 21  # Shader location: sampler2d texture: height                                      
  map_cubemap       ⇐ 22  # Shader location: samplerCube texture: cubemap                                   
  map_irradiance    ⇐ 23  # Shader location: samplerCube texture: irradiance                                
  map_prefilter     ⇐ 24  # Shader location: samplerCube texture: prefilter                                 
  map_brdf          ⇐ 25  # Shader location: sampler2d texture: brdf                                        
}
shaderUniformDataType ⇐ { # Shader uniform data type
  float     ⇐ 0  # Shader uniform type: float         
  vec2      ⇐ 1  # Shader uniform type: vec2 (2 float)
  vec3      ⇐ 2  # Shader uniform type: vec3 (3 float)
  vec4      ⇐ 3  # Shader uniform type: vec4 (4 float)
  int       ⇐ 4  # Shader uniform type: int           
  ivec2     ⇐ 5  # Shader uniform type: ivec2 (2 int) 
  ivec3     ⇐ 6  # Shader uniform type: ivec3 (3 int) 
  ivec4     ⇐ 7  # Shader uniform type: ivec4 (4 int) 
  sampler2d ⇐ 8  # Shader uniform type: sampler2d     
}
shaderAttributeDataType ⇐ { # Shader attribute data types
  float ⇐ 0  # Shader attribute type: float         
  vec2  ⇐ 1  # Shader attribute type: vec2 (2 float)
  vec3  ⇐ 2  # Shader attribute type: vec3 (3 float)
  vec4  ⇐ 3  # Shader attribute type: vec4 (4 float)
}
pixelFormat ⇐ { # Pixel formats
  uncompressed_grayscale    ⇐ 1   # 8 bit per pixel (no alpha)   
  uncompressed_gray_alpha   ⇐ 2   # 8*2 bpp (2 channels)         
  uncompressed_r5g6b5       ⇐ 3   # 16 bpp                       
  uncompressed_r8g8b8       ⇐ 4   # 24 bpp                       
  uncompressed_r5g5b5a1     ⇐ 5   # 16 bpp (1 bit alpha)         
  uncompressed_r4g4b4a4     ⇐ 6   # 16 bpp (4 bit alpha)         
  uncompressed_r8g8b8a8     ⇐ 7   # 32 bpp                       
  uncompressed_r32          ⇐ 8   # 32 bpp (1 channel - float)   
  uncompressed_r32g32b32    ⇐ 9   # 32*3 bpp (3 channels - float)
  uncompressed_r32g32b32a32 ⇐ 10  # 32*4 bpp (4 channels - float)
  compressed_dxt1_rgb       ⇐ 11  # 4 bpp (no alpha)             
  compressed_dxt1_rgba      ⇐ 12  # 4 bpp (1 bit alpha)          
  compressed_dxt3_rgba      ⇐ 13  # 8 bpp                        
  compressed_dxt5_rgba      ⇐ 14  # 8 bpp                        
  compressed_etc1_rgb       ⇐ 15  # 4 bpp                        
  compressed_etc2_rgb       ⇐ 16  # 4 bpp                        
  compressed_etc2_eac_rgba  ⇐ 17  # 8 bpp                        
  compressed_pvrt_rgb       ⇐ 18  # 4 bpp                        
  compressed_pvrt_rgba      ⇐ 19  # 4 bpp                        
  compressed_astc_4x4_rgba  ⇐ 20  # 8 bpp                        
  compressed_astc_8x8_rgba  ⇐ 21  # 2 bpp                        
}
textureFilter ⇐ { # Texture parameters: filter mode
  point           ⇐ 0  # No filter, just pixel approximation      
  bilinear        ⇐ 1  # Linear filtering                         
  trilinear       ⇐ 2  # Trilinear filtering (linear with mipmaps)
  anisotropic_4x  ⇐ 3  # Anisotropic filtering 4x                 
  anisotropic_8x  ⇐ 4  # Anisotropic filtering 8x                 
  anisotropic_16x ⇐ 5  # Anisotropic filtering 16x                
}
textureWrap ⇐ { # Texture parameters: wrap mode
  repeat        ⇐ 0  # Repeats texture in tiled mode                         
  clamp         ⇐ 1  # Clamps texture to edge pixel in tiled mode            
  mirror_repeat ⇐ 2  # Mirrors and repeats the texture in tiled mode         
  mirror_clamp  ⇐ 3  # Mirrors and clamps to border the texture in tiled mode
}
cubemapLayout ⇐ { # Cubemap layouts
  auto_detect         ⇐ 0  # Automatically detect layout type                            
  line_vertical       ⇐ 1  # Layout is defined by a vertical line with faces             
  line_horizontal     ⇐ 2  # Layout is defined by a horizontal line with faces           
  cross_three_by_four ⇐ 3  # Layout is defined by a 3x4 cross with cubemap faces         
  cross_four_by_three ⇐ 4  # Layout is defined by a 4x3 cross with cubemap faces         
  panorama            ⇐ 5  # Layout is defined by a panorama image (equirrectangular map)
}
fontType ⇐ { # Font type, defines generation method
  font_default ⇐ 0  # Default font generation, anti-aliased        
  font_bitmap  ⇐ 1  # Bitmap font generation, no anti-aliasing     
  font_sdf     ⇐ 2  # SDF font generation, requires external shader
}
blendMode ⇐ { # Color blending modes (pre-defined)
  alpha             ⇐ 0  # Blend textures considering alpha (default)                                                      
  additive          ⇐ 1  # Blend textures adding colors                                                                    
  multiplied        ⇐ 2  # Blend textures multiplying colors                                                               
  add_colors        ⇐ 3  # Blend textures adding colors (alternative)                                                      
  subtract_colors   ⇐ 4  # Blend textures subtracting colors (alternative)                                                 
  alpha_premultiply ⇐ 5  # Blend premultiplied textures considering alpha                                                  
  custom            ⇐ 6  # Blend textures using custom src/dst factors (use rlSetBlendFactors())                           
  custom_separate   ⇐ 7  # Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
}
gesture ⇐ { # Gesture
  none        ⇐ 0    # No gesture         
  tap         ⇐ 1    # Tap gesture        
  doubletap   ⇐ 2    # Double tap gesture 
  hold        ⇐ 4    # Hold gesture       
  drag        ⇐ 8    # Drag gesture       
  swipe_right ⇐ 16   # Swipe right gesture
  swipe_left  ⇐ 32   # Swipe left gesture 
  swipe_up    ⇐ 64   # Swipe up gesture   
  swipe_down  ⇐ 128  # Swipe down gesture 
  pinch_in    ⇐ 256  # Pinch in gesture   
  pinch_out   ⇐ 512  # Pinch out gesture  
}
cameramode ⇐ { # Camera system modes
  custom       ⇐ 0  # Custom camera      
  free         ⇐ 1  # Free camera        
  orbital      ⇐ 2  # Orbital camera     
  first_person ⇐ 3  # First person camera
  third_person ⇐ 4  # Third person camera
}
cameraProjection ⇐ { # Camera projection
  perspective  ⇐ 0  # Perspective projection 
  orthographic ⇐ 1  # Orthographic projection
}
nPatchLayout ⇐ { # N-patch layout
  nine_patch             ⇐ 0  # Npatch layout: 3x3 tiles
  three_patch_vertical   ⇐ 1  # Npatch layout: 1x3 tiles
  three_patch_horizontal ⇐ 2  # Npatch layout: 3x1 tiles
}