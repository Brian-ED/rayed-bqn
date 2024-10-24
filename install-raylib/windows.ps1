curl -o "$PSScriptRoot\temp.zip" https://github.com/raysan5/raylib/releases/download/5.0/raylib-5.0_win64_msvc16.zip
Expand-Archive -Force "$PSScriptRoot\temp.zip" "$PSScriptRoot\..\"
