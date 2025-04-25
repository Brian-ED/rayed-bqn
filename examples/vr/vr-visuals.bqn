r ← •Import "../../rayed.bqn"

# Initialization
#--------------------------------------------------------------------------------------

# VR device parameters definition
device ← ⟨
    # Oculus Rift CV1 parameters for simulator
    2160     # Horizontal resolution in pixels
    1200     # Vertical resolution in pixels
    0.133793 # Horizontal size in meters
    0.0669   # Vertical size in meters
    0.041    # Distance between eye and display in meters
    0.07     # Lens separation distance in meters
    0.07     # IPD (distance between pupils) in meters

    # NOTE: CV1 uses fresnel-hybrid-asymmetric lenses with specific compute shaders
    # Following parameters are just an approximation to CV1 distortion stereo rendering
    1‿0.22‿0.24‿0          # Lens distortion
    0.996‿¯0.004‿1.014‿0   # Chromatic aberration correction
⟩
deviceIndex ← {
  hResolution            ⇐ 0 # Horizontal resolution in pixels
  vResolution            ⇐ 1 # Vertical resolution in pixels
  hScreenSize            ⇐ 2 # Horizontal size in meters
  vScreenSize            ⇐ 3 # Vertical size in meters
  eyeToScreenDistance    ⇐ 4 # Distance between eye and display in meters
  lensSeparationDistance ⇐ 5 # Lens separation distance in meters
  interpupillaryDistance ⇐ 6 # IPD (distance between pupils) in meters
  lensDistortionValues   ⇐ 7 # Lens distortion constant parameters
  chromaAbCorrection     ⇐ 8 # Chromatic aberration correction parameters
}

# Load VR stereo config for VR device parameteres (Oculus Rift CV1 parameters)
config ← r.raylib.LoadVrStereoConfig device
configIndex ← {
  projection        ⇐ 0 # VR projection matrices (per eye)
  viewOffset        ⇐ 1 # VR view offset matrices (per eye)
  leftLensCenter    ⇐ 2 # VR left lens center
  rightLensCenter   ⇐ 3 # VR right lens center
  leftScreenCenter  ⇐ 4 # VR left screen center
  rightScreenCenter ⇐ 5 # VR right screen center
  scale             ⇐ 6 # VR distortion scale
  scaleIn           ⇐ 7 # VR distortion scale in
}

renderTextureIndex ← {
  id      ⇐ 0 # OpenGL framebuffer object id
  texture ⇐ 1 # Color buffer attachment texture
  depth   ⇐ 2 # Depth buffer attachment texture
}

textureIndex ← {
  id      ⇐ 0 # OpenGL texture id
  width   ⇐ 1 # Texture base width
  height  ⇐ 2 # Texture base height
  mipmaps ⇐ 3 # Mipmap levels, 1 by default
  format  ⇐ 4 # Data format (PixelFormat type)
}


ArrAlloc ← {
  p ← (r.raylib.MemAlloc 4×≠𝕩).Cast "f32"
  (↕≠𝕩) p.Write¨𝕩
  p
}

# NOTE: screenWidth/screenHeight should match VR device aspect ratio
r.window.SetSize 800‿450

{𝕊:

  # Distortion shader (uses device lens distortion and chroma)
  d ← r.raylib.LoadShader •file.RealPath¨ "default.vs"‿"distortion330.fs"

  ⟨v4⇐shader_uniform_vec4
  ⋄v2⇐shader_uniform_vec2⟩← r.raylib.shaderUniformDataType

  # Update distortion shader with lens and distortion-scale parameters
  r.raylib.SetShaderValue¨r.raylib.GetShaderLocation⌾(1⊸⊑)¨∾⟨
    {⟨d⋄d‿𝕨⋄ArrAlloc𝕩⊑config⋄v2⟩}´¨⟨
      "leftLensCenter"   ‿configIndex.leftLensCenter
      "rightLensCenter"  ‿configIndex.rightLensCenter
      "leftScreenCenter" ‿configIndex.leftScreenCenter
      "rightScreenCenter"‿configIndex.rightScreenCenter
      "scale"            ‿configIndex.scale
      "scaleIn"          ‿configIndex.scaleIn
    ⟩
    {⟨d⋄d‿𝕨⋄ArrAlloc𝕩⊑device⋄v4⟩}´¨⟨
      "deviceWarpParam"‿deviceIndex.lensDistortionValues
      "chromaAbParam"  ‿deviceIndex.chromaAbCorrection
    ⟩
  ⟩
  # Initialize framebuffer for stereo rendering
  # NOTE: Screen size should match HMD aspect ratio
  target ← r.raylib.LoadRenderTexture device⊏˜{𝕩.hResolution‿𝕩.vResolution}deviceIndex

  # Define the camera to look into our 3d world
  camera ← ⟨
    5‿2‿5              # Camera position
    0‿2‿0              # Camera looking at point
    0‿1‿0              # Camera up vector
    60                 # Camera field-of-view Y
    r.raylib.cameraProjection.camera_perspective # Camera projection type
  ⟩
  cubePosition ← 0‿0‿0

  r.raylib.DisableCursor⟨⟩ # Limit cursor to relative movement inside the window

  # Main game loop
  # Detect window close button or ESC key
  {𝕊
      # Update
      #----------------------------------------------------------------------------------
      ⟨⟨camera⟩⟩ ↩ r.raylib.UpdateCameraRef⟨⋈camera, r.raylib.cameraMode.cameraFirstPerson⟩
      #----------------------------------------------------------------------------------

      # Draw
      #----------------------------------------------------------------------------------
      r.raylib.BeginTextureMode target
        r.raylib.ClearBackground r.color.raywhite
        r.raylib.BeginVrStereoMode config
          r.raylib.BeginMode3D camera
            r.raylib.DrawCube cubePosition‿2‿2‿2‿r.color.red
            r.raylib.DrawCubeWires cubePosition‿2‿2‿2‿r.color.maroon
            r.raylib.DrawGrid 40‿1
          r.raylib.EndMode3D⟨⟩
        r.raylib.EndVrStereoMode⟨⟩
      r.raylib.EndTextureMode⟨⟩

      r.raylib.BeginDrawing⟨⟩
        r.raylib.ClearBackground r.color.raywhite
        r.raylib.BeginShaderMode d
          r.raylib.DrawTexturePro⟨
            renderTextureIndex.texture⊑ target
            0‿0∾ ⋈⟜-´ textureIndex.width‿textureIndex.height⊏ renderTextureIndex.texture⊑ target # source
            0‿0∾r.window.GetSize@ # dest
            0‿0, 0, r.color.white
          ⟩
        r.raylib.EndShaderMode⟨⟩
        r.raylib.DrawFPS 10‿10
      r.raylib.EndDrawing⟨⟩
      #----------------------------------------------------------------------------------
  } •_while_ (¬r.window.ShouldClose)@

  # De-Initialization
  #--------------------------------------------------------------------------------------
  r.raylib.UnloadVrStereoConfig config   # Unload stereo config

  r.raylib.UnloadRenderTexture target    # Unload stereo render fbo
  r.raylib.UnloadShader d       # Unload distortion shader
} r.window._openAs "raylib [core] example - vr simulator"
