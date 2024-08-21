⟨c⇐color,window,draw⟩←r←•Import "../../rayed.bqn"
fontSize←50

PerFrame ← {
  txt←"hello how are you? ⦃⦄ 𝕣 𝕩 this is bqn ⥊ ⍴ ⍺ ⍉↓ :D"
  fps←" FPS"∾˜•Repr window.GetFPS@
  c.black‿𝕩‿fontSize     draw.Text 100‿50⋈txt
  c.black‿𝕩‿(fontSize÷4) draw.Text 20‿20⋈fps
  c.white‿𝕩‿fontSize     draw.Text r.mouse.GetPos⊸⋈"Helloo!!!"
  𝕩
} draw._withCanvas_ c.darkgreen

App ← {𝕊: PerFrame •_While_(¬window.ShouldClose) r.font.LoadBQN@}
App window._openAs "test"