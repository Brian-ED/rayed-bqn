⟨color
 draw
 key
 window
 rf⇐rayffi
 rm⇐raymath
⟩←rl←•Import "../../raylib.bqn"

⟨Sin⟩ ← •math

max_samples_per_update ← 4096

frequency ← 440      # Cycles per second (hz)
audioFrequency ← 440 # Audio frequency, for smoothing
sineIdx ← 0          # Index for audio rendering

libname ← "callback.so"
setFreq      ← libname•FFI ""‿"SetFreq"‿">f32"

#------------------------------------------------------------------------------------
# Program main entry point
#------------------------------------------------------------------------------------
{𝕤
    # Initialization
    #--------------------------------------------------------------------------------------
    
    rf.InitAudioDevice ⟨⟩
    font ← rl.font.LoadBQN@
    rf.SetAudioStreamBufferSizeDefault max_samples_per_update

    # Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 1-mono)
    stream ← rf.LoadAudioStream 44100‿16‿1

    rf.SetAudioStreamCallback stream⋈{𝕏⟨⟩}libname•FFI"*:i8"‿"GetCallbackPtr"

    rf.PlayAudioStream stream        # Start processing stream buffer (no data loaded currently)

    # Update
    {𝕤
        # Events
        mouseX‿mouseY ← rl.mouse.GetPos@
        width‿hight ← window.GetSize@
        leftPressed ← rf.IsMouseButtonDown rl.mouse.button.left
        {𝕤
            frequency ↩ 0⌈mouseY
            SetFreq frequency

            pan ← ¬0⌈1⌊ mouseX÷width   # Ratio between left and right speaker (assumes you have directional speakers)
            rf.SetAudioStreamPan stream‿pan

        }⍟⊢leftPressed

        # current buffer state proportionate to the screen
        wave ← •math.Sin width↕⊸×frequency÷width×10
        positions ← ⍉width↕⊸≍250+50×wave

        {𝕤 # Draw
            color.black‿font‿20⊸rl.draw.Text¨⟨
                ⟨width-300 ⋄ 10⟩⋈"sine frequency: "∾•Repr frequency
                10‿10           ⋈"click mouse button to change frequency or pan"
            ⟩
            rf.DrawPixelV∘⋈⟜color.red˘positions
        }draw._withCanvas_ color.raywhite@
    }•_while_(¬window.ShouldClose)@

    # De-Initialization
    #--------------------------------------------------------------------------------------
    rf.UnloadAudioStream stream   # Close raw audio stream and delete buffers from RAM
    rf.CloseAudioDevice  ⟨⟩       # Close audio device (music streaming is automatically stopped)

} rl.window._openAs "raylib [audio] example - raw audio streaming"