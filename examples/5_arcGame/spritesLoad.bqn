⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"
[colorNames, colorsRGBA]←⍉[
    "black"    ‿c.black
    "white"    ‿c.white
    "gray"     ‿c.gray
    "darkgray" ‿c.darkGray
    "red"      ‿c.red
    "orange"   ‿c.orange
    "yellow"   ‿c.yellow
    "lightblue"‿c.lightblue
    "darkblue" ‿c.darkblue⊸
]
pencils ← {𝕩 d._Rectangle}¨colorsRGBA

Split ← (+`×¬)⊸-∘=⊔⊢
SplitOnEmpty ← ((⊢-˜+`×¬)0=≠¨)⊔⊢
Lower ← +⟜(32×1="A["⊸⍋)
colorMappedTextures ← {
  name‿colors←2↑𝕩
  cMapped ← 11↑1+colorNames⊐' 'Split Lower colors
  cMapped⊏˜('0'+↕10)⊐>2↓𝕩
}¨⟨⟩⊸≢¨⊸/SplitOnEmpty •FLines "sprites.txt"

Draw ⇐ {scale ← 𝕨⊣30
  {𝕨𝕊n:{
    scale‿scale (𝕨⊑pencils){𝔽} scale×𝕩+n×5
  }¨⟜(↕≢)𝕨}¨⟜(↕≢) 𝕩⊏colorMappedTextures∾˜<0‿0⥊0
}