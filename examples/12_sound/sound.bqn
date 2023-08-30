⟨color
 draw
 key
 window
 rf⇐rayffi
 rm⇐raymath
⟩←rl←•Import "../../raylib.bqn"

⟨Sin⟩ ← •math


# *******************************************************************************************
# 
#    raylib [audio] example - Raw audio streaming
# 
#    Example originally created with raylib 1.6, last time updated with raylib 4.2
# 
#    Example created by Ramon Santamaria (@raysan5) and reviewed by James Hofmann (@triplefox)
# 
#    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#    BSD-like license that allows static linking with closed source software
# 
#    Copyright (c) 2015-2023 Ramon Santamaria (@raysan5) and James Hofmann (@triplefox)
# 
# *******************************************************************************************/

max_samples            ← 512
max_samples_per_update ← 4096

frequency ← 440      # Cycles per second (hz)
audioFrequency ← 440 # Audio frequency, for smoothing
oldFrequency ← 1     # Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
sineIdx ← 0          # Index for audio rendering

libname ← "callback.so"
setAudioInputCallback ← libname•FFI "*:i8"‿"SetAudioInputCallback"‿">a" # a here is func

# Audio input processing callback
AudioInputCallback ← {𝕊buffer:
    audioFrequency×⟜0.95⌾(-⟜frequency)↩
    incr ← audioFrequency÷44100
    ⌊{𝕤
        n ← 32000×Sin 2×π×sineIdx
        sineIdx +↩ incr
        {sineIdx -↩ 1}⍟⊢sineIdx>1
        n
    }¨buffer
}
audioInputCallbackPtr ← SetAudioInputCallback audioInputCallback

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

    rf.SetAudioStreamCallback stream‿audioInputCallbackPtr

    # Buffer for the single cycle waveform we are synthesizing
    data ← 0¨↕4×max_samples

    rf.PlayAudioStream stream        # Start processing stream buffer (no data loaded currently)

    {𝕤
        # Update
        #----------------------------------------------------------------------------------

        mousePosition ← rl.mouse.GetPos@
        width‿hight ← window.GetSize@

        {𝕤
            fp ← 1⊑mousePosition
            frequency ↩ 40 + fp

            pan ← mousePosition⊑⊸÷width
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
                10∾˜300-˜width
                "sine frequency: "∾•Repr frequency
            ⟩
            Text ⟨10⋄10⟩‿"click mouse button to change frequency or pan"

            # Draw the current buffer state proportionate to the screen
            {
                position ← ⟨
                    𝕩
                    250 + 50×32000÷˜data⊑˜⌊𝕩×max_samples÷width
                ⟩
                rf.DrawPixelV position‿color.red
            }¨↕⌊width

        }draw._withCanvas_ color.raywhite@
        #----------------------------------------------------------------------------------
    }•_while_(¬window.ShouldClose)@

    # De-Initialization
    #--------------------------------------------------------------------------------------
    rf.UnloadAudioStream stream   # Close raw audio stream and delete buffers from RAM
    rf.CloseAudioDevice  ⟨⟩       # Close audio device (music streaming is automatically stopped)

} rl.window._openAs "raylib [audio] example - raw audio streaming"