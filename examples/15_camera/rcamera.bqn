⟨
  GetCameraForward
  GetCameraUp
  GetCameraRight

  # Camera movement
  CameraMoveForward
  CameraMoveUp
  CameraMoveRight
  CameraMoveToTarget

  # Camera rotation
  CameraYaw
  CameraPitch
  CameraRoll

  GetCameraViewMatrix
  GetCameraProjectionMatrix

  UpdateCamera
⟩⇐

#   rcamera - Basic camera system with support for multiple camera modes
#
#   CONFIGURATION:
#       #define RCAMERA_IMPLEMENTATION
#           Generates the implementation of the library into the included file.
#           If not defined, the library is in header only mode and can be included in other headers
#           or source files without problems. But only ONE file should hold the implementation.
#
#       #define RCAMERA_STANDALONE
#           If defined, the library can be used as standalone as a camera system but some
#           functions must be redefined to manage inputs accordingly.
#
#
# Function specifiers definition

⟨rf⇐rayffi, key, mouse
  ⟨
    GetMouseDelta
    GetFrameTime
    cameraProjection
    cameraMode
  ⟩ ⇐ rayffi

  ⟨
    Vector3RotateByAxisAngle
    VectorAngle
    MatrixLookAt
    MatrixPerspective
    MatrixOrtho
    deg2rad
    MP
    MatrixRotate
  ⟩ ⇐ raymath

⟩ ← rl ← •Import "../../raylib.bqn"

cameraIndex ⇐ {
  position   ⇐ 0 # Camera position
  target     ⇐ 1 # Camera target it looks-at
  up         ⇐ 2 # Camera up vector (rotation over its axis)
  fovy       ⇐ 3 # Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
  projection ⇐ 4 # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

camera_first_person_step_trigonometric_divider ← 8
camera_first_person_step_divider ← 30
camera_first_person_waving_divider ← 200

# PLAYER (used by camera)
player_movement_sensitivity ← 20

#----------------------------------------------------------------------------------
# Module Functions Definition
#----------------------------------------------------------------------------------
# Returns the cameras forward vector (normalized)
GetCameraForward ← {𝕊camera:
  ÷⟜(0⊸=⊸++´⌾(×˜))-´cameraIndex.target‿cameraIndex.position⊏camera
}

# Returns the cameras up vector (normalized)
# Note: The up vector might not be perpendicular to the forward vector
GetCameraUp ← {𝕊camera:
  ÷⟜(0⊸=⊸++´⌾(×˜)) cameraIndex.up⊑camera
}

# Returns the cameras right vector (normalized)
GetCameraRight ← {𝕊camera:
  (GetCameraForward camera) 1⊸⌽⊸×{1⌽𝔽˜-𝔽} GetCameraUp camera
}

# Moves the camera in its forward direction
CameraMoveForward ← {𝕊camera‿distance‿moveInWorldPlane:

  forward ← {
    # Project vector onto world plane
    ÷⟜(0⊸=⊸++´⌾(×˜)) 0⌾(1⊸⊑) 𝕩
  }⍟moveInWorldPlane GetCameraForward camera

  # Move position and target
  (forward×distance)⊸+¨⌾(cameraIndex.position‿cameraIndex.target⊸⊏) camera
}

# Moves the camera in its up direction
CameraMoveUp ← {𝕊camera‿distance:
  (distance×GetCameraUp camera)⊸+¨⌾(cameraIndex.position‿cameraIndex.target⊸⊏)camera
}

# Moves the camera target in its current right direction
CameraMoveRight ← {𝕊camera‿distance‿moveInWorldPlane:
  right ← {
    # Project vector onto world plane
    ÷⟜(0⊸=⊸++´⌾(×˜)) 0⌾(1⊸⊑) 𝕩
  }⍟moveInWorldPlane GetCameraRight camera

  # Scale by distance
  (right×distance)⊸+¨⌾(cameraIndex.position‿cameraIndex.target⊸⊏)camera
}

# Moves the camera position closer/farther to/from the camera target
CameraMoveToTarget ← {delta𝕊camera:
  distance ← delta++´⌾(×˜)-´cameraIndex.position‿cameraIndex.target⊏camera

  # Set new distance by moving the position along the forward vector
  forward ← distance×GetCameraForward camera
  (forward -˜ cameraIndex.target⊑camera)⌾(cameraIndex.position⊸⊑)camera
}

# Rotates the camera around its up vector
# Yaw is "looking left and right"
# If rotateAroundTarget is false, the camera rotates around its position
# Note: angle must be provided in radians
CameraYaw ← {𝕊camera‿angle‿rotateAroundTarget:
  up ← GetCameraUp camera # Rotation axis

  # View vector
  targetPosition ← -´cameraIndex.target‿cameraIndex.position⊏camera

  # Rotate view vector around up axis
  targetPosition ↩ Vector3RotateByAxisAngle targetPosition‿up‿angle

  {rotateAroundTarget?
    # Move position relative to target
    (targetPosition -˜ cameraIndex.target⊑camera)⌾(cameraIndex.position⊸⊑)camera
  ;
    # rotate around camera.position
    # Move target relative to position
    (targetPosition + cameraIndex.position⊑camera)⌾(cameraIndex.target⊸⊑)camera
  } 
}

# Rotates the camera around its right vector, pitch is "looking up and down"
#  - lockView prevents camera overrotation (aka "somersaults")
#  - rotateAroundTarget defines if rotation is around target or around its position
#  - rotateUp rotates the up direction as well (typically only usefull in CAMERA_FREE)
# NOTE: angle must be provided in radians
CameraPitch ← {𝕊camera‿angle‿lockView‿rotateAroundTarget‿rotateUp:
  # Up direction
  up ← GetCameraUp camera

  # View vector
  targetPosition ← -´cameraIndex.target‿cameraIndex.position⊏camera

  angle {
    # In these camera modes we clamp the Pitch angle
    # to allow only viewing straight up or down.

    # Clamp view up
    𝕩 ⌊↩ ¯0.001+up VectorAngle targetPosition

    # Clamp view down
    𝕩 ⌈ 0.001-(-up) VectorAngle targetPosition
  }⍟lockView ↩

  # Rotation axis
  right ← GetCameraRight camera

  # Rotate view vector around right axis
  targetPosition ↩ Vector3RotateByAxisAngle targetPosition‿right‿angle

  camera {rotateAroundTarget?
    # Move position relative to target
    (targetPosition -˜ cameraIndex.target⊑𝕩)⌾(cameraIndex.position⊸⊑) 𝕩
  ;
    # rotate around camera.position
    # Move target relative to position
    (targetPosition + cameraIndex.position⊑𝕩)⌾(cameraIndex.target⊸⊑) 𝕩
  } ↩

  {
    # Rotate up direction around right axis
    Vector3RotateByAxisAngle 𝕩‿right‿angle
  }⌾(cameraIndex.up⊸⊑)⍟rotateUp camera
}

# Rotates the camera around its forward vector
# Roll is "turning your head sideways to the left or right"
# Note: angle must be provided in radians
CameraRoll ← {angle𝕊camera:
  # Rotation axis
  forward ← GetCameraForward camera

  # Rotate up direction around forward axis
  {Vector3RotateByAxisAngle 𝕩‿forward‿angle}⌾(cameraIndex.up⊸⊑)camera
}

# Returns the camera view matrix
GetCameraViewMatrix ← {𝕊camera:
  MatrixLookAt cameraIndex.position‿cameraIndex.target‿cameraIndex.up⊏camera
}

# Returns the camera projection matrix
PickCullDist ← {𝕊camera_cull_distance_near‿camera_cull_distance_far:
  ⟨
    {aspect𝕊camera: # GetCameraProjectionMatrix
      { 𝕩 ≡ rl.cameraProjection.camera_perspective?
        MatrixPerspective⟨deg2rad×cameraIndex.fovy⊑camera, aspect, camera_cull_distance_near, camera_cull_distance_far⟩

      ; 𝕩 ≡ rl.cameraProjection.camera_orthographic?
        top ← 2÷˜cameraIndex.fovy⊑camera
        right ← top×aspect

        MatrixOrtho⟨-right, right, -top, top, camera_cull_distance_near, camera_cull_distance_far⟩
      ;
        =⌜˜↕4
      }cameraIndex.projection⊑camera
    }
  ⟩
}

# Default cull distance
⟨GetCameraProjectionMatrix⟩ ← PickCullDist 0.01‿1000


#if !defined(RCAMERA_STANDALONE)
# Update camera position for selected mode
# Camera mode: CAMERA_FREE, CAMERA_FIRST_PERSON, CAMERA_THIRD_PERSON, CAMERA_ORBITAL or CUSTOM

MakeCameraUpdater ← {𝕊⟨
    camera_orbital_speed
    camera_rotation_speed
    camera_move_speed
    camera_pan_speed
    camera_mouse_move_sensitivity
    camera_mouse_scroll_sensitivity
  ⟩:
  
  {mode𝕊camera:
    mouseDelta ← GetMouseDelta⟨⟩
    cm ← rf.cameraMode
    moveInWorldPlane   ← ∨´mode=cm.camera_third_person                  ‿cm.camera_first_person
    rotateAroundTarget ← ∨´mode=cm.camera_third_person‿cm.camera_orbital
    lockView           ← ∨´mode=cm.camera_third_person‿cm.camera_orbital‿cm.camera_first_person‿cm.camera_free
    rotateUp           ← 0

    {mode=cm.camera_orbital?
      # Orbital can just orbit
      rotation ← MatrixRotate⟨GetCameraUp camera, camera_orbital_speed×GetFrameTime⟨⟩⟩
      view ← -´cameraIndex.position‿cameraIndex.target⊏camera
      view MP↩ rotation
      (cameraIndex.target + view)⌾(cameraIndex.position⊸⊑)camera
    ;
      # Camera rotation
      camera ↩ CameraPitch⟨camera, camera_rotation_speed×-´key.IsDown¨key.up‿key.down , lockView, rotateAroundTarget, rotateUp⟩
      camera ↩ CameraYaw  ⟨camera, camera_rotation_speed×-´key.IsDown¨key.left‿key.right, rotateAroundTarget⟩
      camera ↩ CameraRoll⟜camera   camera_rotation_speed×-´key.IsDown¨key.e‿key.q

      # Camera movement
      # Camera pan (for CAMERA_FREE)
      {(mode = cm.camera_free) ∧ mouse.IsButtonDown mouse.button.middle?
        camera ↩ CameraMoveRight⟨camera,  camera_pan_speed×(0⊑mouseDelta) > 0, moveInWorldPlane⟩
        camera ↩ CameraMoveRight⟨camera, -camera_pan_speed×(0⊑mouseDelta) < 0, moveInWorldPlane⟩
        camera ↩ CameraMoveUp   ⟨camera, -camera_pan_speed×(1⊑mouseDelta) > 0⟩
        camera ↩ CameraMoveUp   ⟨camera,  camera_pan_speed×(1⊑mouseDelta) < 0⟩
      ;
        # Mouse support
        camera ↩ CameraYaw  ⟨camera, -(0⊑mouseDelta)×camera_mouse_move_sensitivity, rotateAroundTarget⟩
        camera ↩ CameraPitch⟨camera, -(1⊑mouseDelta)×camera_mouse_move_sensitivity, lockView, rotateAroundTarget, rotateUp⟩
      }

      # Keyboard support
      camera ↩ CameraMoveForward⟨camera,  camera_move_speed×key.IsDown key.w, moveInWorldPlane⟩
      camera ↩ CameraMoveRight  ⟨camera, -camera_move_speed×key.IsDown key.a, moveInWorldPlane⟩
      camera ↩ CameraMoveForward⟨camera, -camera_move_speed×key.IsDown key.s, moveInWorldPlane⟩
      camera ↩ CameraMoveRight  ⟨camera,  camera_move_speed×key.IsDown key.d, moveInWorldPlane⟩

      # Gamepad movement
      {𝕤
        # Gamepad controller support
        camera ↩ CameraYaw  ⟨camera, camera_mouse_move_sensitivity×¯2×rf.GetGamepadAxisMovement 0‿rf.gamepadAxis.gamepad_axis_right_x,           rotateAroundTarget⟩
        camera ↩ CameraPitch⟨camera, camera_mouse_move_sensitivity×¯2×rf.GetGamepadAxisMovement 0‿rf.gamepadAxis.gamepad_axis_right_y, lockView, rotateAroundTarget, rotateUp⟩

        camera ↩ CameraMoveForward⍟(¯0.25≥rf.GetGamepadAxisMovement 0‿rf.gamepadAxis.gamepad_axis_left_y)⟨camera,  camera_move_speed, moveInWorldPlane⟩
        camera ↩ CameraMoveRight  ⍟(¯0.25≥rf.GetGamepadAxisMovement 0‿rf.gamepadAxis.gamepad_axis_left_x)⟨camera, -camera_move_speed, moveInWorldPlane⟩
        camera ↩ CameraMoveForward⍟( 0.25≤rf.GetGamepadAxisMovement 0‿rf.gamepadAxis.gamepad_axis_left_y)⟨camera, -camera_move_speed, moveInWorldPlane⟩
        camera ↩ CameraMoveRight  ⍟( 0.25≤rf.GetGamepadAxisMovement 0‿rf.gamepadAxis.gamepad_axis_left_x)⟨camera,  camera_move_speed, moveInWorldPlane⟩
      }⍟⊢ rf.IsGamepadAvailable 0

      {𝕤
        camera {CameraMoveUp ⟨𝕩,  camera_move_speed⟩}⍟(key.IsDown key.space) ↩
        camera {CameraMoveUp ⟨𝕩, -camera_move_speed⟩}⍟(key.IsDown key.left_control) ↩
      }⍟⊢mode=cm.camera_free
    }

    {
      # Zoom target distance
      camera ↩ 𝕩 CameraMoveToTarget˜-mouse.WheelMoved@
      camera CameraMoveToTarget˜ 2×+´⟨
        key.IsPressed key.keypad.subtract
        -key.IsPressed key.keypad.add
      ⟩
    }⍟(∨´mode=cm.camera_third_person‿cm.camera_orbital‿cm.camera_free) camera
  }
}

updateCamera ← MakeCameraUpdater {
  camera_orbital_speed  ⇐ 0.5
  camera_rotation_speed ⇐ 0.03 # Radians per second
  camera_move_speed     ⇐ 0.09
  camera_pan_speed      ⇐ 0.2

  # Camera mouse movement sensitivity
  camera_mouse_move_sensitivity   ⇐ 0.003     # TODO: it should be independant of framerate
  camera_mouse_scroll_sensitivity ⇐ 1.5
}


# Update camera movement, movement/rotation values should be provided by user
UpdateCameraPro ← {𝕊camera‿movement‿rotation‿zoom:
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
  camera ↩ CameraYaw  ⟨camera, -(0⊑rotation)×deg2rad, rotateAroundTarget⟩
  camera ↩ CameraPitch⟨camera, -(1⊑rotation)×deg2rad, lockView, rotateAroundTarget, rotateUp⟩
  camera ↩ CameraRoll ⟨camera,  (2⊑rotation)×deg2rad⟩

  # Camera movement
  camera ↩ CameraMoveForward⟨camera, 0⊑movement, moveInWorldPlane⟩
  camera ↩ CameraMoveRight  ⟨camera, 1⊑movement, moveInWorldPlane⟩
  camera ↩ CameraMoveUp     ⟨camera, 2⊑movement⟩

  # Zoom target distance
  CameraMoveToTarget camera‿zoom
}
