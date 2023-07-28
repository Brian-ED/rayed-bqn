## NOT FINISHED

# All shader features working on linux only

⟨color, window, draw, rayffi,key⟩←r←•Import "../../raylib.bqn"
⟨materialStruct⇐material⟩ ← rayffi
shader_uniform_vec3 ← 2
shader_uniform_vec4 ← 3

# Create a light and get shader locations
CreateLight ← {lightsCount𝕊⟨x‿y‿z⋄color⋄shader⟩:
  shaderVars ← "enabled"‿"type"‿"position"‿"target"‿"color"
  shader UpdateLightValues {
    type           ⇐ 1
    enabled‿Toggle ⇐ 1‿{𝕊: enabled¬↩}
    pos            ⇐ x‿y‿z
    target         ⇐ 0‿0‿0
    color          ⇐ color
  # NOTE: Lighting shader naming must be the provided ones
    ⟨enabledLoc, typeLoc, posLoc, targetLoc, colorLoc
    ⟩ ⇐ (rayffi.GetShaderLocation shader⋈"lights["∾lightsCount•Repr⊸∾"]."∾∾⟜@)¨shaderVars
  }
}

# Send light properties to shader
# NOTE: Light shader locations should be available 
UpdateLightValues ← {shader𝕊light:
  shader_uniform_int ← 4
  rayffi.SetShaderValue⟨shader, light.enabledLoc,⋈light.enabled  , shader_uniform_int⟩
  rayffi.SetShaderValue⟨shader, light.typeLoc   ,⋈light.type     , shader_uniform_int⟩
  rayffi.SetShaderValue⟨shader, light.posLoc    ,⋈light.pos      , shader_uniform_vec3⟩
  rayffi.SetShaderValue⟨shader, light.targetLoc ,⋈light.target   , shader_uniform_vec3⟩
  rayffi.SetShaderValue⟨shader, light.colorLoc  ,⋈light.color÷255, shader_uniform_vec4⟩
  light
}

PerFrame ← {shader‿model‿cube‿xxx‿font𝕊camera‿lights:
  rayffi.UpdateCamera⟨camera⟩‿2

  # Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
  cameraPos ← ⊑camera
  rayffi.SetShaderValue⟨shader, xxx, cameraPos, shader_uniform_vec3⟩        

  # Check key inputs to enable/disable lights
  lights{𝕨.Toggle@}⍟⊢¨key.IsPressed¨⟨key.y, key.r, key.g, key.b⟩

  # Update light values (actually, only enable/disable them)
  shader⊸UpdateLightValues¨lights

  rayffi.BeginMode3D camera
    rayffi.DrawModel ⟨model,0‿0‿0, 1, color.white⟩
    rayffi.DrawModel ⟨cube, 0‿0‿0, 1, color.white⟩

    {
      𝕩.enabled◶⟨
        rayffi.DrawSphereWires⌈∘×⟜0.3⌾(¯1⊑¯1⊸⊑)
        rayffi.DrawSphereEx
      ⟩ ⟨𝕩.pos, 0.2, 8, 8, 𝕩.color⟩
    }¨lights
    rayffi.DrawGrid 10‿1
  rayffi.EndMode3D⟨⟩
  rayffi.DrawFPS 10‿10

  color.darkGray‿font‿20 draw.Text 10‿40⋈"Use keys [Y][R][G][B] to toggle lights"
  MoveCamera ← (key.q‿key.up‿key.e -○(key.IsPressed¨) key.left‿key.down‿key.right)⊸+⌾⊑
  ⟨
    MoveCamera camera
    lights
  ⟩
}draw._withCanvas_ color.black

{𝕤
  rayFFI.SetConfigFlags window.configFlags.msaa_4x_hint  # Enable Multi Sampling Anti Aliasing 4x (if available)
  camera ← ⟨
    1‿4‿6 # position
    0‿0‿0 # target
    0‿1‿0 # up         # Camera up vector
    45    # fovy       # Camera field-of-view Y
    0     # projection # Camera projection type
  ⟩
  font  ← r.font.LoadBQN 100
  plane ← rayffi.LoadModelFromMesh rayffi.GenMeshPlane 10‿10‿3‿3
  cube  ← rayffi.LoadModelFromMesh rayffi.GenMeshCube   2‿ 4‿2

  # Load basic lighting shader
  shader ← rayffi.LoadShader"lighting.vs"‿"lighting.fs"∾¨@

  # Get some required shader locations
  xxx←rayffi.GetShaderLocation shader⋈"viewPos"∾@

  # Ambient light level (some basic lighting)
  ambientLoc ← rayffi.GetShaderLocation shader⋈"ambient"∾@

  rayffi.SetShaderValue⟨shader, ambientLoc, 1∾˜3⥊0.1, shader_uniform_vec4⟩

  # Create lights
  lights ← CreateLight¨˜⟜(↕≠)⟨
    ⟨¯2‿1‿¯2, color.yellow, shader⟩
    ⟨ 2‿1‿ 2, color.red   , shader⟩
    ⟨¯2‿1‿ 2, color.green , shader⟩
    ⟨ 2‿1‿¯2, color.blue  , shader⟩
  ⟩

  shader‿plane‿cube‿xxx‿font PerFrame•_While_(¬window.ShouldClose) camera‿lights

  rayffi.UnloadModel plane
  rayffi.UnloadModel cube
  rayffi.UnloadShader shader
} window._openAs "raylib [shaders] example - basic lighting"
