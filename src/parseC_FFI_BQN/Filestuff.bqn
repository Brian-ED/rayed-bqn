# ask for file path (empty string if user cancelled)
AskForFile ⇐ {𝕤
  "windows"≡•platform.os?
    !0## code
;
  # dropping the newline
  1↓1⊑•SH "zenity"‿"--file-selection"
}
AskForFolder ⇐ {𝕤
  "windows"≡•platform.os?
    !0## code
;
  # dropping the newline
  1↓1⊑•SH "zenity"‿"--file-selection"‿"--directory"
}

{
  •platform.os≡"macos"?
    •Out¨⟨
      "Please install zenity with the following command before continuing:"
      "brew install zenity"
    ⟩
    •Exit@
}
•SHow⊑•SH "zenity"‿"-h"


o ← "y"‿"yes"
ReRunParser⍟(∨´o≡¨•Getline)@

"
first ask for libraylib.so or raylib.dll

regenerate rayffi.bqn? (if file doesn't exist, just straight up ask for location of raylib.h)

"