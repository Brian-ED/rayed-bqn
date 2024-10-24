⟨⟨RealPath ⋄ Exists ⋄ At⟩⟩ ← •args
lf ← @+10
raylibLibPath ← {
  raylibName ← {
    "windows": "raylib.dll" ;
    "linux": "libraylib.so";
    "darwin":"libraylib.dylib"
  }•platform.os
  validPaths ← Exists¨⊸/ At⟜raylibName¨ {
    "windows": "lib"‿"C:\raylib\raylib\lib"  # C:\raylib is default installation location for the raylib-provided-installer
    ;"linux" : "lib"‿"/usr/local/lib"
    ;"darwin":
      e‿stdout‿·←•SH⎊1‿⟨⟩‿@ "brew"‿"--prefix"‿"raylib"
      brewPath ← ⟨(@+10)⊸≠⊸/stdout⟩⍟(0≢e)⟨⟩
      "lib"‿"/usr/local/lib"∾brewPath
    ;!∾lf∾¨⟨
      "Unknown OS, unable to find path to raylib shared library file automatically."
      "Try providing binary as argument (⟨""raylib.so""⟩•Import""rayed.bqn"")"
    ⟩
  }•platform.os
  {𝕊:
    !∾lf∾¨⟨
      "Path to raylib not found at install location."
      ""
      "  To install raylib, run the install-raylib script:"
      "    "∾RealPath "install-raylib/install.bqn"
      ""
      "  Already installed raylib? Tell rayed.bqn where to find it"
      "    ⟨""path/to/"∾raylibName∾"""⟩•Import""rayed.bqn"")"
      ""
    ⟩
  }⍟(0=≠)validPaths
  RealPath ⊑ validPaths
}

{𝕊:
  ⟨raylibLibPath⟩ •Import RealPath "imports/raylib-bqn/raylib.bqn"
}{𝕘⋄𝔽}{𝕊:
  !•CurrentError⊸∾ ∾lf∾¨⟨
    "Likely incorrect raylib version."
    "Run the following script to install the correct version."
    "Requires an internet connection."
    "Output is ./rayed-bqn/raylib."
    ""
    "  "∾RealPath "install-raylib/install.bqn"
    ""
  ⟩
}@