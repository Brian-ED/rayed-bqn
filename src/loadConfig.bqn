# Default paths
raylibPath ⇐ •file.At "../raylib/lib/raylib.dll" 
bqnLibsPath⇐ •file.At "imports/bqn-libs"
{
  "raylibPath"  𝕊𝕩:raylibPath ↩•file.At"../"•file.At 1↓𝕩;
  "bqn-libsPath"𝕊𝕩:bqnLibsPath↩•file.At"../"•file.At 1↓𝕩
}´¨+`∘=⟜':'⊸⊔¨•FLines "../config.txt"