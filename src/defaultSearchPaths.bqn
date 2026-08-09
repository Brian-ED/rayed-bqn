# Default paths to search for the raylib shared library.
# Imported by searchPaths.bqn unless replaced by a packager.
{
  # C:\raylib is default installation location for the raylib-provided-installer
  "windows": "lib"‿"C:\raylib\raylib\lib"
  ;"linux" : "lib"‿"/usr/local/lib"
  ;"darwin":
    e‿stdout‿·←•SH⎊1‿⟨⟩‿@ "brew"‿"--prefix"‿"raylib"
    brewPath ← ⟨(@+10)⊸≠⊸/stdout⟩⍟(0≢e)⟨⟩
    "lib"‿"/usr/local/lib"∾brewPath
}•platform.os
