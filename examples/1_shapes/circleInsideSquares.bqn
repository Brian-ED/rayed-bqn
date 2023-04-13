# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../../raylib.bqn"

# sizes of the shapes
rec←30 ⋄ cir←100
# positions of the squares
outerRecs ← >⥊∾⌜˜cir‿0-rec‿cir

PerFrame ← {𝕤
  # mouse pos floored
  pos←⌊r.mouse.GetPos@
  cir      red   draw._Circle    pos
  # size, color, shape,          positions 
  (rec‿rec white draw._Rectangle pos⊸+)˘ outerRecs
  # this drawing function is being used to draw on a black canvas
} draw._withCanvas_ black

# 0.5 sets window size to half the monitor size
0.5 PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!" 
# run PerFrame while condition is true, and run this with the window opened as "test" 
# if window should close, close it  ¯\_(ツ)_/¯