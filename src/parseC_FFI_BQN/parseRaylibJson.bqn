## Metaprogram rayffi.bqn automatically.

ffiUtilsPath←⊑•args∾<"../ffiUtils.bqn"

raylibJsonTempLoc ← •file.At "inp-out/raylib.json"
outputLocation ← •file.At "../../rayffi.bqn"
binLocation ← •file.At"a.out"

# util functions
nl ← @+10 # newline
Box ← ⟨⟩⊸≡◶⟨>⋄↕0‿0⟩⊢»¨⟜<' '⥊˜·⌈´≠¨
LowerNames ← +⟜(32×1="A["⊸⍋)⌾(1↑⎉1⊢)
_MetaParse ← {∾˘´[𝕗,𝕨]{F‿w𝕊𝕩:<w⊸∾˘Box F𝕩}˘○⍉𝕩}
SHErr ← {exitcode‿stdout‿stderr←•SH𝕩
  •Out stdout
  stderr!0=exitcode
}

# imports
⟨raylibPath⟩ ← •Import "../loadConfig.bqn"
json ← •Import "../imports/bqn-libs/json.bqn"

# getting raylib.h path
raylibHeaderPath ← "include/raylib.h"∾˜"lib/"∾˜⁼{𝕩↓˜-⊑⊐⟜1⌽'/'=𝕩}raylibPath
(•file.Exists raylibHeaderPath)!˜"raylib header file expected at "∾raylibHeaderPath

# compile c parser if non existant
SHErr ⟨"cc"⋄•file.At"raylib_parser.c"⋄"-o"⋄binLocation⟩
SHErr binLocation‿"-i"‿raylibHeaderPath‿"-f"‿"JSON"‿"-o"‿raylibJsonTempLoc
•file.Remove binLocation

#raygui:
#cc raylib_parser.c && ./a.out -i ./inp-out/raygui.c -f JSON -o ./inp-out/raygui.json && rm ./a.out
#raylib: 
#cc raylib_parser.c && ./a.out -i ./inp-out/raylib.h -f JSON -o ./inp-out/raylib.json && rm ./a.out

remap ← {𝕎𝕏}´{(𝕨⊸≡∧"*"≡1↑⊣)◶⟨⋈⋄𝕩⋈˜1↓⊣⟩´}´¨⟨
  "unsigned char"  ‿"ustr"
  "char"           ‿"str"
  "void"           ‿"ptr"
  "rAudioBuffer"   ‿"ptr"
  "rAudioProcessor"‿"ptr"
⟩
constText←"const "
SwitchOrder ← {⌽⌾((𝕩∊'0'+↕10)⊸/)1⊸⌽⌾((𝕩∊"[]")⊸/)𝕩}⌽

shortendStructNames←[
  "v2"‿"Vector2"
  "v3"‿"Vector3"
  "v4"‿"Vector4"
]

typeReplacements ← ⍉shortendStructNames∾[
  # remove since they're not defined
  "ptr"‿"AudioCallback"
  "ptr"‿"LoadFileDataCallback"
  "ptr"‿"LoadFileTextCallback"
  "ptr"‿"SaveFileDataCallback"
  "ptr"‿"SaveFileTextCallback"
  "ptr"‿"TraceLogCallback"

  """f64"""‿"double"
  """i64"""‿"long"
  "f"      ‿"float"
  "i"      ‿"int"
  "ptr"    ‿"..."
  "u"      ‿"unsigned int"
  "u8"     ‿"char"
  "u8"     ‿"unsigned char"
  """u16"""‿"unsigned short"
  " "      ‿"void"
]

mapArgTypes ← {
  [bqn,c] ← typeReplacements
  {
    consts←constText⊸(⊣≡≠⊸↑)¨𝕩
    s ← ¬consts∨¬⊑¨'*'⊸∊¨𝕩
    cleaned←constText⊸∾⁼¨⌾(consts⊸/)𝕩
    [kept,removed] ← 2‿∘⥊⍉Remap⌾⌽˘> ∨`∘∊⟜"[*"⊸(¬⊸/¯1⊸↓⍟(" "≡¯1⊸↑)⊸⋈SwitchOrder∘/)¨cleaned
    AddRemoved ← {""𝕊𝕩:𝕩;'"'≡⊑𝕩?𝕨⊸∾⌾('"'⊸∾⁼)𝕩;'"'∾𝕨∾"""∾"∾𝕩}
    replaced ← kept LowerNames∘⊣⍟(0⊸≡)¨(c⊐kept)⊏bqn∾0
    removed AddRemoved¨ replaced
  }
}

MapStructTypes ← {
  [bqn,c] ← typeReplacements
  consts←constText⊸(⊣≡≠⊸↑)¨𝕩
  s ← ¬consts∨¬⊑¨'*'⊸∊¨𝕩
  cleaned←constText⊸∾⁼¨⌾(consts⊸/)𝕩
  [kept,removed] ← 2‿∘⥊⍉Remap⌾⌽˘> ∨`∘∊⟜"[*"⊸(¬⊸/¯1⊸↓⍟(" "≡¯1⊸↑)⊸⋈SwitchOrder∘/)¨cleaned
  AddRemoved ← {""𝕊𝕩:𝕩;'"'≡⊑𝕩?𝕨⊸∾⌾('"'⊸∾⁼)𝕩;'"'∾𝕨∾"""∾"∾𝕩}
  replaced ← kept LowerNames∘⊣⍟(0⊸≡)¨(c⊐kept)⊏bqn∾0
  removed AddRemoved¨ replaced
}

mapStructNames ← {
  [bqn,c]←⍉shortendStructNames
  {𝕩LowerNames∘⊣⍟(0⊸≡)¨(c⊐𝕩)⊏bqn∾0}
}

_Time ← {•Show 𝔽•_timed𝕩⋄𝔽𝕩}
mapFuncReturnType ← {
  [bqn,c] ← typeReplacements
  {
    cleaned←𝕩↓˜¨constText≠⊸×constText⊸(⊣≡≠⊸↑)¨𝕩
    [kept,removed] ← 2‿∘⥊⍉Remap⌾⌽˘> ∨`∘∊⟜"[*"⊸(¬⊸/¯1⊸↓⍟(" "≡¯1⊸↑)⊸⋈SwitchOrder∘/)¨cleaned
    AddRemoved ← {""𝕊𝕩:𝕩;'"'≡⊑𝕩?𝕨⊸∾⌾('"'⊸∾⁼)𝕩;'"'∾𝕨∾"""∾"∾𝕩}
    replaced ← kept LowerNames∘⊣⍟(0⊸≡)¨(c⊐kept)⊏bqn∾0
    {'('∾𝕩∾')'}⍟(∨´"∾⊣"⊸∊)¨"ptr⊣"⊸∾⍟(("ustr"≡¯4⊸↑)∨∨´∘=⟜'*'∨"str"≡¯3⊸↑)¨ removed AddRemoved¨ replaced
  }
}

defines‿structs‿aliases‿enums‿callbacks‿functions←{
  x←json.Parse •FChars raylibJsonTempLoc
  !x⊣˝⊸≡"defines"‿"structs"‿"aliases"‿"enums"‿"callbacks"‿"functions"
  ⊢˝¨¨⌾(0‿1‿3‿4‿5⊸⊏)⊢˝x
}

outputLocation •FLines ∨`⌾⌽∘≠⟜' '⊸/¨∾⟨
  •FLines "topOfRayffi.bqn"
  ⋈""
  ⋈"⟨raylibPath⟩ ← •Import ""src/loadConfig.bqn"""
  ⋈"r ⇐ MakeImporter raylibPath"
  ⋈""
  { # defines
    exclTypes  ← "GUARD"‿"MACRO"‿"UNKNOWN"‿"FLOAT_MATH"‿"COLOR"
    Filter ← {𝕊name‿type‿val‿desc:
      ¬∨´⟨"PI"≡name, ∨´type⊸≡¨exclTypes, ⟨⟩≡val ⟩
    }
    filtered ← Filter˘⊸/>defines
    <˘""‿""‿" ⇐ "‿" # "⟨LowerNames¨,⟨⟩¨,•Repr¨,⊢⟩_MetaParse filtered
  }
  ⋈""
  { # enums
    [names,descriptions,values]←⍉>enums
    tabled ← >¨⊢˝¨¨ values
    prefixesRemoved ← {𝕩↓¨˜+´∧˝˘∧`(⊏=⍉)>𝕩↑¨˜⌊´≠¨𝕩}⌾(⊏˘)¨tabled
    bodys ← (<˘("  ")‿" ⇐ "‿"  # "⟨LowerNames¨,•Repr¨,⊢⟩_MetaParse⊢)¨prefixesRemoved
    headers ← names LowerNames⊸∾¨<˘" ⇐ { # "⊸∾˘Box descriptions
    ∾headers<⊸∾¨∾⟜⟨"}"⟩¨bodys
  }
  ⋈""
  { # structs
    [names,descriptions,fields]←⍉>structs
    headers ← (MapStructNames names) ∾⟜" ⇐ ⟨ # "⊸∾¨ descriptions
    bodys ← {⟨"⟩"⟩∾˜<˘"  "‿" # "‿"  # "⟨MapStructTypes,⊢,⊢⟩_MetaParse >𝕩}¨⊢˝¨¨fields
    assembled ← headers <⊸∾¨ bodys
    aliasLines←»⊸∨∘≠⟜' '⊸/¨<˘""‿" ⇐ "‿" # "⟨LowerNames¨,MapArgTypes,⊢⟩_MetaParse ⌽⌾(2⊸↑)˘>⊢˝¨aliases
    p←⊑¨⊢˝¨aliases
    ∾ ∾∾⟜(⋈⋈)¨⟜aliasLines⌾(¯1⊸↓)assembled⊔˜+`»+˝p≡⌜names
  }
  ⋈""
  { # functions
    #•Show¨⌾(330‿307⊸⊏)
    s ← {
      ((⊑'*'⊸∊)¨∧constText⊸(⊣≢≠⊸↑)¨)1‿0⊸⊑¨¯1⊑𝕩
    }¨∾⟜⟨⟨⟩⟩⍟(3=≠)¨functions
    sLines←∨´¨s

    s2 ← {
      "const void *"⊸≡¨1‿0⊸⊑¨¯1⊑𝕩
    }¨∾⟜⟨⟨⟩⟩⍟(3=≠)¨functions
    s2Lines←∨´¨s2
    !∧´¬s2Lines∧sLines # I don't want the lines to collide
    
    sAllLinesExtended ← (↕∘≠⊸+⌾/↑˜+´+≠)s2Lines∨sLines
    s1LinesExtended‿s2LinesExtended ← s2Lines{((+´+≠)𝕩+𝕨)↑𝕨⊸{((/𝕨)¬∘∊˜𝕩)/𝕩+↕≠𝕩}⌾/𝕨+𝕩}{𝔽⋈𝔽˜}sLines
    MakeConstDistinct ← (sAllLinesExtended¬⊸×(1+s2Lines∨sLines)/s+2×s2){'⟩'∾˜1↓∾'⋄'∾¨(⊑"ptr"‿"ustr"‿"str"⊐<)◶⟨"""&u8"""⋄"""&u8"""⋄"""&u8:c8"""⋄"""&"⊸∾"""*"⊸∾⁼⟩¨⌾((1=𝕨)⊸/)"""*i8"""¨⌾((2=𝕨)⊸/)𝕩}¨⊢

    <˘""‿" ⇐ "‿""""‿" _R⟨"‿"#"‿" # "⟨
      ∾⟜"Raw"¨⌾((»s2LinesExtended)⊸/)·∾⟜"Ref"¨⌾((»s1LinesExtended)⊸/)LowerNames¨ ⋄ MapFuncReturnType ⋄ ∾⟜'"'¨ ⋄ MakeConstDistinct MapArgTypes¨ ⋄ (∾' '⊸∾¨)¨ ⋄ ⊢
    ⟩_MetaParse{
      0‿2‿0‿3‿4‿1⊏(3↑𝕩)∾⍉{<˘⍉∘‿2⥊⊢˝˘>⊑𝕩}˘⊢˝𝕩
    }⌾⍉(1+s2Lines∨sLines)/>∾⟜⟨⟨⟩⟩⍟(3=≠)¨functions
  }
⟩
•file.Remove raylibJsonTempLoc
