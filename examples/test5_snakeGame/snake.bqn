# My highscore is 83... beat that!

⟨c⇐color,window,draw,k⇐key⟩←r←•Import "../../raylib.bqn"
textSize ← 100
size ← 15

GetConsts ← {𝕊:{
  winSize       ⇐ window.GetSize@
  textPixelSize ⇐ r.rayFFI.MeasureText¨textSize⋈˜¨"Paused"‿"GAME OVER"
  tileSize      ⇐ ⌊winSize⌊´⊸÷size+2
  lines         ⇐ ⌽¨⊸∾(⊢∾⌜2↑1⌽⁼⊢)tileSize×1+↕1+size # Line drawing positions
}}

nonDarkMode‿darkMode ← {
  ⟨text, fruit, snake, lines, background⟩ ⇐ 𝕩
}¨{
  yellow ← 255‿200‿0‿255
  ⟨c.black‿c.red‿c.blue ‿c.white‿yellow
   ⌈c.white‿c.red‿c.green‿c.white‿c.black÷1.3⟩ # divided to lower intencity
}

OnStart ← {𝕤
  frame ← 0 ⋄ speed ← 10
  # 0 is gameOver, 1 is playing, 2 is paused
  gameState ← 1
  # List of x‿y positions of the snake
  snake ← [0‿0]
  fruit ← 2 •rand.Range size
  # 0‿1 up, 1‿0 right, 0‿¯1 down, ¯1‿0 left
  # first in list is the current facing, pressing right 1⌽ pressing left 1⌽⁼
  facing ← [1‿0, 0‿¯1, ¯1‿0, 0‿1]
  # buffer for key presses
  buffer ← ⟨⟩
  palete ← nonDarkMode
  gameState‿frame‿snake‿fruit‿facing‿speed‿buffer‿palete
}
PerGameFrame ← {𝕊gameState‿snake‿fruit‿facing‿buffer:
  SpawnFruit      ← {•rand.Range∘≠⊸⊑(<˘𝕨)(¬∘∊˜/⊢)⥊↕2⥊size}
  nowFacing       ← facing⌽˜-´k.kLeft‿k.kRight=⊑1↑buffer
  extendedSnake   ← nowfacing(⊢∾˜size|+○⊏)snake
  newFruit        ← extendedSnake SpawnFruit⍟(⊏⊸≡) fruit
  cutSnake        ← ¯1⊸↓⍟(newFruit≡fruit)extendedSnake
  ⟨
    gameState×⍷⊸≡cutSnake # gameState
    cutSnake              # snake
    newFruit              # fruit
    nowFacing             # facing 
    1↓2↑buffer            # reset buffer
  ⟩
}⌾(0‿2‿3‿4‿6⊸⊏)
PerFrame ←{con𝕊⟨gameState,frame,snake,fruit,facing,speed,buffer,pal⟩:
  pauseP ← k.kRIGHT_SHIFT = key ← k.GetPressed@
  10‿10 c.black draw._Text_ 40 ˜•Repr ¯1+≠snake
  ⊑◶⟨ # each function is one scene
    {
      "GAME OVER"pal.text draw._Text_ textSize 2⥊2÷˜con.winSize-1⊑con.textPixelSize
      pal⌾(7⊑⊢)OnStart⍟pauseP 𝕩 # nums mean values to reset
    }
    PerGameFrame⍟(1=speed|frame) {𝕤
      c.white draw._Line˘con.lines
      ( con.tileSize-2) pal.fruit draw._Rectangle○(2⊸⥊)    1+con.tileSize×1+fruit
      {(con.tileSize-2) pal.snake draw._Rectangle○(2⊸⥊) 𝕩}˘1+con.tileSize×1+snake
      ⟨frame+1
       2⌈speed+-´key=k.kDOWN‿k.kUP        # speed
       key∾⍟(⊑∊⟜k.kLeft‿k.kRight) buffer⟩ # Key buffer
    }⌾(1‿5‿6⊸⊏)
    {
      pauseText←"Paused"∾(@+10)∾"d for dark"
      pauseText pal.text draw._Text_ textSize 2÷˜con.winSize-con.textPixelSize⊑⊸∾textSize
      {𝕩≡nonDarkMode?darkMode;nonDarkMode}⌾(7⊑⊢)⍟(key=k.kD)𝕩
    }
  ⟩  {1:2;2:1;𝕩}⍟pauseP⌾⊑ 𝕩
} draw._withCanvas_ {(7⊑𝕩).background}

Game ← GetConsts PerFrame•_While_(¬window.ShouldClose) OnStart
Game window._openAs_ "Snake" 1