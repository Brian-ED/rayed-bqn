# Expects raylib folder to not exist
curl -o temp.zip https://github.com/raysan5/raylib/releases/download/5.0/raylib-5.0_win64_msvc16.zip
Expand-Archive -Force temp.zip ..\ 
remove-Item temp.zip
Rename-Item ..\raylib-5.0_win64_msvc16 -NewName raylib