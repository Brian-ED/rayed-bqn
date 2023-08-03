⟨color,window,draw,rf⇐rayffi⟩←r←•Import "../../../raylib.bqn"
# Idea: "Construct": makes structs from pointer 

⟨MP⟩←•Import "../../../src/imports/bqn-libs/matrix.bqn"

# Model, meshes, materials and animation data
modelIndex ← {
  transform        ⇐ 0           
  num_of_meshes    ⇐ 1              
  num_of_materials ⇐ 2                 
  meshes           ⇐ 3 # Meshes array
  materials        ⇐ 4 # Materials array
  meshMaterial     ⇐ 5 # Mesh material number
  boneCount        ⇐ 6 # Number of bones
  bones            ⇐ 7 # Bones information (skeleton)
  bindPose         ⇐ 8 # Bones base transformation (pose)
}

# Send light properties to shader
# NOTE: Light shader locations should be available 
UpdateLightValues ← {
    𝕩.SetEnabled 𝕩.enabled
    𝕩.SetType    𝕩.type
    𝕩.SetPos     𝕩.pos
    𝕩.SetTarget  𝕩.target
    𝕩.SetColor   𝕩.color÷255
    𝕩
}

Print←{𝕤
    •Show¨{1≡•Type 𝕩?⌊⌾(1e3⊸×)𝕩;𝕩}⚇0 𝕩
    •term.Flush@
    𝕩
}

MakeShaderVarSetter ← {shader𝕊shaderVar‿shaderType:
    i ← rf.GetShaderLocation shader⋈𝕩∾@
    int‿vec3‿vec4⇐r.shaderUniformDataType
    {
        shaderType{
            𝕨=int ? !⌊⊸≡𝕩;
            𝕨=vec3? !(∧´1=•Type¨𝕩)∧⟨3⟩≡≢𝕩;
            𝕨=vec4? !(∧´1=•Type¨𝕩)∧⟨4⟩≡≢𝕩;
            !"Type not defined"
        }𝕩
        rf.SetShaderValue shader‿i‿(⋈𝕩)‿shaderType
    }
}

# Create a light and get shader locations
CreateLight ← {lightsCount𝕊⟨x‿y‿z⋄color⋄shader⟩:
  shader UpdateLightValues {
    type           ⇐ r.textureFilter.point
    enabled‿Toggle ⇐ 1‿{𝕊: enabled¬↩}
    pos            ⇐ x‿y‿z
    target         ⇐ 0‿0‿0
    color          ⇐ color
  # NOTE: Lighting shader naming must be the provided ones
    ⟨SetEnabled, SetType, SetPos, SetTarget, SetColor⟩ ⇐ shader⊸MakeShaderVarSetter¨⟨
        "enabled" ‿r.shaderUniformDataType.int
        "type"    ‿r.shaderUniformDataType.int
        "position"‿r.shaderUniformDataType.vec3
        "target"  ‿r.shaderUniformDataType.vec3
        "color"   ‿r.shaderUniformDataType.vec4
    ⟩
  }
}

{𝕤
    rf.SetConfigFlags window.configFlags.msaa_4x_hint  # Enable Multi Sampling Anti Aliasing 4x (if available)

    camera ← ⟨
        2‿2‿6                        # Camera position
        0‿1‿0÷2                      # Camera looking at point
        0‿1‿0                        # Camera up vector (rotation towards target)
        45                           # Camera field-of-view Y
        r.cameraProjection.perspective # Camera projection type
    ⟩
    # Load models and texture
    ⟨donutModel⋄cubeModel⋄sphereModel
    ⟩ ← rf.LoadModelFromMesh¨⟨
        rf.GenMeshTorus  0.4‿1‿16‿32
        rf.GenMeshCube   3⥊1
        rf.GenMeshSphere 0.5‿32‿32
    ⟩
    texture ← rf.LoadTexture "texel_checker.png"∾@

    # Assign texture to default model material
    F ← {
        materialsPtr ← •Show modelIndex.materials⊑𝕩
        memoryIndexOfMaps ← 8+4
        ptrToMaps ← memoryIndexOfMaps rf.MovePtr materialsPtr
        texture rf.Read r.materialMapIndex.albedo rf.MovePtr ptrToMaps
    }
    F¨donutModel‿cubeModel‿sphereModel

    # Load shader and set up some uniforms
    shader ← rf.LoadShader •file.At¨"lighting.vs"‿"fog.fs"
    shaderLocsIndex ← 1

    locsPtr ← shaderLocsIndex⊑shader
    {
        dataUpTo ← locsPtr rf.MakeI32˜r.shaderLocationIndex.matrix_model
        (dataUpTo∾rf.GetShaderLocation shader⋈"matModel"∾@) rf.ReadI32 locsPtr
    }
    {
        dataUpTo ← locsPtr rf.MakeI32˜r.shaderLocationIndex.vector_view
        (dataUpTo∾rf.GetShaderLocation shader⋈"viewPos"∾@) rf.ReadI32 locsPtr
    }
    # Ambient light level
    ambientLoc ← rf.GetShaderLocation shader⋈"ambient"∾@
    rf.SetShaderValue⟨shader, ambientLoc, ÷1∾˜3⥊5, r.shaderUniformDataType.vec4⟩

    fogDensity ← 0.15
    fogDensityLoc ← rf.GetShaderLocation shader⋈"fogDensity"∾@
    rf.SetShaderValue⟨shader, fogDensityLoc, ⟨fogDensity⟩, r.shaderUniformDataType.float⟩
    
    # NOTE: All models share the same shader
    {
        matsPtr ← modelIndex.materials ⊑ 𝕩
        
        (∾rf.U32ToI8⌾⊑shader) rf.Read matsPtr
    }¨⟨donutModel ⋄ cubeModel ⋄ sphereModel⟩
    
    # Using just 1 point lights
    0 CreateLight⟨0‿2‿6, r.color.white, shader⟩

    # Main game loop
    {𝕤
        # Update
        rf.UpdateCamera ⟨camera⟩⋈r.cameramode.orbital
        
        {𝕤
            fogDensity +↩ 0.001
            {fogDensity↩𝕩}⍟(fogDensity⊸>)1
        }⍟r.key.PressedKey r.key.up
        
        {𝕤
            fogDensity -↩ 0.001
            {fogDensity↩𝕩}⍟(fogDensity⊸<)0
        }⍟r.key.PressedKey r.key.down

        rf.SetShaderValue⟨shader, fogDensityLoc, ⋈fogDensity, r.shaderUniformDataType.float⟩

        # Rotate the torus
        donutModel ↩ {
            (MatrixRotateZ 0.012) MP˜ 𝕩 MP MatrixRotateX ¯0.025
        }⌾(4‿4⥊modelIndex.transform⊸⊑) donutModel

        # Update the light shader with the camera view position
        camPosIndex ← 0
        rf.SetShaderValue⟨shader, ⊑1 rf.MakeI32 locsPtr rf.MovePtr˜ 4×r.shaderLocationIndex.vector_view-1, ⋈⊑camPosIndex⊑camera, r.shaderUniformDataType.vec3⟩

        # Draw
        {𝕤
            {𝕤
                # Draw the models
                rf.DrawModel⟨Print donutModel ⋄ 3⥊0 ⋄ 1 ⋄ r.color.white⟩
                #∾{
                #    ⟨donutModel ⋄  𝕩  ‿0‿2⟩
                #}¨2×¯10+↕20
            }r.draw._in3D camera

            rf.DrawText⟨"Use KEY_UP/KEY_DOWN to change fog density ["∾fogDensity∾".2f]"∾@, 10, 10, 20, r.color.raywhite⟩
        }r.draw._withCanvas_ r.color.gray@
    }•_while_(¬r.window.ShouldClose)@

    rf.UnloadModel¨donutModel‿cubeModel‿sphereModel
    rf.UnloadTexture texture
    rf.UnloadShader  shader

} r.window._openAs˜⟜0.5 "raylib [shaders] example - fog"