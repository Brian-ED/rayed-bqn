# •Show ↑•path
json ← •Import (∾6⥊<"../")∾"bqn-libs/json.bqn"
#str  ← •Import (∾6⥊<"../")∾"bqn-libs/Strings.bqn"
Box ← >(⌈´≠¨)↑¨⊢
{
 "defines"𝕊𝕩:
  n‿t‿v‿d    ← ↕4 # name‿type‿val‿desc
  LowerNames ← +⟜(32×1="A["⊸⍋)
  Parse ← {∾˘´Box¨""‿""‿" ⇐ "‿" # "∾⍟(⟨⟩≢⊢)⚇1 •Show LowerNames‿(⟨⟩˙)‿•Repr‿⊢{𝕎𝕩}¨¨ <˘⍉𝕩}
  exclTypes  ← "GUARD"‿"MACRO"‿"UNKNOWN"‿"FLOAT_MATH"‿"COLOR"
  Filter     ← {("PI"≡n⊑𝕩) ∨ (∨´exclTypes≡¨<t⊑𝕩) ∨ ⟨⟩≡v⊑𝕩 ?0;1}
  •Show Parse Filter˘⊸/ 1⊏˘˘ >⍉¨𝕩

;"structs"𝕊𝕩: # in progress
  •Show ≢⊑𝕩
}´0⊏⍉json.Parse •FChars "raylib.html"
#  "raylib.html"


