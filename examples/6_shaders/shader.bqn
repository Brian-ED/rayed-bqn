# /*******************************************************************************************
# *
# *   raylib [shaders] example - basic lighting
# *
# *   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
# *         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
# *
# *   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
# *
# *   Example originally created with raylib 3.0, last time updated with raylib 4.2
# *
# *   Example contributed by Chris Camacho (@codifies) and reviewed by Ramon Santamaria (@raysan5)
# *
# *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
# *   BSD-like license that allows static linking with closed source software
# *
# *   Copyright (c) 2019-2024 Chris Camacho (@codifies) and Ramon Santamaria (@raysan5)
# *
# ********************************************************************************************/

P ← •term.Flush∘@∘•Show⊸⊢

# depending on rlgl version, you can set this to 100, 120, and 330
glslVersion ← 330

⟨
  color, window, draw, low, key
  rf⇐rayffi, rm⇐raymath
⟩ ← rl ← •Import "../../raylib.bqn"
rlights ← •Import "rlights.bqn"

cameraIndex ← {
  position   ⇐ 0 # Camera position
  target     ⇐ 1 # Camera target it looks-at
  up         ⇐ 2 # Camera up vector (rotation over its axis)
  fovy       ⇐ 3 # Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
  projection ⇐ 4 # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

shaderIndex ← { # Shader
  id   ⇐ 0 # u     # Shader program id
  locs ⇐ 1 # "*"∾i # Shader locations array (RL_MAX_SHADER_LOCATIONS)
}

modelIndex ← { # Model, meshes, materials and animation data
  transform     ⇐ 0 # matrix         # Local transform matrix
  meshCount     ⇐ 1 # i              # Number of meshes
  materialCount ⇐ 2 # i              # Number of materials
  meshes        ⇐ 3 # "*"∾mesh       # Meshes array
  materials     ⇐ 4 # "*"∾material   # Materials array
  meshMaterial  ⇐ 5 # "*"∾i          # Mesh material number
  boneCount     ⇐ 6 # i              # Number of bones
  bones         ⇐ 7 # "*"∾boneInfo   # Bones information (skeleton)
  bindPose      ⇐ 8 # "*"∾transform  # Bones base transformation (pose)
}

materialIndex ⇐ ⟨ # Material, includes shader and maps
  shader ⇐ 0 # shader          # Material shader
  maps   ⇐ 1 # "*"∾materialMap # Material maps array (MAX_MATERIAL_MAPS)
  params ⇐ 2 # "[4]"∾f         # Material generic parameters (if required)
⟩

#------------------------------------------------------------------------------------
# Program main entry point
#--------------------------------------------------------------------------------------

rf.SetConfigFlags rf.configFlags.flag_msaa_4x_hint  # Enable Multi Sampling Anti Aliasing 4x (if available)

# sets window size to half the monitor size
window.SetSize 0.5

{𝕤
  # Define the camera to look into our 3d world
  camera ← ⟨
    2‿4  ‿6 # Camera position
    0‿0.5‿0 # Camera looking at point
    0‿1  ‿0 # Camera up vector (rotation towards target)
    45      # Camera field-of-view Y
    rf.cameraProjection.camera_perspective # Camera projection type
  ⟩

  # Load plane model from a generated mesh
  model ← rf.LoadModelFromMesh rf.GenMeshPlane 10‿10‿3‿3
  cube  ← rf.LoadModelFromMesh rf.GenMeshCube  2 ‿4 ‿2

  # Load basic lighting shader
  shader ← rf.LoadShader "vs"‿"fs"∾˜¨<"shaders/glsl"∾(•Repr glslVersion)∾"/lighting."

  # Get some required shader locations
  {
    locsPtr ← shaderIndex.locs⊑shader
    movedPtr ← rf.shaderLocationIndex.shader_loc_vector_view low.MovePtr 𝕩
    movedPtr low.ReadI32 ⋈rf.GetShaderLocation shader‿"viewPos"
  }
  # Ambient light level (some basic lighting)
  ambientLoc ← rf.GetShaderLocation shader‿"ambient"
  
  F32ToI8 ← (@•FFI"*:i8"‿"memcpy"‿"&i8"‿"*f32"‿"u64"){1⊑𝔽⟨(4×≠𝕩)⥊0, 𝕩, 4×≠𝕩⟩}
  {
    ptr ← rf.MemAlloc 4×4
    (F32ToI8 4⥊1) low.ReadI8 ptr
    rf.SetShaderValue⟨shader, ambientLoc, ptr, rf.shaderUniformDataType.shader_uniform_vec4⟩
  }

  # Assign out lighting shader to model
  {
    matsPtr ← modelIndex.materials⊑model
    firstMatPtr ← 0 low.MovePtr matsPtr
    # write each shader value
    ⟨(2⋆32){𝕨⊸|⌾((𝕨÷2)⊸+)𝕩} shaderIndex.id⊑shader⟩ low.ReadI32 firstMatPtr
    atLocsPtr ← 8 low.MovePtr firstMatPtr
    
    shaderPtr ← shaderIndex.locs⊑shader
    shaderPtr low.ReadI8 atLocsPtr
  }
  {
    matsPtr ← modelIndex.materials⊑cube
    firstMatPtr ← 0 low.MovePtr matsPtr
    ⟨(2⋆32){𝕨⊸|⌾((𝕨÷2)⊸+)𝕩} shaderIndex.id⊑shader⟩ low.ReadI32 firstMatPtr
    atLocsPtr ← 8 low.MovePtr firstMatPtr
    
    shaderPtr ← shaderIndex.locs⊑shader
    shaderPtr low.ReadI8 atLocsPtr
  }

  # Create lights
  lights ← rlights.CreateLight¨⟨
    ⟨rlights.lightType.light_point, ¯2‿1‿¯2, 0‿0‿0, color.yellow, shader⟩
    ⟨rlights.lightType.light_point,  2‿1‿ 2, 0‿0‿0, color.red   , shader⟩
    ⟨rlights.lightType.light_point, ¯2‿1‿ 2, 0‿0‿0, color.green , shader⟩
    ⟨rlights.lightType.light_point,  2‿1‿¯2, 0‿0‿0, color.blue  , shader⟩
  ⟩
  #--------------------------------------------------------------------------------------

  # Main game loop
  {𝕤
    # Update
    #----------------------------------------------------------------------------------
    ⟨⟨camera⟩⟩ ↩ rf.UpdateCameraRef ⟨⋈camera⋄rf.cameraMode.camera_orbital⟩

    # Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    cameraPos ← cameraIndex.position⊑camera
    ⟨loc⟩ ← 1 low.MakeI32 (4×rf.shaderLocationIndex.shader_loc_vector_view)low.MovePtr shaderIndex.locs⊑shader

    rf.SetShaderValueRaw⟨shader, loc, F32ToI8 cameraPos, rf.shaderUniformDataType.shader_uniform_vec3⟩

    # Check key inputs to enable/disable lights
    lights {
      (rf.IsKeyPressed 𝕩) ¬⌾(rlights.lightIndex.enabled⊸⊑)∘⊢⍟⊣𝕨
    }¨↩ ⟨  key.y ⋄ key.r ⋄ key.g ⋄ key.b ⟩
    
    # Update light values (actually, only enable/disable them)
    shader⊸rlights.UpdateLightValues¨ lights
    #----------------------------------------------------------------------------------

    # Draw
    #----------------------------------------------------------------------------------
    {𝕤
      {𝕤
        rf.DrawModel⟨model, 0‿0‿0, 1, color.white⟩
        rf.DrawModel⟨cube , 0‿0‿0, 1, color.white⟩

        # Draw spheres to show where the lights are
        {rlights.lightIndex.enabled⊑𝕩?
          rf.DrawSphereEx   ⟨rlights.lightIndex.position⊑𝕩, 0.2, 8, 8, rlights.lightIndex.color⊑𝕩⟩
        ; rf.DrawSphereWires⟨rlights.lightIndex.position⊑𝕩, 0.2, 8, 8, ⌈0.3⊸×⌾(3⊸⊑)rlights.lightIndex.color⊑𝕩⟩
        }¨lights
        rf.DrawGrid 10‿1
      } rl.draw._in3D camera

      rf.DrawFPS 10‿10

      rf.DrawText⟨"Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, color.darkgray⟩

    } draw._withCanvas_ color.raywhite @
    #----------------------------------------------------------------------------------
  } •_While_(¬window.ShouldClose) @

  # De-Initialization
  #--------------------------------------------------------------------------------------
  rf.UnloadModel  model    # Unload the model
  rf.UnloadModel  cube     # Unload the model
  rf.UnloadShader shader   # Unload shader

} window._openAs "raylib [shaders] example - basic lighting"

