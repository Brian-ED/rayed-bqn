# Import raylib as r, and from r, take out color and key and rename the vars c and k
⟨⟨red, white, black⟩⇐color,window,draw⟩←r←•Import "../../raylib.bqn"

# Defining the sizes of the shapes
rec←30 ⋄ cir←100
outerRecs ← >⥊∾⌜˜cir‿0-rec‿cir


OnStart←{𝕊:
  r.rayFFI.SetWindowState 4
}
PerFrame ← {
  cir      red draw._Circle      𝕩
  # size, color, shape,           positions 
  (rec‿rec white draw._Rectangle 𝕩⊸+)˘ outerRecs

# This function takes the mouse pos (floored) as input, and is being used to draw on a black canvas
}∘⌊∘r.mouse.GetPos draw._withCanvas_ black

PerFrame•_While_(¬window.ShouldClose)∘OnStart window._openAs "Hello!!!"
# run PerFrame while condition is true, and run this with the window opened as "test" 
# if window should close, close it  ¯\_(ツ)_/¯