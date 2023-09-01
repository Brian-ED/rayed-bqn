⟨color
 draw
 key
 window
 rf⇐rayffi
 rm⇐raymath
⟩←rl←•Import "../../raylib.bqn"

⟨Sin⟩ ← •math

max_samples            ← 512
max_samples_per_update ← 4096

frequency ← 440      # Cycles per second (hz)
audioFrequency ← 440 # Audio frequency, for smoothing
oldFrequency ← 1     # Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
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
    Text ← color.black‿font‿20⊸rl.draw.Text

    rf.SetAudioStreamBufferSizeDefault max_samples_per_update

    
    # Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 1-mono)
    stream ← rf.LoadAudioStream 44100‿16‿1

    rf.SetAudioStreamCallback stream⋈{𝕏⟨⟩}libname•FFI"*:i8"‿"GetCallbackPtr"

    # Buffer for the single cycle waveform we are synthesizing
    data ← 0¨↕4×max_samples

    rf.PlayAudioStream stream        # Start processing stream buffer (no data loaded currently)

    {𝕤
        # Update
        #----------------------------------------------------------------------------------

        # Sample mouse input.
        mouseX‿mouseY ← rl.mouse.GetPos@
        width‿hight ← window.GetSize@

        {𝕤
            frequency ↩ 40 + mouseY
            SetFreq frequency

            pan ← mouseX÷width
            rf.SetAudioStreamPan stream‿pan
        }⍟⊢rf.IsMouseButtonDown rl.mouse.button.left

        # Rewrite the sine wave
        # Compute two cycles to allow the buffer padding, simplifying any modulation, resampling, etc.
        {𝕤
            # Compute wavelength. Limit size in both directions.
            #int oldWavelength = waveLength;
            waveLength ← 22050⌊∘÷frequency

            wavelength (1⌈⌊)↩ max_samples÷2

            # Write sine wave
            {𝕊i:
                data {𝕩⌾(i⊸⊑)𝕨} ↩ 32000×•math.Sin 2×π×i÷waveLength
            }¨↕⌊waveLength×2
            
            # Scale read cursor's position to minimize transition artifacts
            #readCursor = (int)(readCursor * ((float)waveLength / (float)oldWavelength));
            oldFrequency ↩ frequency
        }⍟⊢frequency ≠ oldFrequency
        #----------------------------------------------------------------------------------
        # Draw
        #----------------------------------------------------------------------------------
        {𝕤
            Text ⟨
                ⟨300-˜⊑window.GetSize@ ⋄ 10⟩
                "sine frequency: "∾•Repr frequency
            ⟩
            Text 10‿10⋈"click mouse button to change frequency or pan"

            # Draw the current buffer state proportionate to the screen
            positions ← {
                𝕩⋈250+50×32000÷˜data⊑˜⌊𝕩×max_samples÷width
            }¨↕width
            {rf.DrawPixelV 𝕩‿color.red}¨positions

        }draw._withCanvas_ color.raywhite@
        #----------------------------------------------------------------------------------
    }•_while_(¬window.ShouldClose)@

    # De-Initialization
    #--------------------------------------------------------------------------------------
    rf.UnloadAudioStream stream   # Close raw audio stream and delete buffers from RAM
    rf.CloseAudioDevice  ⟨⟩       # Close audio device (music streaming is automatically stopped)

} rl.window._openAs "raylib [audio] example - raw audio streaming"