# My highscore is 124... beat that!

⟨c⇐color,window,draw,k⇐key⟩←r←•Import "../../rayed.bqn"
textSize ← 100
size ← 15

nonDarkMode‿darkMode ← {
  ⟨text, fruit, snake, lines, background⟩ ⇐ 𝕩
}¨{
  yellow ← 255‿200‿0‿255
  ⟨c.black‿c.red‿c.blue ‿c.white‿yellow
   ⌈1.3÷˜c.white‿c.red‿c.green‿c.white‿c.black⟩ # divided to lower intencity
}

Game ← {𝕊:
  # Constants
  winSize       ← window.GetSize@
  textPixelSize ← r.raylib.MeasureText¨textSize⋈˜¨"Paused"‿"GAME OVER"
  tileSize      ← ⌊winSize⌊´⊸÷size+2
  lines         ← ≍´˘⌽¨⊸∾(⊢∾⌜2↑1⌽⁼⊢)tileSize×1+↕1+size # Line drawing positions
  font          ← r.font.LoadBQN 100

  s←⟨⟩

  i ← {
    f ← {
      i←¯1
      {s∾↩<𝕩 ⋄ i+↩1}
    }
    gameState ⇐ F 1 # 0 is gameOver, 1 is playing, 2 is paused
    frame ⇐ F 0
    snake ⇐ F [0‿0] # List of x‿y positions of the snake
    fruit ⇐ F 2 •rand.Range size

    # 0‿1 up, 1‿0 right, 0‿¯1 down, ¯1‿0 left
    # first in list is the current facing, pressing right 1⌽ pressing left 1⌽⁼
    facing ⇐ F [1‿0, 0‿¯1, ¯1‿0, 0‿1]

    speed ⇐ F 10
    keyBuffer ⇐ F ↕0 # buffer for key presses in a game-frame
    keyBufferCatchUp ⇐ F ↕0 # buffer for key presses that leak to next game-frame
    palete ⇐ F nonDarkMode
  }

  PerGameFrame ← {𝕊gameState‿snake‿fruit‿facing‿keyBuffer‿keyBufferCatchUp:
    newBuffer ← keyBufferCatchUp∾⌽keyBuffer
    SpawnFruit    ← {•rand.Range∘≠⊸⊑(<˘𝕨)(¬∘∊˜/⊢)⥊↕2⥊size}
    nowFacing     ← facing⌽˜-´k.left‿k.right=⊑¯1↑newBuffer
    extendedSnake ← nowfacing(⊢∾˜size|+○⊏)snake
    newFruit      ← extendedSnake SpawnFruit⍟(⊏⊸≡) fruit
    cutSnake      ← ¯1⊸↓⍟(newFruit≡fruit)extendedSnake
    ⟨
      gameState×⍷⊸≡cutSnake # gameState
      cutSnake              # snake
      newFruit              # fruit
      nowFacing             # facing
      ↕0                    # reset game-frame keybuffer
      ¯1↓newBuffer          # consume inputted key
    ⟩
  }⌾(i.gameState‿i.snake‿i.fruit‿i.facing‿i.keyBuffer‿i.keyBufferCatchUp⊸⊏)

  PerFrame ← {𝕊:
    pal‿speed‿frame‿fruit ← i.palete‿i.speed‿i.frame‿i.fruit⊏𝕩
    pauseP ← k.right_shift = key ← k.PressedKey@
    {𝕊:
      pal.text‿font‿40 draw.Text 10‿10⋈•Repr ¯1+≠i.snake⊑𝕩
      i.gameState⊸⊑◶⟨ # each function is one scene
        {𝕊: # Game over screen
          pal.text‿font‿textSize draw.Text "GAME OVER"⋈˜2⥊2÷˜winSize-1⊑textPixelSize
          pal⌾(i.palete⊸⊑) s⍟pauseP 𝕩 # reset when pause is pressed
        }
        PerGameFrame⍟(1=speed|frame) {𝕊: # Snake moving
          c.white⊸draw.Line˘lines
          pal.fruit draw.Rectangle +`(1+tileSize×1+fruit)≍2⥊tileSize-2
          pal.snake⊸draw.Rectangle˘(tileSize-2)(+≍⊢)˘1+tileSize×1+i.snake⊑𝕩
          {𝕊f‿s‿b:⟨
            f+1
            2⌈s+-´key=k.down‿k.up
            ∾⟜key⍟(⊑key∊k.left‿k.right) b
          ⟩}⌾(i.frame‿i.speed‿i.keyBuffer⊸⊏)𝕩
        }
        {𝕊: # Pause screen
          pauseText←"Paused, d for dark"
          pal.text‿font‿textSize draw.Text (2÷˜winSize-textPixelSize⊑⊸∾textSize)‿pauseText
          {𝕩≡nonDarkMode?darkMode;nonDarkMode}⌾(i.palete⊑⊢)⍟(key=k.d)𝕩
        }
      ⟩ {1:2;2:1;𝕩}⍟pauseP⌾(i.gameState⊸⊑) 𝕩
    }draw._withCanvas⟜pal.background 𝕩
  }

  PerFrame•_While_(¬window.ShouldClose)s
}
Game window._openAs "Snake"
