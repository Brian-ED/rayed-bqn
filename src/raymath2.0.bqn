# GOAL make raylib functions work on arbitrary vectors and matricies
# ALSO after i finish translating everything, i will try making arbitrary matricies
# aswell as switch from raylib's collumn model to leading axis model.
# Also raylib only uses 4x4 matricies, i'm considering limiting this since it pads matricies a lot

⟨MP⋄MatrixLookAt
 MatrixScale⋄MatrixRotate
 GetCameraMatrix2D
 MatrixRotateX⋄MatrixRotateY⋄MatrixRotateZ
 Vector2Transform
⟩⇐

Sin‿Cos←•math

⟨MP,MatrixDeterminant⇐Determinant⟩ ← •Import "imports/bqn-libs/matrix.bqn"

# Get camera look-at matrix (view matrix)
# returns Matrix
MatrixLookAt ← {𝕊eye‿target‿up: # v3 v3 v3
  vz ← {𝕩÷1⍟(0=⊢)+´⌾(⋆⟜2)𝕩} eye-target
  vx ← {𝕩÷1⍟(0=⊢)+´⌾(⋆⟜2)𝕩} -´×´˘1‿¯1⌽⌜up‿vz
  vy ← -´×´˘1‿¯1⌽⌜vz‿vx

  [
    ⟨vx.x ⋄ vy.x ⋄ vz.x ⋄ 0⟩
    ⟨vx.y ⋄ vy.y ⋄ vz.y ⋄ 0⟩
    ⟨vx.z ⋄ vy.z ⋄ vz.z ⋄ 0⟩
    1∾˜-eye⊸×¨vx‿vy‿vz
  ]
}


# Get translation matrix
MatrixTranslate ← {𝕊x‿y‿z:[# v3 → Matrix
  1‿0‿0‿x
  0‿1‿0‿y
  0‿0‿1‿z
  0‿0‿0‿1
]}

# Get scaling matrix
MatrixScale ← {𝕊x‿y‿z:(𝕩∾1)⌾(0‿0⊸⍉)4‿4⥊0}

# Create rotation matrix from axis and angle
# NOTE: Angle should be provided in radians
MatrixRotate ← {𝕊axis‿angle: # v3 f
  x‿y‿z ← (+´axis⋆2)÷⟜√˜⍟(∧´2↕⊸≠⊣)axis

  sinres ← •math.Sin angle
  cosres ← •math.Cos angle
  m ← ((¬cosres)××⌜˜x‿y‿z)+(cosres¨⌾(0‿0⊸⍉)3‿3⥊sinres)×[
    ⟨ 1 ⋄-z ⋄ y⟩
    ⟨ z ⋄ 1 ⋄-x⟩
    ⟨-y ⋄ x ⋄ 1⟩
  ]
  ∾[ m ⋄3⥊0
    3⥊0⋄1  ]
}

# NOTE: Angle must be provided in radians
MatrixRotateX‿MatrixRotateY‿MatrixRotateZ ← {
    _RotMat ← {cut2x2OfMat On2x2Arr _𝕣 degrees:
        (𝔽(⋈⟜-´≍⌽)(•math.Cos∾•math.Sin)𝕩)⌾(𝕨⊸⊏˘𝕨⊸⊏)=⌜˜↕4
    }
    ⟨1‿2 ⍉_RotMat ⊢
     0‿2 ⊢_RotMat ⊢
     0‿1 ⍉_RotMat ⊢⟩
}

### rcore.c functions

# Get camera 2d transform matrix
GetCameraMatrix2D ← {𝕊camera: # camera2d
  # The camera in world-space is set by
  #   1. Move it to target
  #   2. Rotate by -rotation and scale by (1/zoom)
  #      When setting higher scale, it's more intuitive for the world to become bigger (= camera become smaller),
  #      not for the camera getting bigger, hence the invert. Same deal with rotation.
  #   3. Move it by (-offset);
  #      Offset defines target transform relative to screen, but since we're effectively "moving" screen (camera)
  #      we need to do it into opposite direction (inverse transform)
    
  # Having camera transform in world-space, inverse of it gives the modelview transform.
  # Since (A*B*C)' = C'*B'*A', the modelview is
  #   1. Move to offset
  #   2. Rotate and Scale
  #   3. Move by -target
  origin      ← MatrixTranslate-(1⊑camera)∾0
  rotation    ← MatrixRotate 0‿0‿1⋈ π÷180×2⊑camera
  scale       ← MatrixScale 1∾˜2⥊3⊑camera
  translation ← MatrixTranslate 0∾˜⊑camera
  matTransform ← origin‿scale‿rotation MP´⊸MP translation
}






###############################################################################################
#
#   raymath v1.5 - Math functions to work with Vector2, Vector3, Matrix and Quaternions
#
#   CONVENTIONS:
#     - Matrix structure is defined as row-major (memory layout) but parameters naming AND all
#       math operations performed by the library consider the structure as it was column-major
#       It is like transposed versions of the matrices are used for all the maths
#       It benefits some functions making them cache-friendly and also avoids matrix
#       transpositions sometimes required by OpenGL
#       Example: In memory order, row0 is [m0 m4 m8 m12] but in semantic math row0 is [m0 m1 m2 m3]
#     - Functions are always self-contained, no function use another raymath function inside,
#       required code is directly re-implemented inside
#     - Functions input parameters are always received by value (2 unavoidable exceptions)
#     - Functions use always a "result" variable for return
#     - Functions are always defined inline
#     - Angles are always in radians (DEG2RAD/RAD2DEG macros provided for convenience)
#
###############################################################################################

#----------------------------------------------------------------------------------
# removed from raylib
#----------------------------------------------------------------------------------

## Removed QuaternionToMatrix and QuaternionFromMatrix:
# they have been said to be innacurate by ray - maintainer of raylib. 
# Under "module: raymath" at https://github.com/raysan5/raylib/discussions/2952 

# Too simple:
# Clamp ← Vector2Clamp ← max⌊min⌈x
Vector2Add         ← Vector2AddValue ← Vector3Add ← QuaternionAdd ← QuaternionAddValue ← +
Vector2Multiply    ← Vector2Scale ← QuaternionScale ← ×
Vector2Subtract    ← Vector2SubtractValue ← Vector2Negate ← Vector3Negate ← QuaternionSubtract ← QuaternionSubtractValue ← -
Vector2Divide      ← Vector2Invert ← Vector3Divide ← Vector3Invert ← QuaternionDivide ← ÷
Vector3DistanceSqr ← Vector2DistanceSqr ← ×˜VectorDistance
MatrixTranspose    ← ⍉
MatrixIdentity     ← =⌜˜↕∘4
MatrixInvert       ← matrix.Inverse
MatrixToFloatV    ← ⥊

# extended
Vector2Length     ← Vector3Length     ← QuaternionLength ← VectorLength
Vector2LengthSqr  ← Vector3LengthSqr  ← VectorLengthSqr
Vector2DotProduct ← Vector3DotProduct ← VectorDotProduct 
Vector2Distance   ← Vector3Distance   ← VectorDistance
Vector2Lerp       ← Vector3Lerp       ← QuaternionLerp ← VectorLerp
Vector2Transform  ← Vector3Transform  ← VectorTransform
Vector2ClampValue ← Vector3ClampValue ← VectorClampValue
Vector2Equals     ← Vector3Equals     ← VectorEquals
Vector2Normalize  ← Vector3Normalize  ← QuaternionNormalize ← VectorNormalize
Vector2Angle      ← Vector3Angle      ← VectorAngle

quaternionIdentity ← ¯4↑1

MatrixAdd

Vector3AddValue
Vector3Subtract
Vector3SubtractValue
Vector3Scale
Vector3Multiply
Vector3CrossProduct


#----------------------------------------------------------------------------------
# Defines
#----------------------------------------------------------------------------------

epsilon ← 1e¯6
rad2deg ← ÷deg2rad ← π÷180


#----------------------------------------------------------------------------------
# Types and Structures Definition
#----------------------------------------------------------------------------------

# Vector2 type
typedef struct Vector2 {
    float x;
    float y;
} Vector2;

# Vector3 type
typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;

# Vector4 type
typedef struct Vector4 {
    float x;
    float y;
    float z;
    float w;
} Vector4;

# Quaternion type
typedef Vector4 Quaternion;

# Matrix type (OpenGL style 4x4 - right handed, column major)
typedef struct Matrix {
    float m0, m4, m8, m12;      # Matrix first row (4 components)
    float m1, m5, m9, m13;      # Matrix second row (4 components)
    float m2, m6, m10, m14;     # Matrix third row (4 components)
    float m3, m7, m11, m15;     # Matrix fourth row (4 components)
} Matrix;

⟨Sin, Cos, Tan, Atan2⟩←•math

#----------------------------------------------------------------------------------
# Module Functions Definition - Utils math
#----------------------------------------------------------------------------------

# Calculate linear interpolation between two floats
Lerp ← {𝕊start‿end‿amount:
  start + amount × end - start
}

# Normalize input value within input range
Normalize ← {𝕊value‿start‿end:
  ÷´value‿end-start
}

# Remap input value within input range to output range
Remap ← {𝕊value‿inputStart‿inputEnd‿outputStart‿outputEnd:
  {𝕩×÷´value‿inputEnd-inputStart}⌾(-⟜outputEnd) outputStart
}

# Wrap input value from min to max
Wrap ← {𝕊value‿min‿max:
  (value - max⊸- × value⊸- ⌊∘÷ max⊸-) min
}

# Check whether two given floats are almost equal
FloatEquals ← {𝕊x‿y:
  (|x-y) ≤ epsilon×1⌈x⌈○|y
}

#----------------------------------------------------------------------------------
# Module Functions Definition - Vector2 math
#----------------------------------------------------------------------------------

# Calculate vector length
VectorLength ← +´⌾(×˜)

# 𝕨𝕊𝕩: Calculate two vectors dot product
#  𝕊𝕩: Calculate vector square length
VectorDotProduct ← VectorLengthSqr ← +´×˜

# Calculate distance between two vectors
VectorDistance ← +´⌾(×˜)-

# Calculate angle between two vectors
# NOTE: Angle is calculated from origin point (0, 0)
VectorAngle ← +´∘×Atan2·+´⌾(×˜){(¯1⌽𝕨)×1⌽𝕩}{𝔽˜-𝔽}

# Calculate angle defined by a two vectors line
# NOTE: Parameters need to be normalized
# Current implementation should be aligned with glm::angle
Vector2LineAngle ← Cos⁼1⌈¯1⌈+´∘× # start 𝕊 end

# Transforms a Vector2 by a given Matrix
VectorTransform ← {𝕊v‿matrix:
  x‿y‿z ← 3↑v
  +˝x‿y‿z‿1 × 0‿1⊸⊏˘matrix
}

# Calculate linear interpolation between two vectors
VectorLerp ← {𝕊v1‿v2‿amount:
  amount⊸×⌾(-⟜v1)v2
}

# Calculate reflected vector to normal
Vector2Reflect ← {normal𝕊v: # vector vector
  v-2×normal×+´v×normal
}

# Rotate vector by angle:  angle 𝕊 vector2
Vector2Rotate ← (Cos∾Sin)⊸(-´∘×⋈·+´⌽⊸×)

# Move Vector towards target
Vector2MoveTowards ← {𝕊v‿target‿maxDistance:

  d ← dx‿dy ← target - v;
  value ← +´×˜d

  {
    (value = 0) ∨ (maxDistance ≥ 0) ∧ value ≤ ×˜maxDistance?
      target
    ;
    v+maxDistance×d÷√value
  }
}

# Clamp the magnitude of the vector between two min and max values
VectorClampValue ← {𝕊v‿min‿max:
  length ← +´∘⥊⌾(×˜)v
  {length≤0?v;
    length < min?
      v×min÷length;
    length > max?
      v×max÷length;
    v
  }
}
#•Show VectorClampValue ⟨2‿2‿2‿2,10,22⟩

# Check whether two given vectors are almost equal
VectorEquals ← ∧´|∘-≤epsilon×1⌈⌈○|

#----------------------------------------------------------------------------------
# Module Functions Definition - Vector3 math
#----------------------------------------------------------------------------------

# Calculate one vector perpendicular vector
RMAPI Vector3 Vector3Perpendicular(Vector3 v)
{
    Vector3 result = { 0 };

    float min = (float) fabs(v.x);
    Vector3 cardinalAxis = {1.0f, 0.0f, 0.0f};

    if (fabsf(v.y) < min)
    {
        min = (float) fabs(v.y);
        Vector3 tmp = {0.0f, 1.0f, 0.0f};
        cardinalAxis = tmp;
    }

    if (fabsf(v.z) < min)
    {
        Vector3 tmp = {0.0f, 0.0f, 1.0f};
        cardinalAxis = tmp;
    }

    # Cross product between vectors
    result.x = v.y*cardinalAxis.z - v.z*cardinalAxis.y;
    result.y = v.z*cardinalAxis.x - v.x*cardinalAxis.z;
    result.z = v.x*cardinalAxis.y - v.y*cardinalAxis.x;

    return result;
}

# Calculate angle between two vectors
Vector3Angle ← +´∘×Atan2·+´⌾(×˜){(¯1⌽𝕨)×1⌽𝕩}{𝔽˜-𝔽}

# Normalize provided vector
VectorNormalize ← ÷⟜(0⊸=⊸++´⌾(×˜))

# Orthonormalize provided vectors
# Makes vectors normalized and orthogonal to each other
# Gram-Schmidt function implementation
Vector3OrthoNormalize{v1𝕊v2:
  # Vector3Normalize v1
  F ← ÷⟜(0⊸=⊸++´⌾(×˜))

  # Vector3CrossProduct´v1‿v2
  G ← {(¯1⌽𝕨)×1⌽𝕩}{𝔽˜-𝔽}
  
  v1 G˜○F v1 F⊸G v2
}

# Transforms a Vector2 by a given Matrix
VectorTransform ← {𝕊v‿matrix:
  x‿y‿z ← 3↑v
  +˝x‿y‿z‿1 × (↕≠v)⊸⊏˘matrix
}

# Transform a vector by quaternion rotation
Vector3RotateByQuaternion ← {q𝕊v: x‿y‿z‿w←q
  MP⟜v MP⟜q[
    [
      [ x ⋄ -y ⋄ -z ⋄  w]
      [ y ⋄  x ⋄ -w ⋄ -z]
      [ z ⋄  w ⋄  x ⋄  y]
    ]
    [
      [ y ⋄  x ⋄  w ⋄  z]
      [-x ⋄  y ⋄ -z ⋄  w]
      [-w ⋄  z ⋄  y ⋄ -x]
    ]
    [
      [ z ⋄ -w ⋄  x ⋄ -y]
      [ w ⋄  z ⋄  y ⋄  x]
      [-x ⋄ -y ⋄  z ⋄  w]
    ]
  ]
}

# Rotates a vector around an axis
Vector3RotateByAxisAngle ← {𝕊v‿axisV3‿angle:
  # Using Euler-Rodrigues Formula
  # Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula
  
  a ← Cos angle÷2
  w ← axisV3 ÷⟜(0⊸=⊸++´⌾(×˜))⊸× Sin angle÷2
  F ← {(¯1⌽𝕨)×1⌽𝕩}{𝔽˜-𝔽}
  wv ← w F v
  v+2×(w⊸F+a⊸×) wv
}

# Calculate reflected vector to normal
VectorReflect ← {normal𝕊v3:
  v - (+´v×normal)×2×normal
}

Vector3Min ← ⌊
Vector3Max ← ⌈

# Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
# NOTE: Assumes P is on the plane of the triangle
RMAPI Vector3 Vector3Barycenter(Vector3 p, Vector3 a, Vector3 b, Vector3 c)
{
    Vector3 result = { 0 };

    Vector3 v0 = { b.x - a.x, b.y - a.y, b.z - a.z };   # Vector3Subtract(b, a)
    Vector3 v1 = { c.x - a.x, c.y - a.y, c.z - a.z };   # Vector3Subtract(c, a)
    Vector3 v2 = { p.x - a.x, p.y - a.y, p.z - a.z };   # Vector3Subtract(p, a)
    float d00 = (v0.x*v0.x + v0.y*v0.y + v0.z*v0.z);    # Vector3DotProduct(v0, v0)
    float d01 = (v0.x*v1.x + v0.y*v1.y + v0.z*v1.z);    # Vector3DotProduct(v0, v1)
    float d11 = (v1.x*v1.x + v1.y*v1.y + v1.z*v1.z);    # Vector3DotProduct(v1, v1)
    float d20 = (v2.x*v0.x + v2.y*v0.y + v2.z*v0.z);    # Vector3DotProduct(v2, v0)
    float d21 = (v2.x*v1.x + v2.y*v1.y + v2.z*v1.z);    # Vector3DotProduct(v2, v1)

    float denom = d00*d11 - d01*d01;

    result.y = (d11*d20 - d01*d21)/denom;
    result.z = (d00*d21 - d01*d20)/denom;
    result.x = 1.0f - (result.z + result.y);

    return result;
}

# Projects a Vector3 from screen space into object space
# NOTE: We are avoiding calling other raymath functions despite available
Vector3Unproject←{
  𝕊⟨
    source     # v3
    projection # Matrix
    view       # Matrix
  ⟩
  # Calculate unprojected matrix (multiply view matrix by projection matrix) and invert it
  matViewProj ← veiw MP projection

  # Calculate inverted matrix -> MatrixInvert(matViewProj);  
  matViewProjInv ← Inverse matViewProj

  # Create quaternion from source point
  quat ← source∾1

  # Multiply quat point by unprojecte matrix
  qtransformed ← +˝quat⊸×˘matViewProjInv

  # Normalized world points in vectors
  qtransformed÷3⊑qtransformed;
}

# Get Vector3 as float array
RMAPI float3 Vector3ToFloatV(Vector3 v)
{
    float3 buffer = { 0 };

    buffer.v[0] = v.x;
    buffer.v[1] = v.y;
    buffer.v[2] = v.z;

    return buffer;
}

# Compute the direction of a refracted ray 
Vector3Refract ← {𝕊⟨
    v # v3: normalized direction of the incoming ray
    n # v3: normalized normal vector of the interface of two optical media
    r # f : ratio of the refractive index of the medium from where the ray comes to the refractive index of the medium on the other side of the surface
  ⟩
  dot ← +´v×n
  d ← ¬(r⋆2)×¬dot⋆2
  {r×v-n×(√d)+r×dot}⍟(d≥0)3⥊0
}

#----------------------------------------------------------------------------------
# Module Functions Definition - Matrix math
#----------------------------------------------------------------------------------

# Get the trace of the matrix (sum of the values along the diagonal)
MatrixTrace ← +´0‿0⍉⊢

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
MatrixRotate ← {angle𝕊axis: x‿y‿z←axis
  {axis÷↩𝕩}⍟(∧´≠⟜0‿1)+´⌾(×˜)axis

  sinres ← Sin angle
  cosres ← Cos angle
  t ← 1 - cosres

  r←[
    ⟨  cosres ⋄ -z×sinres ⋄  y×sinres⟩
    ⟨z×sinres ⋄    cosres ⋄ -x×sinres⟩
    ⟨z×sinres ⋄    cosres ⋄ -x×sinres⟩
  ]+t××⌜˜axis
  
  ∾[
    r⋈l←3⥊0
    l⋈1
  ]
}

# Get xyz-rotation matrix
# NOTE: Angle must be provided in radians
MatrixRotateXYZ {angle:
  ⟨
    cx‿cy‿cz
    sx‿sy‿sz
  ⟩ ← (Cos≍Sin) -angle
  [
    ⟨
      cz×cy
      (cz×sy×sx) - sz×cx
      (cz×sy×cx) + sz×sx
    ⟩
    ⟨
      sz×cy
      (sx×sy×sz) + cz×cx
      (cx×sy×sz) - cz×sx
    ⟩
    ⟨
      -sy
      cy×sx
      cy×cx
    ⟩
  ]⌾(⍉3‿3⊸↑)=⌜˜↕4
}

# Get zyx-rotation matrix
# NOTE: Angle must be provided in radians
MatrixRotateZYX{𝕊angle:
  ⟨
    cx‿cy‿cz
    sx‿sy‿sz
  ⟩ ← (Cos≍Sin) angle

  [
    ⟨
      cz×cy
      (cz×sy×sx) - cx×sz
      (sz×sx) + cz×cx×sy
    ⟩
    ⟨
      cy×sz
      (cz×cx) + sz×sy×sx
      (cx×sz×sy) - cz×sx
    ⟩
    ⟨
      -sy
      cy×sx
      cy×cx
    ⟩
  ]⌾(⍉3‿3⊸↑)=⌜˜↕4
}

# Get scaling matrix
MatrixScale ← {𝕊x‿y‿z:
  𝕩⊸×⌾(3‿3⊸↑)=⌜˜↕4
}

# Get perspective projection matrix
MatrixFrustum ← {𝕊left‿right‿bottom‿top‿near‿far:
  [
    ⟨near×2 ⋄ 0      ⋄ right+left   ⋄ 0         ⟩÷right-left
    ⟨0      ⋄ near×2 ⋄   top+bottom ⋄ 0         ⟩÷  top-bottom
    ⟨0      ⋄ 0      ⋄   far+near   ⋄ far×near×2⟩÷ near-far
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
    ⟨near×2 ⋄ 0      ⋄ right+left   ⋄ 0         ⟩÷right-left
    ⟨0      ⋄ near×2 ⋄   top+bottom ⋄ 0         ⟩÷  top-bottom
    ⟨0      ⋄ 0      ⋄   far+near   ⋄ far×near×2⟩÷ near-far
    ⟨0      ⋄ 0      ⋄ ¯1           ⋄ 0         ⟩
  ]
}

# Get orthographic projection matrix
MatrixOrtho ← {𝕊left‿right‿bottom‿top‿near‿far:
  [
    ⟨ 2 ⋄ 0 ⋄  0 ⋄ - right+left   ⟩÷right-left
    ⟨ 0 ⋄ 2 ⋄  0 ⋄ -   top+bottom ⟩÷  top-bottom
    ⟨ 0 ⋄ 0 ⋄  2 ⋄     far+near   ⟩÷  near-far
    ⟨ 0 ⋄ 0 ⋄  0 ⋄ 1              ⟩
  ]
}

# Get camera look-at matrix (view matrix)
MatrixLookAt ← {𝕊eye‿target‿up: # all are Vector3

    # Vector3Normalize(vz)
    vz ← ÷⟜(0⊸=⊸++´⌾(×˜)) eye-target

    # Vector3CrossProduct(up, vz)
    vx ← ÷⟜(0⊸=⊸++´⌾(×˜)) up{(¯1⌽𝕨)×1⌽𝕩}{𝔽˜-𝔽}vz
    
    # Vector3CrossProduct(vz, vx)
    vy ← vz {(¯1⌽𝕨)×1⌽𝕩}{𝔽˜-𝔽} vx
  [
    vx∾+´-vx×eye
    vy∾+´-vy×eye
    vz∾+´-vz×eye
    ¯4↑1
  ]
}

#----------------------------------------------------------------------------------
# Module Functions Definition - Quaternion math
#----------------------------------------------------------------------------------

# Invert provided quaternion
QuaternionInvert ← ¯1‿¯1‿¯1‿1×÷⟜(0⊸=⊸++´○(×˜))

MP ← +˝∘×⎉1‿∞
# Calculate two quaternion multiplication
QuaternionMultiply ← {q2𝕊q1:
  qax‿qay‿qaz‿qaw ← q1
  qbx‿qby‿qbz‿qbw ← q2
  ⟨
    +´ ⟨ qaw×qbx ⋄ -qaz×qby ⋄  qay×qbz ⋄ qax×qbw⟩
    +´ ⟨ qaz×qbx ⋄  qaw×qby ⋄ -qax×qbz ⋄ qay×qbw⟩
    +´ ⟨-qay×qbx ⋄  qax×qby ⋄  qaw×qbz ⋄ qaz×qbw⟩
    +´ ⟨-qax×qbx ⋄ -qay×qby ⋄ -qaz×qbz ⋄ qaw×qbw⟩
  ⟩
}
QuaternionMultiply2 ← {q2𝕊q1: x‿y‿z‿w←𝕩
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
    (+˝÷≠)[q1,q2]
  }
}

# Calculate quaternion based on the rotation from one vector to another
QuaternionFromVector3ToVector ← {to𝕊from:
  cos2Theta ← +˝from×to
  cross     ← from{(¯1⌽𝕨)×1⌽𝕩}{𝔽˜-𝔽}to

  # QuaternionNormalize(q);
  # NOTE: Normalize to essentially nlerp the original and identity to 0.5
  ÷⟜(0⊸=⊸++´⌾(×˜))cross∾1+cos2Theta
}


# Get rotation quaternion for an angle and axis
# NOTE: Angle must be provided in radians
QuaternionFromAxisAngle ← {angle𝕊axis:
  axisNormalized ← ÷⟜(0⊸=⊸++´⌾(×˜)) axis    
  ÷⟜(0⊸=⊸++´⌾(×˜)) (Cos∾˜axisNormalized×Sin) angle÷2
}

# Get the rotation angle and axis for a given quaternion
QuaternionToAxisAngle ← {𝕊x‿y‿z‿w:
  # QuaternionNormalize(q);
    
  ÷⟜(0⊸=⊸++´⌾(×˜))⍟(1<|w)𝕩

  resAngle ← 2×Cos w

  # when the angle is zero just set an arbitrary normalized axis. (0‿0‿1)
  resAxis ← (Sin Cos⁼w){𝕨÷˜3↑q}⍟(≠⟜0)0‿0‿1
  
  resAxis‿resAngle
}

# Get the quaternion equivalent to Euler angles
# NOTE: Rotation order is ZYX
QuaternionFromEuler{pitch‿yaw‿roll:
  F ← ×´˘(Sin Cos⁼)⌾(0‿0⍉⊢)4⊸⥊˘
  ¯1‿1‿¯1‿1×(Cos ×○F Sin) 𝕩÷2
}

# Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
# NOTE: Angles are returned in a Vector3 struct in radians
QuaternionToEuler ← {𝕊x‿y‿z‿w:
  ⟨
    # Roll (x-axis rotation)
    Atan2´⟨2×(w×x)+y×z ⋄ 1-2×+´×˜x‿y⟩

    # Pitch (y-axis rotation)
    Sin⁼¯1⌊1⌈2×-´×˝2‿2⥊𝕩

    # Yaw (z-axis rotation)
    Atan2´⟨2×+´×´¨2(↑⋈↓)𝕩 ⋄ 1-2×+´×˜y‿z⟩
  ⟩
}

# Transform a quaternion given a transformation matrix
QuaternionTransform ← {q𝕊mat: # →Quaternion
  q⊸×˘mat
}

# Check whether two given quaternions are almost equal
QuaternionEquals ← ∨´·∧˝(|-≍˘+)≤epsilon×1⌈⌈○|


