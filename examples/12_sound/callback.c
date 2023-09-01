// Compilation:
// 
// gcc callback.c -c -I/home/brian/CBQNStuffs/CBQN/include/ -fPIC
// gcc -shared -o libcallback.so callback.o

#include <raylib.h>
#include <math.h>           // Required for: sinf()
// #include <stdio.h>         // Required for: printf()

// Cycles per second (hz)
float frequency = 440.0f;

// Audio frequency, for smoothing
float audioFrequency = 440.0f;

// Index for audio rendering
float sineIdx = 0.0f;

typedef unsigned int u32;
typedef short i16;

// Audio input processing callback
void AudioInputCallback(i16 *buffer, u32 frames) {
    audioFrequency = frequency+0.95f*(audioFrequency-frequency);
    float incr = audioFrequency/44100.0f;

    for (u32 i = 0; i < frames; i++) {
        buffer[i] = (i16)(32000.0f*sinf(2*PI*sineIdx));
        sineIdx += incr;
        if (sineIdx > 1.0f) sineIdx -= 1.0f;
    }
}

void *GetCallbackPtr() {
    return AudioInputCallback;
}

void SetFreq(float x) {
    frequency = x;
}