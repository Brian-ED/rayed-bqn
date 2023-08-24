⟨color
 draw
 key
 rf⇐rayffi
 rm⇐raymath
⟩←rl←•Import "../../raylib.bqn"

# Check if point is inside rectangle
CheckCollision0ToRec ← ∧´(≤⟜0∾0⊸≤)˝∘⍉

# intersection using the slab method
# https://tavianator.com/2011/ray_box.html#:~:text=The%20fastest%20method%20for%20performing,remains%2C%20it%20intersected%20the%20box.
RayIntersectRect ← {direction𝕊box: # v2𝕊[v2,v2] → v2
  minParam‿maxParam ← ⌈´⊸∾⟜(⌊´)˝⍉{𝕊dir‿pos‿siz:
    (⌊´⋈⌈´) dir÷˜pos‿siz
  }˘⍉[direction]∾box
  {
    ∧´(<⟜0∾0⊸<)˝box?
      0‿0
  ;
    {𝕤
      direction×minParam
    }⍟(maxParam>0⌈minParam)∞×0⊸=⊸+×direction  # if maxParam < 0, ray is intersecting AABB, but the whole AABB is behind us # if minParam > maxParam, ray doesn't intersect AABB
  }
}

CheckCollisionRay2dCircle ← {𝕊⟨
    direction  # v2
    center     # v2
    radius     # f
  ⟩:
  {
    radius>+´⌾(×˜)center?
      0‿0
  ;
    dot ← 0⌈+´direction×center
    (+´⌾(×˜)center-direction×dot){
      direction×dot-radius-⌾(×˜)𝕨
    }⍟(<⟜radius)∞×0⊸=⊸+direction
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
  
  #ori ← 5‿5
  #•Show ⌈˝⍉[1‿1,4‿4]
  #•Show -⌊´-⟜ori¨⟨¯1‿1,4‿4⟩

  Rotate ← (⋈⟜-´≍⌽)•math.Cos∾•math.Sin
  {𝕤
    angleDelta ← turnSpeed×rf.GetFrameTime∘⟨⟩⊸×-´key.IsDown key.right‿key.left
    direction rm.MP˜↩ Rotate angleDelta
    origin +↩ walkSpeed×-˝key.IsDown ["DS","AW"]
    touchedRec‿touchedCir ← {
      intersect ↩•Show origin⊸+(>○|⊑∾)¨´ 𝕩
      ∞‿∞⊸≢¨|𝕩
    } ⟨
      direction RayIntersectRect -⟜origin˘box
      CheckCollisionRay2dCircle direction‿(center-origin)‿radius
    ⟩
    box rl.draw.Rectangle˜ touchedRec⊑colors
    rf.DrawCircleV⟨center⋄radius⋄touchedCir⊑colors⟩
    rf.DrawCircleV origin‿10‿color.yellow
    rf.DrawCircleV intersect‿5‿color.green
    color.blue rl.draw.Line +`origin≍direction×500
  } draw._withCanvas_ color.black •_while_ (¬rl.window.ShouldClose)@
} rl.window._openAs "raylib extras [Math2d] example - ray rect intersection"