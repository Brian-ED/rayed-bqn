# Import raylib as r, and from r, take out color and key and rename the vars c and k
⟨c⇐color,window,draw⟩←r←•Import "../raylib.bqn"

# Defining the sizes of the shapes
rec←30 ⋄ cir←100

# Set the setting "Resize" to 1, so you can resize the window 
1 r.window.Setting "resize"

PerFrame ← {
  # radius, color, shape, position
  cir     c.red draw._Circle 𝕩
  # size, color, shape,           positions 
  rec‿rec c.red draw._Rectangle⚇1𝕩+⚇1∾⌜˜cir‿0-rec‿cir

# This function takes the mouse pos (floored) as input, and is being used to draw on a black canvas
}∘⌊∘r.mouse.GetPos draw._withCanvas_ c.black


PerFrame•_While_(¬window.ShouldClose) window._openAs "test"
# run PerFrame while condition is true, and run this with the window opened as "test" 
# if window should close, close it  ¯\_(ツ)_/¯
