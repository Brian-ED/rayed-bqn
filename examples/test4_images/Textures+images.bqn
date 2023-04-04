⟨c⇐color,window,draw⟩←r←•Import "../../raylib.bqn"

fontSize←30

OnStart←{𝕊:⟨
  0 ⋄ r.rayFFI.LoadTexture "logo.png"∾@ # original SVG taken from https://github.com/mlochbaum/BQN/blob/master/logo.svg
⟩}
PerFrame ← {𝕊⟨meRot, logo⟩:
  pos←⌊r.mouse.GetPos@
  fps←" FPS"∾˜•Repr r.rayFFI.GetFPS⟨⟩
  fps c.black draw._Text_ fontSize 20‿20
  {r.rayFFI.DrawTextureEx ⟨logo, pos, meRot+𝕩, 0.2, c.white⟩}¨90×↕4
  ⟨90|meRot+r.rayFFI.GetMouseWheelMove⟨⟩, logo⟩
} draw._withCanvas_ c.green

PerFrame•_While_(¬window.ShouldClose)∘OnStart window._openAs_ "test" 1
