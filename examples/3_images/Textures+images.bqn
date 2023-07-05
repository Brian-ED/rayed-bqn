⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

#  Texture ← {⟨r‿g‿b‿a,rotation,texture⟩ 𝕊 scale‿pos:
#    NeedsWindow@
#    rayFFI.DrawTextureEx⟨texture,pos,rotation,scale,color⟩
#  }

PerFrame ← {tex‿font𝕊scrolled:
  c.white‿font‿30 d.Text 20‿20⋈•Repr∘w.fps.Get⊸∾" FPS"
  {d.Texture⟜m.GetPos c.white‿tex∾𝕩∾˜÷5}¨𝕩+90×↕4
  90|m.WheelMoved⊸+𝕩
} d._withCanvas_ c.black

BQNToRayImg←{𝕊img:⟨⥊img⟩∾(4⊸∾⁼{𝔽⌾⌽⎊𝔽}≢img)∾1‿r.pixelFormat.uncompressed_r8g8b8a8}

loadTextureFromImage ⇐ {
  _R‿S‿P‿i8‿i‿texture←r.rayffi
  f ← texture "LoadTextureFromImage"_R S i8<∘P⊸∾4⥊<i
  F BQNToRayImg
}
{𝕤
  font ← r.font.LoadBQN@
  #r.image.LoadBQN "logo.png"
  x←•Show∘≢⊸⊢>∾((∾˜1280÷2)⥊<)¨⌽⊸≍c.blue‿c.red
  tex ← LoadTextureFromImage x
  tex‿font PerFrame•_While_(¬w.ShouldClose) 0
  r.font   .Unload •Show font
  r.texture.Unload tex
} w._openAs "test"