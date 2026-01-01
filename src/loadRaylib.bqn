⟨⟨RealPath ⋄ Exists ⋄ At⟩⟩ ← {𝕊:⋈⟨".."⟩•BQN"•file"}⍟(0=≠) •args
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
      "Unknown OS, unable to find path to raylib binary automatically."
      "Try providing binary as argument (⟨""raylib.so""⟩•Import""rayed.bqn"")"
    ⟩
  }•platform.os
  {𝕊:
    !∾lf∾¨⟨
      "Path to raylib binary not found at install location."
      ""
      "  To install raylib, run the install-raylib script:"
      "    bqn "∾•file.RealPath "../install-raylib.bqn"
      ""
      "  Already installed raylib? Tell rayed.bqn where to find it"
      "    ⟨""path/to/"∾raylibName∾"""⟩•Import""rayed.bqn"")"
      ""
    ⟩
  }⍟(0=≠)validPaths
  "File expected at "!Exists ⊑validPaths
  RealPath ⊑validPaths
}

{𝕊:
  ⟨raylibLibPath⟩ •Import "../imports/raylib-bqn/raylib.bqn"
}⎊{𝕊:
  !•CurrentError⊸∾ ∾lf∾¨⟨
    "Likely incorrect raylib version."
    "Run the following script to install the correct version."
    "Requires an internet connection."
    "Output goes in ./rayed-bqn/lib/"
    ""
    "  bqn """∾""""∾˜•file.RealPath "../install-raylib.bqn"
    ""
  ⟩
}@
