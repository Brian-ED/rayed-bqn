⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../rayed.bqn"

PerFrame ← {
  tex‿font←𝕨
  {𝕊scrolled:
    c.white‿font‿30 d.Text 20‿20⋈•Repr∘w.GetFPS⊸∾" FPS"
    {d.Texture⟜m.GetPos c.white‿tex∾𝕩∾˜÷5}¨𝕩+90×↕4
    90|m.WheelMoved⊸+𝕩
  }d._withCanvas⟜c.black•_While_(¬w.ShouldClose) 𝕩
}

{𝕤
  font ← r.font.LoadBQN@
  x ← [c.blue,c.red]⊏˜∾((∾˜1280÷2)⥊<)¨⌽⊸≍↕2
  {𝕩‿font PerFrame 0} r.texture._WithImage x
  r.font.Unload font
} w._openAs "test"