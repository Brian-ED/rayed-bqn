## Conventions:
# One big goal of this lib is to eliminate as many bugs of raylib as possible,
# for example, opening the window twice is impossible because it is not intended in raylib, and causes many bugs.

# x and y as variables (also x1 y1, x2 y2 etc) are always positions

# -------
# Exports
⟨draw, texture, monitor, window, mouse
 font, key, utils, clipboard⟩⇐

⟨
  traceLogLevel
  gamepadButton, gamepadAxis
  materialMapIndex
  shaderLocationIndex, shaderUniformDataType, shaderAttributeDataType
  pixelFormat
  textureFilter, textureWrap
  cubemapLayout
  fontType
  blendMode
  gesture
  cameramode, cameraProjection
  nPatchLayout
⟩ ⇐ •Import "src/indexNamespaces.bqn"

⟨bqnLibsPath⟩ ← •Import "src/loadConfig.bqn"
rayFFI  ⇐ •Import "rayffi.bqn"
global  ← •Import "src/global.bqn"
color   ⇐ •Import "src/colors.bqn"
raymath ⇐ •Import "src/raymath.bqn"
image   ⇐ •Import "src/image.bqn"
# -------

# TODO: These need to be more accurate
isLinux   ← •BQN⎊0"1∘•SH⎊0 ""lsb_release""‿""-i"""
isWindows ← ¬isLinux

# Utils:
FileAt      ← "/cygdrive/c"("C:"∾≠⊸↓)⍟(⊣≡≠⊸↑)•file.At                # remade •FileAt to work for cygwin
NeedsWindow ← {window.isOpen?𝕩;!"Expected window to be open"}
global.SetNeedsWindow NeedsWindow

# Defaults
rayffi.SetTraceLogLevel traceLogLevel.warning # makes logs not output INFO: logs to stdOut
rayffi.SetConfigFlags 4 #SetConfigFlags is before InitWindow, SetWindowState is after

texture ← {
  Load      ⇐ {𝕊strPath: # Load texture from file into GPU memory (VRAM)
    NeedsWindow@
    !•file.Exists 𝕩
    rayFFI.LoadTexture 𝕩
  }
  Unload    ⇐ {𝕊texture: NeedsWindow@ ⋄ @⊣rayFFI.UnloadTexture𝕩}
  _with ⇐ {𝔽_𝕣 strPath : (Unload⊢𝔽)Load𝕩}
  _WithImage ⇐ {
    NeedsWindow@
    (Unload⊢𝔽)rayffi.LoadTextureFromImage image._WithRayImg 𝕩
  }
}
monitor ← {
  ⟨Selected ⋄ Count
   RefreshRate ⋄ Size
   Sizemm ⋄ Name⟩⇐
  Selected    ← rayFFI.GetCurrentMonitor∘⟨⟩NeedsWindow
  Count       ← rayFFI.GetMonitorCount∘⟨⟩NeedsWindow

  notAMonitorErr ← "Invalid monitor 𝕩, can only be @ for currently selected monitor or a monitor number; ( 𝕩∊↕monitor.Count@ ) v ( 𝕩≡@ )"
  M ← @⊸≢◶Selected‿{𝕩⊣notAMonitorErr!⊑𝕩∊↕Count@} # No need for NeedsWindow because Selected and Count need it so error still works

  RefreshRate ← rayFFI.GetMonitorRefreshRate M
  Size        ← (rayFFI.GetMonitorWidth ∾ rayFFI.GetMonitorHeight)M
  Sizemm      ← (rayFFI.GetMonitorPhysicalWidth ∾ rayFFI.GetMonitorPhysicalHeight)M
  Name        ← rayFFI.GetMonitorName M
}

window ← {
  ⟨
   isOpen ⋄ _openAs ⋄ SetIcon ⋄ fps ⋄ GetSize
   ShouldClose ⋄ Needed ⋄ SetPos
  ⟩⇐
  Needed ← NeedsWindow
  isOpen ← 0
  SetPos ← {rayFFI.SetWindowPosition NeedsWindow𝕩}
  Open ← {𝕨𝕊 title: scale←𝕨⊣1
    (¬isOpen)!˜"The window cannot be opened twice"
    (scale≡0⌈1⌊scale)!˜"Scale can only be between 0 and 1"
    ((⟨⟩⊸≡∨⟨2⟩⊸≡)≢scale)!˜"Scale can be a scaler (⟨⟩≢≢𝕨) or length two list (⟨2⟩≡≢𝕨)"
    rayFFI.InitWindow 0‿0‿𝕩
    isOpen↩1
    rayffi.SetExitKey 0 # 0 means no key, essentially removing esc key closing programs implicitly
    rayFFI.SetWindowPosition⍟isWindows 0‿42 # 42 here is the window header on windows only
    rayFFI.SetWindowSize monitor.Size∘@⊸× scale
    fps.Set monitor.RefreshRate@
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
  _openAs ← {𝕨 App _𝕣 title: scale←2⥊𝕨⊣1
    scale Open𝕩
    Close⊸⊢𝔽@
  }
  # TODO: Needs to test input for image
  SetIcon ← {𝕊image: NeedsWindow@ ⋄ rayFFI.SetWindowIcon𝕩}

  fps ← {
    Get ⇐ rayFFI.GetFPS⟨⟩⊣NeedsWindow
    Set ⇐ {
      (𝕩=⌈0⌈𝕩)!˜"FPS has to be a positive int"
      𝕩⊣rayFFI.SetTargetFPS𝕩
    }⊣NeedsWindow
  }
  # NOTE: Every bit registers one state (use it with bit masks)
  # By default all flags are set to 0
  configFlags ⇐ {
    fullscreen_mode          ⇐ 2⋆1  # Set to run program in fullscreen
    window_resizable         ⇐ 2⋆2  # Set to allow resizable window
    window_undecorated       ⇐ 2⋆3  # Set to disable window decoration (frame and buttons)
    window_transparent       ⇐ 2⋆4  # Set to allow transparent framebuffer
    msaa_4x_hint             ⇐ 2⋆5  # Set to try enabling MSAA 4X
    vsync_hint               ⇐ 2⋆6  # Set to try enabling V-Sync on GPU
    window_hidden            ⇐ 2⋆7  # Set to hide window
    window_always_run        ⇐ 2⋆8  # Set to allow windows running while minimized
    window_minimized         ⇐ 2⋆9  # Set to minimize window (iconify)
    window_maximized         ⇐ 2⋆10 # Set to maximize window (expanded to monitor)
    window_unfocused         ⇐ 2⋆11 # Set to window non focused
    window_topmost           ⇐ 2⋆12 # Set to window always on top
    window_highdpi           ⇐ 2⋆13 # Set to support HighDPI
    window_mouse_passthrough ⇐ 2⋆14 # Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    interlaced_hint          ⇐ 2⋆16 # Set to try enabling interlaced video format (for V3D)
  }
}
draw ← {
  ⟨
   _withCanvas_ ⋄ Rectangle ⋄ Text ⋄ Line
   Texture ⋄ Ellipse ⋄ EllipseOutline ⋄ _in3D
   advanced
  ⟩⇐
  _in3D ← {𝕨 Drawing3D _𝕣 camera:
    NeedsWindow@          # pos  target up   FOV Camera projection type
    !𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iii"‿"iii"‿"iii"‿'i'‿'i'
    rayffi.BeginMode3D 𝕩
    rayffi.EndMode3D∘⟨⟩⊸⊢𝔽𝕩
  }
  Background ← {𝕊r‿g‿b‿a:
    NeedsWindow@
    (∧´𝕩∊↕256)!˜"ClearBackground only accepts ints in the range 0-255 inclusive"
    !𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"
    rayFFI.ClearBackground 𝕩
  }
  Start ← ⊢⊣rayFFI.BeginDrawing∘⟨⟩⊣NeedsWindow
  End   ← ⊢⊣rayFFI.EndDrawing  ∘⟨⟩⊣NeedsWindow
  _withCanvas_ ← {𝕨DrawingFunc _𝕣_ Func_Returning_A_Color𝕩:
    Start@
    Background 𝕨𝔾𝕩
    ⊣⟜End𝕨𝔽𝕩
  }
  Text ← {𝕨𝕊⟨posX‿posY⋄text⟩:
    NeedsWindow@
    t←⟨r‿g‿b‿a⋄font⋄fontSize⋄spacing⟩ ⇐ ∾⟜1⍟(3≡≠)𝕨
    !t‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿("iii"∾5‿8‿8⥊¨'i')‿'i'‿'i'⋄"ii"⋈'c'¨text⟩   # TODO: why is there an each in the type here? at ...⥊¨'i'
    rayFFI.DrawTextCodepoints ⟨font⋄text-@⋄≠text⋄posX‿posY⋄fontSize⋄spacing⋄r‿g‿b‿a⟩
  }
  Line ← {𝕨𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    t←{
      𝕊r‿g‿b‿a:1⋈˜𝕩;
      𝕊⟨r‿g‿b‿a⋄thickness⟩:𝕩
    }𝕨
    !t‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿'i'⋄2‿2⥊'i'⟩
    rayFFI.DrawLineEx(<˘𝕩)∾⌽t
  }
  Texture ← {⟨r‿g‿b‿a⋄texture⋄scale⋄rotation⟩ 𝕊 x‿y:
    NeedsWindow@
    !𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿"iiiii"‿'i'‿'i'⋄"ii"⟩
    rayFFI.DrawTextureEx ⟨texture⋄x‿y⋄rotation⋄scale⋄r‿g‿b‿a⟩ # texture‿v2‿f‿f‿color # texture position rotation scale tint
  }
  Rectangle ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    "Rectangle only accepts ints as args"!(∧´⌈⊸=∨∞=|)𝕨∾⥊𝕩
    !𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"⋈2‿2⥊'i'
    rayFFI.DrawRectangle 𝕨∾⟜<˜(⊣∾-˜)˝∧˘⌾⍉𝕩
  }
  Ellipse ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    ((∧´⌈⊸=∨∞=|)𝕨∾⥊𝕩)!˜"Ellipse only accepts ints as args"
    (∧´𝕨∊↕256)!˜"𝕗 (color) only accepts ints in the range 0-255 inclusive"
    rayffi.DrawEllipse 𝕨∾⟜<˜(⌈∾⊢-⊏∘𝕩)(+˝÷≠)𝕩
  }
  EllipseOutline ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    rayffi.DrawEllipseLines 𝕨∾⟜<˜(⌈∾⊢-⊏∘𝕩)(+˝÷≠)𝕩                # i‿i‿f‿f‿color # centerX centerY radiusH radiusV
  }

  # These aren't recommended because they are useless if you use _withCanvas_.
  # They also don't behave well if ran in the wrong order,
  # you only want to run them in the "start, background, end" sequence.
  advanced ⇐ {Start‿Background‿End⇐Start‿Background‿End}
}
font ← {
  ⟨ Load ⋄ LoadBQN ⋄ LoadRaylib ⋄ Unload ⟩⇐
  IsFont ← {
    (𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iii"∾"iiiii"<⊸∾⋈˜8⥊'i')!˜"Expected a valid font"   # Type info can be found in rayffi.bqn https://github.com/Brian-ED/rayed-bqn/blob/1ccf239c9167307c36bcd882c7f1031640f67032/rayffi.bqn#L81
    𝕩⊣(¬∨´∧´¨0=¯2↑𝕩)!˜"Invalid font. font has null pointers, making it invalid"
  }
  glyphInfo←{value‿offsetX‿offsetY‿advanceX‿image⇐↕5}             # The namespace is for eliminating magic-numbers

  Unload ← rayFFI.UnloadFont∘IsFont NeedsWindow

  Load ← {
    NeedsWindow@
    F←{
      𝕊size‿filePath:
        ⟨filePath⋄size⋄≍@⋄0⟩
    ;                                           # fontSize fontChars glyphCount # use NULL for fontChars and 0 for glyphCount to load the default character set
      charactersAllowed 𝕊 size‿filePath:
        ⟨filePath⋄size⋄𝕨-@⋄≠𝕨⟩
    }
    fontArgs←𝕨F𝕩
    IsFont rayFFI.LoadFontEx fontArgs
  }

  LoadBQN ← {𝕊fontSize:                                           # Sorce of font and chars: https://dzaima.github.io/BQN386/
    NeedsWindow@
    chars ← •FChars "src/chars.txt"
    rayFFI.LoadFontEx⟨FileAt"src/BQN386.ttf"⋄100⍟(@⊸≡)𝕩⋄chars-@⋄≠chars⟩
  }
  LoadRaylib ← rayffi.GetFontDefault∘⟨⟩
}
clipboard ← {
  ⟨ToBytes⟩ ← •Import bqnLibsPath∾"/strings.bqn"
  Get ⇐ rayffi.MakeUTF8 rayffi.StrLen⊸⋈∘rayffi.GetClipboardText∘⟨⟩
  Set ⇐ rayffi.SetClipboardText ToBytes⊣NeedsWindow
}
utils ← {
  ⟨_FromCenter⋄_bitwise⟩⇐
  _FromCenter ← {c←(+˝÷≠)˘𝕩⋄𝔽⌾(-⟜c)𝕩}                             # example of 𝕩: [x1‿x2‿x3⋄y1‿y2‿y3⋄z1‿z2‿z3]
  _bitwise ← {2⊸×⊸+˜´𝕨(0⊘1⊣◶⟨𝔽∘⊑⊢⋄𝔽´⊢⟩⌈○≠↑¨⋈)○(2|⌊∘÷⟜2⍟(↕1+·⌊2⋆⁼1⌈⊢))𝕩}
}
mouse ← {
  GetPos     ⇐ rayFFI.GetMousePosition ⟨⟩⊣NeedsWindow
  WheelMoved ⇐ rayFFI.GetMouseWheelMove⟨⟩⊣NeedsWindow
  IsButtonDown ⇐ {
    NeedsWindow@
    "Mouse button doesn't exist. (𝕩∊↕7)"!∨´⥊𝕩∊↕buttons
    rayFFI.IsMouseButtonDown⚇0 𝕩
  }
  buttons ← 7
  button ⇐ {
    left‿right‿middle‿side‿extra‿forward‿back ⇐ ↕buttons
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
key ← {
  IsPressed ⇐ {𝕊 key:
    rayFFI.IsKeyPressed @-˜⍟<𝕩
  }⚇0⊣NeedsWindow
  IsDown ⇐ {
    rayffi.IsKeyDown @-˜⍟<𝕩
  }⚇0⊣NeedsWindow

  PressedKey ⇐ {𝕤                                                 # Get key pressed as keycode
    rayFFI.GetKeyPressed⟨⟩
  }⊣NeedsWindow
  PressedChar ⇐ {𝕤
    @+rayffi.GetcharPressed⟨⟩
  }⊣NeedsWindow

  # Keyboard keys (US keyboard layout)
  # NOTE: Use GetKeyPressed() to allow redefining
  # required keys for alternative layouts

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
  backslash     ⇐ 92       # \
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

  keypad ⇐ {
    num_lock    ⇐ 282      # Num lock
    zero        ⇐ 320      # Keypad 0
    one         ⇐ 321      # Keypad 1
    two         ⇐ 322      # Keypad 2
    three       ⇐ 323      # Keypad 3
    four        ⇐ 324      # Keypad 4
    five        ⇐ 325      # Keypad 5
    six         ⇐ 326      # Keypad 6
    seven       ⇐ 327      # Keypad 7
    eight       ⇐ 328      # Keypad 8
    nine        ⇐ 329      # Keypad 9
    decimal     ⇐ 330      # Keypad .
    divide      ⇐ 331      # Keypad /
    multiply    ⇐ 332      # Keypad *
    subtract    ⇐ 333      # Keypad -
    add         ⇐ 334      # Keypad +
    enter       ⇐ 335      # Keypad Enter
    equal       ⇐ 336      # Keypad =
  }
  android ⇐ {
    back        ⇐ 4        # back button
    menu        ⇐ 82       # menu button
    volume_up   ⇐ 24       # volume up button
    volume_down ⇐ 25       # volume down button
  }
}