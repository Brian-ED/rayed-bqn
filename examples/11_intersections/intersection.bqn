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
        x‿y‿width‿height # v4
        origin    # v2
        direction # v2
    ⟩:

    minParam ← ¯∞
    maxParam ← ∞
    mon ← 𝕨0⊘1𝕩
    {𝕤
        txMin ← (⊑direction) ÷˜ (⊑origin) -˜ x
        txMax ← (⊑direction) ÷˜ (⊑origin) -˜ x + width  

        minParam ⌈↩ txMin ⌊ txMax
        maxParam ⌊↩ txMin ⌈ txMax
    }⍟⊢0≢⊑direction
    {𝕤
        tyMin ← (1⊑direction) ÷˜ (1⊑origin) -˜ y
        tyMax ← (1⊑direction) ÷˜ (1⊑origin) -˜ y + height

        minParam ⌈↩ tyMin⌊tyMax
        maxParam ⌊↩ tyMin⌈tyMax
    }⍟⊢0≢1⊑direction
    {
        maxParam < 0?0;        # if maxParam < 0, ray is intersecting AABB, but the whole AABB is behind us
        minParam > maxParam?0; # if minParam > maxParam, ray doesn't intersect AABB
        mon? 1 ∾ origin + direction × minParam
        ;1
    }
}

CheckCollisionRay2dCircle ← {
    intersection𝕊⟨ # v2
        origin     # v2
        direction  # v2
        center     # v2
        radius     # f
    ⟩:
    mon ← (𝕨0⊘1𝕩)
    intersection⊸⋈ { rf.CheckCollisionPointCircle origin‿center‿radius?
        1⊣{𝕊:intersection ↩ origin}⍟mon@
    ;
        vecToCenter ← center - origin
        dot ← +´vecToCenter×direction
        {dot<0 ? 0;
            nearest ← origin + direction × dot

            nearestToCenter ← center - nearest
            distSq          ← +´nearestToCenter⋆2

            distSq ≤ radius × radius ?
            1⊣{𝕤
                nearestDist ← √´×˜center-nearest
                b ← √´-´radius‿nearestDist⋆2
                intersection ↩ origin + direction × dot - b
            }⍟⊢¬mon
            ;0
        }
    }
}

{𝕤
    rect ← 100‿100‿200‿50
    origin ← 450‿300
    direction ← 0‿¯1
    center ← 600‿200
    radius ← 50

    # Main game loop
    {𝕤
        angleDelta ← 90×rf.GetFrameTime⊸×-´rf.IsKeyDown¨key.left‿key.right
        intersect ← 0‿0
        direction ↩ rm.Vector2Transform direction⋈rm.MatrixRotateZ angleDelta × π÷180

        hit ← RayIntersectRect rect‿origin‿direction

        rf.DrawRectangleRec rect ⋈ color.red⍟hit color.gray
        rf.DrawCircleV origin‿10‿color.yellow

        rf.DrawCircleV⍟hit intersect‿5‿color.green

        rf.DrawCircleV¨(⊢´intersect‿·↩intersect CheckCollisionRay2dCircle origin‿direction‿center‿radius)⊑⟨
            ⟨center‿radius‿color.gray⟩
            ⟨
                center‿radius‿color.red
                center‿2‿color.white
                intersect‿5‿color.green
            ⟩
        ⟩
        rf.DrawLineV⟨origin, origin+direction×500, color.blue⟩
    } draw._withCanvas_ color.black •_while_ (¬rl.window.ShouldClose) @
} rl.window._openAs "raylib extras [Math2d] example - ray rect intersection"