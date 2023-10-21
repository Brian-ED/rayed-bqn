⟨
  MakeImporter # Makes an importer that improves the ffi function creation syntax
  P  # '*' means a pointer
  S  # Parse types into one struct

  # predefined C types
  i‿f‿u‿c‿i8‿bool‿u8‿str‿uStr‿ptr # i, f, and u are 32 sized, c is 8, str, ustr and ptr are 8 per char
  quaternion # quaternion isn't defined sometimes in c header files yet still used, so keeping this here makes my life easier
⟩⇐

# Makes an importer that improves the ffi function creation syntax
MakeImporter ⇐ {𝕨𝕊path: debug←𝕨⊣0
  {𝕨 funcName _𝕣 inpTypes: outType←𝕨⊣⟨⟩
    a←(⋈'>'⊸∾)⍟(×∘≠∧1=≡)@⟨⟩⍟≡𝕩
    HandleError ← {
      •Out "DEBUG TYPE INFO:"
      •Out •Fmt 𝕩
      •Out "END OF DEBUG TYPE INFO; BEGINING WITH FULL ERROR:"
      •term.Flush@
      𝕨•FFI𝕩
    }
    func ← path •FFI⎊HandleError outType‿funcName∾a
    m ← str⊸≡¨a
    {𝕏⊣•term.Flush∘•Out∘funcName}⍟debug {𝕏∾⟜@}⍟(a≡⋈'>'∾str) {𝕏∾⟜@¨⌾(m⊸/)}⍟(∨´m) func
  }
}

P ⇐ '*'⊸∾             # '*' means a pointer
S ⇐ {'{'∾'}'«∾','∾¨𝕩} # Parse types into one struct

# predefined C types
c ⇐ "i8"
bool ⇐ "i8"
i‿f‿u‿i8‿·‿u8 ⇐ ⥊"32"‿"8"∾˜⌜"ifu"
str‿uStr ⇐ P¨"iu"∾¨<"8:c8"
ptr ⇐ "*:i8"

quaternion ⇐ "[4]f32"