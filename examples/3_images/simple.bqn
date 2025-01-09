⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../rayed.bqn"

w.SetSize 0.5

{𝕤
  tex ← r.texture.Load •file.At "logo.png"

  {𝕤
    c.white‿tex‿0.2‿0 d.Texture 0‿0
  }d._withCanvas⟜c.black •_While_(¬w.ShouldClose)@

  r.texture.Unload tex
} w._openAs "test"
