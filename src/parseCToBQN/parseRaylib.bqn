## Metaprogram rayffi.bqn automatically.

ffiUtilsPath←⊑•args∾<"../ffiUtils.bqn"

nl ← @+10 # newline
json ← •Import "../imports/bqn-libs/json.bqn"

Box ← {>𝕩»¨<(⌈´≠¨𝕩)⥊𝕨⊣' '}
LowerNames ← +⟜(32×1="A["⊸⍋)⌾(1↑⊢)
_MetaParse ← {∾˘´Box¨𝕨∾⚇1𝕗{𝕎𝕩}¨¨<˘⍉𝕩}
_MetaParseFull ← {∾˘´Box¨𝕨∾⚇1𝕗{𝕎𝕩}¨<˘⍉𝕩}
⟨raylibPath⟩ ← •Import"../loadConfig.bqn"

mapArgTypes ← {𝕊[bqn,c]:{𝕩LowerNames∘⊣⍟(0⊸≡)¨(c⊐𝕩)⊏bqn∾<0}6↓⍟("const "≡↑)¨⊢} abc←⍉[  
  # pointers
  "'*'∾boneInfo"      ‿"boneInfo *"
  "'*'∾camera3D"      ‿"Camera *"
  "'*'∾color"         ‿"Color *"
  "'*'∾glyphInfo"     ‿"GlyphInfo *"
  "'*'∾image"         ‿"Image *"
  "'*'∾material"      ‿"Material *"
  "'*'∾materialMap"   ‿"materialMap *"
  "'*'∾matrix"        ‿"Matrix *"
  "'*'∾mesh"          ‿"Mesh *"
  "'*'∾model"         ‿"Model *"
  "'*'∾modelAnimation"‿"ModelAnimation *"
  "'*'∾rectangle"     ‿"rectangle *"
  "'*'∾texture"       ‿"Texture2D *"
  "'*'∾transform"     ‿"transform *"
  "'*'∾v2"            ‿"Vector2 *"
  "'*'∾v3"            ‿"Vector3 *"
  "'*'∾v4"            ‿"Vector4 *"
  "'*'∾wave"          ‿"Wave *"
  """**""∾rectangle"  ‿"Rectangle **"
  """**""∾transform"  ‿"transform **"

  # remove since they're not defined
  "ptr"‿"AudioCallback"
  "ptr"‿"LoadFileDataCallback"
  "ptr"‿"LoadFileTextCallback"
  "ptr"‿"rAudioBuffer *"
  "ptr"‿"rAudioProcessor *"
  "ptr"‿"SaveFileDataCallback"
  "ptr"‿"SaveFileTextCallback"
  "ptr"‿"TraceLogCallback"

  # shorten struct names
  "camera3D"     ‿"Camera"
  "renderTexture"‿"RenderTexture2D"
  "texture"      ‿"Texture2D"
  "texture"      ‿"textureCubemap"
  "v2"           ‿"Vector2"
  "v3"           ‿"Vector3"
  "v4"           ‿"Vector4"

  "'*'∾f"   ‿"float *"
  "'*'∾i"   ‿"int *"
  "'*'∾str" ‿"char **"
  "'*'∾u"   ‿"unsigned int *"
  """*i16"""‿"unsigned short *"
  """f64""" ‿"double"
  """i64""" ‿"long"
  "f"       ‿"float"
  "i"       ‿"int"
  "ptr"     ‿"..."
  "ptr"     ‿"void *"
  "str"     ‿"char *"
  "u"       ‿"unsigned int"
  "u8"      ‿"char"
  "u8"      ‿"unsigned char"
  "ustr"    ‿"unsigned char *"
]

mapStructTypes ← {𝕊[bqn,c]:{𝕩⊣⍟(0⊸≡)¨((LowerNames¨c)⊐𝕩)⊏bqn∾0}{
  b ← (⊑∘⊐¨⟜'['-≠¨)𝕩
  "ptr⊣"⊸∾⍟(('*'≡1⊑2↑⊢)∨("ustr"≡4↑⊢)∨"str"≡3↑⊢)¨ 3⊸↓¨⌾((0=b)⊸/) 𝔽{'"'∾¨(b↑¨𝕩)∾¨"""∾"⊸∾¨𝔽 b↓¨𝕩} LowerNames¨𝕩
}6↓⍟("const "≡↑)¨⊢}abc

mapStructNames ← {𝕊[bqn,c]:{𝕩LowerNames∘⊣⍟(0⊸≡)¨(c⊐𝕩)⊏bqn∾<0}6↓⍟("const "≡↑)¨⊢}⍉[  
  "v4"‿"Vector4"
  "v3"‿"Vector3"
  "v2"‿"Vector2"
]

MapFuncReturnType ← " "⍟("void"⊸≡)·{'('∾𝕩∾')'}⍟(∨´"∾⊣"⊸∊)MapStructTypes⌾⋈

defines‿structs‿aliases‿enums‿callbacks‿functions←{
  x←⍉json.Parse •FChars "./inp-out/raylib.json"
  !(⊏˘x)≡"defines"‿"structs"‿"aliases"‿"enums"‿"callbacks"‿"functions"
  1⊏˘x
}
{𝕊𝕩: 
  ⥊nl∾˘""‿" ⇐ "‿" # "⟨LowerNames,LowerNames,⊢⟩_MetaParse 1‿0‿2⊸⊏˘>1⊏¨𝕩
}aliases

"./inp-out/rayffi.bqn"•FLines (•FLines "topOfRayffi.bqn") ∾(⋈"r ⇐ MakeImporter """∾raylibPath∾'"')∾∾´⟨
  { # defines
    Parse ← {∾˘´Box¨""‿""‿" ⇐ "‿" # "∾⍟(⟨⟩≢⊢)⚇1⟨LowerNames,⟨⟩˙,•Repr,⊢⟩{𝕎𝕩}¨¨ <˘⍉𝕩}
    exclTypes  ← "GUARD"‿"MACRO"‿"UNKNOWN"‿"FLOAT_MATH"‿"COLOR"
    Filter     ← {𝕊n‿t‿v‿d: # name‿type‿val‿desc
      ¬∨´⟨"PI"≡n, ∨´t⊸≡¨exclTypes, ⟨⟩≡v ⟩
    }
    <˘Parse Filter˘⊸/ 1⊏˘˘ >⍉¨defines
  }
  { # structs
    ParseStruct ← {
      ∾(@+10)∾¨"⟩"∾˜<˘"  "∾⎉1""‿" # "‿"  # "⟨⊢, ⊢,⊢⟩_MetaParse MapStructTypes⌾(⊏˘) >𝕩
    }
    Parse ← { # 𝕊 ⍉[name,desc,fields]:
      header ← (»⊸∨' '⊸≠)⊸/¨<˘""‿" ⇐ S ⟨ # "⟨LowerNames,⊢⟩_MetaParse MapStructNames⌾(⊏˘) 2↑˘𝕩
      body ← ∨`⌾⌽∘≠⟜' '⊸/¨<˘⟨""⟩⟨ParseStruct 1⊏¨⊢⟩_MetaParse ¯1↑˘3↑˘𝕩
      body ∾˜¨header
    }⌽⌾(1↓⊢)˘⌾⍉
    Parse 1⊏˘˘>⍉¨⌽structs
  }
  { # enums
    ParseNamespace←{𝕊name‿description‿values:
      header ← (LowerNames name)∾" ⇐ { # "∾description
      body   ← ""‿" ⇐ "‿"  # "⟨LowerNames,•Repr,⊢⟩_MetaParse >1⊏¨values
      (nl∾"}")∾˜header∾∾(nl∾"  ")⊸∾¨<˘body
    }
    ParseNamespace¨1⊏¨enums
  }
  { # functions
    FillTitles ← ⊢˝ # "name"‿"description"‿"returnType"‿"params"
    <˘⟨"", " ⇐ ", "", " _R"," # "⟩⟨
      LowerNames¨
      MapFuncReturnType¨
      '"'∾¨∾⟜'"'¨
      <˘"⟨"‿"⟩ #"⟨{<˘1↓˘∾˘´('⋄'⊸∾˘)¨ Box¨<˘⍉(<"") Box MapArgTypes¨𝕩},∾¨' '⊸∾¨¨⟩_MetaParseFull ·(⍉0⊸⊏¨≍1⊸⊏¨){2‿∘⥊⍉>1⊏¨𝕩}¨
      ⊢
    ⟩_MetaParseFull{# ⍉[name, description, returnType, params]:
      0‿1‿0‿2‿3⊸⊏˘0‿2‿3‿1⊸⊏˘𝕩
    }> FillTitles¨functions
  }
⟩