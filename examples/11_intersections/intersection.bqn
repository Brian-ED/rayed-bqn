# translated from https://github.com/raylib-extras/examples-c/blob/main/ray2d_rect_intersection/ray2d_rect_intersection.c

⟨color
 draw
 key
 rf⇐raylib
 rm⇐raymath
⟩←rl←•Import "../../rayed.bqn"

# intersection using the slab method
# https://tavianator.com/2011/ray_box.html#:~:text=The%20fastest%20method%20for%20performing,remains%2C%20it%20intersected%20the%20box.
RayIntersectRect ← {direction𝕊box: # v2𝕊[v2,v2] → v2
  𝕨×⍟(0⊸≠)¨˜∞⍟(∨´≤)⟜(0⌈⌈´)˜˝⍉∧˘𝕨÷˜⍉𝕩
}
# maxParam>0⌈minParam
# (x>0)∧y<x
CheckCollisionRay2dCircle ← {direction𝕊center‿radius: c‿r←𝕩 # v2 𝕊 v2‿f
  𝕨×⍟(0⊸≠)¨˜-0⌊(0⊸<◶¯∞‿√r×˜⊸-·+´∘×˜c-𝕨×⊢)⌾((0⌈+´𝕨×c)⊸+)0
}
{𝕤
  box ← [100‿100
         300‿150]
  origin    ← 450‿300
  direction ← 0‿¯1
  center    ← 600‿200
  radius    ← 50
  colors    ← color.gray‿color.red
  walkSpeed ← 3
  turnSpeed ← 3

  Rotate ← (⋈⟜-´≍⌽)•math.Cos∾•math.Sin

  # Main game loop
  {𝕤
    angleDelta ← turnSpeed×rf.GetFrameTime∘⟨⟩⊸×-´key.IsDown key.right‿key.left
    direction rm.MP˜↩ Rotate angleDelta
    origin +↩ walkSpeed×-˝key.IsDown ["DS","AW"]
    interaction ← ⍉[
      direction RayIntersectRect -⟜origin˘box
      direction CheckCollisionRay2dCircle⟨center-origin, radius⟩
    ]
    touchedRec‿touchedCir ← ∧˝∞≠|interaction
    intersect ← origin+⌊˝˘⌾((0⊸=⊸+direction)⊸×)interaction

    box rl.draw.Rectangle˜ touchedRec⊑colors
    rf.DrawCircleV⟨center⋄radius⋄touchedCir⊑colors⟩
    rf.DrawCircleV origin‿10‿color.yellow
    rf.DrawCircleV intersect‿5‿color.green
    color.blue rl.draw.Line +`origin≍direction×500
  }draw._withCanvas⟜color.black •_while_ (¬rl.window.ShouldClose)@
} rl.window._openAs "raylib extras [Math2d] example - ray rect intersection"