## Conventions:
# One big goal of this lib is to eliminate as many bugs of raylib as possible,
# for example, opening the window twice is impossible because it is not intended in raylib, and causes many bugs.

# x and y as variables (also x1 y1, x2 y2 etc) are always positions

# -------
# Exports
⟨
  draw, texture, monitor, window, mouse
  font, key, clipboard, StartClock
  sound, bqnoise, math, camera, image, model, low, log
⟩⇐

⟨
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
  rlglValues⇐rlgl
⟩ ⇐ ⟨
  gamepadButton, gamepadAxis
  bqnFontChars
  windowConfigFlags
  traceLogLevel
⟩ ← •Import "src/constants.bqn"

# Check if CBQN was compiled with FFI
(⊑⟨"ffi"⟩∊•listsys)!˜"CBQN compiled without ffi (FFI=0)"

{!"git-submodules "∾(•Repr𝕩)∾" not found.
Use the following command to install the neccessary git submodules:

  git submodule update --init --recursive
"}⍟(0≠≠){¬•file.Exists"imports"•file.At𝕩}¨⊸/ "bqn-libs"‿"BQN386"‿"BQNoise"‿"raylib-bqn"

# -------
# internal functions
NeedsWindow ← {window.isOpen?𝕩;!"Expected window to be open"}
# -------

# -------
# Imports
raylib  ⇐ ⟨•file⟩ •Import "src/loadRaylib.bqn"
math ← •Import "src/math.bqn"
image   ← NeedsWindow‿raylib •Import "src/image.bqn"
low     ← •Import "src/low.bqn"
bqnoise ← •Import "imports/BQNoise/wav.bqn"
bqnoiseOptions ← •Import "imports/BQNoise/options.bqn"
camera ← @ # has rayed.bqn as a dependency. camera is defined later in rayed.bqn.
# -------

# -------
# defaults
raylib.SetTraceLogLevel traceLogLevel.warning # makes logs not output "INFO:" logs to stdOut
# -------

# -------
# constants
i32_max ← ¯1+2⋆31
i32_min ← -2⋆31
# -------

log ← {
  # log.setLevel
  setLevel ⇐ {
    S‿t ← raylib.SetTraceLogLevel‿traceloglevel
    All     ⇐ S∘t.all     # Display all logs
    Trace   ⇐ S∘t.trace   # Trace logging, intended for internal use only
    Debug   ⇐ S∘t.debug   # Debug logging, used for internal debugging, it should be disabled on release builds
    Info    ⇐ S∘t.info    # Info logging, used for program execution info
    Warning ⇐ S∘t.warning # Warning logging, used on recoverable failures
    Error   ⇐ S∘t.error   # Error logging, used on unrecoverable failures
    Fatal   ⇐ S∘t.fatal   # Fatal logging, used to abort program: exit(EXIT_FAILURE)
    None    ⇐ S∘t.none    # Disable logging
  }
}

texture ← {
  ⟨ Load ⋄ Unload ⋄ LoadFromImage ⋄ Update
  _WithImage ⋄ _withFile ⋄ _WithRayImage ⟩⇐
  # texture.Load
  Load ← {𝕊filePath: # Load texture from file into GPU memory (VRAM)
    NeedsWindow@
    {!"Path given wasn't absolute 𝕩≡"∾•Repr𝕩}⍟("."⊸•file.At⊸≢)𝕩
    {𝕊:!"Couldn't find file at "∾filePath}⍟¬•file.Exists 𝕩   #TODO verify if the error message errors when file doesn't exist.
    raylib.LoadTexture 𝕩
  }
  # texture.Unload
  Unload ← {𝕊texture:
    NeedsWindow@
    @⊣raylib.UnloadTexture𝕩
  }
  # texture.LoadFromImage
  LoadFromImage ← {
    NeedsWindow@
    raylib.LoadTextureFromImage image._AsRayImg 𝕩
  }
  # texture.Update
  Update ← {image𝕊texture:
    NeedsWindow@
    raylib.UpdateTextureRaw⟨texture⋄⥊image⟩
  }
  # texture._withFile
  _withFile ← {𝔽_𝕣 filePath:
    (Unload⊢𝔽)Load𝕩
  }
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

  notAMonitorErr ← "Invalid monitor 𝕩, can only be @ for currently selected monitor or a monitor number; ( ∊⟜(↕monitor.Count@)⌾<𝕩 ) v ( 𝕩≡@ )"
  M ← @⊸≢◶Selected‿{𝕩⊣notAMonitorErr!∊⟜(↕Count@)⌾<𝕩} # No need for NeedsWindow because Selected and Count need it so error still works

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
    _openAs ⋄ Open ⋄ Close ⋄ isOpen ⋄ SetIcon ⋄ GetFPS ⋄ SetFPS ⋄ GetSize
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
  GetPos ← {𝕊:isopen?
    raylib.GetWindowPosition⟨⟩
  ;
    tempPos
  }

  # Set the x‿y position of the window   (relative to current monitor?)
  # window.SetPos
  tempPos ← 0‿0
  SetPos ← {isopen?
    raylib.SetWindowPosition⊸⊢𝕩
  ;
    tempPos ↩ 2⥊𝕩
  }

  # tempSize is used to store size until window is open
  tempSize ← 0‿0

  # Set the width and hight of the window, width and hight being relative to window position
  # window.SetSize
  SetSize ← {𝕊size:
    ((⌈⊸≡∨⊢≡0⌈1⌊⊢)𝕩)!˜"Size can only be between 0 and 1, or a positive whole number"
    ((⟨⟩⊸≡∨⟨2⟩⊸≡)≢𝕩)!˜"Size can be a scalar (⟨⟩≢≢𝕨) or length two list (⟨2⟩≡≢𝕨)"
    isOpen?

      #TODO: instead of error, save the size for when you make the window normal again.
      "Cannot set window size while it's maximized"!¬raylib.IsWindowMaximized⟨⟩
      "Cannot set window size while it's minimized"!¬raylib.IsWindowMinimized⟨⟩

      s ← (raylib.GetMonitorWidth ∾ raylib.GetMonitorHeight) raylib.GetCurrentMonitor⟨⟩
      f ← (1⊸>∧0⊸≤)𝕩
      # if given size is 0-1, scale the window relative to monitor size
      raylib.SetWindowSize ⌈2⥊s×⟜¬⌾(f⊸/)2⥊𝕩
  ;
    tempSize↩2⥊𝕩
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
    # Errors
    (¬isOpen)!˜"The window cannot be opened twice"
    "Cannot set fullscreen and set window size to non-0" !¬ IsFullscreen⊸∧0‿0≢tempSize

    # startup
    raylib.SetConfigFlags flags←2⊸×⊸+˜´GetState@
    raylib.InitWindow 400‿400‿𝕩
    isOpen↩1
    raylib.SetExitKey 0 # 0 means no key, essentially removing esc key closing programs implicitly

    # constants
    s ← (raylib.GetMonitorWidth ∾ raylib.GetMonitorHeight) raylib.GetCurrentMonitor⟨⟩
    isScaling ← (1⊸>∧0⊸≤)tempSize # if given size is 0-1, scale the window relative to monitor size
    windowSize ← ⌈{∨´isScaling?isScaling/s;⟨⟩}⊸×⟜¬⌾(isScaling⊸/)tempSize

    raylib.SetWindowPosition {
      •platform.os≡"windows"?
        IsDecorated⊸∧ ¬IsFullscreen@?
          0‿42+𝕩  # 42 here is the window header on windows only
      ; 𝕩
    } tempPos

    raylib.SetWindowSize windowSize

    # Setting fps to the refresh rate of the currently selected monitor
    SetFPS raylib.GetMonitorRefreshRate raylib.GetCurrentMonitor⟨⟩
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
  _openAs ← {App _𝕣 title:
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
  # window.GetFPS
  GetFPS ⇐ {𝕤
    NeedsWindow@
    raylib.GetFPS⟨⟩
  }
  # window.SetFPS
  SetFPS ⇐ {𝕊fps:
    NeedsWindow@
    ((∞=𝕩) ∨ 0≤𝕩)!˜"FPS has to be a non-negative number"
    𝕩⊣raylib.SetTargetFPS i32_max⌊0⍟(∞⊸=)⌈𝕩
  }
  # window.Screenshot
  Screenshot ← {𝕊:
    NeedsWindow@
    raylib.LoadImageFromScreen⟨⟩
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
  IWS ← raylib.IsWindowState
  cs ← raylib.ClearWindowState‿raylib.SetWindowState
  cf ← configFlags

  B←"Boolean required"!∊⟜(↕2)⌾<
  SetFullscreen        ⇐ {B𝕩 ⋄ fullscreen        ↩ 𝕩 ⊣ raylib.ToggleFullscreen∘⟨⟩⍟(𝕩≠IWS)⍟isopen cf.fullscreen_mode} # window.SetFullscreen
  SetResizable         ⇐ {B𝕩 ⋄ resizable         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_resizable         } # window.SetResizable
  SetDecorated         ⇐ {B𝕩 ⋄ decorated         ↩ 𝕩 ⊣ ¬∘𝕩◶cs⍟isOpen cf.window_undecorated       } # window.SetDecorated
  SetTransparent       ⇐ {B𝕩 ⋄ transparent       ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_transparent       } # window.SetTransparent
  Setmsaa4xhint        ⇐ {B𝕩 ⋄ msaa4xhint        ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.msaa4xhint               } # window.Setmsaa4xhint
  Setvsynchint         ⇐ {B𝕩 ⋄ vsyncHint         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.vsync_hint               } # window.Setvsynchint
  SetHidden            ⇐ {B𝕩 ⋄ hidden            ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_hidden            } # window.SetHidden
  SetRunWhileMinimized ⇐ {B𝕩 ⋄ runWhileMinimized ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_always_run        } # window.SetRunWhileMinimized
  SetMinimized         ⇐ {B𝕩 ⋄ minimized         ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_minimized         } # window.SetMinimized
  SetMaximized         ⇐ {B𝕩 ⋄ maximized         ↩ 𝕩 ⊣   raylib.MaximizeWindow∘⟨⟩⍟(𝕩=IWS)⍟isOpen cf.window_maximized} # window.SetMaximized
  SetFocused           ⇐ {B𝕩 ⋄ focused           ↩ 𝕩 ⊣ ¬∘𝕩◶cs⍟isOpen cf.window_unfocused         } # window.SetFocused
  SetTopmost           ⇐ {B𝕩 ⋄ topmost           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_topmost           } # window.SetTopmost
  SetHighDPI           ⇐ {B𝕩 ⋄ highDPI           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_highDPI           } # window.SetHighDPI
  SetMousePassThrough  ⇐ {B𝕩 ⋄ topmost           ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_mouse_passthrough } # window.SetMousePassThrough
  SetInterlacedhint    ⇐ {B𝕩 ⋄ interlacedhint    ↩ 𝕩 ⊣   𝕩◶cs⍟isOpen cf.window_interlacedhint    } # window.SetInterlacedhint

  IsFullscreen        ⇐ {𝕊: isOpen?  IWS cf.fullscreen_mode          ; fullscreen        }
  IsResizable         ⇐ {𝕊: isOpen?  IWS cf.window_resizable         ; resizable         }
  IsDecorated         ⇐ {𝕊: isOpen? ¬IWS cf.window_undecorated       ; decorated         }
  IsTransparent       ⇐ {𝕊: isOpen?  IWS cf.window_transparent       ; transparent       }
  IsMsaa4xhint        ⇐ {𝕊: isOpen?  IWS cf.msaa4xhint               ; msaa4xhint        }
  IsVsyncHint         ⇐ {𝕊: isOpen?  IWS cf.vsync_hint               ; vsyncHint         }
  IsHidden            ⇐ {𝕊: isOpen?  IWS cf.window_hidden            ; hidden            }
  IsRunWhileMinimized ⇐ {𝕊: isOpen?  IWS cf.window_always_run        ; runWhileMinimized }
  IsMinimized         ⇐ {𝕊: isOpen?  IWS cf.window_minimized         ; minimized         }
  IsMaximized         ⇐ {𝕊: isOpen?  IWS cf.window_maximized         ; maximized         }
  IsFocused           ⇐ {𝕊: isOpen? ¬IWS cf.window_unfocused         ; focused           }
  IsTopmost           ⇐ {𝕊: isOpen?  IWS cf.window_topmost           ; topmost           }
  IsHighDPI           ⇐ {𝕊: isOpen?  IWS cf.window_highDPI           ; highDPI           }
  IsMousePassThrough  ⇐ {𝕊: isOpen?  IWS cf.window_mouse_passthrough ; mousePassThrough  }
  IsInterlacedhint    ⇐ {𝕊: isOpen?  IWS cf.window_interlacedhint    ; interlacedhint    }

  # window.stateNames
  stateNames ← ⟨
    "fullscreen"
    "resizable"
    "undecorated"
    "transparent"
    "msaa4xhint"
    "vsyncHint"
    "hidden"
    "runWhileMinimized"
    "minimized"
    "maximized"
    "unfocused"
    "topmost"
    "highDPI"
    "mousePassThrough"
    "interlacedhint"
  ⟩
  # window.GetState
  GetState ← {𝕤 # returns binary list that corrisponds to raylib's config_flags format
    0‿fullscreen‿resizable‿(¬decorated)‿transparent‿msaa_4x_hint‿vsync_hint‿hidden‿runWhileMinimized‿minimized‿maximized‿(¬focused)‿topmost‿highdpi‿mouse_passthrough‿0‿interlaced_hint
  }
}

# Drawing
draw ← {
  ⟨
    _withCanvas ⋄ advanced
    _in3D ⋄ _in2D
    _withBlend ⋄ _withShader
    _inRectangle ⋄ _inTexture
    Rectangle ⋄ Triangle
    Circle ⋄ Ellipse ⋄ EllipseOutline
    Line ⋄ ThickLine
    Poly ⋄ PolyLines
    Text ⋄ Texture
  ⟩⇐

  isDrawing ← 0

  # Start 3d mode, drawing relative to camera using 𝔽, then ends 3d mode
  # draw._in3D
  _in3D ← {𝕨 Drawing3D _𝕣 camera:
    NeedsWindow@          # pos  target up   FOV Camera projection type
    "_in3D: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iii"‿"iii"‿"iii"‿'i'‿'i'
    raylib.BeginMode3D 𝕩
    raylib.EndMode3D∘⟨⟩⊸⊢𝔽𝕩
  }

  # Start 2d mode, drawing relative to camera using 𝔽, then ends 2d mode
  # draw._in2D
  _in2D ← {𝕨 Drawing2D _𝕣 offset‿target‿rotation‿zoom:
    NeedsWindow@          # pos  target up   FOV Camera projection type
    "_in2D: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"ii"‿"ii"‿'i'‿'i'
    raylib.BeginMode2D 𝕩
    raylib.EndMode2D∘⟨⟩⊸⊢𝔽𝕩
  }

  # Start drawing, draw background as color 𝕩, use function 𝔽𝕨, end drawing
  # draw._WithCanvas
  _withCanvas ← {𝕨DrawingFunc _𝕣 color: arg←𝕨⊣@
    NeedsWindow@
    "Canvas is already being drawn"!¬isDrawing
    "_WithCanvas only accepts 𝕩 as a color; 4 ints in the range 0-255 inclusive"!∧´⟨
      𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"
      ∧´(255⊸≥∧0⊸≤)𝕩
    ⟩
    raylib.BeginDrawing⟨⟩
    isDrawing↩1
    raylib.ClearBackground 𝕩
    {isDrawing↩0}∘raylib.EndDrawing∘⟨⟩⊸⊢𝔽arg
  }

  # draw._inTexture
  _inTexture ← {𝔽 _𝕣 texture:
    raylib.BeginTextureMode𝕩
    raylib.EndTextureMode∘⟨⟩⊸⊢ 𝔽𝕩
  }

  # draw._withShader
  _withShader ← {
    raylib.BeginShaderMode𝕩
    raylib.EndShaderMode∘⟨⟩⊸⊢𝔽𝕩
  }

  # draw._inRectangle
  _inRectangle ← {
    raylib.BeginScissorMode (⊣∾-˜)˝∧˘⌾⍉i32_max⌊0⌈⌊𝕩
    raylib.EndScissorMode∘⟨⟩⊸⊢𝔽𝕩
  }

  _withBlend ← {
    raylib.BeginBlendMode𝕩
    raylib.EndBlendMode∘⟨⟩⊸⊢𝔽𝕩
  }

  # Draw text at x‿y in given font, color, and size
  # draw.Text
  Text ← {𝕨𝕊⟨x‿y⋄text⟩: t←⟨r‿g‿b‿a⋄font⋄fontSize⋄spacing⟩ ⇐ ∾⟜1⍟(3≡≠)𝕨
    NeedsWindow@
    "Text: wrong types as input"!t‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿("iii"∾(5⥊'i')‿'n'‿'n')‿'i'‿'i'⋄"ii"⋈'c'¨text⟩
    raylib.DrawTextCodepoints ⟨font⋄text-@⋄≠text⋄x‿y⋄fontSize⋄spacing⋄r‿g‿b‿a⟩
  }

  # Draw line from x1‿y1 to x2‿y2
  # draw.Line
  Line ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    "Line: wrong types as input"!𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"⋄2‿2⥊'i'⟩
    raylib.DrawLineEx(<˘𝕩)∾1⋈𝕨
  }⎉1‿2

  # Draw line with a specified thickness
  # draw.ThinckLine
  ThickLine ← {⟨r‿g‿b‿a⋄thickness⟩𝕊[x1‿y1⋄x2‿y2]:
    "Line: wrong types as input"!𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿'i'⋄2‿2⥊'i'⟩
    raylib.DrawLineEx(<˘𝕩)∾⌽𝕨
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
    raylib.DrawRectangleV 𝕨∾⟜<˜(⊣⋈-˜)˝∧˘⌾⍉i32_max⌊i32_min⌈⌊𝕩 # capping with max and min to avoid errors at ∞
  }⎉1‿2

  # draw.Ellipse
  Ellipse ← {r‿g‿b‿a𝕊[x1‿y1⋄x2‿y2]:
    NeedsWindow@
    𝕩(i32_max⌊i32_min⌈⌊)↩
    ((∧´⌈⊸=∧0⊸≤∧≤⟜255)𝕨)!˜"𝕨 (color) only accepts ints in the range 0-255 inclusive"
    raylib.DrawEllipse 𝕨∾⟜<˜(⌈∾⊢-⊏∘𝕩)(+˝÷≠)𝕩
  }⎉1‿2

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
  }⎉1‿2

  # draw.Triangle
  Triangle ← {color𝕊[x1‿y1⋄x2‿y2⋄x3‿y3]:
    [p1,p2,p3] ← 𝕩
    raylib.DrawTriangle p1‿𝕨∾˜p2‿p3⌽˜ π< (2×π)| p3-○(•math.Atan2´p2⊸-)p1
  }⎉1‿2

  # draw.Poly
  Poly ← {color𝕊⟨p1⋄sides⋄radius⋄rotation⟩:
    NeedsWindow@
    raylib.DrawPoly p1‿sides‿radius‿rotation‿𝕨
  }⎉1‿2

  # draw.PolyLines
  PolyLines ← {⟨r‿g‿b‿a⋄thickness⟩𝕊𝕩:
    NeedsWindow@
    "PolyLines: wrong types as input"!𝕨‿𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨"iiii"‿'i'⋄"ii"‿'i'‿'i'‿'i'⟩
    raylib.DrawPolyLinesEx 𝕩∾⌽𝕨
  }⎉1‿2

  # These aren't recommended because they are useless if you use _WithCanvas.
  # They also don't behave well if ran in the wrong order,
  # you only want to run them in the "start, background, end" sequence
  advanced ⇐ {
    Start‿Background‿End⇐

    # draw.advanced.Start
    Start ← {𝕤
      NeedsWindow@
      raylib.BeginDrawing⟨⟩
    }
    # draw.advanced.Background
    Background ← {𝕊r‿g‿b‿a:
      NeedsWindow@
      "Background: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iiii"
      (∧´(255⊸≥∧>0⊸≤)𝕩)!˜"ClearBackground only accepts ints in the range 0-255 inclusive"
      raylib.ClearBackground 𝕩
    }
    # draw.advanced.End
    End ← {𝕤
      NeedsWindow@
      raylib.EndDrawing⟨⟩
    }
  }
}
font ← {
  ⟨ Load ⋄ LoadBQN ⋄ LoadRaylib ⋄ Unload ⟩⇐
  IsValid ← {
    (𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iii"∾"iiiii"<⊸∾⋈˜'n')!˜"Expected a valid font"
    𝕩⊣(¬∨´low.IsNull¨¯2↑𝕩)!˜"Invalid font. font has null pointers, likely due to unsuported format."
  }
  glyphInfo ← {value‿offsetX‿offsetY‿advanceX‿image⇐↕5}             # The namespace is for eliminating magic-numbers

  # font.Unload
  Unload ⇐ {
    NeedsWindow@
    IsValid 𝕩
    raylib.UnloadFont 𝕩
  }
  # font.Load
  Load ⇐ {
    𝕊size‿fileType‿fontFileChars:
      𝕩𝕊˜' '+↕95
  ;
    charactersAllowed 𝕊 size‿fileType‿fontFileChars:
      NeedsWindow@
      log.setLevel.Error@
      r←raylib.LoadFontFromMemory⟨fileType⋄fontFileChars⋄≠fontFileChars⋄size⋄@-˜charactersAllowed⋄≠charactersAllowed⟩
      r⊣log.setLevel.Warning@
  }

  # font.LoadFile
  # Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  LoadFile ⇐ {
    𝕊size‿filePath:
      𝕩𝕊˜' '+↕95
  ;
    charactersAllowed 𝕊 size‿filePath:
      NeedsWindow@
      {!"Path given wasn't absolute: "∾•Repr𝕩}⍟("."⊸•file.At⊸≢)filePath
      {!"Couldn't find file: "∾•Repr𝕩}⍟(¬•file.Exists) filePath

      log.setLevel.Error@
      r←raylib.LoadFontEx ⟨filePath⋄size⋄𝕨-@⋄≠𝕨⟩
      r⊣log.setLevel.Warning@
  }

  # font.LoadBQN
  LoadBQN ← {𝕊fontSize: fontSize 100⍟(@⊸≡)↩
    NeedsWindow@
    file ← •file.RealPath ("Expected file at: "⊸∾!•file.Exists)⊸⊢ •file.At "imports/BQN386/BQN386.ttf"
    log.setLevel.Error@
    r←raylib.LoadFontEx⟨file⋄fontSize⋄bqnFontChars-@⋄≠bqnFontChars⟩
    r⊣log.setLevel.Warning@
  }
  # font.LoadRaylib
  LoadRaylib ← {𝕊@:
    NeedsWindow@
    raylib.GetFontDefault⟨⟩
  }
}
clipboard ← {
  ⟨Get ⋄ Set⟩⇐
  ⟨ToBytes⟩ ← •Import "imports/bqn-libs/strings.bqn"

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
  ⟨
    Time ⋄ Tick
    startTime ⋄ delta ⋄ frame
  ⟩⇐

  # time is relative to when you started the clock
  lastTime ← 0
  startTime ⇐ •MonoTime@ # clock.startTime
  delta ⇐ 0 # clock.delta
  frame ⇐ 0 # clock.frame

  # clock.Time
  Time ⇐ {𝕊:startTime-˜•Monotime@}

  # clock.Tick
  Tick ⇐ {𝕊:
    frame+↩1
    delta ↩ lastTime-˜startTime-˜•MonoTime@
    lastTime ↩ startTime-˜•MonoTime@
    delta
  }
}

mouse ← {

  # mouse.buttonCount
  buttonCount ⇐ 7

  # mouse.button.
  button ⇐ {
    left‿right‿middle‿side‿extra‿forward‿back ⇐ ↕buttonCount
    IsDown‿IsPressed‿IsReleased‿IsUp⇐
    IsMouseButton ← "Mouse button doesn't exist. (𝕩∊↕7)"⊸!∘⊑∘∊⟜(↕buttonCount)⚇0

    # mouse.button.IsDown
    IsDown ⇐ {𝕊mouseButton:
      NeedsWindow@
      IsMouseButton 𝕩
      raylib.IsMouseButtonDown⚇0 𝕩
    }
    # mouse.button.IsPressed
    IsPressed ⇐ {𝕊mouseButton:
      NeedsWindow@
      IsMouseButton 𝕩
      raylib.IsMouseButtonPressed⚇0 𝕩
    }
    # mouse.button.IsReleased
    IsReleased ⇐ {𝕊mouseButton:
      NeedsWindow@
      IsMouseButton 𝕩
      raylib.IsMouseButtonReleased⚇0 𝕩
    }
    # mouse.button.IsUp
    IsUp ⇐ {𝕊mouseButton:
      NeedsWindow@
      IsMouseButton 𝕩
      raylib.IsMouseButtonUp⚇0 𝕩
    }
  }
  # mouse.GetPos
  GetPos     ⇐ {𝕊:
    NeedsWindow@
    raylib.GetMousePosition⟨⟩
  }
  # mouse.SetPos
  SetPos     ⇐ {𝕊x‿y:
    NeedsWindow@
    raylib.SetMousePosition x‿y
  }
  # mouse.GetDelta
  GetDelta ⇐ {𝕊:
    NeedsWindow@
    raylib.GetMouseDelta⟨⟩
  }
  # mouse.SetOffset
  SetOffset ⇐ {𝕊offsetX‿offsetY:
    NeedsWindow@
    raylib.SetMouseOffset ⌊𝕩
  }
  # mouse.SetScale
  SetScale ⇐ {𝕊scaleX‿scaleY:
    NeedsWindow@
    raylib.SetMouseScale 𝕩
  }
  # mouse.WheelMoved
  WheelMoved ⇐ {𝕊:
    NeedsWindow@
    raylib.GetMouseWheelMove⟨⟩
  }

  cursor ⇐ {
    # mouse.cursor.Show
    Show ⇐ {𝕊:
      NeedsWindow@
      𝕩⊣raylib.ShowCursor⟨⟩
    }
    # mouse.cursor.Hide
    Hide ⇐ {𝕊:
      NeedsWindow@
      𝕩⊣raylib.HideCursor⟨⟩
    }
    # mouse.cursor.IsHidden
    IsHidden ⇐ {𝕊:
      NeedsWindow@
      𝕩⊣raylib.IsCursorHidden⟨⟩
    }
    # mouse.cursor.Enable
    Enable ⇐ {𝕊:
      NeedsWindow@
      𝕩⊣raylib.EnableCursor⟨⟩
    }
    # mouse.cursor.Disable
    Disable ⇐ {𝕊:
      NeedsWindow@
      𝕩⊣raylib.DisableCursor⟨⟩
    }
    # mouse.cursor.IsOnScreen
    IsOnScreen ⇐ {𝕊:
      NeedsWindow@
      𝕩⊣raylib.IsCursorOnScreen⟨⟩
    }
    # mouse.cursor.Set
    Set ⇐ {
      NeedsWindow@
      𝕩⊣raylib.SetMouseCursor 𝕩
    }

    # mouse.cursor.shape
    shape ⇐ {
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
}

# Wave, audio wave data
sound ⇐ {
  ⟨
    Play ⋄ Stop ⋄ Pause ⋄ Resume ⋄ IsPlaying
    SetVolume ⋄ SetPitch ⋄ SetPan
    LoadFromFile ⋄ Unload
    _withDevice ⋄ wave
  ⟩⇐
  audioReady ← 0
  NeedsAudio ← { # Everything that needs audio also needs the window to be open
    NeedsWindow@
    𝕩⊣"Audio not started, run audio with sound._withDevice"!audioReady
  }
  wave ⇐ {
    ⟨LoadFromFile ⋄ Unload ⋄ _withFile⟩⇐

    # sound.wave.LoadFromFile
    LoadFromFile ⇐ {𝕊filePath:
      {!"Path given wasn't absolute 𝕩≡"∾•Repr𝕩}⍟("."⊸•file.At⊸≢)𝕩
      {𝕊:!"Couldn't find file at "∾filePath}⍟¬•file.Exists 𝕩

      bqnSound ← {
        freq‿format‿bqnSound ← bqnoise.ReadFull filePath
        ⌊∘÷⟜(2⋆¯16+1⊑format) freq‿bqnoiseOptions.freq bqnoiseOptions.Resample⍟(≢´⊣) bqnSound
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
    Unload ⇐ {𝕊frameCount‿sampleRate‿sampleSize‿channels‿data:
      raylib.MemFree data
    }
    # sound.wave._withFile
    _withFile ⇐ {(Unload⊢𝔽)LoadFromFile}
  }
  # sound._withDevice
  _withDevice ⇐ {𝕨𝔽_𝕣𝕩:
    NeedsWindow@
    raylib.InitAudioDevice⟨⟩
    audioReady ↩ 1
    r←𝕨𝔽𝕩
    raylib.CloseAudioDevice⟨⟩
    audioReady ↩ 0
    r
  }
  # sound.LoadFromFile
  LoadFromFile ⇐ {𝕊:
    NeedsAudio@
    raylib.LoadSoundFromWave 𝕩
  } wave._withFile
  # sound.Play
  Play  ⇐ {𝕊sound:
    NeedsAudio@
    raylib.PlaySound 𝕩
  }
  # sound.Stop
  Stop  ⇐ {𝕊sound:
    NeedsAudio@
    raylib.StopSound 𝕩
  }
  # sound.Pause
  Pause ⇐ {𝕊sound:
    NeedsAudio@
    raylib.PauseSound𝕩
  }
  # sound.Resume
  Resume ⇐ {𝕊sound:
    NeedsAudio@
    raylib.ResumeSound 𝕩
  }
  # sound.IsPlaying
  IsPlaying ⇐ {𝕊sound:
    NeedsAudio@
    raylib.IsSoundPlaying 𝕩
  }
  # sound.SetVolume
  SetVolume ⇐ {volume𝕊sound:
    "Volume must be a number"!0≡•Type𝕨
    NeedsAudio@
    raylib.SetSoundVolume 𝕩‿𝕨
  }
  # sound.SetPitch
  SetPitch ⇐ {pitch𝕊sound:
    "Pitch must be a number"!0≡•Type𝕨
    NeedsAudio@
    raylib.SetSoundPitch 𝕩‿𝕨
  }
  # sound.SetPan
  SetPan ⇐ {pan𝕊sound:
    "Pan must be a number"!0≡•Type𝕨
    NeedsAudio@
    raylib.SetSoundPan 𝕩‿𝕨
  }
  # sound.Unload
  Unload ⇐ raylib.UnloadSound
}

#gamepad ← {
#  button‿axis⇐gamepadButton‿gamepadAxis
#
#  unknown          ⇐ 0   # Unknown button, just for error checking
#  left_face_up     ⇐ 1   # Gamepad left DPAD up button
#  left_face_right  ⇐ 2   # Gamepad left DPAD right button
#  left_face_down   ⇐ 3   # Gamepad left DPAD down button
#  left_face_left   ⇐ 4   # Gamepad left DPAD left button
#  right_face_up    ⇐ 5   # Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
#  right_face_right ⇐ 6   # Gamepad right button right (i.e. PS3: Square, Xbox: X)
#  right_face_down  ⇐ 7   # Gamepad right button down (i.e. PS3: Cross, Xbox: A)
#  right_face_left  ⇐ 8   # Gamepad right button left (i.e. PS3: Circle, Xbox: B)
#  left_trigger_1   ⇐ 9   # Gamepad top/back trigger left (first), it could be a trailing button
#  left_trigger_2   ⇐ 10  # Gamepad top/back trigger left (second), it could be a trailing button
#  right_trigger_1  ⇐ 11  # Gamepad top/back trigger right (one), it could be a trailing button
#  right_trigger_2  ⇐ 12  # Gamepad top/back trigger right (second), it could be a trailing button
#  middle_left      ⇐ 13  # Gamepad center buttons, left one (i.e. PS3: Select)
#  middle           ⇐ 14  # Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
#  middle_right     ⇐ 15  # Gamepad center buttons, right one (i.e. PS3: Start)
#  left_thumb       ⇐ 16  # Gamepad joystick pressed button left
#  right_thumb      ⇐ 17  # Gamepad joystick pressed button right
#
#  ps4 ← {
#    x ⇐ right_face_down
#    o ⇐ right_face_left
#    square ⇐ right_face_right
#    triangle ⇐ right_face_up
#  }
#  xboxButton ←

# isGamepadAvailable
# getGamepadName
# isGamepadButtonPressed
# isGamepadButtonDown
# isGamepadButtonReleased
# isGamepadButtonUp
# getGamepadButtonPressed
# getGamepadAxisCount
# getGamepadAxisMovement
# setGamepadMappings
# setGamepadVibration

#}

key ← {
  IsKey ⇐ ("Key doesn't exist"!0⊸≤∧<⟜512)⚇0 @-˜⍟≤⚇0⊢

  # key.IsPressed
  IsPressed ⇐ {𝕊key:
    NeedsWindow@
    IsKey 𝕩
    (raylib.IsKeyPressed @-˜⍟≤⊢)⚇0 𝕩
  }
  # key.IsPressedRepeat
  IsPressedRepeat ⇐ {𝕊key:
    NeedsWindow@
    IsKey 𝕩
    (raylib.IsKeyPressedRepeat @-˜⍟≤⊢)⚇0 𝕩
  }
  # key.IsReleased
  IsReleased ⇐ {𝕊key:
    NeedsWindow@
    IsKey 𝕩
    (raylib.IsKeyReleased @-˜⍟≤⊢)⚇0 𝕩
  }
  # key.IsKeyUp
  IsKeyUp ⇐ {𝕊key:
    NeedsWindow@
    IsKey 𝕩
    (raylib.IsKeyUp @-˜⍟≤⊢)⚇0 𝕩
  }
  # key.IsDown
  IsDown ⇐ {
    NeedsWindow@
    IsKey 𝕩
    (raylib.IsKeyDown @-˜⍟≤⊢)⚇0 𝕩
  }
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
  zero‿one‿two‿three‿four‿five‿six‿seven‿eight‿nine ⇐ 48+↕10 # 0-9
  semicolon     ⇐ 59       # ;
  equal         ⇐ 61       # =
  a‿b‿c‿d‿e‿f‿g‿h‿i‿j‿k‿l‿m‿n‿o‿p‿q‿r‿s‿t‿u‿v‿w‿x‿y‿z ⇐ 65+↕26 # A-Z | a-z
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
  f1‿f2‿f3‿f4‿f5‿f6‿f7‿f8‿f9‿f10‿f11‿f12 ⇐ 290+↕12 # F1 - F12
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
    zero‿one‿two‿three‿four‿five‿six‿seven‿eight‿nine←320+↕10 # Keypad 0-9
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

# model
model ← {
  ⟨
    LoadFile ⋄ Unload ⋄ Draw ⋄ LoadFromMesh
    GetBoundingBox ⋄ DrawWires ⋄ DrawWiresEx
  ⟩⇐

  # model.LoadFile
  LoadFile ← {𝕊filePath:
    {!"Path given wasn't absolute 𝕩≡"∾•Repr𝕩}⍟("."⊸•file.At⊸≢)𝕩
    {!"Couldn't find file at "∾𝕩}⍟(¬•file.Exists) 𝕩   #TODO verify if the error message errors when file doesn't exist.

    raylib.LoadModel •file.At 𝕩
  }

  # model.Unload
  # Unload model (including meshes) from memory (RAM and/or VRAM)
  Unload ← {𝕊:
    "model.Unload: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡"iinnninn"∾˜<16⥊'i'
    raylib.UnloadModel 𝕩
  }

  # model.Draw
  Draw ← {𝕨𝕊model‿position‿scale‿tint:
    rotationAxis‿rotationAngle←𝕨⊣0‿1‿0⋈0
    scale ⥊˜↩ 3
    {
      "model.Draw: wrong types as input"!𝕩•Type⊸⊑⟜"_icfmdn"⚇0⊸≡⟨
        "iii"⋄"iii"⋄"iinnninn"∾˜<16⥊'i'⋄"iii"⋄"iii"⋄'i'
      ⟩
      raylib.DrawModelEx 𝕩
    } rotationAxis‿rotationAngle‿model‿position‿scale‿tint
  }


  LoadFromMesh ← {raylib.LoadModelFromMesh 𝕩}
  GetBoundingBox ← {raylib.GetModelBoundingBox 𝕩}
  DrawWires ← {raylib.DrawModelWires 𝕩}
  DrawWiresEx ← {raylib.DrawModelWiresEx 𝕩}
}

# Late imports that need rayed.bqn as dependency
camera ↩ key‿mouse‿raylib‿math •Import "src/camera.bqn"


# # TODO add IsImage, IsTexture etc for error checks
#
# # TODO functions left to decide to add
#
# loadFontFromImage
# isWindowState
# isWindowHidden
# isWindowMinimized
# isWindowMaximized
# isWindowFocused
# isWindowResized
# toggleBorderlessWindowed
# restoreWindow
# setWindowIcons
# setWindowMinSize
# setWindowMaxSize
# setWindowOpacity
# setWindowFocused
# getWindowHandle
# getRenderWidth
# getRenderHeight
# getWindowScaleDPI
# beginVrStereoMode
# endVrStereoMode
# loadVrStereoConfig
# unloadVrStereoConfig
# loadShaderFromMemory
# getShaderLocation
# getShaderLocationAttrib
# setShaderValue
# setShaderValueV
# setShaderValueMatrix
# setShaderValueTexture
# unloadShader
# getScreenToWorldRay getScreenToWorldRayEx
# getWorldToScreen getWorldToScreenEx
# getWorldToScreen2D
# getScreenToWorld2D
# takeScreenshot
# openURL
# traceLog
# memRealloc
# setTraceLogCallback
# isFileDropped
# loadDroppedFiles
# unloadDroppedFiles
# getFileModTime
#
# compressData
# decompressData
# encodeDataBase64
# decodeDataBase64
#
# loadAutomationEventList
# unloadAutomationEventList
# exportAutomationEventList
# setAutomationEventList
# setAutomationEventBaseFrame
# startAutomationEventRecording
# stopAutomationEventRecording
# playAutomationEvent
# getTouchX
# getTouchY
# getTouchPosition
# getTouchPointId
# getTouchPointCount
# setGesturesEnabled
# isGestureDetected
# getGestureDetected
# getGestureHoldDuration
# getGestureDragVector
# getGestureDragAngle
# getGesturePinchVector
# getGesturePinchAngle
#
# setShapesTexture
# getShapesTexture
#
# getShapesTextureRectangle
#
# # draw
# drawLineStrip
# drawLineBezier
# drawCircleSector
# drawCircleSectorLines
# drawCircleGradient
# drawCircleLines
# drawRing
# drawRingLines
# drawRectangleRec
# drawRectanglePro
# drawRectangleGradientV
# drawRectangleGradientH
# drawRectangleGradientEx
# drawRectangleLines
# drawRectangleLinesEx
# drawRectangleRounded
# drawRectangleRoundedLines
# drawTriangle
# drawTriangleLines
# drawTriangleFan
# drawTriangleStrip
# drawSplineLinear
# drawSplineBasis
# drawSplineCatmullRom
# drawSplineBezierQuadratic
# drawSplineBezierCubic
# drawSplineSegmentLinear
# drawSplineSegmentBasis
# drawSplineSegmentCatmullRom
# drawSplineSegmentBezierQuadratic
# drawSplineSegmentBezierCubic
# getSplinePointLinear
# getSplinePointBasis
# getSplinePointCatmullRom
# getSplinePointBezierQuad
# getSplinePointBezierCubic
#
# # collision
# checkCollisionRecs
# checkCollisionCircles
# checkCollisionCircleRec
# checkCollisionPointRec
# checkCollisionPointCircle
# checkCollisionPointTriangle
# checkCollisionPointPoly
# checkCollisionLines
# checkCollisionPointLine
# getCollisionRec
#
#
# loadTexture
# loadTextureFromImage
# loadTextureCubemap
# loadRenderTexture
# unloadTexture
# unloadRenderTexture
# updateTexture
# updateTextureRec
# genTextureMipmaps
# setTextureFilter
# setTextureWrap
# drawTextureRec
# drawTexturePro
# drawTextureNPatch
# colorIsEqual
# fade
# colorToInt
# colorNormalize
# colorFromNormalized
# colorToHSV
# colorFromHSV
# colorTint
# colorBrightness
# colorContrast
# colorAlpha
# colorAlphaBlend
# getColor
# getPixelColor
# setPixelColor
# getPixelDataSize
#
# loadFontData
# genImageFontAtlas
# unloadFontData
# unloadFont
# exportFontAsCode
# drawFPS
# drawText
# drawTextEx
# drawTextPro
# drawTextCodepoint
# drawTextCodepoints
# setTextLineSpacing
# measureTextEx
# getGlyphIndex
# getGlyphInfo
# getGlyphAtlasRec
#
# # draw3d
# drawLine3D
# drawPoint3D
# drawCircle3D
# drawTriangle3D
# drawTriangleStrip3D
# drawCube
# drawCubeV
# drawCubeWires
# drawCubeWiresV
# drawSphere
# drawSphereEx
# drawSphereWires
# drawCylinder
# drawCylinderEx
# drawCylinderWires
# drawCylinderWiresEx
# drawCapsule
# drawCapsuleWires
# drawPlane
# drawRay
# drawGrid
#
# # no idea
# drawBoundingBox
# drawBillboard
# drawBillboardRec
# drawBillboardPro
#
# # mesh
# uploadMesh
# updateMeshBuffer
# unloadMesh
# drawMesh
# drawMeshInstanced
# getMeshBoundingBox
# genMeshTangents
# exportMesh
# exportMeshAsCode
# genMeshPoly
# genMeshPlane
# genMeshCube
# genMeshSphere
# genMeshHemiSphere
# genMeshCylinder
# genMeshCone
# genMeshTorus
# genMeshKnot
# genMeshHeightmap
# genMeshCubicmap
#
# # Materials
# loadMaterials
# loadMaterialDefault
# unloadMaterial
# setMaterialTexture
# setModelMeshMaterial
#
# # animations
# loadModelAnimations
# updateModelAnimation
# unloadModelAnimation
# unloadModelAnimations
# isModelAnimationValid
#
# # collision3d
# checkCollisionSpheres
# checkCollisionBoxes
# checkCollisionBoxSphere
# getRayCollisionSphere
# getRayCollisionBox
# getRayCollisionMesh
# getRayCollisionTriangle
# getRayCollisionQuad
#
# # audio
# setMasterVolume
# getMasterVolume
#
# loadWave
# loadWaveFromMemory
#
# loadSound
# loadSoundAlias
# unloadSoundAlias
# updateSound
#
# exportWave
# waveCopy
# waveCrop
# waveFormat
# loadWaveSamples
# unloadWaveSamples
#
# # music
# loadMusicStream
# loadMusicStreamFromMemory
# unloadMusicStream
# playMusicStream
# isMusicStreamPlaying
# updateMusicStream
# stopMusicStream
# pauseMusicStream
# resumeMusicStream
# seekMusicStream
# setMusicVolume
# setMusicPitch
# setMusicPan
# getMusicTimeLength
# getMusicTimePlayed
#
# # audiostream
# loadAudioStream
# unloadAudioStream
# updateAudioStream
# isAudioStreamProcessed
# playAudioStream
# pauseAudioStream
# resumeAudioStream
# isAudioStreamPlaying
# stopAudioStream
# setAudioStreamVolume
# setAudioStreamPitch
# setAudioStreamPan
# setAudioStreamBufferSizeDefault
# setAudioStreamCallback
# attachAudioStreamProcessor
# detachAudioStreamProcessor
# attachAudioMixedProcessor
# detachAudioMixedProcessor
