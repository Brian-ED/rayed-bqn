rayFFI⇐•Import "rayffi.bqn"

_bitwise⇐{
  _into⇐{𝕗_𝕣⁼𝕩: 𝕗⊸×⊸+˜´𝕩; 𝕗|⌊∘÷⟜𝕗⍟(↕1+·⌊𝕗⋆⁼1⌈⊢)𝕩}
  𝕗{_𝕣:(𝔽´⌈○≠↑¨⋈)⌾(2 _into)}
}



IsKeyPressed ⇐ {𝕊 key:
  0≠rayFFI.IsKeyPressed-⟜@⍟(∞⊸<)𝕩
}⚇0

image ⇐ {
  Load   ⇐ {𝕊strPath: ⊑rayFFI.LoadImage𝕩∾@} # ⊑ used because LoadImage outputs image‿strPath for unknown reasons.
  Unload ⇐ {𝕊image:  @⊣rayFFI.UnloadImage𝕩}
  _with  ⇐ {(Unload⊢𝔽)Load𝕩}
}


window ⇐ {
  ⟨_init ⋄ Close
   SetIcon ⋄ ClearBackground ⋄ SetToResizable⟩⇐

  _init ← {title _𝕣 posX‿posY: fps←𝕨⊣60
    "𝕩 can only be ints"!∧´⌈⊸=𝕩
    rayFFI.InitWindow 𝕩∾<𝕗∾@
    rayFFI.SetTargetFPS fps
  }
  Close ← rayFFI.WindowShouldClose∘⟨⟩

  ClearBackground ← {𝕊r‿g‿b‿t:
    "ClearBackground only accepts ints as args"!∧´⌈⊸=𝕩
    rayFFI.ClearBackground 𝕩
  }

  SetIcon     ← {rayFFI.SetWindowIcon𝕩}

  # Make this modify window settings instead of overwrite
  SetToResizable ← rayFFI.SetWindowState∘4
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
  # switch to `letter-@` when possible.
  # I'm keeping these for look up and for ease of use.

  kNULL          ⇐ 0        # Key: NULL, used for no key pressed
  # Alphanumeric keys
  kAPOSTROPHE    ⇐ 39       # Key: '
  kCOMMA         ⇐ 44       # Key: ,
  kMINUS         ⇐ 45       # Key: -
  kPERIOD        ⇐ 46       # Key: .
  kSLASH         ⇐ 47       # Key: /
  kZERO          ⇐ 48       # Key: 0
  kONE           ⇐ 49       # Key: 1
  kTWO           ⇐ 50       # Key: 2
  kTHREE         ⇐ 51       # Key: 3
  kFOUR          ⇐ 52       # Key: 4
  kFIVE          ⇐ 53       # Key: 5
  kSIX           ⇐ 54       # Key: 6
  kSEVEN         ⇐ 55       # Key: 7
  kEIGHT         ⇐ 56       # Key: 8
  kNINE          ⇐ 57       # Key: 9
  kSEMICOLON     ⇐ 59       # Key: ;
  kEQUAL         ⇐ 61       # Key: =
  kA             ⇐ 65       # Key: A | a
  kB             ⇐ 66       # Key: B | b
  kC             ⇐ 67       # Key: C | c
  kD             ⇐ 68       # Key: D | d
  kE             ⇐ 69       # Key: E | e
  kF             ⇐ 70       # Key: F | f
  kG             ⇐ 71       # Key: G | g
  kH             ⇐ 72       # Key: H | h
  kI             ⇐ 73       # Key: I | i
  kJ             ⇐ 74       # Key: J | j
  kK             ⇐ 75       # Key: K | k
  kL             ⇐ 76       # Key: L | l
  kM             ⇐ 77       # Key: M | m
  kN             ⇐ 78       # Key: N | n
  kO             ⇐ 79       # Key: O | o
  kP             ⇐ 80       # Key: P | p
  kQ             ⇐ 81       # Key: Q | q
  kR             ⇐ 82       # Key: R | r
  kS             ⇐ 83       # Key: S | s
  kT             ⇐ 84       # Key: T | t
  kU             ⇐ 85       # Key: U | u
  kV             ⇐ 86       # Key: V | v
  kW             ⇐ 87       # Key: W | w
  kX             ⇐ 88       # Key: X | x
  kY             ⇐ 89       # Key: Y | y
  kZ             ⇐ 90       # Key: Z | z
  kLEFT_BRACKET  ⇐ 91       # Key: [
  kBACKSLASH     ⇐ 92       # Key: '\'
  kRIGHT_BRACKET ⇐ 93       # Key: ]
  kGRAVE         ⇐ 96       # Key: `
  # Function keys
  kSPACE         ⇐ 32       # Key: Space
  kESCAPE        ⇐ 256      # Key: Esc
  kENTER         ⇐ 257      # Key: Enter
  kTAB           ⇐ 258      # Key: Tab
  kBACKSPACE     ⇐ 259      # Key: Backspace
  kINSERT        ⇐ 260      # Key: Ins
  kDELETE        ⇐ 261      # Key: Del
  kRIGHT         ⇐ 262      # Key: Cursor right
  kLEFT          ⇐ 263      # Key: Cursor left
  kDOWN          ⇐ 264      # Key: Cursor down
  kUP            ⇐ 265      # Key: Cursor up
  kPAGE_UP       ⇐ 266      # Key: Page up
  kPAGE_DOWN     ⇐ 267      # Key: Page down
  kHOME          ⇐ 268      # Key: Home
  kEND           ⇐ 269      # Key: End
  kCAPS_LOCK     ⇐ 280      # Key: Caps lock
  kSCROLL_LOCK   ⇐ 281      # Key: Scroll down
  kNUM_LOCK      ⇐ 282      # Key: Num lock
  kPRINT_SCREEN  ⇐ 283      # Key: Print screen
  kPAUSE         ⇐ 284      # Key: Pause
  kF1            ⇐ 290      # Key: F1
  kF2            ⇐ 291      # Key: F2
  kF3            ⇐ 292      # Key: F3
  kF4            ⇐ 293      # Key: F4
  kF5            ⇐ 294      # Key: F5
  kF6            ⇐ 295      # Key: F6
  kF7            ⇐ 296      # Key: F7
  kF8            ⇐ 297      # Key: F8
  kF9            ⇐ 298      # Key: F9
  kF10           ⇐ 299      # Key: F10
  kF11           ⇐ 300      # Key: F11
  kF12           ⇐ 301      # Key: F12
  kLEFT_SHIFT    ⇐ 340      # Key: Shift left
  kLEFT_CONTROL  ⇐ 341      # Key: Control left
  kLEFT_ALT      ⇐ 342      # Key: Alt left
  kLEFT_SUPER    ⇐ 343      # Key: Super left
  kRIGHT_SHIFT   ⇐ 344      # Key: Shift right
  kRIGHT_CONTROL ⇐ 345      # Key: Control right
  kRIGHT_ALT     ⇐ 346      # Key: Alt right
  kRIGHT_SUPER   ⇐ 347      # Key: Super right
  kKB_MENU       ⇐ 348      # Key: KB menu
  # Keypad keys
  kKP_0          ⇐ 320      # Key: Keypad 0
  kKP_1          ⇐ 321      # Key: Keypad 1
  kKP_2          ⇐ 322      # Key: Keypad 2
  kKP_3          ⇐ 323      # Key: Keypad 3
  kKP_4          ⇐ 324      # Key: Keypad 4
  kKP_5          ⇐ 325      # Key: Keypad 5
  kKP_6          ⇐ 326      # Key: Keypad 6
  kKP_7          ⇐ 327      # Key: Keypad 7
  kKP_8          ⇐ 328      # Key: Keypad 8
  kKP_9          ⇐ 329      # Key: Keypad 9
  kKP_DECIMAL    ⇐ 330      # Key: Keypad .
  kKP_DIVIDE     ⇐ 331      # Key: Keypad /
  kKP_MULTIPLY   ⇐ 332      # Key: Keypad *
  kKP_SUBTRACT   ⇐ 333      # Key: Keypad -
  kKP_ADD        ⇐ 334      # Key: Keypad +
  kKP_ENTER      ⇐ 335      # Key: Keypad Enter
  kKP_EQUAL      ⇐ 336      # Key: Keypad =
  kBACK          ⇐ 4        # Key: Android back button
  kMENU          ⇐ 82       # Key: Android menu button
  kVOLUME_UP     ⇐ 24       # Key: Android volume up button
  kVOLUME_DOWN   ⇐ 25       # Key: Android volume down button
}