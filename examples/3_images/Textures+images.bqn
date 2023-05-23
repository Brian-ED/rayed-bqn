⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"
MovePtr8 ← {b←256⋆↕8 ⋄ -⟜(256×≥⟜128) 256|⌊÷⟜b 𝕨+´b×256|𝕩}

_OnStart ← {𝕩
  tex‿img←"logo.png"⊸{𝕏𝕨}¨⟨r.texture.Load, r.image.Load⟩
  tex‿img𝔽0
  r.texture.Unload tex
  r.image.Unload img
}
PerFrame ← {tex‿img𝕊𝕩:
  20‿20 c.white d._Text_ 30˜•Repr∘w.fps.Get⊸∾" FPS"  
  c.white d._Texture_ tex⟜m.GetPos¨0.2⋈¨𝕩+90×↕4
  90|m.WheelMoved⊸+𝕩
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬w.ShouldClose)_OnStart
Game w._openAs "test"
