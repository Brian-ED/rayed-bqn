⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"
PerFrame ← {
  20‿20 c.white d._Text_ 30˜•Repr∘w.fps.Get⊸∾" FPS"
  c.white d._Texture_ 𝕨⟜(m.GetPos@)¨0.2⋈¨𝕩+90×↕4
  90|m.WheelMoved⊸+𝕩
} d._withCanvas_ c.black

Game ← r.texture.Load∘"logo.png" PerFrame•_While_(¬w.ShouldClose) 0˙
Game w._openAs_ "test" 1
