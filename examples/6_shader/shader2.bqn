⟨color, window, draw, rayffi, key⟩←r←•Import "../../raylib.bqn"
⟨materialStruct⇐material⟩ ← rayffi
Show ← {•Out ('␀'-@)⊸+⌾((@=f)⊸/)f←•Fmt𝕩 ⋄ •term.Flush@ ⋄ 𝕩}

# RLights

# Light data
###typedef struct {   
###    int type;
###    bool enabled;
###    Vector3 position;
###    Vector3 target;
###    Color color;
###    float attenuation;
###    
###    # Shader locations
###    int enabledLoc;
###    int typeLoc;
###    int positionLoc;
###    int targetLoc;
###    int colorLoc;
###    int attenuationLoc;
###} Light;

# LightToArr ← {l:⟨
#     l.type
#     l.enabled
#     l.position
#     l.target
#     l.color
#     l.attenuation
# 
#     l.enabledLoc
#     l.typeLoc
#     l.positionLoc
#     l.targetLoc
#     l.colorLoc
#     l.attenuationLoc
# ⟩}

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

# Create a light and get shader locations
CreateLight ⇐ 4⊸⊑{shader𝕊𝕩:UpdateLightValues shader‿𝕩⋄𝕩}{
    𝕊⟨
        type        # int
        position    # Vector3
        target      # Vector3
        color       # Color
        shader      # Shader
        lightsCount # int
    ⟩:
    type‿position‿target‿color⇐
    enabled ⇐ 1
    SetType     ⇐ {type     ↩ 𝕩}
    SetPosition ⇐ {position ↩ 𝕩}
    SetTarget   ⇐ {target   ↩ 𝕩}
    SetColor    ⇐ {color    ↩ 𝕩}

    # NOTE: Lighting shader naming must be the provided ones
    F ← rayffi.GetShaderLocation shader⋈@∾˜("lights["∾"]."∾˜•Repr lightsCount)⊸∾
    enabledLoc  ⇐ F "enabled"
    typeLoc     ⇐ F "type"
    positionLoc ⇐ F "position"
    targetLoc   ⇐ F "target"
    colorLoc    ⇐ F "color"
    Toggle ⇐ {𝕊:enabled¬↩}
}

# Send light properties to shader
# NOTE: Light shader locations should be available 
UpdateLightValues ← {shader‿light:
    # Send light to shader
    F ← rayffi.SetShaderValue⟨shader⟩⊸∾
    su ← r.shaderUniformDataType
    F ⟨light.enabledLoc , ⋈light.enabled , su.int ⟩ # TODO: may not work. replaced & at light.enabled with ⋈
    F ⟨light.typeLoc    , ⋈light.type    , su.int ⟩ # TODO: may not work. replaced & at light.type with ⋈
    F ⟨light.positionLoc, light.position , su.vec3⟩
    F ⟨light.targetLoc  , light.target   , su.vec3⟩
    F ⟨light.colorLoc   , light.color÷255, su.vec4⟩
}
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
    model ← rayffi.LoadModelFromMesh rayffi.GenMeshPlane 10‿10‿3‿3
    cube  ← rayffi.LoadModelFromMesh rayffi.GenMeshCube  2 ‿4 ‿2

    # Load basic lighting shader
    # loadShader ← "../../C/raylib/src/libraylib.so" •FFI "*:i8"‿"LoadShader"‿"*i8:c8"‿"*i8:c8"
    shader ← rayffi.LoadShader@∾˜¨"lighting."⊸∾¨"vs"‿"fs"
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
    lights ← CreateLight¨↕∘≠⊸({l𝕊a‿b:⟨lightType.point⋄a⋄3⥊0⋄b⋄shader⋄l⟩}¨)⟨
        ¯2‿1‿¯2 ⋈ color.yellow
         2‿1‿ 2 ⋈ color.red
        ¯2‿1‿ 2 ⋈ color.green
         2‿1‿¯2 ⋈ color.blue
    ⟩
    font 𝔽 camera‿shader‿lights‿cube‿model
    r.font.Unload font
    rayffi.UnloadModel¨ model‿cube
    rayffi.UnloadShader shader
}

# Main game loop
PerFrame ← {font𝕊camera‿shader‿lights‿cube‿model:
    # Update
    #----------------------------------------------------------------------------------
    rayffi.UpdateCamera ⟨camera⟩‿r.cameramode.orbital # TODO may not work, &camera → ⟨camera⟩

    # Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    rayffi.SetShaderValue ⟨
        shader
        {
            locsPtr ← shaderType.locs⊑shader # shader.locs
            ¯1⊑locsPtr rayffi.MakeI32˜1+r.shaderLocationIndex.vector_view  # locsPtr[SHADER_LOC_VECTOR_VIEW]
        }
        ⊑camera
        r.shaderUniformDataType.vec3
    ⟩

    # Check key inputs to enable/disable lights
    lights {𝕨.Toggle@}⍟(key.IsPressed⊢)¨⟨key.y⋄key.r⋄key.g⋄key.b⟩
    
    # Update light values (actually, only enable/disable them)
    (UpdateLightValues shader⊸⋈)¨lights
    #----------------------------------------------------------------------------------

    # Draw
    #----------------------------------------------------------------------------------
    {𝕤
        {𝕤
            rayffi.DrawModel ⟨cube ⋄ 3⥊0 ⋄ 1 ⋄ color.white⟩
            rayffi.DrawModel ⟨model ⋄ 3⥊0 ⋄ 1 ⋄ color.white⟩

            # Draw spheres to show where the lights are
            {𝕩.enabled? rayffi.DrawSphereEx 𝕩.position‿0.2‿8‿8‿𝕩.color
            ;           rayffi.DrawSphereWires ⟨𝕩.position, 0.2, 8, 8, ∾⟜76 3↑𝕩.color⟩
            }¨lights

            rayffi.DrawGrid 10‿1

        } draw._in3D camera

        rayffi.DrawFPS 10‿10

        color.darkgray‿font‿30 draw.Text 10‿40⋈"Use keys [Y][R][G][B] to toggle lights"

    }draw._withCanvas_ color.raywhite@
    (key.right‿key.up‿key.e -○key.IsPressed key.left‿key.down‿key.q)⊸+⌾(⊑⊑)𝕩
}

Game ← PerFrame•_While_(¬window.ShouldClose) _withConsts
Game window._openAs "raylib [shaders] example - basic lighting"

