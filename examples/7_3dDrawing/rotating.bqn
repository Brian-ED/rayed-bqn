# The MoveCamera function is what rotates the camera

⟨color, window, draw, raylib, k⇐key⟩←r←•Import "../../rayed.bqn"
⟨IsPressed⟩←k
_setup ← {𝕨𝔽_𝕣𝕩:
  meshes ← raylib.LoadModelFromMesh¨ ⟨
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
  camera ← ⟨ 4‿4‿0, 0‿0‿0,  0‿1‿0, 45,        0⟩
  meshes‿lights‿font 𝔽 lightToggle‿camera
  raylib.UnloadModel¨meshes
}

rotMat ← r.raymath.MatrixRotateZ π÷80
MoveCamera ← {
  n ← -´IsPressed⟨k.q, k.up, k.e⟩‿⟨k.left, k.down, k.right⟩
  rotMat r.raymath.MP 𝕩+n
}⌾⊑

PerFrame ← {meshes‿lights‿font𝕊lightToggle‿camera:
  out←⟨
    lightToggle≠IsPressed⟨k.y, k.r, k.g, k.b⟩
    MoveCamera camera
  ⟩
  {𝕤
    {𝕤
      (raylib.DrawModel⟨0‿0‿0, 1, color.white⟩∾˜<)¨meshes
      raylib.DrawGrid 10‿1
      lightToggle⊣◶⟨
        raylib.DrawSphereWires ⌈∘×⟜1‿1‿1‿0.3⌾(¯1⊸⊑)∘⊢
        raylib.DrawSphereEx⊢
      ⟩¨(¯1⌽0.2‿8‿8∾⌽)¨lights
    } draw._in3D camera
    raylib.DrawFPS 10‿10
    color.darkGray‿font‿20 draw.Text 10‿40⋈"Use keys [Y][R][G][B] to toggle lights"
    
  } draw._withCanvas_ color.black @
  out
}

Game ← PerFrame•_While_(¬window.ShouldClose) _setup
Game window._openAs "raylib [shaders] example - basic lighting"


