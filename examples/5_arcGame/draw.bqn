⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"
PerFrame ← {
  20‿20 c.white d._Text_ 30˜•Repr∘w.fps.Get⊸∾" FPS"
  100‿0 c.white d._Texture_ 𝕩 m.GetPos@
} d._withCanvas_ c.black

Game ← PerFrame•_While_(¬w.ShouldClose)r.texture.Load∘"test.png"
Game w._openAs_ "test" 1
