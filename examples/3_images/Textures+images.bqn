⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

PerFrame ← {tex‿font𝕊scrolled:
  c.white‿font‿30 d.Text 20‿20⋈•Repr∘w.fps.Get⊸∾" FPS"
  {d.Texture⟜m.GetPos c.white‿tex∾𝕩∾˜÷5}¨𝕩+90×↕4
  90|m.WheelMoved⊸+𝕩
} d._withCanvas_ c.black

{𝕤
  font ← r.font.LoadBQN@
  x ← r.image.FromFile •file.At "logo.png"
  {
    𝕩‿font PerFrame•_While_(¬w.ShouldClose) 0
  } r.texture._WithImage x
  r.font.Unload font
} w._openAs "test"