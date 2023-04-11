⟨c⇐color,window,draw,k⇐key⟩←r←•Import "../../raylib.bqn"
⟨DrawBoard⇐Draw⟩←•Import"spritesLoad.bqn"

g←{
  chars  ← " @o⭍#/\-|+<>^v" # the characters that are used in the level representation
  ⟨empty,player,machine,pmachine,wall
  lmirror,rmirror,hbeam,vbeam,xbeam,llaser
  rlaser,ulaser,dlaser⟩⇐↕≠chars

  mirrors⇐lmirror‿rmirror
  beams←hbeam‿vbeam‿xbeam
  lasers←llaser‿rlaser‿ulaser‿dlaser
  movables←player∾mirrors
  opaque←player‿machine‿wall∾lasers

  Move←{a‿b:⟨1↓a,a⊑⊸∾b⟩}⍟{∨´(⥊movables≍⌜beams)≡¨<⊑¨𝕩}
  # 𝕩: ⟨⟨1,0⟩,⟨2,0⟩,⟨0,0)⟩ (3 tiles) | result: ⟨⟨0⟩,⟨1,0⟩,⟨2,0)⟩
  # Given 3 tiles try to Push the second tile (possibly a movable object)
  # and afterwards try to move the first one (the player) if possible
  Push←Move⌾(2↑⊢)Move⌾(1↓⊢)
  
  Tiles←{(𝕩+𝕨×⊢)¨↕3} # given object (including itself)
  # We (try to) push the tile in front of the player
  Step⇐{Push⌾((𝕨 Tiles ⊑player /○⥊⟜(↕≢)∘⍷ ⊑¨𝕩)⊸⊑)𝕩} # 𝕨 S 𝕩 | 𝕨: direction | 𝕩:level | Step the game

  Bounce←{d‿w S x:{ # Base case:
    ⊑opaque∊˜w⊑x? # When the beam touches an opaque object (not a mirror):

      (machine=w⊑x)◶⟨x,pmachine⌾(w⊸⊑)x⟩@;
      ⊑(lasers∾empty)∊˜w⊑x ?
        ⟨d,w+d⟩S{
          cTile←empty‿hbeam‿vbeam‿xbeam⊐𝕩
          cBeam←(×⊑d)⊑⟨hbeam‿hbeam‿xbeam‿xbeam,vbeam‿xbeam‿vbeam‿xbeam⟩
          ⊑cTile⊏cBeam
        }⌾(w⊸⊑)x;
        d←⌽d×-⊸¬lmirror=w⊑x # calculate the mirror bounce direction
        ⟨d,w+d⟩S x           # and recurse to the next position
      }
  }
  Shoot⇐{𝕩Bounce´⌽∾⟨0‿¯1,0‿1,¯1‿0,1‿0⟩(<∘⊣⋈¨<⊸+)¨/○⥊⟜(↕≢)¨𝕩⊸=¨lasers}
  colors ← c.blue‿c.yellow‿c.cyan‿c.red
  cols   ← colors⊏˜⌈´(≠chars)↑¨(↕3)×/⁼¨⟨pmachine⟩‿mirrors‿beams    

  Ascii2Level←{(↕≠chars)⊑˜⊑chars⊐𝕩}¨
  levels⇐Ascii2Level∘>¨((⊢-˜+`×¬)0=≠¨)⊸⊔•FLines "levels.txt"
}
onStart ← {
  gameState ← 1
  moves ← ⟨0‿0⟩ # list of moves, each move is a direction, we start without moving
  currentLevel←0
  ⟨gameState, moves, currentLevel⟩
}
PerFrame ← {𝕊⟨gameState, moves, currentLevel⟩:
  key←k.GetPressed @
  30‿30 c.white draw._Text_ 40˜"Level "∾•Repr 1+currentLevel
  gameState◶⟨
    {𝕤 # Playing
      # Draw not implemented. map each int as sprite
      10 DrawBoard level←g.Shoot(currentLevel⊑g.levels) g.Step´⌽moves
      won ← ¬⊑g.machine∊⥊level
        # has the user beaten all of the levels?
      ⟨
        1⌾⊑⍟won gameState
        ⟨0‿0⟩⍟('r'=key)(-1<≠)⊸↓⍟('u'=key) moves∾⟨0‿¯1,1‿0,¯1‿0,0‿1⟩/˜∨˝["hjkl","aswd"]=key
        1+⍟won currentLevel
      ⟩
    }
    {𝕤 # info screen
      {currentLevel=0?
        1↓∾(@+10)∾¨⟨
        "Power the machines by moving the mirrors"
        "Controls: (hjkl or wasd) to move, u to undo, r to reset level, q to quit"
        ⟩;
        "Good job! took only "∾(moves)∾" moves. press any key to continue to the next level!"
      }c.white draw._Text_ 30 300‿300
      ⟨0,⟨0‿0⟩,1⊸+⟩{𝕎𝕩}¨⍟(0≢key) 𝕩
    }
  ⟩𝕩
}draw._withCanvas_ c.black
# On end, show "Well played, you win!"

Game ← PerFrame•_While_ {(window.ShouldClose@)¬⊸∧(2⊑𝕩)<≠g.levels}OnStart
Game window._openAs "Arc"