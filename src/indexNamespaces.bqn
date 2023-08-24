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