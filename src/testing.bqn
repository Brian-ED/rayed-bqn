# Tests are very undeveloped.
# This file may be turned into a testing directory when it gets bigger.
# Catagories are seperated by 2 newlines.

# all tests successful as of june 13. 2023

# Raymath:
Round ← {⌊∘+⟜0.5⌾((10⋆𝕨)⊸×)𝕩}

e←""

!100.2131≡4 Round 100.21312344123

⟨MatrixRotate⟩ ← •Import "raymath.bqn"
e↩"MatrixRotate"
e!(•Repr 5 Round MatrixRotate 0 ‿0‿1⋈¯21) ≡ "4‿4⥊¯0.54773‿0.83666‿0‿0‿¯0.83666‿¯0.54773‿0‿0‿0‿0‿1‿0‿0‿0‿0‿1"
e!(•Repr 5 Round MatrixRotate 0 ‿1‿0⋈ 45) ≡ "4‿4⥊0.52532‿0‿0.8509‿0‿0‿1‿0‿0‿¯0.8509‿0‿0.52532‿0‿0‿0‿0‿1"
e!(•Repr 5 Round MatrixRotate 21‿3‿4⋈ 45) ≡ "4‿4⥊0.97453‿¯0.0935‿0.20382‿0‿0.22184‿0.53449‿¯0.81554‿0‿¯0.03269‿0.83999‿0.54162‿0‿0‿0‿0‿1"


# raylib.bqn

⟨⟨_FromCenter⟩⇐utils⟩←•Import "../raylib.bqn"
e↩"_FromCenter"
e!(•Repr 5 Round 2⊸×_FromCenter[10‿15⋄15‿20⋄20‿25]) ≡ "3‿2⥊7.5‿17.5‿12.5‿22.5‿17.5‿27.5"
e!(•Repr 5 Round 2⊸×_FromCenter[10‿15‿15⋄15‿20‿20]) ≡ "2‿3⥊6.66667‿16.66667‿16.66667‿11.66667‿21.66667‿21.66667"





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


"
for the entire message, i define   f⁼ to be  f^-1. 
the variables f, g, and h are always functions, the rest are values

First, you define an inverse for as many primitives as you can. for example define √⁼x to be x⋆2 and such. with this in mind, we can deduce the inverse of functions just based on the primitives used in its code.

F(G(x)) inverted is G⁼(F⁼(x))
F(G(x, y, ...)) inverted with respect to x is G⁼(F⁼(x), y, ...)
F(G(x), G(y), ...)	inverted with respect to x is G⁼(F⁼(x, G(y), G(z), ...))
G⁼(F(G(x), G(y), ...))  inverted with respect to x is  G⁼(F⁼(G(x), G(y), ...))

this may be obvious, but note, if function is defined for multiple inputs like lets say f(x), and f(x, y), inverting f is still allowed and just applies to both versions.



  Also have inverses of operators (functions taking functions)

i define map(f, x, y, z...) to be [f(x1,y1,z1, ...), f(x2,y2,z2, ...), f(x3,y3,z3, ...)...] 

define f(x, y, ...) = map(g, x, y, ...)
then the inverse is  f⁼(x, y, ...) = [g⁼(x1, y1, ...), g⁼(x2, y2, ...), ...]



Mod 	Inverse 	Requirements
⍟n 	⍟(-n) 	Atomic number n; no check, like ⁼

𝔾(𝕩, 𝔽(𝕨)) 	{𝕨𝔽⊸(𝔾⁼)𝕩}
𝔾(𝕩, k) 	{k⊸(𝔾⁼)𝕩}

𝕨𝔽⟜𝔾𝕩  {𝕨𝔾⁼𝔽⁼𝕩} 	Dyadic case


𝔽⟜k 	k𝔽˜⁼⊢ 	Monadic case, constant k
k𝔽𝔾 	𝔾⁼{𝕨𝔽𝔾𝕩}(k𝔽⁼⊢) 	Constant k
𝔽𝔾K 	𝔽⁼k𝔾˜⁼⊢ 	Constant k
"