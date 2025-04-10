#!usr/bin/env bqn
⟨Realpath⋄At⋄Exists⋄CreateDir⋄Remove⋄List⋄Bytes⋄path⟩ ← •file
⟨os⟩←•platform
version ← "5.5"
binariesPath ← "lib"

⟨               ext     ⋄ libFile         ⋄ raylibFolder
⟩←{"darwin":  ⟨".tar.gz"⋄"libraylib.dylib"⋄"raylib-"∾version∾"_macos"       ⟩
;  "linux":   ⟨".tar.gz"⋄"libraylib.so"   ⋄"raylib-"∾version∾"_linux_amd64" ⟩
;  "windows": ⟨".zip"   ⋄"raylib.dll"     ⋄"raylib-"∾version∾"_win64_msvc16"⟩
} os

git_clone_path ← "https://www.github.com/raysan5/raylib/releases/download/"∾version∾"/"∾raylibFolder∾ext

# Expected library to not exist
!∘{𝕊:"raylib already installed. Delete it to re-install.
  rm "∾(Realpath 𝕩)∾"
"}⍟Exists binariesPath At libFile

# ---------------
# download raylib
# ---------------

Exec ← {e‿·‿o:o!0≡e}•SH

# Download raylib zip/tar file
Exec {"windows"≡os?
  ⟨
    "Powershell.exe" ⋄ "-Command"
    "curl -o """∾(At"temp"∾ext)∾""" "∾git_clone_path
  ⟩
;
  ⟨"curl" ⋄ "-o" ⋄ At"temp"∾ext ⋄ git_clone_path, "-L"⟩
}
"Downloading raylib failed from github failed. Likely due to redirects not being followed."!⟨⟩≢•FBytes "temp"∾ext

# unzip/untar/unarchive raylib
# tar on windows handles zip files, while mac/linux get raylib as tar.gz files
Exec ⟨"tar" ⋄ "-xzf"⋄Realpath"temp"∾ext ⋄ "-C"⋄path⟩
Remove Realpath"temp"∾ext
"Extracting raylib failed"!Exists raylibFolder At "lib" At libFile

# ---------------------
# Copy binary file to binariesPath
# ---------------------
CreateDir⍟(¬Exists) binariesPath
(binariesPath At libFile) Bytes Bytes Realpath raylibFolder At "lib" At libFile

# -----------------
# Clean away raylib
# -----------------
filesToBeDeleted ← raylibFolder⊸At¨ ∾⟨
  "lib"    ⊸At¨•file.List raylibFolder At"lib"
  "include"⊸At¨"raylib.h"‿"raymath.h"‿"rlgl.h"
  "CHANGELOG"‿"LICENSE"‿"README.md"
⟩
!∘{𝕊:"Unexpected files in "∾raylibFolder∾", "∾•Repr filesToBeDeleted
}⍟(0≠≠)¬∘Exists¨⊸/filesToBeDeleted
Remove¨filesToBeDeleted
cleaupErrorMsg ← "Cleanup unsuccessful. Please delete "∾raylibFolder∾" manually "
RMDirCmd ← {
  os≡"windows"?
    ⟨"Powershell.exe" ⋄ "-Command" ⋄ "RD '"∾𝕩∾"'"⟩
; "rmdir"⋈𝕩
}
{cleaupErrorMsg!0‿⟨⟩‿⟨⟩≡•SH RMDirCmd Realpath raylibFolder At𝕩}¨"lib"‿"include"‿""

•Out "raylib installed successfully"
