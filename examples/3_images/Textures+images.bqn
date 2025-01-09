⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../rayed.bqn"

PerFrame ← {
  tex‿font←𝕨
  𝕩 {𝕊scrolled:
    c.white‿font‿30 d.Text 20‿20⋈•Repr∘w.GetFPS⊸∾" FPS"
    {d.Texture⟜m.GetPos c.white‿tex∾𝕩∾˜÷5}¨𝕩+90×↕4
    90|m.WheelMoved⊸+𝕩
  }d._withCanvas c.black
}

{𝕤
  font ← r.font.LoadBQN@
  {
    𝕩‿font PerFrame•_While_(¬w.ShouldClose) 0
  } r.texture._WithFile •file.At "logo.png"
  r.font.Unload font
} w._openAs "test"
