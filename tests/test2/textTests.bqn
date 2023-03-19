⟨c⇐color,window,draw⟩←r←•Import "../../raylib.bqn"
txt←"Helloo!!!∾𝕨⍉↕"
fontSize←30
me←0
OnStart←{𝕤
  r.window.Open "hi"

  r.rayFFI.SetWindowState 4
  me↩r.rayFFI.LoadTexture "me.png"∾@ # Load texture from file into GPU memory (VRAM)
}

PerFrame ← {
  txt c.black draw._Text_ fontSize 𝕩
  # r.rayFFI.DrawTextCodepoints ⟨r.rayFFI.GetFontDefault⟨⟩, txt-@, ≠txt, 100‿100, fontSize‿30‿c.black⟩

  fps←" FPS"∾˜•Repr r.rayFFI.GetFPS⟨⟩
  fps c.black draw._Text_ fontSize 20‿20
  r.rayFFI.DrawTextureEx me‿𝕩‿45‿0.25‿c.white # texture position rotation scale tint

}∘⌊∘r.mouse.GetPos draw._withCanvas_ c.green

PerFrame•_While_(¬window.ShouldClose)∘OnStart window._openAs "test"
r.window.Close@