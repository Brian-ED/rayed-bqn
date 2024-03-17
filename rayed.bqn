## Conventions:
# One big goal of this lib is to eliminate as many bugs of raylib as possible,
# for example, opening the window twice is impossible because it is not intended in raylib, and causes many bugs.

# x and y as variables (also x1 y1, x2 y2 etc) are always positions

# -------
# Exports
⟨
  draw, texture, monitor, window, mouse
  font, key, clipboard, StartClock
  sound, bqnoise, raymath, image, low
⟩⇐

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

# Loading dependencies
•Import∘"src/parseFFI.bqn"⍟¬•file.Exists "config.bqn"
⟨raylib⟩ ⇐ {
  paths ← ⟨"ffi/raylib.bqn"⟩
  tried ← •Import⎊{
    0⊣•Out "Error running "∾𝕩
  }¨paths
  paths{
    •Out "Attempting reparsing for automatic fix."
    •Import "src/parseFFI.bqn"
    •Out∘"Fix successful"⊸⊢ •Import¨𝕨
  }⍟(⟨⟩⊸≢)⌾((0⊸≡¨tried)⊸/)tried
}
raymath ← •Import "src/raymath.bqn"
image   ← •Import "src/image.bqn"
low     ← •Import "src/low.bqn"
bqnoise ← •Import "src/imports/BQNoise/wav.bqn"
bqnoiseOptions ← •Import "src/imports/BQNoise/options.bqn"
# -------

# Utils:
FileAt ← "/cygdrive/c"("C:"∾≠⊸↓)⍟(⊣≡≠⊸↑)•file.At                # remade •FileAt to work for cygwin

# Defaults
raylib.SetTraceLogLevel traceLogLevel.warning # makes logs not output INFO: logs to stdOut

# constants
i32_max ← ¯1+2⋆31

texture ← {
  ⟨ Load ⋄ Unload ⋄ _WithImage ⋄ _withFile ⋄ _WithRayImage ⟩⇐
  # texture.Load
  Load ← {𝕊filePath: # Load texture from file into GPU memory (VRAM)
    NeedsWindow@
    {!"Path given wasn't absolute 𝕩≡"∾•Repr𝕩}⍟("."⊸•file.At⊸≢)𝕩
    {𝕊:!"Couldn't find file at "∾•file.RealPath filePath}⍟¬•file.Exists 𝕩
    raylib.LoadTexture 𝕩
  }
  # texture.Unload
  Unload ← {𝕊texture: NeedsWindow@ ⋄ @⊣raylib.UnloadTexture𝕩}
  # texture._with
  _withFile ← {𝔽_𝕣 filePath : (Unload⊢𝔽)Load𝕩}
  # texture._withRayImage
  _withRayImage ← {
    NeedsWindow@
    (Unload⊢𝔽)raylib.LoadTextureFromImage 𝕩
  }
  # texture._withImage
  _withImage ← {
    NeedsWindow@
    (Unload⊢𝔽)raylib.LoadTextureFromImage image._AsRayImg 𝕩
  }
}
monitor ← {
  ⟨Selected ⋄ Count
   RefreshRate ⋄ Size
   Sizemm ⋄ Name ⋄ GetPos⟩⇐
  # monitor.Selected
  Selected ← {𝕤
    NeedsWindow@
    raylib.GetCurrentMonitor⟨⟩
  }
  # monitor.Count
  Count ← {𝕤
    NeedsWindow@
    raylib.GetMonitorCount⟨⟩
  }

  notAMonitorErr ← "Invalid monitor 𝕩, can only be @ for currently selected monitor or a monitor number; ( 𝕩∊↕monitor.Count@ ) v ( 𝕩≡@ )"
  M ← @⊸≢◶Selected‿{𝕩⊣notAMonitorErr!⊑𝕩∊↕Count@} # No need for NeedsWindow because Selected and Count need it so error still works

  # monitor.RefreshRate
  RefreshRate ← {𝕊monitor:
    raylib.GetMonitorRefreshRate M 𝕩
  }
  # monitor.Size
  Size ← {𝕊monitor:
    (raylib.GetMonitorWidth ∾ raylib.GetMonitorHeight)M 𝕩
  }
  # Get size in milimeters
  # monitor.Sizemm
  Sizemm ← {𝕊monitor:
    (raylib.GetMonitorPhysicalWidth ∾ raylib.GetMonitorPhysicalHeight)M 𝕩
  }
  # monitor.Name
  Name ← {𝕊monitor:
    raylib.GetMonitorName M 𝕩
  }
  # monitor.GetPos
  GetPos ← {𝕤
    raylib.GetMonitorPosition M 𝕩
  }
}

# window functionality
window ← {
  ⟨
    _openAs ⋄ Open ⋄ Close ⋄ isOpen ⋄ SetIcon ⋄ fps ⋄ GetSize
    ShouldClose ⋄ Needed ⋄ SetPos ⋄ GetPos ⋄ SetSize ⋄ configFlags
    SetTitle

    IsFullscreen        ⋄ SetFullscreen
    IsResizable         ⋄ SetResizable
    IsDecorated         ⋄ SetDecorated
    IsTransparent       ⋄ SetTransparent
    IsMsaa4xhint        ⋄ Setmsaa4xhint
    IsVsyncHint         ⋄ Setvsynchint
    IsHidden            ⋄ SetHidden
    IsRunWhileMinimized ⋄ SetRunWhileMinimized
    IsMinimized         ⋄ SetMinimized
    IsMaximized         ⋄ SetMaximized
    IsFocused           ⋄ SetFocused
    IsTopmost           ⋄ SetTopmost
    IsHighDPI           ⋄ SetHighDPI
    IsMousePassThrough  ⋄ SetMousePassThrough
    IsInterlacedhint    ⋄ SetInterlacedhint

    GetState ⋄ stateNames # get binary list of above settings (including empty ones in the raylib binary format)
  ⟩⇐
  # window.Needed
  Needed ← NeedsWindow
  isOpen ← 0

  # Get the x‿y position of the window   (relative to current monitor?)
  # window.GetPos
  GetPos ← {raylib.GetWindowPosition⟨⟩⊣NeedsWindow𝕩}
  
  # Set the x‿y position of the window   (relative to current monitor?)
  # window.SetPos
  SetPos ← {
    NeedsWindow@
    raylib.SetWindowPosition𝕩
  }

  # tempSize is used to store size until window is open
  tempSize ← 0‿0

  # Set the width and hight of the window, width and hight being relative to window position
  # window.SetSize
  SetSize ← {𝕊size:
    ((⌈⊸≡∨⊢≡0⌈1⌊⊢)𝕩)!˜"Size can only be between 0 and 1, or a positive whole number"
    ((⟨⟩⊸≡∨⟨2⟩⊸≡)≢𝕩)!˜"Size can be a scaler (⟨⟩≢≢𝕨) or length two list (⟨2⟩≡≢𝕨)"
    isOpen?
      s ← (raylib.GetMonitorWidth ∾ raylib.GetMonitorHeight) raylib.GetCurrentMonitor⟨⟩
      f ← (1⊸>∧0⊸≤)𝕩
      # if given size is 0-1, scale the window relative to monitor size
      raylib.SetWindowSize ⌈2⥊s×⟜¬⌾(f⊸/)2⥊𝕩
  ;
    tempSize↩𝕩
  }
  
  # Get the width and hight of the window, width and hight being relative to window position
  # window.GetSize
  GetSize ← {𝕤
    isOpen?
      ⟨raylib.GetScreenWidth⟨⟩
       raylib.GetScreenHeight⟨⟩⟩
  ;
    tempSize
  }

  # Open the window with default settings
  # window.Open
  Open ⇐ {𝕊 title:
    (¬isOpen)!˜"The window cannot be opened twice"
    raylib.InitWindow 0‿0‿𝕩
    raylib.SetWindowPosition⍟("windows"≡•platform.os) 0‿42 # 42 here is the window header on windows only

    raylib.SetWindowState 2⊸×⊸+˜´ GetState@

    !raylib.IsWindowReady⟨⟩
    isOpen↩1

    SetSize tempSize

    raylib.SetExitKey 0 # 0 means no key, essentially removing esc key closing programs implicitly
    raylib.SetWindowPosition⍟("windows"≡•platform.os) 0‿42 # 42 here is the window header on windows only
    # Setting fps to the refresh rate of the currently selected monitor
    fps.Set raylib.GetMonitorRefreshRate raylib.GetCurrentMonitor⟨⟩
    window
  }
  # window.ShouldClose
  ShouldClose ← {𝕤
    NeedsWindow@
    raylib.WindowShouldClose⟨⟩
  }
  # window.Close
  Close ← {
    NeedsWindow@
    raylib.CloseWindow⟨⟩
    𝕩⊣isOpen↩0
  }
  # window.OpenAs
  _openAs ← {App _𝕣 title: size←𝕨⊣1
    Open 𝕩
    Close⊸⊢𝔽@
  }
  # TODO: Needs to test input for image
  # window.SetIcon
  SetIcon ← {𝕊image: NeedsWindow@ ⋄ raylib.SetWindowIcon𝕩} image._AsRayImg

  #window.SetTitle
  SetTitle ← {
    NeedsWindow@
    "𝕩 has to be a list of characters"!(=𝕩)∧∧´2=•Type¨𝕩
    raylib.SetWindowTitle 𝕩
  }

  fps ← {
    # window.fps.Get
    Get ⇐ {𝕤
      NeedsWindow@
      raylib.GetFPS⟨⟩
    }
    # window.fps.Set
    Set ⇐ {
      (𝕩=0⌈⌈𝕩)!˜"FPS has to be a positive int"
      𝕩⊣raylib.SetTargetFPS𝕩
    }⊣NeedsWindow
  }
  # window.configFlags
  configFlags ← windowConfigFlags

  fullscreen        ← 0 # Set to run program in fullscreen                                              # window.fullscreen
  resizable         ← 1 # Set to allow resizable window                                                 # window.resizable
  decorated         ← 1 # Set to 0 to disable window decoration (frame and buttons)                     # window.decorated
  transparent       ← 0 # Set to allow transparent framebuffer                                          # window.transparent
  msaa4xhint        ← 0 # Set to try enabling MSAA 4X                                                   # window.msaa4xhint
  vsyncHint         ← 0 # Set to try enabling V-Sync on GPU                                             # window.vsyncHint
  hidden            ← 0 # Set to hide window                                                            # window.hidden
  runWhileMinimized ← 0 # Set to allow windows running while minimized                                  # window.runWhileMinimized
  minimized         ← 0 # Set to minimize window (iconify)                                              # window.minimized
  maximized         ← 0 # Set to maximize window (expanded to monitor)                                  # window.maximized
  focused           ← 1 # Set to 0 to non focus window                                                  # window.focused
  topmost           ← 0 # Set to window always on top                                                   # window.topmost
  highDPI           ← 0 # Set to support HighDPI                                                        # window.highDPI
  mousePassThrough  ← 0 # Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED # window.mousePassThrough
  interlacedhint    ← 0 # Set to try enabling interlaced video format (for V3D)                         # window.interlacedhint

  # array of Clear‿Set that clears(Clear sets var to 0) and sets(Set var to 1) used as ◶cs
  # window state not available on some platforms so will replace clear‿set with other functions like ToggleFullscreen
  cs ← raylib.ClearWindowState‿raylib.SetWindowState
  cf ← configFlags

  SetFullscreen        ⇐ {!⊑𝕩∊↕2 ⋄ fullscreen        ↩ 𝕩 ⊣ raylib.ToggleFullscreen∘⟨⟩⍟⊢isopen∧𝕩≠IsFullscreen@} # window.SetFullscreen
  SetResizable         ⇐ {!⊑𝕩∊↕2 ⋄ resizable         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_resizable         } # window.SetResizable
  SetDecorated         ⇐ {!⊑𝕩∊↕2 ⋄ decorated         ↩ 𝕩 ⊣ ¬∘𝕩◶cs⍟isOpen cf.window_undecorated       } # window.SetDecorated
  SetTransparent       ⇐ {!⊑𝕩∊↕2 ⋄ transparent       ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_transparent       } # window.SetTransparent
  Setmsaa4xhint        ⇐ {!⊑𝕩∊↕2 ⋄ msaa4xhint        ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.msaa4xhint               } # window.Setmsaa4xhint
  Setvsynchint         ⇐ {!⊑𝕩∊↕2 ⋄ vsyncHint         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.vsync_hint               } # window.Setvsynchint
  SetHidden            ⇐ {!⊑𝕩∊↕2 ⋄ hidden            ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_hidden            } # window.SetHidden
  SetRunWhileMinimized ⇐ {!⊑𝕩∊↕2 ⋄ runWhileMinimized ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_always_run        } # window.SetRunWhileMinimized
  SetMinimized         ⇐ {!⊑𝕩∊↕2 ⋄ minimized         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_minimized         } # window.SetMinimized
  SetMaximized         ⇐ {!⊑𝕩∊↕2 ⋄ maximized         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_maximized         } # window.SetMaximized
  SetFocused           ⇐ {!⊑𝕩∊↕2 ⋄ focused           ↩ 𝕩 ⊣ ¬∘𝕩◶cs⍟isOpen cf.window_unfocused         } # window.SetFocused
  SetTopmost           ⇐ {!⊑𝕩∊↕2 ⋄ topmost           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_topmost           } # window.SetTopmost
  SetHighDPI           ⇐ {!⊑𝕩∊↕2 ⋄ highDPI           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.highDPI                  } # window.SetHighDPI
  SetMousePassThrough  ⇐ {!⊑𝕩∊↕2 ⋄ topmost           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_mouse_passthrough } # window.SetMousePassThrough
  SetInterlacedhint    ⇐ {!⊑𝕩∊↕2 ⋄ interlacedhint    ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_interlacedhint    } # window.SetInterlacedhint

  IWS ← raylib.IsWindowState
  IsFullscreen        ⇐ {𝕊: isOpen? IWS cf.fullscreen_mode          ; fullscreen        }
  IsResizable         ⇐ {𝕊: isOpen? IWS cf.window_resizable         ; resizable         }
  IsDecorated         ⇐ {𝕊: isOpen? IWS cf.window_undecorated       ; decorated         }
  IsTransparent       ⇐ {𝕊: isOpen? IWS cf.window_transparent       ; transparent       }
  IsMsaa4xhint        ⇐ {𝕊: isOpen? IWS cf.msaa4xhint               ; msaa4xhint        }
  IsVsyncHint         ⇐ {𝕊: isOpen? IWS cf.vsync_hint               ; vsyncHint         }
  IsHidden            ⇐ {𝕊: isOpen? IWS cf.window_hidden            ; hidden            }
  IsRunWhileMinimized ⇐ {𝕊: isOpen? IWS cf.window_always_run        ; runWhileMinimized }
  IsMinimized         ⇐ {𝕊: isOpen? IWS cf.window_minimized         ; minimized         }
  IsMaximized         ⇐ {𝕊: isOpen? IWS cf.window_maximized         ; maximized         }
  IsFocused           ⇐ {𝕊: isOpen? IWS cf.window_unfocused         ; focused           }
  IsTopmost           ⇐ {𝕊: isOpen? IWS cf.window_topmost           ; topmost           }
  IsHighDPI           ⇐ {𝕊: isOpen? IWS cf.highDPI                  ; highDPI           }
  IsMousePassThrough  ⇐ {𝕊: isOpen? IWS cf.window_mouse_passthrough ; mousePassThrough  }
  IsInterlacedhint    ⇐ {𝕊: isOpen? IWS cf.window_interlacedhint    ; interlacedhint    }

  # window.stateNames
  stateNames ← [
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
  # window.GetState
  GetState ← {𝕤 # returns binary list that corrisponds to raylib's config_flags format
    0‿fullscreen‿resizable‿(¬decorated)‿transparent‿msaa_4x_hint‿vsync_hint‿hidden‿runWhileMinimized‿minimized‿maximized‿(¬focused)‿topmost‿highdpi‿mouse_passthrough‿0‿interlaced_hint
  }
}

# Drawing
draw ← {
  ⟨
    _withCanvas_ ⋄ _in3D ⋄ _withinRectangle
    Rectangle ⋄ Triangle ⋄ Line
    Ellipse ⋄ EllipseOutline
    Text ⋄ Texture ⋄ advanced
  ⟩⇐

  # Start 3d mode, drawing relative to camera using 𝔽, then ends 3d mode
  # draw._in3D
  _in3D ← {𝕨 Drawing3D _𝕣 camera:
    NeedsWindow@          # pos  target up   FOV Camera projection type
    "_in3D: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iii"‿"iii"‿"iii"‿'i'‿'i'
    raylib.BeginMode3D 𝕩
    raylib.EndMode3D∘⟨⟩⊸⊢𝔽𝕩
  }
  # Start drawing, draw background, use function 𝔽, end drawing
  # draw._withCanvas_
  _withCanvas_ ← {𝕨DrawingFunc _𝕣_ Func_Returning_A_Color𝕩:
    Start@
    Background 𝕨𝔾𝕩
    ⊣⟜End𝕨𝔽𝕩
  }

  # draw._onTexture
  {𝔽 _𝕣 texture:
    raylib.BeginTextureMode𝕩
    raylib.EndTextureMode∘⟨⟩⊸⊢ 𝔽𝕩
  }

  # draw._withinRectangle
  _withinRectangle ← {
    raylib.BeginScissorMode (⊣∾-˜)˝∧˘⌾⍉i32_max⌊0⌈⌊𝕩
    raylib.EndScissorMode∘⟨⟩⊸⊢𝔽𝕩
  }

  # Draw text at x‿y in given font, color, and size
  # draw.Text
  Text ← {𝕨𝕊⟨x‿y⋄text⟩:
    NeedsWindow@
    t ← ⟨r‿g‿b‿a⋄font⋄fontSize⋄spacing⟩ ⇐ ∾⟜1⍟(3≡≠)𝕨
    "Text: wrong types as input"!t‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿("iii"∾(5⥊'i')‿'n'‿'n')‿'i'‿'i'⋄"ii"⋈'c'¨text⟩
    raylib.DrawTextCodepoints ⟨font⋄text-@⋄≠text⋄x‿y⋄fontSize⋄spacing⋄r‿g‿b‿a⟩
  }

  # Draw line from x1‿y1 to x2‿y2
  # draw.Line
  Line ← {𝕨𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    leftArg ← {
      𝕊r‿g‿b‿a:1⋈˜𝕩;
      𝕊⟨r‿g‿b‿a⋄thickness⟩:𝕩
    }𝕨
    "Line: wrong types as input"!leftArg‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿'i'⋄2‿2⥊'i'⟩
    raylib.DrawLineEx(<˘𝕩)∾⌽leftArg
  }

  # draw.Texture
  Texture ← {tint‿texture‿scale‿rotation𝕊x‿y:
    NeedsWindow@
    "Texture: wrong types as input"!⟨tint⋄texture⋄scale⋄rotation⟩‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿"iiiii"‿'i'‿'i'⋄"ii"⟩
    raylib.DrawTextureEx ⟨texture⋄x‿y⋄rotation⋄scale⋄tint⟩ # texture‿v2‿f‿f‿color # texture position rotation scale tint
  }

  # draw.Rectangle
  Rectangle ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    "Rectangle: wrong types as input"!𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"⋈2‿2⥊'i'
    raylib.DrawRectangleV 𝕨∾⟜<˜(⊣⋈-˜)˝∧˘⌾⍉i32_max⌊0⌈⌊𝕩 # capping with max and min to avoid errors at ∞
  }

  # draw.Ellipse
  Ellipse ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    ((∧´⌈⊸=∨∞=|)⥊𝕩)!˜"Ellipse only accepts ints as args"
    ((∧´0⊸≤∧≤⟜255)𝕨)!˜"𝕨 (color) only accepts ints in the range 0-255 inclusive"
    raylib.DrawEllipse 𝕨∾⟜<˜(⌈∾⊢-⊏∘𝕩)(+˝÷≠)𝕩
  }

  # Draw a color-filled circle
  # draw.Circle
  Circle ← {r‿g‿b‿a𝕊⟨x‿y⋄radius⟩: # color 𝕊 pos‿radius
    NeedsWindow@
    (𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"‿⟨"ii"⋄'i'⟩)!˜"Wrong input types given to draw.Circle"
    ((∧´⌈⊸=∨∞=|)x‿y)!˜"Position for draw.Circle has to be two ints"
    ((∧´0⊸≤∧≤⟜255)𝕨)!˜"𝕨 (color) only accepts ints in the range 0-255 inclusive"
    raylib.DrawCircle x‿y‿radius‿𝕨
  }

  # draw.EllipseOutline
  EllipseOutline ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    raylib.DrawEllipseLines 𝕨∾⟜<˜(⌈∾⊢-⊏∘𝕩)(+˝÷≠)𝕩                # i‿i‿f‿f‿color # centerX centerY radiusH radiusV
  }

  # draw.Triangle
  Triangle ← {color𝕊[x1‿y1⋄x2‿y2⋄x3‿y3]:
    [p1,p2,p3] ← 𝕩
    raylib.DrawTriangle p1‿𝕨∾˜p2‿p3⌽˜p3<○(•math.Atan2´p2⊸-)p1
  }

  # Start Drawing
  Start ← {𝕤
    NeedsWindow@
    raylib.BeginDrawing⟨⟩
  }
  # Draw background
  Background ← {𝕊r‿g‿b‿a:
    NeedsWindow@
    (∧´(255⊸≥∧>0⊸≤)𝕩)!˜"ClearBackground only accepts ints in the range 0-255 inclusive"
    "Background: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"
    raylib.ClearBackground 𝕩
  }
  # End drawing
  End ← {𝕤
    NeedsWindow@
    raylib.EndDrawing⟨⟩
  }
  # These aren't recommended because they are useless if you use _withCanvas_.
  # They also don't behave well if ran in the wrong order,
  # you only want to run them in the "start, background, end" sequence.
  advanced ⇐ {Start‿Background‿End⇐Start‿Background‿End}
}

font ← {
  ⟨ Load ⋄ LoadBQN ⋄ LoadRaylib ⋄ Unload ⟩⇐
  IsFont ← {
    (𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iii"∾"iiiii"<⊸∾⋈˜'n')!˜"Expected a valid font"
    𝕩⊣(¬∨´low.IsNull¨¯2↑𝕩)!˜"Invalid font. font has null pointers, making it invalid"
  }
  glyphInfo ← {value‿offsetX‿offsetY‿advanceX‿image⇐↕5}             # The namespace is for eliminating magic-numbers

  # font.Unload
  Unload ⇐ {
    NeedsWindow@
    IsFont 𝕩
    raylib.UnloadFont 𝕩
  }
  # font.Load
  Load ⇐ {
    NeedsWindow@
    F ← {
      𝕊size‿filePath:
        ⟨filePath⋄size⋄≍@⋄0⟩
    ;                                           # fontSize fontChars glyphCount # use NULL for fontChars and 0 for glyphCount to load the default character set
      charactersAllowed 𝕊 size‿filePath:
        ⟨filePath⋄size⋄𝕨-@⋄≠𝕨⟩
    }
    ·‿filePath ← 𝕩
    {!"Path given wasn't absolute 𝕩≡"∾•Repr𝕩}⍟("."⊸•file.At⊸≢)filePath
    {𝕊:!"Couldn't find file at "∾•file.RealPath filePath}⍟¬•file.Exists filePath

    IsFont raylib.LoadFontEx 𝕨F𝕩
  }

  # font.LoadBQN
  LoadBQN ← {𝕊fontSize: fontSize 100⍟(@⊸≡)↩
    NeedsWindow@
    file ← ("Expected file at: "⊸∾!•file.Exists)⊸⊢ FileAt"src/imports/BQN386/BQN386.ttf"
    raylib.LoadFontEx⟨file⋄fontSize⋄bqnFontChars-@⋄≠bqnFontChars⟩
  }
  # font.LoadRaylib
  LoadRaylib ← {𝕊@:
    raylib.GetFontDefault⟨⟩
  }
}
clipboard ← {
  ⟨Get ⋄ Set⟩⇐
  ⟨ToBytes⟩ ← •Import "src/imports/bqn-libs/strings.bqn"
  
  # clipboard.Get
  Get ⇐ {𝕤
    NeedsWindow@
    low.IsNull◶⟨
      low.StrLen⊸low.MakeUTF8
      ""
    ⟩ raylib.GetClipboardText⟨⟩
  }
  # clipboard.Set
  Set ⇐ {𝕊text:
    NeedsWindow@
    raylib.SetClipboardText ToBytes 𝕩
  }
}

# start clock then tick at the start of every frame to get accurate clock.delta and clock.time
StartClock ← {𝕊@:
  ⟨startTime ⋄ Time ⋄ Tick⟩⇐

  # time is relative to when you started the clock
  # clock.startTime
  startTime ⇐ •MonoTime@
  lastTime ← 0
  
  delta ⇐ 0
  frame ⇐ 0

  # clock.Time
  Time  ⇐ {𝕊:startTime-˜•Monotime@}
  
  # clock.Tick
  Tick ⇐ {𝕊:
    frame+↩1
    delta ↩ lastTime-˜startTime-˜•MonoTime@
    lastTime ↩ startTime-˜•MonoTime@
    delta
  }
}

mouse ← {
  # mouse.GetPos
  GetPos     ⇐ {𝕤
    NeedsWindow@
    raylib.GetMousePosition⟨⟩
  }
  # mouse.WheelMoved
  WheelMoved ⇐ {𝕤
    NeedsWindow@
    raylib.GetMouseWheelMove⟨⟩
  }
  # mouse.IsButtonDown
  IsButtonDown ⇐ {
    NeedsWindow@
    "Mouse button doesn't exist. (𝕩∊↕7)"!∨´⥊𝕩∊↕buttons
    raylib.IsMouseButtonDown⚇0 𝕩
  }
  buttons ← 7
  # mouse.button.
  button ⇐ {
    left‿right‿middle‿side‿extra‿forward‿back ⇐ ↕buttons
  }
  # mouse.cursor.
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

# Wave, audio wave data
sound ⇐ {
  wave ⇐ {
    ⟨LoadFromFile ⋄ Unload ⋄ _withFile⟩⇐

    # sound.wave.LoadFromFile
    LoadFromFile ⇐ {𝕊filePath:
      {!"Path given wasn't absolute 𝕩≡"∾•Repr𝕩}⍟("."⊸•file.At⊸≢)𝕩
      {𝕊:!"Couldn't find file at "∾•file.RealPath filePath}⍟¬•file.Exists 𝕩
    
      bqnSound ← {
        freq‿format‿bqnSound ← bqnoise.ReadFull filePath
        ⌊∘÷⟜(2⋆¯16+1⊑format) bqnSound bqnoiseOptions.Resample˜ freq∾bqnoiseOptions.freq
      }
      ⟨
        1⊑≢bqnSound   # frameCount
        bqnoiseOptions.freq  # sampleRate
        1⊑bqnoiseOptions.fmt # sampleSize
        ≠bqnSound     # channels
        { # *data
          data ← ⥊⍉bqnSound
          {↕∘≠⊸(𝕩.Write¨) data}⊸⊢(raylib.MemAlloc 2×≠data).Cast "i16"
        }
      ⟩
    }

    # sound.wave.Unload
    Unload ⇐ raylib.MemFree 4⊸⊑

    # sound.wave._withFile
    _withFile ⇐ {(Unload⊢𝔽)LoadFromFile}
  }

  # sound.FromFile
  FromFile ⇐ raylib.LoadSoundFromWave wave._withFile # fileName→Sound
  
  # sound.Play
  Play ⇐ raylib.PlaySound
  _withAudio ⇐ {
    raylib.CloseAudioDevice∘⟨⟩⊢𝔽⊣raylib.InitAudioDevice∘⟨⟩
  }
}

key ← {
  
  # key.IsPressed
  IsPressed ⇐ {𝕊 key:
    raylib.IsKeyPressed @-˜⍟<𝕩
  }⚇0⊣NeedsWindow

  # key.IsDown
  IsDown ⇐ {
    raylib.IsKeyDown @-˜⍟<𝕩
  }⚇0⊣NeedsWindow

  # Get key pressed as keycode
  # key.PressedKey
  PressedKey ⇐ {𝕤
    NeedsWindow@
    raylib.GetKeyPressed⟨⟩
  }

  # key.PressedChar
  PressedChar ⇐ {𝕤
    NeedsWindow@
    @+raylib.GetcharPressed⟨⟩
  }

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