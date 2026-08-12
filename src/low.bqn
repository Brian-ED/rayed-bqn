#------------------------------------------------------------------------------------
# BQN low-level function utils
#------------------------------------------------------------------------------------

# BQN Pointer functions
# useful for low level programming in bqn

# turn UTF-8-encoded string at pointer 𝕩 to BQN string,
# with 𝕨 bytes if given or null terminated if not
MakeUTF8 ⇐ {
  𝕨 { 𝕊𝕩: •foreign.ReadCharsTo0𝕩
    ;𝕨𝕊𝕩: •FromUTF8 𝕩.ReadList𝕨
  } 𝕩.Cast"i8"
}

# NumCount 𝕊 pointer # turn data at pointer into a number array
MakeF32 ⇐ (@•FFI"*:i8"‿"memcpy"‿"⥊f32"‿"*i8"‿"usize"){1⊑𝔽 ⟨𝕨, 𝕩, 𝕨×4⟩}

# 𝕊 pointer # length of unicode C-string
strLen ⇐ @•FFI "usize"‿"strlen"‿">*"

nullI8 ⇐ •foreign.null.Cast "i8"
IsNull ⇐ {0 = nullI8.Sub 𝕩.Cast "i8"}

F32ToI8 ⇐ (@•FFI"*:i8"‿"memcpy"‿"⥊i8"‿"*f32"‿"usize"){1⊑𝔽⟨4×≠𝕩, 𝕩, 4×≠𝕩⟩}

# Note, raylib.MemAlloc should be used as Alloc with raylib.
GetFnsNeedingAlloc ⇐ {𝕊alloc:
  # It is also a good reminder to not assume
  # input string length is the C-string length.
  AllocCStr ⇐ {𝕊str:
    p ← (Alloc ≠𝕩).Cast "i8:c8"
    p.WriteList 𝕩
    ⟨¯1+≠𝕩, p⟩
  } @∾˜•ToUTF8
}
