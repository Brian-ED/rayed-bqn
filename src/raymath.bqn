# Math functions to work with Vectors, Matricies and Quaternions

# GOAL make raylib functions work on arbitrary vectors and matricies
# aswell as switch from raylib's collumn model to leading axis model.
# Also considering making Quaternions be real‿i‿j‿k instead of i‿j‿k‿real
# raylib and 3d graphics in general uses 4x4 matricies for rotation and position, but 3x3 are enough for just rotation.

# CONVENTIONS:
# - Functions are always self-contained, no function use another raymath function inside,
# - Angles are always in radians


#----------------------------------------------------------------------------------
# removed from raylib
#----------------------------------------------------------------------------------

## Removed QuaternionToMatrix and QuaternionFromMatrix:
# they have been said to be innacurate by ray - maintainer of raylib. 
# Under "module: raymath" at https://github.com/raysan5/raylib/discussions/2952 
## removed Vector3Perpendicular, as it isn't well defined.
⟨
  # new, non-existant in raylib
  _ToDim_      # set length of square input arrays, 𝔽 being applied to the inputs after padding to length 𝕘 
  MatrixExtend # pad square matrix to a length

  # multiply by constants for converting
  deg2rad, rad2deg

  # scaler ops
  Wrap
  Normalize
  Remap
  FloatEquals

  # works on any shaped input
  Round
  Lerp

  # functions applied to a list
  Vector3Unproject
  Vector3OrthoNormalize
  Vector3RotateByAxisAngle
  VectorClampValue
  VectorAngle
  VectorLength ⋄ VectorLengthSqr
  VectorDotProduct
  VectorDistance
  Vector2LineAngle
  Vector2Reflect
  Vector2Rotate
  VectorMoveTowards
  Vector3CrossProduct
  VectorNormalize
  Vector3OrthoNormalize
  Vector3RotateByQuaternion
  Vector3RotateByAxisAngle
  VectorReflect
  Vector3Barycenter
  Vector3Unproject
  Vector3Refract
  
  # matrix operations
    # generalized
    MP ⋄ Inverse ⋄ MatrixDeterminant # from matrix.bqn in Marshall's bqn-libs
    MatrixScale ⋄ MatrixTrace

    # only output 3x3
    MatrixRotate ⋄ MatrixRotateX ⋄ MatrixRotateY ⋄ MatrixRotateZ

    # only take list length 3
    MatrixTranslate
    MatrixLookAt
    MatrixRotateXYZ
    MatrixRotateZYX
  
    # take scalers
    MatrixFrustum
    MatrixPerspective
    MatrixOrtho

  # quaternion operations
  QuaternionInvert
  QuaternionMultiply
  QuaternionNlerp
  QuaternionSlerp
  QuaternionFromVector3ToVector
  QuaternionFromAxisAngle
  QuaternionToAxisAngle
  QuaternionFromEuler
  QuaternionToEuler
  QuaternionEquals
⟩⇐





# Too simple:
# Vector2Add         ← Vector2AddValue ← Vector3Add ← Vector3AddValue ← MatrixAdd ← QuaternionAdd ← QuaternionAddValue ←  +
# Vector2Multiply    ← Vector2Scale ← Vector3Multiply ← Vector3Scale ← QuaternionScale ← ×
# Vector2Subtract    ← Vector2SubtractValue ← Vector2Negate ← Vector3Subtract ← Vector3SubtractValue ← Vector3Negate ← QuaternionSubtract ← QuaternionSubtractValue ← -
# Vector2Divide      ← Vector2Invert ← Vector3Divide ← Vector3Invert ← QuaternionDivide ← ÷
# Vector3DistanceSqr ← Vector2DistanceSqr ← ×˜VectorDistance
# MatrixTranspose    ← ⍉
# MatrixIdentity     ← =⌜˜↕∘4
# MatrixInvert       ← matrix.Inverse
# MatrixToFloatV     ← ⥊
# Vector3Min         ← ⌊
# Vector3Max         ← ⌈
# Clamp              ← Vector2Clamp ← max⌊min⌈x

# extended:
# Vector2Length       ← Vector3Length     ← QuaternionLength ← VectorLength
# Vector2LengthSqr    ← Vector3LengthSqr  ← VectorLengthSqr
# Vector2DotProduct   ← Vector3DotProduct ← VectorDotProduct 
# Vector2Distance     ← Vector3Distance   ← VectorDistance
# Vector2Lerp         ← Vector3Lerp       ← QuaternionLerp ← Lerp
# Vector2Transform    ← Vector3Transform  ← VectorTransform ← (1∾˜3⊸↑)⊸MP
# QuaternionTransform ← MP
# Vector2ClampValue   ← Vector3ClampValue ← VectorClampValue
# Vector2Equals       ← Vector3Equals     ← VectorEquals ← VectorEquals
# Vector2Normalize    ← Vector3Normalize  ← QuaternionNormalize ← VectorNormalize
# Vector2Angle        ← Vector3Angle      ← VectorAngle
# Vector2MoveTowards  ← VectorMoveTowards
# Vector2CrossProduct ← Vector3CrossProduct


#----------------------------------------------------------------------------------
# Notes
#----------------------------------------------------------------------------------

# Why 4x4 Matricies?
#   https://stackoverflow.com/questions/29079685/how-does-4x4-matrix-work-in-3d-graphic
#   Matrices define linear transformations between vector spaces.
#   All linear transformations map the origin of the domain to the origin of the range.
#   Therefore 3x3 matrices cannot perform translation on 3D vectors since the origin in one space cannot be mapped to anything but the origin on another using linear maps.
#   To overcome this problem, we can fake the system into performing translations through the use of an extra dimension where all vectors will have a 1 in the last vector component. 
#   These 4D vectors will never be at the origin (having 1 in the last component) and so are not required to always map to the origin.
#   Through the use of this we can construct a 4x4 matrix to perform translation.

# Get scaling matrix
MatrixScale ← {𝕊v:𝕩×=⌜˜≠𝕩}


#----------------------------------------------------------------------------------
# Defines
#----------------------------------------------------------------------------------

epsilon ← 1e¯6
rad2deg ← ÷deg2rad ← π÷180

⟨Sin, Cos, Tan, Atan2⟩←•math

raylibPath‿bqnLibsPath ← •Import "loadConfig.bqn"

⟨MP, MatrixDeterminant⇐Determinant, Inverse⟩ ← •Import bqnLibsPath •file.At "matrix.bqn"

Round ← {⌊∘+⟜0.5⌾((10⋆𝕨)⊸×)𝕩}

#----------------------------------------------------------------------------------
# Utils math
#----------------------------------------------------------------------------------

# Calculate linear interpolation between two floats or vectors
Lerp ← {𝕊v1‿v2‿amount:
  amount⊸×⌾(-⟜v1)v2
}

# Normalize input value within input range
Normalize ← {start‿end𝕊value:
  (∧´⥊end≠start)!˜"Normalize: start can't equal end (start‿end←𝕨 ⋄ end≠start)"
  value÷○(-⟜start)end
}

# Remap input value within input range to output range
Remap ← {𝕊value‿inputStart‿inputEnd‿outputStart‿outputEnd:
  {𝕩×÷´value‿inputEnd-inputStart}⌾(-⟜outputEnd) outputStart
}

Wrap ← {𝕊value‿min‿max:
  "Wrap: Min can't equal max"!min≢max
  max|⌾(-⟜min)value
}

# Check whether two given vectors are almost equal
FloatEquals ← ∧´∘⥊|∘-≤epsilon×1⌈⌈○|

#----------------------------------------------------------------------------------
# Vector math
#----------------------------------------------------------------------------------

# Calculate vector length
VectorLength ← +´⌾(×˜)

# 𝕨𝕊𝕩: Calculate two vectors dot product
#  𝕊𝕩: Calculate vector square length
VectorDotProduct ← VectorLengthSqr ← +´×˜

# Calculate distance between two vectors
VectorDistance ← +´⌾(×˜)-

# Calculate angle between two vectors
# NOTE: Angle is calculated from origin point (0, 0)
VectorAngle ← {
  3=≠𝕩: (Cos⁼+´∘×÷×○(+´⌾(×˜)))´𝕨‿𝕩  # length3 is faster
;
  (+´∘×Atan2·+´⌾(×˜)1⊸⌽⊸×{1⌽𝔽˜-𝔽})´𝕨‿𝕩
}

# Calculate angle defined by a two vectors line
# NOTE: Parameters need to be normalized
# Current implementation should be aligned with glm::angle
Vector2LineAngle ← Cos⁼1⌈¯1⌈+´∘× # start 𝕊 end

# Calculate reflected vector to normal
Vector2Reflect ← {normal𝕊v: # vector vector
  v-2×normal×+´v×normal
}

# Rotate vector by angle:  angle 𝕊 vector2
Vector2Rotate ← (Cos∾Sin)⊸(-´∘×⋈·+´⌽⊸×)

# Move Vector towards target
VectorMoveTowards ← {target‿maxDistance𝕊v:
  target⌊v+maxDistance×÷⟜(0⊸=⊸++´⌾(×˜))target-v
}

# Clamp the magnitude of the vector between two min and max values
VectorClampValue ← {𝕊v‿min‿max:
  (÷×max⌊min⌈⊢)⟜(0⊸=⊸++´⌾(×˜))v
}

# Calculate two vectors cross product
Vector3CrossProduct ← 1⊸⌽⊸×{1⌽𝔽˜-𝔽}

# Normalize provided vector
VectorNormalize ← ÷⟜(0⊸=⊸++´⌾(×˜))

# Orthonormalize provided vectors
# Makes vectors normalized and orthogonal to each other
# Gram-Schmidt function implementation
Vector3OrthoNormalize ← {v1𝕊v2:
  # Vector3Normalize v1
  F ← ÷⟜(0⊸=⊸++´⌾(×˜))

  # Vector3CrossProduct´v1‿v2
  G ← 1⊸⌽⊸×{1⌽𝔽˜-𝔽}
  
  v1 G○F˜ v1 F⊸G v2
}

# Transform a vector by quaternion rotation
Vector3RotateByQuaternion ← {q𝕊v: x‿y‿z‿w←q
  MP⟜v MP⟜q[
    [
      ⟨ x ⋄ -y ⋄ -z ⋄  w⟩
      ⟨ y ⋄  x ⋄ -w ⋄ -z⟩
      ⟨ z ⋄  w ⋄  x ⋄  y⟩
    ]
    [
      ⟨ y ⋄  x ⋄  w ⋄  z⟩
      ⟨-x ⋄  y ⋄ -z ⋄  w⟩
      ⟨-w ⋄  z ⋄  y ⋄ -x⟩
    ]
    [
      ⟨ z ⋄ -w ⋄  x ⋄ -y⟩
      ⟨ w ⋄  z ⋄  y ⋄  x⟩
      ⟨-x ⋄ -y ⋄  z ⋄  w⟩
    ]
  ]
}

# Rotates a vector around an axis
Vector3RotateByAxisAngle ← {𝕊v‿axisV3‿angle:
  # Using Euler-Rodrigues Formula
  # Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula
  
  a ← Cos angle÷2
  w ← axisV3 ÷⟜(0⊸=⊸++´⌾(×˜))⊸× Sin angle÷2
  F ← 1⊸⌽⊸×{1⌽𝔽˜-𝔽}
  wv ← w F v
  v+2×(w⊸F+a⊸×) wv
}

# Calculate reflected vector to normal
VectorReflect ← {normal𝕊v:
  v - (+´v×normal)×2×normal
}

# Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
# NOTE: Assumes P is on the plane of the triangle
Vector3Barycenter ← {𝕊p‿a‿b‿c: # v3‿v3‿v3‿v3→v3
  # s0 and s1 are magic values, as in, i have no idea what they mean :)
  s0‿s1‿denom ← {-´×˝⌽⌾⊏𝕩}¨(<˘≠⌜˜↕3)/¨<+´˘×˝˘(>↕3‿2)⊏-⟜a¨b‿c‿p
  (¬+´)⊸∾s0‿s1÷denom
}

# Projects a Vector3 from screen space into object space
# NOTE: We are avoiding calling other raymath functions despite available
Vector3Unproject ← {
  𝕊⟨
    source     # v3
    projection # Matrix
    view       # Matrix
  ⟩:
  projection‿view⍉¨↩
  # Create quaternion from source point
  quat ← source∾1

  qtransformed ← quat MP Inverse view MP projection

  # Normalized world points in vectors
  ¯1(↓÷⊑)qtransformed
}

# Compute the direction of a refracted ray 
Vector3Refract ← {𝕊⟨
    v # v3: normalized direction of the incoming ray
    n # v3: normalized normal vector of the interface of two optical media
    r # f : ratio of the refractive index of the medium from where the ray comes to the refractive index of the medium on the other side of the surface
  ⟩:
  dot ← +´v×n
  d ← ¬¬⊸∧´×˜dot‿r
  {𝕊:(r×v)-n×(√d)+r×dot}⍟(d≥0)3⥊0
}

#----------------------------------------------------------------------------------
# Matrix math
#----------------------------------------------------------------------------------

# Extend square matrix by identity matrix:
MatrixExtend ← {len𝕊mat: # returns square matrix
  1¨⌾(0‿0⍉((-len-≠𝕩)¨≢𝕩)⊸↑)𝕨¨∘≢⊸↑𝕩
}

# 𝔽 is applied after resizing the square matricies 𝕩 and 𝕨 by padding identity matrix, so that 𝕩 and 𝕨 have length 𝕘 (∧´g=≠¨𝕩‿𝕨)
_ToDim_ ← {𝔽 _𝕣_ dim:𝔽○(𝕘⊸MatrixExtend)}

# Get the trace of the matrix (sum of the values along the diagonal)
MatrixTrace ← +´0‿0⊸⍉

# Get translation matrix
MatrixTranslate ← {𝕊x‿y‿z:
  [
    1‿0‿0‿x
    0‿1‿0‿y
    0‿0‿1‿z
    0‿0‿0‿1
  ]
}
# Create rotation matrix from axis and angle
# NOTE: Angle should be provided in radians
MatrixRotate ← {𝕊axis‿angle: # v3 f
  v ← ×⌜˜÷⟜(0⊸=⊸++´⌾(×˜)) axis
  x‿y‿z ← axis
  (v×¬Cos angle)+((=⌜˜↕3)⊏(Sin∾Cos)angle)×[
    ⟨ 1 ⋄-z ⋄ y⟩
    ⟨ z ⋄ 1 ⋄-x⟩
    ⟨-y ⋄ x ⋄ 1⟩
  ]
}

# NOTE: Angle must be provided in radians
MatrixRotateX‿MatrixRotateY‿MatrixRotateZ ← {
  _RotMat ← {cut2x2OfMat On2x2Arr _𝕣 degrees:
    (𝔽(⋈⟜-´≍⌽)(•math.Cos∾•math.Sin)𝕩)⌾(𝕨⊸⊏˘𝕨⊸⊏)=⌜˜↕3
  }
  ⟨1‿2 ⍉_RotMat ⊢
   0‿2 ⊢_RotMat ⊢
   0‿1 ⍉_RotMat ⊢⟩
}

# Get xyz-rotation matrix
# NOTE: Angle must be provided in radians
MatrixRotateXYZ ← {𝕊angle:
  [cx‿cy‿cz
   sx‿sy‿sz] ← (Cos≍Sin)-𝕩
  [
    ⟨ cy×cz ⋄ (sx×cz×sy) - sz×cx ⋄ (cx×sy×cz) + sz×sx ⟩
    ⟨ cy×sz ⋄ (sx×sy×sz) + cz×cx ⋄ (cx×sy×sz) - cz×sx ⟩
    ⟨   -sy ⋄  sx×cy             ⋄  cx×cy             ⟩
  ]
}

# Get zyx-rotation matrix
# NOTE: Angle must be provided in radians
MatrixRotateZYX ← MatrixRotateXYZ-

# Get perspective projection matrix
MatrixFrustum ← {𝕊left‿right‿bottom‿top‿near‿far:
  [
    ⟨near×2 ⋄ 0      ⋄ right+left   ⋄ 0         ⟩÷0⊸=⊸+right-left
    ⟨0      ⋄ near×2 ⋄   top+bottom ⋄ 0         ⟩÷0⊸=⊸+  top-bottom
    ⟨0      ⋄ 0      ⋄   far+near   ⋄ far×near×2⟩÷0⊸=⊸+ near-far
    ⟨0      ⋄ 0      ⋄ ¯1           ⋄ 0         ⟩
  ]
}

# Get perspective projection matrix
# NOTE: Fovy angle must be provided in radians
MatrixPerspective ← {𝕊fovy‿aspect‿near‿far:
  top    ← near×Tan fovy÷2
  bottom ← -top
  right  ← top×aspect
  left   ← -right

  # MatrixFrustum(-right, right, -top, top, near, far);
  [
    ⟨near×2 ⋄ 0      ⋄ right+left   ⋄ 0         ⟩0⊸=⊸+÷right-left
    ⟨0      ⋄ near×2 ⋄   top+bottom ⋄ 0         ⟩0⊸=⊸+÷  top-bottom
    ⟨0      ⋄ 0      ⋄   far+near   ⋄ far×near×2⟩0⊸=⊸+÷ near-far
    ⟨0      ⋄ 0      ⋄ ¯1           ⋄ 0         ⟩
  ]
}

# Get orthographic projection matrix
MatrixOrtho ← {𝕊left‿right‿bottom‿top‿near‿far:
  [
    ⟨ 2 ⋄ 0 ⋄  0 ⋄ left  +right ⟩÷left  -right
    ⟨ 0 ⋄ 2 ⋄  0 ⋄ bottom+top   ⟩÷bottom-top
    ⟨ 0 ⋄ 0 ⋄  2 ⋄ near  +far   ⟩÷near  -far
    ⟨ 0 ⋄ 0 ⋄  0 ⋄ 1            ⟩
  ]
}

# Get camera look-at matrix (view matrix)
MatrixLookAt ← {𝕊eye‿target‿up: # all are Vector3
  Norm ← ÷⟜(0⊸=⊸++´⌾(×˜))
  Cross ← 1⊸⌽⊸×{1⌽𝔽˜-𝔽}
  vz ← Norm eye-target
  vx ← Norm up Cross vz
  vy ← vz Cross vx
  ⍉[
    vx∾+´-vx×eye
    vy∾+´-vy×eye
    vz∾+´-vz×eye
    ¯4↑1
  ]
}


#----------------------------------------------------------------------------------
# Quaternion math
#----------------------------------------------------------------------------------

quaternionIdentity ← ¯4↑1

# Invert provided quaternion
QuaternionInvert ← ¯1‿¯1‿¯1‿1×÷⟜(0⊸=⊸++´○(×˜))

# Calculate two quaternion multiplication
QuaternionMultiply ← {q2𝕊q1: x‿y‿z‿w←𝕩
  𝕨 MP˜ [
    ⟨ w ⋄ -z ⋄  y ⋄ x⟩
    ⟨ z ⋄  w ⋄ -x ⋄ y⟩
    ⟨-y ⋄  x ⋄  w ⋄ z⟩
    ⟨-x ⋄ -y ⋄ -z ⋄ w⟩
  ]
}

# Calculate slerp-optimized interpolation between two quaternions
QuaternionNlerp ← {𝕊q1‿q2‿amount:
  ÷⟜(0⊸=⊸++´⌾(×˜))amount⊸×⌾(-⟜q1)q2
}

# Calculates spherical linear interpolation between two quaternions
QuaternionSlerp ← {𝕊q1‿q2‿amount:
  cosHalfTheta ← +´q1×q2
  cosHalfTheta‿q2×↩-⍟(cosHalfTheta<0)1

  {
    1 ≤ cosHalfTheta? q1
  ;
    0.95 < cosHalfTheta? ÷⟜(0⊸=⊸++´⌾(×˜))amount⊸×⌾(-⟜q1)q2
  ;
    sinHalfTheta ← Sin halfTheta ← Cos⁼cosHalfTheta
    0.001 ≤ sinHalfTheta?
    +˝[q1⋄q2]×sinHalfTheta÷˜Sin halfTheta×¬⊸⋈amount
  ;
    (+˝÷≠)[q1⋄q2]
  }
}

# Calculate quaternion based on the rotation from one vector to another
QuaternionFromVector3ToVector ← {to𝕊from:
  cos2Theta ← +˝from×to
  cross     ← from 1⊸⌽⊸×{1⌽𝔽˜-𝔽}to

  # QuaternionNormalize(q);
  # NOTE: Normalize to essentially nlerp the original and identity to 0.5
  ÷⟜(0⊸=⊸++´⌾(×˜))cross∾1+cos2Theta
}


# Get rotation quaternion for an angle and axis
# NOTE: Angle must be provided in radians
QuaternionFromAxisAngle ← {angle𝕊axis:
  Norm ← ÷⟜(0⊸=⊸++´⌾(×˜))
  Norm (Cos∾˜axis Norm⊸×Sin) angle÷2
}

# Get the rotation angle and axis for a given quaternion
QuaternionToAxisAngle ← {𝕊𝕩:

  # QuaternionNormalize(q);
  x‿y‿z‿w ← q ← ÷⟜(0⊸=⊸++´⌾(×˜))𝕩 # removed ⍟{1<|¯1⊑𝕩}

  angle ← 2×Cos⁼w

  # when the angle is zero just set an arbitrary normalized axis. (0‿0‿1)
  axis ← (Sin Cos⁼w){𝕨÷˜3↑q}⍟(≠⟜0)0‿0‿1

  axis‿angle
}

# Get the quaternion equivalent to Euler angles
# NOTE: Rotation order is ZYX
QuaternionFromEuler ← {pitch‿yaw‿roll:
  F ← ×´˘(Sin Cos⁼)⌾(0‿0⍉⊢)4⊸⥊˘
  ¯1‿1‿¯1‿1×(Cos ×○F Sin) 𝕩÷2
}

# Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
# NOTE: Angles are returned in a Vector3 struct in radians
QuaternionToEuler ← {𝕊x‿y‿z‿w:
  ⟨
    # Roll (x-axis rotation)
    Atan2⟜¬´2×+´¨⟨y×w‿z ⋄ ×˜x‿y⟩

    # Pitch (y-axis rotation)
    Sin⁼¯1⌊1⌈2×-´×˝2‿2⥊𝕩

    # Yaw (z-axis rotation)
    Atan2´⟨2×+´×´¨2(↑⋈↓)𝕩 ⋄ ¬2×+´×˜y‿z⟩
  ⟩
}

# Check whether two given quaternions are almost equal
QuaternionEquals ← ∨´·∧˝(|-≍˘+)≤epsilon×1⌈⌈○|