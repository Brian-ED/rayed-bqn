⟨MovePtr⋄Alloc⇐MemAlloc⋄Modify⇐Read⋄Make⋄MakeUTF8⋄StrLen⋄MemFree⟩ ← rayffi ← •Import "../../rayffi.bqn"
### make sure all inputs are i8
### and make sure to add error message for rank and depth requirement
_asPtr ← {
  (size⥊0) Modify ptr ← Alloc size←≠𝕩

  Set ← {𝕨𝕊elements:
    index ← 𝕨⊣0
    "Elements has to be a list"!(≡∧=)𝕩
    "Elements have to be ints"!⌈⊸≡𝕩
    "Writing out of bounds"!size≥index+≠𝕩
    𝕩 Modify index MovePtr ptr
  }
  Show ← {𝕤
    size Make ptr
  }

  r←{
    ref⇐ptr
    Set⇐Set
    size⇐size
    Show⇐Show
  }
  𝔽 r
  Free ← {𝕤
    MemFree ptr
    ptr↩@ ⋄ size↩@
    Show↩"Can't show freed memory"⊸!
    Set↩"Can't set freed memory"⊸!
    Free↩"Already Freed"⊸!
    @
  }
}

memCopyI8ToF32 ← @•FFI"*:i8"‿"memcpy"‿"&f32"‿"*i8"‿"u64"
memCopyF32ToI8 ← @•FFI"*:i8"‿"memcpy"‿"&i8"‿"*f32"‿"u64"

#x← •Show "f32"‿"f64"Construct 0‿0‿¯128‿63‿0‿0‿0‿0‿0‿0‿0‿64‿0‿0‿64‿64‿0‿0‿0‿0‿0‿0‿16‿64‿0‿0‿¯128‿64‿0‿0‿0‿0‿0‿0‿24‿64
#•Show "f32"‿"f64" Construct⁼ x

#•Show ⟨64‿'f'⋄1‿'u'⟩•bit._cast ⟨1⟩
#•Show •Repr⟨64‿'f'⋄32‿'i'⟩•bit._cast⟨2⟩
#•Show •Repr⟨64‿'f'⋄32‿'i'⟩•bit._cast⟨6⟩

# •Show ⟨1‿'u'⋄32‿'i'⟩•bit._cast ⌽"00111111100000000000000000000000"-'0'

#len ← 3
#ptr ← rayffi.MemAlloc len×4+8
#
#⟨
#  0,0,¯128,63 ⋄ 0,0,0,0,0,0, 0,64 
#  0,0,  64,64 ⋄ 0,0,0,0,0,0,16,64
#  0,0,¯128,64 ⋄ 0,0,0,0,0,0,24,64
#⟩ rayffi.Read ptr
#MemFree ptr

ScalerTypeSize ← {
  '*'≡⊑𝕩?64
;
  "["≡⊑𝕩?
    (𝕊𝕩↓˜2+b)×•ParseFloat 𝕩/˜b←∧`(1↓𝕩)∊'0'+↕10
;
  •ParseFloat 𝕩/˜∧`⌾⌽𝕩∊'0'+↕10
}∧`∘≠⟜':'⊸/

StructSize ← {
  flat ← {1=≡𝕩?ScalerTypeSize𝕩;𝕊¨⍟(1<≡)𝕩}{F𝕩:{F¨⌾((2≤≡¨𝕩)⊸/)𝕩}"*:i8"¨⌾(('*'≡¨⊑¨𝕩)⊸/)𝕩}𝕩
}

Cast ← {
  ⟨from⋄32‿'f'⟩𝕊𝕩:
    bytes ← ∘‿4⥊from‿8•bit._cast 𝕩
    {⊑1⊑MemCopyI8ToF32⟨0⟩‿𝕩‿4}˘bytes
;
  ⟨from⋄8‿'u'⟩𝕊𝕩:
    256|from‿8•bit._cast 𝕩
;
  ⟨32‿'f'⋄to⟩𝕊𝕩:
    8‿to •bit._cast 1⊑MemCopyF32ToI8⟨0⥊˜4×≠𝕩⋄𝕩⋄4⟩
;
  (𝕨⊸{"type "∾(•Repr 𝕩¬⊸/𝕨)∾" not supported"}!∧´)𝕨∊⟨1‿'u', 8‿'i', 16‿'i', 32‿'i', 64‿'f', 8‿'c', 16‿'c', 32‿'c', 8, 16, 32⟩
  𝕨•bit._cast𝕩
}

Construct ← {
  𝕊⁼:
    widths ← StructSize 𝕨
    types ← ⊑¨𝕨
    ∾⥊(widths(8‿'i'⋈˜∾)¨types)(Cast¨)⎉1⋈¨𝕩
;
  widths ← StructSize 𝕨
  types ← ¯1⊑⚇1{-+´∧`⌾⌽𝕩∊'0'+↕10}⊸↓⚇1{F𝕩:{F¨⌾((2≤≡¨𝕩)⊸/)𝕩}"*:i8"¨⌾(('*'≡¨⊑¨𝕩)⊸/)𝕩}𝕨
  (widths(8⋈∾)¨types)⊸(⋈⁼∘Cast¨)˘((⊢/↕∘≠)widths÷8)⊸⊔˘⟨∘⋄8÷˜+´widths⟩⥊𝕩
}
CollapsePtrs ← {𝕤{𝕎¨⌾((2≤≡¨𝕩)⊸/)𝕩}"*:i8"¨⌾(('*'≡¨⊑¨𝕩)⊸/)𝕩}

rayffi.SetTraceLogLevel rayffi.traceLogLevel.warning # makes logs not output INFO: logs to stdOut

out‿⟨len⟩←rayffi.LoadModelAnimationsRef "/mnt/0AD47A53D47A414D/Users/brian/Persinal/Scripts/C/raylib/examples/models/resources/models/m3d/cesium_man.m3d"‿⟨0⟩
•Show out
data ← out rayffi.Make˜len×+´{(∾𝕊¨)⍟(1<≡)⥊𝕩} StructSize rayffi.modelAnimation

•Show a_int‿b_int←8‿32•bit._cast 8↑data
•Show ptr1 ← 8↑8↓data
•Show ptr2 ← 8↑16↓data
•Show u8_32 ← 256|32↑24↓data
•Show  32↓24↓data

•Show "*{i32,i32,*:i8,*:i8,[32]u8}"
rayffi.UnloadModelAnimation a_int‿b_int‿ptr1‿ptr2‿u8_32
•Show 3 rayffi.Make ptr1
#•Show CollapsePtrs rayffi.modelAnimation
#•Show rayffi.modelAnimation Construct data
