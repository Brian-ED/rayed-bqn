⟨c⇐color,window,draw⟩←r←•Import "../../raylib.bqn"
fontSize←50

OnStart ← {𝕊⟨font⇐bqnFont⟩:
  PerFrame ← {
    pos ← ⌊r.mouse.GetPos@
    txt←"hello how are you? ⦃⦄ 𝕣 𝕩 this is bqn ⥊ ⍴ ⍺ ⍉↓ :D"
    fps←" FPS"∾˜•Repr window.fps.Get@
    c.black‿font‿fontSize      draw.Text 100‿50⋈txt
    c.black‿font‿(⌈fontSize÷4) draw.Text 20‿20⋈fps
    c.white‿font‿fontSize      draw.Text pos⋈"Helloo!!!"
  } draw._withCanvas_ c.green
  PerFrame•_While_(¬window.ShouldClose)@
}
OnStart window._openAs "test"
