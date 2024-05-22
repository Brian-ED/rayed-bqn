# Expects raylib folder to not exist
if (1 - (Test-Path -Path "$PSScriptRoot\..\raylib") ) {
  $folder = "$PSScriptRoot\raylib-5.0_linux_amd64"
  if (Test-Path -Path $folder ) {
    Remove-Item -Path $folder -Recurse -Force
  }
  curl -o "$PSScriptRoot\temp.zip" https://github.com/raysan5/raylib/releases/download/5.0/raylib-5.0_win64_msvc16.zip
  Expand-Archive -Force "$PSScriptRoot\temp.zip" "$PSScriptRoot\..\"
  remove-Item "$PSScriptRoot\temp.zip"
  Rename-Item "$PSScriptRoot\..\raylib-5.0_win64_msvc16" -NewName "raylib"
}