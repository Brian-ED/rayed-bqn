# Tests are very undeveloped.
# This file may be turned into a testing directory when it gets bigger.
# Catagories are seperated by 2 newlines.

# all tests successful as of june 13. 2023

# Raymath:
⟨
  MatrixRotate, Wrap, Normalize, Vector3Unproject, MP, _ToDim_, MatrixExtend, Round
  QuaternionEquals, Vector3OrthoNormalize, Vector3RotateByAxisAngle, VectorClampValue
  MatrixTranslate, MatrixRotateX, MatrixRotateY, MatrixRotateZ, VectorAngle, deg2rad, rad2deg
  SlopeInterceptToLine, DistanceToPlane

  # In progress 
    MatrixPerspective
  
    # These have been extensively tested against C versions
    MatrixOrtho
    MatrixLookAt, 
⟩ ← •Import "raymath.bqn"

Approx ← 5⊸Round

#region Raymath
e←"Round"
e!100.2131≡4 Round 100.21312344123

e↩"MatrixRotate"
e!(Approx MatrixRotate 0 ‿0‿1⋈¯21) ≡ 3‿3⥊¯0.54773‿0.83666‿0‿¯0.83666‿¯0.54773‿0‿0‿0‿1
e!(Approx MatrixRotate 0 ‿1‿0⋈ 45) ≡ 3‿3⥊0.52532‿0‿0.8509‿0‿1‿0‿¯0.8509‿0‿0.52532
e!(Approx MatrixRotate 21‿3‿4⋈ 45) ≡ 3‿3⥊0.97453‿¯3.33944‿2.63827‿3.46779‿0.53449‿¯17.85675‿¯2.46715‿17.8812‿0.54162

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
e!(Approx Vector3Unproject s‿mat‿mat2) ≡ 0.49573‿¯23.22222‿20.03419

e↩"MatrixRotateZ"
x←[
  1‿0‿0‿2
  0‿1‿0‿2
  0‿0‿1‿2
  0‿0‿0‿1
]
y ← MatrixRotateZ π
c ← x MP _ToDim_ 4 y
e!(Approx c) ≡ (4‿4⥊¯1‿0‿0‿2‿0‿¯1‿0‿2‿0‿0‿1‿2‿0‿0‿0‿1)

e↩"MatrixExtend"
e!(3 MatrixExtend 2‿2⥊↕4) ≡ (3‿3⥊0‿1‿0‿2‿3‿0‿0‿0‿1)

e↩"Vector3OrthoNormalize"
e!(Approx 1‿2‿3 Vector3OrthoNormalize 4‿5‿6) ≡ 0.87287‿0.21822‿¯0.43644
e!((-5+↕4) QuaternionEquals 5+↕4)≡1
e!((-4+↕4) QuaternionEquals 5+↕4)≡0

e↩"Vector3RotateByAxisAngle"
e!(Vector3RotateByAxisAngle ⟨↕3, 0‿1‿0, 1⟩) ≡ 1.682941969615793‿1‿1.0806046117362795

e↩"VectorClampValue"
e!(+´⌾(×˜)⊸⋈ VectorClampValue ⟨2‿2‿2‿2,10,22⟩) ≡ ⟨10,5‿5‿5‿5⟩
e!(+´⌾(×˜)⊸⋈ VectorClampValue ⟨2‿2‿2‿2,30,42⟩) ≡ ⟨30,15‿15‿15‿15⟩
e!(+´⌾(×˜)⊸⋈ VectorClampValue ⟨2‿2‿2‿2,0.5,1.5⟩) ≡ ⟨1.5,0.75‿0.75‿0.75‿0.75⟩

e↩"MatrixRotateX"
e!(Approx ∾MatrixRotateX¨ (π÷2)×↕4) ≡ (12‿3⥊1‿0‿0‿0‿1‿0‿0‿0‿1‿1‿0‿0‿0‿0‿1‿0‿¯1‿0‿1‿0‿0‿0‿¯1‿0‿0‿0‿¯1‿1‿0‿0‿0‿0‿¯1‿0‿1‿0)

e↩"MatrixRotateY"
e!(Approx ∾MatrixRotateY¨ (π÷2)×↕4) ≡ (12‿3⥊1‿0‿0‿0‿1‿0‿0‿0‿1‿0‿0‿¯1‿0‿1‿0‿1‿0‿0‿¯1‿0‿0‿0‿1‿0‿0‿0‿¯1‿0‿0‿1‿0‿1‿0‿¯1‿0‿0)

e↩"MatrixRotateZ"
e!(Approx ∾MatrixRotateZ¨ (π÷2)×↕4) ≡ (12‿3⥊1‿0‿0‿0‿1‿0‿0‿0‿1‿0‿1‿0‿¯1‿0‿0‿0‿0‿1‿¯1‿0‿0‿0‿¯1‿0‿0‿0‿1‿0‿¯1‿0‿1‿0‿0‿0‿0‿1)

e↩"MatrixRotateZ AND MatrixTranslate"
mat ↩ (MatrixRotateZ π)MP _ToDim_ 4 MatrixTranslate 2‿2‿2
e!(Approx mat⊸MP⌾(∾⟜1)1‿2‿3) ≡ ¯3‿¯4‿5

e↩"VectorAngle"
e!(Approx 1‿2     VectorAngle 3‿4    ) ≡ 0.17985
e!(Approx 1‿2‿3‿4 VectorAngle 5‿6‿7‿8) ≡ 0.2502
e!(Approx 1‿2‿3   VectorAngle 2‿3‿4  ) ≡ 0.12187

# raylib.bqn

⟨⟨_FromCenter⟩⇐utils⟩←•Import "../raylib.bqn"
e↩"_FromCenter"
e!(Approx 2⊸×_FromCenter[10‿15⋄15‿20⋄20‿25]) ≡ (3‿2⥊7.5‿17.5‿12.5‿22.5‿17.5‿27.5)
e!(Approx 2⊸×_FromCenter[10‿15‿15⋄15‿20‿20]) ≡ (2‿3⥊6.66667‿16.66667‿16.66667‿11.66667‿21.66667‿21.66667)

•Out "Raymath tests passed"


⟨GetWorldToScreenEx⟩ ← •Import "rcore.bqn"

camera2D ← {target⇐20‿30 ⋄ offset⇐40‿60 ⋄ zoom⇐1.2 ⋄ rotation⇐95}
camera3D ← {position⇐230‿120‿90 ⋄ target⇐204‿303‿226 ⋄ up⇐0‿1‿0 ⋄ fovy⇐100 ⋄ projection⇐1}
pos ← 111‿9‿4
width‿height ← 1920‿1080

e↩"MatrixLookAt"
e!(Approx MatrixLookAt camera3D.position‿camera3D.target‿camera3D.up) ≡ 4‿4⥊¯0.98221‿0.14974‿0.1133‿0‿0‿0.60338‿¯0.79746‿0‿¯0.18778‿¯0.78327‿¯0.59264‿0‿242.80856‿¯36.35183‿122.97376‿1

e↩"GetWorldToScreenEx"
e!(Approx GetWorldToScreenEx pos‿camera3D‿width‿height) ≡ 2396.74492‿728.27699

•Out "RCore tests passed"

e↩"SimpleToLine"
!1‿2‿¯1 ≡ SlopeInterceptToLine 1‿2

e↩"DistanceToPlane"
!6.7890285822722145≡ 8‿2‿¯2‿5 DistanceToPlane 4‿¯4‿3
!1.6165807537309518≡¯8‿1‿7‿¯5 DistanceToPlane 2‿5‿3
!2.23606797749979  ≡ ¯0.5‿¯1‿0.5 DistanceToPlane 4‿4
!2.23606797749979  ≡ (SlopeInterceptToLine 1‿2) DistanceToPlane 4‿4