# Press A to start a blast noise
# Press B to start a blast noise

⟨⟨red, white, black⟩⇐color, window, key, draw, rayffi, sound
⟩ ← r ← •Import "../../raylib.bqn"

# sets window size to half the monitor size
window.SetSize 0.5

PerFrame ← {𝕊bqnoise1‿bqnoise2:
  key.a‿key.b rayffi.PlaySound∘⊢⍟(key.IsPressed⊣)¨ bqnoise1‿bqnoise2
}⊸⊢ draw._withCanvas_ black

Start ← {𝕤
  rayffi.InitAudioDevice ⟨⟩
  bqnoise1‿bqnoise2 ← sound.FromFile¨ •file.At¨ "testSound1.wav"‿"testSound2.wav"
  PerFrame•_While_(¬window.ShouldClose) bqnoise1‿bqnoise2
  rayffi.CloseAudioDevice ⟨⟩
}
Start window._openAs "Hello!!!"