⟨
  GetCameraMatrix2D
⟩⇐
⟨MP⟩ ← rm ← •Import "raymath.bqn"

# Get camera 2d transform matrix
GetCameraMatrix2D ← {𝕊camera: # camera2d
  # The camera in world-space is set by
  #   1. Move it to target
  #   2. Rotate by -rotation and scale by (1/zoom)
  #      When setting higher scale, it's more intuitive for the world to become bigger (= camera become smaller),
  #      not for the camera getting bigger, hence the invert. Same deal with rotation.
  #   3. Move it by (-offset);
  #      Offset defines target transform relative to screen, but since we're effectively "moving" screen (camera)
  #      we need to do it into opposite direction (inverse transform)
    
  # Having camera transform in world-space, inverse of it gives the modelview transform.
  # Since (A*B*C)' = C'*B'*A', the modelview is
  #   1. Move to offset
  #   2. Rotate and Scale
  #   3. Move by -target
  origin      ← rm.MatrixTranslate-(1⊑camera)∾0
  rotation    ← rm.MatrixRotate 0‿0‿1⋈ π÷180×2⊑camera
  scale       ← rm.MatrixScale 1∾˜2⥊3⊑camera
  translation ← rm.MatrixTranslate 0∾˜⊑camera
  matTransform ← origin‿scale‿rotation MP´⊸MP translation
}
