⟨
  ⟨ReadI32 ⋄ ReadI8⟩⇐low
  rf⇐raylib
  ⟨
    GetShaderLocation ⋄ SetShaderValueRaw ⋄ SetShaderValue
    MemAlloc ⋄ MemFree
    ⟨ SHADER_UNIFORM_INT ⋄ SHADER_UNIFORM_VEC3 ⋄ SHADER_UNIFORM_Vec4
    ⟩⇐shaderUniformDataType
  ⟩⇐raylib
  ⟨black⋄white⋄raywhite⟩⇐color
  key⋄mouse
⟩ ← rl ← •Import "../../rayed.bqn"

shaderIndex ← { # Shader
  id   ⇐ 0 # u     # Shader program id
  locs ⇐ 1 # "*"∾i # Shader locations array (RL_MAX_SHADER_LOCATIONS)
}
# A few good julia sets
pointsOfInterest ← [
    ¯0.348827‿0.607167
    ¯0.786268‿0.169728
    ¯0.8‿0.156
     0.285‿0.0
    ¯0.835‿¯0.2321
    ¯0.70176‿¯0.3842
]

screenWidth ← 800
screenHeight ← 450
offsetSpeedMul ← 2

startingZoom ← 0.75

{𝕤
  # Load julia set shader
  shader ← rf.LoadShader •file.RealPath¨ "shaders/glsl330"⊸•file.At¨ "default.vs"‿"julia_set.fs"

  # Get some required shader locations
  veiwPos ← rf.GetShaderLocation shader‿"viewPos"
  {
    locsPtr ← shaderIndex.locs⊑shader
    rf.shaderLocationIndex.shader_loc_vector_view locsPtr.Write veiwPos
  }

  # Create a RenderTexture2D to be used for render to texture
  target ← rf.LoadRenderTexture rl.window.GetSize@

  # c constant to use in z^2 + c
  c ← ⊏pointsOfInterest

  # Offset and zoom to draw the julia set at. (centered on screen and default size)
  offset ← 0‿0
  zoom ← startingZoom

  # Get variable (uniform) locations on the shader to connect with the program
  # NOTE: If uniform variable could not be found in the shader, function returns -1
  cLoc      ← GetShaderLocation shader‿"c"
  zoomLoc   ← GetShaderLocation shader‿"zoom"
  offsetLoc ← GetShaderLocation shader‿"offset"
# Report to dzaima: &ref seem to accept pointer objects

  cv2 ← (rf.MemAlloc 8).Cast "f32"
  (↕2)cv2.Write¨c

  zoomFloat ← (rf.MemAlloc 4).Cast "f32"
  zoomFloat.Write zoom

  offsetV2 ← (rf.MemAlloc 8).Cast "f32"
  (↕2)offsetV2.Write¨offset

    (↕2)cv2.Write¨c

  # Upload the shader uniform values!
  rf.SetShaderValue⟨shader, cLoc     , cv2     , rf.shaderUniformDataType.shader_uniform_vec2 ⟩
  rf.SetShaderValue⟨shader, zoomLoc  , zoomFloat , rf.shaderUniformDataType.shader_uniform_float⟩
  rf.SetShaderValue⟨shader, offsetLoc, offsetV2, rf.shaderUniformDataType.shader_uniform_vec2 ⟩

  incrementSpeed ← 0 # Multiplier of speed to change c value
  showControls ← 1   # Show controls

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



  # Main game loop
  increment←0
  {𝕊:

    {𝕊:
      (↕2)cv2.Write¨𝕩
      SetShaderValue⟨shader, cLoc, cv2, rf.shaderUniformDataType.shader_uniform_vec2⟩
    }˘pointsOfInterest/˜key.IsPressed¨key.one+↕6

    # If "R" is pressed, reset zoom and offset.
    {
        zoomFloat.Write zoom
        (↕2)offsetV2.Write¨offset↩0‿0
        (↕2)zoomFloat.Write¨startingZoom
        SetShaderValue⟨shader, zoomLoc  , zoomFloat , rf.shaderUniformDataType.shader_uniform_float⟩
        SetShaderValue⟨shader, offsetLoc, offsetV2, rf.shaderUniformDataType.shader_uniform_vec2 ⟩
    }⍟key.IsPressed key.r

    incrementSpeed ×↩ ¬key.IsPressed key.space # Pause animation (c change)
    showControls   ≠↩  key.IsPressed key.f1    # Toggle whether or not to show controls

    increment +↩ key.right-○key.IsPressed key.left

    # If either left or right button is pressed, zoom in/out.
    {
      # Change zoom. If Mouse left -> zoom in. Mouse right -> zoom out.
      zoom ×↩ ⋆0.01×-´mouse.IsButtonDown mouse.button.left‿mouse.button.right
      mousePos ← mouse.GetPos@
      # Find the velocity at which to change the camera. Take the distance of the mouse
      # from the center of the screen as the direction, and adjust magnitude based on
      # the current zoom.
      offsetVelocity ← (0.5-˜mousePos÷rl.window.GetSize@)×offsetSpeedMul÷zoom

      # Apply move velocity to camera
      offset +↩ offsetVelocity÷rf.GetFrameTime⟨⟩

      # Update the shader uniform values!
      zoomFloat.Write zoom
      (↕2)offsetV2.Write¨offset↩0‿0

      SetShaderValue⟨shader, zoomLoc, zoomfloat,    rf.shaderUniformDataType.shader_uniform_float⟩
      SetShaderValue⟨shader, offsetLoc, offsetV2, rf.shaderUniformDataType.shader_uniform_vec2⟩
    }⍟rl.mouse.IsButtonDown mouse.button.right

    SetShaderValue⟨shader, cLoc, cv2, rf.shaderUniformDataType.shader_uniform_vec2⟩
    #----------------------------------------------------------------------------------

    # Draw the saved texture and rendered julia set with shader
    # NOTE: We do not invert texture on Y, already considered inside shader
    rf.BeginShaderMode shader
      # WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
      # when rendering the RenderTexture2D to fit in the HighDPI scaled Window
      texture ← 1
      rf.DrawTextureEx⟨texture⊑target, 0‿0, 0, 1, white⟩
    rf.EndShaderMode⟨⟩

    {rf.DrawText 𝕨‿10‿𝕩‿30‿raywhite}¨⟜(30×1+↕∘≠)⍟showControls ⟨
      "Press Mouse buttons right/left to zoom in/out and move"
      "Press KEY_F1 to toggle these controls"
      "Press KEYS [1 - 6] to change point of interest"
      "Press KEY_LEFT | KEY_RIGHT to change speed"
      "Press KEY_SPACE to stop movement animation"
      "Press KEY_R to recenter the camera"
    ⟩
  }rl.draw._withCanvas_ black •_while_ (¬rl.window.ShouldClose)@
  # De-Initialization
  #--------------------------------------------------------------------------------------
  rf.UnloadShader shader              # Unload shader
  rf.UnloadRenderTexture target        # Unload render texture

} rl.window._openAs "raylib [shaders] example - basic lighting"
