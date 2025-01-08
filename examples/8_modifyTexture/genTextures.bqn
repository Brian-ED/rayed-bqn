⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../rayed.bqn"

img ← ¯128+256|128+1000‿1000‿4⥊100/∾˘´≍¨´1000⥊¨c.blue⋈○<c.red

PerFrame ← {𝕊:
  tex‿font←𝕨
  {𝕊frame‿rot:
    c.green‿font‿30 d.Text 20‿20⋈•Repr∘w.GetFPS⊸∾" FPS"
    (m.GetPos@)⊸{c.white‿tex‿0.2‿𝕩d.Texture𝕨}¨rot+90×↕4
    tex r.texture.Update˜ frame⌽img
    ⟨frame+1⋄90|m.WheelMoved⊸+rot⟩
  }d._withCanvas⟜c.black •_While_(¬w.ShouldClose)𝕩
}
Game ← {𝕊:
  font←r.font.LoadBQN@
  {𝕊tex:
    tex‿font PerFrame 0‿0
  } r.texture._WithImage img
}

Game w._openAs "test"
