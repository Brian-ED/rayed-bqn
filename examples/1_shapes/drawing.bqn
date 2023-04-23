⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../../raylib.bqn"
ind ← {
  shape   ⇐ 0    # 0:rectange 1:sircle ...
  pos     ⇐ 1+↕2 # x y
  size    ⇐ 3+↕2 # x y
  visDeg  ⇐ 5+↕1
  outline ⇐ 6+↕1
  color   ⇐ 7+↕4 # r g b a
}
DrawShape ← {𝕊 shapeData2d:
  R ← 1↓⟜∾' '∾¨⊢
  •SHow⟨
    {Rectangle:
      absPos ← ind.pos⊏𝕩
      size   ← ind.size⊏𝕩
      "DrawRectangle "∾•Repr ⟨size⊸+⊸∾absPos, 0‿0, ind.color⊏𝕩⟩
    }˘
    {Circle:
      absPos ← ind.pos⊏𝕩
      size   ← ind.size⊏𝕩
      ("drawCircleSector ")∾•Repr size⊸+⊸∾absPos
          # drawCircleSector          ⇐ "DrawCircleSector"          _R v2‿f‿f‿f‿i‿color      # center radius startAngle endAngle segments                  # Draw a piece of a circle
    }˘
  ⟩(⊣{𝕎𝕩}¨≠⊸↑)(⊏⊔⍉)shapeData2d
  @
}

inp ← ∾⟨
  1‿0‿0   # type
  2‿3⥊10  # pos x y z
  [2‿1‿5  # Size x y
   2‿1‿5]
  2÷˜π×↕3 # rotation
  3⥊2×π   # Degrees of visability for sircle sectors, ignored for rectangles
  0‿0‿0   # only outline
  ⍉>3⥊<white # colors
⟩
DrawShape inp

•Exit @

drawCircleSectorLines     ⇐ "DrawCircleSectorLines"     _R v2‿f‿f‿f‿i‿color      # center radius startAngle endAngle segments                  # Draw circle sector outline
drawCircleGradient        ⇐ "DrawCircleGradient"        _R i‿i‿f‿color‿color     # centerX centerY radius color1 color2                        # Draw a gradient-filled circle
drawCircleLines           ⇐ "DrawCircleLines"           _R i‿i‿f‿color           # centerX centerY radius                                      # Draw circle outline
drawEllipseLines          ⇐ "DrawEllipseLines"          _R i‿i‿f‿f‿color         # centerX centerY radiusH radiusV                             # Draw ellipse outline
drawRing                  ⇐ "DrawRing"                  _R v2‿f‿f‿f‿f‿i‿color    # center innerRadius outerRadius startAngle endAngle segments # Draw ring
drawRingLines             ⇐ "DrawRingLines"             _R v2‿f‿f‿f‿f‿i‿color    # center innerRadius outerRadius startAngle endAngle segments # Draw ring outline
drawRectanglePro          ⇐ "DrawRectanglePro"          _R rectangle‿v2‿f‿color  # rectangle origin rotation                                   # Draw a color-filled rectangle with pro parameters
drawRectangleGradientV    ⇐ "DrawRectangleGradientV"    _R i‿i‿i‿i‿color‿color   # posX posY width hight                                        # Draw a vertical-gradient-filled rectangle
drawRectangleGradientH    ⇐ "DrawRectangleGradientH"    _R i‿i‿i‿i‿color‿color   # posX posY width hight                                       # Draw a horizontal-gradient-filled rectangle
drawRectangleGradientEx   ⇐ "DrawRectangleGradientEx"   _R rectangle<⊸∾4⥊<color  #                                                             # Draw a gradient-filled rectangle with custom vertex colors
drawRectangleLines        ⇐ "DrawRectangleLines"        _R i‿i‿i‿i‿color         # posX posY width hight color                                 # Draw rectangle outline
drawRectangleLinesEx      ⇐ "DrawRectangleLinesEx"      _R rectangle‿f‿color     # rectangle lineThick                                         # Draw rectangle outline with extended parameters
drawRectangleRounded      ⇐ "DrawRectangleRounded"      _R rectangle‿f‿i‿color   # rectangle roundness segments color                          # Draw rectangle with rounded edges
drawRectangleRoundedLines ⇐ "DrawRectangleRoundedLines" _R rectangle‿f‿i‿f‿color # rectangle roundness segments lineThick                      # Draw rectangle with rounded edges outline
drawTriangle              ⇐ "DrawTriangle"              _R v2‿v2‿v2‿color        #                                                             # Draw a color-filled triangle _R vertex in counter-clockwise order!)
drawTriangleLines         ⇐ "DrawTriangleLines"         _R v2‿v2‿v2‿color        #                                                             # Draw triangle outline _R vertex in counter-clockwise order!)
drawTriangleFan           ⇐ "DrawTriangleFan"           _R points‿i‿color        # points pointCount                                           # Draw a triangle fan defined by points _R first vertex is the center)
drawTriangleStrip         ⇐ "DrawTriangleStrip"         _R points‿i‿color        # points pointCount                                           # Draw a triangle strip defined by points
drawPoly                  ⇐ "DrawPoly"                  _R v2‿i‿f‿f‿color        # center sides radius rotation                                # Draw a regular polygon _R Vector version)
drawPolyLines             ⇐ "DrawPolyLines"             _R v2‿i‿f‿f‿color        # center sides radius rotation                                # Draw a polygon outline of n sides
drawPolyLinesEx           ⇐ "DrawPolyLinesEx"           _R v2‿i‿f‿f‿f‿color      # center sides radius rotation lineThick                      # Draw a polygon outline of n sides with extended parameters

rec←30 ⋄ cir←100
outerRecs ← >⥊∾⌜˜cir‿0-rec‿cir

PerFrame ← {𝕤
  pos←⌊r.mouse.GetPos@
  cir      red   draw._Circle    pos
  (rec‿rec white draw._Rectangle pos⊸+)˘ outerRecs
} draw._withCanvas_ black

0.5 PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!" 