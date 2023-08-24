⟨MovePtr⋄Alloc⇐MemAlloc⋄Modify⇐Read⋄Make⋄MakeUTF8⋄StrLen⋄MemFree⟩ ← •Import "../rayffi.bqn"
### make sure all inputs are i8
### and make sure to add error message for rank and depth requirement
MakePtr ← {
  ⟨Set⋄Show⋄Free
   size⋄ptr⟩⇐
  (size⥊0) Modify ptr ← Alloc size ← 𝕩
  Set ⇐ {𝕨𝕊elements:
    index ← 𝕨⊣0
    "Elements has to be a list"!(≡∧=)𝕩
    "Elements have to be ints"!⌈⊸≡𝕩
    "Writing out of bounds"!size≥index+≠𝕩
    𝕩 Modify index MovePtr ptr
  }
  Show ← {𝕤
    size Make ptr
  }
  Free ← {𝕤
    MemFree ptr
    ptr↩@ ⋄ size↩@
    Show↩"Can't show freed memory"⊸!
    Set↩"Can't set freed memory"⊸!
    Free↩"Already Freed"⊸!
    @
  }
}
ptr ← MakePtr 5
•Show ptr.ptr

•Show ptr.Show@
3 ptr.Set 10‿10
ptr.Set 10‿10
•Show ptr.Show@
ptr.Free@