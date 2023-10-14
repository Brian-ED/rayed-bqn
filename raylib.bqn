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
  color
⟩ ⇐ ⟨
  bqnFontChars
  windowConfigFlags
⟩ ← •Import "src/constants.bqn"

global ← •Import "src/global.bqn"
NeedsWindow ← {window.isOpen?𝕩;!"Expected window to be open"}
global.SetNeedsWindow needsWindow

⟨bqnLibsPath⟩ ← •Import "src/loadConfig.bqn"
rayFFI  ⇐ •Import "rayffi.bqn"
raymath ⇐ •Import "src/raymath.bqn"
image   ⇐ •Import "src/image.bqn"
# -------

# Utils:
FileAt ← "/cygdrive/c"("C:"∾≠⊸↓)⍟(⊣≡≠⊸↑)•file.At                # remade •FileAt to work for cygwin

# Defaults
rayffi.SetTraceLogLevel traceLogLevel.warning # makes logs not output INFO: logs to stdOut

# constants
i32_max ← ¯1+2⋆31

texture ← {
  Load ⇐ {𝕊strPath: # Load texture from file into GPU memory (VRAM)
    NeedsWindow@
    !•file.Exists 𝕩
    rayFFI.LoadTexture 𝕩
  }
  Unload ⇐ {𝕊texture: NeedsWindow@ ⋄ @⊣rayFFI.UnloadTexture𝕩}
  _with ⇐ {𝔽_𝕣 strPath : (Unload⊢𝔽)Load𝕩}
  _WithImage ⇐ {
    NeedsWindow@
    (Unload⊢𝔽)rayffi.LoadTextureFromImage image._AsRayImg 𝕩
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
  Sizemm      ← (rayFFI.GetMonitorPhysicalWidth ∾ rayFFI.GetMonitorPhysicalHeight)M # mm stands for milimeter
  Name        ← rayFFI.GetMonitorName M
}

# window functionality
window ← {
  ⟨
    isOpen ⋄ _openAs ⋄ SetIcon ⋄ fps ⋄ GetSize
    ShouldClose ⋄ Needed ⋄ SetPos ⋄ GetPos ⋄ SetSize ⋄ configFlags

    fullscreen        ⋄ SetFullscreen
    resizable         ⋄ SetResizable
    decorated         ⋄ SetDecorated
    transparent       ⋄ SetTransparent
    msaa4xhint        ⋄ Setmsaa4xhint
    vsyncHint         ⋄ Setvsynchint
    hidden            ⋄ SetHidden
    runWhileMinimized ⋄ SetRunWhileMinimized
    minimized         ⋄ SetMinimized
    maximized         ⋄ SetMaximized
    focused           ⋄ SetFocused
    topmost           ⋄ SetTopmost
    highDPI           ⋄ SetHighDPI
    mousePassThrough  ⋄ SetMousePassThrough
    interlacedhint    ⋄ SetInterlacedhint

    GetState # get binary list of above settings (including empty ones in the raylib binary format)
  ⟩⇐

  Needed ← NeedsWindow
  isOpen ← 0

  # Get the x‿y position of the window   (relative to current monitor?)
  GetPos ← {rayffi.GetWindowPosition⟨⟩⊣NeedsWindow𝕩}
  
  # Set the x‿y position of the window   (relative to current monitor?)
  SetPos ← {rayFFI.SetWindowPosition NeedsWindow𝕩}

  # tempSize is used to store size until window is open
  tempSize ← 0‿0

  # Set the width and hight of the window, width and hight being relative to window position
  SetSize ← {𝕊size:
    ((⌈⊸≡∨⊢≡0⌈1⌊⊢)𝕩)!˜"Size can only be between 0 and 1, or a positive whole number"
    ((⟨⟩⊸≡∨⟨2⟩⊸≡)≢𝕩)!˜"Size can be a scaler (⟨⟩≢≢𝕨) or length two list (⟨2⟩≡≢𝕨)"
    isOpen?
      s ← (rayFFI.GetMonitorWidth ∾ rayFFI.GetMonitorHeight) rayFFI.GetCurrentMonitor⟨⟩
      f ← (1⊸>∧0⊸≤)𝕩
      # if given size is 0-1, scale the window relative to monitor size
      rayFFI.SetWindowSize ⌈2⥊s×⟜¬⌾(f⊸/)2⥊𝕩
  ;
    tempSize↩𝕩
  }
  
  # Get the width and hight of the window, width and hight being relative to window position
  GetSize ← {𝕤
    isOpen?
      ⟨rayFFI.GetScreenWidth⟨⟩
       rayFFI.GetScreenHeight⟨⟩⟩
  ;
    tempSize
  }

  # Open the window with default settings
  Open ← {𝕊 title:
    (¬isOpen)!˜"The window cannot be opened twice"
    rayFFI.InitWindow 0‿0‿𝕩
    rayFFI.SetWindowPosition⍟("windows"≡•platform.os) 0‿42 # 42 here is the window header on windows only

    binary←GetState@
    rayffi.SetWindowState 2⊸×⊸+˜´ binary

    isOpen↩1

    SetSize tempSize

    rayffi.SetExitKey 0 # 0 means no key, essentially removing esc key closing programs implicitly
    rayFFI.SetWindowPosition⍟("windows"≡•platform.os) 0‿42 # 42 here is the window header on windows only
    # Setting fps to the refresh rate of the currently selected monitor
    fps.Set rayFFI.GetMonitorRefreshRate rayFFI.GetCurrentMonitor⟨⟩
  }
  ShouldClose ← rayFFI.WindowShouldClose⟨⟩⊣NeedsWindow
  Close ← {
    NeedsWindow@
    rayFFI.CloseWindow⟨⟩
    𝕩⊣isOpen↩0
  }
  _openAs ← {App _𝕣 title: size←𝕨⊣1
    Open 𝕩
    Close⊸⊢𝔽 {startTime⇐•Monotime@} 
  }
  # TODO: Needs to test input for image
  SetIcon ← {𝕊image: NeedsWindow@ ⋄ rayFFI.SetWindowIcon𝕩} image._AsRayImg

  fps ← {
    Get ⇐ rayFFI.GetFPS⟨⟩⊣NeedsWindow
    Set ⇐ {
      (𝕩=0⌈⌈𝕩)!˜"FPS has to be a positive int"
      𝕩⊣rayFFI.SetTargetFPS𝕩
    }⊣NeedsWindow
  }
  configFlags ← windowConfigFlags

  fullscreen        ← 0 # Set to run program in fullscreen
  resizable         ← 1 # Set to allow resizable window
  decorated         ← 1 # Set to 0 to disable window decoration (frame and buttons)
  transparent       ← 0 # Set to allow transparent framebuffer
  msaa4xhint        ← 0 # Set to try enabling MSAA 4X
  vsyncHint         ← 0 # Set to try enabling V-Sync on GPU
  hidden            ← 0 # Set to hide window
  runWhileMinimized ← 0 # Set to allow windows running while minimized
  minimized         ← 0 # Set to minimize window (iconify)
  maximized         ← 0 # Set to maximize window (expanded to monitor)
  focused           ← 1 # Set to 0 to non focus window
  topmost           ← 0 # Set to window always on top
  highDPI           ← 0 # Set to support HighDPI
  mousePassThrough  ← 0 # Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
  interlacedhint    ← 0 # Set to try enabling interlaced video format (for V3D)

  cf ← configFlags
  cs ← { # array of Clear‿Set that clears(Clear sets var to 0) and sets(Set var to 1) used as ◶cs
    ⟨Clear⇐ClearWindowState, Set⇐SetWindowState⟩ ← rayffi
    Clear‿Set
  }
  
  SetFullscreen        ⇐ { fullscreen        ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.fullscreen_mode          }
  SetResizable         ⇐ { resizable         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_resizable         }
  SetDecorated         ⇐ { decorated         ↩ 𝕩 ⊣ ¬∘𝕩◶cs⍟isOpen cf.window_undecorated       }
  SetTransparent       ⇐ { transparent       ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_transparent       }
  Setmsaa4xhint        ⇐ { msaa4xhint        ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.msaa4xhint               }
  Setvsynchint         ⇐ { vsyncHint         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.vsync_hint               }
  SetHidden            ⇐ { hidden            ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_hidden            }
  SetRunWhileMinimized ⇐ { runWhileMinimized ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_always_run        }
  SetMinimized         ⇐ { minimized         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_minimized         }
  SetMaximized         ⇐ { maximized         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_maximized         }
  SetFocused           ⇐ { focused           ↩ 𝕩 ⊣ ¬∘𝕩◶cs⍟isOpen cf.window_unfocused         }
  SetTopmost           ⇐ { topmost           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_topmost           }
  SetHighDPI           ⇐ { highDPI           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.highDPI                  }
  SetMousePassThrough  ⇐ { topmost           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_mouse_passthrough }
  SetInterlacedhint    ⇐ { interlacedhint    ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_interlacedhint    }
  
  names ← [
    "                 "
    "fullscreen       "
    "resizable        "
    "undecorated      "
    "transparent      "
    "msaa4xhint       "
    "vsyncHint        "
    "hidden           "
    "runWhileMinimized"
    "minimized        "
    "maximized        "
    "unfocused        "
    "topmost          "
    "highDPI          "
    "mousePassThrough "
    "interlacedhint   "
    "interlacedhint   "
  ]
  GetState ← {𝕤 # returns binary list that corrisponds to raylib's config_flags format
    0‿fullscreen‿resizable‿(¬decorated)‿transparent‿msaa_4x_hint‿vsync_hint‿hidden‿runWhileMinimized‿minimized‿maximized‿(¬focused)‿topmost‿highdpi‿mouse_passthrough‿0‿interlaced_hint
  }
  GetFmtState ← names<⊸∾˘GetState
}

# Drawing
draw ← {
  ⟨
    _withCanvas_ ⋄ _in3D
    Rectangle ⋄ Triangle ⋄ Line
    Ellipse ⋄ EllipseOutline
    Text ⋄ Texture ⋄ advanced
  ⟩⇐

  # Start 3d mode, drawing relative to camera using 𝔽, then ends 3d mode
  _in3D ← {𝕨 Drawing3D _𝕣 camera:
    NeedsWindow@          # pos  target up   FOV Camera projection type
    "_in3D: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iii"‿"iii"‿"iii"‿'i'‿'i'
    rayffi.BeginMode3D 𝕩
    rayffi.EndMode3D∘⟨⟩⊸⊢𝔽𝕩
  }

  # Draw background
  Background ← {𝕊r‿g‿b‿a:
    NeedsWindow@
    (∧´(255⊸≥∧>0⊸≤)𝕩)!˜"ClearBackground only accepts ints in the range 0-255 inclusive"
    "Background: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"
    rayFFI.ClearBackground 𝕩
  }

  # Start Drawing
  Start ← ⊢⊣rayFFI.BeginDrawing∘⟨⟩⊣NeedsWindow

  # End drawing
  End ← ⊢⊣rayFFI.EndDrawing∘⟨⟩⊣NeedsWindow

  # Start drawing, draw background, use function 𝔽, end drawing
  _withCanvas_ ← {𝕨DrawingFunc _𝕣_ Func_Returning_A_Color𝕩:
    Start@
    Background 𝕨𝔾𝕩
    ⊣⟜End𝕨𝔽𝕩
  }

  # Draw text at x‿y in given font, color, and size
  Text ← {𝕨𝕊⟨x‿y⋄text⟩:
    NeedsWindow@
    t←⟨r‿g‿b‿a⋄font⋄fontSize⋄spacing⟩ ⇐ ∾⟜1⍟(3≡≠)𝕨
    "Text: wrong types as input"!t‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿("iii"∾5‿8‿8⥊¨'i')‿'i'‿'i'⋄"ii"⋈'c'¨text⟩
    rayFFI.DrawTextCodepoints ⟨font⋄text-@⋄≠text⋄x‿y⋄fontSize⋄spacing⋄r‿g‿b‿a⟩
  }

  # Draw line from x1‿y1 to x2‿y2
  Line ← {𝕨𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    leftArg←{
      𝕊r‿g‿b‿a:1⋈˜𝕩;
      𝕊⟨r‿g‿b‿a⋄thickness⟩:𝕩
    }𝕨
    "Line: wrong types as input"!leftArg‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿'i'⋄2‿2⥊'i'⟩
    rayFFI.DrawLineEx(<˘𝕩)∾⌽leftArg
  }

  Texture ← {⟨r‿g‿b‿a⋄texture⋄scale⋄rotation⟩ 𝕊 x‿y:
    NeedsWindow@
    "Texture: wrong types as input"!𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿"iiiii"‿'i'‿'i'⋄"ii"⟩
    rayFFI.DrawTextureEx ⟨texture⋄x‿y⋄rotation⋄scale⋄r‿g‿b‿a⟩ # texture‿v2‿f‿f‿color # texture position rotation scale tint
  }

  Rectangle ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    "Rectangle: wrong types as input"!𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"⋈2‿2⥊'i'
    rayFFI.DrawRectangleV 𝕨∾⟜<˜(⊣⋈-˜)˝∧˘⌾⍉i32_max⌊0⌈⌊𝕩 # capping with max and min to avoid errors at ∞
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

  Triangle ← {color𝕊[x1‿y1⋄x2‿y2⋄x3‿y3]:
    [p1,p2,p3]← 𝕩
    rayffi.DrawTriangle ⟨p1,𝕨⟩∾˜p2‿p3⌽˜p3<○(•math.Atan2´p2⊸-)p1
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

  LoadBQN ← {𝕊fontSize:
    NeedsWindow@
    rayFFI.LoadFontEx⟨FileAt"src/BQN386.ttf"⋄100⍟(@⊸≡)𝕩⋄bqnFontChars-@⋄≠bqnFontChars⟩
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

# start clock then tick at the start of every frame to get accurate clock.delta and clock.time
StartClock ← {𝕊@:
  # time is relative to when you started the clock
  startTime ⇐ •MonoTime@
  lastTime ← 0
  
  delta ⇐ 0
  frame ⇐ 0

  Time  ⇐ {𝕊:startTime-˜•Monotime@}
  Tick ⇐ {𝕊:
    frame+↩1
    delta ↩ lastTime-˜startTime-˜•MonoTime@
    lastTime ↩ startTime-˜•MonoTime@
    delta
  }
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