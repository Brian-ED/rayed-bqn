⟨⟨white, black⟩⇐color⟩←r←•Import "../../raylib.bqn"
EO ← r.draw.EllipseOutline

PerFrame ← {
  q←∾˘˘⟜⌽1‿¯1-⊸≍⊸×|0‿100-𝕩   # Morphing
  s←∾˘˘˝q⊸+˘⍷⌽˘⊸∾100×0∾˘¬↕3  # duping
  white EO r.mouse.GetPos⊸+s # moving + drawing
  100|𝕩+1
}r.draw._withCanvas_ black

0.5 PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Hello!!!" 