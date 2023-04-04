⟨c⇐color,window,draw,k⇐key⟩←r←•Import "../../raylib.bqn"
size ← 15

GetConsts ← {𝕤
  # Line drawing positions
  offWH ← ⌊0.5+(size+2)÷˜window.GetSize@
  [offw,offh] ← offWH×⌜1+↕size+1
  tr‿bl ← 2↑1⌽⥊∾⌜˝offWH×⌜1∾size+1
  minMaxX‿minMaxY ← tr∾¨bl
  lines ← <˘⍉⊸∾´minMaxX‿offw∾⌜¨offh‿minMaxY
  offWH‿lines
}
OnStart ← {𝕤
  frame ← 0 ⋄ speed ← 10
  # 0 is gameOver, 1 is playing, 2 is paused
  gameState ← 1
  # List of x‿y positions of the snake
  snake ← ⟨0‿0⟩
  fruit ← 2 •rand.Range size
  # 0‿1 up, 1‿0 right, 0‿¯1 down, ¯1‿0 left
  # first in list is the current facing, pressing right 1⌽ pressing left 1⌽⁼
  facing ← ⟨1‿0, 0‿¯1, ¯1‿0, 0‿1⟩ 
  frame‿gameState‿snake‿fruit‿facing‿speed
}
PerFrame ←{offWH‿lines𝕊frame‿gameState‿snake‿fruit‿facing‿speed:
  # Drawing
  gameState◶{𝕊:"Game Over" c.black draw._Text_ 20 100‿100}‿{𝕊:
    c.white draw._Line¨lines
    ( offWH-2)  c.red draw._Rectangle 1+offWH×1+fruit
    {(offWH-2) c.blue draw._Rectangle 1+offWH×𝕩}¨1+snake
  }‿{𝕊: "Paused" c.black draw._Text_ 40 100‿200} @
  (•Repr ¯1+≠snake)c.black draw._Text_ 40 10‿10

  # Computing game
  key ← r.rayFFI.GetKeyPressed⟨⟩
  pauseP ← key=k.kRIGHT_SHIFT
  newGameState ←{1:2;2:1;𝕩}⍟pauseP gameState

  NewFruit ← {𝕊:•rand.Range∘≠⊸⊑ snake(¬∘∊˜/⊢)⥊↕2⥊size}
  ExtendSnake ← {¯1↓⍟(fruit≢1⊑⊢) 𝕩∾˜<size|facing+○⊑𝕩}
  {
    pauseP∧0=gameState? OnStart@;
    2=newGameState? newGameState⌾(1⊑⊢)𝕩;
    ⟨
      frame+1=gameState                         # frame
      newGameState×⍷⊸≡snake                     # gameState
      ExtendSnake⍟(1=speed|frame˙)snake         # snake
      NewFruit⍟((⊑snake)⊸≡∧1=speed|frame˙)fruit # fruit
      facing⌽˜-´key=k.kLEFT‿k.kRIGHT            # facing 
      2⌈speed+-´key=k.kDOWN‿k.kUP               # speed
    ⟩
  }𝕩
} draw._withCanvas_ 255‿200‿0‿255

(GetConsts PerFrame•_While_(¬window.ShouldClose) OnStart) window._openAs_ "Snake" 0.5‿0.9