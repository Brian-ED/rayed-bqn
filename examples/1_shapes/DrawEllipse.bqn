⟨⟨red, white, black⟩⇐color, window⟩←r←•Import "../../raylib.bqn"

Draw ← {b𝕊a:
  {(|𝕏0‿100-b) white r.draw._EllipseOutline a}¨⊢‿⌽
}¨ r.draw._withCanvas_ black

PerFrame ← {
  pos←⌊r.mouse.GetPos@
  𝕩 Draw pos⊸+¨⟨0‿0, 100‿0, 0‿100, ¯100‿0, 0‿¯100⟩
  100|𝕩+1
}

0.5 PerFrame•_While_(¬window.ShouldClose)∘0 window._openAs "Hello!!!" 