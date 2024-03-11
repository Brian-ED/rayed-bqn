⟨
  GetCameraMatrix2D ⋄ GetWorldToScreenEx ⋄ GetWorldToScreen
⟩⇐
⟨MP ⋄ Rot2D⇐MatrixRotate2D⟩ ← rm ← •Import "raymath.bqn"
rf ← •Import "../ffi/raylib.bqn"
⟨NeedsWindow⟩ ← •Import "global.bqn"
⟨rlgl ⋄ ⟨perspective⋄orthographic⟩⇐cameraProjection⟩ ← •Import "constants.bqn"

# Get camera 2d transform matrix
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

# Get camera 2d transform matrix
GetCameraMatrix2D ← {𝕊offset‿target‿rotation‿zoom: # camera2d
  translation‿origin ← rm.MatrixTranslate¨∾⟜0¨offset⋈-target
  origin MP translation MP˜ rm._ToDim_ 4 zoom×Rot2D rm.deg2rad×rotation
}

# Get the screen space position from a 3d world space position
GetWorldToScreen ← {𝕊position‿camera: # v3‿cam3d
  NeedsWindow@
  screenPos ← GetWorldToScreenEx⟨position, camera, rf.GetScreenWidth⟨⟩, rf.GetScreenHeight⟨⟩⟩
}

# Get size position for a 3d world space position (useful for texture drawing)
# ScreenSize is optional, if not given it's calculated automatically
GetWorldToScreenEx ← {pos‿⟨position⋄target⋄up⋄fovy⋄projection⟩‿width‿height:

  # Calculate projection matrix (from perspective instead of frustum
  matProj ← {
    0: # perspective
      # Calculate projection matrix from perspective
      rm.MatrixPerspective⟨fovy×rm.deg2rad, width÷height, rlgl.cull_distance_near, rlgl.cull_distance_far⟩
  ;
    1: # orthographic
      top ← fovy÷2
      right ← top×width÷height

      # Calculate projection matrix from orthographic
      rm.MatrixOrtho⟨-right, right, -top, top, rlgl.cull_distance_near, rlgl.cull_distance_far⟩
  } projection

  # Calculate view matrix from camera look at
  matView ← rm.MatrixLookAt⟨position, target, up⟩

  # Transform world position to view then Transform result to projection (clip space position)
  worldPos ← matProj MP˜ matView MP˜ pos∾1

  # Calculate normalized device coordinates (inverted y)
  # Calculate 2d screen position vector
  width‿height×2÷˜1+-⌾(1⊸⊑)2↑worldPos
}


