⟨
  rf⇐raylib
  ⟨
    GetShaderLocation ⋄ SetShaderValueRaw ⋄ SetShaderValue
    MemAlloc ⋄ MemFree
    ⟨
      SHADER_UNIFORM_INT ⋄ SHADER_UNIFORM_VEC3 ⋄ SHADER_UNIFORM_Vec4
    ⟩⇐shaderUniformDataType
  ⟩⇐raylib
⟩ ← rl ← •Import "../../rayed.bqn"

lightIndex ⇐ {
  type        ⇐ 0
  enabled     ⇐ 1
  position    ⇐ 2
  target      ⇐ 3
  color       ⇐ 4
  attenuation ⇐ 5

  # Shader locations
  enabledLoc     ⇐ 6
  typeLoc        ⇐ 7
  positionLoc    ⇐ 8
  targetLoc      ⇐ 9
  colorLoc       ⇐ 10
  attenuationLoc ⇐ 11
}

# Light type
lighttype ⇐ {
  light_directional ⇐ 0,
  light_point ⇐ 1
}

CreateLight ⇐ # Create a light and get shader locations
UpdateLightValues ⇐ # Send light properties to shader

max_lights  ⇐ 4    # Max dynamic lights supported by shader
lightsCount ← 0    # Current amount of created lights

# Create a light and get shader locations
CreateLight ← {𝕊type‿position‿target‿color‿shader: # i v3 v3 Color Shader
  ("You can't have more than "∾(•Repr maxLights)∾" lights")!lightsCount<maxLights

  GetShaderLoc ← GetShaderLocation shader⋈"lights["∾(•Repr lightsCount)∾"]."∾⊢

  {𝕊:lightsCount+↩1}⊸⊢ shader⊸UpdateLightValues⊸⊢⟨
    type     # type
    1        # enabled
    position # position
    target   # target
    color    # color
    0        # attenuation

    # Shader locations
    # NOTE: Lighting shader naming must be the provided ones
    GetShaderLoc "enabled"
    GetShaderLoc "type"
    GetShaderLoc "position"
    GetShaderLoc "target"
    GetShaderLoc "color"
    0 # attenuationLoc
  ⟩
}

# Send light properties to shader
# NOTE: Light shader locations should be available

UpdateLightValues ← {shader𝕊⟨
    # Send to shader light enabled state and type
    type
    enabled
    position
    target
    color
    attenuation
    enabledLoc
    typeLoc
    positionLoc
    targetLoc
    colorLoc
    attenuationLoc
  ⟩:

  {
    ptr ← (MemAlloc 4).Cast "i32"
    ptr.Write type
    rf.SetShaderValue⟨shader, typeLoc, ptr , SHADER_UNIFORM_INT ⟩
  }
  {
    ptr ← (MemAlloc 1).Cast "i8"
    ptr.Write enabled
    SetShaderValue⟨shader, enabledLoc, ptr , SHADER_UNIFORM_INT ⟩
  }
  {
    # [3]f32
    ptr ← (MemAlloc 4×3).Cast "f32"
    ptr.WriteList position
    ptr.ReadList 3
    SetShaderValue⟨shader, positionLoc, ptr, SHADER_UNIFORM_VEC3⟩ # Send to shader light position values
  }
  {
    ptr ← (MemAlloc 4×3).Cast "f32"
    ptr.WriteList target
    SetShaderValue⟨shader, targetLoc, ptr, SHADER_UNIFORM_VEC3⟩ # Send to shader light target position values
  }
  {
    ptr ← (MemAlloc 4×4).Cast "f32"
    ptr.WriteList color÷255
    SetShaderValue⟨shader, colorLoc, ptr, SHADER_UNIFORM_VEC4⟩ # Send to shader light color values
  }
  ⟨
    # Send to shader light enabled state and type
    type
    enabled
    position
    target
    color
    attenuation
    enabledLoc
    typeLoc
    positionLoc
    targetLoc
    colorLoc
    attenuationLoc
  ⟩
}
