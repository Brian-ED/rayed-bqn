## Metaprogram rayffi.bqn automatically.

# imports
⟨raylibPath⟩ ← •Import "loadConfig.bqn"
json ← •Import "imports/bqn-libs/json.bqn"
⟨JsonToFFI⋄ParseHeader⋄ToPrettyJson⟩ ← •Import "imports/c-header-to-bqn-ffi/parse.bqn"

outputLocation ← "../rayffi.bqn"

# getting raylib.h path
raylibHeaderPath ← "include/raylib.h"∾˜"lib/"∾˜⁼{𝕩↓˜-⊑⊐⟜1⌽'/'=𝕩}raylibPath
(•file.Exists raylibHeaderPath)!˜"raylib header file expected at "∾raylibHeaderPath

inp ← •FChars raylibHeaderPath

outputLocation •FChars JsonToFFI json.Parse ToPrettyJson "RLAPI" ParseHeader inp

•Out "rayffi.bqn successfully generated"