# Tests are very undeveloped.
# This file may be turned into a testing directory when it gets bigger.
# Catagories are seperated by 2 newlines.

# all tests successful as of june 13. 2023

# Raymath:
⟨
  MatrixRotate, Wrap, Normalize, Vector3Unproject, MatrixRotateZ, MP, _ToDim_, Approx, MatrixExtend, Round
⟩ ← •Import "raymath.bqn"


e←"Round"
e!100.2131≡4 Round 100.21312344123


e↩"MatrixRotate"
e!(•Repr 5 Round MatrixRotate 0 ‿0‿1⋈¯21) ≡ "(3‿3⥊¯0.54773‿0.83666‿0‿¯0.83666‿¯0.54773‿0‿0‿0‿1)"
e!(•Repr 5 Round MatrixRotate 0 ‿1‿0⋈ 45) ≡ "(3‿3⥊0.52532‿0‿0.8509‿0‿1‿0‿¯0.8509‿0‿0.52532)"
e!(•Show •Repr 5 Round MatrixRotate 21‿3‿4⋈ 45) ≡ "(3‿3⥊0.97453‿¯3.33944‿2.63827‿3.46779‿0.53449‿¯17.85675‿¯2.46715‿17.8812‿0.54162)"

e↩"Wrap"
e!31 ≡ Wrap 210‿21‿200

e↩"Normalize"
e!0.5≡0‿2 Normalize 1

e↩"Vector3Unproject"
mat ← [
  1‿2‿3‿4
  5‿6‿7‿8
  9‿1‿2‿3
  4‿5‿6‿9
]
mat2 ← [
  11‿12‿13‿14
  15‿16‿17‿18
  19‿11‿12‿13
  14‿15‿16‿19
]
s ← 1‿2‿3
•SHow Vector3Unproject s‿mat‿mat2
# { 0.495726, -23.222216, 20.034185 }

e↩"MatrixRotateZ"
x←[
  1‿0‿0‿2
  0‿1‿0‿2
  0‿0‿1‿2
  0‿0‿0‿1
]

y ← MatrixRotateZ π
c ← x MP _ToDim_ 4 y
•SHow Approx c


•Show 3 MatrixExtend 2‿2⥊↕4


# raylib.bqn

⟨⟨_FromCenter⟩⇐utils⟩←•Import "../raylib.bqn"
e↩"_FromCenter"
e!(•Repr 5 Round 2⊸×_FromCenter[10‿15⋄15‿20⋄20‿25]) ≡ "(3‿2⥊7.5‿17.5‿12.5‿22.5‿17.5‿27.5)"
e!(•Repr 5 Round 2⊸×_FromCenter[10‿15‿15⋄15‿20‿20]) ≡ "(2‿3⥊6.66667‿16.66667‿16.66667‿11.66667‿21.66667‿21.66667)"





# testing (moved later to testing.bqn)
#•Show 1‿2‿3 Vector3OrthoNormalize 4‿5‿6

#•Show (-5+↕4) QuaternionEquals 5+↕4
#•Show (-4+↕4) QuaternionEquals 5+↕4

# raylib additions
# in MatrixOrtho please put x+b in the same order as x-b
# QuaternionToAxisAngle use epsilon
# reorder MatrixRotateXYZ's z y x to x y z at the top
# in quaternioninvert it seems the first index shouldn't be negated
# useless fabsf in QuaternionSlerp

# 1⊸-⌾(×˜) → (Sin Cos⁼)
# -⟜1⌾(×˜) → (Cos Sin⁼)
#Sin‿Cos←•math
#•Show (Cos Sin⁼)⍟ •Show •math.Cos 1
#•Show •math.Sin 2
#•Show 1⊸-⌾(×˜)
#Sin Cos⁼

# cos‿sin←•math
# •Show Vector3RotateByAxisAngle ⟨↕3, 0‿1‿0, 1⟩
# # ⟨ 1.682941969615793 1 1.0806046117362795 ⟩

#•Show 0.2‿0.5 (Vector2Angle=○•Show Vector3Angle) 0.2‿0.5

#•Show +´⌾(×˜)•Show VectorClampValue ⟨2‿2‿2‿2,10,22⟩
#•Show +´⌾(×˜)•Show VectorClampValue ⟨2‿2‿2‿2,30,42⟩
#•Show +´⌾(×˜)•Show VectorClampValue ⟨2‿2‿2‿2,0.5,1.5⟩

#mat ← (MatrixRotateZ π)MP MatrixTranslate 2‿2‿2
#•Show mat⊸MP⌾(∾⟜1)1‿2‿3

#•Show mat MP 1‿2‿3‿1
#F←{
#  a‿b←(<·⌈´≢¨«¨·<1⥊˜·⌈´=¨)⊸(↑¨)𝕩‿𝕨
#  d←-|𝕩-○≠𝕨
#  MP´1¨⌾(0‿0⍉(d⥊˜=𝕩)⊸↑)¨a‿b
#}
#•Show (2‿2⥊1)F 3‿3⥊1
## ┌─       
## ╵ 2 2 1  
##   2 2 1  
##   2 2 1  
##         ┘


#•Show 2+1‿2‿3


#•Show¨ Approx MatrixRotateX¨ (π÷2)×↕4
#•Out 3⥊"
#"
#•Show¨ Approx MatrixRotateY¨ (π÷2)×↕4
#•Out 3⥊"
#"
#•Show¨ Approx MatrixRotateZ¨ (π÷2)×↕4
#
#•Show =⌜˜↕2
#•Show ¯1‿1×⌽=⌜˜↕2
#a←π÷2
#mat←•SHow a×¯1‿1×⌽=⌜˜↕2
#•Show Approx +´{𝕊:(•math.Fact𝕩)÷˜MP⍟(𝕩-1)˜mat}¨↕200
#•Show Approx [⟨Cos a,-Sin a⟩,⟨Sin a, Cos a⟩]



#•Show =´Approx ⟨
#  1‿2 VectorAngle 3‿4
#  deg2rad × 10.304
#⟩
#•Out""
#•Show =´Approx ⟨
#  1‿2‿3 VectorAngle 2‿3‿4
#  deg2rad × 6.98
#⟩
#•Show =´Approx ⟨
#  1‿2‿3 Vector3Angle 2‿3‿4
#  deg2rad × 6.98
#⟩
#•Out""
#•Show =´Approx ⟨
#  1‿2‿3‿4 VectorAngle 5‿6‿7‿8
#  deg2rad × 14.3352
#⟩



