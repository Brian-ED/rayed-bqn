# Notes about this file:
# • I am not done with FFIing every raylib function.
# • I have forgotten to annotate some string var names in comments with *.
# • This file is FFI for almost everything in raylib.h: https:#github.com/raysan5/raylib/blob/fec96137e8d10ee6c88914fbe5e5429c13ee1dac/src/raylib.h
# • FFI functions are not tested before release. There are simply too many for the moment. The functions in raylib.bqn are tested, atleast minimally.

raylibPath←"raylibSource/lib/raylib.dll" # Default path
{
  "raylibPath"𝕊𝕩:raylibPath↩1↓𝕩
}´¨+`∘=⟜':'⊸⊔¨•FLines "config.txt"

#region Structs
P⇐'*'⊸∾             # '*' means a pointer
S⇐{'{'∾'}'«∾','∾¨𝕩} # Parse types into one struct

# FFI types
i‿f‿u‿i8‿·‿u8⇐⥊"32"‿"8"∾⌜"ifu"
str‿uStr⇐P¨"iu"∾¨"8:c8"
ptr⇐"*:i8"

# Structs
v2‿v3‿v4  ⇐ S¨2↓↑4⥊<"f32"
color     ⇐ S 4⥊<u8
rectangle ⇐ S 4⥊<f

# Texture, tex data stored in GPU memory (VRAM)
texture ⇐ S u‿i‿i‿i‿i
# id      # OpenGL texture id
# width   # Texture base width
# height  # Texture base height
# mipmaps # Mipmap levels, 1 by default
# format  # Data format (PixelFormat type)

# Camera2D, defines position/orientation in 2d space
camera2D ⇐ S v2‿v2‿f‿f
# offset   # Camera offset (displacement from target)
# target   # Camera target (rotation and zoom origin)
# rotation # Camera rotation in degrees
# zoom     # Camera zoom (scaling), should be 1.0f by default

# Camera, defines position/orientation in 3d space
camera3D ⇐ S v3‿v3‿v3‿f‿i
# position   # Camera position
# target     # Camera target it looks-at
# up         # Camera up vector (rotation over its axis)
# fovy       # Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
# projection # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

shader ⇐ S u‿ptr
# Shader program id
# Shader locations array (RL_MAX_SHADER_LOCATIONS)

# Matrix, 4x4 components, column major, OpenGL style, right handed
matrix ⇐ S 16⥊<f
# m0 m4 m8  m12
# m1 m5 m9  m13
# m2 m6 m10 m14
# m3 m7 m11 m15

# RenderTexture, fbo for texture rendering
renderTexture ⇐ S u<⊸∾2⥊<texture
# OpenGL framebuffer object id
# Color buffer attachment texture
# Depth buffer attachment texture

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

# Image, pixel data stored in CPU memory (RAM)
image ⇐ S ptr<⊸∾4⥊<i
# *data   # Image raw data
# width   # Image base width
# height  # Image base height
# mipmaps # Mipmap levels, 1 by default
# format  # Data format (PixelFormat type)

# GlyphInfo, font characters glyphs info
glyphInfo ⇐ S i‿i‿i‿i‿image
# value    # Character value (Unicode)
# offsetX  # Character offset X when drawing
# offsetY  # Character offset Y when drawing
# advanceX # Character advance position X
# image    # Character image data

# Font, font texture and GlyphInfo array data
font ⇐ S ⟨i,i,i,texture,ptr,ptr⟩
# baseSize           # Base size (default chars height)
# glyphCount         # Number of glyph characters
# glyphPadding       # Padding around the glyph characters
# Texture atlas containing the glyphs
# recs        # Rectangles in texture for the glyphs
# glyphs      # Glyphs info data

# MaterialMap
materialMap ⇐ S ⟨
  texture # map texture
  color   # map color
  f       # map value
⟩

# Material, includes shader and maps
material ⇐ S ⟨
  shader        # Material shader
  P materialMap # Material maps array (MAX_MATERIAL_MAPS)
  S 4⥊<f     # params[4] # Material generic parameters (if required)
⟩


# Mesh, vertex data and vao/vbo
mesh ← S ⟨
  i # vertexCount   # Number of vertices stored in arrays
  i # triangleCount # Number of triangles stored (indexed or not)

  # Vertex attributes data
  ptr # float *vertices         # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
  ptr # float *texcoords        # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
  ptr # float *texcoords2       # Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
  ptr # float *normals          # Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
  ptr # float *tangents         # Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
  ptr # unsigned char *colors   # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
  ptr # unsigned short *indices # Vertex indices (in case vertex data comes indexed)

  # Animation vertex data
  ptr # float *animVertices    # Animated vertex positions (after bones transformations)
  ptr # float *animNormals     # Animated normals (after bones transformations)
  ptr # unsigned char *boneIds # Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
  ptr # float *boneWeights     # Vertex bone weight, up to 4 bones influence by vertex (skinning)

  # OpenGL identifiers
  u    # unsigned int vaoId  # OpenGL Vertex Array Object id
  ptr # unsigned int *vboId # OpenGL Vertex Buffer Objects id (default vertex data)
⟩

# Bone, skeletal animation bone
boneInfo ⇐ S ⟨
  S 32⥊<c # name[32] # Bone name
  i            # parent   # Bone parent
⟩

# Transform, vertex transformation data
transform ⇐ S ⟨
  v3 # translation # Translation
  v4 # quaternion  # rotation
  v3 # scale       # Scale
⟩

# Model, meshes, materials and animation data
model ⇐ S ⟨
  matrix    # Matrix transform    # Local transform matrix
  i         # meshCount           # Number of meshes
  i         # materialCount       # Number of materials
  ptr       # Mesh *meshes        # Meshes array
  ptr       # Material *materials # Materials array
  i         # int *meshMaterial   # Mesh material number
  # Animation data
  i         # int boneCount       # Number of bones
  ptr       # BoneInfo *bones     # Bones information (skeleton)
  transform # Transform *bindPose # Bones base transformation (pose)
⟩

boundingBox ← S v3‿v3 # min corner to max corner

# ray for raycasting
ray ⇐ S v3‿v3 # position direction

# NPatchInfo, n-patch layout info
nPatchInfo ⇐ S ⟨
  rectangle # Texture source rectangle
  i         # Left   border offset
  i         # Top    border offset
  i         # Right  border offset
  i         # Bottom border offset
  i         # Layout of the n-patch: 3x3, 1x3 or 3x1
⟩

# ModelAnimation
ModelAnimation {
    int boneCount;          # Number of bones
    int frameCount;         # Number of animation frames
    BoneInfo *bones;        # Bones information (skeleton)
    Transform **framePoses; # Poses array by frame
} ModelAnimation;


# RayCollision, ray hit information
RayCollision {
    bool hit;               # Did the ray hit something?
    float distance;         # Distance to the nearest hit
    Vector3 point;          # Point of the nearest hit
    Vector3 normal;         # Surface normal of hit
} RayCollision;


# BoundingBox
BoundingBox {
    Vector3 min;            # Minimum vertex box-corner
    Vector3 max;            # Maximum vertex box-corner
} BoundingBox;

# Wave, audio wave data
Wave {
    unsigned int frameCount;    # Total number of frames (considering channels)
    unsigned int sampleRate;    # Frequency (samples per second)
    unsigned int sampleSize;    # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    unsigned int channels;      # Number of channels (1-mono, 2-stereo, ...)
    void *data;                 # Buffer data pointer
} Wave;

# AudioStream, custom audio stream
audioStream ⇐ S ⟨
    ptr # rAudioProcessor *buffer # Pointer to internal data used by the audio system
    ptr # rAudioBuffer *processor # Pointer to internal data processor, useful for audio effects
    u   # sampleRate              # Frequency (samples per second)
    u   # sampleSize              # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    u   # channels                # Number of channels (1-mono, 2-stereo, ...)
⟩

# Sound
sound ⇐ S ⟨
  audioStream # AudioStream stream # Audio stream
  u # frameCount         # Total number of frames (considering channels)
⟩

# Music, audio stream, anything longer than ~10 seconds should be streamed
Music {
    AudioStream stream;         # Audio stream
    unsigned int frameCount;    # Total number of frames (considering channels)
    bool looping;               # Music looping enable

    int ctxType;                # Type of music context (audio filetype)
    void *ctxData;              # Audio context data, depends on type
} Music;

# VrDeviceInfo, Head-Mounted-Display device parameters
VrDeviceInfo {
    int hResolution;                # Horizontal resolution in pixels
    int vResolution;                # Vertical resolution in pixels
    float hScreenSize;              # Horizontal size in meters
    float vScreenSize;              # Vertical size in meters
    float vScreenCenter;            # Screen center in meters
    float eyeToScreenDistance;      # Distance between eye and display in meters
    float lensSeparationDistance;   # Lens separation distance in meters
    float interpupillaryDistance;   # IPD (distance between pupils) in meters
    float lensDistortionValues[4];  # Lens distortion constant parameters
    float chromaAbCorrection[4];    # Chromatic aberration correction parameters
} VrDeviceInfo;

# VrStereoConfig, VR stereo rendering configuration for simulator
VrStereoConfig {
    Matrix projection[2];           # VR projection matrices (per eye)
    Matrix viewOffset[2];           # VR view offset matrices (per eye)
    float leftLensCenter[2];        # VR left lens center
    float rightLensCenter[2];       # VR right lens center
    float leftScreenCenter[2];      # VR left screen center
    float rightScreenCenter[2];     # VR right screen center
    float scale[2];                 # VR distortion scale
    float scaleIn[2];               # VR distortion scale in
} VrStereoConfig;

# File path list
FilePathList {
    unsigned int capacity;          # Filepaths max entries
    unsigned int count;             # Filepaths entries count
    char **paths;                   # Filepaths entries
} FilePathList;

# Trace log level
# NOTE: Organized by priority level
typedef enum {
    LOG_ALL = 0,        # Display all logs
    LOG_TRACE,          # Trace logging, intended for internal use only
    LOG_DEBUG,          # Debug logging, used for internal debugging, it should be disabled on release builds
    LOG_INFO,           # Info logging, used for program execution info
    LOG_WARNING,        # Warning logging, used on recoverable failures
    LOG_ERROR,          # Error logging, used on unrecoverable failures
    LOG_FATAL,          # Fatal logging, used to abort program: exit(EXIT_FAILURE)
    LOG_NONE            # Disable logging
} TraceLogLevel;

# Mouse cursor
typedef enum {
    MOUSE_CURSOR_DEFAULT       = 0,     # Default pointer shape
    MOUSE_CURSOR_ARROW         = 1,     # Arrow shape
    MOUSE_CURSOR_IBEAM         = 2,     # Text writing cursor shape
    MOUSE_CURSOR_CROSSHAIR     = 3,     # Cross shape
    MOUSE_CURSOR_POINTING_HAND = 4,     # Pointing hand cursor
    MOUSE_CURSOR_RESIZE_EW     = 5,     # Horizontal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NS     = 6,     # Vertical resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NWSE   = 7,     # Top-left to bottom-right diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NESW   = 8,     # The top-right to bottom-left diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_ALL    = 9,     # The omnidirectional resize/move cursor shape
    MOUSE_CURSOR_NOT_ALLOWED   = 10     # The operation-not-allowed shape
} MouseCursor;

# Gamepad buttons
typedef enum {
    GAMEPAD_BUTTON_UNKNOWN = 0,         # Unknown button, just for error checking
    GAMEPAD_BUTTON_LEFT_FACE_UP,        # Gamepad left DPAD up button
    GAMEPAD_BUTTON_LEFT_FACE_RIGHT,     # Gamepad left DPAD right button
    GAMEPAD_BUTTON_LEFT_FACE_DOWN,      # Gamepad left DPAD down button
    GAMEPAD_BUTTON_LEFT_FACE_LEFT,      # Gamepad left DPAD left button
    GAMEPAD_BUTTON_RIGHT_FACE_UP,       # Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
    GAMEPAD_BUTTON_RIGHT_FACE_RIGHT,    # Gamepad right button right (i.e. PS3: Square, Xbox: X)
    GAMEPAD_BUTTON_RIGHT_FACE_DOWN,     # Gamepad right button down (i.e. PS3: Cross, Xbox: A)
    GAMEPAD_BUTTON_RIGHT_FACE_LEFT,     # Gamepad right button left (i.e. PS3: Circle, Xbox: B)
    GAMEPAD_BUTTON_LEFT_TRIGGER_1,      # Gamepad top/back trigger left (first), it could be a trailing button
    GAMEPAD_BUTTON_LEFT_TRIGGER_2,      # Gamepad top/back trigger left (second), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_1,     # Gamepad top/back trigger right (one), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_2,     # Gamepad top/back trigger right (second), it could be a trailing button
    GAMEPAD_BUTTON_MIDDLE_LEFT,         # Gamepad center buttons, left one (i.e. PS3: Select)
    GAMEPAD_BUTTON_MIDDLE,              # Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
    GAMEPAD_BUTTON_MIDDLE_RIGHT,        # Gamepad center buttons, right one (i.e. PS3: Start)
    GAMEPAD_BUTTON_LEFT_THUMB,          # Gamepad joystick pressed button left
    GAMEPAD_BUTTON_RIGHT_THUMB          # Gamepad joystick pressed button right
} GamepadButton;

# Gamepad axis
typedef enum {
    GAMEPAD_AXIS_LEFT_X        = 0,     # Gamepad left stick X axis
    GAMEPAD_AXIS_LEFT_Y        = 1,     # Gamepad left stick Y axis
    GAMEPAD_AXIS_RIGHT_X       = 2,     # Gamepad right stick X axis
    GAMEPAD_AXIS_RIGHT_Y       = 3,     # Gamepad right stick Y axis
    GAMEPAD_AXIS_LEFT_TRIGGER  = 4,     # Gamepad back trigger left, pressure level: [1..-1]
    GAMEPAD_AXIS_RIGHT_TRIGGER = 5      # Gamepad back trigger right, pressure level: [1..-1]
} GamepadAxis;

# Material map index
typedef enum {
    MATERIAL_MAP_ALBEDO = 0,        # Albedo material (same as: MATERIAL_MAP_DIFFUSE)
    MATERIAL_MAP_METALNESS,         # Metalness material (same as: MATERIAL_MAP_SPECULAR)
    MATERIAL_MAP_NORMAL,            # Normal material
    MATERIAL_MAP_ROUGHNESS,         # Roughness material
    MATERIAL_MAP_OCCLUSION,         # Ambient occlusion material
    MATERIAL_MAP_EMISSION,          # Emission material
    MATERIAL_MAP_HEIGHT,            # Heightmap material
    MATERIAL_MAP_CUBEMAP,           # Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_IRRADIANCE,        # Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_PREFILTER,         # Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_BRDF               # Brdf material
} MaterialMapIndex;

# Shader location index
typedef enum {
    SHADER_LOC_VERTEX_POSITION = 0, # Shader location: vertex attribute: position
    SHADER_LOC_VERTEX_TEXCOORD01,   # Shader location: vertex attribute: texcoord01
    SHADER_LOC_VERTEX_TEXCOORD02,   # Shader location: vertex attribute: texcoord02
    SHADER_LOC_VERTEX_NORMAL,       # Shader location: vertex attribute: normal
    SHADER_LOC_VERTEX_TANGENT,      # Shader location: vertex attribute: tangent
    SHADER_LOC_VERTEX_COLOR,        # Shader location: vertex attribute: color
    SHADER_LOC_MATRIX_MVP,          # Shader location: matrix uniform: model-view-projection
    SHADER_LOC_MATRIX_VIEW,         # Shader location: matrix uniform: view (camera transform)
    SHADER_LOC_MATRIX_PROJECTION,   # Shader location: matrix uniform: projection
    SHADER_LOC_MATRIX_MODEL,        # Shader location: matrix uniform: model (transform)
    SHADER_LOC_MATRIX_NORMAL,       # Shader location: matrix uniform: normal
    SHADER_LOC_VECTOR_VIEW,         # Shader location: vector uniform: view
    SHADER_LOC_COLOR_DIFFUSE,       # Shader location: vector uniform: diffuse color
    SHADER_LOC_COLOR_SPECULAR,      # Shader location: vector uniform: specular color
    SHADER_LOC_COLOR_AMBIENT,       # Shader location: vector uniform: ambient color
    SHADER_LOC_MAP_ALBEDO,          # Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
    SHADER_LOC_MAP_METALNESS,       # Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
    SHADER_LOC_MAP_NORMAL,          # Shader location: sampler2d texture: normal
    SHADER_LOC_MAP_ROUGHNESS,       # Shader location: sampler2d texture: roughness
    SHADER_LOC_MAP_OCCLUSION,       # Shader location: sampler2d texture: occlusion
    SHADER_LOC_MAP_EMISSION,        # Shader location: sampler2d texture: emission
    SHADER_LOC_MAP_HEIGHT,          # Shader location: sampler2d texture: height
    SHADER_LOC_MAP_CUBEMAP,         # Shader location: samplerCube texture: cubemap
    SHADER_LOC_MAP_IRRADIANCE,      # Shader location: samplerCube texture: irradiance
    SHADER_LOC_MAP_PREFILTER,       # Shader location: samplerCube texture: prefilter
    SHADER_LOC_MAP_BRDF             # Shader location: sampler2d texture: brdf
} ShaderLocationIndex;

# Shader uniform data type
typedef enum {
    SHADER_UNIFORM_FLOAT = 0,       # Shader uniform type: float
    SHADER_UNIFORM_VEC2,            # Shader uniform type: vec2 (2 float)
    SHADER_UNIFORM_VEC3,            # Shader uniform type: vec3 (3 float)
    SHADER_UNIFORM_VEC4,            # Shader uniform type: vec4 (4 float)
    SHADER_UNIFORM_INT,             # Shader uniform type: int
    SHADER_UNIFORM_IVEC2,           # Shader uniform type: ivec2 (2 int)
    SHADER_UNIFORM_IVEC3,           # Shader uniform type: ivec3 (3 int)
    SHADER_UNIFORM_IVEC4,           # Shader uniform type: ivec4 (4 int)
    SHADER_UNIFORM_SAMPLER2D        # Shader uniform type: sampler2d
} ShaderUniformDataType;

# Shader attribute data types
typedef enum {
    SHADER_ATTRIB_FLOAT = 0,        # Shader attribute type: float
    SHADER_ATTRIB_VEC2,             # Shader attribute type: vec2 (2 float)
    SHADER_ATTRIB_VEC3,             # Shader attribute type: vec3 (3 float)
    SHADER_ATTRIB_VEC4              # Shader attribute type: vec4 (4 float)
} ShaderAttributeDataType;

# Pixel formats
# NOTE: Support depends on OpenGL version and platform
typedef enum {
    PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1, # 8 bit per pixel (no alpha)
    PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA,    # 8*2 bpp (2 channels)
    PIXELFORMAT_UNCOMPRESSED_R5G6B5,        # 16 bpp
    PIXELFORMAT_UNCOMPRESSED_R8G8B8,        # 24 bpp
    PIXELFORMAT_UNCOMPRESSED_R5G5B5A1,      # 16 bpp (1 bit alpha)
    PIXELFORMAT_UNCOMPRESSED_R4G4B4A4,      # 16 bpp (4 bit alpha)
    PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,      # 32 bpp
    PIXELFORMAT_UNCOMPRESSED_R32,           # 32 bpp (1 channel - float)
    PIXELFORMAT_UNCOMPRESSED_R32G32B32,     # 32*3 bpp (3 channels - float)
    PIXELFORMAT_UNCOMPRESSED_R32G32B32A32,  # 32*4 bpp (4 channels - float)
    PIXELFORMAT_COMPRESSED_DXT1_RGB,        # 4 bpp (no alpha)
    PIXELFORMAT_COMPRESSED_DXT1_RGBA,       # 4 bpp (1 bit alpha)
    PIXELFORMAT_COMPRESSED_DXT3_RGBA,       # 8 bpp
    PIXELFORMAT_COMPRESSED_DXT5_RGBA,       # 8 bpp
    PIXELFORMAT_COMPRESSED_ETC1_RGB,        # 4 bpp
    PIXELFORMAT_COMPRESSED_ETC2_RGB,        # 4 bpp
    PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA,   # 8 bpp
    PIXELFORMAT_COMPRESSED_PVRT_RGB,        # 4 bpp
    PIXELFORMAT_COMPRESSED_PVRT_RGBA,       # 4 bpp
    PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA,   # 8 bpp
    PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA    # 2 bpp
} PixelFormat;

# Texture parameters: filter mode
# NOTE 1: Filtering considers mipmaps if available in the texture
# NOTE 2: Filter is accordingly set for minification and magnification
typedef enum {
    TEXTURE_FILTER_POINT = 0,               # No filter, just pixel approximation
    TEXTURE_FILTER_BILINEAR,                # Linear filtering
    TEXTURE_FILTER_TRILINEAR,               # Trilinear filtering (linear with mipmaps)
    TEXTURE_FILTER_ANISOTROPIC_4X,          # Anisotropic filtering 4x
    TEXTURE_FILTER_ANISOTROPIC_8X,          # Anisotropic filtering 8x
    TEXTURE_FILTER_ANISOTROPIC_16X,         # Anisotropic filtering 16x
} TextureFilter;

# Texture parameters: wrap mode
typedef enum {
    TEXTURE_WRAP_REPEAT = 0,                # Repeats texture in tiled mode
    TEXTURE_WRAP_CLAMP,                     # Clamps texture to edge pixel in tiled mode
    TEXTURE_WRAP_MIRROR_REPEAT,             # Mirrors and repeats the texture in tiled mode
    TEXTURE_WRAP_MIRROR_CLAMP               # Mirrors and clamps to border the texture in tiled mode
} TextureWrap;

# Cubemap layouts
typedef enum {
    CUBEMAP_LAYOUT_AUTO_DETECT = 0,         # Automatically detect layout type
    CUBEMAP_LAYOUT_LINE_VERTICAL,           # Layout is defined by a vertical line with faces
    CUBEMAP_LAYOUT_LINE_HORIZONTAL,         # Layout is defined by a horizontal line with faces
    CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR,     # Layout is defined by a 3x4 cross with cubemap faces
    CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE,     # Layout is defined by a 4x3 cross with cubemap faces
    CUBEMAP_LAYOUT_PANORAMA                 # Layout is defined by a panorama image (equirrectangular map)
} CubemapLayout;

# Font type, defines generation method
typedef enum {
    FONT_DEFAULT = 0,               # Default font generation, anti-aliased
    FONT_BITMAP,                    # Bitmap font generation, no anti-aliasing
    FONT_SDF                        # SDF font generation, requires external shader
} FontType;

# Color blending modes (pre-defined)
typedef enum {
    BLEND_ALPHA = 0,                # Blend textures considering alpha (default)
    BLEND_ADDITIVE,                 # Blend textures adding colors
    BLEND_MULTIPLIED,               # Blend textures multiplying colors
    BLEND_ADD_COLORS,               # Blend textures adding colors (alternative)
    BLEND_SUBTRACT_COLORS,          # Blend textures subtracting colors (alternative)
    BLEND_ALPHA_PREMULTIPLY,        # Blend premultiplied textures considering alpha
    BLEND_CUSTOM,                   # Blend textures using custom src/dst factors (use rlSetBlendFactors())
    BLEND_CUSTOM_SEPARATE           # Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
} BlendMode;

# Gesture
# NOTE: Provided as bit-wise flags to enable only desired gestures
typedef enum {
    GESTURE_NONE        = 0,        # No gesture
    GESTURE_TAP         = 1,        # Tap gesture
    GESTURE_DOUBLETAP   = 2,        # Double tap gesture
    GESTURE_HOLD        = 4,        # Hold gesture
    GESTURE_DRAG        = 8,        # Drag gesture
    GESTURE_SWIPE_RIGHT = 16,       # Swipe right gesture
    GESTURE_SWIPE_LEFT  = 32,       # Swipe left gesture
    GESTURE_SWIPE_UP    = 64,       # Swipe up gesture
    GESTURE_SWIPE_DOWN  = 128,      # Swipe down gesture
    GESTURE_PINCH_IN    = 256,      # Pinch in gesture
    GESTURE_PINCH_OUT   = 512       # Pinch out gesture
} Gesture;

# Camera system modes
typedef enum {
    CAMERA_CUSTOM = 0,              # Custom camera
    CAMERA_FREE,                    # Free camera
    CAMERA_ORBITAL,                 # Orbital camera
    CAMERA_FIRST_PERSON,            # First person camera
    CAMERA_THIRD_PERSON             # Third person camera
} CameraMode;

# Camera projection
typedef enum {
    CAMERA_PERSPECTIVE = 0,         # Perspective projection
    CAMERA_ORTHOGRAPHIC             # Orthographic projection
} CameraProjection;

# N-patch layout
typedef enum {
    NPATCH_NINE_PATCH = 0,          # Npatch layout: 3x3 tiles
    NPATCH_THREE_PATCH_VERTICAL,    # Npatch layout: 1x3 tiles
    NPATCH_THREE_PATCH_HORIZONTAL   # Npatch layout: 3x1 tiles
} NPatchLayout;



#endregion Structs

#region FFIFunctions

# making FFI nicer to use
_R ⇐ {𝕨 funcName _𝕣 inpTypes: outType←𝕨⊣⟨⟩
  a←(⋈'>'⊸∾)⍟(×∘≠∧1=≡)@⟨⟩⍟≡𝕩
  raylibPath•FFI outType‿𝕗∾a
}


#------------------------------------------------------------------------------------
# Window and Graphics Device Functions (Module: core)
#------------------------------------------------------------------------------------

# Window-related functions
initWindow               ⇐      "InitWindow"              _R i‿i‿str # width height title # Initialize window and OpenGL context
windowShouldClose        ⇐ i    "WindowShouldClose"       _R@                             # Check if KEY_ESCAPE pressed or Close icon pressed
closeWindow              ⇐      "CloseWindow"             _R@                             # Close window and unload OpenGL context
isWindowReady            ⇐ "i8" "IsWindowReady"           _R@                             # Check if window has been initialized successfully
isWindowFullscreen       ⇐ "i8" "IsWindowFullscreen"      _R@                             # Check if window is currently fullscreen
isWindowHidden           ⇐ "i8" "IsWindowHidden"          _R@                             # Check if window is currently hidden (only PLATFORM_DESKTOP)
isWindowMinimized        ⇐ "i8" "IsWindowMinimized"       _R@                             # Check if window is currently minimized (only PLATFORM_DESKTOP)
isWindowMaximized        ⇐ "i8" "IsWindowMaximized"       _R@                             # Check if window is currently maximized (only PLATFORM_DESKTOP)
isWindowFocused          ⇐ "i8" "IsWindowFocused"         _R@                             # Check if window is currently focused (only PLATFORM_DESKTOP)
isWindowResized          ⇐ "i8" "IsWindowResized"         _R@                             # Check if window has been resized last frame
isWindowState            ⇐ "i8" "IsWindowState"           _R u # flag                     # Check if one specific window flag is enabled
setWindowState           ⇐      "SetWindowState"          _R u # flags                    # Set window configuration state using flags (only PLATFORM_DESKTOP)
clearWindowState         ⇐      "ClearWindowState"        _R u # flags                    # Clear window configuration state flags
toggleFullscreen         ⇐      "ToggleFullscreen"        _R@                             # Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)
maximizeWindow           ⇐      "MaximizeWindow"          _R@                             # Set window state: maximized, if resizable (only PLATFORM_DESKTOP)
minimizeWindow           ⇐      "MinimizeWindow"          _R@                             # Set window state: minimized, if resizable (only PLATFORM_DESKTOP)
restoreWindow            ⇐      "RestoreWindow"           _R@                             # Set window state: not minimized/maximized (only PLATFORM_DESKTOP)
setWindowIcon            ⇐      "SetWindowIcon"           _R image                        # Set icon for window (single image, RGBA 32bit, only PLATFORM_DESKTOP)
setWindowIcons           ⇐      "SetWindowIcons"          _R(P image)‿i # images count  # Set icon for window (multiple images, RGBA 32bit, only PLATFORM_DESKTOP)
setWindowTitle           ⇐      "SetWindowTitle"          _R str # title                  # Set title for window (only PLATFORM_DESKTOP)
setWindowPosition        ⇐      "SetWindowPosition"       _R i‿i # x y                    # Set window position on screen (only PLATFORM_DESKTOP)
setWindowMonitor         ⇐      "SetWindowMonitor"        _R i   # monitor                # Set monitor for the current window (fullscreen mode)
setWindowMinSize         ⇐      "SetWindowMinSize"        _R i‿i # width height           # Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
setWindowSize            ⇐      "SetWindowSize"           _R i‿i # width height           # Set window dimensions
setWindowOpacity         ⇐      "SetWindowOpacity"        _R f # opacity                  # Set window opacity [0.0f..1.0f] (only PLATFORM_DESKTOP)
getWindowHandle          ⇐ ptr "GetWindowHandle"         _R@                             # Get native window handle
getScreenWidth           ⇐ i    "GetScreenWidth"          _R@                             # Get current screen width
getScreenHeight          ⇐ i    "GetScreenHeight"         _R@                             # Get current screen height
getRenderWidth           ⇐ i    "GetRenderWidth"          _R@                             # Get current render width (it considers HiDPI)
getRenderHeight          ⇐ i    "GetRenderHeight"         _R@                             # Get current render height (it considers HiDPI)
getMonitorCount          ⇐ i    "GetMonitorCount"         _R@                             # Get number of connected monitors
getCurrentMonitor        ⇐ i    "GetCurrentMonitor"       _R@                             # Get current connected monitor
getMonitorPosition       ⇐ v2   "GetMonitorPosition"      _R i # monitor                  # Get specified monitor position
getMonitorWidth          ⇐ i    "GetMonitorWidth"         _R i # monitor                  # Get specified monitor width (current video mode used by monitor)
getMonitorHeight         ⇐ i    "GetMonitorHeight"        _R i # monitor                  # Get specified monitor height (current video mode used by monitor)
getMonitorPhysicalWidth  ⇐ i    "GetMonitorPhysicalWidth" _R i # monitor                  # Get specified monitor physical width in millimetres
getMonitorPhysicalHeight ⇐ i    "GetMonitorPhysicalHeight"_R i # monitor                  # Get specified monitor physical height in millimetres
getMonitorRefreshRate    ⇐ i    "GetMonitorRefreshRate"   _R i # monitor                  # Get specified monitor refresh rate
getWindowPosition        ⇐ v2   "GetWindowPosition"       _R@                             # Get window position XY on monitor
getWindowScaleDPI        ⇐ v2   "GetWindowScaleDPI"       _R@                             # Get window scale DPI factor
getMonitorName           ⇐ ptr "GetMonitorName"          _R i # utf-8 _R monitor         # Get the human-readable, UTF-8 encoded name of the primary monitor
setClipboardText         ⇐      "SetClipboardText"        _R str # text                   # Set clipboard text content
getClipboardText         ⇐ ptr "GetClipboardText"        _R@ # utf-8                     # Get clipboard text content
enableEventWaiting       ⇐      "EnableEventWaiting"      _R@                             # Enable waiting for events on EndDrawing(), no automatic event polling
disableEventWaiting      ⇐      "DisableEventWaiting"     _R@                             # Disable waiting for events on EndDrawing(), automatic events polling


# Custom frame control functions
# NOTE: Those functions are intended for advance users that want full control over the frame processing
# By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
# To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
swapScreenBuffer ⇐ "SwapScreenBuffer"_R@                # Swap back buffer with front buffer (screen drawing)
pollInputEvents  ⇐ "PollInputEvents" _R@                # Register all input events
waitTime         ⇐ "WaitTime"        _R "f64" # seconds # Wait for some time (halt program execution)

# Cursor-related functions
showCursor       ⇐      "showCursor"      _R@ # Shows cursor
hideCursor       ⇐      "hideCursor"      _R@ # Hides cursor
isCursorHidden   ⇐ "i8" "isCursorHidden"  _R@ # Check if cursor is not visible
enableCursor     ⇐      "enableCursor"    _R@ # Enables cursor (unlock cursor)
disableCursor    ⇐      "disableCursor"   _R@ # Disables cursor (lock cursor)
isCursorOnScreen ⇐ "i8" "isCursorOnScreen"_R@ # Check if cursor is on the screen

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
loadShader              ⇐ shader"LoadShader"             _R str‿str           # vsFileName fsFileName # Load shader from files and bind default locations
loadShaderFromMemory    ⇐ shader"LoadShaderFromMemory"   _R str‿str           # vsCode fsCode                           # Load shader from code strings and bind default locations
isShaderReady           ⇐ "i8"  "IsShaderReady"          _R shader                                                      # Check if a shader is ready
getShaderLocation       ⇐ i     "GetShaderLocation"      _R shader‿str        # shader uniformName                      # Get shader uniform location
getShaderLocationAttrib ⇐ i     "GetShaderLocationAttrib"_R shader‿str        # shader attribName                       # Get shader attribute location
setShaderValue          ⇐       "SetShaderValue"         _R shader‿i‿(P f)‿i   # shader locIndex value uniformType       # Set shader uniform value   # note to future Brian: Changed void to *f32 to fix a bug.
setShaderValue2         ⇐       "SetShaderValue"         _R shader‿i‿ptr‿i   # shader locIndex value uniformType       # Set shader uniform value   # note to future Brian: Changed void to *f32 to fix a bug.
setShaderValueV         ⇐       "SetShaderValueV"        _R shader‿i‿ptr‿i‿i # shader locIndex value uniformType count # Set shader uniform value vector
setShaderValueMatrix    ⇐       "SetShaderValueMatrix"   _R shader‿i‿matrix   # shader locindex mat                     # Set shader uniform value (matrix 4x4)
setShaderValueTexture   ⇐       "SetShaderValueTexture"  _R shader‿i‿texture  # shader locIndex texture                 # Set shader uniform value for texture (sampler2d)
unloadShader            ⇐       "UnloadShader"           _R shader                                                      # Unload shader from GPU memory (VRAM)

# # Screen-space-related functions
# Ray GetMouseRay(Vector2 mousePosition, Camera camera);      # Get a ray trace from mouse position
# Matrix GetCameraMatrix(Camera camera);                      # Get camera transform matrix (view matrix)
# Matrix GetCameraMatrix2D(Camera2D camera);                  # Get camera 2d transform matrix
# Vector2 GetWorldToScreen(Vector3 position, Camera camera);  # Get the screen space position for a 3d world space position
# Vector2 GetScreenToWorld2D(Vector2 position, Camera2D camera); # Get the world space position for a 2d camera screen space position
# Vector2 GetWorldToScreenEx(Vector3 position, Camera camera, int width, int height); # Get size position for a 3d world space position
# Vector2 GetWorldToScreen2D(Vector2 position, Camera2D camera); # Get the screen space position for a 2d camera world space position

# Timing-related functions
setTargetFPS ⇐       "SetTargetFPS" _R i # fps # Set target FPS (maximum)
getFPS       ⇐ i     "GetFPS"       _R@        # Get current FPS
getFrameTime ⇐ f     "GetFrameTime" _R@        # Get time in seconds for last frame drawn (delta time)
getTime      ⇐ "f64" "GetTime"      _R@        # Get elapsed time in seconds since InitWindow()

# Misc. functions
getRandomValue ⇐ i "GetRandomValue"_R i‿i # min max  # Get a random value between min and max (both included)
setRandomSeed  ⇐   "SetRandomSeed" _R i   # seed     # Set the seed for the random number generator
takeScreenshot ⇐   "TakeScreenshot"_R str # filename # Takes a screenshot of current screen (filename extension defines format)
setConfigFlags ⇐   "SetConfigFlags"_R u   # flags    # Setup init configuration flags (view FLAGS)

traceLog         ⇐      "TraceLog"        _R i‿str                         # logLevel text ... # Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
setTraceLogLevel ⇐      "SetTraceLogLevel"_R i                             # logLevel          # Set the current threshold (minimum) log level
memAlloc         ⇐ ptr "MemAlloc"        _R u                             # size              # Internal memory allocator
memRealloc       ⇐ ptr "MemRealloc"      _R ptr‿u                        # ptr size          # Internal memory reallocator
memFree          ⇐      "MemFree"         _R ptr                          # ptr               # Internal memory free

openURL ⇐ "OpenURL"_R str #url # Open URL with default system browser (if available)

# Set custom callbacks
# WARNING: Callbacks setup is intended for advance users
setTraceLogCallback     ⇐ "traceLogCallback"    _R traceLogCallback     # callback # Set custom trace log
setLoadFileDataCallback ⇐ "loadFileDataCallback"_R loadFileDataCallback # callback # Set custom file binary data loader
setSaveFileDataCallback ⇐ "saveFileDataCallback"_R saveFileDataCallback # callback # Set custom file binary data saver
setLoadFileTextCallback ⇐ "loadFileTextCallback"_R loadFileTextCallback # callback # Set custom file text data loader
setSaveFileTextCallback ⇐ "saveFileTextCallback"_R saveFileTextCallback # callback # Set custom file text data saver

# # Files management functions
# unsigned char *LoadFileData(const char *fileName, unsigned int *bytesRead);       # Load file data as byte array (read)
# void UnloadFileData(unsigned char *data);                   # Unload file data allocated by LoadFileData()
# bool SaveFileData(const char *fileName, void *data, unsigned int bytesToWrite);   # Save data to file from byte array (write), returns true on success
# bool ExportDataAsCode(const unsigned char *data, unsigned int size, const char *fileName); # Export data to code (.h), returns true on success
# char *LoadFileText(const char *fileName);                   # Load text data from file (read), returns a '\0' terminated string
# void UnloadFileText(char *text);                            # Unload file text data allocated by LoadFileText()
# bool SaveFileText(const char *fileName, char *text);        # Save text data to file (write), string must be '\0' terminated, returns true on success
# bool FileExists(const char *fileName);                      # Check if file exists
# bool DirectoryExists(const char *dirPath);                  # Check if a directory path exists
# bool IsFileExtension(const char *fileName, const char *ext); # Check file extension (including point: .png, .wav)
# int GetFileLength(const char *fileName);                    # Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
# const char *GetFileExtension(const char *fileName);         # Get pointer to extension for a filename string (includes dot: '.png')
# const char *GetFileName(const char *filePath);              # Get pointer to filename for a path string
# const char *GetFileNameWithoutExt(const char *filePath);    # Get filename string without extension (uses static string)
# const char *GetDirectoryPath(const char *filePath);         # Get full path for a given fileName with path (uses static string)
# const char *GetPrevDirectoryPath(const char *dirPath);      # Get previous directory path for a given path (uses static string)
# const char *GetWorkingDirectory(void);                      # Get current working directory (uses static string)
# const char *GetApplicationDirectory(void);                  # Get the directory if the running application (uses static string)
# bool ChangeDirectory(const char *dir);                      # Change working directory, return true on success
# bool IsPathFile(const char *path);                          # Check if a given path is a file or a directory
# FilePathList LoadDirectoryFiles(const char *dirPath);       # Load directory filepaths
# FilePathList LoadDirectoryFilesEx(const char *basePath, const char *filter, bool scanSubdirs); # Load directory filepaths with extension filtering and recursive directory scan
# void UnloadDirectoryFiles(FilePathList files);              # Unload filepaths
# bool IsFileDropped(void);                                   # Check if a file has been dropped into window
# FilePathList LoadDroppedFiles(void);                        # Load dropped filepaths
# void UnloadDroppedFiles(FilePathList files);                # Unload dropped filepaths
# long GetFileModTime(const char *fileName);                  # Get file modification time (last write time)

# Compression/Encoding functionality
compressData     ⇐ ptr "CompressData"    _R uStr‿i‿"&i32"  # data dataSize compDataSize      # Compress data (DEFLATE algorithm), memory must be MemFree()
decompressData   ⇐ ptr "DecompressData"  _R uStr‿i‿"&i32"  # compData compDataSize dataSize  # Decompress data (DEFLATE algorithm), memory must be MemFree()
encodeDataBase64 ⇐ ptr "EncodeDataBase64"_R uStr‿i‿i       # data dataSize *outputSize       # Encode data to Base64 string, memory must be MemFree()
decodeDataBase64 ⇐ ptr "DecodeDataBase64"_R uStr‿i‿(P i) # data *outputSize                # Decode Base64 string data, memory must be MemFree()


#------------------------------------------------------------------------------------
# Input Handling Functions (Module: core)
#------------------------------------------------------------------------------------

# Input-related functions: keyboard
isKeyPressed   ⇐ "i8" "IsKeyPressed"  _R i # Check if a key has been pressed once
isKeyDown      ⇐ "i8" "IsKeyDown"     _R i # Check if a key is being pressed
isKeyReleased  ⇐ "i8" "IsKeyReleased" _R i # Check if a key has been released once
isKeyUp        ⇐ "i8" "IsKeyUp"       _R i # Check if a key is NOT being pressed
setExitKey     ⇐      "SetExitKey"    _R i # Set a custom key to exit program (default is ESC)
getKeyPressed  ⇐  i   "GetKeyPressed" _R@  # Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
getCharPressed ⇐  i   "GetCharPressed"_R@  # Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty

# Input-related functions: gamepads
# bool IsGamepadAvailable(int gamepad);                   # Check if a gamepad is available
# const char *GetGamepadName(int gamepad);                # Get gamepad internal name id
# bool IsGamepadButtonPressed(int gamepad, int button);   # Check if a gamepad button has been pressed once
# bool IsGamepadButtonDown(int gamepad, int button);      # Check if a gamepad button is being pressed
# bool IsGamepadButtonReleased(int gamepad, int button);  # Check if a gamepad button has been released once
# bool IsGamepadButtonUp(int gamepad, int button);        # Check if a gamepad button is NOT being pressed
# int GetGamepadButtonPressed(void);                      # Get the last gamepad button pressed
# int GetGamepadAxisCount(int gamepad);                   # Get gamepad axis count for a gamepad
# float GetGamepadAxisMovement(int gamepad, int axis);    # Get axis movement value for a gamepad axis
# int SetGamepadMappings(const char *mappings);           # Set internal gamepad mappings (SDL_GameControllerDB)

# Input-related functions: mouse
isMouseButtonPressed  ⇐ "i8" "IsMouseButtonPressed" _R i   # button          # Check if a mouse button has been pressed once
isMouseButtonDown     ⇐ "i8" "IsMouseButtonDown"    _R i   # button          # Check if a mouse button is being pressed
isMouseButtonReleased ⇐ "i8" "IsMouseButtonReleased"_R i   # button          # Check if a mouse button has been released once
isMouseButtonUp       ⇐ "i8" "IsMouseButtonUp"      _R i   # button          # Check if a mouse button is NOT being pressed
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
# int GetTouchX(void);                                    # Get touch position X for touch point 0 (relative to screen size)
# int GetTouchY(void);                                    # Get touch position Y for touch point 0 (relative to screen size)
# Vector2 GetTouchPosition(int index);                    # Get touch position XY for a touch point index (relative to screen size)
# int GetTouchPointId(int index);                         # Get touch point identifier for given index
# int GetTouchPointCount(void);                           # Get number of touch points


# #------------------------------------------------------------------------------------
# # Gestures and Touch Handling Functions (Module: rgestures)
# #------------------------------------------------------------------------------------
# void SetGesturesEnabled(unsigned int flags);      # Enable a set of gestures using flags
# bool IsGestureDetected(int gesture);              # Check if a gesture have been detected
# int GetGestureDetected(void);                     # Get latest detected gesture
# float GetGestureHoldDuration(void);               # Get gesture hold time in milliseconds
# Vector2 GetGestureDragVector(void);               # Get gesture drag vector
# float GetGestureDragAngle(void);                  # Get gesture drag angle
# Vector2 GetGesturePinchVector(void);              # Get gesture pinch delta
# float GetGesturePinchAngle(void);                 # Get gesture pinch angle

#------------------------------------------------------------------------------------
# Camera System Functions (Module: rcamera)
#------------------------------------------------------------------------------------

updateCamera    ⇐ "UpdateCamera"   _R (P camera3d)‿i       # Camera mode                   # Update camera position for selected mode
updateCameraPro ⇐ "UpdateCameraPro"_R (P camera3d)‿v3‿v3‿f # Camera movement rotation zoom # Update camera movement/rotation


#------------------------------------------------------------------------------------
# Basic Shapes Drawing Functions (Module: shapes)
#------------------------------------------------------------------------------------
# Set texture and rectangle to be used on shapes drawing
# NOTE: It can be useful when using basic shapes and one single font,
# defining a font char white rectangle would allow drawing everything in a single draw call
#void SetShapesTexture(Texture2D texture, Rectangle source);       # Set texture and rectangle to be used on shapes drawing

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

# # Basic shapes collision detection functions
# bool CheckCollisionRecs(Rectangle rec1, Rectangle rec2);                                           # Check collision between two rectangles
# bool CheckCollisionCircles(Vector2 center1, float radius1, Vector2 center2, float radius2);        # Check collision between two circles
# bool CheckCollisionCircleRec(Vector2 center, float radius, Rectangle rec);                         # Check collision between circle and rectangle
# bool CheckCollisionPointRec(Vector2 point, Rectangle rec);                                         # Check if point is inside rectangle
# bool CheckCollisionPointCircle(Vector2 point, Vector2 center, float radius);                       # Check if point is inside circle
# bool CheckCollisionPointTriangle(Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3);               # Check if point is inside a triangle
# bool CheckCollisionPointPoly(Vector2 point, Vector2 *points, int pointCount);                      # Check if point is within a polygon described by array of vertices
# bool CheckCollisionLines(Vector2 startPos1, Vector2 endPos1, Vector2 startPos2, Vector2 endPos2, Vector2 *collisionPoint); # Check the collision between two lines defined by two points each, returns collision point by reference
# bool CheckCollisionPointLine(Vector2 point, Vector2 p1, Vector2 p2, int threshold);                # Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
# Rectangle GetCollisionRec(Rectangle rec1, Rectangle rec2);                                         # Get collision rectangle for two rectangles collision

#------------------------------------------------------------------------------------
# Texture Loading and Drawing Functions (Module: textures)
#------------------------------------------------------------------------------------

# Image loading functions
# NOTE: This functions do not require GPU access
loadImage            ⇐ image "LoadImage"           _R str         # fileName                               # Load image from file into CPU memory (RAM)
loadImageRaw         ⇐ image "LoadImageRaw"        _R str‿i‿i‿i‿i # fileName width hight format headerSize # Load image from RAW file data
loadImageAnim        ⇐ image "LoadImageAnim"       _R str‿i       # fileName framesCount                   # Load image sequence from file (frames appended to image.data)
loadImageFromMemory  ⇐ image "LoadImageFromMemory" _R str‿str‿i   # fileType fileData dataSize             # Load image from memory buffer, fileType refers to extension: i.e. '.png'
loadImageFromTexture ⇐ image "LoadImageFromTexture"_R texture     # texture2D                              # Load image from GPU texture data
loadImageFromScreen  ⇐ image "LoadImageFromScreen" _R@                                                     # Load image from screen buffer and (screenshot)
isImageReady         ⇐ "i8"  "IsImageReady"        _R image # Check if an image is ready
unloadImage          ⇐       "UnloadImage"         _R image                                                # Unload image from CPU memory (RAM)
exportImage          ⇐ "i8"  "ExportImage"         _R image‿str   # image filename                         # Export image data to file, returns true on success
exportImageAsCode    ⇐ "i8"  "ExportImageAsCode"   _R image‿str   # image fileName                         # Export image as code file defining an array of bytes, returns true on success


# Image generation functions
genImageColor          ← image "GenImageColor"         _R i‿i‿color           # width hight color                     # Generate image: plain color
genImageGradientV      ← image "GenImageGradientV"     _R i‿i‿color‿color     # width hight top bottom                # Generate image: vertical gradient
genImageGradientH      ← image "GenImageGradientH"     _R i‿i‿color‿color     # width hight left right                # Generate image: horizontal gradient
genImageGradientRadial ← image "GenImageGradientRadial"_R i‿i‿f‿color‿color   # width hight density inner outer       # Generate image: radial gradient
genImageChecked        ← image "GenImageChecked"       _R i‿i‿i‿i‿color‿color # width hight checksX checksY col1 col2 # Generate image: checked
genImageWhiteNoise     ← image "GenImageWhiteNoise"    _R i‿i‿f               # width hight factor                    # Generate image: white noise
genImagePerlinNoise    ← image "GenImagePerlinNoise"   _R i‿i‿i‿i‿f           # width hight offsetX offsetY scale     # Generate image: perlin noise
genImageCellular       ← image "GenImageCellular"      _R i‿i‿i               # width hight tileSize                  # Generate image: cellular algorithm, bigger tileSize means bigger cells
genImageText           ← image "GenImageText"          _R i‿i‿str             # width hight *text                     # Generate image: grayscale image from text data

# # Image manipulation functions
# Image ImageCopy(Image image);                                                                      # Create an image duplicate (useful for transformations)
# Image ImageFromImage(Image image, Rectangle rec);                                                  # Create an image from another image piece
# Image ImageText(const char *text, int fontSize, Color color);                                      # Create an image from text (default font)
# Image ImageTextEx(Font font, const char *text, float fontSize, float spacing, Color tint);         # Create an image from text (custom sprite font)
# void ImageFormat(Image *image, int newFormat);                                                     # Convert image data to desired format
# void ImageToPOT(Image *image, Color fill);                                                         # Convert image to POT (power-of-two)
# void ImageCrop(Image *image, Rectangle crop);                                                      # Crop an image to a defined rectangle
# void ImageAlphaCrop(Image *image, float threshold);                                                # Crop image depending on alpha value
# void ImageAlphaClear(Image *image, Color color, float threshold);                                  # Clear alpha channel to desired color
# void ImageAlphaMask(Image *image, Image alphaMask);                                                # Apply alpha mask to image
# void ImageAlphaPremultiply(Image *image);                                                          # Premultiply alpha channel
# void ImageBlurGaussian(Image *image, int blurSize);                                                # Apply Gaussian blur using a box blur approximation
# void ImageResize(Image *image, int newWidth, int newHeight);                                       # Resize image (Bicubic scaling algorithm)
# void ImageResizeNN(Image *image, int newWidth,int newHeight);                                      # Resize image (Nearest-Neighbor scaling algorithm)
# void ImageResizeCanvas(Image *image, int newWidth, int newHeight, int offsetX, int offsetY, Color fill);  # Resize canvas and fill with color
# void ImageMipmaps(Image *image);                                                                   # Compute all mipmap levels for a provided image
# void ImageDither(Image *image, int rBpp, int gBpp, int bBpp, int aBpp);                            # Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
# void ImageFlipVertical(Image *image);                                                              # Flip image vertically
# void ImageFlipHorizontal(Image *image);                                                            # Flip image horizontally
# void ImageRotateCW(Image *image);                                                                  # Rotate image clockwise 90deg
# void ImageRotateCCW(Image *image);                                                                 # Rotate image counter-clockwise 90deg
# void ImageColorTint(Image *image, Color color);                                                    # Modify image color: tint
# void ImageColorInvert(Image *image);                                                               # Modify image color: invert
# void ImageColorGrayscale(Image *image);                                                            # Modify image color: grayscale
# void ImageColorContrast(Image *image, float contrast);                                             # Modify image color: contrast (-100 to 100)
# void ImageColorBrightness(Image *image, int brightness);                                           # Modify image color: brightness (-255 to 255)
# void ImageColorReplace(Image *image, Color color, Color replace);                                  # Modify image color: replace color
# Color *LoadImageColors(Image image);                                                               # Load color data from image as a Color array (RGBA - 32bit)
# Color *LoadImagePalette(Image image, int maxPaletteSize, int *colorCount);                         # Load colors palette from image as a Color array (RGBA - 32bit)
# void UnloadImageColors(Color *colors);                                                             # Unload color data loaded with LoadImageColors()
# void UnloadImagePalette(Color *colors);                                                            # Unload colors palette loaded with LoadImagePalette()
# Rectangle GetImageAlphaBorder(Image image, float threshold);                                       # Get image alpha border rectangle
# Color GetImageColor(Image image, int x, int y);                                                    # Get image pixel color at (x, y) position

# Image drawing functions
# NOTE: Image software-rendering functions (CPU)
imageClearBackground ⇐ "ImageClearBackground"_R(P image)‿color # *dst # Clear image background with given color
# ImageDrawPixel(Image *dst, int posX, int posY, Color color);                                  # Draw pixel within an image
# ImageDrawPixelV(Image *dst, Vector2 position, Color color);                                   # Draw pixel within an image (Vector version)
# ImageDrawLine(Image *dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color); # Draw line within an image
# ImageDrawLineV(Image *dst, Vector2 start, Vector2 end, Color color);                          # Draw line within an image (Vector version)
# ImageDrawCircle(Image *dst, int centerX, int centerY, int radius, Color color);               # Draw a filled circle within an image
# ImageDrawCircleV(Image *dst, Vector2 center, int radius, Color color);                        # Draw a filled circle within an image (Vector version)
# ImageDrawCircleLines(Image *dst, int centerX, int centerY, int radius, Color color);          # Draw circle outline within an image
# ImageDrawCircleLinesV(Image *dst, Vector2 center, int radius, Color color);                   # Draw circle outline within an image (Vector version)
# ImageDrawRectangle(Image *dst, int posX, int posY, int width, int height, Color color);       # Draw rectangle within an image
# ImageDrawRectangleV(Image *dst, Vector2 position, Vector2 size, Color color);                 # Draw rectangle within an image (Vector version)
# ImageDrawRectangleRec(Image *dst, Rectangle rec, Color color);                                # Draw rectangle within an image
# ImageDrawRectangleLines(Image *dst, Rectangle rec, int thick, Color color);                   # Draw rectangle lines within an image
# ImageDraw(Image *dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint);             # Draw a source image within a destination image (tint applied to source)
# ImageDrawText(Image *dst, const char *text, int posX, int posY, int fontSize, Color color);   # Draw text (using default font) within an image (destination)
# ImageDrawTextEx(Image *dst, Font font, const char *text, Vector2 position, float fontSize, float spacing, Color tint); # Draw text (custom sprite font) within an image (destination)

# Texture loading functions
# NOTE: These functions require GPU access
loadTexture          ⇐ texture       "LoadTexture"         _R str             # fileName                         # Load texture from file into GPU memory (VRAM)
loadTextureFromImage ⇐ texture       "LoadTextureFromImage"_R image                                              # Load texture from image data
loadTextureCubemap   ⇐ texture       "LoadTextureCubemap"  _R image‿i         # textureCubemap ""_R image layout # Load cubemap from image, multiple image cubemap layouts supported
loadRenderTexture    ⇐ renderTexture "LoadRenderTexture"   _R i‿i             # width height                     # Load texture for rendering (framebuffer)
isTextureReady       ⇐ "i8"          "IsTextureReady"      _R texture                                            # Check if a texture is ready
unloadTexture        ⇐               "UnloadTexture"       _R texture                                            # Unload texture from GPU memory (VRAM)
isRenderTextureReady ⇐ "i8"          "IsRenderTextureReady"_R renderTexture2D # target                           # Check if a render texture is ready
unloadRenderTexture  ⇐               "UnloadRenderTexture" _R renderTexture   # target                           # Unload render texture from GPU memory (VRAM)
updateTexture        ⇐               "UpdateTexture"       _R texture‿ptr                                       # Update GPU texture with new data
updateTextureRec     ⇐               "UpdateTextureRec"    _R texture‿rectangle‿ptr                             # Update GPU texture rectangle with new data

# Texture configuration functions
#GenTextureMipmaps(Texture2D *texture);                                                        # Generate GPU mipmaps for a texture
#SetTextureFilter(Texture2D texture, int filter);                                              # Set texture scaling filter mode
#SetTextureWrap(Texture2D texture, int wrap);                                                  # Set texture wrapping mode

# Texture drawing functions
drawTexture       ⇐ "DrawTexture"      _R texture‿i‿i‿color                       # texture posX posY tint                       # Draw a Texture2D
drawTextureV      ⇐ "DrawTextureV"     _R texture‿v2‿color                        # texture position tint                        # Draw a Texture2D with position defined as Vector2
drawTextureEx     ⇐ "DrawTextureEx"    _R texture‿v2‿f‿f‿color                    # texture position rotation scale tint         # Draw a Texture2D with extended parameters
drawTextureRec    ⇐ "DrawTextureRec"   _R texture‿rectangle‿v2‿color              # texture source position tint                 # Draw a part of a texture defined by a rectangle
drawTexturePro    ⇐ "DrawTexturePro"   _R texture‿rectangle ‿rectangle‿v2‿f‿color # texture source dest origin rotation tint     # Draw a part of a texture defined by a rectangle with 'pro' parameters
drawTextureNPatch ⇐ "DrawTextureNPatch"_R texture‿nPatchInfo‿rectangle‿v2‿f‿color # texture nPatchInfo dest origin rotation tint # Draws a texture (or part of it) that stretches or shrinks nicely

# Color/pixel related functions
#Color Fade(Color color, float alpha);                                 # Get color with alpha applied, alpha goes from 0.0f to 1.0f
#int ColorToInt(Color color);                                          # Get hexadecimal value for a Color
#Vector4 ColorNormalize(Color color);                                  # Get Color normalized as float [0..1]
#Color ColorFromNormalized(Vector4 normalized);                        # Get Color from normalized values [0..1]
#Vector3 ColorToHSV(Color color);                                      # Get HSV values for a Color, hue [0..360], saturation/value [0..1]
#Color ColorFromHSV(float hue, float saturation, float value);         # Get a Color from HSV values, hue [0..360], saturation/value [0..1]
#Color ColorTint(Color color, Color tint);                             # Get color multiplied with another color
#Color ColorBrightness(Color color, float factor);                     # Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
#Color ColorContrast(Color color, float contrast);                     # Get color with contrast correction, contrast values between -1.0f and 1.0f
colorAlpha ⇐ color "ColorAlpha"_R color‿f # color alpha # Get color with alpha applied, alpha goes from 0.0f to 1.0f
#Color ColorAlphaBlend(Color dst, Color src, Color tint);              # Get src alpha-blended into dst color with tint
#Color GetColor(unsigned int hexValue);                                # Get Color structure from hexadecimal value
#Color GetPixelColor(void *srcPtr, int format);                        # Get Color from a source pixel pointer of certain format
#void SetPixelColor(void *dstPtr, Color color, int format);            # Set color formatted into destination pixel pointer
#int GetPixelDataSize(int width, int height, int format);              # Get pixel data size in bytes for certain format

#------------------------------------------------------------------------------------
# Font Loading and Text Drawing Functions (Module: text)
#------------------------------------------------------------------------------------

# Font loading/unloading functions
getFontDefault    ⇐ font "GetFontDefault"_R@                                                          # Get the default Font
loadFont          ⇐ font "LoadFont"         _R str           # fileName                               # Load font from file into GPU memory (VRAM)
loadFontEx        ⇐ font "LoadFontEx"       _R str‿i‿(P i)‿i     # fileName fontSize fontChars glyphCount # Load font from file with extended parameters, use NULL for fontChars and 0 for glyphCount to load the default character set
loadFontFromImage ⇐ font "LoadFontFromImage"_R image‿color‿i # image color(key?) firstChar            # Load font from Image (XNA style)
#Font LoadFontFromMemory(const char *fileType, const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int glyphCount); # Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
#bool IsFontReady(Font font);                                                          # Check if a font is ready
#GlyphInfo *LoadFontData(const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int glyphCount, int type); # Load font data for further use
#Image GenImageFontAtlas(const GlyphInfo *chars, Rectangle **recs, int glyphCount, int fontSize, int padding, int packMethod); # Generate image font atlas using chars info
#void UnloadFontData(GlyphInfo *chars, int glyphCount);                                # Unload font chars info data (RAM)
unloadFont        ⇐      "UnloadFont"       _R font                                                   # Unload font from GPU memory (VRAM)
#bool ExportFontAsCode(Font font, const char *fileName);                               # Export font as code file, returns true on success

# Text drawing
drawFPS            ⇐ "DrawFPS"           _R i‿i                         # posX posY                                                # Draw current FPS
drawText           ⇐ "DrawText"          _R str‿i‿i‿i‿color             # text posX posY fontSize color                            # Draw text (using default font)
drawTextEx         ⇐ "DrawTextEx"        _R font‿str‿v2‿f‿f‿color       # font text position spacing fontSize tint                 # Draw text using font and additional parameters     # Warning, does not support unicode
drawTextPro        ⇐ "DrawTextPro"       _R font‿str‿v2‿v2‿f‿f‿f‿color  # font text position origin rotation fontSize spacing tint # Draw text using Font and pro parameters (rotation) # Warning, does not support unicode
drawTextCodepoint  ⇐ "DrawTextCodepoint" _R font‿i‿v2‿f‿color           # font codepoint position fontSize tint                    # Draw one character (codepoint)
drawTextCodepoints ⇐ "DrawTextCodepoints"_R font‿(P i)‿i‿v2‿f‿f‿color # font codepoints count position fontSize spacing tint     # Draw multiple character (codepoint)

# Text font info functions
measureText      ⇐ i         "MeasureText"     _R str‿i        # text fontSize              # Measure string width for default font
measureTextEx    ⇐ v2        "MeasureTextEx"   _R font‿str‿f‿f # font text fontSize spacing # Measure string size for Font
getGlyphIndex    ⇐ i         "GetGlyphIndex"   _R font‿i       # font codepoint             # Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
getGlyphInfo     ⇐ glyphInfo "GetGlyphInfo"    _R font‿i       # font codepoint             # Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
getGlyphAtlasRec ⇐ rectangle "GetGlyphAtlasRec"_R font‿i       # font codepoint             # Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found

# Text codepoints management functions (unicode characters)
# char *LoadUTF8(const int *codepoints, int length);                # Load UTF-8 text encoded from codepoints array
# void UnloadUTF8(char *text);                                      # Unload UTF-8 text encoded from codepoints array
# int *LoadCodepoints(const char *text, int *count);                # Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
# void UnloadCodepoints(int *codepoints);                           # Unload codepoints data from memory
# int GetCodepointCount(const char *text);                          # Get total number of codepoints in a UTF-8 encoded string
# int GetCodepoint(const char *text, int *codepointSize);           # Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
# int GetCodepointNext(const char *text, int *codepointSize);       # Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
# int GetCodepointPrevious(const char *text, int *codepointSize);   # Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
# const char *CodepointToUTF8(int codepoint, int *utf8Size);        # Encode one codepoint into UTF-8 byte array (array length returned as parameter)

# Text strings management functions (no UTF-8 strings, only byte chars)
# NOTE: Some strings allocate memory internally for returned strings, just be careful!
# int TextCopy(char *dst, const char *src);                                             # Copy one string to another, returns bytes copied
# bool TextIsEqual(const char *text1, const char *text2);                               # Check if two text string are equal
# unsigned int TextLength(const char *text);                                            # Get text length, checks for '\0' ending
# const char *TextFormat(const char *text, ...);                                        # Text formatting with variables (sprintf() style)
# const char *TextSubtext(const char *text, int position, int length);                  # Get a piece of a text string
# char *TextReplace(char *text, const char *replace, const char *by);                   # Replace text string (WARNING: memory must be freed!)
# char *TextInsert(const char *text, const char *insert, int position);                 # Insert text in a position (WARNING: memory must be freed!)
# const char *TextJoin(const char **textList, int count, const char *delimiter);        # Join text strings with delimiter
# const char **TextSplit(const char *text, char delimiter, int *count);                 # Split text into multiple strings
# void TextAppend(char *text, const char *append, int *position);                       # Append text at specific position and move cursor!
# int TextFindIndex(const char *text, const char *find);                                # Find first text occurrence within a string
# const char *TextToUpper(const char *text);                      # Get upper case version of provided string
# const char *TextToLower(const char *text);                      # Get lower case version of provided string
# const char *TextToPascal(const char *text);                     # Get Pascal case notation version of provided string
# int TextToInteger(const char *text);                            # Get integer value from text (negative values not supported)

#------------------------------------------------------------------------------------
# Basic 3d Shapes Drawing Functions (Module: models)
#------------------------------------------------------------------------------------

# Basic geometric 3D shapes drawing functions
drawLine3D          ⇐ "DrawLine3D"         _R v3‿v3‿color         # startPos endPos color                              # Draw a line in 3D world space
drawPoint3D         ⇐ "DrawPoint3D"        _R v3‿color            # position color                                     # Draw a point in 3D space, actually a small line
drawCircle3D        ⇐ "DrawCircle3D"       _R v3‿f‿v3‿f‿color     # center radius rotationAxis rotationAngle color     # Draw a circle in 3D world space
drawTriangle3D      ⇐ "DrawTriangle3D"     _R v3‿v3‿v3‿color      # v1 v2 v3 color                                     # Draw a color-filled triangle (vertex in counter-clockwise order!)
drawTriangleStrip3D ⇐ "DrawTriangleStrip3D"_R (P v3)‿i‿color    # *points pointCount color                           # Draw a triangle strip defined by points
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
loadModel           ⇐ model       "LoadModel"          _R str  # fileName # Load model from files (meshes and materials)
loadModelFromMesh   ⇐ model       "LoadModelFromMesh"  _R mesh            # Load model from generated mesh (default material)
isModelReady        ⇐ "i8"        "IsModelReady"       _R model           # Check if a model is ready
unloadModel         ⇐             "UnloadModel"        _R model           # Unload model (including meshes) from memory (RAM and/or VRAM)
getModelBoundingBox ⇐ boundingBox "GetModelBoundingBox"_R model           # Compute model bounding box limits (considers all meshes)

# Model drawing functions
drawModel        ⇐ "DrawModel"       _R model‿v3‿f‿color # model position scale tint              # Draw a model (with texture if set)
drawModelEx      ⇐ "DrawModelEx"     _R model‿v3‿v3‿f‿v3‿color # model position rotationAxis rotationAngle scale tint # Draw a model with extended parameters
drawModelWires   ⇐ "DrawModelWires"  _R model‿v3‿f‿color # model position scale tint          # Draw a model wires (with texture if set)
drawModelWiresEx ⇐ "DrawModelWiresEx"_R model‿v3‿v3‿f‿v3‿color # model position rotationAxis rotationAngle scale tint # Draw a model wires (with texture if set) with extended parameters
drawBoundingBox  ⇐ "DrawBoundingBox" _R boundingBox‿color # box color                                   # Draw bounding box (wires)
drawBillboard    ⇐ "DrawBillboard"   _R camera3d‿texture‿v3‿f‿color # camera texture position size tint   # Draw a billboard texture
drawBillboardRec ⇐ "DrawBillboardRec"_R camera3d‿texture‿rectangle‿v3‿v2‿color # camera texture source position size tint # Draw a billboard texture defined by source
drawBillboardPro ⇐ "DrawBillboardPro"_R camera3d‿texture‿rectangle‿v3‿v3‿v2‿v2‿f‿color # camera texture source position up size origin rotation tint # Draw a billboard texture defined by source and rotation

# Mesh management functions
#void UploadMesh(Mesh *mesh, bool dynamic);                                            # Upload mesh vertex data in GPU and provide VAO/VBO ids
#void UpdateMeshBuffer(Mesh mesh, int index, const void *data, int dataSize, int offset); # Update mesh vertex data in GPU for a specific buffer index
#void UnloadMesh(Mesh mesh);                                                           # Unload mesh data from CPU and GPU
#void DrawMesh(Mesh mesh, Material material, Matrix transform);                        # Draw a 3d mesh with material and transform
#void DrawMeshInstanced(Mesh mesh, Material material, const Matrix *transforms, int instances); # Draw multiple mesh instances with material and different transforms
#bool ExportMesh(Mesh mesh, const char *fileName);                                     # Export mesh data to file, returns true on success
#BoundingBox GetMeshBoundingBox(Mesh mesh);                                            # Compute mesh bounding box limits
#void GenMeshTangents(Mesh *mesh);                                                     # Compute mesh tangents

# Mesh generation functions
#Mesh GenMeshPoly(int sides, float radius);                                            # Generate polygonal mesh
genMeshPlane ⇐ mesh "GenMeshPlane"_R f‿f‿i‿i # width length resX resZ                         # Generate plane mesh (with subdivisions)
genMeshCube  ⇐ mesh "GenMeshCube" _R f‿f‿f   # width height length                            # Generate cuboid mesh
#Mesh GenMeshSphere(float radius, int rings, int slices);                              # Generate sphere mesh (standard sphere)
#Mesh GenMeshHemiSphere(float radius, int rings, int slices);                          # Generate half-sphere mesh (no bottom cap)
#Mesh GenMeshCylinder(float radius, float height, int slices);                         # Generate cylinder mesh
#Mesh GenMeshCone(float radius, float height, int slices);                             # Generate cone/pyramid mesh
#Mesh GenMeshTorus(float radius, float size, int radSeg, int sides);                   # Generate torus mesh
#Mesh GenMeshKnot(float radius, float size, int radSeg, int sides);                    # Generate trefoil knot mesh
#Mesh GenMeshHeightmap(Image heightmap, Vector3 size);                                 # Generate heightmap mesh from image data
#Mesh GenMeshCubicmap(Image cubicmap, Vector3 cubeSize);                               # Generate cubes-based map mesh from image data

# Material loading/unloading functions
#Material *LoadMaterials(const char *fileName, int *materialCount);                    # Load materials from model file
#Material LoadMaterialDefault(void);                                                   # Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
#bool IsMaterialReady(Material material);                                              # Check if a material is ready
#void UnloadMaterial(Material material);                                               # Unload material from GPU memory (VRAM)
#void SetMaterialTexture(Material *material, int mapType, Texture2D texture);          # Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
#void SetModelMeshMaterial(Model *model, int meshId, int materialId);                  # Set material for a mesh

# Model animations loading/unloading functions
#modelAnimation *LoadModelAnimations(const char *fileName, unsigned int *animCount);   # Load model animations from file
#void UpdateModelAnimation(Model model, ModelAnimation anim, int frame);               # Update model animation pose
#void UnloadModelAnimation(ModelAnimation anim);                                       # Unload animation data
#void UnloadModelAnimations(ModelAnimation *animations, unsigned int count);           # Unload animation array data
#bool IsModelAnimationValid(Model model, ModelAnimation anim);                         # Check model animation skeleton match

# Collision detection functions
#bool CheckCollisionSpheres(Vector3 center1, float radius1, Vector3 center2, float radius2);   # Check collision between two spheres
#bool CheckCollisionBoxes(BoundingBox box1, BoundingBox box2);                                 # Check collision between two bounding boxes
#bool CheckCollisionBoxSphere(BoundingBox box, Vector3 center, float radius);                  # Check collision between box and sphere
#RayCollision GetRayCollisionSphere(Ray ray, Vector3 center, float radius);                    # Get collision info between ray and sphere
#RayCollision GetRayCollisionBox(Ray ray, BoundingBox box);                                    # Get collision info between ray and box
#RayCollision GetRayCollisionMesh(Ray ray, Mesh mesh, Matrix transform);                       # Get collision info between ray and mesh
#RayCollision GetRayCollisionTriangle(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3);            # Get collision info between ray and triangle
#RayCollision GetRayCollisionQuad(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4);    # Get collision info between ray and quad


#------------------------------------------------------------------------------------
# Audio Loading and Playing Functions (Module: audio)
#------------------------------------------------------------------------------------

# Audio device management functions
#void InitAudioDevice(void);                                     # Initialize audio device and context
#void CloseAudioDevice(void);                                    # Close the audio device and context
#bool IsAudioDeviceReady(void);                                  # Check if audio device has been initialized successfully
#void SetMasterVolume(float volume);                             # Set master volume (listener)

# Wave/Sound loading/unloading functions
#Wave LoadWave(const char *fileName);                            # Load wave data from file
#Wave LoadWaveFromMemory(const char *fileType, const unsigned char *fileData, int dataSize); # Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
#bool IsWaveReady(Wave wave);                                    # Checks if wave data is ready
#Sound LoadSound(const char *fileName);                          # Load sound from file
#Sound LoadSoundFromWave(Wave wave);                             # Load sound from wave data
#bool IsSoundReady(Sound sound);                                 # Checks if a sound is ready
#void UpdateSound(Sound sound, const void *data, int sampleCount); # Update sound buffer with new data
#void UnloadWave(Wave wave);                                     # Unload wave data
#void UnloadSound(Sound sound);                                  # Unload sound
#bool ExportWave(Wave wave, const char *fileName);               # Export wave data to file, returns true on success
#bool ExportWaveAsCode(Wave wave, const char *fileName);         # Export wave sample data to code (.h), returns true on success

# Wave/Sound management functions
#void PlaySound(Sound sound);                                    # Play a sound
#void StopSound(Sound sound);                                    # Stop playing a sound
#void PauseSound(Sound sound);                                   # Pause a sound
#void ResumeSound(Sound sound);                                  # Resume a paused sound
#bool IsSoundPlaying(Sound sound);                               # Check if a sound is currently playing
#void SetSoundVolume(Sound sound, float volume);                 # Set volume for a sound (1.0 is max level)
#void SetSoundPitch(Sound sound, float pitch);                   # Set pitch for a sound (1.0 is base level)
#void SetSoundPan(Sound sound, float pan);                       # Set pan for a sound (0.5 is center)
#Wave WaveCopy(Wave wave);                                       # Copy a wave to a new wave
#void WaveCrop(Wave *wave, int initSample, int finalSample);     # Crop a wave to defined samples range
#void WaveFormat(Wave *wave, int sampleRate, int sampleSize, int channels); # Convert wave data to desired format
#float *LoadWaveSamples(Wave wave);                              # Load samples data from wave as a 32bit float data array
#void UnloadWaveSamples(float *samples);                         # Unload samples data loaded with LoadWaveSamples()

# Music management functions
#Music LoadMusicStream(const char *fileName);                    # Load music stream from file
#Music LoadMusicStreamFromMemory(const char *fileType, const unsigned char *data, int dataSize); # Load music stream from data
#bool IsMusicReady(Music music);                                 # Checks if a music stream is ready
#void UnloadMusicStream(Music music);                            # Unload music stream
#void PlayMusicStream(Music music);                              # Start music playing
#bool IsMusicStreamPlaying(Music music);                         # Check if music is playing
#void UpdateMusicStream(Music music);                            # Updates buffers for music streaming
#void StopMusicStream(Music music);                              # Stop music playing
#void PauseMusicStream(Music music);                             # Pause music playing
#void ResumeMusicStream(Music music);                            # Resume playing paused music
#void SeekMusicStream(Music music, float position);              # Seek music to a position (in seconds)
#void SetMusicVolume(Music music, float volume);                 # Set volume for music (1.0 is max level)
#void SetMusicPitch(Music music, float pitch);                   # Set pitch for a music (1.0 is base level)
#void SetMusicPan(Music music, float pan);                       # Set pan for a music (0.5 is center)
#float GetMusicTimeLength(Music music);                          # Get music time length (in seconds)
#float GetMusicTimePlayed(Music music);                          # Get current music time played (in seconds)

# AudioStream management functions
#AudioStream LoadAudioStream(unsigned int sampleRate, unsigned int sampleSize, unsigned int channels); # Load audio stream (to stream raw audio pcm data)
#bool IsAudioStreamReady(AudioStream stream);                    # Checks if an audio stream is ready
#void UnloadAudioStream(AudioStream stream);                     # Unload audio stream and free memory
#void UpdateAudioStream(AudioStream stream, const void *data, int frameCount); # Update audio stream buffers with data
#bool IsAudioStreamProcessed(AudioStream stream);                # Check if any audio stream buffers requires refill
#void PlayAudioStream(AudioStream stream);                       # Play audio stream
#void PauseAudioStream(AudioStream stream);                      # Pause audio stream
#void ResumeAudioStream(AudioStream stream);                     # Resume audio stream
#bool IsAudioStreamPlaying(AudioStream stream);                  # Check if audio stream is playing
#void StopAudioStream(AudioStream stream);                       # Stop audio stream
#void SetAudioStreamVolume(AudioStream stream, float volume);    # Set volume for audio stream (1.0 is max level)
#void SetAudioStreamPitch(AudioStream stream, float pitch);      # Set pitch for audio stream (1.0 is base level)
#void SetAudioStreamPan(AudioStream stream, float pan);          # Set pan for audio stream (0.5 is centered)
#void SetAudioStreamBufferSizeDefault(int size);                 # Default size for new audio streams
#void SetAudioStreamCallback(AudioStream stream, AudioCallback callback);  # Audio thread callback to request new data

#void AttachAudioStreamProcessor(AudioStream stream, AudioCallback processor); # Attach audio stream processor to stream
#void DetachAudioStreamProcessor(AudioStream stream, AudioCallback processor); # Detach audio stream processor from stream

#void AttachAudioMixedProcessor(AudioCallback processor); # Attach audio stream processor to the entire audio pipeline
#void DetachAudioMixedProcessor(AudioCallback processor); # Detach audio stream processor from the entire audio pipeline

#endregion