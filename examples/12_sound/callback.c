// Compilation:
// 
// gcc callback.c -c -I/home/brian/CBQNStuffs/CBQN/include/ -fPIC
// gcc -shared -o libcallback.so callback.o


#include <raylib.h>
#include <bqnffi.h>

BQNV bqnFn;

// Audio input processing callback
void AudioInputCallback(void *buffer, unsigned int frames) {
    size_t len = frames;
    BQNV arr = bqn_makeI16Vec(len, buffer);
    BQNV bufferList = bqn_call1(bqnFn, arr);
    bqn_free(arr);
    bqn_readI16Arr(bufferList, buffer);
    bqn_free(bufferList);
}

void *SetAudioInputCallback(BQNV func) {
    bqnFn = func;
    return AudioInputCallback;
}
