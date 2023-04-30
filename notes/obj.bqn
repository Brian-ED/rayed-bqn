## trying to make better syntax for the drawing functions
# ⟨ cirOutline, cir, rec
#   _Move, _Scale, _Color
# ⟩⇐

⟨⟨_Rectangle, _Ellipse, _EllipseOutline⟩⇐draw⟩←rl←•Import "../raylib.bqn"

# ⟨_Move, _Scale, _Color⟩ ← {𝕊d:
# {R _𝕣:{(𝕨R⊢)⌾(d⊸⊏)𝕩}⚇1}
# }¨1↓props

# _Draw ⇐ {type colors _𝕣 posSize:
#   f←type⊑⟨_Rectangle, _Ellipse, _EllipseOutline⟩
#   size⊏𝕩 (colorRGBA⊏𝕩)_F pos⊏𝕩
# }{𝔽⚇1 𝕩}

_EllipseOutline

x ← ⍉⁼[0‿0,100‿100] ≍ [10‿100,200‿200]

•SHow +˝•Show 2‿1÷˜2‿2⥊↕100
•SHow +˝˘•Show ÷⟜2‿1˘2‿2‿2⥊↕100

Draw ← {𝕨𝕊𝕩:(•SHow -˝⎉1𝕩) 𝕨 _EllipseOutline˘⍉⌈+˝⎉1𝕩÷⎉1 2‿1}
PerFrame ← {
  rl.color.red rl.draw._Line 0‿122⊸+¨⟨100‿200,0‿0⟩
  rl.color.red rl.draw._Line 150+0‿122⊸+¨⟨100‿200,0‿0⟩
  rl.color.white Draw (𝕩÷2)‿𝕩+x
  100|1+𝕩
} rl.draw._withCanvas_ rl.color.black
PerFrame•_While_(¬rl.window.ShouldClose)∘0 rl.window._openAs "Hello!!!"
•Show ⍷⊸≡¨⊸/⥊↕3‿3‿3