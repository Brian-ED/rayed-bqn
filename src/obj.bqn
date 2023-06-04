## trying to make better syntax for the drawing functions

# ⟨Sin,Cos⟩←•math
# RM←{[⟨b←Cos𝕩⋄-a←Sin𝕩⟩⋄a‿b]}

# ⟨_Move, _Scale, _Color⟩ ← {𝕊d:
# {R _𝕣:{(𝕨R⊢)⌾(d⊸⊏)𝕩}⚇1}
# }¨1↓props

rl←•Import "../raylib.bqn"
⟨Split,lf⟩←•Import"imports/bqn-libs/strings.bqn"

s1x1‿s1y1←0‿10     ⋄  s1x2‿s1y2←100‿140
s2x1‿s2y1←100‿100  ⋄  s2x2‿s2y2←200‿200
s3x1‿s3y1←300‿300  ⋄  s3x2‿s3y2←400‿400
ss←⍉[
  s1←[s1x1‿s1x2,s1y1‿s1y2]
  s2←[s2x1‿s2x2,s2y1‿s2y2]
  s3←[s3x1‿s3x2,s3y1‿s3y2]
]

⟨white,yellow,red,black⟩←rl.color
EO ← rl.draw.EllipseOutline
PerFrame ← {
  [white,yellow,red]EO𝕩‿0+20+ss
  q←∾˘˘⟜⌽1‿¯1-⊸≍⊸×|0‿100-𝕩      # Morphing
  s←∾˘˘˝q⊸+˘⍷⌽˘⊸∾100×0∾˘¬↕3     # duping
  white EO rl.mouse.GetPos⊸+s   # moving + drawing
  100|1+𝕩
} rl.draw._withCanvas_ rl.color.black
PerFrame•_While_(¬rl.window.ShouldClose)∘0 rl.window._openAs "Hello!!!"
