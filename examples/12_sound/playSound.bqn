# Press A to start raylib blast noise
# Press space to start BQNoise blast noise

⟨⟨red, white, black⟩⇐color, window, key, draw, rf⇐rayffi
⟩ ← r ← •Import "../../raylib.bqn"
noise ← •Import "BQNoise/wav.bqn"
options ← •Import "BQNoise/options.bqn"

# sets window size to half the monitor size
window.SetSize 0.5

# Wave, audio wave data
wave ← {
  Load ⇐ {𝕊filename:
    bqnSound ← {
      freq‿format‿bqnSound ← noise.ReadFull filename
      ÷⟜(2⋆¯16+1⊑format) bqnSound options.Resample˜ freq∾options.freq
    }
    ⟨
      1⊑≢bqnSound   # frameCount
      options.freq  # sampleRate
      •Show 1⊑options.fmt # sampleSize
      ≠bqnSound     # channels
      { # *data
        data ← ⥊⍉bqnSound
        data⊸rf.ReadI16⊸⊢ rf.MemAlloc 2×≠data # 2 is byte length of int
      }
    ⟩
  }

  Unload ⇐ rf.MemFree 4⊸⊑

  _with ⇐ {(Unload⊢𝔽)Load}
}

LoadSound ← rf.LoadSoundFromWave wave._with # fileName→Sound

PerFrame ← {𝕊sound‿sound2:
  rf.PlaySound⍟(key.IsPressed key.space) sound
  rf.PlaySound⍟(key.IsPressed key.a) sound2
  𝕩
} draw._withCanvas_ black

Start ← {𝕤
  rf.InitAudioDevice ⟨⟩
  bqnoise‿raylib ← (LoadSound∾rf.LoadSound)•file.At"testSound.wav"
  PerFrame•_While_(¬window.ShouldClose) bqnoise‿raylib
  rf.CloseAudioDevice ⟨⟩
}
Start window._openAs "Hello!!!"