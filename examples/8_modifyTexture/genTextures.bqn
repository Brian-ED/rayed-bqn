⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

_OnStart ← {𝕤
  img ← r.image.New imgData←1000‿1000‿4⥊100/∾˘´≍¨´1000⥊¨c.blue⋈○<c.red
  tex ← r.rayffi.LoadTextureFromImage img
  r.image.Unload img
  font ← r.font.LoadBQN 100
  tex‿font𝔽imgData‿0
  r.texture.Unload tex
}
PerFrame ← {tex‿font𝕊img‿rot:
  c.white‿font‿30  d.Text 20‿20⋈•Repr∘w.fps.Get⊸∾" FPS"  
  
  (m.GetPos@)⊸{c.white‿tex‿0.2‿𝕩d.Texture𝕨}¨rot+90×↕4
  r.rayffi.UpdateTexture tex⋈⥊img
  (1⌽img)⋈90|m.WheelMoved⊸+rot
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬w.ShouldClose)_OnStart
Game w._openAs "test"
