⟨MP⋄MatrixLookAt
 MatrixScale⋄MatrixRotate
 GetCameraMatrix2D
⟩⇐

⟨MP⟩ ← •Import "imports/bqn-libs/matrix.bqn"

# Get camera look-at matrix (view matrix)
# returns Matrix
MatrixLookAt ← {𝕊eye‿target‿up: # v3 v3 v3
  vz ← {𝕩÷1⍟(0=⊢)+´⌾(⋆⟜2)𝕩} eye-target
  vx ← {𝕩÷1⍟(0=⊢)+´⌾(⋆⟜2)𝕩} -´×´˘1‿¯1⌽⌜up‿vz
  vy ← -´×´˘1‿¯1⌽⌜vz‿vx

  [
    ⟨vx.x ⋄ vy.x ⋄ vz.x ⋄ 0⟩
    ⟨vx.y ⋄ vy.y ⋄ vz.y ⋄ 0⟩
    ⟨vx.z ⋄ vy.z ⋄ vz.z ⋄ 0⟩
    1∾˜-eye⊸×¨vx‿vy‿vz
  ]
}

# Get translation matrix
MatrixTranslate ← {𝕊x‿y‿z:[# v3 → Matrix
  1‿0‿0‿x
  0‿1‿0‿y
  0‿0‿1‿z
  0‿0‿0‿1
]}

# Get scaling matrix
MatrixScale ← {𝕊x‿y‿z:(1+4↑𝕩-1)⌾(0‿0⊸⍉)4‿4⥊0}

# Create rotation matrix from axis and angle
# NOTE: Angle should be provided in radians
MatrixRotate ← {𝕊axis‿angle: # v3 f
  x‿y‿z ← (+´axis⋆2)÷⟜√˜⍟(∧´2↕⊸≠⊣)axis

  sinres ← •math.Sin angle
  cosres ← •math.Cos angle
  m ← ((¬cosres)××⌜˜x‿y‿z)+(cosres¨⌾(0‿0⊸⍉)3‿3⥊sinres)×[
    ⟨ 1 ⋄-z ⋄ y⟩
    ⟨ z ⋄ 1 ⋄-x⟩
    ⟨-y ⋄ x ⋄ 1⟩
  ]
  ∾[m‿⟨0,0,0⟩
    ⟨0‿0‿0⋄1⟩]
}


### rcore.c functions

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
  origin      ← MatrixTranslate-(1⊑camera)∾0
  rotation    ← MatrixRotate 0‿0‿1⋈ π÷180×2⊑camera
  scale       ← MatrixScale 1∾˜2⥊3⊑camera
  translation ← MatrixTranslate 0∾˜⊑camera
  matTransform ← origin‿scale‿rotation MP´⊸MP translation
}