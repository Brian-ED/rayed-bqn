⟨Realpath⋄At⋄Exists⋄CreateDir⋄Remove⋄List⋄Bytes⋄path⟩ ← •file
⟨os⟩←•platform
version ← "5.0"
binariesPath ← "../lib"

⟨               ext     ⋄ libFile         ⋄ raylibFolder
⟩←{"darwin":  ⟨".tar.gz"⋄"libraylib.dylib"⋄"raylib-"∾version∾"_macos"       ⟩
;  "linux":   ⟨".tar.gz"⋄"libraylib.so"   ⋄"raylib-"∾version∾"_linux_amd64" ⟩
;  "windows": ⟨".zip"   ⋄"raylib.dll"     ⋄"raylib-"∾version∾"_win64_msvc16"⟩
} os

# Expected library to not exist
{𝕊:
  !"raylib already installed. Delete it to re-install. (rm "∾')'∾˜Realpath 𝕩
}⍟Exists binariesPath At libFile

# ---------------
# download raylib
# ---------------

{"windows"≡os?
  •SH ⋈ RealPath "windows.ps1"
;
  unarchive ← {
    ".tar.gz": {"tar"‿"-xzf"‿𝕩‿"-C"‿path}
  ; ".zip": {"unzip"‿"-d"‿path‿𝕩}
  } ext
  Exec ← {e‿·‿o:o!0≡e}•SH
  Exec ⟨"wget" ⋄ "-O" ⋄ At"temp"∾ext
    "https://www.github.com/raysan5/raylib/releases/download/"∾version∾"/"∾raylibFolder∾ext
  ⟩
  Exec Unarchive Realpath"temp"∾ext
}
Remove Realpath"temp"∾ext

# ---------------------
# move binary to binariesPath
# ---------------------
CreateDir⍟(¬Exists) binariesPath
(binariesPath At libFile) Bytes Bytes Realpath raylibFolder At "lib" At libFile

# -----------------
# clean away raylib
# -----------------

(raylibFolder At "a") •FChars "helloo.txt"

filesToBeDeleted ← raylibFolder⊸At¨ ∾"lib"‿"include"‿"" At⚇1 ⟨
  •file.List raylibFolder At"lib"
  "raylib.h"‿"raymath.h"‿"rlgl.h"
  "CHANGELOG"‿"LICENSE"‿"README.md"‿"a"
⟩
{𝕊:!"Unexpected files in "∾raylibFolder∾", "∾•Repr filesToBeDeleted
}⍟(0≠≠)¬∘Exists¨⊸/filesToBeDeleted
Remove¨filesToBeDeleted
cleaupErrorMsg ← "Cleanup unsuccessful. Please delete "∾raylibFolder∾" manually "
{cleaupErrorMsg!0‿⟨⟩‿⟨⟩≡•SH"rmdir"⋈Realpath raylibFolder At𝕩}¨"lib"‿"include"‿""
#•file.Remove Realpath raylibFolder
