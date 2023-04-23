⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../../raylib.bqn"

PerFrame ← {
  pos←⌊r.mouse.GetPos@
  𝕩{
    r.rayffi.DrawEllipse 𝕩∾(|0‿100-𝕨)∾<4⥊255
    r.rayffi.DrawEllipse 𝕩∾(|⌽0‿100-𝕨)∾<4⥊255
  }¨pos⊸+¨⟨0‿0, 100‿0, 0‿100, ¯100‿0, 0‿¯100⟩
  100|𝕩+1
} draw._withCanvas_ black

0.5 PerFrame•_While_(¬window.ShouldClose)∘0 window._openAs "Hello!!!" 