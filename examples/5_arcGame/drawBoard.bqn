⟨w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"
ns←{
  Get⇐{⟨"","",𝕨⟩•BQN"(⊑•args)."∾𝕩}
  Keys⇐(+`×¬)⊸-∘=⟜'‿'⊸⊔"⇐}{"∾⁼¯2⌽•Fmt
  Has⇐⊑∊⟜Keys˜
}
[colorsRGBA, colorNames]←⍉>{𝕩⊸ns.Get⊸⋈¨ns.Keys𝕩}r.color
txtFile←"sprites.txt"
pencils ← {𝕩⊸d.Rectangle}¨colorsRGBA

colorMappedTextures ← {
  name‿colors←2↑𝕩
  cMapped ← 11↑colorNames⊐grouped←(+`×¬)⊸-∘=⟜' '⊸⊔(32×1="A["⊸⍋)⊸+colors
  (colorNames≠⊸≠⌈´cMapped)!˜"Invalid color found in "∾txtFile∾1⌽") (colors ≡ "∾•Fmt grouped
  cMapped⊏˜('0'+↕10)⊐>2↓𝕩
}¨((+`×¬)⊸-0=≠¨)⊸⊔ •FLines txtFile

{scale ← 𝕨⊣20
  {𝕨𝕊n:
    {
      𝕨◶pencils⌽⍉100++`scale×1‿1≍˜𝕩+n×5
    }¨⟜(↕≢)𝕨
  }¨⟜(↕≢)𝕩⊏colorMappedTextures∾˜<↕0‿0
}

•Show •math.Sin⁼ •math.Sin 0.5

#_G_←{scale‿n←𝕗‿𝕘
#  𝕨◶pencils⌽⍉100++`scale×1‿1≍˜•Show 𝕩+n×5
#}

t←⟨⟩
_G_←{t∾↩<•Show 𝕩‿𝕨‿𝕗‿𝕘} # 𝕗‿𝕘≡scale‿n 

_H_←{l←𝕗⋄𝕨𝕘_L_𝕩¨↕≢𝕨}


x←[0‿1,2‿3]
(2‿2⥊+`(<x)∾3⥊4)h _H_ g 0
!(•Repr t)≡"⟨⟨0‿0,0,0,0‿0⟩,⟨0‿1,1,0,0‿0⟩,⟨1‿0,2,0,0‿0⟩,⟨1‿1,3,0,0‿0⟩,⟨0‿0,4,0,0‿1⟩,⟨0‿1,5,0,0‿1⟩,⟨1‿0,6,0,0‿1⟩,⟨1‿1,7,0,0‿1⟩,⟨0‿0,8,0,1‿0⟩,⟨0‿1,9,0,1‿0⟩,⟨1‿0,10,0,1‿0⟩,⟨1‿1,11,0,1‿0⟩,⟨0‿0,12,0,1‿1⟩,⟨0‿1,13,0,1‿1⟩,⟨1‿0,14,0,1‿1⟩,⟨1‿1,15,0,1‿1⟩⟩"

#{(𝕨⊣20)h _H_ g𝕩⊏colorMappedTextures∾˜<↕0‿0}