⟨color, window, draw, rf⇐rayffi, key⟩←r←•Import "../../../raylib.bqn"

# Light type
lightType ← {
    directional ⇐ 0
    point       ⇐ 1
}

modelType ← {
  transform     ⇐ 0 # Matrix transform    # Local transform matrix
  meshCount     ⇐ 1 # meshCount           # Number of meshes
  materialCount ⇐ 2 # materialCount       # Number of materials
  meshes        ⇐ 3 # Mesh *meshes        # Meshes array
  materials     ⇐ 4 # Material *materials # Materials array
  meshMaterial  ⇐ 5 # int *meshMaterial   # Mesh material number
  boneCount     ⇐ 6 # int boneCount       # Number of bones
  bones         ⇐ 7 # BoneInfo *bones     # Bones information (skeleton)
  bindPose      ⇐ 8 # Transform *bindPose # Bones base transformation (pose)
}

shaderType ← {
    programID ⇐ 0 # u         # Shader program id
    locs      ⇐ 1 # ptr (P i) # Shader locations array (RL_MAX_SHADER_LOCATIONS)
}

# Define the camera to look into our 3d world
camera ←⟨
    3‿3‿3                          # position   # Camera position
    0‿1‿0÷2                        # target     # Camera looking at point
    0‿1‿0                          # up         # Camera up vector (rotation towards target)
    45                             # fovy       # Camera field-of-view Y
    r.cameraProjection.perspective # projection # Camera projection type
⟩

Show ← {•Out ('␀'-@)⊸+⌾((@=f)⊸/)f←•Fmt𝕩 ⋄ •term.Flush@ ⋄ 𝕩}

ShaderVal ← {shader‿shaderType𝕊shaderVar:
    i←rf.GetShaderLocation shader⋈𝕩∾@
    Set ⇐ {rf.SetShaderValue shader‿i‿𝕩‿shaderType}

}

{𝕤
    rf.SetConfigFlags r.window.configFlags.msaa_4x_hint  # Enable Multi Sampling Anti Aliasing 4x (if available)
    model‿cube ← rf.LoadModelFromMesh¨⟨
        rf.GenMeshPlane 10‿10‿3‿3 
        rf.GenMeshCube  2‿4‿2
    ⟩

    # Load basic lighting shader
    # loadShader ← "../../C/raylib/src/libraylib.so" •FFI "*:i8"‿"LoadShader"‿"*i8:c8"‿"*i8:c8"
    shader ← rf.LoadShader •file.At¨"lighting."⊸∾¨"vs"‿"fs"
    shaderLocsPtr ← shaderType.locs ⊑ shader # shader.locs
    
    font ← r.font.LoadBQN 100

    # Get some required shader locations
    { # shader.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
        movedPtr ← shaderLocsPtr rf.MovePtr˜4×r.shaderLocationIndex.vector_view
        movedPtr rf.ReadI32˜⋈rf.GetShaderLocation shader⋈"viewPos"∾@
    }
    # Ambient light level (some basic lighting)
    ambientLoc ← rf.GetShaderLocation shader⋈"ambient"∾@
    rf.SetShaderValue ⟨shader, ambientLoc, ÷10‿10‿10‿1, r.shaderUniformDataType.vec4⟩
    
    # Assign out lighting shader to model
    MakeMaterialPtr ← {𝕤
        size ← +´⟨
            12 # shaderSize
            
            # rest of material struct
            8   # ptrSize
            4×4 # v4Size
        ⟩
        ptr←rf.MemAlloc size
        ptr rf.Read˜size↑∾˜∾rf.U32ToI8⌾⊑shader
        ptr
    }
    (•Show 36⊸rf.Make)⌾(modelType.materials⊸⊑)¨model‿cube
    model‿cube MakeMaterialPtr⌾(modelType.materials⊸⊑)¨↩
    # model.materials[0].shader ← shader;
    # cube .materials[0].shader ← shader;

    # Create lights
    CreateLight ← {𝕊⟨
            position    # Vector3
            target      # Vector3
            color       # Color
            pKey
            lightsCount
        ⟩:
        type‿position‿target‿color⇐
        color÷↩255
        enabled ⇐ 1
        type ← lightType.point

        # NOTE: Lighting shader naming must be the provided ones
        F ← {type‿var:
            loc ← rf.GetShaderLocation shader⋈"lights["∾(•Repr lightsCount)∾"]."∾var∾@
            {𝕩⊣rf.SetShaderValue ⟨shader⋄loc⋄⥊𝕩⋄type⟩}
        }
        su ← r.shaderUniformDataType
        setEnabled  ← {𝕊n: G←{enabled  ↩ N𝕩} ⋄ G enabled  ⋄ g} F su.int ‿"enabled"
        setType     ⇐ {𝕊n: G←{type     ↩ N𝕩} ⋄ G type     ⋄ g} F su.int ‿"type"
        setPosition ⇐ {𝕊n: G←{position ↩ N𝕩} ⋄ G position ⋄ g} F su.vec3‿"position"
        setTarget   ⇐ {𝕊n: G←{target   ↩ N𝕩} ⋄ G target   ⋄ g} F su.vec3‿"target"
        setColor    ⇐ {𝕊n: G←{color    ↩ N𝕩} ⋄ G color    ⋄ g} F su.vec4‿"color"
        Toggle      ⇐ {𝕊: SetEnabled¬enabled}⍟(key.IsPressed∘pKey)
        
    }
    lights ← CreateLight¨({a‿b‿k:⟨a⋄3⥊0⋄b⋄k⟩}¨∾¨↕∘≠)⟨
        ⟨¯2‿1‿¯2 ⋄ color.yellow ⋄ key.y⟩
        ⟨ 2‿1‿ 2 ⋄ color.red    ⋄ key.r⟩
        ⟨¯2‿1‿ 2 ⋄ color.green  ⋄ key.g⟩
        ⟨ 2‿1‿¯2 ⋄ color.blue   ⋄ key.b⟩
    ⟩



    # Main game loop
    {𝕤
        rf.UpdateCamera ⟨camera⟩‿r.cameramode.orbital
        rf.SetShaderValue ⟨
            shader
            ⊢´(r.shaderLocationIndex.vector_view+1) rf.MakeI32 shaderLocsPtr # locsPtr[SHADER_LOC_VECTOR_VIEW]
            ⊑camera
            r.shaderUniformDataType.vec3
        ⟩
        lights {𝕨.Toggle@}⍟(key.IsPressed⊢)¨⟨key.y⋄key.r⋄key.g⋄key.b⟩
        {𝕤 
            Show¨ cube
            rf.DrawModel ⟨model ⋄ 3⥊0 ⋄ 1 ⋄ color.white⟩
            Show "Hi2"
            rf.DrawModel ⟨cube ⋄ 3⥊0 ⋄ 1 ⋄ color.white⟩
            # Draw spheres to show where the lights are
            {𝕩.enabled? rf.DrawSphereEx 𝕩.position‿0.2‿8‿8‿(𝕩.color×255)
            ;           rf.DrawSphereWires 76⌾⊑⌾⌽⌾⊑⌾⌽ ⟨𝕩.position, 0.2, 8, 8, 𝕩.color×255⟩
            }¨lights
            rf.DrawGrid 10‿1
        } r.draw._in3D camera

        rf.DrawFPS 10‿10
        color.darkgray‿font‿30 draw.Text 10‿40⋈"Use keys [Y][R][G][B] to toggle lights"

        (key.right‿key.up‿key.e -○key.IsPressed key.left‿key.down‿key.q)⊸+⌾(⊑⊑)𝕩
    }draw._withCanvas_ color.raywhite•_While_(¬window.ShouldClose) @

    r.font.Unload font
    rf.UnloadModel¨ model‿cube
    rf.UnloadShader shader
}window._openAs "raylib [shaders] example - basic lighting"



# Draw a model (with texture if set)
DrawModel ← {𝕊model‿position‿scale‿tint:
    rotationAxis ← 0‿1‿0
    rf.DrawModelEx⟨model, position, rotationAxis, 0, 3⥊scale, tint⟩
}