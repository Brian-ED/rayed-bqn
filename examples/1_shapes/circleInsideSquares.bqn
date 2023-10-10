# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../../raylib.bqn"

# sizes of the shapes
rec←60 ⋄ cir←400
# positions of the squares
distFromMiddle ← 170
outerRecs ← distFromMiddle×¯1+2×>⥊↕2‿2

window.SetSize 0.5

PerFrame ← {𝕤
  # mouse pos floored
  pos←r.mouse.GetPos@
   red     draw.Ellipse   cir⊸+⊸≍  pos-cir÷2
  {white   draw.Rectangle rec⊸+⊸≍𝕩+pos-rec÷2}˘outerRecs 
  # color, shape,         positions
  # this drawing function is being used to draw on a black canvas
} draw._withCanvas_ black

# 0.5 sets window size to half the monitor size
PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!" 
# run PerFrame while condition is true, and run this with the window opened as "test" 
# if window should close, close it  ¯\_(ツ)_/¯ 
