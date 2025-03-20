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
perlin ← •Import "../imports/bqn-libs/perlin.bqn"
low ← •Import "low.bqn"
⟨NeedsWindow,raylib⟩ ← {𝕊:@⋈•Import"loadRaylib.bqn"}⍟(0=≠)•args
allFormats ← (•ns.Get¨⍋⊸⊏⊢)⟜•ns.Keys pixelFormat
Squeeze‿Type ← ⟨
  {⟨S⇐Squeeze⟩: S; ⊢}
  {⟨T⇐Type⟩: T; ""}
⟩{𝕎𝕩}¨•BQN∘"•internal"⍟(∨´"internal"⊸≡¨)•listsys

#R        G        B        A
#00110011 00110011 00110011 00110011

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
  (↕size) ptr.Write¨ (dataPtr.Cast "i8").Read¨ ↕size
  ptr‿oldWidth‿oldHeight‿mipmaps‿format
}

# image.ToArr
ToArr ← {𝕊raylibImg:
  changeFormat←pixelFormat.uncompressed_r8g8b8a8≢4⊑𝕩
  dataptr‿width‿height‿·‿format ← {
    ⊑⊑raylib.ImageFormatRef ⟨Copy 𝕩⟩‿pixelFormat.uncompressed_r8g8b8a8
  }⍟changeFormat 𝕩
  "Invalid image format"!×format
  bqnImg ← height‿width‿4(⊣⥊×´⊸low.Make)dataPtr
  raylib.MemFree⍟changeFormat dataPtr
  bqnImg
}

# image.LoadFromArr
LoadFromArr ← {𝕊img:
  NeedsWindow@
  ptr ← {𝕩.Cast"i8"} raylib.MemAlloc≠l←¯128+256|128+⥊𝕩
  l ptr.Write¨˜↕≠l
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
    dataptr‿width‿height‿·‿format←image
    r ← width‿height‿4‿frames(⊣⥊×´⊸low.Make)dataPtr
    r ⊣ raylib.MemFree dataPtr
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
  Squeeze ¯128+256|128+⍉inner + ⌊(outer-inner)×⌜ ⌈⌜´ |¯1+ (↕¨size) ÷ 0⊸=⊸+ 2÷˜size-1 # dzaima helped a lot :)
}

# Generate image: radial gradient
# image.GenGradientRadial
GenGradientRadial ← {[inner⋄outer]𝕊size‿density:
  r ← 2÷˜⌊´size
  radial ← +⌜´⌾(×˜)(size÷2)-˜↕¨size # make circle
  radial-↩ r×density                # resize center
  radial÷↩ 0⊸=⊸+r×¬density          # add blur
  Squeeze ¯128+256|128+ ⍉inner + ⌊(outer-inner)×⌜ 1⌊0⌈ radial # coloring
}

# Generate image: white noise
GenWhiteNoise ← {factor𝕊size:
  [0‿0‿0‿¯1⋄¯1‿¯1‿¯1‿¯1] ⊏˜ (⌊100×𝕨)> 𝕩 •rand.Range 100
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
#PerFrame ← {⟨tex1⋄tex2⋄tex3⋄tex4⋄tex5
#  ⟩𝕊scrolled:
#  raylib.BeginDrawing⟨⟩
#    raylib.ClearBackground 4⥊0
#    raylib.DrawFPS 0‿0
#    raylib.DrawTextureEx ⟨tex1⋄300‿0+   raylib.GetMousePosition⟨⟩⋄𝕩⋄÷5⋄4⥊255⟩
#    raylib.DrawTextureEx ⟨tex2⋄300‿600+raylib.GetMousePosition⟨⟩⋄𝕩⋄÷5⋄4⥊255⟩
#    raylib.DrawTextureEx ⟨tex3⋄300‿300+raylib.GetMousePosition⟨⟩⋄𝕩⋄÷5⋄4⥊255⟩
#    raylib.DrawTextureEx ⟨tex4⋄0‿0+raylib.GetMousePosition⟨⟩⋄𝕩⋄÷5⋄4⥊255⟩
#    raylib.DrawTextureEx ⟨tex5⋄0‿300+raylib.GetMousePosition⟨⟩⋄𝕩⋄÷5⋄4⥊255⟩
#  raylib.EndDrawing⟨⟩
#  90|raylib.GetMouseWheelMove∘⟨⟩⊸+𝕩
#}
#
#raylib.SetTraceLogLevel raylib.traceLogLevel.log_warning
#
#raylib.InitWindow 700‿700‿"hello"
#  raylib.SetTargetFPS 60
#  raylib.SetWindowPosition 0‿50
#  size ← 1000‿1000
#
#  a‿b‿c‿d‿e ← size∾⟨0, 4⥊255, 255‿0‿0‿255⟩
#  img1←ToArr raylib.GenImageGradientSquare a‿b‿c‿d‿e
#  img2←[d⋄e]GenGradientSquare a‿b
#  img3 ← [d⋄e] GenGradientRadial ⟨1000‿1000,0.5⟩
#  img1‿img2‿img3 LoadFromArr¨↩
#
#  img4 ← raylib.GenImageWhiteNoise size∾0.52
#  img5 ← LoadFromArr 0.5 GenWhiteNoise size
#
#  t ← raylib.LoadTextureFromImage¨ img1‿img2‿img3‿img4‿img5
#  Unload¨img1‿img2‿img3‿img4‿img5
#
#  t PerFrame•_While_(¬raylib.WindowShouldClose∘⟨⟩) 0
#  raylib.UnloadTexture¨t
#
#raylib.CloseWindow⟨⟩
