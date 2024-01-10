## Metaprogram rayffi.bqn automatically.

# imports
⟨raylibPath⟩ ← conf ← •Import "loadConfig.bqn"
json ← •Import "imports/bqn-libs/json.bqn"
⟨ToFFI⋄ParseHeader⟩ ← •Import "imports/c-header-to-bqn-ffi/parse.bqn"

ParseRayFFI ← {𝕊binPath‿headerPath:
  (•file.Exists binPath)!˜"Library file expected at "∾binPath
  (•file.Exists headerPath)!˜"Header file expected at "∾headerPath
  header ← •FChars headerPath
  "../rayffi.bqn" •FChars binPath ToFFI "RLAPI" ParseHeader header
  •Out "rayffi.bqn successfully generated"
}

ParseRayGUI ← {𝕊binPath‿headerPath:
  (•file.Exists binPath)!˜"Library file expected at "∾binPath
  (•file.Exists headerPath)!˜"Header file expected at "∾headerPath
  headerAndCode ← •FChars headerPath
  header ← ¯91↓(1⊐˜"RAYGUI IMPLEMENTATION"⊸⍷)⊸↑headerAndCode
  "raygui.bqn" •FChars binPath ToFFI "RAYGUIAPI" ParseHeader header
  •Out "raygui.bqn successfully generated"
}

ParseRayFFI ⋈⟜{"include/raylib.h"∾˜"lib/"∾˜⁼𝕩↓˜-⊑⊐⟜1⌽'/'=𝕩} raylibPath
ParseRayGUI∘(conf⊸•ns.Get¨)⍟(∧´conf⊸•ns.Has¨) "rayguilibpath"‿"rayguiheaderpath"