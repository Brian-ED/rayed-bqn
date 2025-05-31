⟨raylib⟩ ← •Import "../../../rayed.bqn"
compressedFiles ← "Map__5_Normal_Bump.png"‿"RubberDuck_LOD0.obj"
{
  data ← •FBytes 𝕩∾".comp"
  p‿⟨s⟩ ← raylib.DeCompressDataRef⟨data,≠data,⋈0⟩
  d ← (p.Cast "u8").Read¨↕s
  𝕩 •FBytes @+d
}¨compressedFiles
