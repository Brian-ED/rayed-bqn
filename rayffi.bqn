# Notes about this file:
# • This file is FFI for everything in raylib.h: https:#github.com/raysan5/raylib/blob/fec96137e8d10ee6c88914fbe5e5429c13ee1dac/src/raylib.h
# • FFI functions are not tested before release. There are simply too many for the moment. The functions in raylib.bqn are tested, atleast minimally.

# • You may change defaults in raylib/src/config.h for smaller build size by commenting out the following lines with "//":
# define SUPPORT_TEXT_MANIPULATION  1

# • if a function here can be implemented in BQN, that ffi definition can be replaced.

# • the functions in this file are simply drop-in replacements for all raylib functions. 

# Functions that have been excluded:
#   TextFormat, not needed.
#   textCopy, not needed in bqn
#   TextIsEqual, 𝕨≡𝕩
#   textLength, ≠𝕩
#   textAppend, the function abuses mutation, use ∾ and `pos+↩`
#   genImageGradientLinear, according to https://github.com/Brian-ED/rayed-bqn/issues/6 this wasn't working. Alternatives are implemented in raylib.bqn as image.GenGradientLinear
#   genImageGradientSquare, according to https://github.com/Brian-ED/rayed-bqn/issues/6 this wasn't working. Alternatives are implemented in raylib.bqn as image.GenGradientSquare

# Debug prints names of ffi functions when they're called
debug ← 0

raylibPath‿bqnLibsPath ← •Import "src/loadConfig.bqn"
math ← •Import "src/raymath.bqn"

#region Structs
P ⇐ '*'⊸∾             # '*' means a pointer
S ⇐ {'{'∾'}'«∾','∾¨𝕩} # Parse types into one struct
c ⇐ "i8"
bool ⇐ "i8"
i‿f‿u‿i8‿·‿u8 ⇐ ⥊"32"‿"8"∾˜⌜"ifu"
str‿uStr ⇐ P¨"iu"∾¨<"8:c8"
ptr ⇐ "*:i8"

v2‿v3‿v4 ⇐ S¨2↓↑4⥊<f

# Matrix, 4x4 components, column major, OpenGL style, right handed
matrix ⇐ S 16⥊<f
# m0 m4 m8  m12
# m1 m5 m9  m13
# m2 m6 m10 m14
# m3 m7 m11 m15

color     ⇐ S 4⥊<u8
rectangle ⇐ v4

# Image, pixel data stored in CPU memory (RAM)
image ⇐ S ptr<⊸∾4⥊<i
# *data   # Image raw data
# width   # Image base width
# height  # Image base height
# mipmaps # Mipmap levels, 1 by default
# format  # Data format (PixelFormat type)

# Texture, tex data stored in GPU memory (VRAM)
texture ⇐ S u‿i‿i‿i‿i
# id      # OpenGL texture id
# width   # Texture base width
# height  # Texture base height
# mipmaps # Mipmap levels, 1 by default
# format  # Data format (PixelFormat type)

# RenderTexture, fbo for texture rendering
renderTexture ⇐ S u<⊸∾2⥊<texture
# OpenGL framebuffer object id
# Color buffer attachment texture
# Depth buffer attachment texture

# NPatchInfo, n-patch layout info
nPatchInfo ⇐ S ⟨
  rectangle # Texture source rectangle
  i         # Left   border offset
  i         # Top    border offset
  i         # Right  border offset
  i         # Bottom border offset
  i         # Layout of the n-patch: 3x3, 1x3 or 3x1
⟩
# GlyphInfo, font characters glyphs info
glyphInfo ⇐ S i‿i‿i‿i‿image
# value    # Character value (Unicode)
# offsetX  # Character offset X when drawing
# offsetY  # Character offset Y when drawing
# advanceX # Character advance position X
# image    # Character image data

# Font, font texture and GlyphInfo array data
font ⇐ S ⟨i⋄i⋄i⋄texture⋄ptr⊣P rectangle⋄ptr⊣P glyphInfo⟩
# baseSize     # Base size (default chars height)
# glyphCount   # Number of glyph characters
# glyphPadding # Padding around the glyph characters
# Texture      # atlas containing the glyphs
# recs         # Rectangles in texture for the glyphs
# glyphs       # Glyphs info data

# Camera, defines position/orientation in 3d space
camera3D ⇐ S v3‿v3‿v3‿f‿i
# position   # Camera position
# target     # Camera target it looks-at
# up         # Camera up vector (rotation over its axis)
# fovy       # Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
# projection # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

# Camera2D, defines position/orientation in 2d space
camera2D ⇐ S v2‿v2‿f‿f
# offset   # Camera offset (displacement from target)
# target   # Camera target (rotation and zoom origin)
# rotation # Camera rotation in degrees
# zoom     # Camera zoom (scaling), should be 1.0f by default

# Mesh, vertex data and vao/vbo
mesh ⇐ S ⟨
  i # vertexCount   # Number of vertices stored in arrays
  i # triangleCount # Number of triangles stored (indexed or not)

  # Vertex attributes data
  ptr # float *vertices         # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
  ptr # float *texcoords        # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
  ptr # float *texcoords2       # Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
  ptr # float *normals          # Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
  ptr # float *tangents         # Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
  ptr # ustr colors   # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
  ptr # unsigned short *indices # Vertex indices (in case vertex data comes indexed)

  # Animation vertex data
  ptr # float *animVertices    # Animated vertex positions (after bones transformations)
  ptr # float *animNormals     # Animated normals (after bones transformations)
  ptr # ustr boneIds # Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
  ptr # float *boneWeights     # Vertex bone weight, up to 4 bones influence by vertex (skinning)

  # OpenGL identifiers
  u   # vaoId               # OpenGL Vertex Array Object id
  ptr # unsigned int *vboId # OpenGL Vertex Buffer Objects id (default vertex data)
⟩
# MaterialMap
materialMap ⇐ S ⟨
  texture # map texture
  color   # map color
  f       # map value
⟩
shader ⇐ S u‿ptr
# u  Shader program id
# *i Shader locations array (RL_MAX_SHADER_LOCATIONS)

# Material, includes shader and maps
material ⇐ S ⟨
  shader            # Material shader
  ptr⊣P materialMap # Material maps array (MAX_MATERIAL_MAPS)
  v4                # params[4] # Material generic parameters (if required)
⟩
# Transform, vertex transformation data
transform ⇐ S ⟨
  v3 # translation # Translation
  v4 # quaternion  # rotation
  v3 # scale       # Scale
⟩
# Bone, skeletal animation bone
boneInfo ⇐ S ⟨
  S 32⥊<u8 # name[32] # Bone name
  i        # parent   # Bone parent
⟩
# Model, meshes, materials and animation data
model ⇐ S ⟨
  matrix    # Matrix transform    # Local transform matrix
  i         # meshCount           # Number of meshes
  i         # materialCount       # Number of materials
  ptr       # Mesh *meshes        # Meshes array
  ptr       # Material *materials # Materials array
  ptr       # int *meshMaterial   # Mesh material number
  # Animation data
  i         # int boneCount       # Number of bones
  ptr       # BoneInfo *bones     # Bones information (skeleton)
  ptr       # Transform *bindPose # Bones base transformation (pose)
⟩
# ModelAnimation
modelAnimation ⇐ S ⟨
  i   # boneCount          # Number of bones
  i   # frameCount         # Number of animation frames
  ptr #  *bones        # Bones information (skeleton)
  ptr #  **framePoses # Poses array by frame
⟩
ray ⇐ S v3‿v3 # position direction # ray for raycasting

# RayCollision, ray hit information
rayCollision ⇐ S ⟨
  bool # hit # Did the ray hit something?
  f    # distance # Distance to the nearest hit
  v3   # point    # Point of the nearest hit
  v3   # normal   # Surface normal of hit
⟩
boundingBox ⇐ S v3‿v3 # min max # min corner to max corner

# Wave, audio wave data
wave ⇐ S ⟨
  i # frameCount    # Total number of frames (considering channels)
  i # sampleRate    # Frequency (samples per second)
  i # sampleSize    # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  i # channels      # Number of channels (1-mono, 2-stereo, ...)
  ptr # *data       # Buffer data pointer
⟩
# AudioStream, custom audio stream
audioStream ⇐ S ⟨
  ptr # rAudioProcessor *buffer # Pointer to internal data used by the audio system
  ptr # rAudioBuffer *processor # Pointer to internal data processor, useful for audio effects
  u   # sampleRate              # Frequency (samples per second)
  u   # sampleSize              # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  u   # channels                # Number of channels (1-mono, 2-stereo, ...)
⟩
sound ⇐ S audioStream‿u
# AudioStream stream # Audio stream
# frameCount         # Total number of frames (considering channels)

# Music, audio stream, anything longer than ~10 seconds should be streamed
music ⇐ S ⟨
  audioStream # stream     # Audio stream
  u           # frameCount # Total number of frames (considering channels)
  bool        # looping    # Music looping enable
  i           # ctxType    # Type of music context (audio filetype)
  ptr         # *ctxData   # Audio context data, depends on type
⟩

# VrDeviceInfo, Head-Mounted-Display device parameters
vrDeviceInfo ⇐ S ⟨
  i      # hResolution;            # Horizontal resolution in pixels
  i      # vResolution;            # Vertical resolution in pixels
  f      # hScreenSize             # Horizontal size in meters
  f      # vScreenSize             # Vertical size in meters
  f      # vScreenCenter           # Screen center in meters
  f      # eyeToScreenDistance     # Distance between eye and display in meters
  f      # lensSeparationDistance  # Lens separation distance in meters
  f      # interpupillaryDistance  # IPD (distance between pupils) in meters
  S 4⥊<f # lensDistortionValues[4] # Lens distortion constant parameters
  S 4⥊<f # chromaAbCorrection[4]   # Chromatic aberration correction parameters
⟩

# VrStereoConfig, VR stereo rendering configuration for simulator
vrStereoConfig ⇐ S S∘⋈¨(2⥊<matrix)∾6⥊<f
# projection[2]        # VR projection matrices (per eye)
# viewOffset[2]        # VR view offset matrices (per eye)
# leftLensCenter[2]    # VR left lens center
# rightLensCenter[2]   # VR right lens center
# leftScreenCenter[2]  # VR left screen center
# rightScreenCenter[2] # VR right screen center
# scale[2]             # VR distortion scale
# scaleIn[2]           # VR distortion scale in

# File path list
filePathList ⇐ S ⟨
  u   # capacity     # Filepaths max entries
  u   # count        # Filepaths entries count
  ptr # char **paths # Filepaths entries
⟩
#endregion Structs

#region FFIFunctions

# making FFI nicer to use
MakeImporter ⇐ {𝕊path:
  {𝕨 funcName _𝕣 inpTypes: outType←𝕨⊣⟨⟩
    a←(⋈'>'⊸∾)⍟(×∘≠∧1=≡)@⟨⟩⍟≡𝕩
    HandleError ← {
      •Out "DEBUG TYPE INFO:"
      •Out •Fmt 𝕩
      •Out "END OF DEBUG TYPE INFO; BEGINING WITH FULL ERROR:"
      •term.Flush@
      𝕨•FFI𝕩
    }
    func ← path •FFI⎊HandleError outType‿funcName∾a
    m ← str⊸≡¨a
    {𝕏⊣•term.Flush∘•Out∘funcName}⍟debug {𝕏∾⟜@}⍟(a≡⋈'>'∾str) {𝕏∾⟜@¨⌾(m⊸/)}⍟(∨´m) func
  }
}
r ⇐ MakeImporter raylibPath

#------------------------------------------------------------------------------------
# BQN low-level function utils
#------------------------------------------------------------------------------------

# BQN Pointer functions
# neccesary for low level programming in bqn
MovePtr  ⇐ {b←256⋆↕8 ⋄ -⟜(256×≥⟜128)256|⌊b÷˜𝕨+´b×256|𝕩}     #      bytes 𝕊 pointer # Move pointer by an amount of bytes
read     ⇐ @•FFI "" ‿"bqn_readI8Arr"  ‿"𝕨>a"    ‿('>'∾ptr)  #       data 𝕊 pointer # write data to pointer
readI32  ⇐ @•FFI "" ‿"bqn_readI32Arr" ‿"𝕨>a"    ‿('>'∾ptr)  #       data 𝕊 pointer # write data to pointer
make     ⇐ @•FFI "a"‿"bqn_makeI8Vec"  ‿"𝕨>u64"  ‿('>'∾ptr)  # bytesCount 𝕊 pointer # turn data at pointer into a number array
makeI32  ⇐ @•FFI "a"‿"bqn_makeI32Vec" ‿"𝕨>u64"  ‿('>'∾ptr)  #   NumCount 𝕊 pointer # turn data at pointer into a number array
makeUTF8 ⇐ @•FFI "a"‿"bqn_makeUTF8Str"‿"𝕨>u64"  ‿('>'∾ptr)  #     length 𝕊 pointer # turn string at pointer into a bqn string
strLen   ⇐ @•FFI i  ‿"strlen"         ‿('>'∾ptr)            #            𝕊 pointer # length of unicode C-string

# NumCount 𝕊 pointer # turn data at pointer into a number array
MakeF32 ⇐ (@•FFI"*:i8"‿"memcpy"‿"&f32"‿"*i8"‿"u64"){
  bytes←∘‿4⥊𝕩 Make˜ 𝕨×4
  1⊑∘⊑˘𝔽∘{⟨0⟩‿𝕩‿4}˘bytes
}

# NumCount 𝕊 pointer # turn data at pointer into a number array
U32ToI8 ⇐ ⟨@•FFI"*:i8"‿"memcpy"‿"&i32"‿"*u32"‿"u64",@•FFI"*:i8"‿"memcpy"‿"&u32"‿"*i32"‿"u64"⟩{
  𝔽_𝕣𝕩:F‿·←𝕗⋄⟨32‿'i'⋄8‿'i'⟩•bit._cast 1⊑F⟨0⟩‿⟨𝕩⟩‿4
;
  𝔽_𝕣⁼𝕩:·‿F←𝕗⋄⊑1⊑F{⟨0⟩‿𝕩‿4} ⟨8‿'i'⋄32‿'i'⟩•bit._cast 𝕩
}

#------------------------------------------------------------------------------------
# Window and Graphics Device Functions (Module: core)
#------------------------------------------------------------------------------------

# Window-related functions
initWindow               ⇐     "InitWindow"              _R i‿i‿str # width height *title # Initialize window and OpenGL context
windowShouldClose        ⇐ bool"WindowShouldClose"       _R@                              # Check if KEY_ESCAPE pressed or Close icon pressed
closeWindow              ⇐     "CloseWindow"             _R@                              # Close window and unload OpenGL context
isWindowReady            ⇐ bool"IsWindowReady"           _R@                              # Check if window has been initialized successfully
isWindowFullscreen       ⇐ bool"IsWindowFullscreen"      _R@                              # Check if window is currently fullscreen
isWindowHidden           ⇐ bool"IsWindowHidden"          _R@                              # Check if window is currently hidden (only PLATFORM_DESKTOP)
isWindowMinimized        ⇐ bool"IsWindowMinimized"       _R@                              # Check if window is currently minimized (only PLATFORM_DESKTOP)
isWindowMaximized        ⇐ bool"IsWindowMaximized"       _R@                              # Check if window is currently maximized (only PLATFORM_DESKTOP)
isWindowFocused          ⇐ bool"IsWindowFocused"         _R@                              # Check if window is currently focused (only PLATFORM_DESKTOP)
isWindowResized          ⇐ bool"IsWindowResized"         _R@                              # Check if window has been resized last frame
isWindowState            ⇐ bool"IsWindowState"           _R u # flag                      # Check if one specific window flag is enabled
setWindowState           ⇐     "SetWindowState"          _R u # flags                     # Set window configuration state using flags (only PLATFORM_DESKTOP)
clearWindowState         ⇐     "ClearWindowState"        _R u # flags                     # Clear window configuration state flags
toggleFullscreen         ⇐     "ToggleFullscreen"        _R@                              # Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)
maximizeWindow           ⇐     "MaximizeWindow"          _R@                              # Set window state: maximized, if resizable (only PLATFORM_DESKTOP)
minimizeWindow           ⇐     "MinimizeWindow"          _R@                              # Set window state: minimized, if resizable (only PLATFORM_DESKTOP)
restoreWindow            ⇐     "RestoreWindow"           _R@                              # Set window state: not minimized/maximized (only PLATFORM_DESKTOP)
setWindowIcon            ⇐     "SetWindowIcon"           _R image                         # Set icon for window (single image, RGBA 32bit, only PLATFORM_DESKTOP)
setWindowIcons           ⇐     "SetWindowIcons"          _R(P image)‿i # images count     # Set icon for window (multiple images, RGBA 32bit, only PLATFORM_DESKTOP)
setWindowTitle           ⇐     "SetWindowTitle"          _R str        # *title           # Set title for window (only PLATFORM_DESKTOP)
setWindowPosition        ⇐     "SetWindowPosition"       _R i‿i        # x y              # Set window position on screen (only PLATFORM_DESKTOP)
setWindowMonitor         ⇐     "SetWindowMonitor"        _R i          # monitor          # Set monitor for the current window (fullscreen mode)
setWindowMinSize         ⇐     "SetWindowMinSize"        _R i‿i        # width height     # Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
setWindowSize            ⇐     "SetWindowSize"           _R i‿i        # width height     # Set window dimensions
setWindowOpacity         ⇐     "SetWindowOpacity"        _R f          # opacity          # Set window opacity [0.0f..1.0f] (only PLATFORM_DESKTOP)
getWindowHandle          ⇐ ptr "GetWindowHandle"         _R@                              # Get native window handle
getScreenWidth           ⇐ i   "GetScreenWidth"          _R@                              # Get current screen width
getScreenHeight          ⇐ i   "GetScreenHeight"         _R@                              # Get current screen height
getRenderWidth           ⇐ i   "GetRenderWidth"          _R@                              # Get current render width (it considers HiDPI)
getRenderHeight          ⇐ i   "GetRenderHeight"         _R@                              # Get current render height (it considers HiDPI)
getMonitorCount          ⇐ i   "GetMonitorCount"         _R@                              # Get number of connected monitors
getCurrentMonitor        ⇐ i   "GetCurrentMonitor"       _R@                              # Get current connected monitor
getMonitorPosition       ⇐ v2  "GetMonitorPosition"      _R i # monitor                   # Get specified monitor position
getMonitorWidth          ⇐ i   "GetMonitorWidth"         _R i # monitor                   # Get specified monitor width (current video mode used by monitor)
getMonitorHeight         ⇐ i   "GetMonitorHeight"        _R i # monitor                   # Get specified monitor height (current video mode used by monitor)
getMonitorPhysicalWidth  ⇐ i   "GetMonitorPhysicalWidth" _R i # monitor                   # Get specified monitor physical width in millimetres
getMonitorPhysicalHeight ⇐ i   "GetMonitorPhysicalHeight"_R i # monitor                   # Get specified monitor physical height in millimetres
getMonitorRefreshRate    ⇐ i   "GetMonitorRefreshRate"   _R i # monitor                   # Get specified monitor refresh rate
getWindowPosition        ⇐ v2  "GetWindowPosition"       _R@                              # Get window position XY on monitor
getWindowScaleDPI        ⇐ v2  "GetWindowScaleDPI"       _R@                              # Get window scale DPI factor
getMonitorName           ⇐ ptr "GetMonitorName"          _R i   # utf-8 _R monitor        # Get the human-readable, UTF-8 encoded name of the primary monitor
setClipboardText         ⇐     "SetClipboardText"        _R str # *text                   # Set clipboard text content                                                   # NOTE changed *:c8
getClipboardText         ⇐ ptr "GetClipboardText"        _R@    # utf-8                   # Get clipboard text content
enableEventWaiting       ⇐     "EnableEventWaiting"      _R@                              # Enable waiting for events on EndDrawing(), no automatic event polling
disableEventWaiting      ⇐     "DisableEventWaiting"     _R@                              # Disable waiting for events on EndDrawing(), automatic events polling


# Custom frame control functions
# NOTE: Those functions are intended for advance users that want full control over the frame processing
# By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
# To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
swapScreenBuffer ⇐ "SwapScreenBuffer"_R@                # Swap back buffer with front buffer (screen drawing)
pollInputEvents  ⇐ "PollInputEvents" _R@                # Register all input events
waitTime         ⇐ "WaitTime"        _R "f64" # seconds # Wait for some time (halt program execution)

# Cursor-related functions
showCursor       ⇐      "ShowCursor"      _R@ # Shows cursor
hideCursor       ⇐      "HideCursor"      _R@ # Hides cursor
isCursorHidden   ⇐ bool "IsCursorHidden"  _R@ # Check if cursor is not visible
enableCursor     ⇐      "EnableCursor"    _R@ # Enables cursor (unlock cursor)
disableCursor    ⇐      "DisableCursor"   _R@ # Disables cursor (lock cursor)
isCursorOnScreen ⇐ bool "IsCursorOnScreen"_R@ # Check if cursor is on the screen

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

# VR stereo config functions for VR simulator
# LoadVrStereoConfig   ⇐ vrStereoConfig "LoadVrStereoConfig"   vrDeviceInfo   # device # Load VR stereo config for VR simulator device parameters
# UnloadVrStereoConfig ⇐                "UnloadVrStereoConfig" vrStereoConfig # config # Unload VR stereo config

# Shader management functions
# NOTE: Shader functionality is not available on OpenGL 1.1
#LoadShader ⇐ {𝕊vsFileName‿fsFileName: LoadShaderFromMemory ""⊸≡◶⟨⥊@, @∾˜•FChars⟩¨𝕩}
loadShader              ⇐ shader "LoadShader"             _R str‿str      # Load shader from files and bind default locations
loadShaderFromMemory    ⇐ shader "LoadShaderFromMemory"   _R str‿str      # *vsCode *fsCode # Load shader from code strings and bind default locations
IsShaderReady ⇐ {𝕊shader: # Check if a shader is ready
  id‿locsPtr ← 𝕩
  (id>0)∧locsPtr≢8⥊0      # id>0 means loaded successfully and non-null pointer means memory has been succesfully allocated
}
getShaderLocation       ⇐ i "GetShaderLocation"      _R shader‿str        # shader *uniformName                      # Get shader uniform location
getShaderLocationAttrib ⇐ i "GetShaderLocationAttrib"_R shader‿str        # shader *attribName                       # Get shader attribute location
setShaderValue          ⇐   "SetShaderValue"         _R shader‿i‿(P f)‿i  # shader locIndex *value uniformType       # Set shader uniform value   # note to future Brian: Changed void to *f32 to fix a bug.
setShaderValueV         ⇐   "SetShaderValueV"        _R shader‿i‿ptr‿i‿i  # shader locIndex *value uniformType count # Set shader uniform value vector
setShaderValueMatrix    ⇐   "SetShaderValueMatrix"   _R shader‿i‿matrix   # shader locindex mat                      # Set shader uniform value (matrix 4x4)
setShaderValueTexture   ⇐   "SetShaderValueTexture"  _R shader‿i‿texture  # shader locIndex texture                  # Set shader uniform value for texture (sampler2d)
unloadShader            ⇐   "UnloadShader"           _R shader                                                       # Unload shader from GPU memory (VRAM)

# Screen-space-related functions
getMouseRay        ⇐ ray    "GetMouseRay"        _R v2‿camera3D      # mousePosition camera         # Get a ray trace from mouse position

GetCameraMatrix ← {𝕊camera:
  position‿target‿up‿fovy‿projection ← 𝕩
  math.MatrixLookAt position‿target‿up
}
getCameraMatrix2D  ⇐ matrix "GetCameraMatrix2D"  _R camera3D                                        # Get camera 2d transform matrix
getWorldToScreen   ⇐ v2     "GetWorldToScreen"   _R v3‿camera3D      # position camera              # Get the screen space position for a 3d world space position
getScreenToWorld2D ⇐ v2     "GetScreenToWorld2D" _R v2‿camera3D      # position camera              # Get the world space position for a 2d camera screen space position
getWorldToScreenEx ⇐ v2     "GetWorldToScreenEx" _R v3‿camera3D‿i‿i  # position camera width height # Get size position for a 3d world space position
getWorldToScreen2D ⇐ v2     "GetWorldToScreen2D" _R v2‿camera3D      # position camera              # Get the screen space position for a 2d camera world space position

# Timing-related functions
setTargetFPS ⇐       "SetTargetFPS" _R i # fps # Set target FPS (maximum)
getFPS       ⇐ i     "GetFPS"       _R@        # Get current FPS
getFrameTime ⇐ f     "GetFrameTime" _R@        # Get time in seconds for last frame drawn (delta time)
getTime      ⇐ "f64" "GetTime"      _R@        # Get elapsed time in seconds since InitWindow()

# Misc. functions
getRandomValue ⇐ i "GetRandomValue"_R i‿i # min max   # Get a random value between min and max (both included)
setRandomSeed  ⇐   "SetRandomSeed" _R i   # seed      # Set the seed for the random number generator
takeScreenshot ⇐   "TakeScreenshot"_R str # *filename # Takes a screenshot of current screen (filename extension defines format)
setConfigFlags ⇐   "SetConfigFlags"_R u   # flags     # Setup init configuration flags (view FLAGS)

traceLog         ⇐     "TraceLog"        _R i‿str                         # logLevel *text ... # Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
setTraceLogLevel ⇐     "SetTraceLogLevel"_R i                             # logLevel           # Set the current threshold (minimum) log level
memAlloc         ⇐ ptr "MemAlloc"        _R u                             # size               # Internal memory allocator
memRealloc       ⇐ ptr "MemRealloc"      _R ptr‿u                         # *ptr size          # Internal memory reallocator
memFree          ⇐     "MemFree"         _R ptr                           # *ptr               # Internal memory free

openURL ⇐ "OpenURL"_R str # url # Open URL with default system browser (if available)

# Set custom callbacks
# WARNING: Callbacks setup is intended for advance users
setTraceLogCallback     ⇐ "SetTraceLogCallback"    _R ptr # *traceLogCallback     # Set custom trace log
setLoadFileDataCallback ⇐ "SetLoadFileDataCallback"_R ptr # *loadFileDataCallback # Set custom file binary data loader
setSaveFileDataCallback ⇐ "SetSaveFileDataCallback"_R ptr # *saveFileDataCallback # Set custom file binary data saver
setLoadFileTextCallback ⇐ "SetLoadFileTextCallback"_R ptr # *loadFileTextCallback # Set custom file text data loader
setSaveFileTextCallback ⇐ "SetSaveFileTextCallback"_R ptr # *saveFileTextCallback # Set custom file text data saver

# Files management functions
loadFileData            ⇐ (ptr⊣ustr)   "LoadFileData"            _R str‿(P u)    # *fileName *bytesRead          # Load file data as byte array (read)
unloadFileData          ⇐              "UnloadFileData"          _R ustr         # *data                         # Unload file data allocated by LoadFileData()
saveFileData            ⇐ bool         "SaveFileData"            _R str‿ptr‿u    # *fileName *data bytesToWrite  # Save data to file from byte array (write), returns true on success
exportDataAsCode        ⇐ bool         "ExportDataAsCode"        _R ustr‿u‿str   # *data size *fileName          # Export data to code (.h), returns true on success
loadFileText            ⇐ ptr          "LoadFileText"            _R str          # *fileName                     # Load text data from file (read), returns a '\0' terminated string
unloadFileText          ⇐              "UnloadFileText"          _R str          # *text                         # Unload file text data allocated by LoadFileText()
saveFileText            ⇐ bool         "SaveFileText"            _R str‿str      # *fileName *text               # Save text data to file (write), string must be '\0' terminated, returns true on success
fileExists              ⇐ bool         "FileExists"              _R str          # *fileName                     # Check if file exists
directoryExists         ⇐ bool         "DirectoryExists"         _R str          # *dirPath                      # Check if a directory path exists
isFileExtension         ⇐ bool         "IsFileExtension"         _R str‿str      # *fileName *ext                # Check file extension (including point: .png, .wav)
getFileLength           ⇐ i            "GetFileLength"           _R str          # *fileName                     # Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
getFileExtension        ⇐ (ptr⊣str)    "GetFileExtension"        _R str          # *fileName                     # Get pointer to extension for a filename string (includes dot: '.png')
getFileName             ⇐ (ptr⊣str)    "GetFileName"             _R str          # *filePath                     # Get pointer to filename for a path string
getFileNameWithoutExt   ⇐ (ptr⊣str)    "GetFileNameWithoutExt"   _R str          # *filePath                     # Get filename string without extension (uses static string)
getDirectoryPath        ⇐ (ptr⊣str)    "GetDirectoryPath"        _R str          # *filePath                     # Get full path for a given fileName with path (uses static string)
getPrevDirectoryPath    ⇐ (ptr⊣str)    "GetPrevDirectoryPath"    _R str          # *dirPath                      # Get previous directory path for a given path (uses static string)
getWorkingDirectory     ⇐ (ptr⊣str)    "GetWorkingDirectory"     _R@                                             # Get current working directory (uses static string)
getApplicationDirectory ⇐ (ptr⊣str)    "GetApplicationDirectory" _R@                                             # Get the directory if the running application (uses static string)
changeDirectory         ⇐ bool         "ChangeDirectory"         _R str          # *dir                          # Change working directory, return true on success
isPathFile              ⇐ bool         "IsPathFile"              _R str          # *path                         # Check if a given path is a file or a directory
loadDirectoryFiles      ⇐ filePathList "LoadDirectoryFiles"      _R str          # *dirPath                      # Load directory filepaths
loadDirectoryFilesEx    ⇐ filePathList "LoadDirectoryFilesEx"    _R str‿str‿bool # *basePath *filter scanSubdirs # Load directory filepaths with extension filtering and recursive directory scan
unloadDirectoryFiles    ⇐              "UnloadDirectoryFiles"    _R filePathList # files                         # Unload filepaths
isFileDropped           ⇐ bool         "IsFileDropped"           _R@                                             # Check if a file has been dropped into window
loadDroppedFiles        ⇐ filePathList "LoadDroppedFiles"        _R@                                             # Load dropped filepaths
unloadDroppedFiles      ⇐              "UnloadDroppedFiles"      _R filePathList # files                         # Unload dropped filepaths
getFileModTime          ⇐ "f64"        "GetFileModTime"          _R str          # *fileName                     # Get file modification time (last write time)

# Compression/Encoding functionality
compressData     ⇐ ptr "CompressData"     _R uStr‿i‿"&i32"  # *data dataSize compDataSize      # Compress data (DEFLATE algorithm), memory must be MemFree()
decompressData   ⇐ ptr "DecompressData"   _R uStr‿i‿"&i32"  # *compData compDataSize dataSize  # Decompress data (DEFLATE algorithm), memory must be MemFree()
encodeDataBase64 ⇐ ptr "EncodeDataBase64" _R uStr‿i‿i       # *data dataSize *outputSize       # Encode data to Base64 string, memory must be MemFree()
decodeDataBase64 ⇐ ptr "DecodeDataBase64" _R uStr‿i‿(P i)   # *data *outputSize                # Decode Base64 string data, memory must be MemFree()


#------------------------------------------------------------------------------------
# Input Handling Functions (Module: core)
#------------------------------------------------------------------------------------

# Input-related functions: keyboard
isKeyPressed   ⇐ bool "IsKeyPressed"  _R i # Check if a key has been pressed once
isKeyDown      ⇐ bool "IsKeyDown"     _R i # Check if a key is being pressed
isKeyReleased  ⇐ bool "IsKeyReleased" _R i # Check if a key has been released once
isKeyUp        ⇐ bool "IsKeyUp"       _R i # Check if a key is NOT being pressed
setExitKey     ⇐      "SetExitKey"    _R i # Set a custom key to exit program (default is ESC)
getKeyPressed  ⇐ i    "GetKeyPressed" _R@  # Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
getCharPressed ⇐ i    "GetCharPressed"_R@  # Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty

# Input-related functions: gamepads
isGamepadAvailable      ⇐ bool     "IsGamepadAvailable"      _R i   # gamepad        # Check if a gamepad is available
getGamepadName          ⇐ (ptr⊣str)"GetGamepadName"          _R i   # gamepad        # Get gamepad internal name id
isGamepadButtonPressed  ⇐ bool     "IsGamepadButtonPressed"  _R i‿i # gamepad button # Check if a gamepad button has been pressed once
isGamepadButtonDown     ⇐ bool     "IsGamepadButtonDown"     _R i‿i # gamepad button # Check if a gamepad button is being pressed
isGamepadButtonReleased ⇐ bool     "IsGamepadButtonReleased" _R i‿i # gamepad button # Check if a gamepad button has been released once
isGamepadButtonUp       ⇐ bool     "IsGamepadButtonUp"       _R i‿i # gamepad button # Check if a gamepad button is NOT being pressed
getGamepadButtonPressed ⇐ i        "GetGamepadButtonPressed" _R@                     # Get the last gamepad button pressed
getGamepadAxisCount     ⇐ i        "GetGamepadAxisCount"     _R i   # gamepad        # Get gamepad axis count for a gamepad
getGamepadAxisMovement  ⇐ f        "GetGamepadAxisMovement"  _R i‿i # gamepad axis   # Get axis movement value for a gamepad axis
setGamepadMappings      ⇐ i        "SetGamepadMappings"      _R str # *mappings      # Set internal gamepad mappings (SDL_GameControllerDB)

# Input-related functions: mouse
isMouseButtonPressed  ⇐ bool "IsMouseButtonPressed" _R i   # button          # Check if a mouse button has been pressed once
isMouseButtonDown     ⇐ bool "IsMouseButtonDown"    _R i   # button          # Check if a mouse button is being pressed
isMouseButtonReleased ⇐ bool "IsMouseButtonReleased"_R i   # button          # Check if a mouse button has been released once
isMouseButtonUp       ⇐ bool "IsMouseButtonUp"      _R i   # button          # Check if a mouse button is NOT being pressed
getMouseX             ⇐ i    "GetMouseX"            _R@                      # Get mouse position X
getMouseY             ⇐ i    "GetMouseY"            _R@                      # Get mouse position Y
getMousePosition      ⇐ v2   "GetMousePosition"     _R@                      # Get mouse position XY
getMouseDelta         ⇐ v2   "GetMouseDelta"        _R@                      # Get mouse delta between frames
setMousePosition      ⇐      "SetMousePosition"     _R i‿i # x y             # Set mouse position XY
setMouseOffset        ⇐      "SetMouseOffset"       _R i‿i # offsetX offsetY # Set mouse offset
setMouseScale         ⇐      "SetMouseScale"        _R f‿f # scaleX scaleY   # Set mouse scaling
getMouseWheelMove     ⇐ f    "GetMouseWheelMove"    _R@                      # Get mouse wheel movement for X or Y, whichever is larger
getMouseWheelMoveV    ⇐ v2   "GetMouseWheelMoveV"   _R@                      # Get mouse wheel movement for both X and Y
setMouseCursor        ⇐      "SetMouseCursor"       _R i   # cursor          # Set mouse cursor

# Input-related functions: touch
getTouchX          ⇐ i  "GetTouchX"          _R@          # Get touch position X for touch point 0 (relative to screen size)
getTouchY          ⇐ i  "GetTouchY"          _R@          # Get touch position Y for touch point 0 (relative to screen size)
getTouchPosition   ⇐ v2 "GetTouchPosition"   _R i # index # Get touch position XY for a touch point index (relative to screen size)
getTouchPointId    ⇐ i  "GetTouchPointId"    _R i # index # Get touch point identifier for given index
getTouchPointCount ⇐ i  "GetTouchPointCount" _R@          # Get number of touch points


#------------------------------------------------------------------------------------
# Gestures and Touch Handling Functions (Module: rgestures)
#------------------------------------------------------------------------------------
setGesturesEnabled     ⇐      "SetGesturesEnabled"     _R u # flags   # Enable a set of gestures using flags
isGestureDetected      ⇐ bool "IsGestureDetected"      _R i # gesture # Check if a gesture have been detected
getGestureDetected     ⇐ i    "GetGestureDetected"     _R@            # Get latest detected gesture
getGestureHoldDuration ⇐ f    "GetGestureHoldDuration" _R@            # Get gesture hold time in milliseconds
getGestureDragVector   ⇐ v2   "GetGestureDragVector"   _R@            # Get gesture drag vector
getGestureDragAngle    ⇐ f    "GetGestureDragAngle"    _R@            # Get gesture drag angle
getGesturePinchVector  ⇐ v2   "GetGesturePinchVector"  _R@            # Get gesture pinch delta
getGesturePinchAngle   ⇐ f    "GetGesturePinchAngle"   _R@            # Get gesture pinch angle

#------------------------------------------------------------------------------------
# Camera System Functions (Module: rcamera)
#------------------------------------------------------------------------------------

updateCamera    ⇐ "UpdateCamera"   _R ('&'∾camera3d)‿i       # Camera mode                   # Update camera position for selected mode
updateCameraPro ⇐ "UpdateCameraPro"_R ('&'∾camera3d)‿v3‿v3‿f # Camera movement rotation zoom # Update camera movement/rotation

#------------------------------------------------------------------------------------
# Basic Shapes Drawing Functions (Module: shapes)
#------------------------------------------------------------------------------------

# Set texture and rectangle to be used on shapes drawing
# NOTE: It can be useful when using basic shapes and one single font,
# defining a font char white rectangle would allow drawing everything in a single draw call
setShapesTexture ⇐ "SetShapesTexture" _R texture‿rectangle # texture source # Set texture and rectangle to be used on shapes drawing

# Basic shapes drawing functions
drawPixel                 ⇐ "DrawPixel"                 _R i‿i‿color             # x y                                                         # Draw a pixel
drawPixelV                ⇐ "DrawPixelV"                _R v2‿color              # position                                                    # Draw a pixel _R Vector version)
drawLine                  ⇐ "DrawLine"                  _R i‿i‿i‿i‿color         # startPosX startPosY endPosX endPosY                         # Draw a line
drawLineV                 ⇐ "DrawLineV"                 _R v2‿v2‿color           # startPos endPos                                             # Draw a line _R Vector version) 
drawLineEx                ⇐ "DrawLineEx"                _R v2‿v2‿f‿color         # startPos endPos thick                                       # Draw a line defining thickness
drawLineBezier            ⇐ "DrawLineBezier"            _R v2‿v2‿f‿color         # startPos endPos thick                                       # Draw a line using cubic-bezier curves in-out
drawLineBezierQuad        ⇐ "DrawLineBezierQuad"        _R v2‿v2‿v2‿f‿color      # startPos endPos controlPos thick                            # Draw line using quadratic bezier curves with a control point
drawLineBezierCubic       ⇐ "DrawLineBezierCubic"       _R v2‿v2‿v2‿v2‿f‿color   # startPos endPos startControlPos endControlPos thick         # Draw line using cubic bezier curves with 2 control points
drawLineStrip             ⇐ "DrawLineStrip"             _R (P v2)‿i‿color        # points pointCount color                                     # Draw lines sequence
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
drawRectangleGradientV    ⇐ "DrawRectangleGradientV"    _R i‿i‿i‿i‿color‿color   # posX posY width hight                                        # Draw a vertical-gradient-filled rectangle
drawRectangleGradientH    ⇐ "DrawRectangleGradientH"    _R i‿i‿i‿i‿color‿color   # posX posY width hight                                       # Draw a horizontal-gradient-filled rectangle
drawRectangleGradientEx   ⇐ "DrawRectangleGradientEx"   _R rectangle<⊸∾4⥊<color  #                                                             # Draw a gradient-filled rectangle with custom vertex colors
drawRectangleLines        ⇐ "DrawRectangleLines"        _R i‿i‿i‿i‿color         # posX posY width hight color                                 # Draw rectangle outline
drawRectangleLinesEx      ⇐ "DrawRectangleLinesEx"      _R rectangle‿f‿color     # rectangle lineThick                                         # Draw rectangle outline with extended parameters
drawRectangleRounded      ⇐ "DrawRectangleRounded"      _R rectangle‿f‿i‿color   # rectangle roundness segments color                          # Draw rectangle with rounded edges
drawRectangleRoundedLines ⇐ "DrawRectangleRoundedLines" _R rectangle‿f‿i‿f‿color # rectangle roundness segments lineThick                      # Draw rectangle with rounded edges outline
drawTriangle              ⇐ "DrawTriangle"              _R v2‿v2‿v2‿color        #                                                             # Draw a color-filled triangle _R vertex in counter-clockwise order!)
drawTriangleLines         ⇐ "DrawTriangleLines"         _R v2‿v2‿v2‿color        #                                                             # Draw triangle outline _R vertex in counter-clockwise order!)
drawTriangleFan           ⇐ "DrawTriangleFan"           _R (P v2)‿i‿color        # points pointCount                                           # Draw a triangle fan defined by points _R first vertex is the center)
drawTriangleStrip         ⇐ "DrawTriangleStrip"         _R (P v2)‿i‿color        # points pointCount                                           # Draw a triangle strip defined by points
drawPoly                  ⇐ "DrawPoly"                  _R v2‿i‿f‿f‿color        # center sides radius rotation                                # Draw a regular polygon _R Vector version)
drawPolyLines             ⇐ "DrawPolyLines"             _R v2‿i‿f‿f‿color        # center sides radius rotation                                # Draw a polygon outline of n sides
drawPolyLinesEx           ⇐ "DrawPolyLinesEx"           _R v2‿i‿f‿f‿f‿color      # center sides radius rotation lineThick                      # Draw a polygon outline of n sides with extended parameters

# Basic shapes collision detection functions
checkCollisionRecs          ⇐ bool      "CheckCollisionRecs"          _R rectangle‿rectangle # rec1 rec2                                           # Check collision between two rectangles
checkCollisionCircles       ⇐ bool      "CheckCollisionCircles"       _R v2‿f‿v2‿f           # center1 radius1 center2 radius2                     # Check collision between two circles
checkCollisionCircleRec     ⇐ bool      "CheckCollisionCircleRec"     _R v2‿f‿rectangle      # center radius rec                                   # Check collision between circle and rectangle
checkCollisionPointRec      ⇐ bool      "CheckCollisionPointRec"      _R v2‿rectangle        # point rec                                           # Check if point is inside rectangle
checkCollisionPointCircle   ⇐ bool      "CheckCollisionPointCircle"   _R v2‿v2‿f             # point center radius                                 # Check if point is inside circle
checkCollisionPointTriangle ⇐ bool      "CheckCollisionPointTriangle" _R v2‿v2‿v2‿v2         # point p1 p2 p3                                      # Check if point is inside a triangle
checkCollisionPointPoly     ⇐ bool      "CheckCollisionPointPoly"     _R v2‿(P v2)‿i         # point *points pointCount                            # Check if point is within a polygon described by array of vertices
checkCollisionLines         ⇐ bool      "CheckCollisionLines"         _R v2‿v2‿v2‿v2‿('&'∾v2)  # startPos1 endPos1 startPos2 endPos2 *collisionPoint # Check the collision between two lines defined by two points each, returns collision point by reference
checkCollisionPointLine     ⇐ bool      "CheckCollisionPointLine"     _R v2‿v2‿v2‿i          # point p1 p2 threshold                               # Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
getCollisionRec             ⇐ rectangle "GetCollisionRec"             _R rectangle‿rectangle # rec1 rec2                                           # Get collision rectangle for two rectangles collision

#------------------------------------------------------------------------------------
# Texture Loading and Drawing Functions (Module: textures)
#------------------------------------------------------------------------------------

# Image loading functions
# NOTE: This functions do not require GPU access
loadImage            ⇐ image "LoadImage"           _R str         # *fileName                               # Load image from file into CPU memory (RAM)
loadImageRaw         ⇐ image "LoadImageRaw"        _R str‿i‿i‿i‿i # *fileName width hight format headerSize # Load image from RAW file data
loadImageAnim        ⇐ image "LoadImageAnim"       _R str‿i       # *fileName framesCount                   # Load image sequence from file (frames appended to image.data)
loadImageFromMemory  ⇐ image "LoadImageFromMemory" _R str‿str‿i   # *fileType *fileData dataSize            # Load image from memory buffer, fileType refers to extension: i.e. '.png'
loadImageFromTexture ⇐ image "LoadImageFromTexture"_R texture     # texture2D                               # Load image from GPU texture data
loadImageFromScreen  ⇐ image "LoadImageFromScreen" _R@                                                      # Load image from screen buffer and (screenshot)
isImageReady         ⇐ bool  "IsImageReady"        _R image                                                 # Check if an image is ready
unloadImage          ⇐       "UnloadImage"         _R image                                                 # Unload image from CPU memory (RAM)
exportImage          ⇐ bool  "ExportImage"         _R image‿str   # image *filename                         # Export image data to file, returns true on success
exportImageAsCode    ⇐ bool  "ExportImageAsCode"   _R image‿str   # image *fileName                         # Export image as code file defining an array of bytes, returns true on success

# Image generation functions
genImageColor          ← image "GenImageColor"         _R i‿i‿color           # width hight color                     # Generate image: plain color
genImageGradientRadial ← image "GenImageGradientRadial"_R i‿i‿f‿color‿color   # width hight density inner outer       # Generate image: radial gradient
genImageChecked        ← image "GenImageChecked"       _R i‿i‿i‿i‿color‿color # width hight checksX checksY col1 col2 # Generate image: checked
genImageWhiteNoise     ← image "GenImageWhiteNoise"    _R i‿i‿f               # width hight factor                    # Generate image: white noise
genImagePerlinNoise    ← image "GenImagePerlinNoise"   _R i‿i‿i‿i‿f           # width hight offsetX offsetY scale     # Generate image: perlin noise
genImageCellular       ← image "GenImageCellular"      _R i‿i‿i               # width hight tileSize                  # Generate image: cellular algorithm, bigger tileSize means bigger cells
genImageText           ← image "GenImageText"          _R i‿i‿str             # width hight *text                     # Generate image: grayscale image from text data

# Image manipulation functions
imageCopy             ⇐ image        "ImageCopy"             _R image                                                                     # Create an image duplicate (useful for transformations)
imageFromImage        ⇐ image        "ImageFromImage"        _R image‿rectangle                                                           # Create an image from another image piece
imageText             ⇐ image        "ImageText"             _R str‿i‿color               # *text fontSize color                          # Create an image from text (default font)
imageTextEx           ⇐ image        "ImageTextEx"           _R font‿str‿f‿f‿color        # font text fontSize spacing tint               # Create an image from text (custom sprite font)
imageFormat           ⇐              "ImageFormat"           _R ('&'∾image)‿i             # image newFormat                               # Convert image data to desired format
imageToPOT            ⇐              "ImageToPOT"            _R ('&'∾image)‿color         # image fill                                    # Convert image to POT (power-of-two)
imageCrop             ⇐              "ImageCrop"             _R ('&'∾image)‿rectangle     # image crop                                    # Crop an image to a defined rectangle
imageAlphaCrop        ⇐              "ImageAlphaCrop"        _R ('&'∾image)‿f             # threshold                                     # Crop image depending on alpha value
imageAlphaClear       ⇐              "ImageAlphaClear"       _R ('&'∾image)‿color‿f       # color threshold                               # Clear alpha channel to desired color
imageAlphaMask        ⇐              "ImageAlphaMask"        _R ('&'∾image)‿image         # image alphaMask                               # Apply alpha mask to image
imageAlphaPremultiply ⇐              "ImageAlphaPremultiply" _R  '&'∾image                                                                # Premultiply alpha channel
imageBlurGaussian     ⇐              "ImageBlurGaussian"     _R ('&'∾image)‿i             # image blurSize                                # Apply Gaussian blur using a box blur approximation
imageResize           ⇐              "ImageResize"           _R ('&'∾image)‿i‿i           # image newWidth newHeight                      # Resize image (Bicubic scaling algorithm)
imageResizeNN         ⇐              "ImageResizeNN"         _R ('&'∾image)‿i‿i           # image newWidth newHeight                      # Resize image (Nearest-Neighbor scaling algorithm)
imageResizeCanvas     ⇐              "ImageResizeCanvas"     _R ('&'∾image)‿i‿i‿i‿i‿color # image newWidth newHeight offsetX offsetY fill # Resize canvas and fill with color
imageMipmaps          ⇐              "ImageMipmaps"          _R  '&'∾image                                                                # Compute all mipmap levels for a provided image
imageDither           ⇐              "ImageDither"           _R ('&'∾image)‿i‿i‿i‿i       # rBpp gBpp bBpp aBpp                           # Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
imageFlipVertical     ⇐              "ImageFlipVertical"     _R  '&'∾image                                                                # Flip image vertically
imageFlipHorizontal   ⇐              "ImageFlipHorizontal"   _R  '&'∾image                                                                # Flip image horizontally
imageRotateCW         ⇐              "ImageRotateCW"         _R  '&'∾image                                                                # Rotate image clockwise 90deg
imageRotateCCW        ⇐              "ImageRotateCCW"        _R  '&'∾image                                                                # Rotate image counter-clockwise 90deg
imageColorTint        ⇐              "ImageColorTint"        _R ('&'∾image)‿color                                                         # Modify image color: tint
imageColorInvert      ⇐              "ImageColorInvert"      _R  '&'∾image                                                                # Modify image color: invert
imageColorGrayscale   ⇐              "ImageColorGrayscale"   _R  '&'∾image                                                                # Modify image color: grayscale
imageColorContrast    ⇐              "ImageColorContrast"    _R ('&'∾image)‿f             # image contrast                                # Modify image color: contrast (-100 to 100)
imageColorBrightness  ⇐              "ImageColorBrightness"  _R ('&'∾image)‿i             # brightness                                    # Modify image color: brightness (-255 to 255)
imageColorReplace     ⇐              "ImageColorReplace"     _R ('&'∾image)‿color‿color   # image color replace                           # Modify image color: replace color
loadImageColors       ⇐ (ptr⊣P color)"LoadImageColors"       _R image                     #                                               # Load color data from image as a Color array (RGBA - 32bit)
loadImagePalette      ⇐ (ptr⊣P color)"LoadImagePalette"      _R image‿i‿(P i)             # image maxPaletteSize *colorCount              # Load colors palette from image as a Color array (RGBA - 32bit)
unloadImageColors     ⇐              "UnloadImageColors"     _R  P color                                                                  # Unload color data loaded with LoadImageColors()
unloadImagePalette    ⇐              "UnloadImagePalette"    _R  P color                                                                  # Unload colors palette loaded with LoadImagePalette()
getImageAlphaBorder   ⇐ rectangle    "GetImageAlphaBorder"   _R image‿f                   # image threshold                               # Get image alpha border rectangle
getImageColor         ⇐ color        "GetImageColor"         _R image‿i‿i                 # image x y                                     # Get image pixel color at (x, y) position

# Image drawing functions
# NOTE: Image software-rendering functions (CPU)
imageClearBackground    ⇐ "ImageClearBackground"    _R ('&'∾image)‿color                           # *dst color                                     # Clear image background with given color
imageDrawPixel          ⇐ "ImageDrawPixel"          _R ('&'∾image)‿i‿i‿color                       # *dst posX posY color                           # Draw pixel within an image
imageDrawPixelV         ⇐ "ImageDrawPixelV"         _R ('&'∾image)‿v2‿color                        # *dst position color                            # Draw pixel within an image (Vector version)
imageDrawLine           ⇐ "ImageDrawLine"           _R ('&'∾image)‿i‿i‿i‿i‿color                   # *dst startPosX startPosY endPosX endPosY color # Draw line within an image
imageDrawLineV          ⇐ "ImageDrawLineV"          _R ('&'∾image)‿v2‿v2‿color                     # *dst start end color                           # Draw line within an image (Vector version)
imageDrawCircle         ⇐ "ImageDrawCircle"         _R ('&'∾image)‿i‿i‿i‿color                     # *dst centerX centerY radius color              # Draw a filled circle within an image
imageDrawCircleV        ⇐ "ImageDrawCircleV"        _R ('&'∾image)‿v2‿i‿color                      # *dst center radius color                       # Draw a filled circle within an image (Vector version)
imageDrawCircleLines    ⇐ "ImageDrawCircleLines"    _R ('&'∾image)‿i‿i‿i‿color                     # *dst centerX centerY radius color              # Draw circle outline within an image
imageDrawCircleLinesV   ⇐ "ImageDrawCircleLinesV"   _R ('&'∾image)‿v2‿i‿color                      # *dst center radius color                       # Draw circle outline within an image (Vector version)
imageDrawRectangle      ⇐ "ImageDrawRectangle"      _R ('&'∾image)‿i‿i‿i‿i‿color                   # *dst posX posY width hight color               # Draw rectangle within an image
imageDrawRectangleV     ⇐ "ImageDrawRectangleV"     _R ('&'∾image)‿v2‿v2‿color                     # *dst position size color                       # Draw rectangle within an image (Vector version)
imageDrawRectangleRec   ⇐ "ImageDrawRectangleRec"   _R ('&'∾image)‿rectangle‿color                 # *dst rec color                                 # Draw rectangle within an image
imageDrawRectangleLines ⇐ "ImageDrawRectangleLines" _R ('&'∾image)‿rectangle‿i‿color               # *dst rec thick color                           # Draw rectangle lines within an image
imageDraw               ⇐ "ImageDraw"               _R ('&'∾image)‿image‿rectangle‿rectangle‿color # *dst src srcRec dstRec tint                    # Draw a source image within a destination image (tint applied to source)
imageDrawText           ⇐ "ImageDrawText"           _R ('&'∾image)‿str‿i‿i‿i‿color                 # *dst *text posX posY fontSize color            # Draw text (using default font) within an image (destination)
imageDrawTextEx         ⇐ "ImageDrawTextEx"         _R ('&'∾image)‿font‿str‿v2‿f‿f‿color           # *dst font *text position fontSize spacing tint # Draw text (custom sprite font) within an image (destination)

# Texture loading functions
# NOTE: These functions require GPU access
loadTexture          ⇐ texture       "LoadTexture"         _R str            # *fileName     # Load texture from file into GPU memory (VRAM)
loadTextureFromImage ⇐ texture       "LoadTextureFromImage"_R image                          # Load texture from image data
loadTextureCubemap   ⇐ texture       "LoadTextureCubemap"  _R image‿i        # image layout  # Load cubemap from image, multiple image cubemap layouts supported
loadRenderTexture    ⇐ renderTexture "LoadRenderTexture"   _R i‿i            # width height  # Load texture for rendering (framebuffer)
isTextureReady       ⇐ bool          "IsTextureReady"      _R texture                        # Check if a texture is ready
unloadTexture        ⇐               "UnloadTexture"       _R texture                        # Unload texture from GPU memory (VRAM)
isRenderTextureReady ⇐ bool          "IsRenderTextureReady"_R renderTexture  # target        # Check if a render texture is ready
unloadRenderTexture  ⇐               "UnloadRenderTexture" _R renderTexture  # target        # Unload render texture from GPU memory (VRAM)
updateTexture        ⇐               "UpdateTexture"       _R texture‿(P u8) # texture color # Update GPU texture with new data                                    ## Executive change: changed "void *" type into "*u8" because *u8 just makes more sense. what else would you input into color?
updateTextureRec     ⇐               "UpdateTextureRec"    _R texture‿rectangle‿ptr          # Update GPU texture rectangle with new data

# Texture configuration functions
genTextureMipmaps ⇐ "GenTextureMipmaps" _R P texture # *texture       # Generate GPU mipmaps for a texture
setTextureFilter  ⇐ "SetTextureFilter"  _R texture‿i # texture filter # Set texture scaling filter mode
setTextureWrap    ⇐ "SetTextureWrap"    _R texture‿i # texture wrap   # Set texture wrapping mode

# Texture drawing functions
drawTexture       ⇐ "DrawTexture"       _R texture‿i‿i‿color                       # texture posX posY tint                       # Draw a Texture2D
drawTextureV      ⇐ "DrawTextureV"      _R texture‿v2‿color                        # texture position tint                        # Draw a Texture2D with position defined as Vector2
drawTextureEx     ⇐ "DrawTextureEx"     _R texture‿v2‿f‿f‿color                    # texture position rotation scale tint         # Draw a Texture2D with extended parameters
drawTextureRec    ⇐ "DrawTextureRec"    _R texture‿rectangle‿v2‿color              # texture source position tint                 # Draw a part of a texture defined by a rectangle
drawTexturePro    ⇐ "DrawTexturePro"    _R texture‿rectangle ‿rectangle‿v2‿f‿color # texture source dest origin rotation tint     # Draw a part of a texture defined by a rectangle with 'pro' parameters
drawTextureNPatch ⇐ "DrawTextureNPatch" _R texture‿nPatchInfo‿rectangle‿v2‿f‿color # texture nPatchInfo dest origin rotation tint # Draws a texture (or part of it) that stretches or shrinks nicely

# Color/pixel related functions
fade                ⇐ color "Fade"                _R color‿f           # color alpha           # Get color with alpha applied, alpha goes from 0.0f to 1.0f
colorToInt          ⇐ i     "ColorToInt"          _R color                                     # Get hexadecimal value for a Color
colorNormalize      ⇐ v4    "ColorNormalize"      _R color                                     # Get Color normalized as float [0..1]
colorFromNormalized ⇐ color "ColorFromNormalized" _R v4                # normalized            # Get Color from normalized values [0..1]
colorToHSV          ⇐ v3    "ColorToHSV"          _R color                                     # Get HSV values for a Color, hue [0..360], saturation/value [0..1]
colorFromHSV        ⇐ color "ColorFromHSV"        _R f‿f‿f             # hue saturation value  # Get a Color from HSV values, hue [0..360], saturation/value [0..1]
colorTint           ⇐ color "ColorTint"           _R color‿color       # color tint            # Get color multiplied with another color
colorBrightness     ⇐ color "ColorBrightness"     _R color‿f           # color factor          # Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
colorContrast       ⇐ color "ColorContrast"       _R color‿f           # color contrast        # Get color with contrast correction, contrast values between -1.0f and 1.0f
colorAlpha          ⇐ color "ColorAlpha"          _R color‿f           # color alpha           # Get color with alpha applied, alpha goes from 0.0f to 1.0f
colorAlphaBlend     ⇐ color "ColorAlphaBlend"     _R color‿color‿color # dst src tint          # Get src alpha-blended into dst color with tint
getColor            ⇐ color "GetColor"            _R u                 # hexValue              # Get Color structure from hexadecimal value
getPixelColor       ⇐ color "GetPixelColor"       _R ptr‿i             # *srcPtr format        # Get Color from a source pixel pointer of certain format
setPixelColor       ⇐       "SetPixelColor"       _R ptr‿color‿i       # *dstPtr color format  # Set color formatted into destination pixel pointer
getPixelDataSize    ⇐ i     "GetPixelDataSize"    _R i‿i‿i             # width height format   # Get pixel data size in bytes for certain format

#------------------------------------------------------------------------------------
# Font Loading and Text Drawing Functions (Module: text)
#------------------------------------------------------------------------------------

# Font loading/unloading functions
getFontDefault     ⇐ font              "GetFontDefault"     _R@                                                                                                    # Get the default Font
loadFont           ⇐ font              "LoadFont"           _R str                                   # *fileName                                                   # Load font from file into GPU memory (VRAM)
loadFontEx         ⇐ font              "LoadFontEx"         _R str‿i‿(P i)‿i                         # *fileName fontSize *fontChars glyphCount                    # Load font from file with extended parameters, use NULL for fontChars and 0 for glyphCount to load the default character set
loadFontFromImage  ⇐ font              "LoadFontFromImage"  _R image‿color‿i                         # image color(key?) firstChar                                 # Load font from Image (XNA style)
loadFontFromMemory ⇐ font              "LoadFontFromMemory" _R str‿ustr‿i‿i‿(P i)‿i                  # *fileType *fileData dataSize fontSize *fontChars glyphCount # Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
isFontReady        ⇐ bool              "IsFontReady"        _R font                                                                                                # Check if a font is ready
loadFontData       ⇐ (ptr⊣P glyphInfo) "LoadFontData"       _R ustr‿i‿i‿(P i)‿i‿i                    # *fileData dataSize fontSize fontChars glyphCount type       # Load font data for further use
genImageFontAtlas  ⇐ image             "GenImageFontAtlas"  _R (P glyphInfo)‿(P⍟2 rectangle)‿i‿i‿i‿i # *chars **recs glyphCount fontSize padding packMethod        # Generate image font atlas using chars info
unloadFontData     ⇐                   "UnloadFontData"     _R (P glyphInfo)‿i                       # *chars glyphCount                                           # Unload font chars info data (RAM)
exportFontAsCode   ⇐ bool              "ExportFontAsCode"   _R font‿str                              # font fileName                                               # Export font as code file, returns true on success
unloadFont         ⇐                   "UnloadFont"         _R font                                                                                                # Unload font from GPU memory (VRAM)

# Text drawing
drawFPS            ⇐ "DrawFPS"           _R i‿i                        # posX posY                                                 # Draw current FPS
drawText           ⇐ "DrawText"          _R str‿i‿i‿i‿color            # *text posX posY fontSize color                            # Draw text (using default font)
drawTextEx         ⇐ "DrawTextEx"        _R font‿str‿v2‿f‿f‿color      # font *text position spacing fontSize tint                 # Draw text using font and additional parameters     # Warning, does not support unicode
drawTextPro        ⇐ "DrawTextPro"       _R font‿str‿v2‿v2‿f‿f‿f‿color # font *text position origin rotation fontSize spacing tint # Draw text using Font and pro parameters (rotation) # Warning, does not support unicode
drawTextCodepoint  ⇐ "DrawTextCodepoint" _R font‿i‿v2‿f‿color          # font codepoint position fontSize tint                     # Draw one character (codepoint)
drawTextCodepoints ⇐ "DrawTextCodepoints"_R font‿(P i)‿i‿v2‿f‿f‿color  # font codepoints count position fontSize spacing tint      # Draw multiple character (codepoint)

# Text font info functions
measureText      ⇐ i         "MeasureText"     _R str‿i        # *text fontSize              # Measure string width for default font
measureTextEx    ⇐ v2        "MeasureTextEx"   _R font‿str‿f‿f # font *text fontSize spacing # Measure string size for Font
getGlyphIndex    ⇐ i         "GetGlyphIndex"   _R font‿i       # font codepoint              # Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
getGlyphInfo     ⇐ glyphInfo "GetGlyphInfo"    _R font‿i       # font codepoint              # Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
getGlyphAtlasRec ⇐ rectangle "GetGlyphAtlasRec"_R font‿i       # font codepoint              # Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found

# Text codepoints management functions (unicode characters)
loadUTF8             ⇐ ptr       "LoadUTF8"             _R (P i)‿i # *str ""_R *codepoints length  # Load UTF-8 text encoded from codepoints array
unloadUTF8           ⇐           "UnloadUTF8"           _R str     # *text                         # Unload UTF-8 text encoded from codepoints array
loadCodepoints       ⇐ ptr       "LoadCodepoints"       _R str⋈P i # *i ""_R *text *count          # Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
unloadCodepoints     ⇐           "UnloadCodepoints"     _R P i     # *codepoints                   # Unload codepoints data from memory
getCodepointCount    ⇐ i         "GetCodepointCount"    _R str     # *text                         # Get total number of codepoints in a UTF-8 encoded string
  getCodepointCountP ⇐ i         "GetCodepointCount"    _R ptr     # DUPLICATE
getCodepoint         ⇐ i         "GetCodepoint"         _R str⋈P i # *text *codepointSize          # Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
getCodepointNext     ⇐ i         "GetCodepointNext"     _R str⋈P i # *text *codepointSize          # Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
getCodepointPrevious ⇐ i         "GetCodepointPrevious" _R str⋈P i # *text *codepointSize          # Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
codepointToUTF8      ⇐ (ptr⊣str) "CodepointToUTF8"      _R i‿(P i) # codepoint *utf8Size           # Encode one codepoint into UTF-8 byte array (array length returned as parameter)


# Text strings management functions
TextSubtext   ⇐ {index‿len𝕊text:len↑index↓text}                                 #     i‿i𝕊str       → str      # Get a piece of a text string
⟨TextReplace⇐ReplaceAll⟩ ⇐ •Import bqnLibsPath •file.At "strings.bqn"           # str‿str𝕊str       → str      # Replace each instance of a string in old with the corresponding string in new. Instances are non-overlapping, and earlier ones take precedence.
TextInsert    ⇐ {insert‿pos𝕊text:∾⟜insert⊸∾´pos(↑⋈↓)text}                       #   str‿i𝕊str       → str      # Insert text in a position
TextJoin      ⇐ {delimiter𝕊texts:(≠delimiter)↓∾(<delimiter)∾¨texts}             #     str𝕊⟨str...⟩  → str      # textList delimiter # Join text strings with delimiter
TextSplit     ⇐ {𝕊text‿delimiter‿count:count↑delimiter((⊢-˜¬×·+`»⊸<)∘∊˜⊔⊢)text} #        𝕊str‿str‿i → ⟨str...⟩ # Split text into multiple strings
TextFindIndex ⇐ ⊑∘/⍷                                                            #     str𝕊str       → num      # Find first text occurrence within a string
TextToUpper   ⇐ -⟜(32×1="a{"⊸⍋)                                                 #        𝕊str       → str      # Get upper case version of provided string
TextToLower   ⇐ +⟜(32×1="A["⊸⍋)                                                 #        𝕊str       → str      # Get lower case version of provided string
TextToPascal  ⇐ {m←'_'≠𝕩⋄m/𝕩-32×¬»m}                                            #        𝕊str       → str      # Get Pascal case notation version of provided string
TextToInteger ⇐ •ParseFloat                                                     #        𝕊str       → num      # Get number from text

#------------------------------------------------------------------------------------
# Basic 3d Shapes Drawing Functions (Module: models)
#------------------------------------------------------------------------------------

# Basic geometric 3D shapes drawing functions
drawLine3D          ⇐ "DrawLine3D"         _R v3‿v3‿color         # startPos endPos color                              # Draw a line in 3D world space
drawPoint3D         ⇐ "DrawPoint3D"        _R v3‿color            # position color                                     # Draw a point in 3D space, actually a small line
drawCircle3D        ⇐ "DrawCircle3D"       _R v3‿f‿v3‿f‿color     # center radius rotationAxis rotationAngle color     # Draw a circle in 3D world space
drawTriangle3D      ⇐ "DrawTriangle3D"     _R v3‿v3‿v3‿color      # v1 v2 v3 color                                     # Draw a color-filled triangle (vertex in counter-clockwise order!)
drawTriangleStrip3D ⇐ "DrawTriangleStrip3D"_R (P v3)‿i‿color      # *points pointCount color                           # Draw a triangle strip defined by points
drawCube            ⇐ "DrawCube"           _R v3‿f‿f‿f‿color      # position width hight length color                  # Draw cube
drawCubeV           ⇐ "DrawCubeV"          _R v3‿v3‿color         # position size color                                # Draw cube (Vector version)
drawCubeWires       ⇐ "DrawCubeWires"      _R v3‿f‿f‿f‿color      # position width hight length color                  # Draw cube wires
drawCubeWiresV      ⇐ "DrawCubeWiresV"     _R v3‿v3‿color         # position size color                                # Draw cube wires (Vector version)
drawSphere          ⇐ "DrawSphere"         _R v3‿f‿color          # centerPos radius color                             # Draw sphere
drawSphereEx        ⇐ "DrawSphereEx"       _R v3‿f‿i‿i‿color      # centerPos radius rings slices color                # Draw sphere with extended parameters
drawSphereWires     ⇐ "DrawSphereWires"    _R v3‿f‿i‿i‿color      # centerPos radius rings slices color                # Draw sphere wires
drawCylinder        ⇐ "DrawCylinder"       _R v3‿f‿f‿f‿i‿color    # position radiusTop radiusBottom hight slices color # Draw a cylinder/cone
drawCylinderEx      ⇐ "DrawCylinderEx"     _R v3‿v3‿f‿f‿i‿color   # startPos endPos startRadius endRadius sides color  # Draw a cylinder with base at startPos and top at endPos
drawCylinderWires   ⇐ "DrawCylinderWires"  _R v3‿f‿f‿f‿i‿color    # position radiusTop radiusBottom hight slices color # Draw a cylinder/cone wires
drawCylinderWiresEx ⇐ "DrawCylinderWiresEx"_R v3‿v3‿f‿f‿i‿color   # startPos endPos startRadius endRadius sides color  # Draw a cylinder wires with base at startPos and top at endPos
drawCapsule         ⇐ "DrawCapsule"        _R v3‿v3‿f‿i‿i‿color   # startPos endPos radius slices rings color          # Draw a capsule with the center of its sphere caps at startPos and endPos
drawCapsuleWires    ⇐ "DrawCapsuleWires"   _R v3‿v3‿f‿i‿i‿color   # startPos endPos radius slices rings color          # Draw capsule wireframe with the center of its sphere caps at startPos and endPos
drawPlane           ⇐ "DrawPlane"          _R v3‿v2‿color         # centerPos size color                               # Draw a plane XZ
drawRay             ⇐ "DrawRay"            _R ray‿color                                                                # Draw a ray line
drawGrid            ⇐ "DrawGrid"           _R i‿f                 # slices spacing                                     # Draw a grid (centered at (0, 0, 0))

#------------------------------------------------------------------------------------
# Model 3d Loading and Drawing Functions (Module: models)
#------------------------------------------------------------------------------------

# Model management functions
loadModel           ⇐ model       "LoadModel"          _R str  # *fileName # Load model from files (meshes and materials)
loadModelFromMesh   ⇐ model       "LoadModelFromMesh"  _R mesh             # Load model from generated mesh (default material)
isModelReady        ⇐ bool        "IsModelReady"       _R model            # Check if a model is ready
unloadModel         ⇐             "UnloadModel"        _R model            # Unload model (including meshes) from memory (RAM and/or VRAM)
getModelBoundingBox ⇐ boundingBox "GetModelBoundingBox"_R model            # Compute model bounding box limits (considers all meshes)

# Model drawing functions
drawModel        ⇐ "DrawModel"       _R model‿v3‿f‿color                               # model position scale tint                                   # Draw a model (with texture if set)
drawModelEx      ⇐ "DrawModelEx"     _R model‿v3‿v3‿f‿v3‿color                         # model position rotationAxis rotationAngle scale tint        # Draw a model with extended parameters
drawModelWires   ⇐ "DrawModelWires"  _R model‿v3‿f‿color                               # model position scale tint                                   # Draw a model wires (with texture if set)
drawModelWiresEx ⇐ "DrawModelWiresEx"_R model‿v3‿v3‿f‿v3‿color                         # model position rotationAxis rotationAngle scale tint        # Draw a model wires (with texture if set) with extended parameters
drawBoundingBox  ⇐ "DrawBoundingBox" _R boundingBox‿color                              # box color                                                   # Draw bounding box (wires)
drawBillboard    ⇐ "DrawBillboard"   _R camera3d‿texture‿v3‿f‿color                    # camera texture position size tint                           # Draw a billboard texture
drawBillboardRec ⇐ "DrawBillboardRec"_R camera3d‿texture‿rectangle‿v3‿v2‿color         # camera texture source position size tint                    # Draw a billboard texture defined by source
drawBillboardPro ⇐ "DrawBillboardPro"_R camera3d‿texture‿rectangle‿v3‿v3‿v2‿v2‿f‿color # camera texture source position up size origin rotation tint # Draw a billboard texture defined by source and rotation

# Mesh management functions
uploadMesh         ⇐             "UploadMesh"         _R (P mesh)‿bool              # *mesh dynamic                       # Upload mesh vertex data in GPU and provide VAO/VBO ids
updateMeshBuffer   ⇐             "UpdateMeshBuffer"   _R mesh‿i‿(P u8)‿i‿i          # mesh index data dataSize offset     # Update mesh vertex data in GPU for a specific buffer index
unloadMesh         ⇐             "UnloadMesh"         _R mesh                       # mesh                                # Unload mesh data from CPU and GPU
drawMesh           ⇐             "DrawMesh"           _R mesh‿material‿matrix       # mesh material transform             # Draw a 3d mesh with material and transform
drawMeshInstanced  ⇐             "DrawMeshInstanced"  _R mesh‿material‿(P matrix)‿i # mesh material *transforms instances # Draw multiple mesh instances with material and different transforms
exportMesh         ⇐ bool        "ExportMesh"         _R mesh‿str                   # mesh *fileName                      # Export mesh data to file, returns true on success
getMeshBoundingBox ⇐ boundingBox "GetMeshBoundingBox" _R mesh                       # mesh                                # Compute mesh bounding box limits
genMeshTangents    ⇐             "GenMeshTangents"    _R mesh                       # mesh                                # Compute mesh tangents

# Mesh generation functions
genMeshPoly       ⇐ mesh "GenMeshPoly"       _R i‿f      # sides radius             # Generate polygonal mesh
genMeshPlane      ⇐ mesh "GenMeshPlane"      _R f‿f‿i‿i  # width length resX resZ   # Generate plane mesh (with subdivisions)
genMeshCube       ⇐ mesh "GenMeshCube"       _R f‿f‿f    # width height length      # Generate cuboid mesh
genMeshSphere     ⇐ mesh "GenMeshSphere"     _R f‿i‿i    # radius rings slices      # Generate sphere mesh (standard sphere)
genMeshHemiSphere ⇐ mesh "GenMeshHemiSphere" _R f‿i‿i    # radius rings slices      # Generate half-sphere mesh (no bottom cap)
genMeshCylinder   ⇐ mesh "GenMeshCylinder"   _R f‿f‿i    # radius height slices     # Generate cylinder mesh
genMeshCone       ⇐ mesh "GenMeshCone"       _R f‿f‿i    # radius height slices     # Generate cone/pyramid mesh
genMeshTorus      ⇐ mesh "GenMeshTorus"      _R f‿f‿i‿i  # radius size radSeg sides # Generate torus mesh
genMeshKnot       ⇐ mesh "GenMeshKnot"       _R f‿f‿i‿i  # radius size radSeg sides # Generate trefoil knot mesh
genMeshHeightmap  ⇐ mesh "GenMeshHeightmap"  _R image‿v3 # heightmap size           # Generate heightmap mesh from image data
genMeshCubicmap   ⇐ mesh "GenMeshCubicmap"   _R image‿v3 # cubicmap cubeSize        # Generate cubes-based map mesh from image data

# Material loading/unloading functions
loadMaterials        ⇐ (ptr⊣P material) "LoadMaterials"        _R str‿(P i)              # *fileName *materialCount  # Load materials from model file
loadMaterialDefault  ⇐ material         "LoadMaterialDefault"  _R@                                                   # Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
isMaterialReady      ⇐ bool             "IsMaterialReady"      _R material                                           # Check if a material is ready
unloadMaterial       ⇐                  "UnloadMaterial"       _R material                                           # Unload material from GPU memory (VRAM)
setMaterialTexture   ⇐                  "SetMaterialTexture"   _R (P material)‿i‿texture # *material mapType texture # Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
setModelMeshMaterial ⇐                  "SetModelMeshMaterial" _R (P model)‿i‿i          # *model meshId materialId  # Set material for a mesh

# Model animations loading/unloading functions
loadModelAnimations   ⇐ (ptr⊣P modelAnimation) "LoadModelAnimations"   _R str⋈P u                # *filename *anumCount # Load model animations from file
updateModelAnimation  ⇐                        "UpdateModelAnimation"  _R model‿modelAnimation‿i # model anim frame     # Update model animation pose
unloadModelAnimation  ⇐                        "UnloadModelAnimation"  _R modelAnimation                                # Unload animation data
unloadModelAnimations ⇐                        "UnloadModelAnimations" _R (P modelAnimation)‿u   # *animations count    # Unload animation array data
isModelAnimationValid ⇐ bool                   "IsModelAnimationValid" _R model‿modelAnimation                          # Check model animation skeleton match

# Collision detection functions
checkCollisionSpheres   ⇐ bool         "CheckCollisionSpheres"   _R v3‿f‿v3‿f               # center1 radius1 center2 radius2 # Check collision between two spheres
checkCollisionBoxes     ⇐ bool         "CheckCollisionBoxes"     _R boundingBox‿boundingBox # box1 box2                       # Check collision between two bounding boxes
checkCollisionBoxSphere ⇐ bool         "CheckCollisionBoxSphere" _R boundingBox‿v3‿f        # box center radius               # Check collision between box and sphere
getRayCollisionSphere   ⇐ rayCollision "GetRayCollisionSphere"   _R ray‿v3‿f                # ray center radius               # Get collision info between ray and sphere
getRayCollisionBox      ⇐ rayCollision "GetRayCollisionBox"      _R ray‿boundingBox         # ray box                         # Get collision info between ray and box
getRayCollisionMesh     ⇐ rayCollision "GetRayCollisionMesh"     _R ray‿mesh‿matrix         # ray mesh transform              # Get collision info between ray and mesh
getRayCollisionTriangle ⇐ rayCollision "GetRayCollisionTriangle" _R ray‿v3‿v3‿v3            # ray p1 p2 p3                    # Get collision info between ray and triangle
getRayCollisionQuad     ⇐ rayCollision "GetRayCollisionQuad"     _R ray‿v3‿v3‿v3‿v3         # ray p1 p2 p3 p4                 # Get collision info between ray and quad


#------------------------------------------------------------------------------------
# Audio Loading and Playing Functions (Module: audio)
#------------------------------------------------------------------------------------

# Audio device management functions
initAudioDevice    ⇐      "InitAudioDevice"    _R@           # Initialize audio device and context
closeAudioDevice   ⇐      "CloseAudioDevice"   _R@           # Close the audio device and context
isAudioDeviceReady ⇐ bool "IsAudioDeviceReady" _R@           # Check if audio device has been initialized successfully
setMasterVolume    ⇐      "SetMasterVolume"    _R f # volume # Set master volume (listener)

# Wave/Sound loading/unloading functions
loadWave           ⇐ wave  "LoadWave"           _R str         # *fileName                    # Load wave data from file
loadWaveFromMemory ⇐ wave  "LoadWaveFromMemory" _R str‿ustr‿i  # *fileType *fileData dataSize # Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
isWaveReady        ⇐ bool  "IsWaveReady"        _R wave                                       # Checks if wave data is ready
loadSound          ⇐ sound "LoadSound"          _R str         # *fileName                    # Load sound from file
loadSoundFromWave  ⇐ sound "LoadSoundFromWave"  _R wave                                       # Load sound from wave data
isSoundReady       ⇐ bool  "IsSoundReady"       _R sound                                      # Checks if a sound is ready
updateSound        ⇐       "UpdateSound"        _R sound‿ptr‿i # sound *data sampleCount      # Update sound buffer with new data
unloadWave         ⇐       "UnloadWave"         _R wave                                       # Unload wave data
unloadSound        ⇐       "UnloadSound"        _R sound                                      # Unload sound
exportWave         ⇐ bool  "ExportWave"         _R wave‿str    # wave *fileName               # Export wave data to file, returns true on success
exportWaveAsCode   ⇐ bool  "ExportWaveAsCode"   _R wave‿str    # wave *fileName               # Export wave sample data to code (.h), returns true on success

# Wave/Sound management functions
playSound         ⇐           "PlaySound"         _R sound                                                 # Play a sound
stopSound         ⇐           "StopSound"         _R sound                                                 # Stop playing a sound
pauseSound        ⇐           "PauseSound"        _R sound                                                 # Pause a sound
resumeSound       ⇐           "ResumeSound"       _R sound                                                 # Resume a paused sound
isSoundPlaying    ⇐ bool      "IsSoundPlaying"    _R sound                                                 # Check if a sound is currently playing
setSoundVolume    ⇐           "SetSoundVolume"    _R sound‿f        # sound volume                         # Set volume for a sound (1.0 is max level)
setSoundPitch     ⇐           "SetSoundPitch"     _R sound‿f        # sound pitch                          # Set pitch for a sound (1.0 is base level)
setSoundPan       ⇐           "SetSoundPan"       _R sound‿f        # sound pan                            # Set pan for a sound (0.5 is center)
waveCopy          ⇐ wave      "WaveCopy"          _R wave                                                  # Copy a wave to a new wave
waveCrop          ⇐           "WaveCrop"          _R (P wave)‿i‿i   # *wave initSample finalSample         # Crop a wave to defined samples range
waveFormat        ⇐           "WaveFormat"        _R (P wave)‿i‿i‿i # *wave sampleRate sampleSize channels # Convert wave data to desired format
loadWaveSamples   ⇐ (ptr⊣P f) "LoadWaveSamples"   _R wave           # wave                                 # Load samples data from wave as a 32bit float data array
unloadWaveSamples ⇐           "UnloadWaveSamples" _R P f            # *samples                             # Unload samples data loaded with LoadWaveSamples()

# Music management functions
loadMusicStream           ⇐ music "LoadMusicStream"           _R str        # *fileName                # Load music stream from file
loadMusicStreamFromMemory ⇐ music "LoadMusicStreamFromMemory" _R str‿ustr‿i # *fileType *data dataSize # Load music stream from data
isMusicReady              ⇐ bool  "IsMusicReady"              _R music                                 # Checks if a music stream is ready
unloadMusicStream         ⇐       "UnloadMusicStream"         _R music                                 # Unload music stream
playMusicStream           ⇐       "PlayMusicStream"           _R music                                 # Start music playing
isMusicStreamPlaying      ⇐ bool  "IsMusicStreamPlaying"      _R music                                 # Check if music is playing
updateMusicStream         ⇐       "UpdateMusicStream"         _R music                                 # Updates buffers for music streaming
stopMusicStream           ⇐       "StopMusicStream"           _R music                                 # Stop music playing
pauseMusicStream          ⇐       "PauseMusicStream"          _R music                                 # Pause music playing
resumeMusicStream         ⇐       "ResumeMusicStream"         _R music                                 # Resume playing paused music
seekMusicStream           ⇐       "SeekMusicStream"           _R music‿f    # music position           # Seek music to a position (in seconds)
setMusicVolume            ⇐       "SetMusicVolume"            _R music‿f    # music volume             # Set volume for music (1.0 is max level)
setMusicPitch             ⇐       "SetMusicPitch"             _R music‿f    # music pitch              # Set pitch for a music (1.0 is base level)
setMusicPan               ⇐       "SetMusicPan"               _R music‿f    # music pan                # Set pan for a music (0.5 is center)
getMusicTimeLength        ⇐ f     "GetMusicTimeLength"        _R music                                 # Get music time length (in seconds)
getMusicTimePlayed        ⇐ f     "GetMusicTimePlayed"        _R music                                 # Get current music time played (in seconds)

# AudioStream management functions
loadAudioStream                 ⇐ audioStream "LoadAudioStream"                 _R u‿u‿u             # sampleRate sampleSize channels # Load audio stream (to stream raw audio pcm data)
isAudioStreamReady              ⇐ bool        "IsAudioStreamReady"              _R audioStream       # stream                         # Checks if an audio stream is ready
unloadAudioStream               ⇐             "UnloadAudioStream"               _R audioStream       # stream                         # Unload audio stream and free memory
updateAudioStream               ⇐             "UpdateAudioStream"               _R audioStream‿ptr‿i # stream *data frameCount        # Update audio stream buffers with data
isAudioStreamProcessed          ⇐ bool        "IsAudioStreamProcessed"          _R audioStream       # stream                         # Check if any audio stream buffers requires refill
playAudioStream                 ⇐             "PlayAudioStream"                 _R audioStream       # stream                         # Play audio stream
pauseAudioStream                ⇐             "PauseAudioStream"                _R audioStream       # stream                         # Pause audio stream
resumeAudioStream               ⇐             "ResumeAudioStream"               _R audioStream       # stream                         # Resume audio stream
isAudioStreamPlaying            ⇐ bool        "IsAudioStreamPlaying"            _R audioStream       # stream                         # Check if audio stream is playing
stopAudioStream                 ⇐             "StopAudioStream"                 _R audioStream       # stream                         # Stop audio stream
setAudioStreamVolume            ⇐             "SetAudioStreamVolume"            _R audioStream‿f     # stream volume                  # Set volume for audio stream (1.0 is max level)
setAudioStreamPitch             ⇐             "SetAudioStreamPitch"             _R audioStream‿f     # stream pitch                   # Set pitch for audio stream (1.0 is base level)
setAudioStreamPan               ⇐             "SetAudioStreamPan"               _R audioStream‿f     # stream pan                     # Set pan for audio stream (0.5 is centered)
setAudioStreamBufferSizeDefault ⇐             "SetAudioStreamBufferSizeDefault" _R i                 # size                           # Default size for new audio streams
setAudioStreamCallback          ⇐             "SetAudioStreamCallback"          _R audioStream‿ptr   # stream callback                # Audio thread callback to request new data

attachAudioStreamProcessor ⇐ "AttachAudioStreamProcessor" _R audioStream‿ptr # stream (audioCallback processor) # Attach audio stream processor to stream
detachAudioStreamProcessor ⇐ "DetachAudioStreamProcessor" _R audioStream‿ptr # stream (audioCallback processor) # Detach audio stream processor from stream

attachAudioMixedProcessor ⇐ "AttachAudioMixedProcessor" _R ptr # (audioCallback processor) # Attach audio stream processor to the entire audio pipeline
detachAudioMixedProcessor ⇐ "DetachAudioMixedProcessor" _R ptr # (audioCallback processor) # Detach audio stream processor from the entire audio pipeline

#endregion