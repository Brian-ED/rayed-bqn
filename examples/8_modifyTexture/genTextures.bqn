⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

_OnStart ← {𝕤
  img ← r.image.New imgData←1000‿1000‿4⥊100/∾˘´≍¨´1000⥊¨c.blue⋈○<c.red
  tex ← r.rayffi.LoadTextureFromImage img
  r.image.Unload img
  tex𝔽imgData‿0
  r.texture.Unload tex
}
PerFrame ← {img‿rot←𝕩
  20‿20 c.white d._Text_ 30˜•Repr∘w.fps.Get⊸∾" FPS"  
  c.white d._Texture_𝕨⟜m.GetPos¨0.2⋈¨rot+90×↕4
  r.rayffi.UpdateTexture 𝕨⋈⥊img
  (1⌽img)⋈90|m.WheelMoved⊸+rot
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬w.ShouldClose)_OnStart
Game w._openAs "test"
