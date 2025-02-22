# rcamera - Basic camera system with support for multiple camera modes

⟨
  GetForward
  GetUp
  GetRight

  # Camera movement
  MoveForward
  MoveUp
  MoveRight
  MoveToTarget

  # Camera rotation
  Yaw
  Pitch
  Roll

  GetViewMatrix
  GetProjectionMatrix
  MakeGetProjectionMatrix

  Update

  mode
  projection
  index
⟩⇐

key‿mouse‿raylib‿math ← •args

⟨
  up, left, down, right
  w, a, s, d, e, q
  space, left_control, IsPressed, keypad,
  IsDown
⟩ ← key

⟨
  GetFrameTime
  GetMouseDelta
  gamepadAxis
  GetGamepadAxisMovement
  IsGamepadAvailable
⟩ ← raylib
⟨
  Vector3RotateByAxisAngle
  VectorAngle
  MatrixLookAt
  MatrixPerspective
  MatrixOrtho
  deg2rad
  MP
  MatrixRotate
⟩ ← math

mode ← { # Camera system modes
  custom       ⇐ 0  # Custom camera
  free         ⇐ 1  # Free camera
  orbital      ⇐ 2  # Orbital camera
  first_person ⇐ 3  # First person camera
  third_person ⇐ 4  # Third person camera
}

projection ⇐ { # Camera projection
  perspective  ⇐ 0  # Perspective projection
  orthographic ⇐ 1  # Orthographic projection
}

index ⇐ {
  position   ⇐ 0 # Camera position
  target     ⇐ 1 # Camera target it looks-at
  up         ⇐ 2 # Camera up vector (rotation over its axis)
  fovy       ⇐ 3 # Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
  projection ⇐ 4 # Camera projection: projection.perspective or projection.orthographic
}


#----------------------------------------------------------------------------------
# Module Functions Definition
#----------------------------------------------------------------------------------
# Returns the cameras forward vector (normalized)
GetForward ← {𝕊camera:
  ÷⟜(0⊸=⊸++´⌾(×˜))-´index.target‿index.position⊏𝕩
}

# Returns the cameras up vector (normalized)
# Note: The up vector might not be perpendicular to the forward vector
GetUp ← {𝕊camera:
  ÷⟜(0⊸=⊸++´⌾(×˜)) index.up⊑𝕩
}

# Returns the cameras right vector (normalized)
GetRight ← {𝕊camera:
  (GetForward camera) 1⊸⌽⊸×{1⌽𝔽˜-𝔽} GetUp camera
}

# Moves the camera in its forward direction
MoveForward ← {distance𝕊camera:

  forward ← GetForward camera

  # Move position and target
  (forward×distance)⊸+¨⌾(index.position‿index.target⊸⊏) camera
}

# Moves the camera in its forward direction
MoveForwardInWorldPlane ← {distance𝕊camera:

  # Project vector onto world plane
  forward ← ÷⟜(0⊸=⊸++´⌾(×˜)) 0⌾(1⊸⊑) GetForward camera

  # Move position and target
  (forward×distance)⊸+¨⌾(index.position‿index.target⊸⊏) camera
}

# Moves the camera in its up direction
MoveUp ← {distance𝕊camera:
  (distance×GetUp camera)⊸+¨⌾(index.position‿index.target⊸⊏)camera
}

# Moves the camera target in its current right direction
MoveRight ← {distance𝕊camera:
  right ← GetRight camera

  # Scale by distance
  (right×distance)⊸+¨⌾(index.position‿index.target⊸⊏)camera
}

# Moves the camera target in its current right direction
MoveRightInWorldPlane ← {distance𝕊camera:
  # Project vector onto world plane
  right ← ÷⟜(0⊸=⊸++´⌾(×˜)) 0⌾(1⊸⊑) GetRight camera

  # Scale by distance
  (right×distance)⊸+¨⌾(index.position‿index.target⊸⊏)camera
}

# Moves the camera position closer/farther to/from the camera target
MoveToTarget ← {delta𝕊camera:
  distance ← delta++´⌾(×˜)-´index.position‿index.target⊏camera

  # Set new distance by moving the position along the forward vector
  forward ← distance×GetForward camera
  (forward -˜ index.target⊑camera)⌾(index.position⊸⊑)camera
}

# Rotates the camera around its up vector
# Yaw is "looking left and right"
# If rotateAroundTarget is false, the camera rotates around its position
# Note: angle must be provided in radians
Yaw ← {angle‿rotateAroundTarget𝕊camera:
  up ← GetUp camera # Rotation axis

  # View vector
  targetPosition ← -´index.target‿index.position⊏camera

  # Rotate view vector around up axis
  targetPosition Vector3RotateByAxisAngle˜↩up‿angle

  {rotateAroundTarget?
    # Move position relative to target
    (targetPosition -˜ index.target⊑camera)⌾(index.position⊸⊑)camera
  ;
    # rotate around camera.position
    # Move target relative to position
    (targetPosition + index.position⊑camera)⌾(index.target⊸⊑)camera
  }
}

# Rotates the camera around its right vector, pitch is "looking up and down"
#  - lockView prevents camera overrotation (aka "somersaults")
#  - rotateAroundTarget defines if rotation is around target or around its position
#  - rotateUp rotates the up direction as well (typically only useful in mode.free)
# NOTE: angle must be provided in radians
Pitch ← {angle‿lockView‿rotateAroundTarget‿rotateUp𝕊camera:
  # View vector
  targetPosition ← -´index.target‿index.position⊏camera

  angle {
    up ← GetUp camera
    # In these camera modes we clamp the Pitch angle
    # to allow only viewing straight up or down.

    # Clamp view up
    𝕩 ⌊↩ ¯0.001+up VectorAngle targetPosition

    # Clamp view down
    𝕩 ⌈ 0.001-(-up) VectorAngle targetPosition
  }⍟lockView ↩

  # Rotation axis
  right ← GetRight camera

  # Rotate view vector around right axis
  targetPosition Vector3RotateByAxisAngle˜↩right‿angle

  camera {rotateAroundTarget?
    # Move position relative to target
    (targetPosition -˜ index.target⊑𝕩)⌾(index.position⊸⊑) 𝕩
  ;
    # rotate around camera.position
    # Move target relative to position
    (targetPosition + index.position⊑𝕩)⌾(index.target⊸⊑) 𝕩
  } ↩

  # Rotate up direction around right axis
  right‿angle⊸Vector3RotateByAxisAngle⌾(index.up⊸⊑)⍟rotateUp camera
}

# Rotates the camera around its forward vector
# Roll is "turning your head sideways to the left or right"
# Note: angle must be provided in radians
Roll ← {angle𝕊camera:
  # Rotation axis
  forward ← GetForward camera

  # Rotate up direction around forward axis
  forward‿angle⊸Vector3RotateByAxisAngle⌾(index.up⊸⊑)camera
}

# Returns the camera view matrix
GetViewMatrix ← {𝕊camera:
  MatrixLookAt index.position‿index.target‿index.up⊏camera
}

# Make GetProjectionMatrix with your own camera cull distance
MakeGetProjectionMatrix ← {𝕊cull_distance_near‿cull_distance_far:
  {aspect𝕊camera:
    { 𝕩 ≡ projection.perspective?
      MatrixPerspective⟨deg2rad×index.fovy⊑camera, aspect, cull_distance_near, cull_distance_far⟩

    ; 𝕩 ≡ projection.orthographic?
      top ← 2÷˜index.fovy⊑camera
      right ← top×aspect

      MatrixOrtho⟨-right, right, -top, top, cull_distance_near, cull_distance_far⟩
    ;
      =⌜˜↕4
    }index.projection⊑camera
  }
}

# Default cull distance
GetProjectionMatrix ← MakeGetProjectionMatrix {𝔽𝕘}0.01‿1000

MakeUpdater ← {𝕊⟨
    orbital_speed
    rotation_speed
    move_speed
    pan_speed
    mouse_move_sensitivity
    mouse_scroll_sensitivity
  ⟩:

  cm ← mode
  {mode𝕊camera:
    moveInWorldPlane   ← ∨´mode=cm.third_person                  ‿cm.first_person
    rotateAroundTarget ← ∨´mode=cm.third_person‿cm.orbital
    lockView           ← ∨´mode=cm.third_person‿cm.orbital‿cm.first_person‿cm.free
    rotateUp           ← 0

    mouseDelta ← GetMouseDelta⟨⟩

    {mode=cm.orbital?
      # Orbital can just orbit
      camera Yaw˜↩1⋈˜orbital_speed×GetFrameTime⟨⟩
    ;
      frameAdjusting ← 60×GetFrameTime⟨⟩
      # Camera rotation
      camera Pitch˜↩ ⟨frameAdjusting×rotation_speed×-´IsDown¨up‿down , lockView, rotateAroundTarget, rotateUp⟩
      camera Yaw  ˜↩ ⟨frameAdjusting×rotation_speed×-´IsDown¨left‿right, rotateAroundTarget⟩
      camera Roll ˜↩  frameAdjusting×rotation_speed×-´IsDown¨e‿q

      right   ← moveInWorldPlane⊑MoveRight‿MoveRightInWorldPlane
      forward ← moveInWorldPlane⊑MoveForward‿MoveForwardInWorldPlane

      # Camera movement
      # Camera pan (for camera.free)
      {(mode = cm.free) ∧ mouse.IsButtonDown mouse.button.middle?
        camera Right       ˜↩  pan_speed××0⊑mouseDelta
        camera MoveUp˜↩ -pan_speed××1⊑mouseDelta
      ;
        # Mouse support
        camera Yaw  ˜↩⟨-mouse_move_sensitivity×0⊑mouseDelta, rotateAroundTarget⟩
        camera Pitch˜↩⟨-mouse_move_sensitivity×1⊑mouseDelta, lockView, rotateAroundTarget, rotateUp⟩
      }

      # Keyboard support
      camera Forward˜↩ frameAdjusting × move_speed×-´IsDown¨w‿s
      camera Right  ˜↩ frameAdjusting ×-move_speed×-´IsDown¨a‿d

      # Gamepad movement
      {𝕤
        G ← GetGamepadAxisMovement 0⊸⋈

        # Gamepad controller support
        camera Yaw  ˜↩⟨mouse_move_sensitivity×¯20×G gamepadAxis.gamepad_axis_right_x,           rotateAroundTarget⟩
        camera Pitch˜↩⟨mouse_move_sensitivity×¯20×G gamepadAxis.gamepad_axis_right_y, lockView, rotateAroundTarget, rotateUp⟩

        camera Forward⍟(¯0.25≥G gamepadAxis.gamepad_axis_left_y)˜↩ frameAdjusting ×  move_speed
        camera Forward⍟( 0.25≤G gamepadAxis.gamepad_axis_left_y)˜↩ frameAdjusting × -move_speed
        camera Right  ⍟(¯0.25≥G gamepadAxis.gamepad_axis_left_x)˜↩ frameAdjusting × -move_speed
        camera Right  ⍟( 0.25≤G gamepadAxis.gamepad_axis_left_x)˜↩ frameAdjusting ×  move_speed
      }⍟⊢ IsGamepadAvailable 0

      {𝕤
        camera MoveUp⍟(IsDown space       )˜↩ frameAdjusting ×  move_speed
        camera MoveUp⍟(IsDown left_control)˜↩ frameAdjusting × -move_speed
      }⍟⊢mode=cm.free
    }

    {𝕊:
      # Zoom target distance
      camera MoveToTarget˜↩-mouse.WheelMoved@
      camera MoveToTarget˜↩2×-´IsPressed¨keypad.subtract‿keypad.add
    }⍟⊢∨´mode=cm.third_person‿cm.orbital
    camera
  }
}

update ← MakeUpdater {
  orbital_speed  ⇐ 0.5
  rotation_speed ⇐ 0.03 # Radians per second
  move_speed     ⇐ 0.09
  pan_speed      ⇐ 0.2

  # Camera mouse movement sensitivity
  mouse_move_sensitivity   ⇐ 0.003     # TODO: it should be independant of framerate
  mouse_scroll_sensitivity ⇐ 1.5
}


# Update camera movement, movement/rotation values should be provided by user
UpdatePro ← {movement‿rotation‿zoom𝕊camera:
  # Required values
  # movement.x - Move forward/backward
  # movement.y - Move right/left
  # movement.z - Move up/down
  # rotation.x - yaw
  # rotation.y - pitch
  # rotation.z - roll
  # zoom - Move towards target

  lockView           ← 1
  rotateAroundTarget ← 0
  rotateUp           ← 0
  moveInWorldPlane   ← 1

  # Camera rotation
  camera Yaw  ˜↩⟨-deg2rad×0⊑rotation, rotateAroundTarget⟩
  camera Pitch˜↩⟨-deg2rad×1⊑rotation, lockView, rotateAroundTarget, rotateUp⟩
  camera Roll ˜↩  deg2rad×2⊑rotation

  # Camera movement
  camera MoveForwardInWorldPlane˜↩ 0⊑movement
  camera MoveRightInWorldPlane  ˜↩ 1⊑movement
  camera MoveUp                 ˜↩ 2⊑movement

  # Zoom target distance
  MoveToTarget camera‿zoom
}
