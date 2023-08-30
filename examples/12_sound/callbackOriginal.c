
#include <raylib.h>
#include <math.h>           // Required for: sinf()

// Cycles per second (hz)
float frequency = 440.0f;

// Audio frequency, for smoothing
float audioFrequency = 440.0f;

// Index for audio rendering
float sineIdx = 0.0f;

// Audio input processing callback
void AudioInputCallback(short *buffer, unsigned int frames)
{
    audioFrequency = frequency + (audioFrequency - frequency)*0.95f;
    audioFrequency += 1.0f;
    audioFrequency -= 1.0f;
    float incr = audioFrequency/44100.0f;

    for (unsigned int i = 0; i < frames; i++)
    {
        buffer[i] = (short)(32000.0f*sinf(2*PI*sineIdx));
        sineIdx += incr;
        if (sineIdx > 1.0f) sineIdx -= 1.0f;
    }
}

void *GetCallbackPtr()
{
    return AudioInputCallback;
}


void SetFreq(float x)
{
    frequency = x;    
}