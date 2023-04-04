
# SPDX-License-Identifier: AGPL-3.0-or-later
# SPDX-FileCopyrightText: 2022 Rampoina <rampoina@protonmail.com>
#
# Sokobqn
# The level is a 2d matrix of lists (tiles)
# Each list contains the objects of the game:
# 0: floor, 1: player, 2: box, 3: goal, 4: wall
# 4: player on goal, 5: box on goal
#
# Example:                              ASCII:
# ┌─                                    ┌─
# ╵ ⟨ 4 ⟩ ⟨ 4 ⟩   ⟨ 4 ⟩   ⟨ 4 ⟩ ⟨ 4 ⟩   ╵"#####
#   ⟨ 4 ⟩ ⟨ 1 0 ⟩ ⟨ 2 0 ⟩ ⟨ 0 ⟩ ⟨ 4 ⟩     #@*.#
#   ⟨ 4 ⟩ ⟨ 4 ⟩   ⟨ 4 ⟩   ⟨ 4 ⟩ ⟨ 4 ⟩     #####"
#                                     ┘         ┘
moves←⟨0‿0⟩ # list of moves, each move is a direction, we start without moving
chars←" @$.+*#" # legal characters


SplitOnEmpty←{𝕩⊔˜(⊢-˜+`×¬)0=≠¨𝕩}
Ascii2Matrix←{(⊑chars⊐𝕩)⊑⟨≍0,1‿0,2‿0,≍3,1‿3,2‿3,≍6⟩}¨(⊢↑˝·≍⟜¬2+≢)

# 𝕨 Tiles 𝕩 | 𝕩: object coordinate (3‿1) |  𝕨: direction vector (¯1‿0)
# result: ⟨ ⟨ 3 1 ⟩ ⟨ 2 1 ⟩ ⟨ 1 1 ⟩ ⟩
# returns 3 tiles in the specified direction from the
Tiles←{⟨𝕩,𝕩+𝕨,𝕩+2×𝕨⟩} # given object (including itself)

Player←{⊑/○⥊⟜(↕≢)1⍷⊑¨𝕩} # Player 𝕩 | 𝕩:level | returns the coordinate of the [P]layer

# Move 𝕩 | 𝕩: ⟨⟨1,0⟩,⟨0⟩⟩ (2 tiles) | result: ⟨⟨0⟩,⟨1,0⟩⟩
# Move the first object in the first tile to the second tile. 
# Only move Player/Box -> Floor/Goal
# the second tile can't be a box because we moved it previously
# if it is it means that the box was unmovable (next to a wall) so we do nothing
Move←{a‿b:⟨1↓a,(⊑a)∾b⟩}⍟{∨´(⥊1‿2≍⌜0‿3)≡⌜<⊑¨𝕩}

# Push 𝕩 | 𝕩: ⟨⟨1,0⟩,⟨2,0⟩,⟨0,0)⟩ (3 tiles) | result: ⟨⟨0⟩,⟨1,0⟩,⟨2,0)⟩
# Given 3 tiles try to [P]ush the second tile (possible box) 
# and afterwards try to move the first one (player) if possible
Push←Move⌾(2↑⊢)Move⌾(1↓⊢) 

S←{Push⌾((𝕨 Tiles Player 𝕩 )⊸⊑)𝕩} # 𝕨 S 𝕩 | 𝕨: direction | 𝕩:level | Step the game
Draw←{chars⊏˜+´¨𝕨 S´ ⌽𝕩} # 𝕨 Draw 𝕩 | 𝕨: levels | 𝕩: moves | Draw the game in ASCII
W←{(2≡¨⊑¨𝕩) =○(+´⥊) (<2‿3)≡¨𝕩} # W 𝕩 | 𝕩: level | [W]in condition
N←{moves↩moves∾<𝕩}
Undo←{𝕊:moves↩(-1<≠)⊸↓moves}
While ← {𝕨{𝕊∘𝔾⍟𝔽𝕩}𝕩@}´

# Main loop
levels←Ascii2Matrix¨>¨SplitOnEmpty•FLines "levels.txt" # Load file containing levels
currentLevel←0
•term.RawMode 1 # set terminal to raw mode
•Out "[?25l[2J[H" # Cursor to origin, hide it and clear screen
clear←""
While {𝕤⋄currentLevel<≠levels}‿{𝕤 # Loop until the user wins
  •Out "[H" # Cursor to origin
  •Out "Level: "∾•Repr 1+currentLevel
  •Out "7"  # Save cursor position
  •Out "Controls: (hjkl) to move, u to undo, r to reset level"
  •Out˘ (currentLevel⊑levels) Draw moves
  key←•term.CharB @
  {𝕤⋄N ⊑("hjkl"=key)/⟨0‿¯1,1‿0,¯1‿0,0‿1⟩}⍟(⊑key∊"hjkl")@
  {𝕤⋄Undo @}⍟(key='u')@
  {𝕤⋄•Out "[?12l[?25h"⋄•Exit 0}⍟(key='q')@
  {𝕤⋄moves↩⟨0‿0⟩}⍟(key='r')@
  {𝕤⋄clear↩"[2J"}⍟(((1⊸+>○(⌊1+10⋆⁼1⌈⊢)⊢)¯1+≠moves)∧key='u')@
  •Out "8" # Restore cursor position
  {𝕤⋄•Out clear∾"Controls: (hjkl) to move, u to undo, r to reset level"}⍟(⊑key∊"hjkluqr")@
  {𝕤⋄•Out "Invalid key: (hjkl) to move, u to undo, r to reset level"}⍟(¬⊑key∊"hjkluqr")@
  •Out˘ (currentLevel⊑levels) Draw moves
  •Out "Moves: "∾•Repr ¯1+≠moves
  {𝕤⋄•Out "[H"⋄currentLevel↩currentLevel+1⋄moves↩⟨0‿0⟩}⍟(W (currentLevel⊑levels) S´⌽moves)@
}
•Out "Well played, you win!"
•Out "[?12l[?25h"
