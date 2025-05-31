⟨raylib⟩ ← •Import "../../../rayed.bqn"
{
  data ← •FBytes 𝕩
  p‿⟨s⟩ ← raylib.CompressDataRef⟨data,≠data,⋈0⟩
  d ← (p.Cast "u8").Read¨↕s
  (𝕩∾".comp") •FBytes d
}¨"Map__5_Normal_Bump.png"‿"RubberDuck_LOD0.obj"
