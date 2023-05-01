# THIS EXAMPLE IS INCOMPLETE

⟨color, window, draw, rayffi,key⟩←r←•Import "../../raylib.bqn"
⟨materialStruct⇐material⟩ ← rayffi
xxx←@
# Create a light and get shader locations
CreateLight ← {lightsCount𝕊intType‿v3Pos‿v3Target‿color‿shader: # i v3 v3 color shader
  light ← ⟨
    intType, 1, v3Pos, v3Target, color
    @ # attenuation
  # NOTE: Lighting shader naming must be the provided ones
    rayffi.GetShaderLocation shader⋈"lights["∾lightsCount∾"].enabled"
    rayffi.GetShaderLocation shader⋈"lights["∾lightsCount∾"].type"
    rayffi.GetShaderLocation shader⋈"lights["∾lightsCount∾"].position"
    rayffi.GetShaderLocation shader⋈"lights["∾lightsCount∾"].target"
    rayffi.GetShaderLocation shader⋈"lights["∾lightsCount∾"].color"
    @ # attenuationLoc
  ⟩
  shader UpdateLightValues light
}
shader_uniform_int ← 4
shader_uniform_vec3 ← 2
shader_uniform_vec4 ← 3
versionGLSL ← 330
shader_loc_vector_veiw ← 11
shader_loc_matrix_model ← 9

# Send light properties to shader
# NOTE: Light shader locations should be available 
UpdateLightValues ← {shader𝕊light:
  # Send to shader light enabled state and type
  rayffi.SetShaderValue ⟨shader, 6⊑light, ⟨1⊑light⟩, shader_uniform_int⟩
  rayffi.SetShaderValue ⟨shader, 7⊑light,  ⟨⊑light⟩, shader_uniform_int⟩

  # Send to shader light position values
  position ← 2⊑light
  positionLoc ← 8⊑light
  rayffi.SetShaderValue⟨shader, positionLoc, position, shader_uniform_vec3⟩

  # Send to shader light target position values
  target ← 3⊑light
  targetLoc ← 9⊑light
  rayffi.SetShaderValue⟨shader, targetLoc, target, shader_uniform_vec3⟩

  # Send to shader light color values
  color ← 255÷˜4⊑light
  rayffi.SetShaderValue⟨shader, ¯2⊑light, color, shader_uniform_vec4⟩
  light
}

LoadConsts ← {𝕤
  # Initialization
  rayFFI.SetConfigFlags window.configFlags.msaa_4x  # Enable Multi Sampling Anti Aliasing 4x (if available)

  # Define the camera to look into our 3d world
  camera ← ⟨
    2‿4‿6 # position   # Camera position
    0‿0‿0 # target     # Camera looking at point
    0‿1‿0 # up         # Camera up vector (rotation towards target)
    45    # fovy       # Camera field-of-view Y
    0     # projection # Camera projection type
  ⟩

  # Load plane model from a generated mesh
  model ← rayffi.LoadModelFromMesh rayffi.GenMeshPlane 10‿10‿3‿3
  cube  ← rayffi.LoadModelFromMesh rayffi.GenMeshCube   2‿ 4‿2

  # Load basic lighting shader
  shader ← rayffi.LoadShader"lighting.vs"‿"lighting.fs"∾¨@
  # Get some required shader locations
  
  mutateAtIndex ←  @•FFI""‿"bqn_readI32Arr"‿"𝕨>a"‿"𝕩>*:i8"
  p ← (4×shader_loc_vector_veiw) {b←256⋆↕8 ⋄ -⟜(256×≥⟜128) 256|⌊÷⟜b 𝕨++´b×256|𝕩} 1⊑shader
  p MutateAtIndex˜⋈xxx↩rayffi.GetShaderLocation shader⋈"viewPos"∾@

  # Ambient light level (some basic lighting)
  ambientLoc ← rayffi.GetShaderLocation shader⋈"ambient"∾@

  rayffi.SetShaderValue⟨shader, ambientLoc, 1∾˜3⥊0.1, shader_uniform_vec4⟩

  # Assign out lighting shader to model
  materialsIndex←5

#    model.materials[0].shader = shader;
#    cube .materials[0].shader = shader;

#  p1 ← materialsIndex⊑model
#  p2 ← materialsIndex⊑cube

#  model‿cube shader⌾(0⊑4⊑⊢)¨↩

  # Create lights
  lights ← CreateLight¨˜⟜(↕≠)⟨
    ⟨1, ¯2‿1‿¯2, 0‿0‿0, color.yellow, shader⟩
    ⟨1,  2‿1‿ 2, 0‿0‿0, color.red,    shader⟩
    ⟨1, ¯2‿1‿ 2, 0‿0‿0, color.green,  shader⟩
    ⟨1,  2‿1‿¯2, 0‿0‿0, color.blue,   shader⟩
  ⟩
  camera‿shader‿lights‿model‿cube
}
PerFrame ← {camera‿shader‿lights‿model‿cube𝕊𝕩:
  rayffi.UpdateCamera⟨camera⟩‿2

  # Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
  cameraPos ← ⊑camera
  rayffi.SetShaderValue⟨shader, xxx, cameraPos, shader_uniform_vec3⟩        

  # Check key inputs to enable/disable lights
  lights{¬⍟(r.key.IsPressed𝕩)⌾(1⊸⊑)𝕨}¨↩⟨key.kY, key.kR, key.kG, key.kB⟩
  
  # Update light values (actually, only enable/disable them)
  shader⊸UpdateLightValues¨lights

  rayffi.BeginMode3D camera
    rayffi.DrawModel ⟨model,0‿0‿0, 1, color.white⟩
    rayffi.DrawModel ⟨cube, 0‿0‿0, 1, color.white⟩

    {0≢6⊑𝕩? rayffi.DrawSphereEx ⟨2⊑𝕩, 0.2, 8, 8, 4⊑𝕩⟩;
      rayffi.DrawSphereWires  ⟨2⊑𝕩, 0.2, 8, 8, rayffi.ColorAlpha⟨4⊑𝕩, 0.3⟩⟩
    }¨lights
    rayffi.DrawGrid 10‿1
  rayffi.EndMode3D⟨⟩
  rayffi.DrawFPS 10‿10

  rayffi.DrawText "Use keys [Y][R][G][B] to toggle lights"‿10‿40‿20‿color.darkGray

}draw._withCanvas_ color.white

Unload ← {𝕊camera‿shader‿lights‿model‿cube:
  rayffi.UnloadModel model
  rayffi.UnloadModel cube
  rayffi.UnloadShader shader
}
Game ← Unload LoadConsts PerFrame•_While_(¬window.ShouldClose) ⊢
Game window._openAs "raylib [shaders] example - basic lighting"
