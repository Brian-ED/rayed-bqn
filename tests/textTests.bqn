⟨c⇐color,window,draw⟩←r←•Import "../raylib.bqn"

PerFrame ← {
  30‿30 c.white draw._Rectangle 𝕩
  r.rayFFI.DrawFPS 10‿10
  r.rayFFI.DrawText ("Helloo!!!"∾@)<⊸∾𝕩∾30‿c.black # text posX posY fontSize color
}∘⌊∘r.mouse.GetPos draw._withCanvas_ c.white

PerFrame•_While_(¬window.ShouldClose) window._openAs "testa"
