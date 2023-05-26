⟨c⇐color,window,⟨_withCanvas_⟩⇐draw,k⇐key⟩←r←•Import "../../raylib.bqn"
È←{
  w𝕊⁼𝕩:{𝕊x:{!w≡𝕨⋄x}}⚇0𝕩;
  𝕊⁼𝕩:{𝕏˙}⚇0𝕩;
   𝕊𝕩:{𝕏@}⚇0𝕩;
  w𝕊𝕩:𝕨{𝕏𝕨}⚇0𝕩
}
nl←@+10
# !+‿- ≡ È È⁼ +‿-
# !+‿- ≡ 1 È 1 È⁼+‿-
# •Show 1 È˜´3⥊{1⊸+}
# •Show 1 È˜´3⥊<⟨1⊸+,1⊸+⟩
fontSize←50
lineSpacing ← 40
DrawEllipses ← {frame𝕊poses:
  {(|𝕏0‿100-frame) c.white r.draw._EllipseOutline poses}¨⊢‿⌽
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
  "parsefloat"‿•ParseFloat
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
  "ns"‿•ns
  "drawellipses"‿DrawEllipses
  "r"‿r
⟩

{𝕤
    font←r.font.LoadBQN fontSize

    DrawText ← {pos𝕊str:r.rayFFI.DrawTextCodepoints ⟨font, str-@, ≠str, pos, fontSize, 1, c.blue⟩}
    bqn ← •ReBQN{
        system ⇐ sysvals∾<"listsys"(⊣⋈<⊸∾)⊑¨sysvals∾<"drawtext"‿DrawText
        repl   ⇐ "loose"
    }
    KeyFunc←{c𝕊str‿funcs‿⟨y,x⟩:{
        k.backspace≡c? ×+´x‿y?
            ⟨x⊸(↑∾+⟜1↓⊢)⌾y str,funcs,y 0⊸≤◶(-⟜1∾∞˙)‿⋈ x-1⟩
        ;k.enter≡c?
            ¬∘r.rayffi.IsKeyDown∘341◶⟨
                ⟨str∾<"",funcs,cursorPos⟩
                (3≡•Type)◶⟨
                    {⟨nl⊸=⊸((⊢-˜+`×¬)⊸⊔)∘•Repr⎊⟨"Result irrepresentable"⟩𝕩, funcs, ∞‿∞⟩}
                    {⟨⋈"Successfully added function", funcs∾𝕩, cursorPos⟩}
                ⟩BQN⎊•currentError str
            ⟩
        ;k.left≡c?
            ⟨str,funcs,y 0⊸≤◶(-⟜1∾∞˙)‿⋈ x-1⟩
        ;k.right≡c?
        ;str‿funcs‿⟨y,x⟩
    }}
    # Perframe
    {𝕊str‿funcs‿frame‿cursorPos:
        str⊸È¨funcs
        100‿50 DrawText str
        keys‿chars ← {1↓𝕏⊸∾•_While_(×⊑)𝕏@}¨k.PressedKey‿k.PressedChar
        # •Show⍟(⟨⟩⊸≢)keys # debugging
        newStr‿newFuncs ← str‿funcs‿cursorPos KeyFunc´keys
        ⟨newStr∾chars+@,newFuncs,60|1+frame⟩
    }_withCanvas_ c.black •_While_(¬window.ShouldClose) ⟨""⟩‿⟨⟩‿0‿⟨0,0⟩

    r.rayffi.UnloadFont font

} window._openAs "BQN Repl"
