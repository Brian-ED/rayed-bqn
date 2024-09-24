⟨
  rl⇐raylib
  window
  model
  color
⟩ ← r ← •Import "../../rayed.bqn"


Game ← {𝕊:
  r.mouse.cursor.Disable@

  # Define the camera to look into our 3d world
  camera ← ⟨
    50‿50‿50  # Camera position
    0‿10‿0    # Camera looking at point
    0‿1‿0     # Camera up vector (rotation towards target)
    45        # Camera field-of-view Y
    r.cameraProjection.perspective # Camera mode type
  ⟩

  compressedFiles ← "OBJ/Map__5_Normal_Bump.tga"‿"OBJ/RubberDuck_LOD0.obj"
  {
    data ← •FBytes 𝕩∾".comp"
    p‿⟨s⟩ ← rl.DeCompressDataRef⟨data,≠data,⋈0⟩
    d ← (p.Cast "u8").Read¨↕s
    𝕩 •FBytes @+d
  }¨compressedFiles

  # A model consists of a matrix, meshes, materials, bones
  duck ← r.model.LoadFile •file.At "OBJ/RubberDuck_LOD0.obj"

  •file.Remove¨compressedFiles

  # run PerFrame while the window shouldn't close
  duck PerFrame•_While_(¬window.ShouldClose) camera

  # Unloading model, freeing it's memory.
  rl.UnloadModel duck
}

PerFrame ← {duck𝕊oldCamera:
  # Look for keystrokes from user, move the camera
  camera ← ⊑⊑rl.UpdateCameraRef ⟨⋈oldCamera⋄rl.cameraMode.camera_third_person⟩

  # Preparing another buffer to draw the new frame, with white background
  {𝕊:
    # Draws FPS at x=40 y=40
    rl.DrawFPS 40‿40

    # Draw 3d stuff relative to the camera
    rl.BeginMode3D camera

      # draws grid
      rl.DrawGrid 20‿10

      # Draw the duck model at position
      position ← 0‿0‿0 ⋄ scale ← 1
      rl.DrawModel duck‿position‿scale‿color.white

    # Stop drawing 3d
    rl.EndMode3D⟨⟩

  } r.draw._withCanvas_ r.color.white@

  camera # return the output state
}

Game window._openAs "Example!"