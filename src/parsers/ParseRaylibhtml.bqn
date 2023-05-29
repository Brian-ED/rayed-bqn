## Metaprogram rayffi.bqn automatically.
## INCOMPLETE the current rayffi file is all manually made.

nl ← @+10 # newline
json ← •Import (∾5⥊<"../")∾"bqn-libs/json.bqn"
#str  ← •Import (∾6⥊<"../")∾"bqn-libs/Strings.bqn"
Box ←  >⊢»¨⟜<' '⥊˜·⌈´≠¨
LowerNames ← +⟜(32×1="A["⊸⍋)⌾(1↑⊢)
_MetaParse ← {∾˘´Box¨𝕨∾⍟(⟨⟩≢⊢)⚇1𝕗{𝕎𝕩}¨¨<˘⍉𝕩}
# fs ← '*'∾f
# is ← '*'∾i
MapTypes ← (⊣(•Show⊣)⍟("undef"≡⊢)¨⊏∘⌽˘⊸⊐˜⊏"undef"∾⟜<˜⊏˘∘⊢)⟜[  
  ## This specific map is only for function arguments 
  # ? really unsure of:
  "bool"‿"bool"
  "void"‿"..."
  "void"‿"const char **"

  # star adds? testing needed
  "('*'∾wave)"‿"Wave *"
  "('*'∾image)"‿"Image *"
  "('*'∾model)"‿"Model *"
  "('*'∾mesh)"‿"Mesh *"
  "('*'∾modelAnimation)"‿"ModelAnimation *"
  "('*'∾color)"‿"Color *"
  "('*'∾v2)"‿"Vector2 *"
  "('*'∾v3)"‿"Vector3 *"
  "('*'∾v4)"‿"Vector4 *"
  "('*'∾texture)"‿"Texture2D *"
  "('*'∾material)"‿"Material *"
  "('*'∾matrix)"‿"const Matrix *"
  # Lowercased
  "rectangle"‿"Rectangle"
  "camera"‿"Camera"
  "camera"‿"Camera2D"
  "camera"‿"Camera3D"
  "audioCallback"‿"AudioCallback"
  "audioStream"‿"AudioStream"
  "image"‿ "Image"
  "wave"‿"Wave"
  "sound"‿"Sound"
  "ray"‿"Ray"
  "matrix"‿"Matrix"
  "boundingBox"‿"BoundingBox"
  "mesh"‿"Mesh"
  "model"‿"Model"
  "material"‿"Material"
  "texture2D"‿"Texture2D"
  "font"‿"Font"
  "modelAnimation"‿"ModelAnimation"
  "color"‿"Color"
  "music"‿"Music"
  "filePathList"‿"FilePathList"
  "nPatchInfo"‿"NPatchInfo"
  "renderTexture"‿"RenderTexture2D"
  "shader"‿"Shader"
  "vrStereoConfig"‿"VrStereoConfig"
  "vrDeviceInfo"‿"VrDeviceInfo"
  "traceLogCallback"‿"TraceLogCallback"
  "loadFileDataCallback"‿"LoadFileDataCallback"
  "saveFileDataCallback"‿"SaveFileDataCallback"
  "loadFileTextCallback"‿"LoadFileTextCallback"
  "saveFileTextCallback"‿"SaveFileTextCallback"
  
  # shorten struct names
  "v4"‿"Vector4"
  "v3"‿"Vector3"
  "v2"‿"Vector2"

  "void" ‿"void *"
  "i"    ‿"int"
  "u"    ‿"unsigned int"
  "ui"   ‿"unsigned int *"
  """f64"""‿"double"
  """&i32"""‿"int *"
  "fs"   ‿"float *"
  "f"    ‿"float"
  "str"  ‿"const char *"
  "uStr" ‿"const unsigned char *"
]
"rayffi.bqn" •FChars ∾ nl ∾¨ {
 "defines"𝕊𝕩:
  Parse ← {∾˘´Box¨""‿""‿" ⇐ "‿" # "∾⍟(⟨⟩≢⊢)⚇1⟨LowerNames,⟨⟩˙,•Repr,⊢⟩{𝕎𝕩}¨¨ <˘⍉𝕩}
  exclTypes  ← "GUARD"‿"MACRO"‿"UNKNOWN"‿"FLOAT_MATH"‿"COLOR"
  Filter     ← {𝕊n‿t‿v‿d: # name‿type‿val‿desc
    ¬("PI"≡n) ∨ (∨´t⊸≡¨exclTypes) ∨ ⟨⟩≡v
  }
  ⥊nl∾˘Parse Filter˘⊸/ 1⊏˘˘ >⍉¨𝕩
;"structs"𝕊𝕩:
  Parse ← { # 𝕊 ⍉[name,desc,fields]:
    ParseStruct ← {
      ∾(@+10)∾¨"⟩"∾˜<˘"  "∾⎉1""‿" # "‿"  # "⟨'"'∾∾⟜'"',⊢,⊢⟩_MetaParse >𝕩
    }
    {
      header ← (»⊸∨' '⊸≠)⊸/¨ <˘(⥊@+10)‿" ⇐ ⟨ # "⟨LowerNames,⊢⟩_MetaParse 2↑˘𝕩
      body ← (∨`⌾⌽' '⊸≠)⊸/¨<˘⟨""⟩⟨ParseStruct 1⊏¨⊢⟩_MetaParse ¯1↑˘3↑˘𝕩
      ∾ body ∾˜¨header
    }⌽⌾(1↓⊢)˘⌾⍉𝕩
  }
  Parse 1⊏˘˘>⍉¨𝕩
;"aliases"𝕊𝕩:"" # Least priority
;"enums"𝕊𝕩:
  ParseNamespace←{𝕊⟨name,description,values⟩:
    header ← (LowerNames name) ∾" ⇐ { # "∾ description
    body   ← ""‿" ⇐ "‿"  # "⟨LowerNames,•Repr,⊢⟩_MetaParse >1⊏¨values
    (nl∾"}")∾˜header∾∾(nl∾"  ")⊸∾¨<˘body
  }
  ∾nl∾¨ParseNamespace¨1⊏¨𝕩
;"callbacks"𝕊𝕩:"" # I don't know what callbacks do, i formatted them as functions but they are probably not.
  #⥊nl∾˘⟨""," ⇐ "," _R"," # "⟩⟨LowerNames,'"'∾˜'"'∾⊢,⊢,⊢⟩_MetaParse{# ⍉[name, description, returnType, params]:
  #  {<˘∾˘´<∘Box˘⍉>{⟨' '∾˜»«∾∾⟜'"'¨"‿"""⊸∾¨⊑𝕩, "#"∾⟜∾' '∾¨1⊑𝕩⟩}¨(<˘⍉∘>)¨1⊏¨¨𝕩}⌾(2⊏˘⊢) 0‿2‿3‿1⊸⊏˘𝕩
  #}>1⊏¨𝕩
;"functions"𝕊𝕩:
  FillTitles ← {𝕊[titles, args]:
    all ← "name"‿"description"‿"returnType"‿"params"
    args⌾((/all∊titles)⊸⊏)(0‿2⥊"")∾⟜<˜3⥊<""
  }

  ⥊nl∾˘⟨""," ⇐ "," _R"," # "⟩⟨LowerNames,'"'∾˜'"'∾⊢,⊢,⊢⟩_MetaParse{# ⍉[name, description, returnType, params]:
    {<˘∾˘´<∘Box˘⍉>{⟨' '∾˜" @"⍟(""⊸≡)»«∾'‿'∾¨MapTypes⊑𝕩, "#"∾⟜∾' '∾¨1⊑ 𝕩⟩}¨(<˘⍉∘>)¨1⊏¨¨𝕩}⌾(2⊏˘⊢) 0‿2‿3‿1⊸⊏˘𝕩
  }> FillTitles¨𝕩
}´¨<˘⍉json.Parse •FChars "raylib.html"