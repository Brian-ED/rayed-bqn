# This file may be turned into a testing directory when it gets bigger.
# Catagories are seperated by 2 newlines.

# testing values
camera2D ← {target⇐20‿30 ⋄ offset⇐40‿60 ⋄ zoom⇐1.2 ⋄ rotation⇐95}
camera3D ← {position⇐230‿120‿90 ⋄ target⇐204‿303‿226 ⋄ up⇐0‿1‿0 ⋄ fovy⇐100 ⋄ projection⇐1}


# Math:
⟨
  MatrixRotate, Wrap, Normalize, Vector3Unproject, MP, _ToDim_, MatrixExtend, Round
  QuaternionEquals, Vector3OrthoNormalize, Vector3RotateByAxisAngle, VectorClampValue
  MatrixTranslate, MatrixRotateX, MatrixRotateY, MatrixRotateZ, VectorAngle, deg2rad, rad2deg
  LineToSlopeIntercept, DistanceToPlane, QuaternionFromEuler, QuaternionToEuler
  VectorReflect, VectorNormalize, Vector3CrossProduct, Vector2LineAngle, Remap

  # These have been extensively tested against C versions
  MatrixOrtho
  MatrixLookAt,
⟩ ← •Import "math.bqn"

Approx ← 5⊸Round

•Out "(math tests started"
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
e![1‿1‿0⋄1‿1‿0⋄1‿1‿1]≡3 MatrixExtend [1‿1⋄1‿1⋄1‿1]

e↩"Vector3OrthoNormalize"
e!(Approx 1‿2‿3 Vector3OrthoNormalize 4‿5‿6) ≡ 0.87287‿0.21822‿¯0.43644
e!((-5+↕4) QuaternionEquals 5+↕4)≡1
e!((-4+↕4) QuaternionEquals 5+↕4)≡0

e↩"Vector3RotateByAxisAngle"
e!(Approx ⟨0‿1‿0, 1⟩ Vector3RotateByAxisAngle ↕3) ≡ 1.68294‿1‿1.0806
e!(Approx ⟨ 0‿1‿0 ⋄ ¯0.021 ⟩Vector3RotateByAxisAngle ¯2.6848‿1.7908‿¯2.3633) ≡ ¯2.63458‿1.7908‿¯2.41916

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
e!(Approx[
  1‿1‿0
  1‿3‿0
] VectorAngle○⍉ ≍˜0‿1‿0) ≡ 0.7854‿0.32175

e↩"LineToSlopeIntercept"
e!(LineToSlopeIntercept⁼ 1‿2         ) ≡ ¯1‿1‿2
e!(LineToSlopeIntercept 0.5‿¯0.5‿¯1) ≡ 1‿2
e!(LineToSlopeIntercept ¯1‿1‿2     ) ≡ 1‿2

e↩"DistanceToPlane"
e!2.71058≡Approx 5‿8‿2‿¯2 DistanceToPlane 4‿¯4‿3
e!0.46829≡Approx ¯5‿¯8‿1‿7 DistanceToPlane 2‿5‿3
e!5.50598≡Approx ¯3‿3‿3‿1 DistanceToPlane 2‿¯8‿¯3
e!4.91935≡Approx 0.5‿¯0.5‿¯1 DistanceToPlane 4‿4
e!4.91935≡Approx (LineToSlopeIntercept⁼ 1‿2) DistanceToPlane 4‿4

e!2.71058‿0.46829‿4.91935‿5.50598‿4.91935≡Approx [
   5‿¯5‿ 0.5‿¯3‿¯1
   8‿¯8‿¯0.5‿ 3‿1
   2‿ 1‿¯1  ‿ 3‿2
  ¯2‿ 7‿ 0  ‿ 1‿0
] DistanceToPlane [
   4‿2‿4‿ 2‿4
  ¯4‿5‿4‿¯8‿4
   3‿3‿0‿¯3‿0
]

e↩"MatrixLookAt"
e!(Approx MatrixLookAt camera3D.position‿camera3D.target‿camera3D.up) ≡ 4‿4⥊¯0.98221‿0.14974‿0.1133‿0‿0‿0.60338‿¯0.79746‿0‿¯0.18778‿¯0.78327‿¯0.59264‿0‿242.80856‿¯36.35183‿122.97376‿1

e↩"QuaternionFromEuler"
e!(Approx QuaternionFromEuler 1|π‿0‿π) ≡ 0.07056‿0.005‿0.07056‿0.995

e↩"QuaternionToEuler"
e!(Approx QuaternionToEuler 0.07056‿0.005‿0.07056‿0.995) ≡ 0.14159‿1e¯5‿0.14159

e↩"VectorReflect"
e!(Approx          1‿0‿0 VectorReflect 2‿2‿0) ≡ ¯2‿2‿0
e!(Approx (+´⌾(×˜)1‿1‿0) VectorReflect 0‿2‿0) ≡ ¯8‿¯6‿¯8

e↩"VectorNormalize"
e!(VectorNormalize 0‿1‿1)≡○Approx +˜⁼√0‿2‿2
e!(VectorNormalize 1‿0‿1)≡○Approx +˜⁼√2‿0‿2

e! 0.8‿0.6 ≡ Approx VectorNormalize 4‿3

vnormOut ← [
  [
    0.52981‿0.79472‿0.13245‿0.26491
    0.25355‿0.59161‿0.08452‿0.76064
    0.73241‿0.24414‿0.48827‿0.40689
  ]
  [
    0.31822‿0.47733‿0.39778‿  0.716
    0.05641‿0.05641‿ 0.0188‿0.99664
    0.10038‿0.99263‿0.06692‿0.01115
  ]
]
e!vnormOut ≡○Approx VectorNormalize˘˘ vnormInp ← [[4‿6‿1‿2⋄3‿7‿1‿9⋄9‿3‿6‿5]⋄[4‿6‿5‿9⋄3‿3‿1‿53⋄9‿89‿6‿1]]

e!(VectorNormalize vnormInp) ≡○Approx [
  [
    0.70711‿0.70711‿0.19612‿0.21693
    0.70711‿0.91915‿0.70711‿0.16741
    0.70711‿0.03369‿0.70711‿0.98058
  ]
  [
    0.70711‿0.70711‿0.98058‿0.97619
    0.70711‿0.39392‿0.70711‿0.98589
    0.70711‿0.99943‿0.70711‿0.19612
  ]
]

e!(VectorNormalize [1‿3‿5⋄2‿4‿6]) ≡○Approx [0.44721‿0.6‿0.64018⋄0.89443‿0.8‿0.76822]
e!(VectorNormalize˘[1‿2⋄3‿4⋄5‿6]) ≡○Approx [0.44721‿0.89443⋄0.6‿0.8⋄0.64018‿0.76822]

e↩"Vector3CrossProduct"
e!0.70711‿¯1.06066‿1.06066 ≡○Approx 1⊸+⌾((VectorNormalize 0‿1‿1)⊸Vector3CrossProduct) VectorNormalize 1‿0‿1

e↩"Vector2LineAngle"
e!0.88732 ≡○Approx 4‿100 Vector2LineAngle○(÷⟜(0⊸=⊸++´⌾(×˜))) 4‿3
e!0.88766‿0.87731 ≡○Approx [4‿100⋄5‿100] Vector2LineAngle○(÷⟜(0⊸=⊸++˝⌾(×˜)))○⍉ ≍˜4‿3

e↩"Remap"
e! 68 ≡ Remap 12‿ 5‿10‿40‿60
e! 40 ≡ Remap 10‿10‿20‿40‿60


•Out "Math tests passed)"
•Out "(RCore tests started"


⟨GetWorldToScreenEx⟩ ← ⟨{⇐}⋄1⟩ •Import "rcore.bqn"

pos ← 111‿9‿4
width‿height ← 1920‿1080

e↩"GetWorldToScreenEx"
e!(Approx GetWorldToScreenEx pos‿camera3D‿width‿height) ≡ 2396.74492‿728.27699


•Out "RCore tests passed)"
•Out "(Camera tests started"

{𝕊position‿target‿up‿fovy‿projection:

  position‿target‿up‿fovy‿projection
} camera3d

⟨
  Rotate, RotateLocked
  RotateAroundTarget, RotateAroundTargetLocked
  Roll, Pitch, Yaw
⟩ ← ⟨
  {up‿left‿down‿right‿w‿a‿s‿d‿e‿q‿space‿leftControl‿ispressed‿keypad‿isdown‿leftShift⇐↕16}
  {button⇐{middle⇐↕1}}, {getFrameTime‿gamepadaxis‿getgamepadaxismovement‿isgamepadavailable‿getMouseDelta⇐↕5}
  •Import "math.bqn"
⟩ •Import "camera.bqn"

# Reference implementation to test against
Rotate2 ← {⟨angleYaw‿anglePitch‿angleRoll⋄locked⟩𝕊position‿target‿up‿fovy‿projection:
  angleRoll Roll anglePitch‿locked‿1 Pitch angleYaw Yaw position‿target‿up‿fovy‿projection
}

a←⟨0.5‿0.2‿0.4⋄0⟩ Rotate2 camera3D
e↩"Rotate"
e!a≡○Approx 0.5‿0.2‿0.4 Rotate camera3D

c↩⟨0.5‿4‿0.4⋄1⟩ Rotate2 camera3D
e↩"RotateLocked"
e!c≡○Approx 0.5‿4‿0.4 RotateLocked camera3D

•Out "Camera tests passed)"
