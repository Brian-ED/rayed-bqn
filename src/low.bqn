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

null ⇐ ⟨⟩⋈˜⁼(@•FFI"*"‿"memcpy"‿"*:i8"‿"&i8"‿"u64"){𝔽}⟨8⥊0,⟨⟩,0⟩

IsNull ⇐ (@•FFI"*:i8"‿"memcpy"‿"*"‿"&i8"‿"u64"){
  (8⥊0)≡⟨⟩⋈˜⁼𝔽⟨𝕩,⟨⟩,0⟩
}

# NumCount 𝕊 pointer # turn data at pointer into a number array
MakeF32 ⇐ (@•FFI"*:i8"‿"memcpy"‿"&f32"‿"*i8"‿"u64"){
  bytes←∘‿4⥊𝕩 Make˜ 𝕨×4
  1⊑∘⊑˘𝔽∘{⟨0⟩‿𝕩‿4}˘bytes
}

F32ToI8 ⇐ (@•FFI"*:i8"‿"memcpy"‿"&i8"‿"*f32"‿"u64"){1⊑𝔽⟨(4×≠𝕩)⥊0, 𝕩, 4×≠𝕩⟩}


# Note, raylib.MemAlloc should be used as Alloc with raylib.
GetFnsNeedingAlloc ⇐ {𝕊alloc:
  ⟨ AllocCStr ⟩⇐

  # Returns pointer but also length because
  # length changes after converting to UTF8
  # and getting length from the output with
  # low.StrLen is O(n).
  # It is also a good reminder to not assume
  # input string length is the C-string length.
  AllocCStr ⇐ {𝕊str:
    p ← (Alloc 1+≠str).Cast "u8"
    utfCStr ← @∾˜•ToUTF8 str
    len ← ≠utfCStr
    (↕len) p.Write¨ utfCStr-@
    ⟨len-1, p.Cast "i8:c8"⟩
  }
}
