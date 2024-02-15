# Press A to start a blast noise
# Press B to start a slash noise

⟨⟨red, white, black⟩⇐color, window, key, draw, sound
⟩ ← r ← •Import "../../raylib.bqn"

# sets window size to half the monitor size
window.SetSize 0.5

PerFrame ← {
  key.a‿key.b sound.Play∘⊢⍟(key.IsPressed⊣)¨𝕩
}⊸⊢ draw._withCanvas_ black

Start ← {𝕤
  sounds ← sound.FromFile¨ •file.At¨ "testSound1.wav"‿"testSound2.wav"
  PerFrame•_While_(¬window.ShouldClose) sounds
} sound._withAudio

Start window._openAs "Hello!!!"