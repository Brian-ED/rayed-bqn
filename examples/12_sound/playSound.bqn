# Press A to start raylib blast noise
# Press space to start BQNoise blast noise

⟨⟨red, white, black⟩⇐color, window, key, draw, rayffi, sound
⟩ ← r ← •Import "../../raylib.bqn"

# sets window size to half the monitor size
window.SetSize 0.5

PerFrame ← {𝕊bqnoise1‿raylib1‿bqnoise2‿raylib2:
  rayffi.PlaySound⍟(key.IsPressed key.a) bqnoise1
  rayffi.PlaySound⍟(key.IsPressed key.b) raylib1
  rayffi.PlaySound⍟(key.IsPressed key.c) bqnoise2
  rayffi.PlaySound⍟(key.IsPressed key.d) raylib2
}⊸⊢ draw._withCanvas_ black

Start ← {𝕤
  rayffi.InitAudioDevice ⟨⟩
  bqnoise1 ← sound.FromFile •file.At "testSound1.wav"
  bqnoise2 ← sound.FromFile •file.At "testSound2.wav"
  raylib1  ← rayffi.LoadSound •file.At "testSound1.wav"
  raylib2  ← rayffi.LoadSound •file.At "testSound2.wav"
  PerFrame•_While_(¬window.ShouldClose) bqnoise1‿raylib1‿bqnoise2‿raylib2
  rayffi.CloseAudioDevice ⟨⟩
}
Start window._openAs "Hello!!!"