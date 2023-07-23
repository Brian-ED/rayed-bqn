⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

_OnStart ← {𝕨 Func _𝕣 𝕩:
  img ← 1000‿1000‿4⥊100/∾˘´≍¨´1000⥊¨c.blue⋈○<c.red
  font ← r.font.LoadBQN 100
  {𝕊tex:
    tex‿font Func img‿0
  } r.texture._WithImage img
}
PerFrame ← {tex‿font𝕊img‿rot:
  c.white‿font‿30  d.Text 20‿20⋈•Repr∘w.fps.Get⊸∾" FPS"  
  
  (m.GetPos@)⊸{c.white‿tex‿0.2‿𝕩d.Texture𝕨}¨rot+90×↕4
  r.rayffi.UpdateTexture tex⋈⥊img
  (1⌽img)⋈90|m.WheelMoved⊸+rot
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬w.ShouldClose)_OnStart
Game w._openAs "test"
