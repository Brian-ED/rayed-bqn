# Press A to start a blast noise
# Press B to start a slash noise

⟨⟨red, white, black⟩⇐color, window, key, draw, sound
⟩ ← r ← •Import "../../rayed.bqn"

# sets window size to half the monitor size
window.SetSize 0.5

PerFrame ← {
  𝕩 sound.Play∘⊣⍟⊢¨key.IsPressed¨key.a‿key.b
}⊸⊢ draw._withCanvas_ black

Start ← {𝕤
  sounds ← sound.LoadFromFile¨ •file.At¨ "testSound1.wav"‿"testSound2.wav"
  PerFrame•_While_(¬window.ShouldClose) sounds
} sound._withAudio

Start window._openAs "Hello!!!"