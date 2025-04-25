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
  Rotate‿RotateLocked
  RotateAroundTarget‿RotateAroundTargetLocked

  GetViewMatrix
  GetProjectionMatrix
  MakeGetProjectionMatrix

  MakeUpdater

  UpdateFree
  UpdateFirstPerson
  UpdateThirdPerson
  UpdatePro
  UpdateMinecraft

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
Yaw ← {angle𝕊camera:
  up ← GetUp camera # Rotation axis

  # View vector
  targetPosition ← -´index.target‿index.position⊏camera

  # Rotate view vector around up axis
  targetPosition Vector3RotateByAxisAngle˜↩up‿angle

  # rotate around camera.position
  # Move target relative to position
  (targetPosition + index.position⊑camera)⌾(index.target⊸⊑)camera
}

# Rotates the camera around its right vector, pitch is "looking up and down"
#  - lockView prevents camera overrotation (aka "somersaults")
#  - rotateUp rotates the up direction as well (typically only useful in mode.free)
# NOTE: angle must be provided in radians
Pitch ← {angle‿lockView‿rotateUp𝕊camera:

  # clamp the Pitch angle to allow only viewing straight up or down.
  angle {
    t ← -´index.target‿index.position⊏camera
    𝕩 {𝕎𝕩}´ ⌊‿⌈{𝕎⟜𝕩}¨1‿¯1×¯0.001+t VectorAngle˜ ≍˘⟜-GetUp camera
  }⍟lockView ↩

  # Rotation axis
  right ← GetRight camera

  # Rotate view vector around right axis
  targetPosition ← right‿angle Vector3RotateByAxisAngle -´index.target‿index.position⊏camera

  # rotate around camera.position
  # Move target relative to position
  camera {𝕩⋈𝕩+targetPosition}∘⊑⌾(index.position‿index.target⊸⊏) ↩

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

ToTarget ⇐ {
  𝕊⁼:𝕩+<-´𝕩;
  𝕊: 𝕩-<-´𝕩
}⌾(index.position‿index.target⊸⊏)

MakeUpdater ← {𝕊⟨
    moveInWorldPlane
    lockView
    rotateUp

    rotation_speed
    move_speed
    pan_speed
    mouse_move_sensitivity
    mouse_scroll_sensitivity
    keys
  ⟩:
  t←{height‿pitch‿yaw‿panMode⇐keys}
  hUpKey‿hDownKey←t.height
  pUpKey‿pDownKey←t.pitch
  yUpKey‿yDownKey←t.yaw
  panModeKey←t.panMode

  {𝕊camera:

    mouseDelta ← GetMouseDelta⟨⟩
    frameAdjusting ← 60×GetFrameTime⟨⟩

    # Camera rotation
    camera Pitch˜↩ ⟨frameAdjusting×rotation_speed×-´IsDown¨pUpKey‿pDownKey, lockView, rotateUp⟩
    camera Yaw  ˜↩  frameAdjusting×rotation_speed×-´IsDown¨yUpKey‿yDownKey

    right   ← moveInWorldPlane⊑MoveRight‿MoveRightInWorldPlane
    forward ← moveInWorldPlane⊑MoveForward‿MoveForwardInWorldPlane

    # Camera movement
    {mouse.button.IsDown panModeKey?
      # Camera pan (for camera.free)
      camera Right ˜↩  pan_speed××0⊑mouseDelta
      camera MoveUp˜↩ -pan_speed××1⊑mouseDelta
    ;
      # Mouse support
      camera Yaw  ˜↩ -mouse_move_sensitivity×0⊑mouseDelta
      camera Pitch˜↩⟨-mouse_move_sensitivity×1⊑mouseDelta, lockView, rotateUp⟩
    }

    # Keyboard support
    camera Forward˜↩ frameAdjusting × move_speed×-´IsDown¨w‿s
    camera Right  ˜↩ frameAdjusting × move_speed×-´IsDown¨d‿a

    # Gamepad movement
    {𝕤
      G ← GetGamepadAxisMovement 0⊸⋈

      # Gamepad controller support
      camera Yaw  ˜↩ frameAdjusting × mouse_move_sensitivity × ¯20×G gamepadAxis.gamepad_axis_right_x
      camera Pitch˜↩⟨frameAdjusting × mouse_move_sensitivity × ¯20×G gamepadAxis.gamepad_axis_right_y, lockView, rotateUp⟩
      camera Forward˜↩ frameAdjusting × move_speed × 0.25 (-⊸≥-≤) G gamepadAxis.gamepad_axis_left_y
      camera Right˜↩ -frameAdjusting × move_speed × 0.25 (-⊸≥-≤) G gamepadAxis.gamepad_axis_left_x
      camera MoveUp˜↩ frameAdjusting × move_speed × raylib.gamepadButton.gamepad_button_right_face_down -○raylib.IsGamepadButtonDown○(0⊸⋈) raylib.gamepadButton.gamepad_button_right_thumb
    }⍟⊢ IsGamepadAvailable 0

    camera MoveUp˜↩ frameAdjusting × move_speed × space -○IsDown left_control

    camera
  }
}

# Zoom target distance
UpdateZoom ← {𝕊camera: 1𝕊𝕩;
  zoomAmount𝕊camera:
  # scale multiplies the zoom speed to prevent you zooming past 0
  dist ← +´⌾(×˜)-´index.target‿index.position⊏𝕩

  # Zoom slows as you get close, and `0⍟(0≥dist+⊢)` makes sure you can't get to/past 0 incase user zooms for a loooong time.
  camera MoveToTarget˜↩ 0⍟(0≥dist+⊢)- zoomAmount × (mouse.WheelMoved@) + 2×-´IsPressed¨keypad.add‿keypad.subtract
}
UpdateRoll ← {⟨rotationSpeed⋄leftKey‿rightKey⟩𝕊camera: # rotation is Radians per second
  camera Roll ˜↩ (60×GetFrameTime⟨⟩)×rotationSpeed×-´IsDown¨leftKey‿rightKey
}
updateFree ← {0.03‿(𝕨.keys.roll) UpdateRoll 𝕏{⊢⊣⌾(index.up⊸⊑)𝔽}}⟜MakeUpdater {
  rotation_speed ⇐ 0.03
  move_speed     ⇐ 0.09
  pan_speed      ⇐ 0.2

  moveInWorldPlane ⇐ 0
  lockView         ⇐ 1
  rotateUp         ⇐ 0

  # Camera mouse movement sensitivity
  mouse_move_sensitivity   ⇐ 0.003     # TODO: it should be independant of framerate
  mouse_scroll_sensitivity ⇐ 1.5

  keys ⇐ {
    height  ⇐ key.left_control‿key.space
    pitch   ⇐ key.up          ‿key.down
    yaw     ⇐ key.left        ‿key.right
    roll    ⇐ key.e           ‿key.q
    panMode ⇐ mouse.button.middle
  }
}

# Orbital can just orbit
UpdateOrbital ⇐ UpdateZoom {𝕊:0.5×GetFrameTime⟨⟩}⊸Yaw⌾ToTarget

updateFirstPerson ⇐ MakeUpdater {
  rotation_speed ⇐ 0.03 # Radians per second
  move_speed     ⇐ 0.09
  pan_speed      ⇐ 0.2

  moveInWorldPlane   ⇐ 0
  lockView           ⇐ 1
  rotateUp           ⇐ 1

  # Camera mouse movement sensitivity
  mouse_move_sensitivity   ⇐ 0.003     # TODO: it should be independant of framerate
  mouse_scroll_sensitivity ⇐ 1.5

  keys ⇐ {
    height  ⇐ key.left_control‿key.space
    pitch   ⇐ key.up          ‿key.down
    yaw     ⇐ key.left        ‿key.right
    panMode ⇐ mouse.button.middle
  }
}
updateThirdPerson ⇐ {UpdateZoom 𝕏⌾ToTarget} MakeUpdater {
  rotation_speed ⇐ 0.03 # Radians per second
  move_speed     ⇐ 0.09
  pan_speed      ⇐ 0.2

  moveInWorldPlane   ⇐ 0
  lockView           ⇐ 1
  rotateUp           ⇐ 0

  # Camera mouse movement sensitivity
  mouse_move_sensitivity   ⇐ 0.003     # TODO: it should be independant of framerate
  mouse_scroll_sensitivity ⇐ 1.5

  keys ⇐ {
    height ⇐ key.left_control‿key.space
    pitch ⇐ key.up‿key.down
    yaw   ⇐ key.left‿key.right
    roll  ⇐ key.e‿key.q
    panMode ⇐ mouse.button.middle
  }
}
updateMinecraft ← MakeUpdater{
  rotation_speed ⇐ 0.03 # Radians per second
  move_speed     ⇐ 0.09
  pan_speed      ⇐ 0.2

  moveInWorldPlane   ⇐ 1
  lockView           ⇐ 1
  rotateUp           ⇐ 0

  # Camera mouse movement sensitivity
  mouse_move_sensitivity   ⇐ 0.003     # TODO: it should be independant of framerate
  mouse_scroll_sensitivity ⇐ 1.5

  keys ⇐ {
    height ⇐ key.left_shift‿key.space
    pitch ⇐ key.up‿key.down
    yaw   ⇐ key.left‿key.right
    roll  ⇐ @‿@
    panMode ⇐ mouse.button.middle
  }
}

# Update camera movement, movement/rotation values should be provided by user
UpdatePro ← UpdateZoom {movement‿rotation‿zoom𝕊camera:
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
  camera Yaw  ˜↩ -deg2rad×0⊑rotation
  camera Pitch˜↩⟨-deg2rad×1⊑rotation, lockView, rotateUp⟩

  # Camera movement
  camera MoveForwardInWorldPlane˜↩ 0⊑movement
  camera MoveRightInWorldPlane  ˜↩ 1⊑movement
  camera MoveUp                 ˜↩ 2⊑movement

  camera
}

[
  Rotate ‿ RotateLocked
  RotateAroundTarget ‿ RotateAroundTargetLocked
] ← (↕2‿2) {𝕨𝕊f: 𝕨 _f}¨ {{
  angleYaw‿anglePitch‿angleRoll RotateAroundTarget‿LockView _𝕣 position‿target‿up‿fovy‿projection:

  targetPosition ← up‿angleYaw Vector3RotateByAxisAngle target-position
  right ← targetPosition 1⊸⌽⊸×{1⌽𝔽˜-𝔽} up

  anglePitch {
    # In these camera modes we clamp the Pitch angle
    # to allow only viewing straight up or down.

    # Clamp view up
    𝕩 ⌊↩ ¯0.001+up VectorAngle targetPosition

    # Clamp view down
    𝕩 ⌈ 0.001-(-up) VectorAngle targetPosition
  }⍟lockView ↩


  transpos ← right‿anglePitch Vector3RotateByAxisAngle targetPosition
  r←rotateAroundTarget
  [position⋄target] (+`transPos≍˜⊏)⌾(r⌽-⍟r)↩

  ⟨
    position
    target
    up Vector3RotateByAxisAngle˝transPos‿angleRoll≍right‿anglePitch
    fovy
    projection
  ⟩
}}
