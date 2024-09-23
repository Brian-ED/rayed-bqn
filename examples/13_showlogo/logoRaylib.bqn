⟨color
 draw
 key
 window
⟩←rl←•Import "../../rayed.bqn"

# refrence
# A ← 0‿0
# B ← 0∾logoSize-outlineWidth
# C ← ⌽B
# D ← ∾˜logoSize-outlineWidth
#   A ###B
#     ###
#   ##   ##
#   ##   ##
#   ##   ##
#   C ###D
#     ###

# if enabled: press the left and right keys to move forward and backward through animation, space for slowdown
debug ← 1
clock ← rl.StartClock@

LogoAnimation ← {𝕊background:
  isClosed ← 0

  _Scene_ ← { Scene _𝕣_ Until:
    IsDown‿space‿left‿right←key
    NextFrame ← {𝕊:60×clock.delta×´0.1‿2‿¯1/˜IsDown space‿right‿left}
    {
      clock.Tick@
      isClosed ↩ window.ShouldClose@
      Scene draw._withCanvas_ background 𝕩
      NextFrame⊸+𝕩
    } •_while_ {¬isClosed∨Until𝕩}0
  }

  logoSize ← 256
  outlineWidth ← 16
  Logoposition ← ⌊window.GetSize-○(÷⟜2)logoSize˙
  btmrht ← logoSize-outlineWidth
  RecAtLogo ← ⊣ draw.Rectangle Logoposition +⎉1 ⊢

  { # Small box blinking
    color.black RecAtLogo⍟(⌊2|𝕩÷12) ⌽⊸≍outlineWidth‿0
  } _Scene_ {𝕩≥7×12}

  {𝕊excrution: # Top and left bars growing
    color.black⊸RecAtLogo˘ ⍉˘ outlineWidth ∾⎉0 0‿0 ∾ ⌊𝕩 × btmrht × ⌽⊸≍↕2
  }∘(÷⟜64) _Scene_ {68≤𝕩}

  {𝕊excrution: # Bottom and right bars growing
    color.black⊸RecAtLogo˘ ⍉˘ outlineWidth ∾⎉0 0‿0 ∾ btmrht × ⌽⊸≍↕2
    color.black⊸RecAtLogo¨ ⌽˘⊸⋈ btmrht‿0⊸+˘⌽⊸≍outlineWidth‿0
    color.black⊸RecAtLogo¨ ⌽˘⊸⋈ btmrht‿outlineWidth ≍ logoSize∾outlineWidth+⌊btmrht×𝕩
  }∘(÷⟜64) _Scene_ {64≤𝕩}

  font ← rl.font.LoadRaylib@
  {𝕊frame:
    # Letters appearing (one by one)
    # Every 12 frames, one more letter!
    lettersCount ← ⌊frame÷12

    # When all letters have appeared, just fade out everything
    alpha ← ⌊0⌈255⌊255-30×10-˜frame÷12
    (alpha⌾(¯1⊸⊑) color.black)    RecAtLogo ⌽⊸≍0‿logoSize          # outer black
    (alpha⌾(¯1⊸⊑) color.raywhite) RecAtLogo ⌽⊸≍outlineWidth‿btmrht # inner white of logo

    # text
    (alpha⌾(¯1⊸⊑) color.black)‿font‿50 draw.Text ⟨
      Logoposition⊸+84‿176
      lettersCount↑"raylib"
    ⟩
  } _Scene_ {255≤30×¯10+𝕩÷12}
}
LogoAnimation∘color.red window._openAs "helloo"