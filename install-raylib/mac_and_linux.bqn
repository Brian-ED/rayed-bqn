# Expects raylib folder to not exist
(¬•file.Exists "../raylib")!˜"Raylib already installed. Delete raylib to update."
file‿ext ← {
  "darwin": "raylib-5.0_macos"‿".tar.gz"
; "linux": "raylib-5.0_linux_amd64"‿".tar.gz"
} •platform.os

unarchive ← {
  ".tar.gz": {"tar"‿"-xzf"‿𝕩‿"-C"‿".."}
; ".zip": {"unzip"‿"-d"‿"../"‿𝕩}
} ext

!0≡⊑•SH ⟨"wget" ⋄ "-O" ⋄ "./temp"∾ext
  "https://www.github.com/raysan5/raylib/releases/download/5.0/"∾file∾ext
⟩
!0≡⊑•SH Unarchive "temp"∾ext
!0≡⊑•SH "rm"⋈"temp"∾ext
!0≡⊑•SH "mv"‿("../"∾file)‿"../raylib"