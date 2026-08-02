⟨⟨w⇐white, black⟩⇐color⟩←r←•Import "../../rayed.bqn"

d←r.draw
drawFns ←   [
  ⟨
    w d.EllipseOutline ·>⋈⟜0‿0+<∘⊢
    w d.Ellipse ·>⋈⟜0‿0+<∘⊢
  ⟩
  ⟨
    w‿3 d.Line ·>⋈⟜0‿0+<∘⊢
    @
  ⟩
  ⟨
    w d.Rectangle ·>⋈⟜0‿0+<∘⊢
    w d.RectangleOutline ·>⋈⟜0‿0+<∘⊢
  ⟩
  ⟨
    w d.Circle ⊑⊸(⋈˜)
    w d.Triangle ·∾⟜⍉´⋈⟜[0‿0⋄0‿100]+<∘⊢
  ⟩
  ⟨
    {w d.Poly ⟨𝕩⋄⌊30÷˜1⊑𝕨⋄⊑𝕨⋄10⟩}
    {w‿20 d.PolyOutline ⟨𝕩⋄⌊30÷˜1⊑𝕨⋄⊑𝕨⋄10⟩}
  ⟩
]

PerFrame ← {𝕊:
  pos ← 500-˜r.mouse.GetPos@
  drawFns {pos𝕎𝕩}¨300+300×↕≢drawFns
  𝕩+1
}r.draw._withCanvas⟜black

r.window.SetSize 0.5

PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Hello!!!"
