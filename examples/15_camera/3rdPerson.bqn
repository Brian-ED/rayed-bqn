⟨rf⇐raylib, key, color, draw⟩ ← rl ← •Import "../../rayed.bqn"

max_columns ← 20

cameraIndex ← {
  position   ⇐ 0 # Camera position
  target     ⇐ 1 # Camera target it looks-at
  up         ⇐ 2 # Camera up vector (rotation over its axis)
  fovy       ⇐ 3 # Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
  projection ⇐ 4 # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

# Generates some random columns
heights ← 1+•rand.Range¨max_columns⥊13
positions ← <˘⍉[¯15+•rand.Range¨max_columns⥊30, max_columns⥊max_columns÷2, ¯15+•rand.Range¨max_columns⥊30]
colors ← ⍉[
  20+•rand.Range¨max_columns⥊235
  10+•rand.Range¨max_columns⥊45
  max_columns⥊30
  max_columns⥊255
]

stut←1
PerFrame←{𝕊camera‿cameraMode:
  stut≠↩rl.key.IsPressed key.g

  rl.window.SetFPS stut⊑ 1000‿60
  rf.DrawFPS 200‿0
  # Switch camera mode
  {𝕤
    cameraMode ↩ rf.cameraMode.camera_free
    camera 0‿1‿0⌾(cameraIndex.up⊸⊑)↩  # Reset roll
  }⍟⊢key.IsPressed key.one

  {𝕤
    cameraMode ↩ rf.cameraMode.camera_first_person
    camera 0‿1‿0⌾(cameraIndex.up⊸⊑)↩  # Reset roll
  }⍟⊢key.IsPressed key.two

  {𝕤
    cameraMode ↩ rf.cameraMode.camera_third_person
    camera 0‿1‿0⌾(cameraIndex.up⊸⊑)↩  # Reset roll
  }⍟⊢key.IsPressed key.three

  {𝕤
    cameraMode ↩ rf.cameraMode.camera_orbital;
    camera 0‿1‿0⌾(cameraIndex.up⊸⊑)↩  # Reset roll
  }⍟⊢key.IsPressed key.four

  # Switch camera projection
  camera {𝕤
    (cameraIndex.projection⊑𝕩) = rf.cameraProjection.camera_perspective?
      # Create isometric view
      cameraMode ↩ rf.cameraMode.camera_third_person
      # Note: The target distance is related to the render distance in the orthographic projection
      newCam ← ⟨
        0‿2‿¯100
        0‿2‿   0
        0‿1‿0  # Reset roll
        20 # near plane width in CAMERA_ORTHOGRAPHIC
        rf.cameraProjection.camera_orthographic
      ⟩
      newCam rl.camera.CameraYaw  ˜↩⟨¯135×π÷180, 1⟩
      newCam rl.camera.CameraPitch˜↩⟨ ¯45×π÷180, 1, 1, 0⟩
      newCam
  ; (cameraIndex.projection⊑𝕩) = rf.cameraProjection.camera_orthographic?

    # Reset to default view
    cameraMode ↩ rf.cameraMode.camera_third_person
    ⟨
      0‿2‿10
      0‿2‿ 0
      0‿1‿0 # Reset roll
      60
      rf.cameraProjcection.camera_perspective
    ⟩
  }⍟(key.IsPressed key.p) ↩

  # Update camera computes movement internally depending on the camera mode
  # Some default standard keyboard/mouse inputs are hardcoded to simplify use
  # For advance camera controls, it's reecommended to compute camera movement manually
  camera rl.camera.UpdateCamera˜ ↩ cameraMode⋈rf.GetMouseDelta⟨⟩

  # Draw
  {𝕤
    {𝕤

      rf.DrawPlane⟨   0‿0  ‿ 0, 32‿32, color.lightgray   ⟩ # Draw ground
      rf.DrawCube ⟨ ¯16‿2.5‿ 0, 1    , 5, 32, color.blue ⟩ # Draw a blue wall
      rf.DrawCube ⟨  16‿2.5‿ 0, 1    , 5, 32, color.lime ⟩ # Draw a green wall
      rf.DrawCube ⟨   0‿2.5‿16, 32   , 5, 1 , color.gold ⟩ # Draw a yellow wall

      # Draw some cubes around
      {𝕤
        rf.DrawCube     ⟨𝕩⊑positions, 2, 𝕩⊑heights, 2, 𝕩⊏colors⟩
        rf.DrawCubeWires⟨𝕩⊑positions, 2, 𝕩⊑heights, 2, color.maroon⟩
      }¨↕max_columns

      # Draw player cube
      {𝕤
        rf.DrawCube     ⟨cameraIndex.target⊑camera, 0.5, 0.5, 0.5, color.purple⟩
        rf.DrawCubeWires⟨cameraIndex.target⊑camera, 0.5, 0.5, 0.5, color.darkpurple⟩
      }⍟⊢cameraMode = rf.cameraMode.camera_third_person

    } draw._in3D camera

    # Draw info boxes
    rf.DrawRectangle     ⟨5, 5, 530, 150, ⌈∘÷⟜2⌾(3⊸⊑)color.skyblue⟩
    rf.DrawRectangleLines⟨5, 5, 530, 150, color.blue⟩

    TextJ←{y𝕊t:rf.DrawText⟨t,15,y,20,color.black⟩}

    ⟨
      TextJ⟜"Camera controls:"
      TextJ⟜"- Move keys: W, A, S, D, Space, Left-Ctrl"
      TextJ⟜"- Look around: arrow keys or mouse"
      TextJ⟜"- Camera mode keys: 1, 2, 3, 4"
      TextJ⟜"- Zoom keys: num-plus, num-minus or mouse scroll"
      TextJ⟜"- Camera projection key: P"
    ⟩{𝕎𝕩}¨20×1+↕6
    rf.DrawRectangle⟨600, 5, 195, 100, ⌈∘÷⟜2⌾(3⊸⊑)color.skyblue⟩
    rf.DrawRectangleLines⟨600, 5, 195, 100, color.blue⟩

    rf.DrawText⟨"Camera status:", 610, 15, 10, color.black⟩

    modeText ← {
      [a,b] ← ⍉[
        rf.cameraMode.camera_free        ‿"FREE"
        rf.cameraMode.camera_first_person‿"FIRST_PERSON"
        rf.cameraMode.camera_third_person‿"THIRD_PERSON"
        rf.cameraMode.camera_orbital     ‿"ORBITAL"
      ]
      b∾↩<"CUSTOM"
      b⊑˜⊑cameraMode⊐˜a
    }
    projText ← {
      [a,b] ← ⍉[
        rf.cameraProjection.camera_perspective ‿"PERSPECTIVE"
        rf.cameraProjection.camera_orthographic‿"ORTHOGRAPHIC"
      ]
      b∾↩<"CUSTOM"
      b⊑˜⊑a⊐cameraIndex.projection⊑camera # camera.projection will error
    }
    TextI ← {𝕊t‿y:rf.DrawText⟨t, 610, y, 15, color.black⟩}
    TextI⟨"- Mode: "∾modeText, 30⟩
    TextI⟨"- Projection: "∾projText, 45⟩
    R ← 1↓·∾' '∾¨•Repr¨
    TextI⟨"- Position: ("∾')'∾˜R cameraIndex.position⊑camera, 60⟩
    TextI⟨"- Target: ("  ∾')'∾˜R cameraIndex.target⊑camera, 75⟩
    TextI⟨"- Up: ("      ∾')'∾˜R cameraIndex.up⊑camera, 90⟩

  }draw._withCanvas⟜color.raywhite @
  camera‿cameraMode
} •_While_(¬rl.window.ShouldClose)

rl.window.SetSize 0.5

PerFrame∘{𝕤
rl.window.SetFullscreen 0
  rf.DisableCursor⟨⟩                    # Limit cursor to relative movement inside the window
  camera ← ⟨
    0‿2‿4    # Camera position
    0‿2‿0    # Camera target, its looking at point
    0‿1‿0    # Camera up vector (rotation towards target)
    60       # FOV, Camera field-of-view Y
    rf.cameraProjection.camera_perspective # Camera projection type
  ⟩
  # Define the camera to look into our 3d world (position, target, up vector)
  cameraMode ← rf.cameraMode.camera_free

  camera‿cameraMode
} rl.window._openAs "raylib [core] example - 3d camera first person"