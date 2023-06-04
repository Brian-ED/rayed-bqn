⟨co⇐color,window,⟨_withCanvas_⟩⇐draw,k⇐key⟩←r←•Import "../../raylib.bqn"
⟨lf,Split⟩ ← •Import "../../src/imports/bqn-libs/strings.bqn"
fontSize←50
lineSpacing ← 40
DrawEllipses ← {frame𝕊poses:
  {(|𝕏0‿100-100|frame) co.white r.draw._EllipseOutline poses}¨⊢‿⌽
}¨
sysvals ← ⟨
  "out"‿•Out
  "show"‿•Show
  "type"‿•Type
  "sh"‿•Sh
  "decompose"‿•Decompose
  "while"‿•While
  "bqn"‿•BQN
  "cmp"‿•Cmp
  "unixtime"‿•UnixTime
  "monotime"‿•Monotime
  "timed"‿•_timed
  "delay"‿•Delay
  "hash"‿•Hash
  "repr"‿•Repr
#  "parsefloat"‿•ParseFloat
  "fmt"‿•FMT
  "glyph"‿•Glyph
  "makerand"‿•MakeRand
  "rebqn"‿•ReBQN
  "fromutf8"‿•FromUTF8
  "toutf8"‿•ToUTF8
  "math"‿•Math
  "rand"‿•Rand
  "term"‿•term
  "bit"‿•bit
  "primitives"‿•primitives
  "internal"‿•internal
  "fchars"‿•Fchars
  "fbytes"‿•FBytes
  "flines"‿•FLines
  "import"‿•Import
  "ffi"‿•FFI
  "name"‿•name
  "path"‿•path
  "wdpath"‿•wdpath
  "file"‿•file
  "state"‿•state
  "args"‿⟨⟩
#  "ns"‿•ns
  "drawellipses"‿DrawEllipses
  "r"‿r
⟩

Game ← {𝕤
    window.SetPos 0‿540

    font←r.font.LoadBQN fontSize
    DrawText ← {pos𝕊str:r.rayFFI.DrawTextCodepoints ⟨font, str-@, ≠str, pos, fontSize, 1, co.blue⟩}
    bqn ← •ReBQN{
        s←sysvals∾<"drawtext"‿DrawText
        system ⇐ s∾<"listsys"(⊣⋈<⊸∾)⊑¨s
        repl   ⇐ "loose"
    }
    KeyFunc←{ky𝕊s‿f‿p: N←0⌈-⟜1 ⋄ A←(≠s)⌊+⟜1 ⋄ {
     k.backspace≡ky? ⟨p(N⊸↑∾↓)s⋄f⋄N p⟩
    ;k.enter≡ky?
        ¬∘r.rayffi.IsKeyDown∘341◶⟨
            {⟨p(↑∾lf∾↓)𝕩⋄f⋄A p⟩}
            (3≡•Type)◶⟨
                {(<∾f⋈≠)•Repr⎊""𝕩}
                {(<∾(f∾𝕩)⋈≠)"Activating function per frame"}
            ⟩BQN⎊•currentError
        ⟩s
    ;k.left≡ky?  s‿f∾N p
    ;k.right≡ky? s‿f∾A p
    ;s‿f‿p
    }}
    # Perframe
    {𝕊s‿f‿p:
        ky‿c ← {1↓𝕏⊸∾•_While_(∧´0‿@≠⊑)𝕏@}¨k.PressedKey‿k.PressedChar # Input
        {ky‿c𝕏s}¨f
        # •Show⍟(⟨⟩⊸≢)k # debugging
        ns←⊑r←(((≠c)+⊣)⋈↑∾c∾↓)´⌾(2‿0⊸⊏)s‿f‿p KeyFunc´ky
        {DrawText˜´¨(⊢⋈¨50∾¨50×↕∘≠)lf Split𝕩}_withCanvas_ co.black ns # Rendering
        r
    }•_While_(¬window.ShouldClose) ""‿⟨⟩‿0

    r.rayffi.UnloadFont font
}
1‿0.5 Game window._openAs "BQN Repl"
