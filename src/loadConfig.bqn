# Default paths
raylibPath ⇐ •file.At {
  𝕊"windows": "../raylib/lib/raylib.dll"
; 𝕊"linux":   "/usr/local/lib/libraylib.so" 
;             "/usr/local/lib/libraylib.so" 
} •platform.os

bqnLibsPath ⇐ •file.At "imports/bqn-libs"

•FChars⟜""⍟(¬•file.Exists) "../config.txt"

{
  "raylibPath"  𝕊𝕩:raylibPath ↩•file.At"../"•file.At 1↓𝕩;
  "bqn-libsPath"𝕊𝕩:bqnLibsPath↩•file.At"../"•file.At 1↓𝕩
}´¨+`∘=⟜':'⊸⊔¨•FLines "../config.txt"