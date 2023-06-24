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

