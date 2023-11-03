## Metaprogram rayffi.bqn automatically.

ffiUtilsPath←⊑•args∾<"../ffiUtils.bqn"

raylibTempLoc ← "inp-out/raylib.json"
outputLocation ← "./inp-out/rayffi.bqn"

# util functions
nl ← @+10 # newline
Box ← ⟨⟩⊸≡◶⟨>⊢»¨⟜<' '⥊˜·⌈´≠¨⋄↕0‿0⟩
LowerNames ← +⟜(32×1="A["⊸⍋)⌾(1↑⎉1⊢)
_MetaParse ← {∾˘´[𝕗,𝕨]{F‿w𝕊𝕩:<w⊸∾˘Box F𝕩}˘○⍉𝕩}
SHErr ← {exitcode‿stdout‿stderr←•SH𝕩
  •Out stdout
  stderr!0=exitcode
}

# imports
⟨raylibPath⟩ ← •Import"../loadConfig.bqn"
json ← •Import "../imports/bqn-libs/json.bqn"

# getting raylib.h path
raylibHeaderPath ← "include/raylib.h"∾˜"lib/"∾˜⁼{𝕩↓˜-⊑⊐⟜1⌽'/'=𝕩}raylibPath
(•file.Exists raylibHeaderPath)!˜"raylib header file expected at "∾raylibHeaderPath

# compile c parser if non existant

SHErr "cc"‿"raylib_parser.c"
SHErr "./a.out"‿"-i"‿raylibHeaderPath‿"-f"‿"JSON"‿"-o"‿raylibTempLoc
•file.Remove"a.out"

#raygui:
#cc raylib_parser.c && ./a.out -i ./inp-out/raygui.c -f JSON -o ./inp-out/raygui.json && rm ./a.out
#raylib: 
#cc raylib_parser.c && ./a.out -i ./inp-out/raylib.h -f JSON -o ./inp-out/raylib.json && rm ./a.out

mapArgTypes ← {𝕊[bqn,c]:
  remap ← {𝕎𝕏}´{(𝕨⊸≡∧"*"≡1↑⊣)◶⟨⋈⋄𝕩⋈˜1↓⊣⟩´}´¨⟨
    "unsigned char"  ‿"ustr"
    "char"           ‿"str"
    "void"           ‿"ptr"
    "rAudioBuffer"   ‿"ptr"
    "rAudioProcessor"‿"ptr"
  ⟩
  {
    constText←"const "
    consts←constText⊸(⊣≡≠⊸↑)¨𝕩
    cleaned←constText⊸∾⁼¨⌾(consts⊸/)𝕩
    SwitchOrder ← {⌽⌾((𝕩∊'0'+↕10)⊸/)1⊸⌽⌾((𝕩∊"[]")⊸/)𝕩}⌽
    [kept,removed] ← 2‿∘⥊⍉Remap⌾⌽˘> ∨`∘∊⟜"[*"⊸(¬⊸/¯1⊸↓⍟(" "≡¯1⊸↑)⊸⋈SwitchOrder∘/)¨cleaned
    AddRemoved ← {""𝕊𝕩:𝕩;'"'≡⊑𝕩?𝕨⊸∾⌾('"'⊸∾⁼)𝕩;'"'∾𝕨∾"""∾"∾𝕩}
    removed AddRemoved¨ kept LowerNames∘⊣⍟(0⊸≡)¨(c⊐kept)⊏bqn∾<0
  }
} ⍉[
  # remove since they're not defined
  "ptr"‿"AudioCallback"
  "ptr"‿"LoadFileDataCallback"
  "ptr"‿"LoadFileTextCallback"
  "ptr"‿"SaveFileDataCallback"
  "ptr"‿"SaveFileTextCallback"
  "ptr"‿"TraceLogCallback"

  # shorten struct names
  "camera3D"     ‿"Camera"
  "renderTexture"‿"RenderTexture2D"
  "texture"      ‿"Texture2D"
  "texture"      ‿"TextureCubemap"
  "v2"           ‿"Vector2"
  "v3"           ‿"Vector3"
  "v4"           ‿"Vector4"

  """f64""" ‿"double"
  """i64""" ‿"long"
  "f"       ‿"float"
  "i"       ‿"int"
  "ptr"     ‿"..."
  "u"       ‿"unsigned int"
  "u8"      ‿"char"
  "u8"      ‿"unsigned char"
  """u16""" ‿"unsigned short"
]

MapStructTypes ← "ptr⊣"⊸∾⍟(("ustr"≡4⊸↑)∨∨´∘=⟜'*'∨"str"≡3⊸↑)¨ MapArgTypes

mapStructNames ← {𝕊[bqn,c]:{𝕩LowerNames∘⊣⍟(0⊸≡)¨(c⊐𝕩)⊏bqn∾<0}6↓⍟("const "≡↑)¨⊢}⍉[  
  "v4"‿"Vector4"
  "v3"‿"Vector3"
  "v2"‿"Vector2"
]

_Time ← {•Show 𝔽•_timed𝕩⋄𝔽𝕩}
MapFuncReturnType ← " "⍟("void"⊸≡)¨·{'('∾𝕩∾')'}⍟(∨´"∾⊣"⊸∊)¨MapStructTypes

defines‿structs‿aliases‿enums‿callbacks‿functions←{
  x←⍉json.Parse •FChars raylibTempLoc
  !(⊏˘x)≡"defines"‿"structs"‿"aliases"‿"enums"‿"callbacks"‿"functions"
  ⊢˝¨¨1⊏˘x
}

outputLocation •FLines ∨`⌾⌽∘≠⟜' '⊸/¨(•FLines "topOfRayffi.bqn") ∾(⋈"r ⇐ MakeImporter """∾raylibPath∾'"')∾∾´⟨
  ⟨""⟩
  { # defines
    Parse ← ""‿""‿" ⇐ "‿" # "⟨LowerNames¨,⟨⟩¨,•Repr¨,⊢⟩_MetaParse⊢
    exclTypes  ← "GUARD"‿"MACRO"‿"UNKNOWN"‿"FLOAT_MATH"‿"COLOR"
    Filter     ← {𝕊n‿t‿v‿d: # name‿type‿val‿desc
      ¬∨´⟨"PI"≡n, ∨´t⊸≡¨exclTypes, ⟨⟩≡v ⟩
    }
    <˘Parse Filter˘⊸/>defines
  }
  ⟨""⟩
  { # structs
    ParseStruct ← {
      ∾nl∾¨"⟩"∾˜<˘"  "‿" # "‿"  # "⟨MapStructTypes,⊢,⊢⟩_MetaParse >𝕩
    }
    
    [name,desc,fields]←⍉>structs
    header ← »⊸∨∘≠⟜' '⊸/¨<˘""‿" ⇐ S ⟨ # "⟨LowerNames¨,⊢⟩_MetaParse desc ≍˘˜ MapStructNames name
    #•Show name
    #•Show aliasAfterStructs←⊑¨⊢˝¨aliases
    #•Show 1↓⥊nl∾˘""‿" ⇐ "‿" # "⟨LowerNames¨,LowerNames¨MapArgTypes,⊢⟩_MetaParse ⌽⌾(2⊸↑)˘>aliases
    body ← ∨`⌾⌽∘≠⟜' '⊸/¨<˘⟨""⟩⟨ParseStruct¨⟩_MetaParse ≍˘⊢˝¨¨fields
    ∾nl⊸((⊢-˜+`×¬)∘=⊔⊢)¨ body ∾˜¨header
  }
  ⟨""⟩
  { # enums
    [name,description,values]←⍉>enums
    header ← name LowerNames⊸∾¨<˘" ⇐ { # "⊸∾˘Box description
    body   ← (⥊(nl∾"  ")‿" ⇐ "‿"  # "⟨LowerNames¨,•Repr¨,⊢⟩_MetaParse·>1⊸⊏¨)¨values
    ∾nl⊸((⊢-˜+`×¬)∘=⊔⊢)¨ header∾¨∾⟜nl‿'}'¨body
  }
  ⟨""⟩
  { # functions
    # ⍉[name, description, returnType, params]:
    <˘""‿" ⇐ "‿""""‿" _R⟨"‿"#"‿" # "⟨
      LowerNames¨ ⋄ MapFuncReturnType ⋄ ∾⟜'"'¨ ⋄ ('⟩'∾˜1↓·∾'⋄'∾¨MapArgTypes)¨ ⋄ (∾' '⊸∾¨)¨ ⋄ ⊢
    ⟩_MetaParse{
      0‿2‿0‿3‿4‿1⊏(3↑𝕩)∾⍉{<˘⍉∘‿2⥊⊢˝˘>⊑𝕩}˘⊢˝𝕩
    }⌾⍉>∾⟜(<⟨⟩)⍟(3=≠)¨functions
  }
⟩
#•file.Remove raylibTempLoc
