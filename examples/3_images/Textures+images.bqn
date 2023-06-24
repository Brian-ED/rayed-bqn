⟨⟨white,black⟩⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

#  Texture ← {⟨r‿g‿b‿a,rotation,texture⟩ 𝕊 scale‿pos:
#    NeedsWindow@
#    rayFFI.DrawTextureEx⟨texture,pos,rotation,scale,color⟩
#  }

PerFrame ← {tex‿font𝕊scrolled:
  white‿font‿30 d.Text 20‿20⋈•Repr∘w.fps.Get⊸∾" FPS"
  {d.Texture⟜m.GetPos white‿tex∾𝕩∾˜÷5}¨𝕩+90×↕4
  90|m.WheelMoved⊸+𝕩
} d._withCanvas_ black

{𝕊
  font←r.font.LoadBQN 100
  tex←r.texture.Load"logo.png"
  tex‿font PerFrame•_While_(¬w.ShouldClose) 0
  r.font.Unload font
  r.texture.Unload tex
} w._openAs "test"
