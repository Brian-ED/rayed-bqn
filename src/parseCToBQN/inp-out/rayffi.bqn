⟨
  MakeImporter # Makes an importer that improves the ffi function creation syntax
  P  # '*' means a pointer
  S  # Parse types into one struct

  # predefined C types
  i‿f‿u‿c‿i8‿bool‿u8‿str‿uStr‿ptr # i, f, and u are 32 sized, c is 8, str, ustr and ptr are 8 per char
  quaternion # quaternion isn't defined sometimes in c header files yet still used, so keeping this here makes my life easier
⟩⇐

# Makes an importer that improves the ffi function creation syntax
MakeImporter ⇐ {𝕨𝕊path: debug←𝕨⊣0
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

P ⇐ '*'⊸∾             # '*' means a pointer
S ⇐ {'{'∾'}'«∾','∾¨𝕩} # Parse types into one struct

# predefined C types
c ⇐ "i8"
bool ⇐ "i8"
i‿f‿u‿i8‿·‿u8 ⇐ ⥊"32"‿"8"∾˜⌜"ifu"
str‿uStr ⇐ P¨"iu"∾¨<"8:c8"
ptr ⇐ "*:i8"

quaternion ⇐ "[4]f32"
r ⇐ MakeImporter "/usr/local/lib/libraylib.so"

rAYLIB_VERSION_MAJOR ⇐ 5        
rAYLIB_VERSION_MINOR ⇐ 0        
rAYLIB_VERSION_PATCH ⇐ 0        
rAYLIB_VERSION       ⇐ "5.0-dev"

filePathList ⇐ S ⟨ # File path list 
  u   # capacity  # Filepaths max entries  
  u   # count     # Filepaths entries count
  ptr # paths     # Filepaths entries      
⟩
v2 ⇐ S ⟨ # Vector2, 2 components 
  f # x  # Vector x component
  f # y  # Vector y component
⟩
v3 ⇐ S ⟨ # Vector3, 3 components 
  f # x  # Vector x component
  f # y  # Vector y component
  f # z  # Vector z component
⟩
v4 ⇐ S ⟨ # Vector4, 4 components 
  f # x  # Vector x component
  f # y  # Vector y component
  f # z  # Vector z component
  f # w  # Vector w component
⟩
matrix ⇐ S ⟨ # Matrix, 4x4 components, column major, OpenGL style, right-handed 
  f # m0   # Matrix first row (4 components) 
  f # m4   # Matrix first row (4 components) 
  f # m8   # Matrix first row (4 components) 
  f # m12  # Matrix first row (4 components) 
  f # m1   # Matrix second row (4 components)
  f # m5   # Matrix second row (4 components)
  f # m9   # Matrix second row (4 components)
  f # m13  # Matrix second row (4 components)
  f # m2   # Matrix third row (4 components) 
  f # m6   # Matrix third row (4 components) 
  f # m10  # Matrix third row (4 components) 
  f # m14  # Matrix third row (4 components) 
  f # m3   # Matrix fourth row (4 components)
  f # m7   # Matrix fourth row (4 components)
  f # m11  # Matrix fourth row (4 components)
  f # m15  # Matrix fourth row (4 components)
⟩
color ⇐ S ⟨ # Color, 4 components, R8G8B8A8 (32bit) 
  u8 # r  # Color red value  
  u8 # g  # Color green value
  u8 # b  # Color blue value 
  u8 # a  # Color alpha value
⟩
rectangle ⇐ S ⟨ # Rectangle, 4 components 
  f # x       # Rectangle top-left corner position x
  f # y       # Rectangle top-left corner position y
  f # width   # Rectangle width                     
  f # height  # Rectangle height                    
⟩
image ⇐ S ⟨ # Image, pixel data stored in CPU memory (RAM) 
  ptr # data     # Image raw data                
  i   # width    # Image base width              
  i   # height   # Image base height             
  i   # mipmaps  # Mipmap levels, 1 by default   
  i   # format   # Data format (PixelFormat type)
⟩
texture ⇐ S ⟨ # Texture, tex data stored in GPU memory (VRAM) 
  u # id       # OpenGL texture id             
  i # width    # Texture base width            
  i # height   # Texture base height           
  i # mipmaps  # Mipmap levels, 1 by default   
  i # format   # Data format (PixelFormat type)
⟩
renderTexture ⇐ S ⟨ # RenderTexture, fbo for texture rendering 
  u       # id       # OpenGL framebuffer object id   
  texture # texture  # Color buffer attachment texture
  texture # depth    # Depth buffer attachment texture
⟩
nPatchInfo ⇐ S ⟨ # NPatchInfo, n-patch layout info 
  rectangle # source  # Texture source rectangle              
  i         # left    # Left border offset                    
  i         # top     # Top border offset                     
  i         # right   # Right border offset                   
  i         # bottom  # Bottom border offset                  
  i         # layout  # Layout of the n-patch: 3x3, 1x3 or 3x1
⟩
glyphInfo ⇐ S ⟨ # GlyphInfo, font characters glyphs info 
  i     # value     # Character value (Unicode)      
  i     # offsetX   # Character offset X when drawing
  i     # offsetY   # Character offset Y when drawing
  i     # advanceX  # Character advance position X   
  image # image     # Character image data           
⟩
font ⇐ S ⟨ # Font, font texture and GlyphInfo array data 
  i       # baseSize      # Base size (default chars height)    
  i       # glyphCount    # Number of glyph characters          
  i       # glyphPadding  # Padding around the glyph characters 
  texture # texture       # Texture atlas containing the glyphs 
  ptr     # recs          # Rectangles in texture for the glyphs
  ptr     # glyphs        # Glyphs info data                    
⟩
camera3D ⇐ S ⟨ # Camera, defines position/orientation in 3d space 
  v3 # position    # Camera position                                                                                      
  v3 # target      # Camera target it looks-at                                                                            
  v3 # up          # Camera up vector (rotation over its axis)                                                            
  f  # fovy        # Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
  i  # projection  # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC                                         
⟩
camera2D ⇐ S ⟨ # Camera2D, defines position/orientation in 2d space 
  v2 # offset    # Camera offset (displacement from target)        
  v2 # target    # Camera target (rotation and zoom origin)        
  f  # rotation  # Camera rotation in degrees                      
  f  # zoom      # Camera zoom (scaling), should be 1.0f by default
⟩
mesh ⇐ S ⟨ # Mesh, vertex data and vao/vbo 
  i         # vertexCount    # Number of vertices stored in arrays                                                   
  i         # triangleCount  # Number of triangles stored (indexed or not)                                           
  ptr⊣'*'∾f # vertices       # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)                 
  ptr⊣'*'∾f # texcoords      # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)       
  ptr⊣'*'∾f # texcoords2     # Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
  ptr⊣'*'∾f # normals        # Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)                  
  ptr⊣'*'∾f # tangents       # Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)                
  '*'∾u8    # colors         # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)                  
  "u16"     # indices        # Vertex indices (in case vertex data comes indexed)                                    
  ptr⊣'*'∾f # animVertices   # Animated vertex positions (after bones transformations)                               
  ptr⊣'*'∾f # animNormals    # Animated normals (after bones transformations)                                        
  '*'∾u8    # boneIds        # Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)       
  ptr⊣'*'∾f # boneWeights    # Vertex bone weight, up to 4 bones influence by vertex (skinning)                      
  u         # vaoId          # OpenGL Vertex Array Object id                                                         
  ptr⊣'*'∾u # vboId          # OpenGL Vertex Buffer Objects id (default vertex data)                                 
⟩
shader ⇐ S ⟨ # Shader 
  u         # id    # Shader program id                               
  ptr⊣'*'∾i # locs  # Shader locations array (RL_MAX_SHADER_LOCATIONS)
⟩
materialMap ⇐ S ⟨ # MaterialMap 
  texture # texture  # Material map texture
  color   # color    # Material map color  
  f       # value    # Material map value  
⟩
material ⇐ S ⟨ # Material, includes shader and maps 
  shader  # shader  # Material shader                          
  ptr     # maps    # Material maps array (MAX_MATERIAL_MAPS)  
  "[4]"∾f # params  # Material generic parameters (if required)
⟩
transform ⇐ S ⟨ # Transform, vertex transformation data 
  v3         # translation  # Translation
  quaternion # rotation     # Rotation   
  v3         # scale        # Scale      
⟩
boneInfo ⇐ S ⟨ # Bone, skeletal animation bone 
  "[32]"∾u8 # name    # Bone name  
  i         # parent  # Bone parent
⟩
model ⇐ S ⟨ # Model, meshes, materials and animation data 
  matrix           # transform      # Local transform matrix          
  i                # meshCount      # Number of meshes                
  i                # materialCount  # Number of materials             
  ptr⊣'*'∾mesh     # meshes         # Meshes array                    
  ptr⊣'*'∾material # materials      # Materials array                 
  ptr⊣'*'∾i        # meshMaterial   # Mesh material number            
  i                # boneCount      # Number of bones                 
  ptr              # bones          # Bones information (skeleton)    
  ptr              # bindPose       # Bones base transformation (pose)
⟩
modelAnimation ⇐ S ⟨ # ModelAnimation 
  i         # boneCount   # Number of bones             
  i         # frameCount  # Number of animation frames  
  ptr       # bones       # Bones information (skeleton)
  ptr       # framePoses  # Poses array by frame        
  "[32]"∾u8 # name        # Animation name              
⟩
ray ⇐ S ⟨ # Ray, ray for raycasting 
  v3 # position   # Ray position (origin)
  v3 # direction  # Ray direction        
⟩
rayCollision ⇐ S ⟨ # RayCollision, ray hit information 
  bool # hit       # Did the ray hit something? 
  f    # distance  # Distance to the nearest hit
  v3   # point     # Point of the nearest hit   
  v3   # normal    # Surface normal of hit      
⟩
boundingBox ⇐ S ⟨ # BoundingBox 
  v3 # min  # Minimum vertex box-corner
  v3 # max  # Maximum vertex box-corner
⟩
wave ⇐ S ⟨ # Wave, audio wave data 
  u   # frameCount  # Total number of frames (considering channels)            
  u   # sampleRate  # Frequency (samples per second)                           
  u   # sampleSize  # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  u   # channels    # Number of channels (1-mono, 2-stereo, ...)               
  ptr # data        # Buffer data pointer                                      
⟩
audioStream ⇐ S ⟨ # AudioStream, custom audio stream 
  ptr # buffer      # Pointer to internal data used by the audio system           
  ptr # processor   # Pointer to internal data processor, useful for audio effects
  u   # sampleRate  # Frequency (samples per second)                              
  u   # sampleSize  # Bit depth (bits per sample): 8, 16, 32 (24 not supported)   
  u   # channels    # Number of channels (1-mono, 2-stereo, ...)                  
⟩
sound ⇐ S ⟨ # Sound 
  audioStream # stream      # Audio stream                                 
  u           # frameCount  # Total number of frames (considering channels)
⟩
music ⇐ S ⟨ # Music, audio stream, anything longer than ~10 seconds should be streamed
  audioStream # stream      # Audio stream                                 
  u           # frameCount  # Total number of frames (considering channels)
  bool        # looping     # Music looping enable                         
  i           # ctxType     # Type of music context (audio filetype)       
  ptr         # ctxData     # Audio context data, depends on type          
⟩
vrDeviceInfo ⇐ S ⟨ # VrDeviceInfo, Head-Mounted-Display device parameters 
  i       # hResolution             # Horizontal resolution in pixels           
  i       # vResolution             # Vertical resolution in pixels             
  f       # hScreenSize             # Horizontal size in meters                 
  f       # vScreenSize             # Vertical size in meters                   
  f       # vScreenCenter           # Screen center in meters                   
  f       # eyeToScreenDistance     # Distance between eye and display in meters
  f       # lensSeparationDistance  # Lens separation distance in meters        
  f       # interpupillaryDistance  # IPD (distance between pupils) in meters   
  "[4]"∾f # lensDistortionValues    # Lens distortion constant parameters       
  "[4]"∾f # chromaAbCorrection      # Chromatic aberration correction parameters
⟩
vrStereoConfig ⇐ S ⟨ # VrStereoConfig, VR stereo rendering configuration for simulator 
  "[2]"∾matrix # projection         # VR projection matrices (per eye) 
  "[2]"∾matrix # viewOffset         # VR view offset matrices (per eye)
  "[2]"∾f      # leftLensCenter     # VR left lens center              
  "[2]"∾f      # rightLensCenter    # VR right lens center             
  "[2]"∾f      # leftScreenCenter   # VR left screen center            
  "[2]"∾f      # rightScreenCenter  # VR right screen center           
  "[2]"∾f      # scale              # VR distortion scale              
  "[2]"∾f      # scaleIn            # VR distortion scale in           
⟩


configFlags ⇐ { # System/Window config flags
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
  fLAG_BORDERLESS_WINDOWED_MODE ⇐ 32768  # Set to run program in borderless windowed mode                               
  fLAG_MSAA_4X_HINT             ⇐ 32     # Set to try enabling MSAA 4X                                                  
  fLAG_INTERLACED_HINT          ⇐ 65536  # Set to try enabling interlaced video format (for V3D)                        
}
traceLogLevel ⇐ { # Trace log level
  lOG_ALL     ⇐ 0  # Display all logs                                                                   
  lOG_TRACE   ⇐ 1  # Trace logging, intended for internal use only                                      
  lOG_DEBUG   ⇐ 2  # Debug logging, used for internal debugging, it should be disabled on release builds
  lOG_INFO    ⇐ 3  # Info logging, used for program execution info                                      
  lOG_WARNING ⇐ 4  # Warning logging, used on recoverable failures                                      
  lOG_ERROR   ⇐ 5  # Error logging, used on unrecoverable failures                                      
  lOG_FATAL   ⇐ 6  # Fatal logging, used to abort program: exit(EXIT_FAILURE)                           
  lOG_NONE    ⇐ 7  # Disable logging                                                                    
}
keyboardKey ⇐ { # Keyboard keys (US keyboard layout)
  kEY_NULL          ⇐ 0    # Key: NULL, used for no key pressed
  kEY_APOSTROPHE    ⇐ 39   # Key: '                            
  kEY_COMMA         ⇐ 44   # Key: ,                            
  kEY_MINUS         ⇐ 45   # Key: -                            
  kEY_PERIOD        ⇐ 46   # Key: .                            
  kEY_SLASH         ⇐ 47   # Key: /                            
  kEY_ZERO          ⇐ 48   # Key: 0                            
  kEY_ONE           ⇐ 49   # Key: 1                            
  kEY_TWO           ⇐ 50   # Key: 2                            
  kEY_THREE         ⇐ 51   # Key: 3                            
  kEY_FOUR          ⇐ 52   # Key: 4                            
  kEY_FIVE          ⇐ 53   # Key: 5                            
  kEY_SIX           ⇐ 54   # Key: 6                            
  kEY_SEVEN         ⇐ 55   # Key: 7                            
  kEY_EIGHT         ⇐ 56   # Key: 8                            
  kEY_NINE          ⇐ 57   # Key: 9                            
  kEY_SEMICOLON     ⇐ 59   # Key: ;                            
  kEY_EQUAL         ⇐ 61   # Key: =                            
  kEY_A             ⇐ 65   # Key: A | a                        
  kEY_B             ⇐ 66   # Key: B | b                        
  kEY_C             ⇐ 67   # Key: C | c                        
  kEY_D             ⇐ 68   # Key: D | d                        
  kEY_E             ⇐ 69   # Key: E | e                        
  kEY_F             ⇐ 70   # Key: F | f                        
  kEY_G             ⇐ 71   # Key: G | g                        
  kEY_H             ⇐ 72   # Key: H | h                        
  kEY_I             ⇐ 73   # Key: I | i                        
  kEY_J             ⇐ 74   # Key: J | j                        
  kEY_K             ⇐ 75   # Key: K | k                        
  kEY_L             ⇐ 76   # Key: L | l                        
  kEY_M             ⇐ 77   # Key: M | m                        
  kEY_N             ⇐ 78   # Key: N | n                        
  kEY_O             ⇐ 79   # Key: O | o                        
  kEY_P             ⇐ 80   # Key: P | p                        
  kEY_Q             ⇐ 81   # Key: Q | q                        
  kEY_R             ⇐ 82   # Key: R | r                        
  kEY_S             ⇐ 83   # Key: S | s                        
  kEY_T             ⇐ 84   # Key: T | t                        
  kEY_U             ⇐ 85   # Key: U | u                        
  kEY_V             ⇐ 86   # Key: V | v                        
  kEY_W             ⇐ 87   # Key: W | w                        
  kEY_X             ⇐ 88   # Key: X | x                        
  kEY_Y             ⇐ 89   # Key: Y | y                        
  kEY_Z             ⇐ 90   # Key: Z | z                        
  kEY_LEFT_BRACKET  ⇐ 91   # Key: [                            
  kEY_BACKSLASH     ⇐ 92   # Key: '\'                          
  kEY_RIGHT_BRACKET ⇐ 93   # Key: ]                            
  kEY_GRAVE         ⇐ 96   # Key: `                            
  kEY_SPACE         ⇐ 32   # Key: Space                        
  kEY_ESCAPE        ⇐ 256  # Key: Esc                          
  kEY_ENTER         ⇐ 257  # Key: Enter                        
  kEY_TAB           ⇐ 258  # Key: Tab                          
  kEY_BACKSPACE     ⇐ 259  # Key: Backspace                    
  kEY_INSERT        ⇐ 260  # Key: Ins                          
  kEY_DELETE        ⇐ 261  # Key: Del                          
  kEY_RIGHT         ⇐ 262  # Key: Cursor right                 
  kEY_LEFT          ⇐ 263  # Key: Cursor left                  
  kEY_DOWN          ⇐ 264  # Key: Cursor down                  
  kEY_UP            ⇐ 265  # Key: Cursor up                    
  kEY_PAGE_UP       ⇐ 266  # Key: Page up                      
  kEY_PAGE_DOWN     ⇐ 267  # Key: Page down                    
  kEY_HOME          ⇐ 268  # Key: Home                         
  kEY_END           ⇐ 269  # Key: End                          
  kEY_CAPS_LOCK     ⇐ 280  # Key: Caps lock                    
  kEY_SCROLL_LOCK   ⇐ 281  # Key: Scroll down                  
  kEY_NUM_LOCK      ⇐ 282  # Key: Num lock                     
  kEY_PRINT_SCREEN  ⇐ 283  # Key: Print screen                 
  kEY_PAUSE         ⇐ 284  # Key: Pause                        
  kEY_F1            ⇐ 290  # Key: F1                           
  kEY_F2            ⇐ 291  # Key: F2                           
  kEY_F3            ⇐ 292  # Key: F3                           
  kEY_F4            ⇐ 293  # Key: F4                           
  kEY_F5            ⇐ 294  # Key: F5                           
  kEY_F6            ⇐ 295  # Key: F6                           
  kEY_F7            ⇐ 296  # Key: F7                           
  kEY_F8            ⇐ 297  # Key: F8                           
  kEY_F9            ⇐ 298  # Key: F9                           
  kEY_F10           ⇐ 299  # Key: F10                          
  kEY_F11           ⇐ 300  # Key: F11                          
  kEY_F12           ⇐ 301  # Key: F12                          
  kEY_LEFT_SHIFT    ⇐ 340  # Key: Shift left                   
  kEY_LEFT_CONTROL  ⇐ 341  # Key: Control left                 
  kEY_LEFT_ALT      ⇐ 342  # Key: Alt left                     
  kEY_LEFT_SUPER    ⇐ 343  # Key: Super left                   
  kEY_RIGHT_SHIFT   ⇐ 344  # Key: Shift right                  
  kEY_RIGHT_CONTROL ⇐ 345  # Key: Control right                
  kEY_RIGHT_ALT     ⇐ 346  # Key: Alt right                    
  kEY_RIGHT_SUPER   ⇐ 347  # Key: Super right                  
  kEY_KB_MENU       ⇐ 348  # Key: KB menu                      
  kEY_KP_0          ⇐ 320  # Key: Keypad 0                     
  kEY_KP_1          ⇐ 321  # Key: Keypad 1                     
  kEY_KP_2          ⇐ 322  # Key: Keypad 2                     
  kEY_KP_3          ⇐ 323  # Key: Keypad 3                     
  kEY_KP_4          ⇐ 324  # Key: Keypad 4                     
  kEY_KP_5          ⇐ 325  # Key: Keypad 5                     
  kEY_KP_6          ⇐ 326  # Key: Keypad 6                     
  kEY_KP_7          ⇐ 327  # Key: Keypad 7                     
  kEY_KP_8          ⇐ 328  # Key: Keypad 8                     
  kEY_KP_9          ⇐ 329  # Key: Keypad 9                     
  kEY_KP_DECIMAL    ⇐ 330  # Key: Keypad .                     
  kEY_KP_DIVIDE     ⇐ 331  # Key: Keypad /                     
  kEY_KP_MULTIPLY   ⇐ 332  # Key: Keypad *                     
  kEY_KP_SUBTRACT   ⇐ 333  # Key: Keypad -                     
  kEY_KP_ADD        ⇐ 334  # Key: Keypad +                     
  kEY_KP_ENTER      ⇐ 335  # Key: Keypad Enter                 
  kEY_KP_EQUAL      ⇐ 336  # Key: Keypad =                     
  kEY_BACK          ⇐ 4    # Key: Android back button          
  kEY_MENU          ⇐ 82   # Key: Android menu button          
  kEY_VOLUME_UP     ⇐ 24   # Key: Android volume up button     
  kEY_VOLUME_DOWN   ⇐ 25   # Key: Android volume down button   
}
mouseButton ⇐ { # Mouse buttons
  mOUSE_BUTTON_LEFT    ⇐ 0  # Mouse button left                           
  mOUSE_BUTTON_RIGHT   ⇐ 1  # Mouse button right                          
  mOUSE_BUTTON_MIDDLE  ⇐ 2  # Mouse button middle (pressed wheel)         
  mOUSE_BUTTON_SIDE    ⇐ 3  # Mouse button side (advanced mouse device)   
  mOUSE_BUTTON_EXTRA   ⇐ 4  # Mouse button extra (advanced mouse device)  
  mOUSE_BUTTON_FORWARD ⇐ 5  # Mouse button forward (advanced mouse device)
  mOUSE_BUTTON_BACK    ⇐ 6  # Mouse button back (advanced mouse device)   
}
mouseCursor ⇐ { # Mouse cursor
  mOUSE_CURSOR_DEFAULT       ⇐ 0   # Default pointer shape                                        
  mOUSE_CURSOR_ARROW         ⇐ 1   # Arrow shape                                                  
  mOUSE_CURSOR_IBEAM         ⇐ 2   # Text writing cursor shape                                    
  mOUSE_CURSOR_CROSSHAIR     ⇐ 3   # Cross shape                                                  
  mOUSE_CURSOR_POINTING_HAND ⇐ 4   # Pointing hand cursor                                         
  mOUSE_CURSOR_RESIZE_EW     ⇐ 5   # Horizontal resize/move arrow shape                           
  mOUSE_CURSOR_RESIZE_NS     ⇐ 6   # Vertical resize/move arrow shape                             
  mOUSE_CURSOR_RESIZE_NWSE   ⇐ 7   # Top-left to bottom-right diagonal resize/move arrow shape    
  mOUSE_CURSOR_RESIZE_NESW   ⇐ 8   # The top-right to bottom-left diagonal resize/move arrow shape
  mOUSE_CURSOR_RESIZE_ALL    ⇐ 9   # The omnidirectional resize/move cursor shape                 
  mOUSE_CURSOR_NOT_ALLOWED   ⇐ 10  # The operation-not-allowed shape                              
}
gamepadButton ⇐ { # Gamepad buttons
  gAMEPAD_BUTTON_UNKNOWN          ⇐ 0   # Unknown button, just for error checking                               
  gAMEPAD_BUTTON_LEFT_FACE_UP     ⇐ 1   # Gamepad left DPAD up button                                           
  gAMEPAD_BUTTON_LEFT_FACE_RIGHT  ⇐ 2   # Gamepad left DPAD right button                                        
  gAMEPAD_BUTTON_LEFT_FACE_DOWN   ⇐ 3   # Gamepad left DPAD down button                                         
  gAMEPAD_BUTTON_LEFT_FACE_LEFT   ⇐ 4   # Gamepad left DPAD left button                                         
  gAMEPAD_BUTTON_RIGHT_FACE_UP    ⇐ 5   # Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)                 
  gAMEPAD_BUTTON_RIGHT_FACE_RIGHT ⇐ 6   # Gamepad right button right (i.e. PS3: Square, Xbox: X)                
  gAMEPAD_BUTTON_RIGHT_FACE_DOWN  ⇐ 7   # Gamepad right button down (i.e. PS3: Cross, Xbox: A)                  
  gAMEPAD_BUTTON_RIGHT_FACE_LEFT  ⇐ 8   # Gamepad right button left (i.e. PS3: Circle, Xbox: B)                 
  gAMEPAD_BUTTON_LEFT_TRIGGER_1   ⇐ 9   # Gamepad top/back trigger left (first), it could be a trailing button  
  gAMEPAD_BUTTON_LEFT_TRIGGER_2   ⇐ 10  # Gamepad top/back trigger left (second), it could be a trailing button 
  gAMEPAD_BUTTON_RIGHT_TRIGGER_1  ⇐ 11  # Gamepad top/back trigger right (one), it could be a trailing button   
  gAMEPAD_BUTTON_RIGHT_TRIGGER_2  ⇐ 12  # Gamepad top/back trigger right (second), it could be a trailing button
  gAMEPAD_BUTTON_MIDDLE_LEFT      ⇐ 13  # Gamepad center buttons, left one (i.e. PS3: Select)                   
  gAMEPAD_BUTTON_MIDDLE           ⇐ 14  # Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)         
  gAMEPAD_BUTTON_MIDDLE_RIGHT     ⇐ 15  # Gamepad center buttons, right one (i.e. PS3: Start)                   
  gAMEPAD_BUTTON_LEFT_THUMB       ⇐ 16  # Gamepad joystick pressed button left                                  
  gAMEPAD_BUTTON_RIGHT_THUMB      ⇐ 17  # Gamepad joystick pressed button right                                 
}
gamepadAxis ⇐ { # Gamepad axis
  gAMEPAD_AXIS_LEFT_X        ⇐ 0  # Gamepad left stick X axis                          
  gAMEPAD_AXIS_LEFT_Y        ⇐ 1  # Gamepad left stick Y axis                          
  gAMEPAD_AXIS_RIGHT_X       ⇐ 2  # Gamepad right stick X axis                         
  gAMEPAD_AXIS_RIGHT_Y       ⇐ 3  # Gamepad right stick Y axis                         
  gAMEPAD_AXIS_LEFT_TRIGGER  ⇐ 4  # Gamepad back trigger left, pressure level: [1..-1] 
  gAMEPAD_AXIS_RIGHT_TRIGGER ⇐ 5  # Gamepad back trigger right, pressure level: [1..-1]
}
materialMapIndex ⇐ { # Material map index
  mATERIAL_MAP_ALBEDO     ⇐ 0   # Albedo material (same as: MATERIAL_MAP_DIFFUSE)     
  mATERIAL_MAP_METALNESS  ⇐ 1   # Metalness material (same as: MATERIAL_MAP_SPECULAR) 
  mATERIAL_MAP_NORMAL     ⇐ 2   # Normal material                                     
  mATERIAL_MAP_ROUGHNESS  ⇐ 3   # Roughness material                                  
  mATERIAL_MAP_OCCLUSION  ⇐ 4   # Ambient occlusion material                          
  mATERIAL_MAP_EMISSION   ⇐ 5   # Emission material                                   
  mATERIAL_MAP_HEIGHT     ⇐ 6   # Heightmap material                                  
  mATERIAL_MAP_CUBEMAP    ⇐ 7   # Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)   
  mATERIAL_MAP_IRRADIANCE ⇐ 8   # Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  mATERIAL_MAP_PREFILTER  ⇐ 9   # Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP) 
  mATERIAL_MAP_BRDF       ⇐ 10  # Brdf material                                       
}
shaderLocationIndex ⇐ { # Shader location index
  sHADER_LOC_VERTEX_POSITION   ⇐ 0   # Shader location: vertex attribute: position                                     
  sHADER_LOC_VERTEX_TEXCOORD01 ⇐ 1   # Shader location: vertex attribute: texcoord01                                   
  sHADER_LOC_VERTEX_TEXCOORD02 ⇐ 2   # Shader location: vertex attribute: texcoord02                                   
  sHADER_LOC_VERTEX_NORMAL     ⇐ 3   # Shader location: vertex attribute: normal                                       
  sHADER_LOC_VERTEX_TANGENT    ⇐ 4   # Shader location: vertex attribute: tangent                                      
  sHADER_LOC_VERTEX_COLOR      ⇐ 5   # Shader location: vertex attribute: color                                        
  sHADER_LOC_MATRIX_MVP        ⇐ 6   # Shader location: matrix uniform: model-view-projection                          
  sHADER_LOC_MATRIX_VIEW       ⇐ 7   # Shader location: matrix uniform: view (camera transform)                        
  sHADER_LOC_MATRIX_PROJECTION ⇐ 8   # Shader location: matrix uniform: projection                                     
  sHADER_LOC_MATRIX_MODEL      ⇐ 9   # Shader location: matrix uniform: model (transform)                              
  sHADER_LOC_MATRIX_NORMAL     ⇐ 10  # Shader location: matrix uniform: normal                                         
  sHADER_LOC_VECTOR_VIEW       ⇐ 11  # Shader location: vector uniform: view                                           
  sHADER_LOC_COLOR_DIFFUSE     ⇐ 12  # Shader location: vector uniform: diffuse color                                  
  sHADER_LOC_COLOR_SPECULAR    ⇐ 13  # Shader location: vector uniform: specular color                                 
  sHADER_LOC_COLOR_AMBIENT     ⇐ 14  # Shader location: vector uniform: ambient color                                  
  sHADER_LOC_MAP_ALBEDO        ⇐ 15  # Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)    
  sHADER_LOC_MAP_METALNESS     ⇐ 16  # Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
  sHADER_LOC_MAP_NORMAL        ⇐ 17  # Shader location: sampler2d texture: normal                                      
  sHADER_LOC_MAP_ROUGHNESS     ⇐ 18  # Shader location: sampler2d texture: roughness                                   
  sHADER_LOC_MAP_OCCLUSION     ⇐ 19  # Shader location: sampler2d texture: occlusion                                   
  sHADER_LOC_MAP_EMISSION      ⇐ 20  # Shader location: sampler2d texture: emission                                    
  sHADER_LOC_MAP_HEIGHT        ⇐ 21  # Shader location: sampler2d texture: height                                      
  sHADER_LOC_MAP_CUBEMAP       ⇐ 22  # Shader location: samplerCube texture: cubemap                                   
  sHADER_LOC_MAP_IRRADIANCE    ⇐ 23  # Shader location: samplerCube texture: irradiance                                
  sHADER_LOC_MAP_PREFILTER     ⇐ 24  # Shader location: samplerCube texture: prefilter                                 
  sHADER_LOC_MAP_BRDF          ⇐ 25  # Shader location: sampler2d texture: brdf                                        
}
shaderUniformDataType ⇐ { # Shader uniform data type
  sHADER_UNIFORM_FLOAT     ⇐ 0  # Shader uniform type: float         
  sHADER_UNIFORM_VEC2      ⇐ 1  # Shader uniform type: vec2 (2 float)
  sHADER_UNIFORM_VEC3      ⇐ 2  # Shader uniform type: vec3 (3 float)
  sHADER_UNIFORM_VEC4      ⇐ 3  # Shader uniform type: vec4 (4 float)
  sHADER_UNIFORM_INT       ⇐ 4  # Shader uniform type: int           
  sHADER_UNIFORM_IVEC2     ⇐ 5  # Shader uniform type: ivec2 (2 int) 
  sHADER_UNIFORM_IVEC3     ⇐ 6  # Shader uniform type: ivec3 (3 int) 
  sHADER_UNIFORM_IVEC4     ⇐ 7  # Shader uniform type: ivec4 (4 int) 
  sHADER_UNIFORM_SAMPLER2D ⇐ 8  # Shader uniform type: sampler2d     
}
shaderAttributeDataType ⇐ { # Shader attribute data types
  sHADER_ATTRIB_FLOAT ⇐ 0  # Shader attribute type: float         
  sHADER_ATTRIB_VEC2  ⇐ 1  # Shader attribute type: vec2 (2 float)
  sHADER_ATTRIB_VEC3  ⇐ 2  # Shader attribute type: vec3 (3 float)
  sHADER_ATTRIB_VEC4  ⇐ 3  # Shader attribute type: vec4 (4 float)
}
pixelFormat ⇐ { # Pixel formats
  pIXELFORMAT_UNCOMPRESSED_GRAYSCALE    ⇐ 1   # 8 bit per pixel (no alpha)        
  pIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA   ⇐ 2   # 8*2 bpp (2 channels)              
  pIXELFORMAT_UNCOMPRESSED_R5G6B5       ⇐ 3   # 16 bpp                            
  pIXELFORMAT_UNCOMPRESSED_R8G8B8       ⇐ 4   # 24 bpp                            
  pIXELFORMAT_UNCOMPRESSED_R5G5B5A1     ⇐ 5   # 16 bpp (1 bit alpha)              
  pIXELFORMAT_UNCOMPRESSED_R4G4B4A4     ⇐ 6   # 16 bpp (4 bit alpha)              
  pIXELFORMAT_UNCOMPRESSED_R8G8B8A8     ⇐ 7   # 32 bpp                            
  pIXELFORMAT_UNCOMPRESSED_R32          ⇐ 8   # 32 bpp (1 channel - float)        
  pIXELFORMAT_UNCOMPRESSED_R32G32B32    ⇐ 9   # 32*3 bpp (3 channels - float)     
  pIXELFORMAT_UNCOMPRESSED_R32G32B32A32 ⇐ 10  # 32*4 bpp (4 channels - float)     
  pIXELFORMAT_UNCOMPRESSED_R16          ⇐ 11  # 16 bpp (1 channel - half float)   
  pIXELFORMAT_UNCOMPRESSED_R16G16B16    ⇐ 12  # 16*3 bpp (3 channels - half float)
  pIXELFORMAT_UNCOMPRESSED_R16G16B16A16 ⇐ 13  # 16*4 bpp (4 channels - half float)
  pIXELFORMAT_COMPRESSED_DXT1_RGB       ⇐ 14  # 4 bpp (no alpha)                  
  pIXELFORMAT_COMPRESSED_DXT1_RGBA      ⇐ 15  # 4 bpp (1 bit alpha)               
  pIXELFORMAT_COMPRESSED_DXT3_RGBA      ⇐ 16  # 8 bpp                             
  pIXELFORMAT_COMPRESSED_DXT5_RGBA      ⇐ 17  # 8 bpp                             
  pIXELFORMAT_COMPRESSED_ETC1_RGB       ⇐ 18  # 4 bpp                             
  pIXELFORMAT_COMPRESSED_ETC2_RGB       ⇐ 19  # 4 bpp                             
  pIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA  ⇐ 20  # 8 bpp                             
  pIXELFORMAT_COMPRESSED_PVRT_RGB       ⇐ 21  # 4 bpp                             
  pIXELFORMAT_COMPRESSED_PVRT_RGBA      ⇐ 22  # 4 bpp                             
  pIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA  ⇐ 23  # 8 bpp                             
  pIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA  ⇐ 24  # 2 bpp                             
}
textureFilter ⇐ { # Texture parameters: filter mode
  tEXTURE_FILTER_POINT           ⇐ 0  # No filter, just pixel approximation      
  tEXTURE_FILTER_BILINEAR        ⇐ 1  # Linear filtering                         
  tEXTURE_FILTER_TRILINEAR       ⇐ 2  # Trilinear filtering (linear with mipmaps)
  tEXTURE_FILTER_ANISOTROPIC_4X  ⇐ 3  # Anisotropic filtering 4x                 
  tEXTURE_FILTER_ANISOTROPIC_8X  ⇐ 4  # Anisotropic filtering 8x                 
  tEXTURE_FILTER_ANISOTROPIC_16X ⇐ 5  # Anisotropic filtering 16x                
}
textureWrap ⇐ { # Texture parameters: wrap mode
  tEXTURE_WRAP_REPEAT        ⇐ 0  # Repeats texture in tiled mode                         
  tEXTURE_WRAP_CLAMP         ⇐ 1  # Clamps texture to edge pixel in tiled mode            
  tEXTURE_WRAP_MIRROR_REPEAT ⇐ 2  # Mirrors and repeats the texture in tiled mode         
  tEXTURE_WRAP_MIRROR_CLAMP  ⇐ 3  # Mirrors and clamps to border the texture in tiled mode
}
cubemapLayout ⇐ { # Cubemap layouts
  cUBEMAP_LAYOUT_AUTO_DETECT         ⇐ 0  # Automatically detect layout type                            
  cUBEMAP_LAYOUT_LINE_VERTICAL       ⇐ 1  # Layout is defined by a vertical line with faces             
  cUBEMAP_LAYOUT_LINE_HORIZONTAL     ⇐ 2  # Layout is defined by a horizontal line with faces           
  cUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR ⇐ 3  # Layout is defined by a 3x4 cross with cubemap faces         
  cUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE ⇐ 4  # Layout is defined by a 4x3 cross with cubemap faces         
  cUBEMAP_LAYOUT_PANORAMA            ⇐ 5  # Layout is defined by a panorama image (equirrectangular map)
}
fontType ⇐ { # Font type, defines generation method
  fONT_DEFAULT ⇐ 0  # Default font generation, anti-aliased        
  fONT_BITMAP  ⇐ 1  # Bitmap font generation, no anti-aliasing     
  fONT_SDF     ⇐ 2  # SDF font generation, requires external shader
}
blendMode ⇐ { # Color blending modes (pre-defined)
  bLEND_ALPHA             ⇐ 0  # Blend textures considering alpha (default)                                                      
  bLEND_ADDITIVE          ⇐ 1  # Blend textures adding colors                                                                    
  bLEND_MULTIPLIED        ⇐ 2  # Blend textures multiplying colors                                                               
  bLEND_ADD_COLORS        ⇐ 3  # Blend textures adding colors (alternative)                                                      
  bLEND_SUBTRACT_COLORS   ⇐ 4  # Blend textures subtracting colors (alternative)                                                 
  bLEND_ALPHA_PREMULTIPLY ⇐ 5  # Blend premultiplied textures considering alpha                                                  
  bLEND_CUSTOM            ⇐ 6  # Blend textures using custom src/dst factors (use rlSetBlendFactors())                           
  bLEND_CUSTOM_SEPARATE   ⇐ 7  # Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
}
gesture ⇐ { # Gesture
  gESTURE_NONE        ⇐ 0    # No gesture         
  gESTURE_TAP         ⇐ 1    # Tap gesture        
  gESTURE_DOUBLETAP   ⇐ 2    # Double tap gesture 
  gESTURE_HOLD        ⇐ 4    # Hold gesture       
  gESTURE_DRAG        ⇐ 8    # Drag gesture       
  gESTURE_SWIPE_RIGHT ⇐ 16   # Swipe right gesture
  gESTURE_SWIPE_LEFT  ⇐ 32   # Swipe left gesture 
  gESTURE_SWIPE_UP    ⇐ 64   # Swipe up gesture   
  gESTURE_SWIPE_DOWN  ⇐ 128  # Swipe down gesture 
  gESTURE_PINCH_IN    ⇐ 256  # Pinch in gesture   
  gESTURE_PINCH_OUT   ⇐ 512  # Pinch out gesture  
}
cameraMode ⇐ { # Camera system modes
  cAMERA_CUSTOM       ⇐ 0  # Custom camera      
  cAMERA_FREE         ⇐ 1  # Free camera        
  cAMERA_ORBITAL      ⇐ 2  # Orbital camera     
  cAMERA_FIRST_PERSON ⇐ 3  # First person camera
  cAMERA_THIRD_PERSON ⇐ 4  # Third person camera
}
cameraProjection ⇐ { # Camera projection
  cAMERA_PERSPECTIVE  ⇐ 0  # Perspective projection 
  cAMERA_ORTHOGRAPHIC ⇐ 1  # Orthographic projection
}
nPatchLayout ⇐ { # N-patch layout
  nPATCH_NINE_PATCH             ⇐ 0  # Npatch layout: 3x3 tiles
  nPATCH_THREE_PATCH_VERTICAL   ⇐ 1  # Npatch layout: 1x3 tiles
  nPATCH_THREE_PATCH_HORIZONTAL ⇐ 2  # Npatch layout: 3x1 tiles
}


initWindow                      ⇐                         "InitWindow"                      _R⟨i⋄i⋄'*'∾u8⟩                                    # width height title                                                # Initialize window and OpenGL context                                                                                                
closeWindow                     ⇐                         "CloseWindow"                     _R⟨⟩                                              #                                                                   # Close window and unload OpenGL context                                                                                              
windowShouldClose               ⇐ bool                    "WindowShouldClose"               _R⟨⟩                                              #                                                                   # Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)                                                
isWindowReady                   ⇐ bool                    "IsWindowReady"                   _R⟨⟩                                              #                                                                   # Check if window has been initialized successfully                                                                                   
isWindowFullscreen              ⇐ bool                    "IsWindowFullscreen"              _R⟨⟩                                              #                                                                   # Check if window is currently fullscreen                                                                                             
isWindowHidden                  ⇐ bool                    "IsWindowHidden"                  _R⟨⟩                                              #                                                                   # Check if window is currently hidden (only PLATFORM_DESKTOP)                                                                         
isWindowMinimized               ⇐ bool                    "IsWindowMinimized"               _R⟨⟩                                              #                                                                   # Check if window is currently minimized (only PLATFORM_DESKTOP)                                                                      
isWindowMaximized               ⇐ bool                    "IsWindowMaximized"               _R⟨⟩                                              #                                                                   # Check if window is currently maximized (only PLATFORM_DESKTOP)                                                                      
isWindowFocused                 ⇐ bool                    "IsWindowFocused"                 _R⟨⟩                                              #                                                                   # Check if window is currently focused (only PLATFORM_DESKTOP)                                                                        
isWindowResized                 ⇐ bool                    "IsWindowResized"                 _R⟨⟩                                              #                                                                   # Check if window has been resized last frame                                                                                         
isWindowState                   ⇐ bool                    "IsWindowState"                   _R⟨u⟩                                             # flag                                                              # Check if one specific window flag is enabled                                                                                        
setWindowState                  ⇐                         "SetWindowState"                  _R⟨u⟩                                             # flags                                                             # Set window configuration state using flags (only PLATFORM_DESKTOP)                                                                  
clearWindowState                ⇐                         "ClearWindowState"                _R⟨u⟩                                             # flags                                                             # Clear window configuration state flags                                                                                              
toggleFullscreen                ⇐                         "ToggleFullscreen"                _R⟨⟩                                              #                                                                   # Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)                                                                    
toggleBorderlessWindowed        ⇐                         "ToggleBorderlessWindowed"        _R⟨⟩                                              #                                                                   # Toggle window state: borderless windowed (only PLATFORM_DESKTOP)                                                                    
maximizeWindow                  ⇐                         "MaximizeWindow"                  _R⟨⟩                                              #                                                                   # Set window state: maximized, if resizable (only PLATFORM_DESKTOP)                                                                   
minimizeWindow                  ⇐                         "MinimizeWindow"                  _R⟨⟩                                              #                                                                   # Set window state: minimized, if resizable (only PLATFORM_DESKTOP)                                                                   
restoreWindow                   ⇐                         "RestoreWindow"                   _R⟨⟩                                              #                                                                   # Set window state: not minimized/maximized (only PLATFORM_DESKTOP)                                                                   
setWindowIcon                   ⇐                         "SetWindowIcon"                   _R⟨image⟩                                         # image                                                             # Set icon for window (single image, RGBA 32bit, only PLATFORM_DESKTOP)                                                               
setWindowIcons                  ⇐                         "SetWindowIcons"                  _R⟨'*'∾image⋄i⟩                                   # images count                                                      # Set icon for window (multiple images, RGBA 32bit, only PLATFORM_DESKTOP)                                                            
setWindowTitle                  ⇐                         "SetWindowTitle"                  _R⟨'*'∾u8⟩                                        # title                                                             # Set title for window (only PLATFORM_DESKTOP and PLATFORM_WEB)                                                                       
setWindowPosition               ⇐                         "SetWindowPosition"               _R⟨i⋄i⟩                                           # x y                                                               # Set window position on screen (only PLATFORM_DESKTOP)                                                                               
setWindowMonitor                ⇐                         "SetWindowMonitor"                _R⟨i⟩                                             # monitor                                                           # Set monitor for the current window                                                                                                  
setWindowMinSize                ⇐                         "SetWindowMinSize"                _R⟨i⋄i⟩                                           # width height                                                      # Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)                                                                           
setWindowMaxSize                ⇐                         "SetWindowMaxSize"                _R⟨i⋄i⟩                                           # width height                                                      # Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)                                                                           
setWindowSize                   ⇐                         "SetWindowSize"                   _R⟨i⋄i⟩                                           # width height                                                      # Set window dimensions                                                                                                               
setWindowOpacity                ⇐                         "SetWindowOpacity"                _R⟨f⟩                                             # opacity                                                           # Set window opacity [0.0f..1.0f] (only PLATFORM_DESKTOP)                                                                             
setWindowFocused                ⇐                         "SetWindowFocused"                _R⟨⟩                                              #                                                                   # Set window focused (only PLATFORM_DESKTOP)                                                                                          
getWindowHandle                 ⇐ ptr                     "GetWindowHandle"                 _R⟨⟩                                              #                                                                   # Get native window handle                                                                                                            
getScreenWidth                  ⇐ i                       "GetScreenWidth"                  _R⟨⟩                                              #                                                                   # Get current screen width                                                                                                            
getScreenHeight                 ⇐ i                       "GetScreenHeight"                 _R⟨⟩                                              #                                                                   # Get current screen height                                                                                                           
getRenderWidth                  ⇐ i                       "GetRenderWidth"                  _R⟨⟩                                              #                                                                   # Get current render width (it considers HiDPI)                                                                                       
getRenderHeight                 ⇐ i                       "GetRenderHeight"                 _R⟨⟩                                              #                                                                   # Get current render height (it considers HiDPI)                                                                                      
getMonitorCount                 ⇐ i                       "GetMonitorCount"                 _R⟨⟩                                              #                                                                   # Get number of connected monitors                                                                                                    
getCurrentMonitor               ⇐ i                       "GetCurrentMonitor"               _R⟨⟩                                              #                                                                   # Get current connected monitor                                                                                                       
getMonitorPosition              ⇐ v2                      "GetMonitorPosition"              _R⟨i⟩                                             # monitor                                                           # Get specified monitor position                                                                                                      
getMonitorWidth                 ⇐ i                       "GetMonitorWidth"                 _R⟨i⟩                                             # monitor                                                           # Get specified monitor width (current video mode used by monitor)                                                                    
getMonitorHeight                ⇐ i                       "GetMonitorHeight"                _R⟨i⟩                                             # monitor                                                           # Get specified monitor height (current video mode used by monitor)                                                                   
getMonitorPhysicalWidth         ⇐ i                       "GetMonitorPhysicalWidth"         _R⟨i⟩                                             # monitor                                                           # Get specified monitor physical width in millimetres                                                                                 
getMonitorPhysicalHeight        ⇐ i                       "GetMonitorPhysicalHeight"        _R⟨i⟩                                             # monitor                                                           # Get specified monitor physical height in millimetres                                                                                
getMonitorRefreshRate           ⇐ i                       "GetMonitorRefreshRate"           _R⟨i⟩                                             # monitor                                                           # Get specified monitor refresh rate                                                                                                  
getWindowPosition               ⇐ v2                      "GetWindowPosition"               _R⟨⟩                                              #                                                                   # Get window position XY on monitor                                                                                                   
getWindowScaleDPI               ⇐ v2                      "GetWindowScaleDPI"               _R⟨⟩                                              #                                                                   # Get window scale DPI factor                                                                                                         
getMonitorName                  ⇐ (ptr⊣str)               "GetMonitorName"                  _R⟨i⟩                                             # monitor                                                           # Get the human-readable, UTF-8 encoded name of the specified monitor                                                                 
setClipboardText                ⇐                         "SetClipboardText"                _R⟨'*'∾u8⟩                                        # text                                                              # Set clipboard text content                                                                                                          
getClipboardText                ⇐ (ptr⊣str)               "GetClipboardText"                _R⟨⟩                                              #                                                                   # Get clipboard text content                                                                                                          
enableEventWaiting              ⇐                         "EnableEventWaiting"              _R⟨⟩                                              #                                                                   # Enable waiting for events on EndDrawing(), no automatic event polling                                                               
disableEventWaiting             ⇐                         "DisableEventWaiting"             _R⟨⟩                                              #                                                                   # Disable waiting for events on EndDrawing(), automatic events polling                                                                
showCursor                      ⇐                         "ShowCursor"                      _R⟨⟩                                              #                                                                   # Shows cursor                                                                                                                        
hideCursor                      ⇐                         "HideCursor"                      _R⟨⟩                                              #                                                                   # Hides cursor                                                                                                                        
isCursorHidden                  ⇐ bool                    "IsCursorHidden"                  _R⟨⟩                                              #                                                                   # Check if cursor is not visible                                                                                                      
enableCursor                    ⇐                         "EnableCursor"                    _R⟨⟩                                              #                                                                   # Enables cursor (unlock cursor)                                                                                                      
disableCursor                   ⇐                         "DisableCursor"                   _R⟨⟩                                              #                                                                   # Disables cursor (lock cursor)                                                                                                       
isCursorOnScreen                ⇐ bool                    "IsCursorOnScreen"                _R⟨⟩                                              #                                                                   # Check if cursor is on the screen                                                                                                    
clearBackground                 ⇐                         "ClearBackground"                 _R⟨color⟩                                         # color                                                             # Set background color (framebuffer clear color)                                                                                      
beginDrawing                    ⇐                         "BeginDrawing"                    _R⟨⟩                                              #                                                                   # Setup canvas (framebuffer) to start drawing                                                                                         
endDrawing                      ⇐                         "EndDrawing"                      _R⟨⟩                                              #                                                                   # End canvas drawing and swap buffers (double buffering)                                                                              
beginMode2D                     ⇐                         "BeginMode2D"                     _R⟨camera2D⟩                                      # camera                                                            # Begin 2D mode with custom camera (2D)                                                                                               
endMode2D                       ⇐                         "EndMode2D"                       _R⟨⟩                                              #                                                                   # Ends 2D mode with custom camera                                                                                                     
beginMode3D                     ⇐                         "BeginMode3D"                     _R⟨camera3D⟩                                      # camera                                                            # Begin 3D mode with custom camera (3D)                                                                                               
endMode3D                       ⇐                         "EndMode3D"                       _R⟨⟩                                              #                                                                   # Ends 3D mode and returns to default 2D orthographic mode                                                                            
beginTextureMode                ⇐                         "BeginTextureMode"                _R⟨renderTexture⟩                                 # target                                                            # Begin drawing to render texture                                                                                                     
endTextureMode                  ⇐                         "EndTextureMode"                  _R⟨⟩                                              #                                                                   # Ends drawing to render texture                                                                                                      
beginShaderMode                 ⇐                         "BeginShaderMode"                 _R⟨shader⟩                                        # shader                                                            # Begin custom shader drawing                                                                                                         
endShaderMode                   ⇐                         "EndShaderMode"                   _R⟨⟩                                              #                                                                   # End custom shader drawing (use default shader)                                                                                      
beginBlendMode                  ⇐                         "BeginBlendMode"                  _R⟨i⟩                                             # mode                                                              # Begin blending mode (alpha, additive, multiplied, subtract, custom)                                                                 
endBlendMode                    ⇐                         "EndBlendMode"                    _R⟨⟩                                              #                                                                   # End blending mode (reset to default: alpha blending)                                                                                
beginScissorMode                ⇐                         "BeginScissorMode"                _R⟨i⋄i⋄i⋄i⟩                                       # x y width height                                                  # Begin scissor mode (define screen area for following drawing)                                                                       
endScissorMode                  ⇐                         "EndScissorMode"                  _R⟨⟩                                              #                                                                   # End scissor mode                                                                                                                    
beginVrStereoMode               ⇐                         "BeginVrStereoMode"               _R⟨vrStereoConfig⟩                                # config                                                            # Begin stereo rendering (requires VR simulator)                                                                                      
endVrStereoMode                 ⇐                         "EndVrStereoMode"                 _R⟨⟩                                              #                                                                   # End stereo rendering (requires VR simulator)                                                                                        
loadVrStereoConfig              ⇐ vrStereoConfig          "LoadVrStereoConfig"              _R⟨vrDeviceInfo⟩                                  # device                                                            # Load VR stereo config for VR simulator device parameters                                                                            
unloadVrStereoConfig            ⇐                         "UnloadVrStereoConfig"            _R⟨vrStereoConfig⟩                                # config                                                            # Unload VR stereo config                                                                                                             
loadShader                      ⇐ shader                  "LoadShader"                      _R⟨'*'∾u8⋄'*'∾u8⟩                                 # vsFileName fsFileName                                             # Load shader from files and bind default locations                                                                                   
loadShaderFromMemory            ⇐ shader                  "LoadShaderFromMemory"            _R⟨'*'∾u8⋄'*'∾u8⟩                                 # vsCode fsCode                                                     # Load shader from code strings and bind default locations                                                                            
isShaderReady                   ⇐ bool                    "IsShaderReady"                   _R⟨shader⟩                                        # shader                                                            # Check if a shader is ready                                                                                                          
getShaderLocation               ⇐ i                       "GetShaderLocation"               _R⟨shader⋄'*'∾u8⟩                                 # shader uniformName                                                # Get shader uniform location                                                                                                         
getShaderLocationAttrib         ⇐ i                       "GetShaderLocationAttrib"         _R⟨shader⋄'*'∾u8⟩                                 # shader attribName                                                 # Get shader attribute location                                                                                                       
setShaderValue                  ⇐                         "SetShaderValue"                  _R⟨shader⋄i⋄ptr⋄i⟩                                # shader locIndex value uniformType                                 # Set shader uniform value                                                                                                            
setShaderValueV                 ⇐                         "SetShaderValueV"                 _R⟨shader⋄i⋄ptr⋄i⋄i⟩                              # shader locIndex value uniformType count                           # Set shader uniform value vector                                                                                                     
setShaderValueMatrix            ⇐                         "SetShaderValueMatrix"            _R⟨shader⋄i⋄matrix⟩                               # shader locIndex mat                                               # Set shader uniform value (matrix 4x4)                                                                                               
setShaderValueTexture           ⇐                         "SetShaderValueTexture"           _R⟨shader⋄i⋄texture⟩                              # shader locIndex texture                                           # Set shader uniform value for texture (sampler2d)                                                                                    
unloadShader                    ⇐                         "UnloadShader"                    _R⟨shader⟩                                        # shader                                                            # Unload shader from GPU memory (VRAM)                                                                                                
getMouseRay                     ⇐ ray                     "GetMouseRay"                     _R⟨v2⋄camera3D⟩                                   # mousePosition camera                                              # Get a ray trace from mouse position                                                                                                 
getCameraMatrix                 ⇐ matrix                  "GetCameraMatrix"                 _R⟨camera3D⟩                                      # camera                                                            # Get camera transform matrix (view matrix)                                                                                           
getCameraMatrix2D               ⇐ matrix                  "GetCameraMatrix2D"               _R⟨camera2D⟩                                      # camera                                                            # Get camera 2d transform matrix                                                                                                      
getWorldToScreen                ⇐ v2                      "GetWorldToScreen"                _R⟨v3⋄camera3D⟩                                   # position camera                                                   # Get the screen space position for a 3d world space position                                                                         
getScreenToWorld2D              ⇐ v2                      "GetScreenToWorld2D"              _R⟨v2⋄camera2D⟩                                   # position camera                                                   # Get the world space position for a 2d camera screen space position                                                                  
getWorldToScreenEx              ⇐ v2                      "GetWorldToScreenEx"              _R⟨v3⋄camera3D⋄i⋄i⟩                               # position camera width height                                      # Get size position for a 3d world space position                                                                                     
getWorldToScreen2D              ⇐ v2                      "GetWorldToScreen2D"              _R⟨v2⋄camera2D⟩                                   # position camera                                                   # Get the screen space position for a 2d camera world space position                                                                  
setTargetFPS                    ⇐                         "SetTargetFPS"                    _R⟨i⟩                                             # fps                                                               # Set target FPS (maximum)                                                                                                            
getFrameTime                    ⇐ f                       "GetFrameTime"                    _R⟨⟩                                              #                                                                   # Get time in seconds for last frame drawn (delta time)                                                                               
getTime                         ⇐ "f64"                   "GetTime"                         _R⟨⟩                                              #                                                                   # Get elapsed time in seconds since InitWindow()                                                                                      
getFPS                          ⇐ i                       "GetFPS"                          _R⟨⟩                                              #                                                                   # Get current FPS                                                                                                                     
swapScreenBuffer                ⇐                         "SwapScreenBuffer"                _R⟨⟩                                              #                                                                   # Swap back buffer with front buffer (screen drawing)                                                                                 
pollInputEvents                 ⇐                         "PollInputEvents"                 _R⟨⟩                                              #                                                                   # Register all input events                                                                                                           
waitTime                        ⇐                         "WaitTime"                        _R⟨"f64"⟩                                         # seconds                                                           # Wait for some time (halt program execution)                                                                                         
getRandomValue                  ⇐ i                       "GetRandomValue"                  _R⟨i⋄i⟩                                           # min max                                                           # Get a random value between min and max (both included)                                                                              
setRandomSeed                   ⇐                         "SetRandomSeed"                   _R⟨u⟩                                             # seed                                                              # Set the seed for the random number generator                                                                                        
takeScreenshot                  ⇐                         "TakeScreenshot"                  _R⟨'*'∾u8⟩                                        # fileName                                                          # Takes a screenshot of current screen (filename extension defines format)                                                            
setConfigFlags                  ⇐                         "SetConfigFlags"                  _R⟨u⟩                                             # flags                                                             # Setup init configuration flags (view FLAGS)                                                                                         
openURL                         ⇐                         "OpenURL"                         _R⟨'*'∾u8⟩                                        # url                                                               # Open URL with default system browser (if available)                                                                                 
traceLog                        ⇐                         "TraceLog"                        _R⟨i⋄'*'∾u8⋄ptr⟩                                  # logLevel text args                                                # Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)                                                            
setTraceLogLevel                ⇐                         "SetTraceLogLevel"                _R⟨i⟩                                             # logLevel                                                          # Set the current threshold (minimum) log level                                                                                       
memAlloc                        ⇐ ptr                     "MemAlloc"                        _R⟨u⟩                                             # size                                                              # Internal memory allocator                                                                                                           
memRealloc                      ⇐ ptr                     "MemRealloc"                      _R⟨ptr⋄u⟩                                         # ptr size                                                          # Internal memory reallocator                                                                                                         
memFree                         ⇐                         "MemFree"                         _R⟨ptr⟩                                           # ptr                                                               # Internal memory free                                                                                                                
setTraceLogCallback             ⇐                         "SetTraceLogCallback"             _R⟨ptr⟩                                           # callback                                                          # Set custom trace log                                                                                                                
setLoadFileDataCallback         ⇐                         "SetLoadFileDataCallback"         _R⟨ptr⟩                                           # callback                                                          # Set custom file binary data loader                                                                                                  
setSaveFileDataCallback         ⇐                         "SetSaveFileDataCallback"         _R⟨ptr⟩                                           # callback                                                          # Set custom file binary data saver                                                                                                   
setLoadFileTextCallback         ⇐                         "SetLoadFileTextCallback"         _R⟨ptr⟩                                           # callback                                                          # Set custom file text data loader                                                                                                    
setSaveFileTextCallback         ⇐                         "SetSaveFileTextCallback"         _R⟨ptr⟩                                           # callback                                                          # Set custom file text data saver                                                                                                     
loadFileData                    ⇐ ('*'∾u8)                "LoadFileData"                    _R⟨'*'∾u8⋄'*'∾i⟩                                  # fileName dataSize                                                 # Load file data as byte array (read)                                                                                                 
unloadFileData                  ⇐                         "UnloadFileData"                  _R⟨'*'∾u8⟩                                        # data                                                              # Unload file data allocated by LoadFileData()                                                                                        
saveFileData                    ⇐ bool                    "SaveFileData"                    _R⟨'*'∾u8⋄ptr⋄i⟩                                  # fileName data dataSize                                            # Save data to file from byte array (write), returns true on success                                                                  
exportDataAsCode                ⇐ bool                    "ExportDataAsCode"                _R⟨'*'∾u8⋄i⋄'*'∾u8⟩                               # data dataSize fileName                                            # Export data to code (.h), returns true on success                                                                                   
loadFileText                    ⇐ ptr                     "LoadFileText"                    _R⟨'*'∾u8⟩                                        # fileName                                                          # Load text data from file (read), returns a '\0' terminated string                                                                   
unloadFileText                  ⇐                         "UnloadFileText"                  _R⟨'*'∾u8⟩                                        # text                                                              # Unload file text data allocated by LoadFileText()                                                                                   
saveFileText                    ⇐ bool                    "SaveFileText"                    _R⟨'*'∾u8⋄'*'∾u8⟩                                 # fileName text                                                     # Save text data to file (write), string must be '\0' terminated, returns true on success                                             
fileExists                      ⇐ bool                    "FileExists"                      _R⟨'*'∾u8⟩                                        # fileName                                                          # Check if file exists                                                                                                                
directoryExists                 ⇐ bool                    "DirectoryExists"                 _R⟨'*'∾u8⟩                                        # dirPath                                                           # Check if a directory path exists                                                                                                    
isFileExtension                 ⇐ bool                    "IsFileExtension"                 _R⟨'*'∾u8⋄'*'∾u8⟩                                 # fileName ext                                                      # Check file extension (including point: .png, .wav)                                                                                  
getFileLength                   ⇐ i                       "GetFileLength"                   _R⟨'*'∾u8⟩                                        # fileName                                                          # Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)                                                             
getFileExtension                ⇐ (ptr⊣str)               "GetFileExtension"                _R⟨'*'∾u8⟩                                        # fileName                                                          # Get pointer to extension for a filename string (includes dot: '.png')                                                               
getFileName                     ⇐ (ptr⊣str)               "GetFileName"                     _R⟨'*'∾u8⟩                                        # filePath                                                          # Get pointer to filename for a path string                                                                                           
getFileNameWithoutExt           ⇐ (ptr⊣str)               "GetFileNameWithoutExt"           _R⟨'*'∾u8⟩                                        # filePath                                                          # Get filename string without extension (uses static string)                                                                          
getDirectoryPath                ⇐ (ptr⊣str)               "GetDirectoryPath"                _R⟨'*'∾u8⟩                                        # filePath                                                          # Get full path for a given fileName with path (uses static string)                                                                   
getPrevDirectoryPath            ⇐ (ptr⊣str)               "GetPrevDirectoryPath"            _R⟨'*'∾u8⟩                                        # dirPath                                                           # Get previous directory path for a given path (uses static string)                                                                   
getWorkingDirectory             ⇐ (ptr⊣str)               "GetWorkingDirectory"             _R⟨⟩                                              #                                                                   # Get current working directory (uses static string)                                                                                  
getApplicationDirectory         ⇐ (ptr⊣str)               "GetApplicationDirectory"         _R⟨⟩                                              #                                                                   # Get the directory of the running application (uses static string)                                                                   
changeDirectory                 ⇐ bool                    "ChangeDirectory"                 _R⟨'*'∾u8⟩                                        # dir                                                               # Change working directory, return true on success                                                                                    
isPathFile                      ⇐ bool                    "IsPathFile"                      _R⟨'*'∾u8⟩                                        # path                                                              # Check if a given path is a file or a directory                                                                                      
loadDirectoryFiles              ⇐ filePathList            "LoadDirectoryFiles"              _R⟨'*'∾u8⟩                                        # dirPath                                                           # Load directory filepaths                                                                                                            
loadDirectoryFilesEx            ⇐ filePathList            "LoadDirectoryFilesEx"            _R⟨'*'∾u8⋄'*'∾u8⋄bool⟩                            # basePath filter scanSubdirs                                       # Load directory filepaths with extension filtering and recursive directory scan                                                      
unloadDirectoryFiles            ⇐                         "UnloadDirectoryFiles"            _R⟨filePathList⟩                                  # files                                                             # Unload filepaths                                                                                                                    
isFileDropped                   ⇐ bool                    "IsFileDropped"                   _R⟨⟩                                              #                                                                   # Check if a file has been dropped into window                                                                                        
loadDroppedFiles                ⇐ filePathList            "LoadDroppedFiles"                _R⟨⟩                                              #                                                                   # Load dropped filepaths                                                                                                              
unloadDroppedFiles              ⇐                         "UnloadDroppedFiles"              _R⟨filePathList⟩                                  # files                                                             # Unload dropped filepaths                                                                                                            
getFileModTime                  ⇐ "i64"                   "GetFileModTime"                  _R⟨'*'∾u8⟩                                        # fileName                                                          # Get file modification time (last write time)                                                                                        
compressData                    ⇐ ('*'∾u8)                "CompressData"                    _R⟨'*'∾u8⋄i⋄'*'∾i⟩                                # data dataSize compDataSize                                        # Compress data (DEFLATE algorithm), memory must be MemFree()                                                                         
decompressData                  ⇐ ('*'∾u8)                "DecompressData"                  _R⟨'*'∾u8⋄i⋄'*'∾i⟩                                # compData compDataSize dataSize                                    # Decompress data (DEFLATE algorithm), memory must be MemFree()                                                                       
encodeDataBase64                ⇐ ptr                     "EncodeDataBase64"                _R⟨'*'∾u8⋄i⋄'*'∾i⟩                                # data dataSize outputSize                                          # Encode data to Base64 string, memory must be MemFree()                                                                              
decodeDataBase64                ⇐ ('*'∾u8)                "DecodeDataBase64"                _R⟨'*'∾u8⋄'*'∾i⟩                                  # data outputSize                                                   # Decode Base64 string data, memory must be MemFree()                                                                                 
isKeyPressed                    ⇐ bool                    "IsKeyPressed"                    _R⟨i⟩                                             # key                                                               # Check if a key has been pressed once                                                                                                
isKeyPressedRepeat              ⇐ bool                    "IsKeyPressedRepeat"              _R⟨i⟩                                             # key                                                               # Check if a key has been pressed again (Only PLATFORM_DESKTOP)                                                                       
isKeyDown                       ⇐ bool                    "IsKeyDown"                       _R⟨i⟩                                             # key                                                               # Check if a key is being pressed                                                                                                     
isKeyReleased                   ⇐ bool                    "IsKeyReleased"                   _R⟨i⟩                                             # key                                                               # Check if a key has been released once                                                                                               
isKeyUp                         ⇐ bool                    "IsKeyUp"                         _R⟨i⟩                                             # key                                                               # Check if a key is NOT being pressed                                                                                                 
getKeyPressed                   ⇐ i                       "GetKeyPressed"                   _R⟨⟩                                              #                                                                   # Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty                                
getCharPressed                  ⇐ i                       "GetCharPressed"                  _R⟨⟩                                              #                                                                   # Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty                              
setExitKey                      ⇐                         "SetExitKey"                      _R⟨i⟩                                             # key                                                               # Set a custom key to exit program (default is ESC)                                                                                   
isGamepadAvailable              ⇐ bool                    "IsGamepadAvailable"              _R⟨i⟩                                             # gamepad                                                           # Check if a gamepad is available                                                                                                     
getGamepadName                  ⇐ (ptr⊣str)               "GetGamepadName"                  _R⟨i⟩                                             # gamepad                                                           # Get gamepad internal name id                                                                                                        
isGamepadButtonPressed          ⇐ bool                    "IsGamepadButtonPressed"          _R⟨i⋄i⟩                                           # gamepad button                                                    # Check if a gamepad button has been pressed once                                                                                     
isGamepadButtonDown             ⇐ bool                    "IsGamepadButtonDown"             _R⟨i⋄i⟩                                           # gamepad button                                                    # Check if a gamepad button is being pressed                                                                                          
isGamepadButtonReleased         ⇐ bool                    "IsGamepadButtonReleased"         _R⟨i⋄i⟩                                           # gamepad button                                                    # Check if a gamepad button has been released once                                                                                    
isGamepadButtonUp               ⇐ bool                    "IsGamepadButtonUp"               _R⟨i⋄i⟩                                           # gamepad button                                                    # Check if a gamepad button is NOT being pressed                                                                                      
getGamepadButtonPressed         ⇐ i                       "GetGamepadButtonPressed"         _R⟨⟩                                              #                                                                   # Get the last gamepad button pressed                                                                                                 
getGamepadAxisCount             ⇐ i                       "GetGamepadAxisCount"             _R⟨i⟩                                             # gamepad                                                           # Get gamepad axis count for a gamepad                                                                                                
getGamepadAxisMovement          ⇐ f                       "GetGamepadAxisMovement"          _R⟨i⋄i⟩                                           # gamepad axis                                                      # Get axis movement value for a gamepad axis                                                                                          
setGamepadMappings              ⇐ i                       "SetGamepadMappings"              _R⟨'*'∾u8⟩                                        # mappings                                                          # Set internal gamepad mappings (SDL_GameControllerDB)                                                                                
isMouseButtonPressed            ⇐ bool                    "IsMouseButtonPressed"            _R⟨i⟩                                             # button                                                            # Check if a mouse button has been pressed once                                                                                       
isMouseButtonDown               ⇐ bool                    "IsMouseButtonDown"               _R⟨i⟩                                             # button                                                            # Check if a mouse button is being pressed                                                                                            
isMouseButtonReleased           ⇐ bool                    "IsMouseButtonReleased"           _R⟨i⟩                                             # button                                                            # Check if a mouse button has been released once                                                                                      
isMouseButtonUp                 ⇐ bool                    "IsMouseButtonUp"                 _R⟨i⟩                                             # button                                                            # Check if a mouse button is NOT being pressed                                                                                        
getMouseX                       ⇐ i                       "GetMouseX"                       _R⟨⟩                                              #                                                                   # Get mouse position X                                                                                                                
getMouseY                       ⇐ i                       "GetMouseY"                       _R⟨⟩                                              #                                                                   # Get mouse position Y                                                                                                                
getMousePosition                ⇐ v2                      "GetMousePosition"                _R⟨⟩                                              #                                                                   # Get mouse position XY                                                                                                               
getMouseDelta                   ⇐ v2                      "GetMouseDelta"                   _R⟨⟩                                              #                                                                   # Get mouse delta between frames                                                                                                      
setMousePosition                ⇐                         "SetMousePosition"                _R⟨i⋄i⟩                                           # x y                                                               # Set mouse position XY                                                                                                               
setMouseOffset                  ⇐                         "SetMouseOffset"                  _R⟨i⋄i⟩                                           # offsetX offsetY                                                   # Set mouse offset                                                                                                                    
setMouseScale                   ⇐                         "SetMouseScale"                   _R⟨f⋄f⟩                                           # scaleX scaleY                                                     # Set mouse scaling                                                                                                                   
getMouseWheelMove               ⇐ f                       "GetMouseWheelMove"               _R⟨⟩                                              #                                                                   # Get mouse wheel movement for X or Y, whichever is larger                                                                            
getMouseWheelMoveV              ⇐ v2                      "GetMouseWheelMoveV"              _R⟨⟩                                              #                                                                   # Get mouse wheel movement for both X and Y                                                                                           
setMouseCursor                  ⇐                         "SetMouseCursor"                  _R⟨i⟩                                             # cursor                                                            # Set mouse cursor                                                                                                                    
getTouchX                       ⇐ i                       "GetTouchX"                       _R⟨⟩                                              #                                                                   # Get touch position X for touch point 0 (relative to screen size)                                                                    
getTouchY                       ⇐ i                       "GetTouchY"                       _R⟨⟩                                              #                                                                   # Get touch position Y for touch point 0 (relative to screen size)                                                                    
getTouchPosition                ⇐ v2                      "GetTouchPosition"                _R⟨i⟩                                             # index                                                             # Get touch position XY for a touch point index (relative to screen size)                                                             
getTouchPointId                 ⇐ i                       "GetTouchPointId"                 _R⟨i⟩                                             # index                                                             # Get touch point identifier for given index                                                                                          
getTouchPointCount              ⇐ i                       "GetTouchPointCount"              _R⟨⟩                                              #                                                                   # Get number of touch points                                                                                                          
setGesturesEnabled              ⇐                         "SetGesturesEnabled"              _R⟨u⟩                                             # flags                                                             # Enable a set of gestures using flags                                                                                                
isGestureDetected               ⇐ bool                    "IsGestureDetected"               _R⟨u⟩                                             # gesture                                                           # Check if a gesture have been detected                                                                                               
getGestureDetected              ⇐ i                       "GetGestureDetected"              _R⟨⟩                                              #                                                                   # Get latest detected gesture                                                                                                         
getGestureHoldDuration          ⇐ f                       "GetGestureHoldDuration"          _R⟨⟩                                              #                                                                   # Get gesture hold time in milliseconds                                                                                               
getGestureDragVector            ⇐ v2                      "GetGestureDragVector"            _R⟨⟩                                              #                                                                   # Get gesture drag vector                                                                                                             
getGestureDragAngle             ⇐ f                       "GetGestureDragAngle"             _R⟨⟩                                              #                                                                   # Get gesture drag angle                                                                                                              
getGesturePinchVector           ⇐ v2                      "GetGesturePinchVector"           _R⟨⟩                                              #                                                                   # Get gesture pinch delta                                                                                                             
getGesturePinchAngle            ⇐ f                       "GetGesturePinchAngle"            _R⟨⟩                                              #                                                                   # Get gesture pinch angle                                                                                                             
updateCamera                    ⇐                         "UpdateCamera"                    _R⟨'*'∾camera3D⋄i⟩                                # camera mode                                                       # Update camera position for selected mode                                                                                            
updateCameraPro                 ⇐                         "UpdateCameraPro"                 _R⟨'*'∾camera3D⋄v3⋄v3⋄f⟩                          # camera movement rotation zoom                                     # Update camera movement/rotation                                                                                                     
setShapesTexture                ⇐                         "SetShapesTexture"                _R⟨texture⋄rectangle⟩                             # texture source                                                    # Set texture and rectangle to be used on shapes drawing                                                                              
drawPixel                       ⇐                         "DrawPixel"                       _R⟨i⋄i⋄color⟩                                     # posX posY color                                                   # Draw a pixel                                                                                                                        
drawPixelV                      ⇐                         "DrawPixelV"                      _R⟨v2⋄color⟩                                      # position color                                                    # Draw a pixel (Vector version)                                                                                                       
drawLine                        ⇐                         "DrawLine"                        _R⟨i⋄i⋄i⋄i⋄color⟩                                 # startPosX startPosY endPosX endPosY color                         # Draw a line                                                                                                                         
drawLineV                       ⇐                         "DrawLineV"                       _R⟨v2⋄v2⋄color⟩                                   # startPos endPos color                                             # Draw a line (Vector version)                                                                                                        
drawLineEx                      ⇐                         "DrawLineEx"                      _R⟨v2⋄v2⋄f⋄color⟩                                 # startPos endPos thick color                                       # Draw a line defining thickness                                                                                                      
drawLineBezier                  ⇐                         "DrawLineBezier"                  _R⟨v2⋄v2⋄f⋄color⟩                                 # startPos endPos thick color                                       # Draw a line using cubic-bezier curves in-out                                                                                        
drawLineBezierQuad              ⇐                         "DrawLineBezierQuad"              _R⟨v2⋄v2⋄v2⋄f⋄color⟩                              # startPos endPos controlPos thick color                            # Draw line using quadratic bezier curves with a control point                                                                        
drawLineBezierCubic             ⇐                         "DrawLineBezierCubic"             _R⟨v2⋄v2⋄v2⋄v2⋄f⋄color⟩                           # startPos endPos startControlPos endControlPos thick color         # Draw line using cubic bezier curves with 2 control points                                                                           
drawLineBSpline                 ⇐                         "DrawLineBSpline"                 _R⟨'*'∾v2⋄i⋄f⋄color⟩                              # points pointCount thick color                                     # Draw a B-Spline line, minimum 4 points                                                                                              
drawLineCatmullRom              ⇐                         "DrawLineCatmullRom"              _R⟨'*'∾v2⋄i⋄f⋄color⟩                              # points pointCount thick color                                     # Draw a Catmull Rom spline line, minimum 4 points                                                                                    
drawLineStrip                   ⇐                         "DrawLineStrip"                   _R⟨'*'∾v2⋄i⋄color⟩                                # points pointCount color                                           # Draw lines sequence                                                                                                                 
drawCircle                      ⇐                         "DrawCircle"                      _R⟨i⋄i⋄f⋄color⟩                                   # centerX centerY radius color                                      # Draw a color-filled circle                                                                                                          
drawCircleSector                ⇐                         "DrawCircleSector"                _R⟨v2⋄f⋄f⋄f⋄i⋄color⟩                              # center radius startAngle endAngle segments color                  # Draw a piece of a circle                                                                                                            
drawCircleSectorLines           ⇐                         "DrawCircleSectorLines"           _R⟨v2⋄f⋄f⋄f⋄i⋄color⟩                              # center radius startAngle endAngle segments color                  # Draw circle sector outline                                                                                                          
drawCircleGradient              ⇐                         "DrawCircleGradient"              _R⟨i⋄i⋄f⋄color⋄color⟩                             # centerX centerY radius color1 color2                              # Draw a gradient-filled circle                                                                                                       
drawCircleV                     ⇐                         "DrawCircleV"                     _R⟨v2⋄f⋄color⟩                                    # center radius color                                               # Draw a color-filled circle (Vector version)                                                                                         
drawCircleLines                 ⇐                         "DrawCircleLines"                 _R⟨i⋄i⋄f⋄color⟩                                   # centerX centerY radius color                                      # Draw circle outline                                                                                                                 
drawEllipse                     ⇐                         "DrawEllipse"                     _R⟨i⋄i⋄f⋄f⋄color⟩                                 # centerX centerY radiusH radiusV color                             # Draw ellipse                                                                                                                        
drawEllipseLines                ⇐                         "DrawEllipseLines"                _R⟨i⋄i⋄f⋄f⋄color⟩                                 # centerX centerY radiusH radiusV color                             # Draw ellipse outline                                                                                                                
drawRing                        ⇐                         "DrawRing"                        _R⟨v2⋄f⋄f⋄f⋄f⋄i⋄color⟩                            # center innerRadius outerRadius startAngle endAngle segments color # Draw ring                                                                                                                           
drawRingLines                   ⇐                         "DrawRingLines"                   _R⟨v2⋄f⋄f⋄f⋄f⋄i⋄color⟩                            # center innerRadius outerRadius startAngle endAngle segments color # Draw ring outline                                                                                                                   
drawRectangle                   ⇐                         "DrawRectangle"                   _R⟨i⋄i⋄i⋄i⋄color⟩                                 # posX posY width height color                                      # Draw a color-filled rectangle                                                                                                       
drawRectangleV                  ⇐                         "DrawRectangleV"                  _R⟨v2⋄v2⋄color⟩                                   # position size color                                               # Draw a color-filled rectangle (Vector version)                                                                                      
drawRectangleRec                ⇐                         "DrawRectangleRec"                _R⟨rectangle⋄color⟩                               # rec color                                                         # Draw a color-filled rectangle                                                                                                       
drawRectanglePro                ⇐                         "DrawRectanglePro"                _R⟨rectangle⋄v2⋄f⋄color⟩                          # rec origin rotation color                                         # Draw a color-filled rectangle with pro parameters                                                                                   
drawRectangleGradientV          ⇐                         "DrawRectangleGradientV"          _R⟨i⋄i⋄i⋄i⋄color⋄color⟩                           # posX posY width height color1 color2                              # Draw a vertical-gradient-filled rectangle                                                                                           
drawRectangleGradientH          ⇐                         "DrawRectangleGradientH"          _R⟨i⋄i⋄i⋄i⋄color⋄color⟩                           # posX posY width height color1 color2                              # Draw a horizontal-gradient-filled rectangle                                                                                         
drawRectangleGradientEx         ⇐                         "DrawRectangleGradientEx"         _R⟨rectangle⋄color⋄color⋄color⋄color⟩             # rec col1 col2 col3 col4                                           # Draw a gradient-filled rectangle with custom vertex colors                                                                          
drawRectangleLines              ⇐                         "DrawRectangleLines"              _R⟨i⋄i⋄i⋄i⋄color⟩                                 # posX posY width height color                                      # Draw rectangle outline                                                                                                              
drawRectangleLinesEx            ⇐                         "DrawRectangleLinesEx"            _R⟨rectangle⋄f⋄color⟩                             # rec lineThick color                                               # Draw rectangle outline with extended parameters                                                                                     
drawRectangleRounded            ⇐                         "DrawRectangleRounded"            _R⟨rectangle⋄f⋄i⋄color⟩                           # rec roundness segments color                                      # Draw rectangle with rounded edges                                                                                                   
drawRectangleRoundedLines       ⇐                         "DrawRectangleRoundedLines"       _R⟨rectangle⋄f⋄i⋄f⋄color⟩                         # rec roundness segments lineThick color                            # Draw rectangle with rounded edges outline                                                                                           
drawTriangle                    ⇐                         "DrawTriangle"                    _R⟨v2⋄v2⋄v2⋄color⟩                                # v1 v2 v3 color                                                    # Draw a color-filled triangle (vertex in counter-clockwise order!)                                                                   
drawTriangleLines               ⇐                         "DrawTriangleLines"               _R⟨v2⋄v2⋄v2⋄color⟩                                # v1 v2 v3 color                                                    # Draw triangle outline (vertex in counter-clockwise order!)                                                                          
drawTriangleFan                 ⇐                         "DrawTriangleFan"                 _R⟨'*'∾v2⋄i⋄color⟩                                # points pointCount color                                           # Draw a triangle fan defined by points (first vertex is the center)                                                                  
drawTriangleStrip               ⇐                         "DrawTriangleStrip"               _R⟨'*'∾v2⋄i⋄color⟩                                # points pointCount color                                           # Draw a triangle strip defined by points                                                                                             
drawPoly                        ⇐                         "DrawPoly"                        _R⟨v2⋄i⋄f⋄f⋄color⟩                                # center sides radius rotation color                                # Draw a regular polygon (Vector version)                                                                                             
drawPolyLines                   ⇐                         "DrawPolyLines"                   _R⟨v2⋄i⋄f⋄f⋄color⟩                                # center sides radius rotation color                                # Draw a polygon outline of n sides                                                                                                   
drawPolyLinesEx                 ⇐                         "DrawPolyLinesEx"                 _R⟨v2⋄i⋄f⋄f⋄f⋄color⟩                              # center sides radius rotation lineThick color                      # Draw a polygon outline of n sides with extended parameters                                                                          
checkCollisionRecs              ⇐ bool                    "CheckCollisionRecs"              _R⟨rectangle⋄rectangle⟩                           # rec1 rec2                                                         # Check collision between two rectangles                                                                                              
checkCollisionCircles           ⇐ bool                    "CheckCollisionCircles"           _R⟨v2⋄f⋄v2⋄f⟩                                     # center1 radius1 center2 radius2                                   # Check collision between two circles                                                                                                 
checkCollisionCircleRec         ⇐ bool                    "CheckCollisionCircleRec"         _R⟨v2⋄f⋄rectangle⟩                                # center radius rec                                                 # Check collision between circle and rectangle                                                                                        
checkCollisionPointRec          ⇐ bool                    "CheckCollisionPointRec"          _R⟨v2⋄rectangle⟩                                  # point rec                                                         # Check if point is inside rectangle                                                                                                  
checkCollisionPointCircle       ⇐ bool                    "CheckCollisionPointCircle"       _R⟨v2⋄v2⋄f⟩                                       # point center radius                                               # Check if point is inside circle                                                                                                     
checkCollisionPointTriangle     ⇐ bool                    "CheckCollisionPointTriangle"     _R⟨v2⋄v2⋄v2⋄v2⟩                                   # point p1 p2 p3                                                    # Check if point is inside a triangle                                                                                                 
checkCollisionPointPoly         ⇐ bool                    "CheckCollisionPointPoly"         _R⟨v2⋄'*'∾v2⋄i⟩                                   # point points pointCount                                           # Check if point is within a polygon described by array of vertices                                                                   
checkCollisionLines             ⇐ bool                    "CheckCollisionLines"             _R⟨v2⋄v2⋄v2⋄v2⋄'*'∾v2⟩                            # startPos1 endPos1 startPos2 endPos2 collisionPoint                # Check the collision between two lines defined by two points each, returns collision point by reference                              
checkCollisionPointLine         ⇐ bool                    "CheckCollisionPointLine"         _R⟨v2⋄v2⋄v2⋄i⟩                                    # point p1 p2 threshold                                             # Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]                   
getCollisionRec                 ⇐ rectangle               "GetCollisionRec"                 _R⟨rectangle⋄rectangle⟩                           # rec1 rec2                                                         # Get collision rectangle for two rectangles collision                                                                                
loadImage                       ⇐ image                   "LoadImage"                       _R⟨'*'∾u8⟩                                        # fileName                                                          # Load image from file into CPU memory (RAM)                                                                                          
loadImageRaw                    ⇐ image                   "LoadImageRaw"                    _R⟨'*'∾u8⋄i⋄i⋄i⋄i⟩                                # fileName width height format headerSize                           # Load image from RAW file data                                                                                                       
loadImageSvg                    ⇐ image                   "LoadImageSvg"                    _R⟨'*'∾u8⋄i⋄i⟩                                    # fileNameOrString width height                                     # Load image from SVG file data or string with specified size                                                                         
loadImageAnim                   ⇐ image                   "LoadImageAnim"                   _R⟨'*'∾u8⋄'*'∾i⟩                                  # fileName frames                                                   # Load image sequence from file (frames appended to image.data)                                                                       
loadImageFromMemory             ⇐ image                   "LoadImageFromMemory"             _R⟨'*'∾u8⋄'*'∾u8⋄i⟩                               # fileType fileData dataSize                                        # Load image from memory buffer, fileType refers to extension: i.e. '.png'                                                            
loadImageFromTexture            ⇐ image                   "LoadImageFromTexture"            _R⟨texture⟩                                       # texture                                                           # Load image from GPU texture data                                                                                                    
loadImageFromScreen             ⇐ image                   "LoadImageFromScreen"             _R⟨⟩                                              #                                                                   # Load image from screen buffer and (screenshot)                                                                                      
isImageReady                    ⇐ bool                    "IsImageReady"                    _R⟨image⟩                                         # image                                                             # Check if an image is ready                                                                                                          
unloadImage                     ⇐                         "UnloadImage"                     _R⟨image⟩                                         # image                                                             # Unload image from CPU memory (RAM)                                                                                                  
exportImage                     ⇐ bool                    "ExportImage"                     _R⟨image⋄'*'∾u8⟩                                  # image fileName                                                    # Export image data to file, returns true on success                                                                                  
exportImageToMemory             ⇐ ('*'∾u8)                "ExportImageToMemory"             _R⟨image⋄'*'∾u8⋄'*'∾i⟩                            # image fileType fileSize                                           # Export image to memory buffer                                                                                                       
exportImageAsCode               ⇐ bool                    "ExportImageAsCode"               _R⟨image⋄'*'∾u8⟩                                  # image fileName                                                    # Export image as code file defining an array of bytes, returns true on success                                                       
genImageColor                   ⇐ image                   "GenImageColor"                   _R⟨i⋄i⋄color⟩                                     # width height color                                                # Generate image: plain color                                                                                                         
genImageGradientLinear          ⇐ image                   "GenImageGradientLinear"          _R⟨i⋄i⋄i⋄color⋄color⟩                             # width height direction start end                                  # Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient                                                 
genImageGradientRadial          ⇐ image                   "GenImageGradientRadial"          _R⟨i⋄i⋄f⋄color⋄color⟩                             # width height density inner outer                                  # Generate image: radial gradient                                                                                                     
genImageGradientSquare          ⇐ image                   "GenImageGradientSquare"          _R⟨i⋄i⋄f⋄color⋄color⟩                             # width height density inner outer                                  # Generate image: square gradient                                                                                                     
genImageChecked                 ⇐ image                   "GenImageChecked"                 _R⟨i⋄i⋄i⋄i⋄color⋄color⟩                           # width height checksX checksY col1 col2                            # Generate image: checked                                                                                                             
genImageWhiteNoise              ⇐ image                   "GenImageWhiteNoise"              _R⟨i⋄i⋄f⟩                                         # width height factor                                               # Generate image: white noise                                                                                                         
genImagePerlinNoise             ⇐ image                   "GenImagePerlinNoise"             _R⟨i⋄i⋄i⋄i⋄f⟩                                     # width height offsetX offsetY scale                                # Generate image: perlin noise                                                                                                        
genImageCellular                ⇐ image                   "GenImageCellular"                _R⟨i⋄i⋄i⟩                                         # width height tileSize                                             # Generate image: cellular algorithm, bigger tileSize means bigger cells                                                              
genImageText                    ⇐ image                   "GenImageText"                    _R⟨i⋄i⋄'*'∾u8⟩                                    # width height text                                                 # Generate image: grayscale image from text data                                                                                      
imageCopy                       ⇐ image                   "ImageCopy"                       _R⟨image⟩                                         # image                                                             # Create an image duplicate (useful for transformations)                                                                              
imageFromImage                  ⇐ image                   "ImageFromImage"                  _R⟨image⋄rectangle⟩                               # image rec                                                         # Create an image from another image piece                                                                                            
imageText                       ⇐ image                   "ImageText"                       _R⟨'*'∾u8⋄i⋄color⟩                                # text fontSize color                                               # Create an image from text (default font)                                                                                            
imageTextEx                     ⇐ image                   "ImageTextEx"                     _R⟨font⋄'*'∾u8⋄f⋄f⋄color⟩                         # font text fontSize spacing tint                                   # Create an image from text (custom sprite font)                                                                                      
imageFormat                     ⇐                         "ImageFormat"                     _R⟨'*'∾image⋄i⟩                                   # image newFormat                                                   # Convert image data to desired format                                                                                                
imageToPOT                      ⇐                         "ImageToPOT"                      _R⟨'*'∾image⋄color⟩                               # image fill                                                        # Convert image to POT (power-of-two)                                                                                                 
imageCrop                       ⇐                         "ImageCrop"                       _R⟨'*'∾image⋄rectangle⟩                           # image crop                                                        # Crop an image to a defined rectangle                                                                                                
imageAlphaCrop                  ⇐                         "ImageAlphaCrop"                  _R⟨'*'∾image⋄f⟩                                   # image threshold                                                   # Crop image depending on alpha value                                                                                                 
imageAlphaClear                 ⇐                         "ImageAlphaClear"                 _R⟨'*'∾image⋄color⋄f⟩                             # image color threshold                                             # Clear alpha channel to desired color                                                                                                
imageAlphaMask                  ⇐                         "ImageAlphaMask"                  _R⟨'*'∾image⋄image⟩                               # image alphaMask                                                   # Apply alpha mask to image                                                                                                           
imageAlphaPremultiply           ⇐                         "ImageAlphaPremultiply"           _R⟨'*'∾image⟩                                     # image                                                             # Premultiply alpha channel                                                                                                           
imageBlurGaussian               ⇐                         "ImageBlurGaussian"               _R⟨'*'∾image⋄i⟩                                   # image blurSize                                                    # Apply Gaussian blur using a box blur approximation                                                                                  
imageResize                     ⇐                         "ImageResize"                     _R⟨'*'∾image⋄i⋄i⟩                                 # image newWidth newHeight                                          # Resize image (Bicubic scaling algorithm)                                                                                            
imageResizeNN                   ⇐                         "ImageResizeNN"                   _R⟨'*'∾image⋄i⋄i⟩                                 # image newWidth newHeight                                          # Resize image (Nearest-Neighbor scaling algorithm)                                                                                   
imageResizeCanvas               ⇐                         "ImageResizeCanvas"               _R⟨'*'∾image⋄i⋄i⋄i⋄i⋄color⟩                       # image newWidth newHeight offsetX offsetY fill                     # Resize canvas and fill with color                                                                                                   
imageMipmaps                    ⇐                         "ImageMipmaps"                    _R⟨'*'∾image⟩                                     # image                                                             # Compute all mipmap levels for a provided image                                                                                      
imageDither                     ⇐                         "ImageDither"                     _R⟨'*'∾image⋄i⋄i⋄i⋄i⟩                             # image rBpp gBpp bBpp aBpp                                         # Dither image data to 16bpp or lower (Floyd-Steinberg dithering)                                                                     
imageFlipVertical               ⇐                         "ImageFlipVertical"               _R⟨'*'∾image⟩                                     # image                                                             # Flip image vertically                                                                                                               
imageFlipHorizontal             ⇐                         "ImageFlipHorizontal"             _R⟨'*'∾image⟩                                     # image                                                             # Flip image horizontally                                                                                                             
imageRotate                     ⇐                         "ImageRotate"                     _R⟨'*'∾image⋄i⟩                                   # image degrees                                                     # Rotate image by input angle in degrees (-359 to 359)                                                                                
imageRotateCW                   ⇐                         "ImageRotateCW"                   _R⟨'*'∾image⟩                                     # image                                                             # Rotate image clockwise 90deg                                                                                                        
imageRotateCCW                  ⇐                         "ImageRotateCCW"                  _R⟨'*'∾image⟩                                     # image                                                             # Rotate image counter-clockwise 90deg                                                                                                
imageColorTint                  ⇐                         "ImageColorTint"                  _R⟨'*'∾image⋄color⟩                               # image color                                                       # Modify image color: tint                                                                                                            
imageColorInvert                ⇐                         "ImageColorInvert"                _R⟨'*'∾image⟩                                     # image                                                             # Modify image color: invert                                                                                                          
imageColorGrayscale             ⇐                         "ImageColorGrayscale"             _R⟨'*'∾image⟩                                     # image                                                             # Modify image color: grayscale                                                                                                       
imageColorContrast              ⇐                         "ImageColorContrast"              _R⟨'*'∾image⋄f⟩                                   # image contrast                                                    # Modify image color: contrast (-100 to 100)                                                                                          
imageColorBrightness            ⇐                         "ImageColorBrightness"            _R⟨'*'∾image⋄i⟩                                   # image brightness                                                  # Modify image color: brightness (-255 to 255)                                                                                        
imageColorReplace               ⇐                         "ImageColorReplace"               _R⟨'*'∾image⋄color⋄color⟩                         # image color replace                                               # Modify image color: replace color                                                                                                   
loadImageColors                 ⇐ (ptr⊣'*'∾color)         "LoadImageColors"                 _R⟨image⟩                                         # image                                                             # Load color data from image as a Color array (RGBA - 32bit)                                                                          
loadImagePalette                ⇐ (ptr⊣'*'∾color)         "LoadImagePalette"                _R⟨image⋄i⋄'*'∾i⟩                                 # image maxPaletteSize colorCount                                   # Load colors palette from image as a Color array (RGBA - 32bit)                                                                      
unloadImageColors               ⇐                         "UnloadImageColors"               _R⟨'*'∾color⟩                                     # colors                                                            # Unload color data loaded with LoadImageColors()                                                                                     
unloadImagePalette              ⇐                         "UnloadImagePalette"              _R⟨'*'∾color⟩                                     # colors                                                            # Unload colors palette loaded with LoadImagePalette()                                                                                
getImageAlphaBorder             ⇐ rectangle               "GetImageAlphaBorder"             _R⟨image⋄f⟩                                       # image threshold                                                   # Get image alpha border rectangle                                                                                                    
getImageColor                   ⇐ color                   "GetImageColor"                   _R⟨image⋄i⋄i⟩                                     # image x y                                                         # Get image pixel color at (x, y) position                                                                                            
imageClearBackground            ⇐                         "ImageClearBackground"            _R⟨'*'∾image⋄color⟩                               # dst color                                                         # Clear image background with given color                                                                                             
imageDrawPixel                  ⇐                         "ImageDrawPixel"                  _R⟨'*'∾image⋄i⋄i⋄color⟩                           # dst posX posY color                                               # Draw pixel within an image                                                                                                          
imageDrawPixelV                 ⇐                         "ImageDrawPixelV"                 _R⟨'*'∾image⋄v2⋄color⟩                            # dst position color                                                # Draw pixel within an image (Vector version)                                                                                         
imageDrawLine                   ⇐                         "ImageDrawLine"                   _R⟨'*'∾image⋄i⋄i⋄i⋄i⋄color⟩                       # dst startPosX startPosY endPosX endPosY color                     # Draw line within an image                                                                                                           
imageDrawLineV                  ⇐                         "ImageDrawLineV"                  _R⟨'*'∾image⋄v2⋄v2⋄color⟩                         # dst start end color                                               # Draw line within an image (Vector version)                                                                                          
imageDrawCircle                 ⇐                         "ImageDrawCircle"                 _R⟨'*'∾image⋄i⋄i⋄i⋄color⟩                         # dst centerX centerY radius color                                  # Draw a filled circle within an image                                                                                                
imageDrawCircleV                ⇐                         "ImageDrawCircleV"                _R⟨'*'∾image⋄v2⋄i⋄color⟩                          # dst center radius color                                           # Draw a filled circle within an image (Vector version)                                                                               
imageDrawCircleLines            ⇐                         "ImageDrawCircleLines"            _R⟨'*'∾image⋄i⋄i⋄i⋄color⟩                         # dst centerX centerY radius color                                  # Draw circle outline within an image                                                                                                 
imageDrawCircleLinesV           ⇐                         "ImageDrawCircleLinesV"           _R⟨'*'∾image⋄v2⋄i⋄color⟩                          # dst center radius color                                           # Draw circle outline within an image (Vector version)                                                                                
imageDrawRectangle              ⇐                         "ImageDrawRectangle"              _R⟨'*'∾image⋄i⋄i⋄i⋄i⋄color⟩                       # dst posX posY width height color                                  # Draw rectangle within an image                                                                                                      
imageDrawRectangleV             ⇐                         "ImageDrawRectangleV"             _R⟨'*'∾image⋄v2⋄v2⋄color⟩                         # dst position size color                                           # Draw rectangle within an image (Vector version)                                                                                     
imageDrawRectangleRec           ⇐                         "ImageDrawRectangleRec"           _R⟨'*'∾image⋄rectangle⋄color⟩                     # dst rec color                                                     # Draw rectangle within an image                                                                                                      
imageDrawRectangleLines         ⇐                         "ImageDrawRectangleLines"         _R⟨'*'∾image⋄rectangle⋄i⋄color⟩                   # dst rec thick color                                               # Draw rectangle lines within an image                                                                                                
imageDraw                       ⇐                         "ImageDraw"                       _R⟨'*'∾image⋄image⋄rectangle⋄rectangle⋄color⟩     # dst src srcRec dstRec tint                                        # Draw a source image within a destination image (tint applied to source)                                                             
imageDrawText                   ⇐                         "ImageDrawText"                   _R⟨'*'∾image⋄'*'∾u8⋄i⋄i⋄i⋄color⟩                  # dst text posX posY fontSize color                                 # Draw text (using default font) within an image (destination)                                                                        
imageDrawTextEx                 ⇐                         "ImageDrawTextEx"                 _R⟨'*'∾image⋄font⋄'*'∾u8⋄v2⋄f⋄f⋄color⟩            # dst font text position fontSize spacing tint                      # Draw text (custom sprite font) within an image (destination)                                                                        
loadTexture                     ⇐ texture                 "LoadTexture"                     _R⟨'*'∾u8⟩                                        # fileName                                                          # Load texture from file into GPU memory (VRAM)                                                                                       
loadTextureFromImage            ⇐ texture                 "LoadTextureFromImage"            _R⟨image⟩                                         # image                                                             # Load texture from image data                                                                                                        
loadTextureCubemap              ⇐ texture                 "LoadTextureCubemap"              _R⟨image⋄i⟩                                       # image layout                                                      # Load cubemap from image, multiple image cubemap layouts supported                                                                   
loadRenderTexture               ⇐ renderTexture           "LoadRenderTexture"               _R⟨i⋄i⟩                                           # width height                                                      # Load texture for rendering (framebuffer)                                                                                            
isTextureReady                  ⇐ bool                    "IsTextureReady"                  _R⟨texture⟩                                       # texture                                                           # Check if a texture is ready                                                                                                         
unloadTexture                   ⇐                         "UnloadTexture"                   _R⟨texture⟩                                       # texture                                                           # Unload texture from GPU memory (VRAM)                                                                                               
isRenderTextureReady            ⇐ bool                    "IsRenderTextureReady"            _R⟨renderTexture⟩                                 # target                                                            # Check if a render texture is ready                                                                                                  
unloadRenderTexture             ⇐                         "UnloadRenderTexture"             _R⟨renderTexture⟩                                 # target                                                            # Unload render texture from GPU memory (VRAM)                                                                                        
updateTexture                   ⇐                         "UpdateTexture"                   _R⟨texture⋄ptr⟩                                   # texture pixels                                                    # Update GPU texture with new data                                                                                                    
updateTextureRec                ⇐                         "UpdateTextureRec"                _R⟨texture⋄rectangle⋄ptr⟩                         # texture rec pixels                                                # Update GPU texture rectangle with new data                                                                                          
genTextureMipmaps               ⇐                         "GenTextureMipmaps"               _R⟨'*'∾texture⟩                                   # texture                                                           # Generate GPU mipmaps for a texture                                                                                                  
setTextureFilter                ⇐                         "SetTextureFilter"                _R⟨texture⋄i⟩                                     # texture filter                                                    # Set texture scaling filter mode                                                                                                     
setTextureWrap                  ⇐                         "SetTextureWrap"                  _R⟨texture⋄i⟩                                     # texture wrap                                                      # Set texture wrapping mode                                                                                                           
drawTexture                     ⇐                         "DrawTexture"                     _R⟨texture⋄i⋄i⋄color⟩                             # texture posX posY tint                                            # Draw a Texture2D                                                                                                                    
drawTextureV                    ⇐                         "DrawTextureV"                    _R⟨texture⋄v2⋄color⟩                              # texture position tint                                             # Draw a Texture2D with position defined as Vector2                                                                                   
drawTextureEx                   ⇐                         "DrawTextureEx"                   _R⟨texture⋄v2⋄f⋄f⋄color⟩                          # texture position rotation scale tint                              # Draw a Texture2D with extended parameters                                                                                           
drawTextureRec                  ⇐                         "DrawTextureRec"                  _R⟨texture⋄rectangle⋄v2⋄color⟩                    # texture source position tint                                      # Draw a part of a texture defined by a rectangle                                                                                     
drawTexturePro                  ⇐                         "DrawTexturePro"                  _R⟨texture⋄rectangle⋄rectangle⋄v2⋄f⋄color⟩        # texture source dest origin rotation tint                          # Draw a part of a texture defined by a rectangle with 'pro' parameters                                                               
drawTextureNPatch               ⇐                         "DrawTextureNPatch"               _R⟨texture⋄nPatchInfo⋄rectangle⋄v2⋄f⋄color⟩       # texture nPatchInfo dest origin rotation tint                      # Draws a texture (or part of it) that stretches or shrinks nicely                                                                    
fade                            ⇐ color                   "Fade"                            _R⟨color⋄f⟩                                       # color alpha                                                       # Get color with alpha applied, alpha goes from 0.0f to 1.0f                                                                          
colorToInt                      ⇐ i                       "ColorToInt"                      _R⟨color⟩                                         # color                                                             # Get hexadecimal value for a Color                                                                                                   
colorNormalize                  ⇐ v4                      "ColorNormalize"                  _R⟨color⟩                                         # color                                                             # Get Color normalized as float [0..1]                                                                                                
colorFromNormalized             ⇐ color                   "ColorFromNormalized"             _R⟨v4⟩                                            # normalized                                                        # Get Color from normalized values [0..1]                                                                                             
colorToHSV                      ⇐ v3                      "ColorToHSV"                      _R⟨color⟩                                         # color                                                             # Get HSV values for a Color, hue [0..360], saturation/value [0..1]                                                                   
colorFromHSV                    ⇐ color                   "ColorFromHSV"                    _R⟨f⋄f⋄f⟩                                         # hue saturation value                                              # Get a Color from HSV values, hue [0..360], saturation/value [0..1]                                                                  
colorTint                       ⇐ color                   "ColorTint"                       _R⟨color⋄color⟩                                   # color tint                                                        # Get color multiplied with another color                                                                                             
colorBrightness                 ⇐ color                   "ColorBrightness"                 _R⟨color⋄f⟩                                       # color factor                                                      # Get color with brightness correction, brightness factor goes from -1.0f to 1.0f                                                     
colorContrast                   ⇐ color                   "ColorContrast"                   _R⟨color⋄f⟩                                       # color contrast                                                    # Get color with contrast correction, contrast values between -1.0f and 1.0f                                                          
colorAlpha                      ⇐ color                   "ColorAlpha"                      _R⟨color⋄f⟩                                       # color alpha                                                       # Get color with alpha applied, alpha goes from 0.0f to 1.0f                                                                          
colorAlphaBlend                 ⇐ color                   "ColorAlphaBlend"                 _R⟨color⋄color⋄color⟩                             # dst src tint                                                      # Get src alpha-blended into dst color with tint                                                                                      
getColor                        ⇐ color                   "GetColor"                        _R⟨u⟩                                             # hexValue                                                          # Get Color structure from hexadecimal value                                                                                          
getPixelColor                   ⇐ color                   "GetPixelColor"                   _R⟨ptr⋄i⟩                                         # srcPtr format                                                     # Get Color from a source pixel pointer of certain format                                                                             
setPixelColor                   ⇐                         "SetPixelColor"                   _R⟨ptr⋄color⋄i⟩                                   # dstPtr color format                                               # Set color formatted into destination pixel pointer                                                                                  
getPixelDataSize                ⇐ i                       "GetPixelDataSize"                _R⟨i⋄i⋄i⟩                                         # width height format                                               # Get pixel data size in bytes for certain format                                                                                     
getFontDefault                  ⇐ font                    "GetFontDefault"                  _R⟨⟩                                              #                                                                   # Get the default Font                                                                                                                
loadFont                        ⇐ font                    "LoadFont"                        _R⟨'*'∾u8⟩                                        # fileName                                                          # Load font from file into GPU memory (VRAM)                                                                                          
loadFontEx                      ⇐ font                    "LoadFontEx"                      _R⟨'*'∾u8⋄i⋄'*'∾i⋄i⟩                              # fileName fontSize codepoints codepointCount                       # Load font from file with extended parameters, use NULL for codepoints and 0 for codepointCount to load the default character setFont
loadFontFromImage               ⇐ font                    "LoadFontFromImage"               _R⟨image⋄color⋄i⟩                                 # image key firstChar                                               # Load font from Image (XNA style)                                                                                                    
loadFontFromMemory              ⇐ font                    "LoadFontFromMemory"              _R⟨'*'∾u8⋄'*'∾u8⋄i⋄i⋄'*'∾i⋄i⟩                     # fileType fileData dataSize fontSize codepoints codepointCount     # Load font from memory buffer, fileType refers to extension: i.e. '.ttf'                                                             
isFontReady                     ⇐ bool                    "IsFontReady"                     _R⟨font⟩                                          # font                                                              # Check if a font is ready                                                                                                            
loadFontData                    ⇐ ptr                     "LoadFontData"                    _R⟨'*'∾u8⋄i⋄i⋄'*'∾i⋄i⋄i⟩                          # fileData dataSize fontSize codepoints codepointCount type         # Load font data for further use                                                                                                      
genImageFontAtlas               ⇐ image                   "GenImageFontAtlas"               _R⟨'*'∾glyphInfo⋄"**"∾rectangle⋄i⋄i⋄i⋄i⟩          # glyphs glyphRecs glyphCount fontSize padding packMethod           # Generate image font atlas using chars info                                                                                          
unloadFontData                  ⇐                         "UnloadFontData"                  _R⟨'*'∾glyphInfo⋄i⟩                               # glyphs glyphCount                                                 # Unload font chars info data (RAM)                                                                                                   
unloadFont                      ⇐                         "UnloadFont"                      _R⟨font⟩                                          # font                                                              # Unload font from GPU memory (VRAM)                                                                                                  
exportFontAsCode                ⇐ bool                    "ExportFontAsCode"                _R⟨font⋄'*'∾u8⟩                                   # font fileName                                                     # Export font as code file, returns true on success                                                                                   
drawFPS                         ⇐                         "DrawFPS"                         _R⟨i⋄i⟩                                           # posX posY                                                         # Draw current FPS                                                                                                                    
drawText                        ⇐                         "DrawText"                        _R⟨'*'∾u8⋄i⋄i⋄i⋄color⟩                            # text posX posY fontSize color                                     # Draw text (using default font)                                                                                                      
drawTextEx                      ⇐                         "DrawTextEx"                      _R⟨font⋄'*'∾u8⋄v2⋄f⋄f⋄color⟩                      # font text position fontSize spacing tint                          # Draw text using font and additional parameters                                                                                      
drawTextPro                     ⇐                         "DrawTextPro"                     _R⟨font⋄'*'∾u8⋄v2⋄v2⋄f⋄f⋄f⋄color⟩                 # font text position origin rotation fontSize spacing tint          # Draw text using Font and pro parameters (rotation)                                                                                  
drawTextCodepoint               ⇐                         "DrawTextCodepoint"               _R⟨font⋄i⋄v2⋄f⋄color⟩                             # font codepoint position fontSize tint                             # Draw one character (codepoint)                                                                                                      
drawTextCodepoints              ⇐                         "DrawTextCodepoints"              _R⟨font⋄'*'∾i⋄i⋄v2⋄f⋄f⋄color⟩                     # font codepoints codepointCount position fontSize spacing tint     # Draw multiple character (codepoint)                                                                                                 
setTextLineSpacing              ⇐                         "SetTextLineSpacing"              _R⟨i⟩                                             # spacing                                                           # Set vertical line spacing when drawing with line-breaks                                                                             
measureText                     ⇐ i                       "MeasureText"                     _R⟨'*'∾u8⋄i⟩                                      # text fontSize                                                     # Measure string width for default font                                                                                               
measureTextEx                   ⇐ v2                      "MeasureTextEx"                   _R⟨font⋄'*'∾u8⋄f⋄f⟩                               # font text fontSize spacing                                        # Measure string size for Font                                                                                                        
getGlyphIndex                   ⇐ i                       "GetGlyphIndex"                   _R⟨font⋄i⟩                                        # font codepoint                                                    # Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found                                  
getGlyphInfo                    ⇐ glyphInfo               "GetGlyphInfo"                    _R⟨font⋄i⟩                                        # font codepoint                                                    # Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found                                          
getGlyphAtlasRec                ⇐ rectangle               "GetGlyphAtlasRec"                _R⟨font⋄i⟩                                        # font codepoint                                                    # Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found                                 
loadUTF8                        ⇐ ptr                     "LoadUTF8"                        _R⟨'*'∾i⋄i⟩                                       # codepoints length                                                 # Load UTF-8 text encoded from codepoints array                                                                                       
unloadUTF8                      ⇐                         "UnloadUTF8"                      _R⟨'*'∾u8⟩                                        # text                                                              # Unload UTF-8 text encoded from codepoints array                                                                                     
loadCodepoints                  ⇐ (ptr⊣'*'∾i)             "LoadCodepoints"                  _R⟨'*'∾u8⋄'*'∾i⟩                                  # text count                                                        # Load all codepoints from a UTF-8 text string, codepoints count returned by parameter                                                
unloadCodepoints                ⇐                         "UnloadCodepoints"                _R⟨'*'∾i⟩                                         # codepoints                                                        # Unload codepoints data from memory                                                                                                  
getCodepointCount               ⇐ i                       "GetCodepointCount"               _R⟨'*'∾u8⟩                                        # text                                                              # Get total number of codepoints in a UTF-8 encoded string                                                                            
getCodepoint                    ⇐ i                       "GetCodepoint"                    _R⟨'*'∾u8⋄'*'∾i⟩                                  # text codepointSize                                                # Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure                                                      
getCodepointNext                ⇐ i                       "GetCodepointNext"                _R⟨'*'∾u8⋄'*'∾i⟩                                  # text codepointSize                                                # Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure                                                      
getCodepointPrevious            ⇐ i                       "GetCodepointPrevious"            _R⟨'*'∾u8⋄'*'∾i⟩                                  # text codepointSize                                                # Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure                                                  
codepointToUTF8                 ⇐ (ptr⊣str)               "CodepointToUTF8"                 _R⟨i⋄'*'∾i⟩                                       # codepoint utf8Size                                                # Encode one codepoint into UTF-8 byte array (array length returned as parameter)                                                     
textCopy                        ⇐ i                       "TextCopy"                        _R⟨'*'∾u8⋄'*'∾u8⟩                                 # dst src                                                           # Copy one string to another, returns bytes copied                                                                                    
textIsEqual                     ⇐ bool                    "TextIsEqual"                     _R⟨'*'∾u8⋄'*'∾u8⟩                                 # text1 text2                                                       # Check if two text string are equal                                                                                                  
textLength                      ⇐ u                       "TextLength"                      _R⟨'*'∾u8⟩                                        # text                                                              # Get text length, checks for '\0' ending                                                                                             
textFormat                      ⇐ (ptr⊣str)               "TextFormat"                      _R⟨'*'∾u8⋄ptr⟩                                    # text args                                                         # Text formatting with variables (sprintf() style)                                                                                    
textSubtext                     ⇐ (ptr⊣str)               "TextSubtext"                     _R⟨'*'∾u8⋄i⋄i⟩                                    # text position length                                              # Get a piece of a text string                                                                                                        
textReplace                     ⇐ ptr                     "TextReplace"                     _R⟨'*'∾u8⋄'*'∾u8⋄'*'∾u8⟩                          # text replace by                                                   # Replace text string (WARNING: memory must be freed!)                                                                                
textInsert                      ⇐ ptr                     "TextInsert"                      _R⟨'*'∾u8⋄'*'∾u8⋄i⟩                               # text insert position                                              # Insert text in a position (WARNING: memory must be freed!)                                                                          
textJoin                        ⇐ (ptr⊣str)               "TextJoin"                        _R⟨"**"∾u8⋄i⋄'*'∾u8⟩                              # textList count delimiter                                          # Join text strings with delimiter                                                                                                    
textSplit                       ⇐ (ptr⊣'*'∾str)           "TextSplit"                       _R⟨'*'∾u8⋄u8⋄'*'∾i⟩                               # text delimiter count                                              # Split text into multiple strings                                                                                                    
textAppend                      ⇐                         "TextAppend"                      _R⟨'*'∾u8⋄'*'∾u8⋄'*'∾i⟩                           # text append position                                              # Append text at specific position and move cursor!                                                                                   
textFindIndex                   ⇐ i                       "TextFindIndex"                   _R⟨'*'∾u8⋄'*'∾u8⟩                                 # text find                                                         # Find first text occurrence within a string                                                                                          
textToUpper                     ⇐ (ptr⊣str)               "TextToUpper"                     _R⟨'*'∾u8⟩                                        # text                                                              # Get upper case version of provided string                                                                                           
textToLower                     ⇐ (ptr⊣str)               "TextToLower"                     _R⟨'*'∾u8⟩                                        # text                                                              # Get lower case version of provided string                                                                                           
textToPascal                    ⇐ (ptr⊣str)               "TextToPascal"                    _R⟨'*'∾u8⟩                                        # text                                                              # Get Pascal case notation version of provided string                                                                                 
textToInteger                   ⇐ i                       "TextToInteger"                   _R⟨'*'∾u8⟩                                        # text                                                              # Get integer value from text (negative values not supported)                                                                         
drawLine3D                      ⇐                         "DrawLine3D"                      _R⟨v3⋄v3⋄color⟩                                   # startPos endPos color                                             # Draw a line in 3D world space                                                                                                       
drawPoint3D                     ⇐                         "DrawPoint3D"                     _R⟨v3⋄color⟩                                      # position color                                                    # Draw a point in 3D space, actually a small line                                                                                     
drawCircle3D                    ⇐                         "DrawCircle3D"                    _R⟨v3⋄f⋄v3⋄f⋄color⟩                               # center radius rotationAxis rotationAngle color                    # Draw a circle in 3D world space                                                                                                     
drawTriangle3D                  ⇐                         "DrawTriangle3D"                  _R⟨v3⋄v3⋄v3⋄color⟩                                # v1 v2 v3 color                                                    # Draw a color-filled triangle (vertex in counter-clockwise order!)                                                                   
drawTriangleStrip3D             ⇐                         "DrawTriangleStrip3D"             _R⟨'*'∾v3⋄i⋄color⟩                                # points pointCount color                                           # Draw a triangle strip defined by points                                                                                             
drawCube                        ⇐                         "DrawCube"                        _R⟨v3⋄f⋄f⋄f⋄color⟩                                # position width height length color                                # Draw cube                                                                                                                           
drawCubeV                       ⇐                         "DrawCubeV"                       _R⟨v3⋄v3⋄color⟩                                   # position size color                                               # Draw cube (Vector version)                                                                                                          
drawCubeWires                   ⇐                         "DrawCubeWires"                   _R⟨v3⋄f⋄f⋄f⋄color⟩                                # position width height length color                                # Draw cube wires                                                                                                                     
drawCubeWiresV                  ⇐                         "DrawCubeWiresV"                  _R⟨v3⋄v3⋄color⟩                                   # position size color                                               # Draw cube wires (Vector version)                                                                                                    
drawSphere                      ⇐                         "DrawSphere"                      _R⟨v3⋄f⋄color⟩                                    # centerPos radius color                                            # Draw sphere                                                                                                                         
drawSphereEx                    ⇐                         "DrawSphereEx"                    _R⟨v3⋄f⋄i⋄i⋄color⟩                                # centerPos radius rings slices color                               # Draw sphere with extended parameters                                                                                                
drawSphereWires                 ⇐                         "DrawSphereWires"                 _R⟨v3⋄f⋄i⋄i⋄color⟩                                # centerPos radius rings slices color                               # Draw sphere wires                                                                                                                   
drawCylinder                    ⇐                         "DrawCylinder"                    _R⟨v3⋄f⋄f⋄f⋄i⋄color⟩                              # position radiusTop radiusBottom height slices color               # Draw a cylinder/cone                                                                                                                
drawCylinderEx                  ⇐                         "DrawCylinderEx"                  _R⟨v3⋄v3⋄f⋄f⋄i⋄color⟩                             # startPos endPos startRadius endRadius sides color                 # Draw a cylinder with base at startPos and top at endPos                                                                             
drawCylinderWires               ⇐                         "DrawCylinderWires"               _R⟨v3⋄f⋄f⋄f⋄i⋄color⟩                              # position radiusTop radiusBottom height slices color               # Draw a cylinder/cone wires                                                                                                          
drawCylinderWiresEx             ⇐                         "DrawCylinderWiresEx"             _R⟨v3⋄v3⋄f⋄f⋄i⋄color⟩                             # startPos endPos startRadius endRadius sides color                 # Draw a cylinder wires with base at startPos and top at endPos                                                                       
drawCapsule                     ⇐                         "DrawCapsule"                     _R⟨v3⋄v3⋄f⋄i⋄i⋄color⟩                             # startPos endPos radius slices rings color                         # Draw a capsule with the center of its sphere caps at startPos and endPos                                                            
drawCapsuleWires                ⇐                         "DrawCapsuleWires"                _R⟨v3⋄v3⋄f⋄i⋄i⋄color⟩                             # startPos endPos radius slices rings color                         # Draw capsule wireframe with the center of its sphere caps at startPos and endPos                                                    
drawPlane                       ⇐                         "DrawPlane"                       _R⟨v3⋄v2⋄color⟩                                   # centerPos size color                                              # Draw a plane XZ                                                                                                                     
drawRay                         ⇐                         "DrawRay"                         _R⟨ray⋄color⟩                                     # ray color                                                         # Draw a ray line                                                                                                                     
drawGrid                        ⇐                         "DrawGrid"                        _R⟨i⋄f⟩                                           # slices spacing                                                    # Draw a grid (centered at (0, 0, 0))                                                                                                 
loadModel                       ⇐ model                   "LoadModel"                       _R⟨'*'∾u8⟩                                        # fileName                                                          # Load model from files (meshes and materials)                                                                                        
loadModelFromMesh               ⇐ model                   "LoadModelFromMesh"               _R⟨mesh⟩                                          # mesh                                                              # Load model from generated mesh (default material)                                                                                   
isModelReady                    ⇐ bool                    "IsModelReady"                    _R⟨model⟩                                         # model                                                             # Check if a model is ready                                                                                                           
unloadModel                     ⇐                         "UnloadModel"                     _R⟨model⟩                                         # model                                                             # Unload model (including meshes) from memory (RAM and/or VRAM)                                                                       
getModelBoundingBox             ⇐ boundingBox             "GetModelBoundingBox"             _R⟨model⟩                                         # model                                                             # Compute model bounding box limits (considers all meshes)                                                                            
drawModel                       ⇐                         "DrawModel"                       _R⟨model⋄v3⋄f⋄color⟩                              # model position scale tint                                         # Draw a model (with texture if set)                                                                                                  
drawModelEx                     ⇐                         "DrawModelEx"                     _R⟨model⋄v3⋄v3⋄f⋄v3⋄color⟩                        # model position rotationAxis rotationAngle scale tint              # Draw a model with extended parameters                                                                                               
drawModelWires                  ⇐                         "DrawModelWires"                  _R⟨model⋄v3⋄f⋄color⟩                              # model position scale tint                                         # Draw a model wires (with texture if set)                                                                                            
drawModelWiresEx                ⇐                         "DrawModelWiresEx"                _R⟨model⋄v3⋄v3⋄f⋄v3⋄color⟩                        # model position rotationAxis rotationAngle scale tint              # Draw a model wires (with texture if set) with extended parameters                                                                   
drawBoundingBox                 ⇐                         "DrawBoundingBox"                 _R⟨boundingBox⋄color⟩                             # box color                                                         # Draw bounding box (wires)                                                                                                           
drawBillboard                   ⇐                         "DrawBillboard"                   _R⟨camera3D⋄texture⋄v3⋄f⋄color⟩                   # camera texture position size tint                                 # Draw a billboard texture                                                                                                            
drawBillboardRec                ⇐                         "DrawBillboardRec"                _R⟨camera3D⋄texture⋄rectangle⋄v3⋄v2⋄color⟩        # camera texture source position size tint                          # Draw a billboard texture defined by source                                                                                          
drawBillboardPro                ⇐                         "DrawBillboardPro"                _R⟨camera3D⋄texture⋄rectangle⋄v3⋄v3⋄v2⋄v2⋄f⋄color⟩# camera texture source position up size origin rotation tint       # Draw a billboard texture defined by source and rotation                                                                             
uploadMesh                      ⇐                         "UploadMesh"                      _R⟨'*'∾mesh⋄bool⟩                                 # mesh dynamic                                                      # Upload mesh vertex data in GPU and provide VAO/VBO ids                                                                              
updateMeshBuffer                ⇐                         "UpdateMeshBuffer"                _R⟨mesh⋄i⋄ptr⋄i⋄i⟩                                # mesh index data dataSize offset                                   # Update mesh vertex data in GPU for a specific buffer index                                                                          
unloadMesh                      ⇐                         "UnloadMesh"                      _R⟨mesh⟩                                          # mesh                                                              # Unload mesh data from CPU and GPU                                                                                                   
drawMesh                        ⇐                         "DrawMesh"                        _R⟨mesh⋄material⋄matrix⟩                          # mesh material transform                                           # Draw a 3d mesh with material and transform                                                                                          
drawMeshInstanced               ⇐                         "DrawMeshInstanced"               _R⟨mesh⋄material⋄'*'∾matrix⋄i⟩                    # mesh material transforms instances                                # Draw multiple mesh instances with material and different transforms                                                                 
exportMesh                      ⇐ bool                    "ExportMesh"                      _R⟨mesh⋄'*'∾u8⟩                                   # mesh fileName                                                     # Export mesh data to file, returns true on success                                                                                   
getMeshBoundingBox              ⇐ boundingBox             "GetMeshBoundingBox"              _R⟨mesh⟩                                          # mesh                                                              # Compute mesh bounding box limits                                                                                                    
genMeshTangents                 ⇐                         "GenMeshTangents"                 _R⟨'*'∾mesh⟩                                      # mesh                                                              # Compute mesh tangents                                                                                                               
genMeshPoly                     ⇐ mesh                    "GenMeshPoly"                     _R⟨i⋄f⟩                                           # sides radius                                                      # Generate polygonal mesh                                                                                                             
genMeshPlane                    ⇐ mesh                    "GenMeshPlane"                    _R⟨f⋄f⋄i⋄i⟩                                       # width length resX resZ                                            # Generate plane mesh (with subdivisions)                                                                                             
genMeshCube                     ⇐ mesh                    "GenMeshCube"                     _R⟨f⋄f⋄f⟩                                         # width height length                                               # Generate cuboid mesh                                                                                                                
genMeshSphere                   ⇐ mesh                    "GenMeshSphere"                   _R⟨f⋄i⋄i⟩                                         # radius rings slices                                               # Generate sphere mesh (standard sphere)                                                                                              
genMeshHemiSphere               ⇐ mesh                    "GenMeshHemiSphere"               _R⟨f⋄i⋄i⟩                                         # radius rings slices                                               # Generate half-sphere mesh (no bottom cap)                                                                                           
genMeshCylinder                 ⇐ mesh                    "GenMeshCylinder"                 _R⟨f⋄f⋄i⟩                                         # radius height slices                                              # Generate cylinder mesh                                                                                                              
genMeshCone                     ⇐ mesh                    "GenMeshCone"                     _R⟨f⋄f⋄i⟩                                         # radius height slices                                              # Generate cone/pyramid mesh                                                                                                          
genMeshTorus                    ⇐ mesh                    "GenMeshTorus"                    _R⟨f⋄f⋄i⋄i⟩                                       # radius size radSeg sides                                          # Generate torus mesh                                                                                                                 
genMeshKnot                     ⇐ mesh                    "GenMeshKnot"                     _R⟨f⋄f⋄i⋄i⟩                                       # radius size radSeg sides                                          # Generate trefoil knot mesh                                                                                                          
genMeshHeightmap                ⇐ mesh                    "GenMeshHeightmap"                _R⟨image⋄v3⟩                                      # heightmap size                                                    # Generate heightmap mesh from image data                                                                                             
genMeshCubicmap                 ⇐ mesh                    "GenMeshCubicmap"                 _R⟨image⋄v3⟩                                      # cubicmap cubeSize                                                 # Generate cubes-based map mesh from image data                                                                                       
loadMaterials                   ⇐ (ptr⊣'*'∾material)      "LoadMaterials"                   _R⟨'*'∾u8⋄'*'∾i⟩                                  # fileName materialCount                                            # Load materials from model file                                                                                                      
loadMaterialDefault             ⇐ material                "LoadMaterialDefault"             _R⟨⟩                                              #                                                                   # Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)                                                                    
isMaterialReady                 ⇐ bool                    "IsMaterialReady"                 _R⟨material⟩                                      # material                                                          # Check if a material is ready                                                                                                        
unloadMaterial                  ⇐                         "UnloadMaterial"                  _R⟨material⟩                                      # material                                                          # Unload material from GPU memory (VRAM)                                                                                              
setMaterialTexture              ⇐                         "SetMaterialTexture"              _R⟨'*'∾material⋄i⋄texture⟩                        # material mapType texture                                          # Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)                                                
setModelMeshMaterial            ⇐                         "SetModelMeshMaterial"            _R⟨'*'∾model⋄i⋄i⟩                                 # model meshId materialId                                           # Set material for a mesh                                                                                                             
loadModelAnimations             ⇐ (ptr⊣'*'∾modelAnimation)"LoadModelAnimations"             _R⟨'*'∾u8⋄'*'∾i⟩                                  # fileName animCount                                                # Load model animations from file                                                                                                     
updateModelAnimation            ⇐                         "UpdateModelAnimation"            _R⟨model⋄modelAnimation⋄i⟩                        # model anim frame                                                  # Update model animation pose                                                                                                         
unloadModelAnimation            ⇐                         "UnloadModelAnimation"            _R⟨modelAnimation⟩                                # anim                                                              # Unload animation data                                                                                                               
unloadModelAnimations           ⇐                         "UnloadModelAnimations"           _R⟨'*'∾modelAnimation⋄i⟩                          # animations animCount                                              # Unload animation array data                                                                                                         
isModelAnimationValid           ⇐ bool                    "IsModelAnimationValid"           _R⟨model⋄modelAnimation⟩                          # model anim                                                        # Check model animation skeleton match                                                                                                
checkCollisionSpheres           ⇐ bool                    "CheckCollisionSpheres"           _R⟨v3⋄f⋄v3⋄f⟩                                     # center1 radius1 center2 radius2                                   # Check collision between two spheres                                                                                                 
checkCollisionBoxes             ⇐ bool                    "CheckCollisionBoxes"             _R⟨boundingBox⋄boundingBox⟩                       # box1 box2                                                         # Check collision between two bounding boxes                                                                                          
checkCollisionBoxSphere         ⇐ bool                    "CheckCollisionBoxSphere"         _R⟨boundingBox⋄v3⋄f⟩                              # box center radius                                                 # Check collision between box and sphere                                                                                              
getRayCollisionSphere           ⇐ rayCollision            "GetRayCollisionSphere"           _R⟨ray⋄v3⋄f⟩                                      # ray center radius                                                 # Get collision info between ray and sphere                                                                                           
getRayCollisionBox              ⇐ rayCollision            "GetRayCollisionBox"              _R⟨ray⋄boundingBox⟩                               # ray box                                                           # Get collision info between ray and box                                                                                              
getRayCollisionMesh             ⇐ rayCollision            "GetRayCollisionMesh"             _R⟨ray⋄mesh⋄matrix⟩                               # ray mesh transform                                                # Get collision info between ray and mesh                                                                                             
getRayCollisionTriangle         ⇐ rayCollision            "GetRayCollisionTriangle"         _R⟨ray⋄v3⋄v3⋄v3⟩                                  # ray p1 p2 p3                                                      # Get collision info between ray and triangle                                                                                         
getRayCollisionQuad             ⇐ rayCollision            "GetRayCollisionQuad"             _R⟨ray⋄v3⋄v3⋄v3⋄v3⟩                               # ray p1 p2 p3 p4                                                   # Get collision info between ray and quad                                                                                             
initAudioDevice                 ⇐                         "InitAudioDevice"                 _R⟨⟩                                              #                                                                   # Initialize audio device and context                                                                                                 
closeAudioDevice                ⇐                         "CloseAudioDevice"                _R⟨⟩                                              #                                                                   # Close the audio device and context                                                                                                  
isAudioDeviceReady              ⇐ bool                    "IsAudioDeviceReady"              _R⟨⟩                                              #                                                                   # Check if audio device has been initialized successfully                                                                             
setMasterVolume                 ⇐                         "SetMasterVolume"                 _R⟨f⟩                                             # volume                                                            # Set master volume (listener)                                                                                                        
getMasterVolume                 ⇐ f                       "GetMasterVolume"                 _R⟨⟩                                              #                                                                   # Get master volume (listener)                                                                                                        
loadWave                        ⇐ wave                    "LoadWave"                        _R⟨'*'∾u8⟩                                        # fileName                                                          # Load wave data from file                                                                                                            
loadWaveFromMemory              ⇐ wave                    "LoadWaveFromMemory"              _R⟨'*'∾u8⋄'*'∾u8⋄i⟩                               # fileType fileData dataSize                                        # Load wave from memory buffer, fileType refers to extension: i.e. '.wav'                                                             
isWaveReady                     ⇐ bool                    "IsWaveReady"                     _R⟨wave⟩                                          # wave                                                              # Checks if wave data is ready                                                                                                        
loadSound                       ⇐ sound                   "LoadSound"                       _R⟨'*'∾u8⟩                                        # fileName                                                          # Load sound from file                                                                                                                
loadSoundFromWave               ⇐ sound                   "LoadSoundFromWave"               _R⟨wave⟩                                          # wave                                                              # Load sound from wave data                                                                                                           
loadSoundAlias                  ⇐ sound                   "LoadSoundAlias"                  _R⟨sound⟩                                         # source                                                            # Create a new sound that shares the same sample data as the source sound, does not own the sound data                                
isSoundReady                    ⇐ bool                    "IsSoundReady"                    _R⟨sound⟩                                         # sound                                                             # Checks if a sound is ready                                                                                                          
updateSound                     ⇐                         "UpdateSound"                     _R⟨sound⋄ptr⋄i⟩                                   # sound data sampleCount                                            # Update sound buffer with new data                                                                                                   
unloadWave                      ⇐                         "UnloadWave"                      _R⟨wave⟩                                          # wave                                                              # Unload wave data                                                                                                                    
unloadSound                     ⇐                         "UnloadSound"                     _R⟨sound⟩                                         # sound                                                             # Unload sound                                                                                                                        
unloadSoundAlias                ⇐                         "UnloadSoundAlias"                _R⟨sound⟩                                         # alias                                                             # Unload a sound alias (does not deallocate sample data)                                                                              
exportWave                      ⇐ bool                    "ExportWave"                      _R⟨wave⋄'*'∾u8⟩                                   # wave fileName                                                     # Export wave data to file, returns true on success                                                                                   
exportWaveAsCode                ⇐ bool                    "ExportWaveAsCode"                _R⟨wave⋄'*'∾u8⟩                                   # wave fileName                                                     # Export wave sample data to code (.h), returns true on success                                                                       
playSound                       ⇐                         "PlaySound"                       _R⟨sound⟩                                         # sound                                                             # Play a sound                                                                                                                        
stopSound                       ⇐                         "StopSound"                       _R⟨sound⟩                                         # sound                                                             # Stop playing a sound                                                                                                                
pauseSound                      ⇐                         "PauseSound"                      _R⟨sound⟩                                         # sound                                                             # Pause a sound                                                                                                                       
resumeSound                     ⇐                         "ResumeSound"                     _R⟨sound⟩                                         # sound                                                             # Resume a paused sound                                                                                                               
isSoundPlaying                  ⇐ bool                    "IsSoundPlaying"                  _R⟨sound⟩                                         # sound                                                             # Check if a sound is currently playing                                                                                               
setSoundVolume                  ⇐                         "SetSoundVolume"                  _R⟨sound⋄f⟩                                       # sound volume                                                      # Set volume for a sound (1.0 is max level)                                                                                           
setSoundPitch                   ⇐                         "SetSoundPitch"                   _R⟨sound⋄f⟩                                       # sound pitch                                                       # Set pitch for a sound (1.0 is base level)                                                                                           
setSoundPan                     ⇐                         "SetSoundPan"                     _R⟨sound⋄f⟩                                       # sound pan                                                         # Set pan for a sound (0.5 is center)                                                                                                 
waveCopy                        ⇐ wave                    "WaveCopy"                        _R⟨wave⟩                                          # wave                                                              # Copy a wave to a new wave                                                                                                           
waveCrop                        ⇐                         "WaveCrop"                        _R⟨'*'∾wave⋄i⋄i⟩                                  # wave initSample finalSample                                       # Crop a wave to defined samples range                                                                                                
waveFormat                      ⇐                         "WaveFormat"                      _R⟨'*'∾wave⋄i⋄i⋄i⟩                                # wave sampleRate sampleSize channels                               # Convert wave data to desired format                                                                                                 
loadWaveSamples                 ⇐ (ptr⊣'*'∾f)             "LoadWaveSamples"                 _R⟨wave⟩                                          # wave                                                              # Load samples data from wave as a 32bit float data array                                                                             
unloadWaveSamples               ⇐                         "UnloadWaveSamples"               _R⟨'*'∾f⟩                                         # samples                                                           # Unload samples data loaded with LoadWaveSamples()                                                                                   
loadMusicStream                 ⇐ music                   "LoadMusicStream"                 _R⟨'*'∾u8⟩                                        # fileName                                                          # Load music stream from file                                                                                                         
loadMusicStreamFromMemory       ⇐ music                   "LoadMusicStreamFromMemory"       _R⟨'*'∾u8⋄'*'∾u8⋄i⟩                               # fileType data dataSize                                            # Load music stream from data                                                                                                         
isMusicReady                    ⇐ bool                    "IsMusicReady"                    _R⟨music⟩                                         # music                                                             # Checks if a music stream is ready                                                                                                   
unloadMusicStream               ⇐                         "UnloadMusicStream"               _R⟨music⟩                                         # music                                                             # Unload music stream                                                                                                                 
playMusicStream                 ⇐                         "PlayMusicStream"                 _R⟨music⟩                                         # music                                                             # Start music playing                                                                                                                 
isMusicStreamPlaying            ⇐ bool                    "IsMusicStreamPlaying"            _R⟨music⟩                                         # music                                                             # Check if music is playing                                                                                                           
updateMusicStream               ⇐                         "UpdateMusicStream"               _R⟨music⟩                                         # music                                                             # Updates buffers for music streaming                                                                                                 
stopMusicStream                 ⇐                         "StopMusicStream"                 _R⟨music⟩                                         # music                                                             # Stop music playing                                                                                                                  
pauseMusicStream                ⇐                         "PauseMusicStream"                _R⟨music⟩                                         # music                                                             # Pause music playing                                                                                                                 
resumeMusicStream               ⇐                         "ResumeMusicStream"               _R⟨music⟩                                         # music                                                             # Resume playing paused music                                                                                                         
seekMusicStream                 ⇐                         "SeekMusicStream"                 _R⟨music⋄f⟩                                       # music position                                                    # Seek music to a position (in seconds)                                                                                               
setMusicVolume                  ⇐                         "SetMusicVolume"                  _R⟨music⋄f⟩                                       # music volume                                                      # Set volume for music (1.0 is max level)                                                                                             
setMusicPitch                   ⇐                         "SetMusicPitch"                   _R⟨music⋄f⟩                                       # music pitch                                                       # Set pitch for a music (1.0 is base level)                                                                                           
setMusicPan                     ⇐                         "SetMusicPan"                     _R⟨music⋄f⟩                                       # music pan                                                         # Set pan for a music (0.5 is center)                                                                                                 
getMusicTimeLength              ⇐ f                       "GetMusicTimeLength"              _R⟨music⟩                                         # music                                                             # Get music time length (in seconds)                                                                                                  
getMusicTimePlayed              ⇐ f                       "GetMusicTimePlayed"              _R⟨music⟩                                         # music                                                             # Get current music time played (in seconds)                                                                                          
loadAudioStream                 ⇐ audioStream             "LoadAudioStream"                 _R⟨u⋄u⋄u⟩                                         # sampleRate sampleSize channels                                    # Load audio stream (to stream raw audio pcm data)                                                                                    
isAudioStreamReady              ⇐ bool                    "IsAudioStreamReady"              _R⟨audioStream⟩                                   # stream                                                            # Checks if an audio stream is ready                                                                                                  
unloadAudioStream               ⇐                         "UnloadAudioStream"               _R⟨audioStream⟩                                   # stream                                                            # Unload audio stream and free memory                                                                                                 
updateAudioStream               ⇐                         "UpdateAudioStream"               _R⟨audioStream⋄ptr⋄i⟩                             # stream data frameCount                                            # Update audio stream buffers with data                                                                                               
isAudioStreamProcessed          ⇐ bool                    "IsAudioStreamProcessed"          _R⟨audioStream⟩                                   # stream                                                            # Check if any audio stream buffers requires refill                                                                                   
playAudioStream                 ⇐                         "PlayAudioStream"                 _R⟨audioStream⟩                                   # stream                                                            # Play audio stream                                                                                                                   
pauseAudioStream                ⇐                         "PauseAudioStream"                _R⟨audioStream⟩                                   # stream                                                            # Pause audio stream                                                                                                                  
resumeAudioStream               ⇐                         "ResumeAudioStream"               _R⟨audioStream⟩                                   # stream                                                            # Resume audio stream                                                                                                                 
isAudioStreamPlaying            ⇐ bool                    "IsAudioStreamPlaying"            _R⟨audioStream⟩                                   # stream                                                            # Check if audio stream is playing                                                                                                    
stopAudioStream                 ⇐                         "StopAudioStream"                 _R⟨audioStream⟩                                   # stream                                                            # Stop audio stream                                                                                                                   
setAudioStreamVolume            ⇐                         "SetAudioStreamVolume"            _R⟨audioStream⋄f⟩                                 # stream volume                                                     # Set volume for audio stream (1.0 is max level)                                                                                      
setAudioStreamPitch             ⇐                         "SetAudioStreamPitch"             _R⟨audioStream⋄f⟩                                 # stream pitch                                                      # Set pitch for audio stream (1.0 is base level)                                                                                      
setAudioStreamPan               ⇐                         "SetAudioStreamPan"               _R⟨audioStream⋄f⟩                                 # stream pan                                                        # Set pan for audio stream (0.5 is centered)                                                                                          
setAudioStreamBufferSizeDefault ⇐                         "SetAudioStreamBufferSizeDefault" _R⟨i⟩                                             # size                                                              # Default size for new audio streams                                                                                                  
setAudioStreamCallback          ⇐                         "SetAudioStreamCallback"          _R⟨audioStream⋄ptr⟩                               # stream callback                                                   # Audio thread callback to request new data                                                                                           
attachAudioStreamProcessor      ⇐                         "AttachAudioStreamProcessor"      _R⟨audioStream⋄ptr⟩                               # stream processor                                                  # Attach audio stream processor to stream, receives the samples as <float>s                                                           
detachAudioStreamProcessor      ⇐                         "DetachAudioStreamProcessor"      _R⟨audioStream⋄ptr⟩                               # stream processor                                                  # Detach audio stream processor from stream                                                                                           
attachAudioMixedProcessor       ⇐                         "AttachAudioMixedProcessor"       _R⟨ptr⟩                                           # processor                                                         # Attach audio stream processor to the entire audio pipeline, receives the samples as <float>s                                        
detachAudioMixedProcessor       ⇐                         "DetachAudioMixedProcessor"       _R⟨ptr⟩                                           # processor                                                         # Detach audio stream processor from the entire audio pipeline                                                                        
