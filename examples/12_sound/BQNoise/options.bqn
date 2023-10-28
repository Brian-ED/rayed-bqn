fBytes ⇐ •BQN"•FBytes"
fmt  ⇐ 1‿16      # Format: 16-bit integer
freq ⇐ 44100     # Frequency: 44.1kHz
Set ⇐ {fmt‿freq↩𝕩}
SetFBytes ⇐ {FBytes↩𝕏}
SetFreq ⇐ {freq↩𝕩}

# For generating random waveforms; result is a shape 𝕩 array of uniform
# random numbers between 0 and 1
RandFloats ⇐ (•BQN⎊(•rand˙) "•MakeRand 1").Range⟜0

# For reading/writing wave files
warn_dither ⇐ 0  # Whether to warn on non-integer signal
warn_clip   ⇐ 1  # Whether to warn on out-of-bounds signal
Dither ⇐ ⌊ (-˝ ·RandFloats 2∾≢)⊸+
Resample ⇐ { 𝕨 (resample ↩ •Import "soxresample.bqn"){𝔽} 𝕩 }