⟨color, window, draw, rayffi, 
 ⟨kY,kR,kG,kB,kq,kup,ke,kleft,kdown,kright,IsPressed
 ⟩⇐key
⟩←r←•Import "../../raylib.bqn"

_withConsts ← {𝕨𝔽_𝕣𝕩:
  meshes ← rayffi.LoadModelFromMesh¨ ⟨
    rayffi.GenMeshPlane 10‿10‿3‿3
    rayffi.GenMeshCube   2‿ 4‿2
  ⟩
  lights ← ⟨
    ⟨¯2‿1‿¯2, color.yellow⟩
    ⟨ 2‿1‿ 2, color.red   ⟩
    ⟨¯2‿1‿ 2, color.green ⟩
    ⟨ 2‿1‿¯2, color.blue  ⟩
  ⟩
  lightToggle ← 4⥊1
          #  pos    target  up     FOV Yaxis  Camera projection type
  camera ← ⟨ 1‿4‿6, 0‿0‿0,  0‿1‿0, 45,        0⟩
  meshes‿lights 𝔽 lightToggle‿camera
  rayffi.UnloadModel¨meshes
}
PerFrame ← {meshes‿lights𝕊lightToggle‿camera:
  rayffi.BeginMode3D camera
    (rayffi.DrawModel⟨0‿0‿0, 1, color.white⟩∾˜<)¨meshes
    rayffi.DrawGrid 10‿1
    lightToggle⊣◶⟨
      rayffi.DrawSphereWires ⌈∘×⟜1‿1‿1‿0.3⌾(¯1⊸⊑)∘⊢
      rayffi.DrawSphereEx⊢
    ⟩¨(¯1⌽0.2‿8‿8∾⌽)¨lights
  rayffi.EndMode3D⟨⟩
  rayffi.DrawFPS 10‿10
  "Use keys [Y][R][G][B] to toggle lights"color.darkGray draw._Text_ 20 10‿40
  MoveCamera ← (kq‿kup‿ke-○IsPressed kleft‿kdown‿kright)⊸+⌾⊑
  ⟨lightToggle=¬IsPressed ky‿kr‿kg‿kb
   MoveCamera camera⟩
}draw._withCanvas_ color.black

Game ← PerFrame•_While_(¬window.ShouldClose) _withConsts
Game window._openAs "raylib [shaders] example - basic lighting"