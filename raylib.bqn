rayFFI⇐•Import "rayffi.bqn"

IsInt ← {(⌈⟜=𝕩)!˜" has to be int"∾˜𝕨⊣"𝕩"}

_bitwise⇐{
  _into←{𝕗_𝕣⁼𝕩: 𝕗⊸×⊸+˜´𝕩; 𝕗|⌊∘÷⟜𝕗⍟(↕1+·⌊𝕗⋆⁼1⌈⊢)𝕩}
  𝕗{_𝕣:(𝔽´⌈○≠↑¨⋈)⌾(2 _into)}
}

IsKeyPressed ⇐ {𝕊 key:
  0≠rayFFI.IsKeyPressed-⟜@⍟(∞⊸<)𝕩
}⚇0

image ⇐ {
  Load   ⇐ {𝕊strPath: ⊑rayFFI.LoadImage𝕩∾@} # ⊑ used because LoadImage outputs image‿strPath for unknown reasons.
  Unload ⇐ {𝕊image:    rayFFI.UnloadImage𝕩}
  _with  ⇐ {(Unload⊢𝔽)Load𝕩}
}


window ⇐ {
  ⟨_init ⋄ Close
   SetIcon ⋄ SetBackground ⋄ SetToResizable⟩⇐

  Init ← {posX‿posY 𝕊 title: 
    "𝕩 can only be ints"!∧´⌈⊸=𝕩
    rayFFI.InitWindow (𝕨⊣2⥊1000)∾<𝕩∾@
    rayFFI.SetTargetFPS 60
  }
  Close ← rayFFI.WindowShouldClose∘⟨⟩
  SetBackground ← {𝕊r‿g‿b‿t:
    (∧´𝕩∊↕256)!˜"ClearBackground only accepts ints in the range 0-255 inclusive"
    rayFFI.ClearBackground 𝕩
  }
  # Needs to test input for image
  SetIcon ← {rayFFI.SetWindowIcon𝕩}

  # Make this modify window settings instead of overwrite
  Setting ← {
     𝕊"fps":rayFFI.GetFPS⟨⟩
   ;𝕨𝕊"fps":
      "𝕩 has to be int"!1≡⌈⊸=𝕩
      rayFFI.SetTargetFPS 𝕩
   ;𝕨𝕊"resize":
      "𝕩 has to be 0 or 1"!1<⊸≡𝕨∊↕2
      rayFFI.SetWindowState𝕩×4
    𝕊"resize":
    isWindowState 
  }
}

draw ⇐ { 
  ⟨Start ⋄ End ⋄ _with 
   _Circle ⋄ _Rectangle⟩⇐

  Start ← rayFFI.EndDrawing  ∘⟨⟩
  End   ← rayFFI.BeginDrawing∘⟨⟩
  _with ← {End𝔽𝕩⊣Start@}

  _Circle ← {radius ⟨r,g,b,t⟩_𝕣 posX‿posY :
    "only accepts ints as args"    !∧´⌊⊸=a←𝕩∾𝕨∾𝕗
    "Incorrect amount of arguments"!7=≠a
    rayFFI.DrawCircle ⌊𝕩∾𝕨‿𝕗
  }

  _Rectangle ← {width‿height ⟨r,g,b,t⟩_𝕣 posX‿posY :
    "Rectangle only accepts ints as args"!∧´⌈⊸=a←𝕩∾𝕨∾𝕗
    rayFFI.DrawRectangle ⌊(𝕩∾𝕨)∾<𝕗
  }
}


c ⇐ {
  white⇐4⥊255 ⋄ black⇐¯4↑255
  [red    ‿green ‿blue
   magenta‿yellow‿cyan]⇐255×1∾˜¨⍉(-↕3)⌽⌜⋈⟜¬3↑1
}

k ⇐ {
  # consider switching to `letter-@` when possible.

# vars           Keycodes   Keys
  kNULL          ⇐ 0        # NULL, used for no key pressed
  # Alphanumeric keys
  kAPOSTROPHE    ⇐ 39       # '
  kCOMMA         ⇐ 44       # ,
  kMINUS         ⇐ 45       # -
  kPERIOD        ⇐ 46       # .
  kSLASH         ⇐ 47       # /
  kZERO          ⇐ 48       # 0
  kONE           ⇐ 49       # 1
  kTWO           ⇐ 50       # 2
  kTHREE         ⇐ 51       # 3
  kFOUR          ⇐ 52       # 4
  kFIVE          ⇐ 53       # 5
  kSIX           ⇐ 54       # 6
  kSEVEN         ⇐ 55       # 7
  kEIGHT         ⇐ 56       # 8
  kNINE          ⇐ 57       # 9
  kSEMICOLON     ⇐ 59       # ;
  kEQUAL         ⇐ 61       # =
  kA             ⇐ 65       # A | a
  kB             ⇐ 66       # B | b
  kC             ⇐ 67       # C | c
  kD             ⇐ 68       # D | d
  kE             ⇐ 69       # E | e
  kF             ⇐ 70       # F | f
  kG             ⇐ 71       # G | g
  kH             ⇐ 72       # H | h
  kI             ⇐ 73       # I | i
  kJ             ⇐ 74       # J | j
  kK             ⇐ 75       # K | k
  kL             ⇐ 76       # L | l
  kM             ⇐ 77       # M | m
  kN             ⇐ 78       # N | n
  kO             ⇐ 79       # O | o
  kP             ⇐ 80       # P | p
  kQ             ⇐ 81       # Q | q
  kR             ⇐ 82       # R | r
  kS             ⇐ 83       # S | s
  kT             ⇐ 84       # T | t
  kU             ⇐ 85       # U | u
  kV             ⇐ 86       # V | v
  kW             ⇐ 87       # W | w
  kX             ⇐ 88       # X | x
  kY             ⇐ 89       # Y | y
  kZ             ⇐ 90       # Z | z
  kLEFT_BRACKET  ⇐ 91       # [
  kBACKSLASH     ⇐ 92       # '\'
  kRIGHT_BRACKET ⇐ 93       # ]
  kGRAVE         ⇐ 96       # `
  # Function keys
  kSPACE         ⇐ 32       # Space
  kESCAPE        ⇐ 256      # Esc
  kENTER         ⇐ 257      # Enter
  kTAB           ⇐ 258      # Tab
  kBACKSPACE     ⇐ 259      # Backspace
  kINSERT        ⇐ 260      # Ins
  kDELETE        ⇐ 261      # Del
  kRIGHT         ⇐ 262      # Cursor right
  kLEFT          ⇐ 263      # Cursor left
  kDOWN          ⇐ 264      # Cursor down
  kUP            ⇐ 265      # Cursor up
  kPAGE_UP       ⇐ 266      # Page up
  kPAGE_DOWN     ⇐ 267      # Page down
  kHOME          ⇐ 268      # Home
  kEND           ⇐ 269      # End
  kCAPS_LOCK     ⇐ 280      # Caps lock
  kSCROLL_LOCK   ⇐ 281      # Scroll down
  kNUM_LOCK      ⇐ 282      # Num lock
  kPRINT_SCREEN  ⇐ 283      # Print screen
  kPAUSE         ⇐ 284      # Pause
  kF1            ⇐ 290      # F1
  kF2            ⇐ 291      # F2
  kF3            ⇐ 292      # F3
  kF4            ⇐ 293      # F4
  kF5            ⇐ 294      # F5
  kF6            ⇐ 295      # F6
  kF7            ⇐ 296      # F7
  kF8            ⇐ 297      # F8
  kF9            ⇐ 298      # F9
  kF10           ⇐ 299      # F10
  kF11           ⇐ 300      # F11
  kF12           ⇐ 301      # F12
  kLEFT_SHIFT    ⇐ 340      # Shift left
  kLEFT_CONTROL  ⇐ 341      # Control left
  kLEFT_ALT      ⇐ 342      # Alt left
  kLEFT_SUPER    ⇐ 343      # Super left
  kRIGHT_SHIFT   ⇐ 344      # Shift right
  kRIGHT_CONTROL ⇐ 345      # Control right
  kRIGHT_ALT     ⇐ 346      # Alt right
  kRIGHT_SUPER   ⇐ 347      # Super right
  kKB_MENU       ⇐ 348      # KB menu
  # Keypad keys
  kKP_0          ⇐ 320      # Keypad 0
  kKP_1          ⇐ 321      # Keypad 1
  kKP_2          ⇐ 322      # Keypad 2
  kKP_3          ⇐ 323      # Keypad 3
  kKP_4          ⇐ 324      # Keypad 4
  kKP_5          ⇐ 325      # Keypad 5
  kKP_6          ⇐ 326      # Keypad 6
  kKP_7          ⇐ 327      # Keypad 7
  kKP_8          ⇐ 328      # Keypad 8
  kKP_9          ⇐ 329      # Keypad 9
  kKP_DECIMAL    ⇐ 330      # Keypad .
  kKP_DIVIDE     ⇐ 331      # Keypad /
  kKP_MULTIPLY   ⇐ 332      # Keypad *
  kKP_SUBTRACT   ⇐ 333      # Keypad -
  kKP_ADD        ⇐ 334      # Keypad +
  kKP_ENTER      ⇐ 335      # Keypad Enter
  kKP_EQUAL      ⇐ 336      # Keypad =
  kBACK          ⇐ 4        # Android back button
  kMENU          ⇐ 82       # Android menu button
  kVOLUME_UP     ⇐ 24       # Android volume up button
  kVOLUME_DOWN   ⇐ 25       # Android volume down button
}