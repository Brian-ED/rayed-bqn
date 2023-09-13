# Tests are very undeveloped.
# This file may be turned into a testing directory when it gets bigger.
# Catagories are seperated by 2 newlines.

# all tests successful as of june 13. 2023

# Raymath:
⟨
  MatrixRotate, Wrap, Normalize, Vector3Unproject, MP, _ToDim_, MatrixExtend, Round
  QuaternionEquals, Vector3OrthoNormalize, Vector3RotateByAxisAngle, VectorClampValue
  MatrixTranslate, MatrixRotateX, MatrixRotateY, MatrixRotateZ, VectorAngle, deg2rad, rad2deg
  Vector3Angle
⟩ ← •Import "raymath.bqn"

Approx ← 5⊸Round

e←"Round"
e!100.2131≡4 Round 100.21312344123


e↩"MatrixRotate"
e!(•Repr Approx MatrixRotate 0 ‿0‿1⋈¯21) ≡ "(3‿3⥊¯0.54773‿0.83666‿0‿¯0.83666‿¯0.54773‿0‿0‿0‿1)"
e!(•Repr Approx MatrixRotate 0 ‿1‿0⋈ 45) ≡ "(3‿3⥊0.52532‿0‿0.8509‿0‿1‿0‿¯0.8509‿0‿0.52532)"
e!(•Repr Approx MatrixRotate 21‿3‿4⋈ 45) ≡ "(3‿3⥊0.97453‿¯3.33944‿2.63827‿3.46779‿0.53449‿¯17.85675‿¯2.46715‿17.8812‿0.54162)"

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
e!(•Repr Approx Vector3Unproject s‿mat‿mat2) ≡ "0.49573‿¯23.22222‿20.03419"

e↩"MatrixRotateZ"
x←[
  1‿0‿0‿2
  0‿1‿0‿2
  0‿0‿1‿2
  0‿0‿0‿1
]
y ← MatrixRotateZ π
c ← x MP _ToDim_ 4 y
e!(•Repr Approx c) ≡ "(4‿4⥊¯1‿0‿0‿2‿0‿¯1‿0‿2‿0‿0‿1‿2‿0‿0‿0‿1)"

e↩"MatrixExtend"
e!(•Repr 3 MatrixExtend 2‿2⥊↕4) ≡ "(3‿3⥊0‿1‿0‿2‿3‿0‿0‿0‿1)"

e↩"Vector3OrthoNormalize"
e!(•Repr Approx 1‿2‿3 Vector3OrthoNormalize 4‿5‿6) ≡ "0.87287‿0.21822‿¯0.43644"
e!((-5+↕4) QuaternionEquals 5+↕4)≡1
e!((-4+↕4) QuaternionEquals 5+↕4)≡0

e↩"Vector3RotateByAxisAngle"
e!(•Repr Vector3RotateByAxisAngle ⟨↕3, 0‿1‿0, 1⟩) ≡ "1.682941969615793‿1‿1.0806046117362795"

e↩"VectorClampValue"
e!(•Repr +´⌾(×˜)⊸⋈ VectorClampValue ⟨2‿2‿2‿2,10,22⟩) ≡ "⟨10,5‿5‿5‿5⟩"
e!(•Repr +´⌾(×˜)⊸⋈ VectorClampValue ⟨2‿2‿2‿2,30,42⟩) ≡ "⟨30,15‿15‿15‿15⟩"
e!(•Repr +´⌾(×˜)⊸⋈ VectorClampValue ⟨2‿2‿2‿2,0.5,1.5⟩) ≡ "⟨1.5,0.75‿0.75‿0.75‿0.75⟩"

e↩"MatrixRotateX"
e!(•Repr Approx ∾MatrixRotateX¨ (π÷2)×↕4) ≡ "(12‿3⥊1‿0‿0‿0‿1‿0‿0‿0‿1‿1‿0‿0‿0‿0‿1‿0‿¯1‿0‿1‿0‿0‿0‿¯1‿0‿0‿0‿¯1‿1‿0‿0‿0‿0‿¯1‿0‿1‿0)"

e↩"MatrixRotateY"
e!(•Repr Approx ∾MatrixRotateY¨ (π÷2)×↕4) ≡ "(12‿3⥊1‿0‿0‿0‿1‿0‿0‿0‿1‿0‿0‿¯1‿0‿1‿0‿1‿0‿0‿¯1‿0‿0‿0‿1‿0‿0‿0‿¯1‿0‿0‿1‿0‿1‿0‿¯1‿0‿0)"

e↩"MatrixRotateZ"
e!(•Repr Approx ∾MatrixRotateZ¨ (π÷2)×↕4) ≡ "(12‿3⥊1‿0‿0‿0‿1‿0‿0‿0‿1‿0‿1‿0‿¯1‿0‿0‿0‿0‿1‿¯1‿0‿0‿0‿¯1‿0‿0‿0‿1‿0‿¯1‿0‿1‿0‿0‿0‿0‿1)"

e↩"MatrixRotateZ AND MatrixTranslate"
mat ↩ (MatrixRotateZ π)MP _ToDim_ 4 MatrixTranslate 2‿2‿2
e!(•Repr Approx mat⊸MP⌾(∾⟜1)1‿2‿3) ≡ "¯3‿¯4‿5"

e↩"VectorAngle"
e!(•Repr Approx 1‿2 VectorAngle 3‿4) ≡ "0.17985"
e!(•Repr Approx 1‿2‿3‿4 VectorAngle 5‿6‿7‿8) ≡ "0.2502"
e!(•Repr Approx 1‿2‿3 VectorAngle  2‿3‿4) ≡ "0.12187"

e↩"Vector3Angle"
e!(•Repr Approx 1‿2‿3 Vector3Angle 2‿3‿4) ≡ "0.12187"

e↩"Vector3Angle isn't same as VectorAngle"
e!1‿2‿3 (VectorAngle ≡○Approx Vector3Angle) 2‿3‿4

# raylib.bqn

⟨⟨_FromCenter⟩⇐utils⟩←•Import "../raylib.bqn"
e↩"_FromCenter"
e!(•Repr Approx 2⊸×_FromCenter[10‿15⋄15‿20⋄20‿25]) ≡ "(3‿2⥊7.5‿17.5‿12.5‿22.5‿17.5‿27.5)"
e!(•Repr Approx 2⊸×_FromCenter[10‿15‿15⋄15‿20‿20]) ≡ "(2‿3⥊6.66667‿16.66667‿16.66667‿11.66667‿21.66667‿21.66667)"


•Show "Tests passed"