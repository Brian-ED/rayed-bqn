⟨c⇐color,window,draw⟩←r←•Import "../../raylib.bqn"

fontSize←50

OnStart←{𝕤
  # Sorce of font and chars: https://dzaima.github.io/BQN386/
  r.font.LoadBQN 100
}

PerFrame ← {𝕊font:
  pos ← ⌊r.mouse.GetPos@
  txt←"hello how are you? ⦃⦄ 𝕣 𝕩 this is bqn ⥊ ⍴ ⍺ ⍉↓ :D"
  r.rayFFI.DrawTextCodepoints ⟨font, txt-@, ≠txt, 100‿50, fontSize, 1, c.black⟩
  r.rayFFI.DrawTextCodepoint  ⟨font, '⍴'-@, 100‿100, fontSize, c.white⟩

  ## r.rayFFI.DrawTextEx ⟨font, "⍴⍳"∾@, 100‿150, fontSize, 10, c.white⟩ 
  ## r.rayFFI.DrawTextPro ⟨font, "⍴⍳"∾@, 100‿200, 0‿0, 0, fontSize, 1, c.white⟩

  fps←" FPS"∾˜•Repr window.fps.Get@
  fps c.black draw._Text_ (⌈fontSize÷4) 20‿20
  "Helloo!!!" c.white draw._Text_ fontSize pos
  𝕩
} draw._withCanvas_ c.green

PerFrame•_While_(¬window.ShouldClose)∘OnStart window._openAs "test"
