⟨
  rf⇐raylib
  ⟨
    GetShaderLocation ⋄ SetShaderValue
    MemAlloc ⋄ MemFree
  ⟩⇐raylib
  black‿white‿raywhite⇐color
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

offsetSpeedMul ← 2

startingZoom ← 0.75
zoomSpeed ← 1.01

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

  cv2‿zoomFloat‿offsetV2 ← {
    p←(rf.MemAlloc 4×≠𝕩).Cast "f32"
    p⊣p.WriteList 𝕩
  }¨ c‿⟨zoom⟩‿offset

  # Upload the shader uniform values!
  rf.SetShaderValue⟨shader, cLoc     , cv2      , rf.shaderUniformDataType.shader_uniform_vec2 ⟩
  rf.SetShaderValue⟨shader, zoomLoc  , zoomFloat, rf.shaderUniformDataType.shader_uniform_float⟩
  rf.SetShaderValue⟨shader, offsetLoc, offsetV2 , rf.shaderUniformDataType.shader_uniform_vec2 ⟩

  incrementSpeed ← 0 # Multiplier of speed to change c value
  showControls ← 1   # Show controls



  # Main game loop
  increment←0
  {𝕊:
    {𝕊:
      cv2.WriteList 𝕩
      SetShaderValue⟨shader, cLoc, cv2, rf.shaderUniformDataType.shader_uniform_vec2⟩
    }˘pointsOfInterest/˜key.IsPressed¨key.one+↕6

    # If "R" is pressed, reset zoom and offset.
    {𝕊:
      zoomFloat.Write zoom↩startingZoom
      offsetV2.WriteList offset↩0‿0
      SetShaderValue⟨shader, zoomLoc  , zoomFloat, rf.shaderUniformDataType.shader_uniform_float⟩
      SetShaderValue⟨shader, offsetLoc, offsetV2 , rf.shaderUniformDataType.shader_uniform_vec2 ⟩
    }⍟key.IsPressed key.r

    incrementSpeed ×↩ ¬key.IsPressed key.space # Pause animation (c change)
    showControls   ≠↩  key.IsPressed key.f1    # Toggle whether or not to show controls

    incrementSpeed +↩ -´key.IsPressed key.right‿key.left


    # If either left or right button is pressed, zoom in/out
    {𝕊:
      # Change zoom. If Mouse left -> zoom in. Mouse right -> zoom out
      zoom ×↩ {mouse.button.IsDown mouse.button.left ? zoomSpeed ; ÷zoomSpeed}
      zoomFloat.Write zoom

      mousePos ← mouse.GetPos@

      # Find the velocity at which to change the camera. Take the distance of the mouse
      # from the center of the screen as the direction, and adjust magnitude based on the current zoom
      offsetVelocity ← (¯0.5+mousePos÷rl.window.GetSize@)×offsetSpeedMul×÷zoom

      # Apply move velocity to camera
      offset +↩ offsetVelocity×rf.GetFrameTime⟨⟩
      offsetV2.WriteList offset

      # Update the shader uniform values!
      SetShaderValue⟨shader, zoomLoc, zoomfloat,    rf.shaderUniformDataType.shader_uniform_float⟩
      SetShaderValue⟨shader, offsetLoc, offsetV2, rf.shaderUniformDataType.shader_uniform_vec2⟩
    }⍟⊢ ∨´mouse.button.IsDown mouse.button.left‿mouse.button.right

    # Increment c value with time
    dc ← (rf.GetFrameTime⟨⟩)×incrementSpeed×0.0005
    c +↩ dc
    cv2.WriteList c
    SetShaderValue⟨shader, cLoc, cv2, rf.shaderUniformDataType.shader_uniform_vec2⟩
    #----------------------------------------------------------------------------------

    # Draw
    #----------------------------------------------------------------------------------
    # Using a render texture to draw Julia set
    {𝕊:
      # Draw the saved texture and rendered julia set with shader
      # NOTE: We do not invert texture on Y, already considered inside shader
      {𝕊:
        # WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
        # when rendering the RenderTexture2D to fit in the HighDPI scaled Window
        texture ← 1
        rf.DrawTextureEx⟨texture⊑target, 0‿0, 0, 1, white⟩
      } rl.draw._withShader shader

      {rf.DrawText 𝕨‿10‿𝕩‿30‿raywhite}¨⟜(30×1+↕∘≠)⍟showControls ⟨
        "Press Mouse buttons right/left to zoom in/out and move"
        "Press KEY_F1 to toggle these controls"
        "Press KEYS [1 - 6] to change point of interest"
        "Press KEY_LEFT | KEY_RIGHT to change speed"
        "Press KEY_SPACE to stop movement animation"
        "Press KEY_R to recenter the camera"
      ⟩
    } rl.draw._withCanvas⟜black @

  } •_while_ (¬rl.window.ShouldClose)@
  # De-Initialization
  #--------------------------------------------------------------------------------------
  rf.UnloadShader shader              # Unload shader
  rf.UnloadRenderTexture target       # Unload render texture
  MemFree¨ cv2‿zoomFloat‿offsetV2

} rl.window._openAs "raylib [shaders] example - basic lighting"
