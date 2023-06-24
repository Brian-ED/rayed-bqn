⟨w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"
[colorsRGBA, colorNames]←⍉>{𝕩⊸•ns.Get⊸⋈¨•ns.Keys𝕩}r.color
txtFile←"sprites.txt"
pencils ← {𝕩⊸d.Rectangle}¨colorsRGBA

colorMappedTextures ← {
  name‿colors←2↑𝕩
  cMapped ← 11↑colorNames⊐grouped←(+`×¬)⊸-∘=⟜' '⊸⊔(32×1="A["⊸⍋)⊸+colors
  ("Invalid color found in "∾txtFile∾1⌽") (colors ≡ "∾•Fmt grouped)!colorNames≠⊸≠⌈´cMapped
  cMapped⊏˜('0'+↕10)⊐>2↓𝕩
}¨((+`×¬)⊸-0=≠¨)⊸⊔ •FLines txtFile

{scale ← 𝕨⊣20
  {𝕨𝕊n:
    {
      𝕨◶pencils⌽⍉100++`scale×1‿1≍˜𝕩+n×5
    }¨⟜(↕≢)𝕨
  }¨⟜(↕≢)𝕩⊏colorMappedTextures∾˜<↕0‿0
}