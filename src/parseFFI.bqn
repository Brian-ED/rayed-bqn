## Metaprogram ffi automatically.

# imports
⟨raylibLibPath
 raylibHeaderPath⟩ ← conf ← •Import "loadConfig.bqn"
json ← •Import "../imports/bqn-libs/json.bqn"
⟨ToFFI⋄ParseHeader⋄SetPath⟩ ← •Import "../imports/c-header-to-bqn-ffi/parse.bqn"

HasLibError    ← •file.Exists∘(".."⊸•file.At)!˜"Library file expected at "⊸∾∾" according to config.bqn"˙
HasHeaderError ← (•file.Exists∘(".."⊸•file.At)∧".h"⊸(⊣≡-∘≠⊸↑))!˜"Header file expected at "⊸∾∾" according to config.bqn"˙
HasPathsError ← {libPath𝕊headerPath:
  HasLibError libPath
  HasHeaderError headerPath
}

nl ← @+10

# Doesn't implement nested #if
⟨
  CPreProcessorLean
  CPreProcessorStrict
⟩ ← {g←𝕩⋄⟨1 _G⋄0 _G⟩}{{[bools⋄defines] doNotErrorOnMissingDefines _𝕣 charsOfHeader:
  split ← nl ((⊢-˜+`×¬)∘=⊔⊢) (@+13)⊸≠⊸/ 𝕩
  [if⋄endif] ← "#if "‿"#endif"(⊣≡≠⊸↑)⌜∨`∘≠⟜' '⊸/¨split
  1↓∾nl∾¨ ((∨`∧∨⟜«)⟨⟩⊸≢¨)⊸/ endif¬⊸/𝕗{
    parts ← 𝕩 ⊔˜ +` "#elif "⊸(⊣≡≠⊸↑)¨ ∨`∘≠⟜' '⊸/¨ 𝕩
    ifs ← ∨`⌾⌽∘≠⟜' '⊸/¨((⊐⟜1+·¬∨´)"//"⊸⍷)⊸↑¨ ∨`∘»∘=⟜' '⊸/¨ ∨`∘≠⟜' '⊸/¨⊑¨parts
    oob ← defines⊐ifs
    ("<#if> condition not defined in 𝕨 "∾•Repr ifs)!𝕗∨(≠defines)≢⌈´oob
    definedDefines←(oob⊏∾⟜0⍟𝕗 bools)/1↓¨parts
    (⊢∾⟨⟨⟩⟩⥊˜-˜○≠⟜𝕩)×∘≠◶⟨⟩‿⊑definedDefines
  }¨⌾(((+`∘<⟜»⊸×-¬) (1⌊0⌈+)`if-endif)⊸⊔)split
}}

ParseRaylib ← {libPath𝕊headerPath:
  𝕨 HasPathsError 𝕩
  "../ffi/raylib.bqn" •FChars libPath SetPath ToFFI "RLAPI" ParseHeader •FChars headerPath
  •Out "ffi/raylib.bqn successfully generated"
}

ParseRLGL ← {libPath𝕊headerPath:
  𝕨 HasPathsError 𝕩

  defines ← ⍉[
    0‿"defined(_WIN32) && defined(BUILD_LIBTYPE_SHARED)"
    0‿"defined(BUILD_LIBTYPE_SHARED)"
    0‿"!defined(GRAPHICS_API_OPENGL_11) && \"
    0‿"defined(GRAPHICS_API_OPENGL_11)"
    0‿"defined(GRAPHICS_API_OPENGL_21)"
    0‿"defined(GRAPHICS_API_OPENGL_43)"
    0‿"defined(GRAPHICS_API_OPENGL_ES3)"
    0‿"!defined(__cplusplus) && !defined(bool) && !defined(RL_BOOL_TYPE)"
    0‿"defined(GRAPHICS_API_OPENGL_ES2)"
    0‿"defined(__cplusplus)"
    0‿"defined(GRAPHICS_API_OPENGL_33)"
    0‿"defined(_WIN32) && defined(BUILD_LIBTYPE_SHARED)"
    0‿"defined(BUILD_LIBTYPE_SHARED)"
    0‿"defined(_WIN32) && defined(USE_LIBTYPE_SHARED)"
    0‿"(defined(__STDC__) && __STDC_VERSION__ >= 199901L) || (defined(_MSC_VER) && _MSC_VER >= 1800)"
    1‿"!defined(RL_MATRIX_TYPE)"
    1‿"defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)"
    0‿"defined(_WIN32)"
    0‿"defined(USE_LIBTYPE_SHARED)"
  ]

  nameMap ← ⍉[
    "RLGL_VERSION"‿"RLGL_VERSION_STRING"
  ]

  headerWMacros ← (⊐⟜1"RLGL IMPLEMENTATION"⊸⍷)⊸↑ •FChars "rlgl.h"∾˜•file.Name⊸(∾˜⁼) headerPath
  header ← defines CPreProcessorLean headerWMacros
  "../ffi/rlgl.bqn" •FChars libPath SetPath nameMap ToFFI "RLAPI" ParseHeader header
  •Out "ffi/rlgl.bqn successfully generated"
}

ParseRayGUI ← {libPath𝕊headerPath:
  𝕨 HasPathsError 𝕩
  headerAndCode ← •FChars headerPath
  header ← ¯91↓(1⊐˜"RAYGUI IMPLEMENTATION"⊸⍷)⊸↑headerAndCode
  "../ffi/raygui.bqn" •FChars libPath SetPath ToFFI "RAYGUIAPI" ParseHeader header
  •Out "ffi/raygui.bqn successfully generated"
}

raylibLibPath ParseRaylib raylibHeaderPath
raylibLibPath ParseRLGL "rlgl.h" •file.At˜ •file.Parent raylibHeaderPath
conf ParseRayGUI´∘(•ns.Get¨)⍟(∧´•ns.Has¨) "rayguilibpath"‿"rayguiheaderpath"