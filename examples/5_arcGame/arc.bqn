⟨c⇐color,window,draw,k⇐key⟩←r←•Import "../../raylib.bqn"
drawBoard←•Import"drawBoard.bqn"
⟨_Template⟩←•Import "../../src/imports/bqn-libs/strings.bqn"
Template↩"@"_Template



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


⟨empty ⋄player⋄goalOff⋄wall  ⋄lMirror
rMirror⋄lLaser⋄rLaser⋄uLaser ⋄dLaser
⟩⇐↕≠chars←" @o#\/<>^v"                      # the characters that are used in the level representation

goalOn‿beamU←2↕⊸+≠chars
•Exit@

levels←chars⊸⊐∘>¨((⊢-˜+`×¬)0=≠¨)⊸⊔•FLines "levels.txt"

Scene ← {Scene‿Close𝕊start:
  C←Scene draw._withCanvas_ c.black
  C•_While_(window.ShouldClose<Close)𝕩
}

OnStart ← {𝕤
  font←r.font.LoadBQN 100
  DT ← ⟨c.white⋄font⋄30⟩ draw.Text⟜⌽»⊸∨∘≠⟜' '⊸/⊸⋈˜
  
  StartScreen ← ⟨30‿30 DT"
    Power the machines by moving the mirrors
    Controls: wasd to move, u to undo, r to reset level, q to quit
  "˙,@≡k.PressedChar⟩⊸Scene
  
  MiddleScreen ← {𝕩⊣300‿300 DT"
    Good job! Took only "∾•Repr∘𝕩⊸∾" move"∾("s"/˜1≠𝕩)∾".
    Press any key to continue to the next level!
  "}‿(@≡k.PressedChar)⊸Scene
  
  EndScreen ← ⟨300‿300 DT"
    Congratulations!!
    You're done with the game, thanks for playing! :)
    Press any key to restart
  "˙,@≡k.PressedChar⟩⊸Scene

  {𝕊level‿moves:
    key←k.PressedChar@
    DrawBoard level⊑levels
    𝕩⊣0‿0 DT "Level "∾•Repr 1+level
  }‿1 Scene 0‿⟨⟩

  r.font.Unload font
}

# On end, show "Well played, you win!"
OnStart window._openAs "Arc"
