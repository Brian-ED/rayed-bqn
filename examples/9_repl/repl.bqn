
# Example input:
# white Rectangle [100‿100⋄200‿400]˙

⟨co⇐color,window,draw,k⇐key,clipboard⟩←r←•Import "../../rayed.bqn"
⟨lf,Split⟩  ← •Import "../../imports/bqn-libs/strings.bqn"
fontSize    ← 50
lineSpacing ← 40
charSize    ← 27‿50

Game ← {𝕊:
  window.SetPos 0‿540
  font←r.font.LoadBQN fontSize
  DrawText ← co.blue‿font‿fontSize draw.Text ⋈
  rmFn←0
  Back ← {𝕤
    rmFn↩1
  }
  bqn ← •ReBQN{
    s←(⋈⟜(•state•BQN'•'⊸∾)¨•listSys)∾⟨"r"‿r,"drawtext"‿DrawText,"back"‿Back⟩
    system ⇐ s∾<"listsys"(⊣⋈<⊸∾)⊑¨s
    repl   ⇐ "loose"
  }
  BQN "
    ⟨m⇐mouse,⟨white⟩⇐color,⟨rectangle⟩⇐draw,texture⟩←r←•r
    back←•back
  "
  KeyFunc←{ky𝕊s‿f‿p: N←0⌈-⟜1 ⋄ A←(≠s)⌊+⟜1 ⋄ {
  (k.backspace≡ky)∧k.IsDown k.left_control?""‿f‿0
  ;k.backspace≡ky? ⟨p(N⊸↑∾↓)s⋄f⋄N p⟩
  ;(k.IsDown k.leftControl)∧k.enter≡ky? ⟨p(↑∾lf∾↓)s⋄f⋄A p⟩
  ;k.enter≡ky?
    (3≡•Type)◶⟨
      {(<∾f⋈≠)•Repr⎊""𝕩}
      {(<∾(f∾𝕩)⋈≠)"Activating function per frame"}
    ⟩BQN⎊•currentError s
  ;k.left≡ky?  s‿f∾N p
  ;k.right≡ky? s‿f∾A p
  ;(k.v≡ky)∧k.IsDown k.leftControl?
    clipS ← clipboard.Get@
    ⟨p(↑∾clipS∾↓)s,f,p+≠clipS⟩
  ;s‿f‿p
  }}

  # Perframe
  {𝕊s‿f‿p:
    ky‿c ← {1↓𝕏⊸∾•_While_(∧´0‿@≠⊑)𝕏@}¨k.PressedKey‿k.PressedChar # Input
    {ky‿c𝕏s}¨f
    newS←⊑rr←{rmFn↩0⋄¯1⊸↓⌾(1⊑⊢)𝕩}⍟rmFn(+⟜(≠c)⋈↑∾c∾↓)´⌾(2‿0⊸⊏)s‿f‿p KeyFunc´ky
    # Rendering
    {𝕊:
      DrawText˜´¨(⊢⋈¨50∾¨50×↕∘≠)lf Split𝕩
      co.white draw.Line ⍉[0‿0,0‿50]+50‿0+charSize×(∧`⌾⌽∘¬⋈○(+´)⊢)lf=p↑s
    }draw._withCanvas⟜co.black newS

    rr
  }•_While_(¬window.ShouldClose) ""‿⟨⟩‿0

  r.font.Unload font
}
window.SetSize 0.5
Game window._openAs "BQN Repl"
