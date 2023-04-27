## THIS EXAMPLE IS IN PROGRESS, it's dependant on obj.bqn

# ⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../../raylib.bqn"
# ind ← {
#   shape   ⇐ 0    # 0:rectange 1:sircle ...
#   pos     ⇐ 1+↕2 # x y
#   size    ⇐ 3+↕2 # x y
#   visDeg  ⇐ 5+↕1
#   outline ⇐ 6+↕1
#   color   ⇐ 7+↕4 # r g b a
# }
# DrawShape ← {𝕊 shapeData2d:
#   R ← 1↓⟜∾' '∾¨⊢
#   •SHow⟨
#     {Rectangle:
#       absPos ← ind.pos⊏𝕩
#       size   ← ind.size⊏𝕩
#       "DrawRectangle "∾•Repr ⟨size⊸+⊸∾absPos, 0‿0, ind.color⊏𝕩⟩
#     }˘
#     {Circle:
#       absPos ← ind.pos⊏𝕩
#       size   ← ind.size⊏𝕩
#       ("drawCircleSector ")∾•Repr size⊸+⊸∾absPos
#           # drawCircleSector          ⇐ "DrawCircleSector"          _R v2‿f‿f‿f‿i‿color      # center radius startAngle endAngle segments                  # Draw a piece of a circle
#     }˘
#   ⟩(⊣{𝕎𝕩}¨≠⊸↑)(⊏⊔⍉)shapeData2d
#   @
# }

# inp ← ∾⟨
#   1‿0‿0   # type
#   2‿3⥊10  # pos x y z
#   [2‿1‿5  # Size x y
#    2‿1‿5]
#   2÷˜π×↕3 # rotation
#   3⥊2×π   # Degrees of visability for sircle sectors, ignored for rectangles
#   0‿0‿0   # only outline
#   ⍉>3⥊<white # colors
# ⟩
# DrawShape inp

rl←•Import "../raylib.bqn"
obj←•Import "obj.bqn"

circles ← ⟨0‿0, 1‿0, 0‿1, ¯1‿0, 0‿¯1⟩ ×⟜100 obj._Move obj.cirOutline

PerFrame ← {
  a ← ⌽obj._Scale⊸⋈(|0‿100-𝕩)+obj._Scale rl.mouse.GetPos⊸+obj._Move circles
  rl.color.black obj.Draw a
  100|𝕩+1
}
PerFrame•_While_(¬rl.window.ShouldClose)∘0 rl.window._openAs "Hello!!!"