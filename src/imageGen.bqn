⟨
  GradientLinear ⋄ GradientSquare
⟩⇐
# Generate image: linear gradient
# The direction value specifies the direction of the gradient (in degrees)
# with 0 being vertical (from top to bottom), 90 being horizontal (from left to right).
# The gradient effectively rotates counter-clockwise by the specified amount.
GradientLinear ← {𝕊size‿radianDirection‿start‿end: # ⟨i⋄i⟩‿i‿color‿color # Generate image: vertical gradient
  angles ← (•math.Cosf∾•math.Sinf) radianDirection
  >{𝕊i‿j:
    # Calculate the relative position of the pixel along the gradient direction
    pos ← (𝕩⊸×÷○(+´)size⊸×)angles
    factor ← 1⌊0⌈pos

    # Generate the color for this pixel
    (end⊸×+start×¬)factor
  }¨↕size
}


# Generate image: square gradient
GradientSquare ← {𝕊size‿density‿inner‿outer: # ⟨i⋄i⟩‿f‿color‿color # Generate image: square gradient
  center ← size÷2
  >{𝕤
    # Normalize the distances by the dimensions of the gradient rectangle
    normalizedDist ← center÷˜|𝕩-center

    # Calculate the total normalized Manhattan distance
    manhattanDist ← ⌈´normalizedDist

    # makes the gradient start from the center when density is 0, and from the edge when density is 1
    factor ← 1⌊0⌈(manhattanDist⊸-÷¬)density

    # Blend the colors based on the calculated factor
    (outer⊸×+inner×¬)factor

  }¨↕size
}