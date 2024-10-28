# Press A to start a blast noise
# Press B to start a slash noise

⟨⟨red, white, black⟩⇐color, window, key, draw, sound
⟩ ← r ← •Import "../../rayed.bqn"

# sets window size to half the monitor size
window.SetSize 0.5

PerFrame ← {
  •term.Flush@
  𝕩 sound.Play∘⊣⍟⊢¨key.IsPressed¨key.a‿key.b
  𝕩 sound.Pause∘⊣⍟⊢¨key.IsPressed¨key.c‿key.d
  𝕩 sound.Resume∘⊣⍟⊢¨key.IsPressed¨key.e‿key.f
  𝕩 sound.Stop∘⊣⍟⊢¨key.IsPressed¨key.g‿key.h
  𝕩 sound.IsPlaying∘⊣⍟⊢¨key.IsPressed¨key.i‿key.j
}⊸⊢draw._withCanvas⟜black

Start ← {𝕤
  sounds ← sound.LoadFromFile¨ •file.At¨ "testSound1.wav"‿"testSound2.wav"
  PerFrame•_While_(¬window.ShouldClose) sounds
} sound._withDevice

Start window._openAs "Hello!!!"