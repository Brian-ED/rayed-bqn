⟨RP⇐Realpath⋄At⟩ ← •file

# Expects raylib folder to not exist
(¬•file.Exists "../raylib")!˜"Raylib already installed. Delete raylib to update."
file‿ext ← {
  "darwin": "raylib-5.0_macos"‿".tar.gz"
; "linux": "raylib-5.0_linux_amd64"‿".tar.gz"
} •platform.os

unarchive ← {
  ".tar.gz": {"tar"‿"-xzf"‿𝕩‿"-C"‿(RP"..")}
; ".zip": {"unzip"‿"-d"‿(RP"..")‿𝕩}
} ext

!0≡⊑•SH ⟨"wget" ⋄ "-O" ⋄ At"temp"∾ext
  "https://www.github.com/raysan5/raylib/releases/download/5.0/"∾file∾ext
⟩
!0≡⊑•SH Unarchive RP"temp"∾ext
!0≡⊑•SH "rm"⋈RP"temp"∾ext
!0≡⊑•SH ⟨"mv" ⋄ RP ".."•file.At file ⋄ At "../raylib"⟩