⟨
  # Image generation
  GenGradientLinear ⋄ GenGradientSquare

  # Image conversions
  Normalize
  FormatToLengths
  ReFormat

  
  _AsRayImg ⋄ ToArr
  FromFile ⋄ LoadFromArr ⋄ Unload
⟩⇐

# No function unloads or mutates input image, except Unload

⟨pixelFormat⟩ ← •Import "constants.bqn"
rayffi ← •Import "../rayffi.bqn"
⟨NeedsWindow⟩ ← •Import "global.bqn"

allFormats ← (•ns.Get¨⍋⊸⊏⊢)⟜•ns.Keys pixelFormat
uncompressedFormats ← ⟨
  {grayscale  ⇐  8}
  {grayscale‿a⇐8‿8}
  {r‿g‿b  ⇐5‿6‿5  }
  {r‿g‿b  ⇐8‿8‿8  }
  {r‿g‿b‿a⇐5‿5‿5‿1}
  {r‿g‿b‿a⇐4‿4‿4‿4}
  {r‿g‿b‿a⇐8‿8‿8‿8}
  {r      ⇐32     }
  {r‿g‿b  ⇐3⥊32   }
  {r‿g‿b‿a⇐4⥊32   }
⟩

ToArr ← {𝕨𝕊raylibImg: resultFormat←𝕨⊣@
  dataPtr‿width‿hight‿mipmaps‿format ← ⊑⊑rayffi.ImageFormatRef ⟨𝕩⟩‿pixelFormat.uncompressed_r8g8b8a8
  {𝕤
    0!˜×∘≠◶⟨
      "Format given doesn't exist"
      "Format "∾⊑∾" isn't implemented"˙
    ⟩ (format=pixelFormat⊸•ns.Get¨)⊸/ •ns.Keys pixelFormat
  }⍟⊢format≢pixelFormat.uncompressed_r8g8b8a8
  newImg ← width‿hight‿4(⊣⥊256|×´⊸rayffi.Make)dataPtr     # 256|𝕩 is converting from int to uint 
  {{r‿g‿b‿a⇐4⥊8}‿resultFormat ReFormat𝕩}⍟(𝕨0⊘1𝕩) newImg
}

LoadFromArr ← {𝕨𝕊img:
  default ← {r‿g‿b‿a⇐4⥊8}
  format ← 𝕨⊣default
  NeedsWindow@
  standardImg ← format‿default ReFormat img 
  l rayffi.Read ptr←rayffi.MemAlloc≠l←¯128+256|128+⥊standardImg
  ptr<⊸∾(4⊸∾⁼⌾⌽≢𝕩)∾1‿pixelFormat.uncompressedr8g8b8a8
}

Unload ← {𝕊img:
  imgDataIndex ← 0
  rayffi.MemFree imgDataIndex⊑𝕩
  @
}

FromFile ← {𝕊strPath:
  NeedsWindow@
  !•file.Exists𝕩
  (Unload⊢ToArr) rayFFI.LoadImage𝕩
}

_AsRayImg ← {(Unload⊢𝔽)LoadFromArr}


#----------------------------------------------------------------------------------
# Image generation
#----------------------------------------------------------------------------------

# Generate image: linear gradient
# The direction value specifies the direction of the gradient (in degrees)
# with 0 being vertical (from top to bottom), 90 being horizontal (from left to right).
# The gradient effectively rotates counter-clockwise by the specified amount.
GenGradientLinear ← {𝕊size‿radianDirection‿start‿end: # ⟨i⋄i⟩‿i‿color‿color # Generate image: vertical gradient
  angles ← (•math.Cosf∾•math.Sinf) radianDirection
  >{𝕊i‿j:
    # Calculate the relative position of the pixel along the gradient direction
    pos ← (𝕩⊸×÷○(+´)size⊸×)angles
    factor ← 1⌊0⌈pos

    # Generate the color for this pixel
    (end⊸×+start×¬)factor
  }¨↕size
}

# Generate image: square gradient
GenGradientSquare ← {𝕊size‿density‿inner‿outer: # ⟨i⋄i⟩‿f‿color‿color # Generate image: square gradient
  center ← size÷2
  >{𝕤
    # Normalize the distances by the dimensions of the gradient rectangle
    normalizedDist ← center÷˜|𝕩-center

    # Calculate the total normalized Manhattan distance
    manhattanDist ← ⌈´normalizedDist

    # makes the gradient start from the center when density is 0, and from the edge when density is 1
    factor ← 1⌊0⌈(manhattanDist⊸-÷¬)density

    # Blend the colors based on the calculated factor
    (outer⊸×+inner×¬)factor

  }¨↕size
}

#----------------------------------------------------------------------------------
# Image conversions
#----------------------------------------------------------------------------------

# Encode image data in arrays by using encode to encode into binary data by an input format,
# along with also acounting for luminocity.

# TODOs
# remember to normalize not only by gray but by all colors, depending on their bytes 
# after aproximating, turn leftover data into other colors to keep brightness the same 
# calculate leftovers (that come from shortening bit-lengths and therefore loosing information and brightness) and add them in other colors
# using _Base_, improve efficienty of images stored as ints to split it to bit components to save space.
# support compressed formats

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
  vals‿keys ← 𝕩⊸•ns.Get¨⊸⋈•ns.Keys 𝕩 # namespace to arrays
# ┌─unsorted──────┐   ┌─adding defaults─────────────────────────────┐
  [uFormats, ubits] ← ⍉>(∊keys∾formatKeys)/(keys⋈¨vals)∾formatKeys⋈¨0
  ¯1+2⋆ubits ⊏˜⍋ formatKeys ⊐ uFormats  # sorting by formats
}

Normalize ← {format𝕊image:
  bitLengths ← FormatToLengths 𝕨
  size ← 2↑≢image
  m ← 0≠bitLengths
  # pick out color data from image
  colors ← image ÷⎉1 m/bitLengths
  # multiplying it by luminocityMat, thereby splitting rgba and grayscale into rgba components
  colors MP ÷⎉1⟜(0⊸=⊸++˝) m/luminocityMat
}

ReFormat ← {oldFormat‿newFormat𝕊image:
  rgba ← oldFormat Normalize image
  bitLengths ← FormatToLengths newFormat
  m ← 0≠bitLengths
  x ← ⍉⁼ rgba MP ⍉ m/luminocityMat
  ⌊0.5+x×m/bitLengths
}

# Remove later
#_Base_ ← {⌽𝕗|⌊∘÷⟜𝕗⍟(↕𝕘)} # Base _𝕣_ Length input → list
#
#
#oldFormat ← {r‿grayscale⇐8‿8}
#newFormat ← {r⇐8} # 5‿6‿5⥊¨1
#image ← 3‿3‿2⥊[155‿255,0‿0]
#
#•Show oldFormat‿newFormat ReFormat image