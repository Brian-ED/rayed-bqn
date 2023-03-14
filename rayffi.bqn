
# making FFI nicer to use
_R ← {𝕨 funcName _𝕣 inpTypes: outType←𝕨⊣⟨⟩
  a←(⋈'>'⊸∾)⍟((0≠≠)∧1=≡)⟨⟩⍟(@⊸≡)𝕩
  "raylib.dll"•FFI⟨outType⋄𝕗⟩∾a
}
Struct ←{'{'∾'}'«∾','∾¨𝕩}
i←"i32"⋄f←"f32"⋄color←"{u8,u8,u8,u8}"⋄str←"&i32:c8"⋄u←"u32"
rectangle ← Struct 4⥊<f

v2 ← "{f32,f32}"
v3 ← "{f32,f32,f32}"

# *v2 means ⟨1‿2, 3‿4, 5‿6⟩ for example
points←'*'∾v2

# Texture, tex data stored in GPU memory (VRAM)
texture←Struct u‿i‿i‿i‿i
# id      # OpenGL texture id
# width   # Texture base width
# height  # Texture base height
# mipmaps # Mipmap levels, 1 by default
# format  # Data format (PixelFormat type)

# Camera2D, defines position/orientation in 2d space
camera2D ←Struct v2‿v2‿f‿f
# offset   # Camera offset (displacement from target)
# target   # Camera target (rotation and zoom origin)
# rotation # Camera rotation in degrees
# zoom     # Camera zoom (scaling), should be 1.0f by default

# Camera, defines position/orientation in 3d space
camera3D ←Struct v3‿v3‿v3‿f‿i
# position   # Camera position
# target     # Camera target it looks-at
# up         # Camera up vector (rotation over its axis)
# fovy       # Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
# projection # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

shader ←"{u32,*i32}"
# Shader program id
# Shader locations array (RL_MAX_SHADER_LOCATIONS)

# Matrix, 4x4 components, column major, OpenGL style, right handed
matrix ←Struct 16⥊<f
# m0 m4 m8  m12
# m1 m5 m9  m13
# m2 m6 m10 m14
# m3 m7 m11 m15

# RenderTexture, fbo for texture rendering
renderTexture ←Struct"u32"<⊸∾2⥊<texture
# OpenGL framebuffer object id
# Color buffer attachment texture
# Depth buffer attachment texture

# VrStereoConfig, VR stereo rendering configuration for simulator
vrStereoConfig ←Struct Struct∘⋈¨(2⥊<matrix)∾6⥊<f
# projection[2]        # VR projection matrices (per eye)
# viewOffset[2]        # VR view offset matrices (per eye)
# leftLensCenter[2]    # VR left lens center
# rightLensCenter[2]   # VR right lens center
# leftScreenCenter[2]  # VR left screen center
# rightScreenCenter[2] # VR right screen center
# scale[2]             # VR distortion scale
# scaleIn[2]           # VR distortion scale in

# Image, pixel data stored in CPU memory (RAM)
image←Struct "*:i32"<⊸∾4⥊<i
# *data   # Image raw data
# width   # Image base width
# height  # Image base height
# mipmaps # Mipmap levels, 1 by default
# format  # Data format (PixelFormat type)


# BQN FFI
readPointer ⇐@•FFI"a"‿"bqn_makeI32Vec"‿"u64"‿"*:i32"

# Window
initWindow        ⇐ "InitWindow"       _R i‿i‿str
windowShouldClose ⇐i"WindowShouldClose"_R@
closeWindow       ⇐ "CloseWindow"      _R@

# Timing-related functions
setTargetFPS ⇐       "SetTargetFPS" _R i # fps # Set target FPS (maximum)
getFPS       ⇐     i "GetFPS"       _R@        # Get current FPS
getFrameTime ⇐     f "GetFrameTime" _R@        # Get time in seconds for last frame drawn (delta time)
getTime      ⇐ "f64" "GetTime"      _R@        # Get elapsed time in seconds since InitWindow()

setWindowIcon ⇐ "SetWindowIcon"_R image

# Input-related functions: keyboard
isKeyPressed   ⇐ "i32" "IsKeyPressed"  _R i # Check if a key has been pressed once
isKeyDown      ⇐ "i32" "IsKeyDown"     _R i # Check if a key is being pressed
isKeyReleased  ⇐ "i32" "IsKeyReleased" _R i # Check if a key has been released once
isKeyUp        ⇐ "i32" "IsKeyUp"       _R i # Check if a key is NOT being pressed
setExitKey     ⇐       "SetExitKey"    _R i # Set a custom key to exit program (default is ESC)
getKeyPressed  ⇐  i    "GetKeyPressed" _R@  # Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
getCharPressed ⇐  i    "GetCharPressed"_R@  # Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty


# Image loading functions
# NOTE: This functions do not require GPU access
loadImage            ⇐ image "LoadImage"           _R str         # fileName                               # Load image from file into CPU memory (RAM)
loadImageRaw         ⇐ image "LoadImageRaw"        _R str‿i‿i‿i‿i # fileName width hight format headerSize # Load image from RAW file data
loadImageAnim        ⇐ image "LoadImageAnim"       _R str‿i       # fileName framesCount                   # Load image sequence from file (frames appended to image.data)
loadImageFromMemory  ⇐ image "LoadImageFromMemory" _R str‿str‿i   # fileType fileData dataSize             # Load image from memory buffer, fileType refers to extension: i.e. '.png'
loadImageFromTexture ⇐ image "LoadImageFromTexture"_R texture     # texture2D                              # Load image from GPU texture data
loadImageFromScreen  ⇐ image "LoadImageFromScreen" _R@                                                     # Load image from screen buffer and (screenshot)
unloadImage          ⇐       "UnloadImage"         _R image                                                # Unload image from CPU memory (RAM)
exportImage          ⇐ i     "ExportImage"         _R image‿str   # image filename                         # Export image data to file, returns true on success
exportImageAsCode    ⇐ i     "ExportImageAsCode"   _R image‿str   # image fileName                         # Export image as code file defining an array of bytes, returns true on success

# Incomplete catagories::

# Image drawing functions
# NOTE: Image software-rendering functions (CPU)
#imageClearBackground ⇐ "ImageClearBackground"_R('*'∾image)‿color # *dst # Clear image background with given color

# Texture drawing functions
drawTexture ⇐ "DrawTexture"_R texture‿i‿i‿color #texture posX posY tint # Draw a Texture2D


# Texture loading functions
# NOTE: These functions require GPU access
loadTexture          ⇐ texture       "LoadTexture"         _R str           # fileName                          # Load texture from file into GPU memory (VRAM)
loadTextureFromImage ⇐ texture       "LoadTextureFromImage"_R image                                             # Load texture from image data
loadTextureCubemap   ⇐ texture       "LoadTextureCubemap"  _R image‿i       # textureCubemap ""_R image layout # Load cubemap from image, multiple image cubemap layouts supported
loadRenderTexture    ⇐ renderTexture "LoadRenderTexture"   _R i‿i           # width height                      # Load texture for rendering (framebuffer)
unloadTexture        ⇐               "UnloadTexture"       _R texture                                           # Unload texture from GPU memory (VRAM)
unloadRenderTexture  ⇐               "UnloadRenderTexture" _R renderTexture # target                            # Unload render texture from GPU memory (VRAM)
updateTexture        ⇐               "UpdateTexture"       _R texture‿"*:i32"                              # Update GPU texture with new data
updateTextureRec     ⇐               "UpdateTextureRec"    _R texture‿rectangle‿"*:i32"                    # Update GPU texture rectangle with new data


# Drawing-related functions
clearBackground   ⇐ "ClearBackground"  _R color                             # Set background color (framebuffer clear color)
beginDrawing      ⇐ "BeginDrawing"     _R@                                  # Setup canvas (framebuffer) to start drawing
endDrawing        ⇐ "EndDrawing"       _R@                                  # End canvas drawing and swap buffers (double buffering)
beginMode2D       ⇐ "BeginMode2D"      _R camera2D                          # Begin 2D mode with custom camera (2D)
endMode2D         ⇐ "EndMode2D"        _R@                                  # Ends 2D mode with custom camera
beginMode3D       ⇐ "BeginMode3D"      _R camera3D                          # Begin 3D mode with custom camera (3D)
endMode3D         ⇐ "EndMode3D"        _R@                                  # Ends 3D mode and returns to default 2D orthographic mode
beginTextureMode  ⇐ "BeginTextureMode" _R renderTexture  # target           # Begin drawing to render texture
endTextureMode    ⇐ "EndTextureMode"   _R@                                  # Ends drawing to render texture
beginShaderMode   ⇐ "BeginShaderMode"  _R shader                            # Begin custom shader drawing
endShaderMode     ⇐ "EndShaderMode"    _R@                                  # End custom shader drawing (use default shader)
beginBlendMode    ⇐ "BeginBlendMode"   _R i              # mode             # Begin blending mode (alpha, additive, multiplied, subtract, custom)
endBlendMode      ⇐ "EndBlendMode"     _R@                                  # End blending mode (reset to default: alpha blending)
beginScissorMode  ⇐ "BeginScissorMode" _R i‿i‿i‿i        # x y width height # Begin scissor mode (define screen area for following drawing)
endScissorMode    ⇐ "EndScissorMode"   _R@                                  # End scissor mode
beginVrStereoMode ⇐ "BeginVrStereoMode"_R vrStereoConfig # config           # Begin stereo rendering (requires VR simulator)
endVrStereoMode   ⇐ "EndVrStereoMode"  _R@                                  # End stereo rendering (requires VR simulator)


# mouse
isMouseButtonPressed  ⇐ i "IsMouseButtonPressed" _R i   # button          # Check if a mouse button has been pressed once
isMouseButtonDown     ⇐ i "IsMouseButtonDown"    _R i   # button          # Check if a mouse button is being pressed
isMouseButtonReleased ⇐ i "IsMouseButtonReleased"_R i   # button          # Check if a mouse button has been released once
isMouseButtonUp       ⇐ i "IsMouseButtonUp"      _R i   # button          # Check if a mouse button is NOT being pressed
getMouseX             ⇐ i "GetMouseX"            _R@                      # Get mouse position X
getMouseY             ⇐ i "GetMouseY"            _R@                      # Get mouse position Y
getMousePosition      ⇐ v2"GetMousePosition"     _R@                      # Get mouse position XY
getMouseDelta         ⇐ v2"GetMouseDelta"        _R@                      # Get mouse delta between frames
setMousePosition      ⇐   "SetMousePosition"     _R i‿i # x y             # Set mouse position XY
setMouseOffset        ⇐   "SetMouseOffset"       _R i‿i # offsetX offsetY # Set mouse offset
setMouseScale         ⇐   "SetMouseScale"        _R f‿f # scaleX scaleY   # Set mouse scaling
getMouseWheelMove     ⇐ f "GetMouseWheelMove"    _R@                      # Get mouse wheel movement for X or Y, whichever is larger
getMouseWheelMoveV    ⇐ v2"GetMouseWheelMoveV"   _R@                      # Get mouse wheel movement for both X and Y
setMouseCursor        ⇐   "SetMouseCursor"       _R i   # cursor          # Set mouse cursor

# Window
setWindowState ⇐ "SetWindowState"_R u # flags # Set window configuration state using flags (only PLATFORM_DESKTOP)

# Basic shapes drawing functions
drawPixel                 ⇐ "DrawPixel"                 _R i‿i‿color             # x y                                                         # Draw a pixel
drawPixelV                ⇐ "DrawPixelV"                _R v2‿color              # position                                                    # Draw a pixel _R Vector version)
drawLine                  ⇐ "DrawLine"                  _R i‿i‿i‿i‿color         # startPosX startPosY endPosX endPosY                         # Draw a line
drawLineV                 ⇐ "DrawLineV"                 _R v2‿v2‿color           # startPos endPos                                             # Draw a line _R Vector version) 
drawLineEx                ⇐ "DrawLineEx"                _R v2‿v2‿f‿color         # startPos endPos thick                                       # Draw a line defining thickness
drawLineBezier            ⇐ "DrawLineBezier"            _R v2‿v2‿f‿color         # startPos endPos thick                                       # Draw a line using cubic-bezier curves in-out
drawLineBezierQuad        ⇐ "DrawLineBezierQuad"        _R v2‿v2‿v2‿f‿color      # startPos endPos controlPos thick                            # Draw line using quadratic bezier curves with a control point
drawLineBezierCubic       ⇐ "DrawLineBezierCubic"       _R v2‿v2‿v2‿v2‿f‿color   # startPos endPos startControlPos endControlPos thick         # Draw line using cubic bezier curves with 2 control points
drawLineStrip             ⇐ "DrawLineStrip"             _R points‿i‿color        # points pointCount color                                     # Draw lines sequence
drawCircle                ⇐ "DrawCircle"                _R i‿i‿f‿color           # centerX centerY radius                                      # Draw a color-filled circle
drawCircleSector          ⇐ "DrawCircleSector"          _R v2‿f‿f‿f‿i‿color      # center radius startAngle endAngle segments                  # Draw a piece of a circle
drawCircleSectorLines     ⇐ "DrawCircleSectorLines"     _R v2‿f‿f‿f‿i‿color      # center radius startAngle endAngle segments                  # Draw circle sector outline
drawCircleGradient        ⇐ "DrawCircleGradient"        _R i‿i‿f‿color‿color     # centerX centerY radius color1 color2                        # Draw a gradient-filled circle
drawCircleV               ⇐ "DrawCircleV"               _R v2‿f‿color            # center radius                                               # Draw a color-filled circle _R Vector version)
drawCircleLines           ⇐ "DrawCircleLines"           _R i‿i‿f‿color           # centerX centerY radius                                      # Draw circle outline
drawEllipse               ⇐ "DrawEllipse"               _R i‿i‿f‿f‿color         # centerX centerY radiusH radiusV                             # Draw ellipse
drawEllipseLines          ⇐ "DrawEllipseLines"          _R i‿i‿f‿f‿color         # centerX centerY radiusH radiusV                             # Draw ellipse outline
drawRing                  ⇐ "DrawRing"                  _R v2‿f‿f‿f‿f‿i‿color    # center innerRadius outerRadius startAngle endAngle segments # Draw ring
drawRingLines             ⇐ "DrawRingLines"             _R v2‿f‿f‿f‿f‿i‿color    # center innerRadius outerRadius startAngle endAngle segments # Draw ring outline
drawRectangle             ⇐ "DrawRectangle"             _R i‿i‿i‿i‿color         # posX posY width hight                                       # Draw a color-filled rectangle
drawRectangleV            ⇐ "DrawRectangleV"            _R v2‿v2‿color           # position size                                               # Draw a color-filled rectangle _R Vector version)
drawRectangleRec          ⇐ "DrawRectangleRec"          _R rectangle‿color       #                                                             # Draw a color-filled rectangle
drawRectanglePro          ⇐ "DrawRectanglePro"          _R rectangle‿v2‿f‿color  # rectangle origin rotation                                   # Draw a color-filled rectangle with pro parameters
drawRectangleGradientV    ⇐ "DrawRectangleGradientV"    _R i‿i‿i‿i‿color‿color   # posX posY widh hight                                        # Draw a vertical-gradient-filled rectangle
drawRectangleGradientH    ⇐ "DrawRectangleGradientH"    _R i‿i‿i‿i‿color‿color   # posX posY width hight                                       # Draw a horizontal-gradient-filled rectangle
drawRectangleGradientEx   ⇐ "DrawRectangleGradientEx"   _R rectangle<⊸∾4⥊<color  #                                                             # Draw a gradient-filled rectangle with custom vertex colors
drawRectangleLines        ⇐ "DrawRectangleLines"        _R i‿i‿i‿i‿color         # posX posY width hight color                                 # Draw rectangle outline
drawRectangleLinesEx      ⇐ "DrawRectangleLinesEx"      _R rectangle‿f‿color     # rectangle lineThick                                         # Draw rectangle outline with extended parameters
drawRectangleRounded      ⇐ "DrawRectangleRounded"      _R rectangle‿f‿i‿color   # rectangle roundness segments color                          # Draw rectangle with rounded edges
drawRectangleRoundedLines ⇐ "DrawRectangleRoundedLines" _R rectangle‿f‿i‿f‿color # rectangle roundness segments lineThick                      # Draw rectangle with rounded edges outline
drawTriangle              ⇐ "DrawTriangle"              _R v2‿v2‿v2‿color        #                                                             # Draw a color-filled triangle _R vertex in counter-clockwise order!)
drawTriangleLines         ⇐ "DrawTriangleLines"         _R v2‿v2‿v2‿color        #                                                             # Draw triangle outline _R vertex in counter-clockwise order!)
drawTriangleFan           ⇐ "DrawTriangleFan"           _R points‿i‿color        # points pointCount                                           # Draw a triangle fan defined by points _R first vertex is the center)
drawTriangleStrip         ⇐ "DrawTriangleStrip"         _R points‿i‿color        # points pointCount                                           # Draw a triangle strip defined by points
drawPoly                  ⇐ "DrawPoly"                  _R v2‿i‿f‿f‿color        # center sides radius rotation                                # Draw a regular polygon _R Vector version)
drawPolyLines             ⇐ "DrawPolyLines"             _R v2‿i‿f‿f‿color        # center sides radius rotation                                # Draw a polygon outline of n sides
drawPolyLinesEx           ⇐ "DrawPolyLinesEx"           _R v2‿i‿f‿f‿f‿color      # center sides radius rotation lineThick                      # Draw a polygon outline of n sides with extended parameters
