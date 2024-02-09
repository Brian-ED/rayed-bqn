# translated from https://github.com/raylib-extras/examples-c/blob/main/ray2d_rect_intersection/ray2d_rect_intersection.c

⟨color
 draw
 key
 rf⇐rayffi
 rm⇐raymath
⟩←rl←•Import "../../raylib.bqn"

# intersection using the slab method
# https://tavianator.com/2011/ray_box.html#:~:text=The%20fastest%20method%20for%20performing,remains%2C%20it%20intersected%20the%20box.
RayIntersectRect ← {direction𝕊box: # v2𝕊[v2,v2] → v2
  minParam‿maxParam ← 0⌈⌈´⊸∾⟜(⌊´)˝⍉∧˘direction÷˜⍉box
  {maxParam>minParam?
    direction×minParam
  ;
    ∞⊸×⍟(0⊸≠)¨direction
  }  # if maxParam < 0, ray is intersecting AABB, but the whole AABB is behind us # if minParam > maxParam, ray doesn't intersect AABB
}
# maxParam>0⌈minParam
# (x>0)∧y<x
CheckCollisionRay2dCircle ← {direction𝕊⟨center⋄radius⟩: # v2 v2 f
  dot ← 0⌈+´direction×center
  n ← (+´⌾(×˜)center-direction×dot)
  {n<radius?
    direction×0⌈dot-radius-⌾(×˜)n
  ;
    ∞×0⊸=⊸+direction
  }
}
{𝕤
  box ← [100‿100
         300‿150]
  origin    ← 450‿300
  direction ← 0‿¯1
  center    ← 600‿200
  radius    ← 50
  intersect ← ∞‿∞
  colors    ← color.gray‿color.red
  walkSpeed ← 3
  turnSpeed ← 3

  # Main game loop
  Rotate ← (⋈⟜-´≍⌽)•math.Cos∾•math.Sin
  {𝕤
    angleDelta ← turnSpeed×rf.GetFrameTime∘⟨⟩⊸×-´key.IsDown key.right‿key.left
    direction rm.MP˜↩ Rotate angleDelta
    origin +↩ walkSpeed×-˝key.IsDown ["DS","AW"]
    touchedRec‿touchedCir ← {
      intersect ↩ origin+⌊˝˘⌾((0⊸=⊸+×direction)⊸×)𝕩
      ∧˝∞≠|𝕩
    } ⍉[
      direction RayIntersectRect -⟜origin˘box
      direction CheckCollisionRay2dCircle⟨center-origin, radius⟩
    ]
    box rl.draw.Rectangle˜ touchedRec⊑colors
    rf.DrawCircleV⟨center⋄radius⋄touchedCir⊑colors⟩
    rf.DrawCircleV origin‿10‿color.yellow
    rf.DrawCircleV intersect‿5‿color.green
    color.blue rl.draw.Line +`origin≍direction×500
  } draw._withCanvas_ color.black •_while_ (¬rl.window.ShouldClose)@
} rl.window._openAs "raylib extras [Math2d] example - ray rect intersection"