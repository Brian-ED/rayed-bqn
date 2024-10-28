⟨⟨white, black⟩⇐color⟩←r←•Import "../../rayed.bqn"

PerFrame ← {
  pos ← r.mouse.GetPos@    # Position
  q←∾˘˘⟜⌽1‿¯1-⊸≍⊸×|0‿100-𝕩 # Morphing
  s←q⊸+˘[0‿0⋄100‿0⋄0‿100⋄¯100‿0⋄0‿¯100] # duping
  (white r.draw.EllipseOutline·⍉pos+⊢)˘˘⍉⁼s # moving + drawing
  100|𝕩+1
}r.draw._withCanvas⟜black

r.window.SetSize 0.5

PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Hello!!!"