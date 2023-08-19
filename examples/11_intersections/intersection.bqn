⟨color
 draw
 key
 rf⇐rayffi
⟩←rl←•Import "../../raylib.bqn"
rm←•Import "../../src/raymath.bqn"

# intersection using the slab method
# https:#tavianator.com/2011/ray_box.html#:~:text=The%20fastest%20method%20for%20performing,remains%2C%20it%20intersected%20the%20box.

RayIntersectRect←{
  𝕊⟨
    box       # [v2,v2]
    origin    # v2
    direction # v2
  ⟩:
  minParam‿maxParam ← ⌈´⊸⋈⟜(⌊´)´<˘⍉{𝕊dir‿ori‿pos‿siz:
    (⌊´⋈⌈´) dir÷˜pos‿siz-ori
  }˘⍉[direction,origin]∾⍉box

  intersection←∞‿∞
  {𝕊:intersection}⊸⊣{
    maxParam < 0?0;        # if maxParam < 0, ray is intersecting AABB, but the whole AABB is behind us
    minParam > maxParam?0; # if minParam > maxParam, ray doesn't intersect AABB
    intersection↩origin + direction × minParam
    1
  }
}

CheckCollisionRay2dCircle ← {
  𝕊⟨
    origin     # v2
    direction  # v2
    center     # v2
    radius     # f
  ⟩:
  {
    rf.CheckCollisionPointCircle origin‿center‿radius?
      origin
  ; 
    dot ← 0⌈+´direction×center-origin
    Nearest ← origin+direction×⊢
    (+´⌾(×˜)center-Nearest dot){
      Nearest dot--´⌾(×˜)radius⋈𝕨
    }⍟(≤⟜radius)𝕩
  }∞‿∞
}
{𝕤
  box ← [100‿300,
         100‿150]
  origin ← 450‿300
  direction ← 0‿¯1
  center ← 600‿200
  radius ← 50
  intersect ← ∞‿∞
  # Main game loop
  {𝕤
    angleDelta ← rf.GetFrameTime⊸×-´rf.IsKeyDown¨key.right‿key.left
    direction ↩ rm.Vector2Transform direction⋈rm.MatrixRotateZ 0.5×angleDelta×π

    touchedRec‿touchedCir ← {
      intersect ↩ ⌊´𝕩
      ∞‿∞⊸≢¨𝕩
    } ⟨
      RayIntersectRect box‿origin‿direction
      CheckCollisionRay2dCircle origin‿direction‿center‿radius
    ⟩
    box rl.draw.Rectangle˜ color.red⍟touchedRec color.gray
    rf.DrawCircleV origin‿10‿color.yellow

    rf.DrawCircleV¨touchedCir⊑⟨
      ⟨center‿radius‿color.gray⟩
      ⟨
        center‿radius‿color.red
        intersect‿5‿color.green
      ⟩
    ⟩
    rf.DrawLineV⟨origin, origin+direction×500, color.blue⟩
    rf.DrawCircleV intersect‿5‿color.green
  } draw._withCanvas_ color.black •_while_ (¬rl.window.ShouldClose)@
} rl.window._openAs "raylib extras [Math2d] example - ray rect intersection"