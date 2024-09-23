# depending on rlgl version, you can set this to 100, 120, and 330
glslVersion ← 330

⟨
  color, window, draw, low, key
  rf⇐raylib, rm⇐raymath
⟩ ← rl ← •Import "../../rayed.bqn"
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

NestedStructToStr1 ← {
  1≥≡𝕩?𝕩;
  F: {'{'∾'}'«∾','∾¨F¨"*:i8"⍟('*'≡⊑)⍟(×≠)¨𝕩}⌾(((0=≡¨)⊸/𝕩)⊸∾⁼)𝕩
}

NestedStructToStr2 ← {
  1≥≡𝕩?𝕩;
  F: {'{'∾'}'«∾','∾¨F¨𝕩}⌾(((0=≡¨)⊸/𝕩)⊸∾⁼)𝕩
}
mesh ← NestedStructToStr1 rf.mesh
model ← NestedStructToStr2 rf.model
shaderT ← NestedStructToStr2 rf.shader
                                       # vsFileName fsFileName                                             # Load shader from files and bind default locations
{𝕤
  # Define the camera to look into our 3d world
  cameraOrig ← ⟨
    2‿4  ‿6 # Camera position
    0‿0.5‿0 # Camera looking at point
    0‿1  ‿0 # Camera up vector (rotation towards target)
    45      # Camera field-of-view Y
    rf.cameraProjection.camera_perspective # Camera projection type
  ⟩
  # Load plane model from a generated mesh
  model ← rl.model.LoadFromMesh rf.GenMeshPlane 10‿10‿3‿3
  model2 ← rl.model.LoadFromMesh rf.GenMeshPlane 10‿10‿3‿3

  cube  ← rl.model.LoadFromMesh rf.GenMeshCube 2‿4‿2
  # Load basic lighting shader
  shader ← rf.LoadShader •file.At¨ "vs"‿"fs"∾˜¨<"shaders/glsl"∾"/lighting."∾˜•Repr glslVersion

  # Get some required shader locations
  veiwPos ← rf.GetShaderLocation shader‿"viewPos"
  {
    locsPtr ← shaderIndex.locs⊑shader
    rf.shaderLocationIndex.shader_loc_vector_view locsPtr.Write veiwPos
  }

  # Ambient light level, makes it so when no lights are on it's gray instead of black
  {
    ambientLoc ← rf.GetShaderLocation shader‿"ambient"
    rf.SetShaderValueRaw⟨shader, ambientLoc, low.F32ToI8 4⥊1, rf.shaderUniformDataType.shader_uniform_vec4⟩
  }

  # Assign out lighting shader to model
  {
    (𝕩.Field 0).Write shader
  }¨modelIndex.materials⊸⊑¨cube‿model

  # Create lights
  lt ← rlights.lightType.light_point
  lights ← rlights.CreateLight¨⟨
    ⟨lt, ¯2‿1‿¯2, 0‿0‿0, color.yellow, shader⟩
    ⟨lt,  2‿1‿ 2, 0‿0‿0, color.red   , shader⟩
    ⟨lt, ¯2‿1‿ 2, 0‿0‿0, color.green , shader⟩
    ⟨lt,  2‿1‿¯2, 0‿0‿0, color.blue  , shader⟩
  ⟩
  #--------------------------------------------------------------------------------------

  # Main game loop
  {𝕊cameraOld:
    # Update
    #----------------------------------------------------------------------------------
    ⟨⟨camera⟩⟩ ← rf.UpdateCameraRef⟨⋈cameraOld⋄rf.cameraMode.camera_orbital⟩

    # Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    rf.SetShaderValueRaw⟨
      shader, veiwPos
      low.F32ToI8 cameraIndex.position⊑camera
      rf.shaderUniformDataType.shader_uniform_vec3
    ⟩

    # Check key inputs to enable/disable lights
    lights {
      ¬⌾(rlights.lightIndex.enabled⊸⊑)⍟(rl.key.IsPressed 𝕩)𝕨
    }¨↩ ⟨ key.y ⋄ key.r ⋄ key.g ⋄ key.b ⟩
    
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
        l←rlights.lightIndex
        {l.enabled⊑𝕩?
          rf.DrawSphereEx   ⟨l.position⊑𝕩, 0.2, 8, 8, l.color⊑𝕩⟩
        ; rf.DrawSphereWires⟨l.position⊑𝕩, 0.2, 8, 8, ⌈0.3⊸×⌾(3⊸⊑)l.color⊑𝕩⟩
        }¨lights
        rf.DrawGrid 10‿1
      } rl.draw._in3D camera

      rf.DrawFPS 10‿10
      rf.DrawText⟨"Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, color.darkgray⟩
    } draw._withCanvas_ color.raywhite @
    camera
    #----------------------------------------------------------------------------------
  } •_While_(¬window.ShouldClose) cameraOrig

  # De-Initialization
  #--------------------------------------------------------------------------------------
  rf.UnloadModel  model    # Unload the model
  rf.UnloadModel  cube     # Unload the model
  rf.UnloadShader shader   # Unload shader

} window._openAs "raylib [shaders] example - basic lighting"

