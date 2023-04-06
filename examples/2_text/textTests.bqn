⟨c⇐color,window,draw⟩←r←•Import "../../raylib.bqn"

fontSize←30

OnStart←{𝕤
  •Show r.rayffi.LoadFont "BQN386.ttf"∾@
  •SHow r.rayffi.GetFontDefault⟨⟩
}

PerFrame ← {𝕊font:
  pos ← ⌊r.mouse.GetPos@
  
  #---------------------------------------------------------
  # None of these are currently working for unknown reasons. 
  # They do not error. All are related to font, 
  # so an issue with the font struct makes most sense.
  #---------------------------------------------------------
  # txt←"hello how are you? this is bqn ⥊⍉𝕨↕ :D"
  # r.rayFFI.DrawTextCodepoints ⟨font, txt-@, ≠txt, 20‿20, fontSize, 1, c.black⟩
  # r.rayFFI.DrawTextCodepoint  ⟨font, 'A'-@, 110‿100, 50, c.white⟩
  # r.rayFFI.DrawTextEx ⟨font, "hi!!"∾@, 20‿20, 10, 20, c.white⟩
  # r.rayFFI.DrawTextPro ⟨font, "hi!!"∾@, 110‿110, 0‿0, 0, 20, 20, c.white⟩
  
  fps←" FPS"∾˜•Repr window.fps.Get@
  fps c.black draw._Text_ fontSize 20‿20
  "Helloo!!!" c.white draw._Text_ fontSize pos
  𝕩
} draw._withCanvas_ c.green

PerFrame•_While_(¬window.ShouldClose)∘OnStart window._openAs_ "test" 1
