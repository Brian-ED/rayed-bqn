⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

_OnStart ← {𝕩
  tex←r.texture.Load"logo.png"
  tex𝔽0
  r.texture.Unload tex
}
PerFrame ← {tex𝕊𝕩:
  20‿20 c.white d._Text_ 30˜•Repr∘w.fps.Get⊸∾" FPS"  
  c.white d._Texture_ tex⟜m.GetPos¨0.2⋈¨𝕩+90×↕4
  90|m.WheelMoved⊸+𝕩
} d._withCanvas_ c.black

Game ← PerFrame•_While_(¬w.ShouldClose)_OnStart
Game w._openAs "test"
