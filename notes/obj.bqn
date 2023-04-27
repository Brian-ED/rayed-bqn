## trying to make better syntax for the drawing functions

⟨ cirOutline, cir, rec
  _Move, _Scale, _Color
⟩⇐
# obj(square=0) layer posx posy lenx leny r g b a
x‿y‿sx‿sy ← 0‿0‿1‿1
r‿g‿b‿a ← 4⥊255
rec‿cir‿cirOutline ← (↕3)∾¨<x‿y‿sx‿sy‿r‿g‿b‿a

⟨_Move, _Scale, _Color⟩ ← {𝕊d:
{R _𝕣:{(𝕨R⊢)⌾(d⊸⊏)𝕩}⚇1}
}¨⟨1‿2, 3‿4, 5+↕4⟩

Draw ⇐ {
0≡⊑𝕩?  (3‿4⊏𝕩) ((5+↕4)⊏ 𝕩)drawCopy._Rectangle      1‿2⊏𝕩;
1≡⊑𝕩?  (3‿4⊏𝕩) ((5+↕4)⊏ 𝕩)drawCopy._Ellipse        1‿2⊏𝕩;
2≡⊑𝕩?  (3‿4⊏𝕩) ((5+↕4)⊏ 𝕩)drawCopy._EllipseOutline 1‿2⊏𝕩
}{𝔽⚇1 drawCopy._withCanvas_𝕎 𝕩}