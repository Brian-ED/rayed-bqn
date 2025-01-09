# Credit: Bugsworth

⟨color
 draw
 key
 rf⇐raylib
 rm⇐raymath
⟩ ← rl ← •Import "../../rayed.bqn"

{𝕊
    # Initialisation
    position ← 0‿0
    direction ← 0‿0
    dashDir ← 0‿0
    timeSinceSpace ← ¯∞

    # Player features
    staminaLimit ← 100
    staminaComsumption ← 25
    staminaRecovery ← 1
    stamina ← 100

    moveSpeed ← 5
    dashSpeed ← 10

    playerPhase ← ⟨color.yellow, color.green⟩

    {𝕊
        condition ← 0.25 > (•MonoTime@)-timeSinceSpace

        # Space pressed thingy
        {key.IsPressed key.space ∧ stamina > 0?
            timeSinceSpace ↩ •MonoTime@
            dashDir ↩ direction
            stamina -↩ stamina ⌊ staminaComsumption
            ;@
        }

        # Stamina management
        {(1 < (•MonoTime@)-timeSinceSpace) ∧ stamina < staminaLimit?
            stamina +↩ staminaRecovery ; @
        }

        # Directional movement of the player
        position +↩ {condition ?
            dashDir × dashSpeed
            ;
            moveSpeed×rm.Vectornormalize-˝key.IsDown ["DS","AW"]
        }
        rf.DrawCircleV position‿10‿(condition⊑playerPhase)

        # Drawing arrow towards mouse
        oppositeAdjacent ← position - rl.mouse.GetPos@
        direction ↩ -rm.Vectornormalize oppositeAdjacent
        color.blue rl.draw.Line +`position≍direction×50

        # Drawing the stamina bar
        color.green rl.draw.Rectangle [50‿25 ⋄ 2×(stamina + 25)‿10]
    } draw._withCanvas⟜color.black •_while_ (¬rl.window.ShouldClose)@

} rl.window._openAs "Game"
