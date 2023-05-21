⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"
MovePtr8 ← {b←256⋆↕8 ⋄ -⟜(256×≥⟜128) 256|⌊÷⟜b 𝕨+´b×256|𝕩}
⟨void⟩ ← r.rayffi
read ← @•FFI""‿"bqn_readI32Arr"‿">a"‿("𝕨>"∾void)     # write to ptr
make ← @•FFI"a"‿"bqn_makeI32Vec"‿"𝕨>u64"‿(">"∾void)  # materialize
malloc ← @•FFI void‿"malloc"‿">u64"                   # alocate u64

_OnStart ← {𝕩
  tex‿img←"logo.png"⊸{𝕏𝕨}¨⟨r.texture.Load, r.image.Load⟩
  test ← Malloc 8
  test Read 8⥊0
  test‿tex‿img𝔽0
}

PerFrame ← {test‿tex‿img𝕊𝕩:
  20‿20 c.white d._Text_ 30˜•Repr∘w.fps.Get⊸∾" FPS"

  r.rayffi.UpdateTexture tex⋈test
  
  c.white d._Texture_ tex⟜m.GetPos¨0.2⋈¨𝕩+90×↕4
  90|m.WheelMoved⊸+𝕩
} d._withCanvas_ c.black

Game ← PerFrame _OnStart•_While_(¬w.ShouldClose)
Game w._openAs "test"
