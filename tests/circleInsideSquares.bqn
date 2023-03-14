⟨rayFFI, k, c⟩←r←•Import "../raylib.bqn"

"Test"r.window._Init 1000‿1000
r.window.SetToResizable 1
rec←30
cir←100
{
  r.window.ClearBackground c.black
  cir     c.red r.draw._Circle 𝕩
  rec‿rec c.red r.draw._Rectangle⚇1𝕩+⚇1∾⌜˜cir‿0-rec‿cir
}r.draw._with∘⌊∘rayFFI.GetMousePosition •_While_{𝕤
  ¬∨´⟨r.window.Close@⋄r.IsKeyPressed k.kESCAPE⟩
}@
rayFFI.CloseWindow ⟨⟩