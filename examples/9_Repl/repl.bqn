⟨co⇐color,window,⟨_withCanvas_⟩⇐draw,k⇐key⟩←r←•Import "../../raylib.bqn"
⟨lf,Split⟩ ← •Import "../../src/imports/bqn-libs/strings.bqn"
sysVals ← "r"‿r<⊸∾•Import"sysVals.bqn"
fontSize←50
lineSpacing ← 40
charSize←27‿50

Game ← {𝕤
  window.SetPos 0‿540
  font←r.font.LoadBQN fontSize
  DrawText ← {pos𝕊str:r.rayFFI.DrawTextCodepoints ⟨font, str-@, ≠str, pos, fontSize, 1, co.blue⟩}
  rmFn←0
  Back ← {𝕤
    rmFn↩1
  }
  bqn ← •ReBQN{
    s←sysvals∾⟨"drawtext"‿DrawText,"back"‿Back⟩
    system ⇐ s∾<"listsys"(⊣⋈<⊸∾)⊑¨s
    repl   ⇐ "loose"
  }
  BQN "
    ⟨m⇐mouse,⟨white⟩⇐color,⟨rectangle⟩⇐draw,texture⟩←r←•r
    back←•back
  "
  KeyFunc←{ky𝕊s‿f‿p: N←0⌈-⟜1 ⋄ A←(≠s)⌊+⟜1 ⋄ {
  (k.backspace≡ky)∧r.rayffi.IsKeyDown k.left_control?""‿f‿0
  ;k.backspace≡ky? ⟨p(N⊸↑∾↓)s⋄f⋄N p⟩
  ;(r.rayffi.IsKeyDown k.left_control)∧k.enter≡ky? ⟨p(↑∾lf∾↓)s⋄f⋄A p⟩
  ;k.enter≡ky?
    (3≡•Type)◶⟨
      {(<∾f⋈≠)•Repr⎊""𝕩}
      {(<∾(f∾𝕩)⋈≠)"Activating function per frame"}
    ⟩BQN⎊•currentError s
  ;k.left≡ky?  s‿f∾N p
  ;k.right≡ky? s‿f∾A p
  ;s‿f‿p
  }}

  # Perframe
  {𝕊s‿f‿p:
    ky‿c ← {1↓𝕏⊸∾•_While_(∧´0‿@≠⊑)𝕏@}¨k.PressedKey‿k.PressedChar # Input
    {ky‿c𝕏s}¨f
    # •Show⍟(⟨⟩⊸≢)k # debugging
    newS←⊑rr←{rmFn↩0⋄¯1⊸↓⌾(1⊑⊢)𝕩}⍟rmFn(+⟜(≠c)⋈↑∾c∾↓)´⌾(2‿0⊸⊏)s‿f‿p KeyFunc´ky
    # Rendering
    {
      DrawText˜´¨(⊢⋈¨50∾¨50×↕∘≠)lf Split𝕩
      co.white r.draw.Line ⟨0‿0,0‿50⟩+⚇1 50‿0+charSize×(∧`⌾⌽∘¬⋈○(+´)⊢)lf=p↑s
    }_withCanvas_ co.black newS 
    
    rr
  }•_While_(¬window.ShouldClose) ""‿⟨⟩‿0

  r.rayffi.UnloadFont font
}
0.5 Game window._openAs "BQN Repl"

# white _Rectangle˜100‿100˙
# Back@
# frame←pos←wheel←0
# {𝕊:frame(100|+)↩1}
# {𝕤
#   q←∾˘˘⟜⌽1‿¯1-⊸≍⊸×|0‿100-frame # Morphing
#   s←∾˘˘˝q⊸+˘⍷⌽˘⊸∾100×0∾˘¬↕3    # duping
#   white EO r.mouse.GetPos⊸+s   # moving + drawing
# }