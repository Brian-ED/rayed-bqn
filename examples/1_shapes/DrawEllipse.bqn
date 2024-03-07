⟨⟨white, black⟩⇐color⟩←r←•Import "../../rayed.bqn"

PerFrame ← {
  pos ← r.mouse.GetPos@
  q←∾˘˘⟜⌽1‿¯1-⊸≍⊸×|0‿100-𝕩               # Morphing
  s←⍉˘⍉⁼∾˘˘˝q⊸+˘⍷⌽˘⊸∾100×0∾˘¬↕3          # duping
  (white r.draw.EllipseOutline pos⊸+˘)˘s # moving + drawing
  poses ← [pos,400‿300,300‿300]
  white r.draw.Triangle poses
  100|𝕩+1
}r.draw._withCanvas_ black

r.window.SetSize 0.5

PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Hello!!!"