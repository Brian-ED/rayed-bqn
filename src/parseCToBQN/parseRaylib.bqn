## Metaprogram rayffi.bqn automatically.
## INCOMPLETE the current rayffi file is all manually made.

ffiUtilsPath←⊑•args∾<"../ffiUtils.bqn"

nl ← @+10 # newline
json ← •Import "../imports/bqn-libs/json.bqn"

Box ←  >⊢»¨⟜<' '⥊˜·⌈´≠¨
LowerNames ← +⟜(32×1="A["⊸⍋)⌾(1↑⊢)
_MetaParse ← {∾˘´Box¨𝕨∾⍟(⟨⟩≢⊢)⚇1𝕗{𝕎𝕩}¨¨<˘⍉𝕩}
⟨raylibPath⟩ ← •Import"../loadConfig.bqn"

mapArgTypes ← {𝕊[bqn,c]:{𝕩LowerNames∘⊣⍟(0⊸≡)¨(c⊐𝕩)⊏bqn∾<0}6↓⍟("const "≡↑)¨⊢}⍉[  
  # ? really unsure of:
  "ptr"‿"..."
  "'*'∾str"‿"const char **"
  "'*'∾str"‿"char **"
  "ptr"‿"const void *"
  "ustr"‿"unsigned char *"
  "str"‿"char *"
  "'*'∾camera3D"‿"Camera *"
  """**""∾rectangle"‿"Rectangle **"
  "'*'∾glyphInfo"‿"GlyphInfo *"
  "'*'∾matrix"‿"Matrix *"
  "renderTexture"‿"RenderTexture2D"

  # pointers
  "'*'∾wave"‿"Wave *"
  "'*'∾image"‿"Image *"
  "'*'∾model"‿"Model *"
  "'*'∾mesh"‿"Mesh *"
  "'*'∾modelAnimation"‿"ModelAnimation *"
  "'*'∾color"‿"Color *"
  "'*'∾v2"‿"Vector2 *"
  "'*'∾v3"‿"Vector3 *"
  "'*'∾v4"‿"Vector4 *"
  "'*'∾texture"‿"Texture2D *"
  "texture"‿"Texture2D"
  "'*'∾material"‿"Material *"
  "'*'∾matrix"‿"const Matrix *"
  
  # shorten struct names
  "v4"‿"Vector4"
  "v3"‿"Vector3"
  "v2"‿"Vector2"
  "camera3D"‿"Camera"
  "ptr"‿"TraceLogCallback"
  "ptr"‿"LoadFileDataCallback"
  "ptr"‿"SaveFileDataCallback"
  "ptr"‿"LoadFileTextCallback"
  "ptr"‿"SaveFileTextCallback"
  "ptr"‿"AudioCallback"

  "ptr"   ‿"void *"
  "i"      ‿"int"
  "u"      ‿"unsigned int"
  "'*'∾u"‿"unsigned int *"
  """f64"""‿"double"
  "'*'∾i"‿"int *"
  "'*'∾f"‿"float *"
  "f"      ‿"float"
  "str"    ‿"const char *"
  "uStr"   ‿"const unsigned char *"
  "u8"‿"char"
]

mapStructTypes ← {𝕊[bqn,c]:{𝕩⊣⍟(0⊸≡)¨((LowerNames¨c)⊐𝕩)⊏bqn∾0}{
  F←𝔽
  t ← ']'=¯1⊑¨𝕩
  b ← (≠¨𝕩)-˜𝕩⊑∘⊐¨'['
  "ptr"⍟('*'=¯1⊸⊑)¨ b {3↓𝕩}⍟(0=⊣)¨ {'"'∾¨(b↑¨𝕩)∾¨"""∾"⊸∾¨F b↓¨𝕩} LowerNames¨𝕩
}}⍉[  
  # lotsa ptrs since no destructuring pointers in structs (or atleast when returning from functions)
  "ptr⊣'*'∾str"            ‿"const char **"
  "ptr⊣'*'∾wave"           ‿"Wave *"
  "ptr⊣'*'∾image"          ‿"Image *"
  "ptr⊣'*'∾model"          ‿"Model *"
  "ptr⊣'*'∾mesh"           ‿"Mesh *"
  "ptr⊣'*'∾modelAnimation" ‿"ModelAnimation *"
  "ptr⊣'*'∾color"          ‿"Color *"
  "ptr⊣'*'∾v2"             ‿"Vector2 *"
  "ptr⊣'*'∾v3"             ‿"Vector3 *"
  "ptr⊣'*'∾v4"             ‿"Vector4 *"
  "ptr⊣'*'∾texture"        ‿"Texture2D *"
  "ptr⊣'*'∾material"       ‿"Material *"
  "ptr⊣'*'∾matrix"         ‿"const Matrix *"
  "ptr⊣'*'∾u8"                 ‿"unsigned char *"
  """u16"""                ‿"unsigned short *"
  "u8"                     ‿"unsigned char"
  "u8"                     ‿"char"
  """i64"""‿"long"
  "texture"‿"TextureCubemap"
  "renderTexture"‿"RenderTexture2D"

  # shorten struct names
  "v4"     ‿"Vector4"
  "v3"     ‿"Vector3"
  "v2"     ‿"Vector2"
  "texture"‿"Texture2D"

  "i"          ‿"int"
  "u"          ‿"unsigned int"
  "ptr⊣'*'∾u"  ‿"unsigned int *"
  """f64"""    ‿"double"
  "ptr⊣'*'∾i"  ‿"int *"
  "ptr⊣'*'∾f"  ‿"float *"
  "f"          ‿"float"
  "ptr⊣str"    ‿"const char *"
  "ptr⊣uStr"   ‿"const unsigned char *"
]
mapFuncNames ← {𝕊[bqn,c]:{𝕩LowerNames∘⊣⍟(0⊸≡)¨(c⊐𝕩)⊏bqn∾<0}6↓⍟("const "≡↑)¨⊢}⍉[  
  "v4"‿"Vector4"
  "v3"‿"Vector3"
  "v2"‿"Vector2"
]

MapFuncReturnType ← " "⍟("void"⊸≡)·('('⊸∾∾⟜')')⍟(∨´"∾⊣"⊸∊)MapStructTypes⌾<

"./inp-out/rayffi.bqn"•FLines (•FLines "topOfRayffi.bqn") ∾(⋈"r ⇐ MakeImporter """∾raylibPath∾'"')∾ {
 "defines"𝕊𝕩:
    Parse ← {∾˘´Box¨""‿""‿" ⇐ "‿" # "∾⍟(⟨⟩≢⊢)⚇1⟨LowerNames,⟨⟩˙,•Repr,⊢⟩{𝕎𝕩}¨¨ <˘⍉𝕩}
    exclTypes  ← "GUARD"‿"MACRO"‿"UNKNOWN"‿"FLOAT_MATH"‿"COLOR"
    Filter     ← {𝕊n‿t‿v‿d: # name‿type‿val‿desc
      ¬∨´⟨"PI"≡n, ∨´t⊸≡¨exclTypes, ⟨⟩≡v ⟩
    }
    ⥊nl∾˘Parse Filter˘⊸/ 1⊏˘˘ >⍉¨𝕩
;
  "structs"𝕊𝕩:
    ParseStruct ← {
      ∾(@+10)∾¨"⟩"∾˜<˘"  "∾⎉1""‿" # "‿"  # "⟨⊢, ⊢,⊢⟩_MetaParse MapStructTypes⌾(⊏˘) >𝕩
    }
    Parse ← { # 𝕊 ⍉[name,desc,fields]:
      {
        header ← (»⊸∨' '⊸≠)⊸/¨<˘⟨@+10⟩‿" ⇐ S ⟨ # "⟨LowerNames,⊢⟩_MetaParse MapFuncNames⌾(⊏˘) 2↑˘𝕩
        body ← ∨`⌾⌽∘≠⟜' '⊸/¨<˘⟨""⟩⟨ParseStruct 1⊏¨⊢⟩_MetaParse ¯1↑˘3↑˘𝕩
        ∾ body ∾˜¨header
      }⌽⌾(1↓⊢)˘⌾⍉𝕩
    }
    Parse 1⊏˘˘>⍉¨⌽𝕩
;
  "aliases"𝕊𝕩:"" # no aliases
;
  "callbacks"𝕊𝕩:"" # no callbacks
;
  "enums"𝕊𝕩:
    ParseNamespace←{𝕊name‿description‿values:
      header ← (LowerNames name)∾" ⇐ { # "∾description
      body   ← ""‿" ⇐ "‿"  # "⟨LowerNames,•Repr,⊢⟩_MetaParse >1⊏¨values
      (nl∾"}")∾˜header∾∾(nl∾"  ")⊸∾¨<˘body
    }
    ∾nl∾¨ParseNamespace¨1⊏¨𝕩
;
  "functions"𝕊𝕩:
    FillTitles ← {𝕊[titles, args]:
      all ← "name"‿"description"‿"returnType"‿"params"
      args⌾((/all∊titles)⊸⊏)(0‿2⥊"")∾⟜<˜3⥊<""
    }

    ⥊nl∾˘⟨"", " ⇐ ", "", " _R"," # "⟩⟨LowerNames⋄MapFuncReturnType⋄'"'∾'"'∾˜⊢⋄⊢⋄⊢⟩_MetaParse{# ⍉[name, description, returnType, params]:
      0‿1‿0‿2‿3⊸⊏˘{<˘∾˘´<∘Box˘⍉>{⟨'⟨'∾'⟩'∾˜1↓∾'⋄'∾¨MapArgTypes⊑𝕩, "#"∾⟜∾' '∾¨1⊑ 𝕩⟩}¨(<˘⍉∘>)¨1⊏¨¨𝕩}⌾(2⊏˘⊢) 0‿2‿3‿1⊸⊏˘𝕩
    }> FillTitles¨𝕩
}´¨<˘⍉json.Parse •FChars "./inp-out/raylib.json"