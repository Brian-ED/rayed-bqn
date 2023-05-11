# •Show ↑•path
json ← •Import (∾5⥊<"../")∾"bqn-libs/json.bqn"
#str  ← •Import (∾6⥊<"../")∾"bqn-libs/Strings.bqn"
Box ← >(⌈´≠¨)↑¨⊢
LowerNames ← +⟜(32×1="A["⊸⍋)
_MetaParse ← {∾˘´Box¨𝕨∾⍟(⟨⟩≢⊢)⚇1𝕗{𝕎𝕩}¨¨ <˘⍉𝕩}
<∘{
 "defines"𝕊𝕩:
  Parse ← {∾˘´Box¨""‿""‿" ⇐ "‿" # "∾⍟(⟨⟩≢⊢)⚇1⟨LowerNames,⟨⟩˙,•Repr,⊢⟩{𝕎𝕩}¨¨ <˘⍉𝕩}
  exclTypes  ← "GUARD"‿"MACRO"‿"UNKNOWN"‿"FLOAT_MATH"‿"COLOR"
  Filter     ← {𝕊n‿t‿v‿d: # name‿type‿val‿desc
    ¬("PI"≡n) ∨ (∨´t⊸≡¨exclTypes) ∨ ⟨⟩≡v
  }
  <Parse Filter˘⊸/ 1⊏˘˘ >⍉¨𝕩
;"structs"𝕊𝕩: # in progress
  Parse ← { # ⍉[name,desc,fields]
    ParseStruct ← {
      •Show >𝕩
    }
    ""‿" ⇐ "‿" # "⟨LowerNames,⊢,"0"˙∘ParseStruct ¯1⊏¨⊢⟩_MetaParse⌽⌾(1↓⊢)˘⌾⍉𝕩
  }
  Parse 1⊏˘˘>⍉¨𝕩
  0
;0
}´˘⍉json.Parse •FChars "raylib.html"