⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../rayed.bqn"

img ← ¯128+256|128+1000‿1000‿4⥊100/∾˘´≍¨´1000⥊¨c.blue⋈○<c.red

_OnStart ← {𝕨 Func _𝕣 𝕩:
  font ← r.font.LoadBQN 100
  {𝕊tex:
    tex‿font Func 0‿0
  } r.texture._WithImage img
}
PerFrame ← {tex‿font𝕊frame‿rot:
  c.white‿font‿30  d.Text 20‿20⋈•Repr∘w.fps.Get⊸∾" FPS"  
  (m.GetPos@)⊸{c.white‿tex‿0.2‿𝕩d.Texture𝕨}¨rot+90×↕4
  r.raylib.UpdateTextureRaw tex⋈⥊frame⌽img
  ⟨frame+1⋄90|m.WheelMoved⊸+rot⟩
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬w.ShouldClose)_OnStart
Game w._openAs "test"
