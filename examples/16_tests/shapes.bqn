⟨⟨white, black⟩⇐color⟩←r←•Import "../../rayed.bqn"

PerFrame ← {
  pos ← 500-˜r.mouse.GetPos@
  anchors ← 300+300×↕10‿10
  d←r.draw
  [
    white d.EllipseOutline ·>⟨pos⋄0‿0⟩+<
    white d.Ellipse ·>⟨pos⋄0‿0⟩+<
    white d.Line ·>⟨pos⋄0‿0⟩+<
    white‿3 d.ThickLine ·>⟨pos⋄0‿0⟩+<
    white d.Rectangle ·>⟨pos⋄0‿0⟩+<
    white‿1 d.RectangleOutline ·>⟨pos⋄0‿0⟩+<
    #{rectangle‿rectangleoutline‿ellipse‿circle‿ellipseoutline‿triangle‿poly‿polylines‿advanced⇐}
  ] {𝕎𝕩}¨•Show 6‿1↑anchors
  𝕩+1
}r.draw._withCanvas⟜black

r.window.SetSize 0.5

PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Hello!!!"
