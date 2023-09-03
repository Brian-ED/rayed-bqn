# IN PROGRESS press a and d to move forward and backward through animation
⟨color
 draw
 key
 window
 rf⇐rayffi
 rm⇐raymath
 mouse
⟩←rl←•Import "../../raylib.bqn"
⟨DrawText,Fade,DrawRectangle⟩ ← rf



# Points P will be given in ravel order, same with Q. 
# The dimension will be picked based on length of the lists 𝕨 and 𝕩
#  
# 1d:
#   PQ###PQ
# 2d:
#   P ###P
#    Q### Q
#   ##   ##
#   ##   ##
#   ##   ##
#   P ###P
#    Q### Q
OutlinePoints ← {outlineWidth𝕊squareSize:
  "Only accepts lists"!𝕨∧○=𝕩
  "𝕩 and 𝕨 need to be same length (𝕨≡○≠𝕩)"!𝕨≡○≠𝕩
  unitCorners ← >⥊↕2⥊˜≠𝕩
  corners ← unitCorners ×⎉1 𝕩-𝕨
  ⌽𝕨⊸+˘⊸≍corners
}

NextFrame ← key.IsDown∘key.d-key.IsDown∘key.a

LogoAnimation ← {𝕤
  font ← rl.font.LoadRaylib 100
  isClosed ← 0
  logoSize ← 256
  outlineWidth ← 16
  points ← •Show outlineWidth OutlinePoints○(2⊸⥊) logoSize
  
  { # Small box blinking
    isClosed ↩ window.ShouldClose@
    logoposition ← ⌊logoSize-○(÷⟜2)˜window.GetSize@
    color.black draw.Rectangle⍟(⌊2|𝕩÷12) logoposition+⎉1⊏˘points
    𝕩+⍟NextFrame˜1
  } draw._withCanvas_ color.red •_while_{¬isClosed∨84≤𝕩}0  

  {𝕊excrution: # Top and left bars growing
    isClosed ↩ window.ShouldClose@
    logoposition ← logoSize-○(÷⟜2)˜window.GetSize@
    color.black draw.Rectangle logoposition+⎉1⊏˘points
    color.black⊸draw.Rectangle˘ logoposition +⎉1 {(⊏𝕩) ≍⎉1˜ ⌊64÷˜ excrution×1‿2⊏𝕨}˝points
    1+⍟NextFrame𝕩
  } draw._withCanvas_ color.red •_while_{¬isClosed∨60≤𝕩}4

  {𝕊excrution: # Bottom and right bars growing
    isClosed ↩ window.ShouldClose@
    logoposition ← ⌊logoSize-○(÷⟜2)˜window.GetSize@

    color.black draw.Rectangle+`logoposition ≍ logoSize‿outlineWidth
    color.black draw.Rectangle+`logoposition ≍ outlineWidth‿logoSize
    (color.black draw.Rectangle logoposition⊸+˘)¨⌽˘⊸⋈+`(0∾˜logoSize-outlineWidth) ≍ outlineWidth×1‿𝕩
    𝕩+⍟NextFrame˜÷4
  } draw._withCanvas_ color.red •_while_{¬isClosed∨15.75≤𝕩}1

  {𝕊frame‿alpha:
    isClosed ↩ window.ShouldClose@
    windowSize ← window.GetSize@
    logoposition ← ⌊logoSize-○(÷⟜2)˜windowSize
    black ← Fade color.black‿alpha

    # Letters appearing (one by one)    
    # Every 12 frames, one more letter!
    lettersCount ← ⌊frame÷12

    # When all letters have appeared, just fade out everything
    color.black⊸draw.Rectangle¨logoposition⊸+˘¨∾⟨
      ⌽˘⊸⋈+`(logoSize-outlineWidth)‿0≍∾˜outlineWidth
      ⋈0‿outlineWidth
      ⋈(logoSize-outlineWidth)‿logoSize
    ⟩
    black⊸draw.Rectangle¨logoposition⊸+˘¨∾⌽˘⊸⋈¨⟨
      +`outlineWidth‿0≍(logoSize-+˜outlineWidth)‿outlineWidth
      +`outlineWidth‿(logoSize-outlineWidth) ≍(logoSize-+˜outlineWidth)‿outlineWidth
    ⟩
    color.raywhite‿alpha Fade⊸draw.Rectangle logoposition⊸+˘outlineWidth≍logoSize-outlineWidth
    black‿font‿50 draw.Text ⟨84‿176+logoposition, lettersCount↑"raylib"⟩
    ⟨1+⍟NextFrame frame, -⟜0.02⍟(lettersCount≥10)⍟NextFrame alpha⟩
  } draw._withCanvas_ color.red •_while_ {¬isClosed∨0≥1⊑𝕩}0‿1
}
LogoAnimation window._openAs "helloo"
