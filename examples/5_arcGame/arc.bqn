⟨c⇐color,window,draw,k⇐key⟩←r←•Import "../../rayed.bqn"

lf ← @+10

# level example
##############
#            #
#   ######o  #
#            #
#            #
#  >   /     #
#  #   @     #
##############

# the characters that are used in the level representation
⟨
  empty, player, goalOff, wall, lMirror
  rMirror, lLaser, rLaser, uLaser, dLaser
⟩⇐↕≠chars←" @o#\/<>^v"

goalOn‿ubeam‿hbeam‿vbeam‿xbeam←5↕⊸+≠chars
lasers ← ulaser‿llaser‿dlaser‿rlaser
dirs ← ⟨¯1‿0⋄0‿¯1⋄1‿0⋄0‿1⟩
dirLetters ← "wasd"
mirrors ← lmirror‿rmirror
scale ← 10

levels ← chars⊸⊐∘>¨((+`×¬)⊸-0=≠¨)⊸⊔•FLines "levels.txt"

colorsRGBA‿colorNames ← {𝕩⊸•ns.Get¨⊸⋈•ns.Keys𝕩}r.color

txtFile ← "sprites.txt"
pencils ← {𝕩⊸draw.Rectangle}¨colorsRGBA


colorMappedTextures ← {
  name‿colorString ← 2↑𝕩
  colorsPicked ← (+`×¬)⊸-∘=⟜' '⊸⊔ (32×1="A["⊸⍋)⊸+colorString
  cMapped ← 1⌽11↑colorNames⊐⟨"transparent"⟩∾colorsPicked
  {𝕊:!∾⟨
    "Invalid color found in "⋄txtFile
    " (color ≡ "⋄colorsPicked⊑˜⊑⍒¯1↓cmapped⋄")"
  ⟩}⍟⊢colorNames≠⊸=⌈´¯1↓cMapped
  cMapped⊏˜('0'+↕10)⊐>2↓𝕩
}¨((+`×¬)⊸-0=≠¨)⊸⊔ •FLines txtFile

DrawBoard ← {𝕊colors:
  𝕩 draw.Rectangle¨¨ 100++`¨¨scale×≍⟜1‿1¨¨⌽¨¨ (<↕≢⊑𝕩) + <¨5×↕≢𝕩
}∘⊏⟜(⊏⟜colorsRGBA¨colorMappedTextures∾˜<5‿5⥊143)⊸⊢

cornerLasersFlipped ← ⌽˘ cornerLasers ← ⍉⌾⌽⊸≍2=⌈⌜˜↕5
straightLasers ← ≍⟜⍉5‿5⥊2=↕5

DrawLaser ← {level𝕊startPos:
  direction ← dirs⊑˜⊑lasers⊐startPos⊑level
  DrawTile ← {c.red⊸draw.Rectangle¨ 100+scale×(+`1‿1≍˜·⌽(5×𝕩)⊸+)¨/○⥊⟜(↕≢)𝕨}

  ReflectType ← ⊑empty‿rMirror‿lMirror⊐⊑⟜level
  reflectFuncs ← ⟨
        ⋈ ⊣ (straightLasers     ⊏˜  0=⊑)⊸DrawTile
    -∘⌽⊸⋈ ⊣ (cornerLasers       ⊏˜⌽⊸≡⟜¬)⊸DrawTile
      ⌽⊸⋈ ⊣ (cornerLasersFlipped⊏˜   ≤´)⊸DrawTile
  ⟩
  Recurse ← ReflectType∘⊢◶ReflectFuncs´{𝔽+`} •_while_ (2≥⟜ReflectType+´)
  +´ Recurse direction‿startPos
}

OnStart ← {𝕤

  # Definitions

  font←r.font.LoadBQN 100
  DT ← ⟨c.white⋄font⋄30⟩ draw.Text ⋈⟜((»⊸∨≠⟜' ')⊸/)

  _Scene_ ← {𝔽 draw._withCanvas_ c.black •_While_ (window.ShouldClose<𝔾)}

  StartScreen ← DT´¨∘⟨
    30‿30⋈"Power the machines by moving the mirrors"
    30‿60⋈"Controls: wasd to move, r to reset level"
  ⟩⊸⊢ _Scene_ (@≡k.PressedChar)

  MiddleScreen ← DT´¨∘⟨
    300‿300⋈"Good job!"
    300‿330⋈"Press any key to continue to the next level!"
  ⟩⊸⊢ _Scene_ (@≡k.PressedChar)

  EndScreen ← DT´¨∘⟨
    300‿300⋈"Congratulations!!"
    300‿330⋈"You're done with the game, thanks for playing! :)"
    300‿360⋈"Press any key to restart"
  ⟩⊸⊢ _Scene_ (@≡k.PressedChar)

  StartScreen@

  {levelNumber𝕊level:
    0‿0 DT "Level "∾•Repr 1+levelNumber
    key ← k.PressedChar@
    hit ← DrawBoard level
    out←{
      ⊑key∊dirLetters? # movement
        move ← dirs⊑˜⊑dirLetters⊐key
        relivants ← (move×⌜↕3) + ⊑ /○⥊⟜(↕≢) 1=level
        {player‿spaceInfront‿spaceAfterFront:
          {spaceInfront=empty?
            spaceInfront‿player‿spaceAfterFront
          ; ∧´⟨∨´spaceInfront=mirrors⋄spaceAfterFront=empty⟩?
            empty‿player‿spaceInfront
          ;
            𝕩
          }𝕩
        }⌾((<˘⍉relivants|˜≢level)⊸⊑) level
    ; key≡'r'?
        levelNumber⊑levels
    ;
      level
    }
    won ← ∧´goalOff=⊑⟜level¨out⊸DrawLaser¨/○⥊⟜(↕≢)level∊lasers

    out⍟¬won
  } _Scene_ (2==∘⊢) {MiddleScreen∘𝔽}¨˜⟜(↕≠)levels

  EndScreen@

  r.font.Unload font
}

OnStart window._openAs "Arc"