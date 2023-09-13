⟨
  LoadDataNormalized
  FormatToLengths
  ReFormat
⟩⇐
# Encode image data in arrays by using encode to encode into binary data by an input format,
# along with also acounting for luminocity.

# TODOs
# remember to normalize not only by gray but by all colors, depending on their bytes 
# after aproximating, turn leftover data into other colors to keep brightness the same 
# calculate leftovers (that come from shortening bit-lengths and therefore loosing information and brightness) and add them in other colors

# pixel formats for images suported:
# (kinda means it's supported but not space efficient)
# yes    : uncompressed_grayscale    ⇐ 1   # 8 bit per pixel (no alpha)   
# yes    : uncompressed_gray_alpha   ⇐ 2   # 8*2 bpp (2 channels)         
# kinda  : uncompressed_r5g6b5       ⇐ 3   # 16 bpp                       
# yes    : uncompressed_r8g8b8       ⇐ 4   # 24 bpp                       
# kinda  : uncompressed_r5g5b5a1     ⇐ 5   # 16 bpp (1 bit alpha)         
# yes    : uncompressed_r4g4b4a4     ⇐ 6   # 16 bpp (4 bit alpha)         
# yes    : uncompressed_r8g8b8a8     ⇐ 7   # 32 bpp                       
# yes    : uncompressed_r32          ⇐ 8   # 32 bpp (1 channel - float)   
# yes    : uncompressed_r32g32b32    ⇐ 9   # 32*3 bpp (3 channels - float)
# yes    : uncompressed_r32g32b32a32 ⇐ 10  # 32*4 bpp (4 channels - float)
# no     : compressed_dxt1_rgb       ⇐ 11  # 4 bpp (no alpha)             
# no     : compressed_dxt1_rgba      ⇐ 12  # 4 bpp (1 bit alpha)          
# no     : compressed_dxt3_rgba      ⇐ 13  # 8 bpp                        
# no     : compressed_dxt5_rgba      ⇐ 14  # 8 bpp                        
# no     : compressed_etc1_rgb       ⇐ 15  # 4 bpp                        
# no     : compressed_etc2_rgb       ⇐ 16  # 4 bpp                        
# no     : compressed_etc2_eac_rgba  ⇐ 17  # 8 bpp                        
# no     : compressed_pvrt_rgb       ⇐ 18  # 4 bpp                        
# no     : compressed_pvrt_rgba      ⇐ 19  # 4 bpp                        
# no     : compressed_astc_4x4_rgba  ⇐ 20  # 8 bpp                        
# no     : compressed_astc_8x8_rgba  ⇐ 21  # 2 bpp                        

MP←+˝∘×⎉1‿∞

formatKeys ← "r"‿"g"‿"b"‿"a"‿"grayscale"
luminocityMat ← [
# r     g     b      a
  1    ‿0    ‿0     ‿0  # r
  0    ‿1    ‿0     ‿0  # g
  0    ‿0    ‿1     ‿0  # b
  0    ‿0    ‿0     ‿1  # a
  0.299‿0.587‿0.114 ‿0  # grayscale
]

# returns format.r‿format.g‿format.b‿format.a‿format.grayscale
# if value isn't in the namespace, replace it with 0
FormatToLengths ← {𝕊format:
  {𝕊:0!˜"Keys in format namespace need to be one of the following: "∾2↓∾", "⊸∾¨formatKeys
  }⍟¬∧´formatKeys∊˜•ns.Keys format
  keys‿vals ← (⊢⋈•ns.Get¨)⟜•ns.Keys 𝕩 # namespace to arrays
# ┌─unsorted──────┐   ┌─adding defaults───────────────────────┐
  [uFormats, ubits] ← ⍉>(∊keys∾formatKeys)/(keys⋈¨vals)∾formatKeys⋈¨0
  ¯1+2⋆ubits ⊏˜⍋ formatKeys ⊐ uFormats  # sorting by formats
}

LoadDataNormalized ← {format𝕊image:
  bitLengths ← FormatToLengths 𝕨
  size ← 2↑≢image
  m ← 0≠bitLengths
  # pick out color data from image
  colors ← image ÷⎉1 m/bitLengths
  # multiplying it by luminocityMat, thereby splitting rgba and grayscale into rgba components
  colors MP ÷⎉1⟜(0⊸=⊸++˝) m/luminocityMat
}

ReFormat ← {oldFormat‿newFormat𝕊image:
  rgba ← oldFormat LoadDataNormalized image
  bitLengths ← FormatToLengths newFormat
  m ← 0≠bitLengths
  x ← ⍉⁼ rgba MP ⍉ m/luminocityMat
  ⌊0.5+x×m/bitLengths
}

_Base_ ← {⌽𝕗|⌊∘÷⟜𝕗⍟(↕𝕘)} # Base _𝕣_ Length input → list


oldFormat ← {r‿grayscale⇐8‿8}
newFormat ← {r⇐8} # 5‿6‿5⥊¨1
image ← 3‿3‿2⥊[155‿255,0‿0]

•Show oldFormat‿newFormat ReFormat image

# Lets wait on this one
#  ; 𝕊3: # uncompressed_r5g6b5 actually r‿g‿b←5‿6‿5⥊¨1
#      rr‿gg‿bb ← 2‿2‿2 _Base_¨⌊255×r‿g‿b×÷⟜(+´)2⋆5‿6‿5
#      («⍟10 rr) ∨ (»⍟6 gg) ∨ »bb