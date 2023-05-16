### THIS FILE IS NOT MEANT TO BE RAN. 
### IT'S A DOCUMENTATION FILE WITH .bqn EXTENSION FOR HIGHLIGHTING

### Contributors may add brainstorms (they're numbered). Removing contributions of others is discouraged.

# 1; This brainstorm is ongoing 
# layouts for basic function use


# current
text black draw._Text_ fontSize 20‿20

{𝕤
    fontSize draw.Text text
} _colored_ c.black _At_ 20‿20 @
# _colored_ would be similar to draw._with c.black,
# where there would be stored state that would be reverted when 𝕗 is done.
# _at_ changes relative position,
# while _colored_ changes either just simply color, or relative color?

# Could also be formatted like this, though related words are spread appart like draw.Text and text.
fontSize draw.Text _colored_ black _At_ 20‿20 text

# or this?
(fontSize draw.Text text˙) _colored_ c.black _At_ 20‿20 @

# stacking mutluple _At_'s has the effect of adding positions to window.pos

# 2; This brainstorm is on-going
"
have a global index list which is the list that gets inputted to perFrame.
perFrame sequencually applies each function on 𝕩 under variables which each represent an index of the global list.

# global index list
⟨poses, ⟩ ← ↕1

"