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
# Lots of game-engines i see around the place have a tree structure.
# Godot has nodes, with parents and children
# unity has a similar parent system.

# i would like to see the benifits of tree structures.
# try to find out a functional pattern to achive whatever they accomplish.
 
# one thing that could work would be having functions be 
# executing its children sequentually (children and parents being functions)
# and the output of the children would be their data such as position.
# these positions would be collected into the usual position arrays of [x‿x1‿x2‿...⋄ y‿y1‿y2‿...]
# which would all be used by the parent.


# after looking a bit into godot, it seems that most of the uses of 
# nodes can be accomplished through •Import, importing functions that would 
# accomplish camera movement, skeleton, and such. 
