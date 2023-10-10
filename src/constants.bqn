⟨
  traceLogLevel
  gamepadButton
  gamepadAxis
  materialMapIndex
  shaderLocationIndex
  shaderUniformDataType
  shaderAttributeDataType
  pixelFormat
  textureFilter
  textureWrap
  cubemapLayout
  fontType
  blendMode
  gesture
  cameraProjection
  nPatchLayout
  color
  bqnFontChars
  rlgl
⟩⇐

traceLogLevel ← { # Trace log level
  all     ⇐ 0  # Display all logs                                                                   
  trace   ⇐ 1  # Trace logging, intended for internal use only                                      
  debug   ⇐ 2  # Debug logging, used for internal debugging, it should be disabled on release builds
  info    ⇐ 3  # Info logging, used for program execution info                                      
  warning ⇐ 4  # Warning logging, used on recoverable failures                                      
  error   ⇐ 5  # Error logging, used on unrecoverable failures                                      
  fatal   ⇐ 6  # Fatal logging, used to abort program: exit(EXIT_FAILURE)                           
  none    ⇐ 7  # Disable logging                                                                    
}
gamepadButton ← { # Gamepad buttons
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
gamepadAxis ← { # Gamepad axis
  left_x        ⇐ 0  # Gamepad left stick X axis                          
  left_y        ⇐ 1  # Gamepad left stick Y axis                          
  right_x       ⇐ 2  # Gamepad right stick X axis                         
  right_y       ⇐ 3  # Gamepad right stick Y axis                         
  left_trigger  ⇐ 4  # Gamepad back trigger left, pressure level: [1..-1] 
  right_trigger ⇐ 5  # Gamepad back trigger right, pressure level: [1..-1]
}
materialMapIndex ← { # Material map index
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
shaderLocationIndex ← { # Shader location index
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
shaderUniformDataType ← { # Shader uniform data type
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
shaderAttributeDataType ← { # Shader attribute data types
  float ⇐ 0  # Shader attribute type: float         
  vec2  ⇐ 1  # Shader attribute type: vec2 (2 float)
  vec3  ⇐ 2  # Shader attribute type: vec3 (3 float)
  vec4  ⇐ 3  # Shader attribute type: vec4 (4 float)
}
pixelFormat ← { # Pixel formats for images
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
textureFilter ← { # Texture parameters: filter mode
  point           ⇐ 0  # No filter, just pixel approximation      
  bilinear        ⇐ 1  # Linear filtering                         
  trilinear       ⇐ 2  # Trilinear filtering (linear with mipmaps)
  anisotropic_4x  ⇐ 3  # Anisotropic filtering 4x                 
  anisotropic_8x  ⇐ 4  # Anisotropic filtering 8x                 
  anisotropic_16x ⇐ 5  # Anisotropic filtering 16x                
}
textureWrap ← { # Texture parameters: wrap mode
  repeat        ⇐ 0  # Repeats texture in tiled mode                         
  clamp         ⇐ 1  # Clamps texture to edge pixel in tiled mode            
  mirror_repeat ⇐ 2  # Mirrors and repeats the texture in tiled mode         
  mirror_clamp  ⇐ 3  # Mirrors and clamps to border the texture in tiled mode
}
cubemapLayout ← { # Cubemap layouts
  auto_detect         ⇐ 0  # Automatically detect layout type                            
  line_vertical       ⇐ 1  # Layout is defined by a vertical line with faces             
  line_horizontal     ⇐ 2  # Layout is defined by a horizontal line with faces           
  cross_three_by_four ⇐ 3  # Layout is defined by a 3x4 cross with cubemap faces         
  cross_four_by_three ⇐ 4  # Layout is defined by a 4x3 cross with cubemap faces         
  panorama            ⇐ 5  # Layout is defined by a panorama image (equirrectangular map)
}
fontType ← { # Font type, defines generation method
  font_default ⇐ 0  # Default font generation, anti-aliased        
  font_bitmap  ⇐ 1  # Bitmap font generation, no anti-aliasing     
  font_sdf     ⇐ 2  # SDF font generation, requires external shader
}
blendMode ← { # Color blending modes (pre-defined)
  alpha             ⇐ 0  # Blend textures considering alpha (default)                                                      
  additive          ⇐ 1  # Blend textures adding colors                                                                    
  multiplied        ⇐ 2  # Blend textures multiplying colors                                                               
  add_colors        ⇐ 3  # Blend textures adding colors (alternative)                                                      
  subtract_colors   ⇐ 4  # Blend textures subtracting colors (alternative)                                                 
  alpha_premultiply ⇐ 5  # Blend premultiplied textures considering alpha                                                  
  custom            ⇐ 6  # Blend textures using custom src/dst factors (use rlSetBlendFactors())                           
  custom_separate   ⇐ 7  # Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
}
gesture ← {
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
cameramode ⇐ {
  custom       ⇐ 0  # Custom camera      
  free         ⇐ 1  # Free camera        
  orbital      ⇐ 2  # Orbital camera     
  first_person ⇐ 3  # First person camera
  third_person ⇐ 4  # Third person camera
}
cameraProjection ← { # Camera projection
  perspective  ⇐ 0  # Perspective projection 
  orthographic ⇐ 1  # Orthographic projection
}
nPatchLayout ← {
  nine_patch             ⇐ 0  # Npatch layout: 3x3 tiles
  three_patch_vertical   ⇐ 1  # Npatch layout: 1x3 tiles
  three_patch_horizontal ⇐ 2  # Npatch layout: 3x1 tiles
}
# NOTE: Every bit registers one state (use it with bit masks)
# By default all flags are set to 0
windowConfigFlags ⇐ {
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
# Useful constants for RLGL
rlgl ← {
  default_batch_buffer_elements   ⇐   8192  # Default internal render batch elements limits
  default_batch_buffers           ⇐      1  # Default number of batch buffers (multi-buffering)
  default_batch_drawcalls         ⇐    256  # Default number of batch draw calls (by state changes: mode, texture)
  default_batch_max_texture_units ⇐      4  # Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
  max_matrix_stack_size           ⇐     32  # Maximum size of internal Matrix stack
  max_shader_locations            ⇐     32  # Maximum number of shader locations supported
  cull_distance_near              ⇐   0.01  # Default projection matrix near cull distance
  cull_distance_far               ⇐ 1000.0  # Default projection matrix far cull distance
}
# list of rgba-format colors for convenience
color ← {
  aliceblue            ⇐ 240‿248‿255‿255
  antiquewhite         ⇐ 250‿235‿215‿255
  aqua                 ⇐ 0  ‿255‿255‿255
  aquamarine           ⇐ 127‿255‿212‿255
  azure                ⇐ 240‿255‿255‿255
  beige                ⇐ 211‿176‿131‿255
  bisque               ⇐ 255‿228‿196‿255
  black                ⇐ 0  ‿0  ‿0  ‿255
  blanchedalmond       ⇐ 255‿235‿205‿255
  blue                 ⇐ 0  ‿121‿241‿255
  blueviolet           ⇐ 138‿43 ‿226‿255
  brown                ⇐ 127‿106‿79 ‿255
  burlywood            ⇐ 222‿184‿135‿255
  cadetblue            ⇐ 95 ‿158‿160‿255
  chartreuse           ⇐ 127‿255‿0  ‿255
  chocolate            ⇐ 210‿105‿30 ‿255
  coral                ⇐ 255‿127‿80 ‿255
  cornflowerblue       ⇐ 100‿149‿237‿255
  cornsilk             ⇐ 255‿248‿220‿255
  crimson              ⇐ 220‿20 ‿60 ‿255
  cyan                 ⇐ 0  ‿255‿255‿255
  darkblue             ⇐ 0  ‿82 ‿172‿255
  darkbrown            ⇐ 76 ‿63 ‿47 ‿255
  darkcyan             ⇐ 0  ‿139‿139‿255
  darkgoldenrod        ⇐ 184‿134‿11 ‿255
  darkGray             ⇐ 80 ‿80 ‿80 ‿255
  darkgreen            ⇐ 0  ‿117‿44 ‿255
  darkkhaki            ⇐ 189‿183‿107‿255
  darkmagenta          ⇐ 139‿0  ‿139‿255
  darkolivegreen       ⇐ 85 ‿107‿47 ‿255
  darkorange           ⇐ 255‿140‿0  ‿255
  darkorchid           ⇐ 153‿50 ‿204‿255
  darkpurple           ⇐ 112‿31 ‿126‿255
  darkred              ⇐ 139‿0  ‿0  ‿255
  darksalmon           ⇐ 230‿150‿122‿255
  darkseagreen         ⇐ 143‿188‿143‿255
  darkslateblue        ⇐ 72 ‿61 ‿139‿255
  darkslategray        ⇐ 47 ‿79 ‿79 ‿255
  darkturquoise        ⇐ 64 ‿206‿209‿255
  darkviolet           ⇐ 148‿0  ‿211‿255
  deeppink             ⇐ 255‿20 ‿147‿255
  deepskyblue          ⇐ 0  ‿191‿255‿255
  dimgray              ⇐ 105‿105‿105‿255
  dodgerblue           ⇐ 30 ‿144‿255‿255
  firebrick            ⇐ 178‿34 ‿34 ‿255
  floralwhite          ⇐ 255‿250‿240‿255
  forestgreen          ⇐ 34 ‿139‿34 ‿255
  fuschia              ⇐ 255‿0  ‿255‿255
  gainsboro            ⇐ 220‿220‿220‿255
  ghostwhite           ⇐ 248‿248‿255‿255
  gold                 ⇐ 255‿203‿0  ‿255
  goldenrod            ⇐ 218‿165‿32 ‿255
  gray                 ⇐ 130‿130‿130‿255
  green                ⇐ 0  ‿228‿48 ‿255
  greenyellow          ⇐ 173‿255‿47 ‿255
  honeydew             ⇐ 240‿255‿240‿255
  hotpink              ⇐ 255‿105‿180‿255
  indianred            ⇐ 205‿92 ‿92 ‿255
  indigo               ⇐ 75 ‿0  ‿130‿255
  ivory                ⇐ 255‿255‿240‿255
  khaki                ⇐ 240‿230‿140‿255
  lavender             ⇐ 230‿230‿250‿255
  lavenderblush        ⇐ 255‿240‿245‿255
  lawngreen            ⇐ 124‿252‿0  ‿255
  lemonshiffon         ⇐ 255‿250‿205‿255
  lightblue            ⇐ 173‿216‿230‿255
  lightcoral           ⇐ 240‿128‿128‿255
  lightcyan            ⇐ 225‿255‿255‿255
  lightgoldenrodyellow ⇐ 250‿250‿210‿255
  lightGray            ⇐ 200‿200‿200‿255
  lightgreen           ⇐ 144‿238‿144‿255
  lightred             ⇐ 255‿102‿102‿255
  lightsalmon          ⇐ 255‿160‿122‿255
  lightseagreen        ⇐ 32 ‿178‿170‿255
  lightskyblue         ⇐ 135‿206‿250‿255
  lightslategray       ⇐ 119‿136‿153‿255
  lightsteelblue       ⇐ 176‿196‿222‿255
  lightyellow          ⇐ 255‿255‿224‿255
  lime                 ⇐ 0  ‿158‿47 ‿255
  limegreen            ⇐ 50 ‿205‿50 ‿255
  linen                ⇐ 250‿240‿230‿255
  magenta              ⇐ 255‿0  ‿255‿255
  maroon               ⇐ 190‿33 ‿55 ‿255
  mediumaquamarine     ⇐ 102‿205‿170‿255
  mediumblue           ⇐ 0  ‿0  ‿205‿255
  mediumorchid         ⇐ 186‿85 ‿211‿255
  mediumpurple         ⇐ 147‿112‿219‿255
  mediumseagreen       ⇐ 60 ‿179‿113‿255
  mediumslateblue      ⇐ 123‿104‿238‿255
  mediumspringgreen    ⇐ 0  ‿250‿154‿255
  mediumturquoise      ⇐ 72 ‿209‿204‿255
  mediumvioletred      ⇐ 199‿21 ‿133‿255
  midnightblue         ⇐ 25 ‿25 ‿112‿255
  mintcream            ⇐ 245‿255‿250‿255
  mistyrose            ⇐ 255‿228‿225‿255
  moccasin             ⇐ 255‿228‿181‿255
  navajowhite          ⇐ 255‿228‿181‿255
  navy                 ⇐ 0  ‿0  ‿128‿255
  oldlace              ⇐ 253‿245‿230‿255
  olive                ⇐ 128‿128‿0  ‿255
  olivedrab            ⇐ 107‿142‿35 ‿255
  orange               ⇐ 255‿161‿0  ‿255
  orangered            ⇐ 255‿69 ‿0  ‿255
  orchid               ⇐ 218‿112‿214‿255
  palegoldenrod        ⇐ 238‿232‿170‿255
  palegreen            ⇐ 152‿251‿152‿255
  paleturquoise        ⇐ 175‿238‿238‿255
  palevioletred        ⇐ 219‿112‿147‿255
  papayawhip           ⇐ 255‿239‿213‿255
  peachpuff            ⇐ 255‿218‿185‿255
  peru                 ⇐ 205‿133‿63 ‿255
  pink                 ⇐ 255‿109‿194‿255
  plum                 ⇐ 221‿160‿221‿255
  powderblue           ⇐ 176‿224‿230‿255
  purple               ⇐ 200‿122‿255‿255
  raywhite             ⇐ 245‿245‿245‿255
  red                  ⇐ 230‿41 ‿55 ‿255
  rosybrown            ⇐ 188‿143‿143‿255
  royalblue            ⇐ 65 ‿105‿225‿255
  saddlebrown          ⇐ 139‿69 ‿19 ‿255
  salmon               ⇐ 250‿128‿114‿255
  sandybrown           ⇐ 244‿164‿96 ‿255
  seagreen             ⇐ 46 ‿139‿87 ‿255
  seashell             ⇐ 255‿248‿238‿255
  sienna               ⇐ 160‿82 ‿45 ‿255
  silver               ⇐ 192‿192‿192‿255
  skyblue              ⇐ 102‿191‿255‿255
  slateblue            ⇐ 106‿90 ‿205‿255
  slategray            ⇐ 112‿128‿144‿255
  snow                 ⇐ 255‿250‿250‿255
  springgreen          ⇐ 0  ‿255‿127‿255
  steelblue            ⇐ 70 ‿130‿180‿255
  tan                  ⇐ 210‿180‿140‿255
  teal                 ⇐ 0  ‿128‿128‿255
  thistle              ⇐ 216‿191‿216‿255
  tomato               ⇐ 255‿99 ‿71 ‿255
  transparent          ⇐ 0  ‿0  ‿0  ‿0
  turquoise            ⇐ 64 ‿224‿208‿255
  violet               ⇐ 135‿60 ‿190‿255
  wheat                ⇐ 245‿222‿179‿255
  white                ⇐ 255‿255‿255‿255
  whitesmoke           ⇐ 245‿245‿245‿255
  yellow               ⇐ 253‿249‿0  ‿255
  yellowgreen          ⇐ 154‿205‿50 ‿255
}
# Valid characters in the BQN font  # Sorce of font and chars: https://dzaima.github.io/BQN386/
bqnFontChars ← "!""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſƆƐƒƖƩǍǎǏǐǑǒǓǔǝǢǣǦǧǨǩǰǴǵǸǹǺǻǼǽǾǿȞȟȦȧȨȩȮȯȲȳȷɐɑɒɔɘəɛɜɩʃˆ˘˙˜˝̀́̂̃̄̅̆Ͷͷͻͼͽ;ͿΆ·ΈΉΊΌΎΏΐΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩΪΫάέήίΰαβγδεζηθικλμνξοπρςστυφχψωϊϋόύώϕϖϜϝϱϲϳϴϵ϶ϷϸϹϼϽϾϿЀЁЂЃЄЅІЇЈЌЍЎЏАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяѐёѓєѕіїјўᐵᑈ–—―‖‗‘’‚‛“”„‟†‡•…‰‹›‼‽‿⁄⁰ⁱ⁲⁳⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎₧€ℝ™←↑→↓↔↕↖↗↘↙↩↶↷⇐⇧∅∆∇∉∊∎∏∐∑−∓∔∕∖∗∘∙√∛∜∞∣∥∧∨∩∪∫∵∼∾≈≉≍≠≡≢≣≤≥⊂⊃⊆⊇⊏⊐⊑⊒⊔⊖⊘⊙⊚⊛⊝⊢⊣⊤⊥⊸⊻⊼⊽⋄⋅⋆⋈⋔⌈⌉⌊⌋⌜⌦⌫⌶⌷⌸⌹⌺⌻⌼⌽⌾⌿⍀⍁⍂⍃⍄⍅⍆⍇⍈⍉⍊⍋⍌⍍⍎⍏⍐⍑⍒⍓⍔⍕⍖⍗⍘⍙⍚⍛⍜⍝⍞⍟⍠⍡⍢⍣⍤⍥⍦⍧⍨⍩⍪⍫⍬⍭⍮⍯⍰⍱⍲⍳⍴⍵⍶⍷⍸⍹⍺⎉⎊⎕⎶⏎␀ⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏⓐⓑⓒⓓⓔⓕⓖⓗⓘⓙⓚⓛⓜⓝⓞⓟⓠⓡⓢⓣⓤⓥⓦⓧⓨⓩ─━│┃┌┍┎┏┐┑┒┓└┕┖┗┘┙┚┛├┝┞┟┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┰┱┲┳┴┵┶┷┸┹┺┻┼┽┾┿╀╁╂╃╄╅╆╇╈╉╊╋═║╔╗╚╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬╸╹╺╻╼╽╾╿▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▯▲▼◇◊○◎◦◯◴◵◶◷♀♂♔♕♖♗♘♙♚♛♜♝♞♟♠♡♢♣♤♥♦♧⚇⟜⟦⟧⟨⟩⥊⥌⦃⦄⦅⦆⧵⬫𝔽𝔾𝕊𝕎𝕏𝕗𝕘𝕣𝕤𝕨𝕩"