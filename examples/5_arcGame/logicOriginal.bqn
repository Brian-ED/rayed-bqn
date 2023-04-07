#!/usr/bin/env BQN
# SPDX-License-Identifier: AGPL-3.0-or-later
# SPDX-FileCopyrightText: 2023 Rampoina <rampoina@protonmail.com>

⟨FindIdx,SplitOnEmpty⟩←•Import "utils.bqn"

Game⇐{ # The Game function creates a game object
  𝕊 n‿levelPath‿dchars‿chars‿colors: # from parameters:
  # n: starting level
  # levelPath: the path of the file containing the levels
  # dchars: the characters to use for drawing
  # chars: the characters that are used in the level representation
  # colors: a list with colors

  # Game representation:
  # -------------------------------------------------------------------------------
  # The game has the following objects represented as consecutive integers:
  ⟨floor,player,box,machine,pmachine,wall,lmirror,rmirror,hbeam,vbeam,xbeam,llaser,rlaser,ulaser,dlaser⟩⇐↕≠chars

  mirrors⇐lmirror‿rmirror # the mirrors to reflect
  beams←hbeam‿vbeam‿xbeam # the laser beams
  lasers←llaser‿rlaser‿ulaser‿dlaser # shot by the laser
  # Each with every possible orientation

  # There are *movable* objects like the following:
  movables←player‿box∾mirrors # player, box and mirrors

  # And *opaque* objects which don't reflect lasers:
  opaque←player‿box‿machine‿wall∾lasers

  # *Empty* objects can contain other ones on top:
  empties←floor∾beams
  
  # We use a list of game objects (ints) to represent each tile
  lTiles←{⊑𝕩∊movables ? 
           𝕩‿floor; # the movables are on top of the floor (list of 2 elements)
           ≍𝕩 # And the rest are a list of just that element
         }¨↕≠chars 

  # We transform each character into its tile representation and we transform
  # it into a 2d matrix
  # the matrix is padded to ensure that that we can always get 3 tiles
  # centered on the player and pointing to the current direction
  Ascii2Matrix←{(⊑chars⊐𝕩)⊑lTiles}¨(⊢↑˝·≍⟜¬2+≢) # 𝕩 : Matrix of characters

  # Rules:
  # -------------------------------------------------------------------------------
  #
  # --- Rule 1: -------------------------------------------------------------------
  # - The player can push but not pull any movable object one tile away in the
  #   current direction to an empty tile:

  # 𝕩: ⟨⟨1,0⟩,⟨0⟩⟩ (2 tiles) | result: ⟨⟨0⟩,⟨1,0⟩⟩
  # (Try to) Move the first object in the first tile to the second tile.
  # Only move *movable* tile → *empty* tile
  # the second tile can't be a movable object because we moved it previously
  # if it is it means that the object was unmovable (next to a wall) so we do nothing
  Move←{a‿b:⟨1↓a,(⊑a)∾b⟩}⍟{∨´(⥊movables≍⌜empties)≡⌜<⊑¨𝕩}
  
  # 𝕩: ⟨⟨1,0⟩,⟨2,0⟩,⟨0,0)⟩ (3 tiles) | result: ⟨⟨0⟩,⟨1,0⟩,⟨2,0)⟩
  # Given 3 tiles try to Push the second tile (possibly a movable object)
  # and afterwards try to move the first one (the player) if possible
  Push←Move⌾(2↑⊢)Move⌾(1↓⊢)

  # 𝕩: object coordinate (3‿1) |  𝕨: direction vector (¯1‿0)
  # result: ⟨ ⟨ 3 1 ⟩ ⟨ 2 1 ⟩ ⟨ 1 1 ⟩ ⟩
  # returns 3 tiles in the specified direction from the
  Tiles←{⟨𝕩,𝕩+𝕨,𝕩+2×𝕨⟩} # given object (including itself)

  # We (try to) push the tile in front of the player
  Step←{Push⌾((𝕨 Tiles ⊑player FindIdx ⊑¨𝕩)⊸⊑)𝕩} # 𝕨 S 𝕩 | 𝕨: direction | 𝕩:level | Step the game

  # - The lasers shoot lasers beams that get intercepted by opaque objects and
  #   bounce on mirrors:

  # w‿d Bounce x | x: map | w‿d: w: current position, d: direction of the laser
  # Calculates the bounces of a laser beam recursively
  Bounce←{(w‿d)S x:{ # Base case:
    ⊑opaque∊˜⊑w⊑x? # When the beam touches an opaque object (not a mirror):

      (machine=⊑w⊑x)◶⟨ # if it's not a machine:
          x,           # we do nothing
         ⟨pmachine⟩˙⌾(w⊸⊑)x # and if it is, we change it to a powered machine
         ⟩@; # and the recursion stops

      ⊑empties∊˜⊑w⊑x ? # When the beam passes through an empty space:

        # we draw the laser beam and recurse to the next:
        ⟨w+d,d⟩S{ # we choose the type of laser beam to draw
          cTile←(floor‿hbeam‿vbeam‿xbeam⊐𝕩) # depending on the current tile:
          #                            floor hbeam vbeam xbeam  |  floor hbeam vbeam xbeam  
          cBeam←    ((×⊑d)    ⊑       ⟨hbeam‿hbeam‿xbeam‿xbeam  ,  vbeam‿xbeam‿vbeam‿xbeam⟩)
          # and  beam direction        Horizontal               |  Vertical
          cTile⊏cBeam
        }⌾(w⊸⊑)x;

        # When the beam touches a mirror:
        d←⌽d×-⊸¬lmirror=⊑w⊑x # calculate the mirror bounce direction
        ⟨w+d,d⟩S x           # and recurse to the next position
      } 
  }
  
  # We find each laser machine and shoot a beam in its direction
  # Shoot 𝕩 | 𝕩: map | calculates the bounces for each laser
  Shoot←{𝕩 {𝕨Bounce´⌽𝕩} ∾⟨<0‿¯1,<0‿1,<¯1‿0,<1‿0⟩(⊣⋈˜¨+)¨ FindIdx⟜(⊑¨𝕩)¨ lasers}

  # --- Rule 2: -------------------------------------------------------------------
  # - The Player wins when all machines are powered:
  Win←{¬∨´∨˝machine=⊑¨Shoot 𝕩}# 𝕩: level | Win condition, no unpowered machines after shooting laser


  # Drawing:
  # -------------------------------------------------------------------------------

  # Colors:
  # The parameter 'color' is a list of colors passed to the Game function to alter the
  cols←(≠chars)⥊<(⊑colors)       # base color,
  cols (1⊑colors)˙⌾(pmachine⊸⊑)↩ # the color for the powered machine
  cols (2⊑colors)¨⌾(mirrors⊸⊏)↩  # the color for the mirrors
  cols (3⊑colors)¨⌾(beams⊸⊏)↩    # the color for the laser beams

  Color⇐{(𝕩⊑cols)∾𝕩⊑dchars}  # 𝕩: game Object (int) | draw object with color
  DrawLevel←{∾´¨<˘Color¨+´¨Shoot 𝕨 Step´ ⌽𝕩} # 𝕨 Draw 𝕩 | 𝕨: levels | 𝕩: moves | Draw the game in ASCII

  # State and state mutating functions:
  # -------------------------------------------------------------------------------

  moves⇐⟨0‿0⟩ # list of moves, each move is a direction, we start without moving
  currentLevel⇐n-1
  "Invalid number of fchars" ! 15=≠chars
  "Invalid number of chars"  ! 15=≠dchars
  "The level file contains illegal characters" ! ∧´chars∊˜∾´•Flines levelPath
  levels←Ascii2Matrix¨>¨SplitOnEmpty•FLines levelPath # Load file containing levels
  "Some levels don't contain any player" ! ¬∨´0=≠¨{player FindIdx ⊑¨𝕩}¨levels
  "Some levels don't contain any machine" ! ¬∨´0=≠¨{machine FindIdx ⊑¨𝕩}¨levels
  "The starting level is higher than the number of levels" !  currentLevel<≠levels
  Next⇐{moves↩moves∾<𝕩}
  Undo⇐{𝕊:moves↩(-1<≠)⊸↓moves}
  Draw⇐{𝕊:•Out¨ (currentLevel⊑levels) DrawLevel moves}
  WinLevel⇐{𝕊:Win(currentLevel⊑levels)Step´⌽moves}
  Reset⇐{𝕊:moves↩⟨0‿0⟩}
  NextLevel⇐{𝕊:currentLevel↩currentLevel+1⋄Reset @}
  Over⇐{𝕊:currentLevel<≠levels} # has the user beaten all of the levels?
}
