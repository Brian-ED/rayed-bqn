# IN PROGRESS
⟨color
 draw
 key
 window
 rf⇐rayffi
 rm⇐raymath
 mouse
⟩←rl←•Import "../../raylib.bqn"

# refrence
# A = 0‿0
# B = 0∾logoSize-outlineWidth
# C = ⌽B
# D = ∾˜logoSize-outlineWidth
#   A ###B 
#     ###  
#   ##   ##
#   ##   ##
#   ##   ##
#   C ###D 
#     ###  

# if enabled: press the left and right keys to move forward and backward through animation, space for slowdown
debug ← 0

nextFrame ← {
  IsDown‿space‿left‿right←key
  ÷⟜10⍟(IsDown∘space) 1+IsDown∘right-2×IsDown∘left
}⊣⍟debug 1

LogoAnimation ← {𝕤
  isClosed ← 0

  _Scene_ ← { Scene _𝕣_ Until:
    {
      isClosed ↩ window.ShouldClose@
      Scene draw._withCanvas_ color.red 𝕩
      NextFrame⊸+𝕩
    } •_while_ {¬isClosed∨Until𝕩}0
  }

  logoSize ← 256
  outlineWidth ← 16
  Logoposition ← ⌊window.GetSize-○(÷⟜2)logoSize˙
  btmrht ← logoSize-outlineWidth
  Rectangle ← ⊣ draw.Rectangle Logoposition +⎉1 ⊢

  { # Small box blinking
    color.black Rectangle⍟(⌊2|𝕩÷12) ⌽⊸≍outlineWidth‿0
  } _Scene_ {𝕩≥7×12}

  {𝕊excrution: # Top and left bars growing
    color.black⊸Rectangle˘ ⍉˘ outlineWidth ∾⎉0 0‿0 ∾ ⌊𝕩 × btmrht × ⌽⊸≍↕2
  }∘(÷⟜64) _Scene_ {68≤𝕩}

  {𝕊excrution: # Bottom and right bars growing
    color.black⊸Rectangle˘ ⍉˘ outlineWidth ∾⎉0 0‿0 ∾ btmrht × ⌽⊸≍↕2
    color.black⊸Rectangle¨ ⌽˘⊸⋈ btmrht‿0⊸+˘⌽⊸≍outlineWidth‿0
    color.black⊸Rectangle¨ ⌽˘⊸⋈ btmrht‿outlineWidth ≍ logoSize∾outlineWidth+⌊btmrht×𝕩
  }∘(÷⟜64) _Scene_ {64≤𝕩}

  font ← rl.font.LoadRaylib 100
  {𝕊frame:
    # Letters appearing (one by one)
    # Every 12 frames, one more letter!
    lettersCount ← ⌊frame÷12
    
    # When all letters have appeared, just fade out everything
    alpha ← ⌊0⌈255⌊255-30×10-˜frame÷12
    (alpha⌾(¯1⊸⊑) color.black)    Rectangle ⌽⊸≍0‿logoSize          # outer black
    (alpha⌾(¯1⊸⊑) color.raywhite) Rectangle ⌽⊸≍outlineWidth‿btmrht # inner white of logo
    
    # text
    (alpha⌾(¯1⊸⊑) color.black)‿font‿50 draw.Text ⟨
      Logoposition⊸+84‿176
      lettersCount↑"raylib"
    ⟩
  } _Scene_ {255≤30×¯10+𝕩÷12}
}
LogoAnimation window._openAs "helloo"