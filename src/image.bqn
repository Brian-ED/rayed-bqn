⟨
  # generation
  GenGradientLinear ⋄ GenGradientSquare
  GenGradientRadial ⋄ GenChecked
  GenColor

  # Raylib image format functions
  _AsRayImg ⋄ Copy ⋄ ToArr
  LoadFromArr ⋄ Unload
  GetPixelDataSize # pixel size of the raylib format

  # Miscellaneous
  GetAlphaBorder
  FromFile
  FromTexture
  Crop
  CropAlpha
⟩⇐

# No function unloads or mutates input image, except Unload

⟨pixelFormat⟩ ← •Import "constants.bqn"
low ← •Import "low.bqn"
raylib‿NeedsWindow ← •args

allFormats ← (•ns.Get¨⍋⊸⊏⊢)⟜•ns.Keys pixelFormat

# Get pixel data size in bytes for certain format
# NOTE: Size can be requested for Image or Texture data
# image.GetPixelDataSize
GetPixelDataSize ← {format𝕊size:
  bpp ← { # Bits per pixel
    𝕩≡pixelFormat.uncompressed_grayscale? 8;
    ⊑𝕩∊⟨pixelFormat.uncompressed_gray_alpha
        pixelFormat.uncompressed_r5g6b5
        pixelFormat.uncompressed_r5g5b5a1
        pixelFormat.uncompressed_r4g4b4a4 ⟩? 16;
    𝕩≡pixelFormat.uncompressed_r8g8b8a8     ? 32;
    𝕩≡pixelFormat.uncompressed_r8g8b8       ? 24;
    𝕩≡pixelFormat.uncompressed_r32          ? 32;
    𝕩≡pixelFormat.uncompressed_r32g32b32    ? 32×3;
    𝕩≡pixelFormat.uncompressed_r32g32b32a32 ? 32×4;
    𝕩≡pixelFormat.uncompressed_r16          ? 16;
    𝕩≡pixelFormat.uncompressed_r16g16b16    ? 16×3;
    𝕩≡pixelFormat.uncompressed_r16g16b16a16 ? 16×4;
    ⊑𝕩∊⟨pixelFormat.compressed_dxt1_rgb
        pixelFormat.compressed_dxt1_rgba
        pixelFormat.compressed_etc1_rgb
        pixelFormat.compressed_etc2_rgb
        pixelFormat.compressed_pvrt_rgb
        pixelFormat.compressed_pvrt_rgba⟩? 4;
    ⊑𝕩∊⟨pixelFormat.compressed_dxt3_rgba
        pixelFormat.compressed_dxt5_rgba
        pixelFormat.compressed_etc2_eac_rgba
        pixelFormat.compressed_astc_4x4_rgba⟩? 8;
    𝕩≡pixelFormat.compressed_astc_8x8_rgba   ? 2;
    0
  }format

  dataSize ← 8÷˜bpp×size  # Total data size in bytes

  # Most compressed formats works on 4x4 blocks,
  # if texture is smaller, minimum dataSize is 8 or 16
  datasize‿8‿16‿datasize⊑˜⊑format⍋˜⟨
    pixelFormat.compressed_dxt1_rgb
    pixelformat.compressed_dxt3_rgba
    pixelformat.compressed_astc_8x8_rgba
  ⟩
}

# Copy a raylib image to a new image
# image.Copy
Copy ← {𝕊dataPtr‿oldWidth‿oldHeight‿mipmaps‿format:
  # 1⌈ is security check for NPOT textures
  mapSizes ← ×´¨1⌈⌊∘÷⟜2⍟(↕mipmaps) oldHeight‿oldWidth
  size ← +´format⊸GetPixelDataSize¨mapSizes
  ptr ← (raylib.MemAlloc size).Cast "i8"
  ptr.Write (dataPtr.Cast "i8").Read size
  ptr‿oldWidth‿oldHeight‿mipmaps‿format
}

# image.ToArr
ToArr ← {𝕊raylibImg:
  changeFormat←pixelFormat.uncompressed_r8g8b8a8≢4⊑𝕩
  dataptr‿width‿hight‿·‿format ← {
    ⊑⊑raylib.ImageFormatRef ⟨Copy 𝕩⟩‿pixelFormat.uncompressed_r8g8b8a8
  }⍟changeFormat 𝕩
  "Invalid image format"!×format
  bqnImg ← hight‿width‿4(⊣⥊256|×´⊸low.Make)dataPtr     # 256|𝕩 is converting from int to uint
  raylib.MemFree⍟changeFormat dataPtr
  bqnImg
}

# image.LoadFromArr
LoadFromArr ← {𝕊img:
  NeedsWindow@
  l low.Read ptr←raylib.MemAlloc≠l←¯128+256|128+⥊𝕩
  ptr<⊸∾(⌽∾⟜4⁼≢𝕩)∾1‿pixelFormat.uncompressedr8g8b8a8
}

# image.Unload
Unload ← {𝕊img:
  imgDataIndex ← 0
  raylib.MemFree imgDataIndex⊑𝕩
  @
}

# Load image from file into CPU memory (RAM)
# image.FromFile
FromFile ← {𝕊path:
  NeedsWindow@ # raylib.LoadImageFromMemory needs window to be open
  "Path has to be absolute"!•file.At⊸≡𝕩
  "No file found at path"!•file.Exists𝕩

  # Loading file to memory
  ext ← '.'∾∧`⌾⌽∘≠⟜'.'⊸/𝕩
  fileData ← •FBytes 𝕩

  # Loading image from memory data
  img ← raylib.LoadImageFromMemory⟨ext, fileData, ≠fileData⟩
  # TODO might need to reformat img
  (Unload⊢ToArr) img
}

# TODO
GifToImages ← {𝕊bytes:
  "GIF"≡3↑𝕩?
    NeedsWindow@
    image‿⟨frames⟩ ← raylib.LoadImageAnimFromMemoryRef ⟨".gif"⋄bytes⋄≠bytes⋄⟨0⟩⟩ # fileType fileData dataSize frames # Load image sequence from memory buffer
    dataptr‿width‿hight‿·‿format←image
    width‿hight‿4‿frames(⊣⥊256|×´⊸low.Make)dataPtr     # 256|𝕩 is converting from int to uint
  ;
  @
}

# image._asRayImg
_asRayImg ← {(Unload⊢𝔽)LoadFromArr}

#----------------------------------------------------------------------------------
# Image generation
#----------------------------------------------------------------------------------

# image.GenColor
GenColor ← ∾⟜4⊸⥊˜

# image.GenChecked
GenChecked ← {𝕨⊏˜≠⌜´2|↕¨𝕩}

# Generate image: linear gradient
# The direction value specifies the direction of the gradient as unit vector
# image.GenGradientLinear
GenGradientLinear ← {[start⋄end]𝕊size‿dir:
  ⍉start+⌊(end-start)×⌜+⌜˜´(↕¨size)×dir÷0⊸=⊸+¯1+´dir×size
}

# Generate image: square gradient
# image.GenGradientSquare
GenGradientSquare ← {[inner⋄outer]𝕊size:
  # past impl  ⍉⌊((outer×⌜⊢)+inner×⌜¬) ⌈˝|1+(2÷˜0⊸=⊸+1-size)÷˜⍉⁼>↕size
  ⍉inner + ⌊(outer-inner)×⌜ ⌈⌜´ |¯1+ (↕¨size) ÷ 0⊸=⊸+ 2÷˜size-1 # dzaima helped a lot :)
}

# Generate image: radial gradient
# image.GenGradientRadial
GenGradientRadial ← {[inner⋄outer]𝕊size‿density:
  r ← 2÷˜⌊´size
  radial ← +⌜´⌾(×˜)(size÷2)-˜↕¨size # make circle
  radial-↩ r×density                # resize center
  radial÷↩ 0⊸=⊸+r×¬density          # add blur
  ⍉inner + ⌊(outer-inner)×⌜ 1⌊0⌈ radial # coloring
}

#----------------------------------------------------------------------------------
# Image conversions
#----------------------------------------------------------------------------------

# used to get brightness of color:
#   +´luminocity×color
# color.luminocity
luminocity ← 0.299‿0.587‿0.114‿0

# image.FromTexture
FromTexture ⇐ {𝕊texture:
  NeedsWindow@
  (Unload⊢ToArr) raylib.LoadImageFromTexture 𝕩
}

# image.Crop
Crop ← {[x1‿y1⋄x2‿y2]𝕊img:𝕨⌊˝⊸↓𝕨⌈˝⊸↑𝕩}

# Get image alpha border rectangle
# NOTE: Threshold is defined as a percentage: 0 → 1
# image.GetAlphaBorder
GetAlphaBorder ← {threshold𝕊image:
  (∾⟜4⁼≢𝕩)⊸-⌾(1⊸⊏)⌊´¨+˝¨∧`¨⍉∘⌽⍟[0‿1⋄2‿3](𝕨×255)≥3⊏˘˘𝕩
}

# Crop image depending on alpha value
# NOTE: Threshold is defined as a percentage: 0.0f -> 1.0f
# image.CropAlpha
CropAlpha ← {threshold𝕊image:
  𝕩 Crop˜ 𝕨 GetAlphaBorder 𝕩
}

#TODO
# genImageWhiteNoise
# genImagePerlinNoise
# genImageCellular
# genImageText
# imageText
# imageTextEx
# imageToPOT
# imageAlphaClear
# imageAlphaMask
# imageAlphaPremultiply
# imageBlurGaussian
# imageKernelConvolution
# imageResize
# imageResizeNN
# imageResizeCanvas
# imageMipmaps
# imageDither
# imageFlipVertical
# imageFlipHorizontal
# imageRotate
# imageRotateCW
# imageRotateCCW
# imageColorTint
# imageColorInvert
# imageColorGrayscale
# imageColorContrast
# imageColorBrightness
# imageColorReplace
# loadImagePalette
# unloadImagePalette
# getImageAlphaBorder
# getImageColor
# imageClearBackground
# imageDrawPixel
# imageDrawPixelV
# imageDrawLine
# imageDrawLineV
# imageDrawCircle
# imageDrawCircleV
# imageDrawCircleLines
# imageDrawCircleLinesV
# imageDrawRectangle
# imageDrawRectangleV
# imageDrawRectangleRec
# imageDrawRectangleLines
# imageDraw
# imageDrawText
# imageDrawTextEx
#
# exportImage
# exportImageToMemory
# exportImageAsCode
#


#TESTING
#⟨c⇐color,w⇐window,d⇐draw,m⇐mouse⟩←r←•Import "/home/brian/rayed-bqn/rayed.bqn"
#
#PerFrame ← {tex1‿tex2‿tex3‿font𝕊scrolled:
#  c.white‿font‿30 d.Text 20‿20⋈•Repr∘w.GetFPS⊸∾" FPS"
#  {d.Texture⟜m.GetPos c.white‿tex1∾𝕩∾˜÷5}¨𝕩+90×↕4
#  {d.Texture⟜(0‿700+m.GetPos) c.white‿tex2∾𝕩∾˜÷5}¨𝕩+90×↕4
#  {d.Texture⟜(0‿450+m.GetPos) c.white‿tex1∾𝕩∾˜÷5}¨𝕩+90×↕4
#  90|m.WheelMoved⊸+𝕩
#}d._withCanvas⟜c.black
#
#r.window.SetSize 0.5‿0
#
#{𝕤
#  r.window.SetPos 1000‿0
#  font ← r.font.LoadBQN@
#  size ← 1000‿1000
#
#  img1 ← @
#  •Show {img1↩r.raylib.GenImageGradientSquare𝕩}•_Timed size∾⟨0, 255‿0‿0‿255, 4⥊255⟩
#  img2 ← @
#  •Show {img2↩GenGradientSquare𝕩} •_Timed ⟨size, 255‿0‿0‿255, 4⥊255⟩
#  img2 LoadFromArr↩
#  img3 ← Copy img1
#
#  t‿l‿p ← r.raylib.LoadTextureFromImage¨ img1‿img2‿img3
#  r.image.Unload¨img1‿img2‿img3
#
#  l‿t‿p‿font PerFrame•_While_(¬w.ShouldClose) 0
#  r.texture.Unload¨t‿l
#  r.font.Unload font
#} w._openAs "test"