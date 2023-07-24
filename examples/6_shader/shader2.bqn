⟨color, window, draw, rayffi, key⟩←r←•Import "../../raylib.bqn"
⟨materialStruct⇐material⟩ ← rayffi
Show ← {•Out ('␀'-@)⊸+⌾((@=f)⊸/)f←•Fmt𝕩 ⋄ •term.Flush@ ⋄ 𝕩}

# Light type
###typedef enum {
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
    locs    ⇐ 1 # ptr (P i) # Shader locations array (RL_MAX_SHADER_LOCATIONS)
}

# Send light properties to shader
# NOTE: Light shader locations should be available 
#RLights END

rayffi.SetConfigFlags r.window.configFlags.msaa_4x_hint  # Enable Multi Sampling Anti Aliasing 4x (if available)

_withConsts ← {𝔽_𝕣 𝕩:
    # Define the camera to look into our 3d world
    camera ←⟨
        3‿3‿3   # position   # Camera position
        0‿1‿0÷2 # target     # Camera looking at point
        0‿1‿0   # up         # Camera up vector (rotation towards target)
        45      # fovy       # Camera field-of-view Y
        0       # projection # Camera projection type
    ⟩
    # Load plane model from a generated mesh
    model‿cube ← rayffi.LoadModelFromMesh¨⟨rayffi.GenMeshPlane 10‿10‿3‿3 
                                           rayffi.GenMeshCube  2‿4‿2⟩

    # Load basic lighting shader
    # loadShader ← "../../C/raylib/src/libraylib.so" •FFI "*:i8"‿"LoadShader"‿"*i8:c8"‿"*i8:c8"
    shader ← rayffi.LoadShader •file.At¨"lighting."⊸∾¨"vs"‿"fs"
    font ← r.font.LoadBQN 100
    # Get some required shader locations
    { # shader.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
        ptr ← shaderType.locs ⊑ shader
        movedPtr ← ptr r.rayffi.MovePtr˜8×r.shaderLocationIndex.vector_view
        
        movedPtr rayffi.Read˜⋈rayffi.GetShaderLocation shader⋈"viewPos"∾@
        
        # shader.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
    }
    # Ambient light level (some basic lighting)
    ambientLoc ← rayffi.GetShaderLocation shader⋈"ambient"∾@
    rayffi.SetShaderValue ⟨shader, ambientLoc, ÷10‿10‿10‿1, r.shaderUniformDataType.vec4⟩
    
    # Assign out lighting shader to model
    {shader rayffi.Read modelType.materials ⊑ 𝕩}¨model‿cube
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
            loc ← rayffi.GetShaderLocation shader⋈"lights["∾(•Repr lightsCount)∾"]."∾var∾@
            {𝕩⊣rayffi.SetShaderValue ⟨shader⋄loc⋄⥊𝕩⋄type⟩}
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
    font 𝔽 camera‿shader‿lights‿cube‿model
    r.font.Unload font
    rayffi.UnloadModel¨ model‿cube
    rayffi.UnloadShader shader
}

# Draw a model (with texture if set)
DrawModel ← {𝕊model‿position‿scale‿tint:
    rotationAxis ← 0‿1‿0
    rayffi.DrawModelEx⟨model, position, rotationAxis, 0, 3⥊scale, tint⟩
}

# Main game loop
PerFrame ← {font𝕊camera‿shader‿lights‿cube‿model:
    rayffi.UpdateCamera ⟨camera⟩‿r.cameramode.orbital # TODO may not work, &camera → ⟨camera⟩
    rayffi.SetShaderValue ⟨
        shader
        {
            locsPtr ← shaderType.locs⊑shader # shader.locs
            ⊑1 rayffi.MakeI32 (r.shaderLocationIndex.vector_view×4) rayffi.MovePtr locsPtr  # locsPtr[SHADER_LOC_VECTOR_VIEW]
        }
        ⊑camera
        r.shaderUniformDataType.vec3
    ⟩
    lights {𝕨.Toggle@}⍟(key.IsPressed⊢)¨⟨key.y⋄key.r⋄key.g⋄key.b⟩
    {𝕤
        DrawModel¨<⊸∾⟜⟨3⥊0 ⋄ 1 ⋄ color.white⟩¨cube‿model
        # Draw spheres to show where the lights are
        {𝕩.enabled? rayffi.DrawSphereEx 𝕩.position‿0.2‿8‿8‿(𝕩.color×255)
        ;           rayffi.DrawSphereWires 76⌾⊑⌾⌽⌾⊑⌾⌽ ⟨𝕩.position, 0.2, 8, 8, 𝕩.color×255⟩
        }¨lights
        rayffi.DrawGrid 10‿1
    } draw._in3D camera

    rayffi.DrawFPS 10‿10
    color.darkgray‿font‿30 draw.Text 10‿40⋈"Use keys [Y][R][G][B] to toggle lights"

    (key.right‿key.up‿key.e -○key.IsPressed key.left‿key.down‿key.q)⊸+⌾(⊑⊑)𝕩
}draw._withCanvas_ color.raywhite

Game ← PerFrame•_While_(¬window.ShouldClose) _withConsts
Game window._openAs "raylib [shaders] example - basic lighting"

