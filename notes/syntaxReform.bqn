## THIS EXAMPLE IS IN PROGRESS, it's dependant on obj.bqn

rl←•Import "../raylib.bqn"

circles ← ⟨0‿0, 1‿0, 0‿1, ¯1‿0, 0‿¯1⟩ ×⟜100 obj._Move obj.cirOutline

PerFrame ← {
  a ← ⌽obj._Scale⊸⋈(|0‿100-𝕩)+obj._Scale rl.mouse.GetPos⊸+obj._Move circles
  rl.color.black obj.Draw a
  100|𝕩+1
}
PerFrame•_While_(¬rl.window.ShouldClose)∘0 rl.window._openAs "Hello!!!"