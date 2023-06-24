r←•Import "../../raylib.bqn"
Get‿Set←r.clipboard
string←"⍉↕⍉⊐⍉○↕⍉⍉⥊⥊⥊"
{𝕤
  •Show Get@ # show whatever is on the clipboard currently.
  Set string # Setting clipboard text to the string.
  •Show Get@ # should output the string variable.
}r.window._openAs""