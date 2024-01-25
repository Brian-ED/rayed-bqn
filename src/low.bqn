#------------------------------------------------------------------------------------
# BQN low-level function utils
#------------------------------------------------------------------------------------

# BQN Pointer functions
# neccesary for low level programming in bqn
MovePtr  ⇐ (256⋆↕8){-⟜(256×≥⟜128)256|⌊𝕗÷˜𝕨+´𝕗×256|𝕩}       #      bytes 𝕊 pointer # Move pointer by an amount of bytes
read     ⇐ @•FFI ""   ‿"bqn_readI8Arr"  ‿"𝕨>a"    ‿">*:i8" #       data 𝕊 pointer # write data to pointer
readi8   ⇐ read
readI16  ⇐ @•FFI ""   ‿"bqn_readI16Arr" ‿"𝕨>a"    ‿">*:i8" #       data 𝕊 pointer # write data to pointer
readI32  ⇐ @•FFI ""   ‿"bqn_readI32Arr" ‿"𝕨>a"    ‿">*:i8" #       data 𝕊 pointer # write data to pointer
make     ⇐ @•FFI "a"  ‿"bqn_makeI8Vec"  ‿"𝕨>u64"  ‿">*:i8" # bytesCount 𝕊 pointer # turn data at pointer into a number array
makeI8   ⇐ make
makeI16  ⇐ @•FFI "a"  ‿"bqn_makeI16Vec" ‿"𝕨>u64"  ‿">*:i8" # bytesCount 𝕊 pointer # turn data at pointer into a number array
makeI32  ⇐ @•FFI "a"  ‿"bqn_makeI32Vec" ‿"𝕨>u64"  ‿">*:i8" #   NumCount 𝕊 pointer # turn data at pointer into a number array
makeUTF8 ⇐ @•FFI "a"  ‿"bqn_makeUTF8Str"‿"𝕨>u64"  ‿">*:i8" #     length 𝕊 pointer # turn string at pointer into a bqn string
strLen   ⇐ @•FFI "i32"‿"strlen"         ‿">*:i8"           #            𝕊 pointer # length of unicode C-string

# NumCount 𝕊 pointer # turn data at pointer into a number array
MakeF32 ⇐ (@•FFI"*:i8"‿"memcpy"‿"&f32"‿"*i8"‿"u64"){
  bytes←∘‿4⥊𝕩 Make˜ 𝕨×4
  1⊑∘⊑˘𝔽∘{⟨0⟩‿𝕩‿4}˘bytes
}

# NumCount 𝕊 pointer # turn data at pointer into a number array
U32ToI8 ⇐ ⟨@•FFI"*:i8"‿"memcpy"‿"&i32"‿"*u32"‿"u64",@•FFI"*:i8"‿"memcpy"‿"&u32"‿"*i32"‿"u64"⟩{
  𝔽_𝕣𝕩:F‿·←𝕗⋄⟨32‿'i'⋄8‿'i'⟩•bit._cast 1⊑F⟨0⟩‿⟨𝕩⟩‿4
;
  𝔽_𝕣⁼𝕩:·‿F←𝕗⋄⊑1⊑F{⟨0⟩‿𝕩‿4} ⟨8‿'i'⋄32‿'i'⟩•bit._cast 𝕩
}