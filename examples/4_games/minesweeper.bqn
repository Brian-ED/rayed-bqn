⟨color,window,draw,mouse,key,rayffi⇐raylib⟩←r←•Import "../../rayed.bqn"

textSize ← 30

rectangleSize ← 60
boardSize ← 4‿4

bombCount ← 2
font←@
background ← color.darkGray

bombs ← boardSize⥊boardSize×´⊸↑/⁼bombCount •rand.Deal ×´boardSize
bombLocations ← (»+«+⊢)˘(«+»+⊢)bombs

introText ← "
                       Welcome to minesweeper!


In this game, You are challanged to clear the entire area of mines!

Flag all mines to win, aswell as uncover all the space. Goodluck!
"

square ← {
  ⟨Rectangle,Text⟩ ← draw
  none‿bomb‿gone⇐↕3

  numberColors ← ⟨
    color.blue
    color.green
    color.red
    color.darkblue
    color.darkred
    color.teal
    color.magenta
    color.gray
  ⟩

  points ← rectangleSize × 1+-⟜(boardSize÷2)¨↕boardSize
  Draw ⇐ {bombs𝕊center:
    positions ← (center-rectangleSize÷2)⊸+¨ points
    {
      𝕊0‿bombLoc‿⟨x,y⟩: # normal
        # draw big border square
        color.black⊸Rectangle rectangleSize⊸+⊸≍ -⟜(rectangleSize÷2) x‿y

        # draw smaller inner square
        color.gray⊸Rectangle 0.5⊸×⌾(-⟜x‿y)˘ -⟜(rectangleSize÷2)˘rectangleSize⊸+⊸≍ x‿y
    ;
      𝕊1‿bombLoc‿⟨x,y⟩: # bomb
        # draw big border square
        color.black⊸Rectangle rectangleSize⊸+⊸≍ -⟜(rectangleSize÷2) x‿y

        # draw smaller inner square
        color.gray⊸Rectangle 0.5⊸×⌾(-⟜x‿y)˘ -⟜(rectangleSize÷2)˘rectangleSize⊸+⊸≍ x‿y
    ;
      𝕊2‿bombLoc‿⟨x,y⟩: # gone
        # draw big border square
        color.black⊸Rectangle rectangleSize⊸+⊸≍ -⟜(rectangleSize÷2) x‿y

        # draw smaller inner square
        color.white⊸Rectangle 0.5⊸×⌾(-⟜x‿y)˘ -⟜(rectangleSize÷2)˘rectangleSize⊸+⊸≍ x‿y

        (bombLoc⊑numberColors)‿font‿textSize Text (x‿y-7‿15)⋈•Repr bombLoc

    }⎉1 ⍉ (𝕨≍bombLocations)∾positions
  }
}

window.SetSize 0.5

PerFrame ← {𝕊lastBombs:
  center ← 2÷˜window.GetSize@
  color.white‿font‿textSize draw.Text 20‿20⋈•Repr∘window.GetFPS⊸∾" FPS"

  pos ← -⟜1 {𝕤
    (mouse.GetPos@)⍋˜˘center+rectangleSize×(>↕¨∘+⟜1-÷⟜2)boardSize
  }⍟(mouse.button.IsDown mouse.button.left) 0‿0

  newBombs ← (∧´boardSize⊸>∧0⊸≤)∘pos◶⟨⊢,square.gone⌾(pos⊸⊑)⟩lastBombs

  newBombs square.Draw center

  •term.Flush@
  {
    ∨´⥊ (lastBombs=1) ∧ 2=newBombs?
      0
  ;
    (bombCount-˜×´boardSize)≡+´2=⥊newBombs?
      1
  ;
    newBombs
  }
}


Start ← {𝕤
  isClosed ← 0
  font ↩ r.font.LoadBQN@

  _Scene_ ← { PerFrame _𝕣_ Until 𝕩:
    {
      isClosed ↩ window.ShouldClose@
      PerFrame draw._withCanvas⟜background 𝕩
    } •_while_ {¬isClosed∨Until𝕩}𝕩
  }

  {𝕤 # Intro scene
    center ← 2÷˜window.GetSize@
    color.white‿font‿textSize draw.Text 20‿20⋈•Repr∘window.GetFPS⊸∾" FPS"
    color.white‿font‿(textSize×0.7) draw.Text introText⋈˜center-400‿10
  } _Scene_ {𝕊:0≠key.PressedKey@} 0

  # Play
  winCondition ← PerFrame _Scene_ {⟨⟩≡≢𝕩}bombs

  ⊢◶⟨
    {𝕤 # lost
      center ← 2÷˜window.GetSize@
      color.white‿font‿textSize draw.Text 20‿20⋈•Repr∘window.GetFPS⊸∾" FPS"
      color.white‿font‿(textSize×0.7) draw.Text "You lost :("⋈˜center-400‿10
    } _Scene_ {𝕊:×key.PressedKey@}
    {𝕤 # win
      center ← 2÷˜window.GetSize@
      color.white‿font‿textSize draw.Text 20‿20⋈•Repr∘window.GetFPS⊸∾" FPS"
      color.white‿font‿(textSize×0.7) draw.Text "YOU WON! :D"⋈˜center-400‿10
    } _Scene_ {𝕊:×key.PressedKey@}
  ⟩ winCondition

  r.font.Unload font
}

Start window._openAs "test"
