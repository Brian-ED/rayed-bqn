⟨color,window,draw⟩←r←•Import "../../rayed.bqn"
fontSize←50

txt←"hello how are you? ⦃⦄ 𝕣 𝕩 this is bqn ⥊ ⍴ ⍺ ⍉↓ :D"

PerFrame ← {𝕊a‿b‿c:
  fps←" FPS"∾˜•Repr window.GetFPS@
  color.black‿a‿fontSize     draw.Text 100‿50⋈txt
  color.black‿b‿(fontSize÷4) draw.Text 20‿20⋈fps
  color.white‿c‿fontSize     draw.Text r.mouse.GetPos⊸⋈"Helloo!!!"
  𝕩
}draw._withCanvas⟜color.darkgreen

App ← {𝕊:
  fonts ← ⟨
    (⍷txt) r.font.Load ⟨100⋄".ttf"⋄•FBytes "../../imports/BQN386/BQN386.ttf"⟩
    r.font.LoadBQN@
    r.font.LoadRaylib@
  ⟩
  PerFrame •_While_(¬window.ShouldClose) fonts
}
App window._openAs "test"