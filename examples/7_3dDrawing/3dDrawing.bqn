⟨color, window, draw, raylib, k⇐key⟩←r←•Import "../../rayed.bqn"

_setup ← {𝕨𝔽_𝕣𝕩:
  raylib.DisableCursor⟨⟩
  models ← r.model.LoadFromMesh¨ ⟨
    raylib.GenMeshPlane 10‿10‿3‿3
    raylib.GenMeshCube 2‿4‿2
  ⟩
  font ← r.font.LoadBQN 50
  lights ← ⟨
    ¯2‿1‿¯2⋈color.yellow
     2‿1‿ 2⋈color.red
    ¯2‿1‿ 2⋈color.green
     2‿1‿¯2⋈color.blue
  ⟩
  lightToggle ← 4⥊1
          #  pos    target  up     FOV Yaxis  Camera projection type
  camera ← ⟨ 1‿4‿6, 0‿0‿0,  0‿1‿0, 45,        0⟩
  models‿lights‿font 𝔽 lightToggle‿camera
  r.model.Unload¨models # Unloading models also unloads the meshes
}

PerFrame ← {models‿lights‿font𝕊lightToggle‿camera:
  camera {⊑⊑raylib.UpdateCameraRef⟨𝕩⟩⋈raylib.cameraMode.cAMERA_THIRD_PERSON}↩
  lightToggle ≠↩ k.IsPressed⟨k.y, k.r, k.g, k.b⟩
  {𝕤
    {𝕤
      (raylib.DrawModel⟨0‿0‿0, 1, color.white⟩∾˜<)¨models
      raylib.DrawGrid 10‿1
      lightToggle⊣◶⟨
        raylib.DrawSphereWires ⌈∘×⟜1‿1‿1‿0.3⌾(¯1⊸⊑)∘⊢
        raylib.DrawSphereEx⊢
      ⟩¨(¯1⌽0.2‿8‿8∾⌽)¨lights
    }r.draw._in3D camera
    raylib.DrawFPS 10‿10
    color.lightGray‿font‿20 draw.Text 10‿40⋈"Use keys [Y][R][G][B] to toggle lights"
  }draw._withCanvas⟜color.black @
  lightToggle‿camera
}

Game ← PerFrame•_While_(¬window.ShouldClose) _setup
Game window._openAs "raylib [shaders] example - basic lighting"


