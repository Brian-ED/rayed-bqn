# stb_image - v2.28 - public domain image loader - http:#nothings.org/stb
#
#   You can #define STBI_ASSERT(x) before the #include to avoid using assert.h.
#   And #define STBI_MALLOC, STBI_REALLOC, and STBI_FREE to avoid using malloc,realloc,free
#
#
#      PNG 1/2/4/8/16-bit-per-channel
#
#      TGA (not sure what subset, if a subset)
#      BMP non-1bpp, non-RLE
#      PSD (composited view only, no extra channels, 8/16 bit-per-channel)
#
#      GIF (*comp always reports as 4-channel)
#      PNM (PPM and PGM binary only)
#
#      Animated GIF still needs a proper API, but here's one way to do it:
#          http:#gist.github.com/urraka/685d9a6340b26b830d49
#

#struct stbi_io_callbacks
   # 𝔽 named read   # userList‿dataStr‿size_int → int # fill 'data' with 'size' bytes.  return number of bytes actually read
   # 𝔽 named skip   # userList‿n_int → @              # skip the next 'n' bytes, or 'unget' the last -n bytes if negative
   # 𝔽 named eof    # ⟨userList⟩ → int                # returns nonzero if we are at end of file/data


#define STBI_NOTUSED(v)  (void)(v)

#define STBI_REALLOC_SIZED(p,oldsz,newsz) STBI_REALLOC(p,newsz)

#define STBI_MAX_DIMENSIONS (1 << 24)

#######################/
#
#  context struct and start_xxx functions

# context structure is our basic context used by all images, so it
# contains all the IO context, plus some basic image information
context ← {
   ⟨
      img_x, img_y # u32
      img_n, img_out_n # i32

      void *io_user_data;

      int read_from_callbacks;
      int buflen;
      stbi_uc buffer_start[128];
      int callback_already_read;

      stbi_uc *img_buffer, *img_buffer_end;
      stbi_uc *img_buffer_original, *img_buffer_original_end;
   ⟩⇐↕10
}

# initialize a memory-decode context
static void start_mem(context *s, stbi_uc const *buffer, int len)
{
   s->io.read = NULL;
   s->read_from_callbacks = 0;
   s->callback_already_read = 0;
   s->img_buffer = s->img_buffer_original = (stbi_uc *) buffer;
   s->img_buffer_end = s->img_buffer_original_end = (stbi_uc *) buffer+len;
}

# initialize a callback-based context
static void start_callbacks(context *s, stbi_io_callbacks *c, void *user)
{
   s->io = *c;
   s->io_user_data = user;
   s->buflen = sizeof(s->buffer_start);
   s->read_from_callbacks = 1;
   s->callback_already_read = 0;
   s->img_buffer = s->img_buffer_original = s->buffer_start;
   refill_buffer(s);
   s->img_buffer_original_end = s->img_buffer_end;
}

static void rewind(context *s)
{
   # conceptually rewind SHOULD rewind to the beginning of the stream,
   # but we just rewind to the beginning of the initial buffer, because
   # we only use it after doing 'test', which only ever looks at at most 92 bytes
   s->img_buffer = s->img_buffer_original;
   s->img_buffer_end = s->img_buffer_original_end;
}

enum
{
   STBI_ORDER_RGB,
   STBI_ORDER_BGR
};

typedef struct
{
   int bits_per_channel;
   int num_channels;
   int channel_order;
} result_info;

g_failure_reason ← ""

stbi_failure_reason ⇐ {𝕊: g_failure_reason}

err ← {
   @⊣g_failure_reason ↩ 𝕩
}

# stb_image uses ints pervasively, including for offset calculations.
# therefore the largest decoded image size we can support with the
# current code, even on 64-bit targets, is INT_MAX. this is not a
# significant limitation for the intended use case.
#
# we do, however, need to make sure our size calculations don't
# overflow. hence a few helper functions for size calculations that
# multiply integers together, making sure that they're non-negative
# and no overflow occurs.

# return 1 if the sum is valid, 0 on overflow.
# negative terms are considered invalid.
static int addsizes_valid(int a, int b)
{
   if (b < 0) return 0;
   # now 0 <= b <= INT_MAX, hence also
   # 0 <= INT_MAX - b <= INTMAX.
   # And "a + b <= INT_MAX" (which might overflow) is the
   # same as a <= INT_MAX - b (no overflow)
   return a <= INT_MAX - b;
}

# returns 1 if the product is valid, 0 on overflow.
# negative factors are considered invalid.
static int mul2sizes_valid(int a, int b)
{
   if (a < 0 || b < 0) return 0;
   if (b == 0) return 1; # mul-by-0 is always safe
   # portable way to check for no overflows in a*b
   return a <= INT_MAX/b;
}

# returns 1 if "a*b + add" has no negative terms/factors and doesn't overflow
static int mad2sizes_valid(int a, int b, int add)
{
   return mul2sizes_valid(a, b) && addsizes_valid(a*b, add);
}

# returns 1 if "a*b*c + add" has no negative terms/factors and doesn't overflow
static int mad3sizes_valid(int a, int b, int c, int add)
{
   return mul2sizes_valid(a, b) && mul2sizes_valid(a*b, c) &&
      addsizes_valid(a*b*c, add);
}

# mallocs with size overflow checking
static void *malloc_mad2(int a, int b, int add)
{
   if (!mad2sizes_valid(a, b, add)) return NULL;
   return STBI_MALLOC(a*b + add);
}

static void *malloc_mad3(int a, int b, int c, int add)
{
   if (!mad3sizes_valid(a, b, c, add)) return NULL;
   return STBI_MALLOC(a*b*c + add);
}

# returns 1 if the sum of two signed ints is valid (between -2^31 and 2^31-1 inclusive), 0 on overflow.
static int addints_valid(int a, int b)
{
   if ((a >= 0) != (b >= 0)) return 1; # a and b have different signs, so no overflow
   if (a < 0 && b < 0) return a >= INT_MIN - b; # same as a + b >= INT_MIN; INT_MIN - b cannot overflow since b < 0.
   return a <= INT_MAX - b;
}

# returns 1 if the product of two signed shorts is valid, 0 on overflow.
static int mul2shorts_valid(short a, short b)
{
   if (b == 0 || b == -1) return 1; # multiplication by 0 is always 0; check for -1 so SHRT_MIN/b doesn't overflow
   if ((a >= 0) == (b >= 0)) return a <= SHRT_MAX/b; # product is positive, so similar to mul2sizes_valid
   if (b < 0) return a <= SHRT_MIN / b; # same as a * b >= SHRT_MIN
   return a >= SHRT_MIN / b;
}

# err - error
# errpf - error returning pointer to float
# errpuc - error returning pointer to unsigned char

#define err(x,y)  err(y)
#define errpf(x,y)   ((float *)(size_t) (err(x,y)?NULL:NULL))
#define errpuc(x,y)  ((unsigned char *)(size_t) (err(x,y)?NULL:NULL))

vertically_flip_on_load_global ← 0

stbi_set_flip_vertically_on_load ⇐ {𝕊flag_true_if_should_flip:
   vertically_flip_on_load_global ↩ 𝕩
}

static void *load_main(context *s, int *x, int *y, int *comp, int req_comp, result_info *ri, int bpc)
{
   memset(ri, 0, sizeof(*ri)); # make sure it's initialized if we add new fields
   ri->bits_per_channel = 8; # default is 8 so most paths don't have to be changed
   ri->channel_order = STBI_ORDER_RGB; # all current input & output are this, but this is here so we can add BGR order
   ri->num_channels = 0;

   # test the formats with a very explicit header first (at least a FOURCC
   # or distinctive magic number first)
   
   r ← check_png_header s
   rewind s
   
   if (r)  return png_load(s,x,y,comp,req_comp, ri);
   if (gif_test(s))  return gif_load(s,x,y,comp,req_comp, ri);
   STBI_NOTUSED(bpc);

   # then the formats that can end up attempting to load with just 1 or 2
   # bytes matching expectations; these are prone to false positives, so
   # try them later
   return errpuc("unknown image type", "Image not of any known type, or corrupt");
}

static stbi_uc *convert_16_to_8(uint16 *orig, int w, int h, int channels)
{
   int i;
   int img_len = w * h * channels;
   stbi_uc *reduced;

   reduced = (stbi_uc *) STBI_MALLOC(img_len);
   if (reduced == NULL) return errpuc("outofmem", "Out of memory");

   for (i = 0; i < img_len; ++i)
      reduced[i] = (stbi_uc)((orig[i] >> 8) & 0xFF); # top half of each byte is sufficient approx of 16->8 bit scaling

   STBI_FREE(orig);
   return reduced;
}

static uint16 *convert_8_to_16(stbi_uc *orig, int w, int h, int channels)
{
   int i;
   int img_len = w * h * channels;
   uint16 *enlarged;

   enlarged = (uint16 *) STBI_MALLOC(img_len*2);
   if (enlarged == NULL) return (uint16 *) errpuc("outofmem", "Out of memory");

   for (i = 0; i < img_len; ++i)
      enlarged[i] = (uint16)((orig[i] << 8) + orig[i]); # replicate to high and low byte, maps 0->0, 255->0xffff

   STBI_FREE(orig);
   return enlarged;
}

static void vertical_flip(void *image, int w, int h, int bytes_per_pixel)
{
   int row;
   size_t bytes_per_row = (size_t)w * bytes_per_pixel;
   stbi_uc temp[2048];
   stbi_uc *bytes = (stbi_uc *)image;

   for (row = 0; row < (h>>1); row++) {
      stbi_uc *row0 = bytes + row*bytes_per_row;
      stbi_uc *row1 = bytes + (h - row - 1)*bytes_per_row;
      # swap row0 with row1
      size_t bytes_left = bytes_per_row;
      while (bytes_left) {
         size_t bytes_copy = (bytes_left < sizeof(temp)) ? bytes_left : sizeof(temp);
         memcpy(temp, row0, bytes_copy);
         memcpy(row0, row1, bytes_copy);
         memcpy(row1, temp, bytes_copy);
         row0 += bytes_copy;
         row1 += bytes_copy;
         bytes_left -= bytes_copy;
      }
   }
}

static void vertical_flip_slices(void *image, int w, int h, int z, int bytes_per_pixel)
{
   int slice;
   int slice_size = w * h * bytes_per_pixel;

   stbi_uc *bytes = (stbi_uc *)image;
   for (slice = 0; slice < z; ++slice) {
      vertical_flip(bytes, w, h, bytes_per_pixel);
      bytes += slice_size;
   }
}

static unsigned char *load_and_postprocess_8bit(context *s, int *x, int *y, int *comp, int req_comp)
{
   result_info ri;
   void *result = load_main(s, x, y, comp, req_comp, &ri, 8);

   if (result == NULL)
      return NULL;

   # it is the responsibility of the loaders to make sure we get either 8 or 16 bit.
   STBI_ASSERT(ri.bits_per_channel == 8 || ri.bits_per_channel == 16);

   if (ri.bits_per_channel != 8) {
      result = convert_16_to_8((uint16 *) result, *x, *y, req_comp == 0 ? *comp : req_comp);
      ri.bits_per_channel = 8;
   }

   # @TODO: move convert_format to here

   if (vertically_flip_on_load_global) {
      int channels = req_comp ? req_comp : *comp;
      vertical_flip(result, *x, *y, channels * sizeof(stbi_uc));
   }

   return (unsigned char *) result;
}

static uint16 *load_and_postprocess_16bit(context *s, int *x, int *y, int *comp, int req_comp)
{
   result_info ri;
   void *result = load_main(s, x, y, comp, req_comp, &ri, 16);

   if (result == NULL)
      return NULL;

   # it is the responsibility of the loaders to make sure we get either 8 or 16 bit.
   STBI_ASSERT(ri.bits_per_channel == 8 || ri.bits_per_channel == 16);

   if (ri.bits_per_channel != 16) {
      result = convert_8_to_16((stbi_uc *) result, *x, *y, req_comp == 0 ? *comp : req_comp);
      ri.bits_per_channel = 16;
   }

   # @TODO: move convert_format16 to here
   # @TODO: special case RGB-to-Y (and RGBA-to-YA) for 8-bit-to-16-bit case to keep more precision

   if (vertically_flip_on_load_global) {
      int channels = req_comp ? req_comp : *comp;
      vertical_flip(result, *x, *y, channels * sizeof(uint16));
   }

   return (uint16 *) result;
}

STBIDEF stbi_us *stbi_load_16_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels)
{
   context s;
   start_mem(&s,buffer,len);
   return load_and_postprocess_16bit(&s,x,y,channels_in_file,desired_channels);
}

STBIDEF stbi_us *stbi_load_16_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *channels_in_file, int desired_channels)
{
   context s;
   start_callbacks(&s, (stbi_io_callbacks *)clbk, user);
   return load_and_postprocess_16bit(&s,x,y,channels_in_file,desired_channels);
}

STBIDEF stbi_uc *stbi_load_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp, int req_comp)
{
   context s;
   start_mem(&s,buffer,len);
   return load_and_postprocess_8bit(&s,x,y,comp,req_comp);
}

STBIDEF stbi_uc *stbi_load_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *comp, int req_comp)
{
   context s;
   start_callbacks(&s, (stbi_io_callbacks *) clbk, user);
   return load_and_postprocess_8bit(&s,x,y,comp,req_comp);
}

STBIDEF stbi_uc *stbi_load_gif_from_memory(stbi_uc const *buffer, int len, int **delays, int *x, int *y, int *z, int *comp, int req_comp)
{
   unsigned char *result;
   context s;
   start_mem(&s,buffer,len);

   result = (unsigned char*) load_gif_main(&s, delays, x, y, z, comp, req_comp);
   if (vertically_flip_on_load_global) {
      vertical_flip_slices( result, *x, *y, *z, *comp );
   }

   return result;
}

static float h2l_gamma_i=1.0f/2.2f, h2l_scale_i=1.0f;

#######################################
#
# Common code used by all image loaders
#

enum
{
   SCAN_load=0,
   SCAN_type,
   SCAN_header
};

refill_buffer {𝕊context: # *s
   n ← (s->io.read)(s->io_user_data,(char*)s->buffer_start,s->buflen);
   s->callback_already_read += (int) (s->img_buffer - s->img_buffer_original);
   
   {n=0?
      # at end of file, treat same as if from memory, but need to handle case
      # where s->img_buffer isn't pointing to safe memory, e.g. 0-byte file
      s->read_from_callbacks = 0;
      s->img_buffer = s->buffer_start;
      s->img_buffer_end = s->buffer_start+1;
      *s->img_buffer = 0;
   ;
      s->img_buffer = s->buffer_start;
      s->img_buffer_end = s->buffer_start + n;
   }
}

static void skip(context *s, int n)
{
   if (n == 0) return;  # already there!
   if (n < 0) {
      s->img_buffer = s->img_buffer_end;
      return;
   }
   if (s->io.read) {
      int blen = (int) (s->img_buffer_end - s->img_buffer);
      if (blen < n) {
         s->img_buffer = s->img_buffer_end;
         (s->io.skip)(s->io_user_data, n - blen);
         return;
      }
   }
   s->img_buffer += n;
}

static int getn(context *s, stbi_uc *buffer, int n)
{
   if (s->io.read) {
      int blen = (int) (s->img_buffer_end - s->img_buffer);
      if (blen < n) {
         int res, count;

         memcpy(buffer, s->img_buffer, blen);

         count = (s->io.read)(s->io_user_data, (char*) buffer + blen, n - blen);
         res = (count == (n-blen));
         s->img_buffer = s->img_buffer_end;
         return res;
      }
   }

   if (s->img_buffer+n <= s->img_buffer_end) {
      memcpy(buffer, s->img_buffer, n);
      s->img_buffer += n;
      return 1;
   } else
      return 0;
}

static int get16be(context *s)
{
   int z = get8(s);
   return (z << 8) + get8(s);
}

static uint32 get32be(context *s)
{
   uint32 z = get16be(s);
   return (z << 16) + get16be(s);
}

static int get16le(context *s)
{
   int z = get8(s);
   return z + (get8(s) << 8);
}
Bytecast ← 255⊸| # truncate int to byte

#######################################
#
#  generic converter from built-in img_n to req_comp
#    individual types do this automatically as much as possible (e.g. jpeg
#    does all cases internally since it needs to colorspace convert anyway,
#    and it never has alpha, so very few cases ). png can automatically
#    interleave an alpha=255 channel, but falls back to this for other cases
#
#  assume data buffer is malloced, so malloc a new one and free that one
#  only failure mode is malloc failing

static stbi_uc compute_y(int r, int g, int b)
{
   return (stbi_uc) (((r*77) + (g*150) +  (29*b)) >> 8);
}

static unsigned char *convert_format(unsigned char *data, int img_n, int req_comp, unsigned int x, unsigned int y)
{
   int i,j;
   unsigned char *good;

   if (req_comp == img_n) return data;
   STBI_ASSERT(req_comp >= 1 && req_comp <= 4);

   good = (unsigned char *) malloc_mad3(req_comp, x, y, 0);
   if (good == NULL) {
      STBI_FREE(data);
      return errpuc("outofmem", "Out of memory");
   }

   for (j=0; j < (int) y; ++j) {
      unsigned char *src  = data + j * x * img_n   ;
      unsigned char *dest = good + j * x * req_comp;

      #define COMBO(a,b)  ((a)*8+(b))
      #define CASE(a,b)   case COMBO(a,b): for(i=x-1; i >= 0; --i, src += a, dest += b)
      # convert source image with img_n components to one with req_comp components;
      # avoid switch per pixel, so use switch per scanline and massive macros
      switch (COMBO(img_n, req_comp)) {
         CASE(1,2) { dest[0]=src[0]; dest[1]=255;                                     } break;
         CASE(1,3) { dest[0]=dest[1]=dest[2]=src[0];                                  } break;
         CASE(1,4) { dest[0]=dest[1]=dest[2]=src[0]; dest[3]=255;                     } break;
         CASE(2,1) { dest[0]=src[0];                                                  } break;
         CASE(2,3) { dest[0]=dest[1]=dest[2]=src[0];                                  } break;
         CASE(2,4) { dest[0]=dest[1]=dest[2]=src[0]; dest[3]=src[1];                  } break;
         CASE(3,4) { dest[0]=src[0];dest[1]=src[1];dest[2]=src[2];dest[3]=255;        } break;
         CASE(3,1) { dest[0]=compute_y(src[0],src[1],src[2]);                   } break;
         CASE(3,2) { dest[0]=compute_y(src[0],src[1],src[2]); dest[1] = 255;    } break;
         CASE(4,1) { dest[0]=compute_y(src[0],src[1],src[2]);                   } break;
         CASE(4,2) { dest[0]=compute_y(src[0],src[1],src[2]); dest[1] = src[3]; } break;
         CASE(4,3) { dest[0]=src[0];dest[1]=src[1];dest[2]=src[2];                    } break;
         default: STBI_ASSERT(0); STBI_FREE(data); STBI_FREE(good); return errpuc("unsupported", "Unsupported format conversion");
      }
      #undef CASE
   }

   STBI_FREE(data);
   return good;
}

static uint16 compute_y_16(int r, int g, int b)
{
   return (uint16) (((r*77) + (g*150) +  (29*b)) >> 8);
}

static uint16 *convert_format16(uint16 *data, int img_n, int req_comp, unsigned int x, unsigned int y)
{
   int i,j;
   uint16 *good;

   if (req_comp == img_n) return data;
   STBI_ASSERT(req_comp >= 1 && req_comp <= 4);

   good = (uint16 *) STBI_MALLOC(req_comp * x * y * 2);
   if (good == NULL) {
      STBI_FREE(data);
      return (uint16 *) errpuc("outofmem", "Out of memory");
   }

   for (j=0; j < (int) y; ++j) {
      uint16 *src  = data + j * x * img_n   ;
      uint16 *dest = good + j * x * req_comp;

      #define COMBO(a,b)  ((a)*8+(b))
      #define CASE(a,b)   case COMBO(a,b): for(i=x-1; i >= 0; --i, src += a, dest += b)
      # convert source image with img_n components to one with req_comp components;
      # avoid switch per pixel, so use switch per scanline and massive macros
      switch (COMBO(img_n, req_comp)) {
         CASE(1,2) { dest[0]=src[0]; dest[1]=0xffff;                                     } break;
         CASE(1,3) { dest[0]=dest[1]=dest[2]=src[0];                                     } break;
         CASE(1,4) { dest[0]=dest[1]=dest[2]=src[0]; dest[3]=0xffff;                     } break;
         CASE(2,1) { dest[0]=src[0];                                                     } break;
         CASE(2,3) { dest[0]=dest[1]=dest[2]=src[0];                                     } break;
         CASE(2,4) { dest[0]=dest[1]=dest[2]=src[0]; dest[3]=src[1];                     } break;
         CASE(3,4) { dest[0]=src[0];dest[1]=src[1];dest[2]=src[2];dest[3]=0xffff;        } break;
         CASE(3,1) { dest[0]=compute_y_16(src[0],src[1],src[2]);                   } break;
         CASE(3,2) { dest[0]=compute_y_16(src[0],src[1],src[2]); dest[1] = 0xffff; } break;
         CASE(4,1) { dest[0]=compute_y_16(src[0],src[1],src[2]);                   } break;
         CASE(4,2) { dest[0]=compute_y_16(src[0],src[1],src[2]); dest[1] = src[3]; } break;
         CASE(4,3) { dest[0]=src[0];dest[1]=src[1];dest[2]=src[2];                       } break;
         default: STBI_ASSERT(0); STBI_FREE(data); STBI_FREE(good); return (uint16*) errpuc("unsupported", "Unsupported format conversion");
      }
      #undef CASE
   }

   STBI_FREE(data);
   return good;
}

#######################################
#
#  "baseline" JPEG/JFIF decoder
#
#    simple implementation
#      - doesn't support delayed output of y-dimension
#      - simple interface (only one output format: 8-bit interleaved RGB)
#      - doesn't try to recover corrupt jpegs
#      - doesn't allow partial loading, loading multiple at once
#      - still fast on x86 (copying globals into locals doesn't help x86)
#      - allocates lots of intermediate memory (full size of all components)
#        - non-interleaved case requires this anyway
#        - allows good upsampling (see next)
#    high-quality
#      - upsampled channels are bilinearly interpolated, even across blocks
#      - quality integer IDCT derived from IJG's 'slow'
#    performance
#      - fast huffman; reasonable integer IDCT
#      - some SIMD kernels for common paths on targets with SSE2/NEON
#      - uses a lot of intermediate memory, could cache poorly


# public domain zlib decode    v0.2  Sean Barrett 2006-11-18
#    simple implementation
#      - all input must be provided in an upfront buffer
#      - all output is written to a single output buffer (can malloc/realloc)
#    performance
#      - fast huffman

# fast-way is faster to check than jpeg huffman, but slow way is slower
#define ZFAST_BITS  9 # accelerate all cases in default tables
#define ZFAST_MASK  ((1 << ZFAST_BITS) - 1)
#define ZNSYMS 288 # number of symbols in literal/length alphabet

# zlib-style huffman encoding
# (jpegs packs from left, zlib from right, so can't share code)
typedef struct
{
   uint16 fast[1 << ZFAST_BITS];
   uint16 firstcode[16];
   int maxcode[17];
   uint16 firstsymbol[16];
   stbi_uc  size[ZNSYMS];
   uint16 value[ZNSYMS];
} zhuffman;

stbi_inline static int bitreverse16(int n)
{
  n = ((n & 0xAAAA) >>  1) | ((n & 0x5555) << 1);
  n = ((n & 0xCCCC) >>  2) | ((n & 0x3333) << 2);
  n = ((n & 0xF0F0) >>  4) | ((n & 0x0F0F) << 4);
  n = ((n & 0xFF00) >>  8) | ((n & 0x00FF) << 8);
  return n;
}

stbi_inline static int bit_reverse(int v, int bits)
{
   STBI_ASSERT(bits <= 16);
   # to bit reverse n bits, reverse 16 and shift
   # e.g. 11 bits, bit reverse and shift away 5
   return bitreverse16(v) >> (16-bits);
}

static int zbuild_huffman(zhuffman *z, const stbi_uc *sizelist, int num)
{
   int i,k=0;
   int code, next_code[16], sizes[17];

   # DEFLATE spec for generating codes
   memset(sizes, 0, sizeof(sizes));
   memset(z->fast, 0, sizeof(z->fast));
   for (i=0; i < num; ++i)
      ++sizes[sizelist[i]];
   sizes[0] = 0;
   for (i=1; i < 16; ++i)
      if (sizes[i] > (1 << i))
         return err("bad sizes", "Corrupt PNG");
   code = 0;
   for (i=1; i < 16; ++i) {
      next_code[i] = code;
      z->firstcode[i] = (uint16) code;
      z->firstsymbol[i] = (uint16) k;
      code = (code + sizes[i]);
      if (sizes[i])
         if (code-1 >= (1 << i)) return err("bad codelengths","Corrupt PNG");
      z->maxcode[i] = code << (16-i); # preshift for inner loop
      code <<= 1;
      k += sizes[i];
   }
   z->maxcode[16] = 0x10000; # sentinel
   for (i=0; i < num; ++i) {
      int s = sizelist[i];
      if (s) {
         int c = next_code[s] - z->firstcode[s] + z->firstsymbol[s];
         uint16 fastv = (uint16) ((s << 9) | i);
         z->size [c] = (stbi_uc     ) s;
         z->value[c] = (uint16) i;
         if (s <= ZFAST_BITS) {
            int j = bit_reverse(next_code[s],s);
            while (j < (1 << ZFAST_BITS)) {
               z->fast[j] = fastv;
               j += (1 << s);
            }
         }
         ++next_code[s];
      }
   }
   return 1;
}

# zlib-from-memory implementation for PNG reading
#    because PNG allows splitting the zlib stream arbitrarily,
#    and it's annoying structurally to have PNG call ZLIB call PNG,
#    we require PNG read all the IDATs and combine them into a single
#    memory buffer

typedef struct
{
   stbi_uc *zbuffer, *zbuffer_end;
   int num_bits;
   uint32 code_buffer;

   char *zout;
   char *zout_start;
   char *zout_end;
   int   z_expandable;

   zhuffman z_length, z_distance;
} zbuf;

stbi_inline static int zeof(zbuf *z)
{
   return (z->zbuffer >= z->zbuffer_end);
}

stbi_inline static stbi_uc zget8(zbuf *z)
{
   return zeof(z) ? 0 : *z->zbuffer++;
}

static void fill_bits(zbuf *z)
{
   do {
      if (z->code_buffer >= (1U << z->num_bits)) {
        z->zbuffer = z->zbuffer_end;  /* treat this as EOF so we fail. */
        return;
      }
      z->code_buffer |= (unsigned int) zget8(z) << z->num_bits;
      z->num_bits += 8;
   } while (z->num_bits <= 24);
}

stbi_inline static unsigned int zreceive(zbuf *z, int n)
{
   unsigned int k;
   if (z->num_bits < n) fill_bits(z);
   k = z->code_buffer & ((1 << n) - 1);
   z->code_buffer >>= n;
   z->num_bits -= n;
   return k;
}

static int zhuffman_decode_slowpath(zbuf *a, zhuffman *z)
{
   int b,s,k;
   # not resolved by fast table, so compute it the slow way
   # use jpeg approach, which requires MSbits at top
   k = bit_reverse(a->code_buffer, 16);
   for (s=ZFAST_BITS+1; ; ++s)
      if (k < z->maxcode[s])
         break;
   if (s >= 16) return -1; # invalid code!
   # code size is s, so:
   b = (k >> (16-s)) - z->firstcode[s] + z->firstsymbol[s];
   if (b >= ZNSYMS) return -1; # some data was corrupt somewhere!
   if (z->size[b] != s) return -1;  # was originally an assert, but report failure instead.
   a->code_buffer >>= s;
   a->num_bits -= s;
   return z->value[b];
}

stbi_inline static int zhuffman_decode(zbuf *a, zhuffman *z)
{
   int b,s;
   if (a->num_bits < 16) {
      if (zeof(a)) {
         return -1;   /* report error for unexpected end of data. */
      }
      fill_bits(a);
   }
   b = z->fast[a->code_buffer & ZFAST_MASK];
   if (b) {
      s = b >> 9;
      a->code_buffer >>= s;
      a->num_bits -= s;
      return b & 511;
   }
   return zhuffman_decode_slowpath(a, z);
}

static int zexpand(zbuf *z, char *zout, int n)  # need to make room for n bytes
{
   char *q;
   unsigned int cur, limit, old_limit;
   z->zout = zout;
   if (!z->z_expandable) return err("output buffer limit","Corrupt PNG");
   cur   = (unsigned int) (z->zout - z->zout_start);
   limit = old_limit = (unsigned) (z->zout_end - z->zout_start);
   if (UINT_MAX - cur < (unsigned) n) return err("outofmem", "Out of memory");
   while (cur + n > limit) {
      if(limit > UINT_MAX / 2) return err("outofmem", "Out of memory");
      limit *= 2;
   }
   q = (char *) STBI_REALLOC_SIZED(z->zout_start, old_limit, limit);
   STBI_NOTUSED(old_limit);
   if (q == NULL) return err("outofmem", "Out of memory");
   z->zout_start = q;
   z->zout       = q + cur;
   z->zout_end   = q + limit;
   return 1;
}

static const int zlength_base[31] = {
   3,4,5,6,7,8,9,10,11,13,
   15,17,19,23,27,31,35,43,51,59,
   67,83,99,115,131,163,195,227,258,0,0 };

static const int zlength_extra[31]=
{ 0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0,0,0 };

static const int zdist_base[32] = { 1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,
257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577,0,0};

static const int zdist_extra[32] =
{ 0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13};

static int parse_huffman_block(zbuf *a)
{
   char *zout = a->zout;
   for(;;) {
      int z = zhuffman_decode(a, &a->z_length);
      if (z < 256) {
         if (z < 0) return err("bad huffman code","Corrupt PNG"); # error in huffman codes
         if (zout >= a->zout_end) {
            if (!zexpand(a, zout, 1)) return 0;
            zout = a->zout;
         }
         *zout++ = (char) z;
      } else {
         stbi_uc *p;
         int len,dist;
         if (z == 256) {
            a->zout = zout;
            return 1;
         }
         if (z >= 286) return err("bad huffman code","Corrupt PNG"); # per DEFLATE, length codes 286 and 287 must not appear in compressed data
         z -= 257;
         len = zlength_base[z];
         if (zlength_extra[z]) len += zreceive(a, zlength_extra[z]);
         z = zhuffman_decode(a, &a->z_distance);
         if (z < 0 || z >= 30) return err("bad huffman code","Corrupt PNG"); # per DEFLATE, distance codes 30 and 31 must not appear in compressed data
         dist = zdist_base[z];
         if (zdist_extra[z]) dist += zreceive(a, zdist_extra[z]);
         if (zout - a->zout_start < dist) return err("bad dist","Corrupt PNG");
         if (zout + len > a->zout_end) {
            if (!zexpand(a, zout, len)) return 0;
            zout = a->zout;
         }
         p = (stbi_uc *) (zout - dist);
         if (dist == 1) { # run of one byte; common in images.
            stbi_uc v = *p;
            if (len) { do *zout++ = v; while (--len); }
         } else {
            if (len) { do *zout++ = *p++; while (--len); }
         }
      }
   }
}

static int compute_huffman_codes(zbuf *a)
{
   static const stbi_uc length_dezigzag[19] = { 16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15 };
   zhuffman z_codelength;
   stbi_uc lencodes[286+32+137];#padding for maximum single op
   stbi_uc codelength_sizes[19];
   int i,n;

   int hlit  = zreceive(a,5) + 257;
   int hdist = zreceive(a,5) + 1;
   int hclen = zreceive(a,4) + 4;
   int ntot  = hlit + hdist;

   memset(codelength_sizes, 0, sizeof(codelength_sizes));
   for (i=0; i < hclen; ++i) {
      int s = zreceive(a,3);
      codelength_sizes[length_dezigzag[i]] = (stbi_uc) s;
   }
   if (!zbuild_huffman(&z_codelength, codelength_sizes, 19)) return 0;

   n = 0;
   while (n < ntot) {
      int c = zhuffman_decode(a, &z_codelength);
      if (c < 0 || c >= 19) return err("bad codelengths", "Corrupt PNG");
      if (c < 16)
         lencodes[n++] = (stbi_uc) c;
      else {
         stbi_uc fill = 0;
         if (c == 16) {
            c = zreceive(a,2)+3;
            if (n == 0) return err("bad codelengths", "Corrupt PNG");
            fill = lencodes[n-1];
         } else if (c == 17) {
            c = zreceive(a,3)+3;
         } else if (c == 18) {
            c = zreceive(a,7)+11;
         } else {
            return err("bad codelengths", "Corrupt PNG");
         }
         if (ntot - n < c) return err("bad codelengths", "Corrupt PNG");
         memset(lencodes+n, fill, c);
         n += c;
      }
   }
   if (n != ntot) return err("bad codelengths","Corrupt PNG");
   if (!zbuild_huffman(&a->z_length, lencodes, hlit)) return 0;
   if (!zbuild_huffman(&a->z_distance, lencodes+hlit, hdist)) return 0;
   return 1;
}

static int parse_uncompressed_block(zbuf *a)
{
   stbi_uc header[4];
   int len,nlen,k;
   if (a->num_bits & 7)
      zreceive(a, a->num_bits & 7); # discard
   # drain the bit-packed data into header
   k = 0;
   while (a->num_bits > 0) {
      header[k++] = (stbi_uc) (a->code_buffer & 255); # suppress MSVC run-time check
      a->code_buffer >>= 8;
      a->num_bits -= 8;
   }
   if (a->num_bits < 0) return err("zlib corrupt","Corrupt PNG");
   # now fill header the normal way
   while (k < 4)
      header[k++] = zget8(a);
   len  = header[1] * 256 + header[0];
   nlen = header[3] * 256 + header[2];
   if (nlen != (len ^ 0xffff)) return err("zlib corrupt","Corrupt PNG");
   if (a->zbuffer + len > a->zbuffer_end) return err("read past buffer","Corrupt PNG");
   if (a->zout + len > a->zout_end)
      if (!zexpand(a, a->zout, len)) return 0;
   memcpy(a->zout, a->zbuffer, len);
   a->zbuffer += len;
   a->zout += len;
   return 1;
}

static int parse_zlib_header(zbuf *a)
{
   int cmf   = zget8(a);
   int cm    = cmf & 15;
   /* int cinfo = cmf >> 4; */
   int flg   = zget8(a);
   if (zeof(a)) return err("bad zlib header","Corrupt PNG"); # zlib spec
   if ((cmf*256+flg) % 31 != 0) return err("bad zlib header","Corrupt PNG"); # zlib spec
   if (flg & 32) return err("no preset dict","Corrupt PNG"); # preset dictionary not allowed in png
   if (cm != 8) return err("bad compression","Corrupt PNG"); # DEFLATE required for png
   # window = 1 << (8 + cinfo)... but who cares, we fully buffer output
   return 1;
}

static const stbi_uc zdefault_length[ZNSYMS] =
{
   8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8, 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
   8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8, 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
   8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8, 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
   8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8, 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
   8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8, 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
   9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
   9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
   9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
   7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7, 7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8
};
static const stbi_uc zdefault_distance[32] =
{
   5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
};

static int parse_zlib(zbuf *a, int parse_header)
{
   int final, type;
   if (parse_header)
      if (!parse_zlib_header(a)) return 0;
   a->num_bits = 0;
   a->code_buffer = 0;
   do {
      final = zreceive(a,1);
      type = zreceive(a,2);
      if (type == 0) {
         if (!parse_uncompressed_block(a)) return 0;
      } else if (type == 3) {
         return 0;
      } else {
         if (type == 1) {
            # use fixed code lengths
            if (!zbuild_huffman(&a->z_length  , zdefault_length  , ZNSYMS)) return 0;
            if (!zbuild_huffman(&a->z_distance, zdefault_distance,  32)) return 0;
         } else {
            if (!compute_huffman_codes(a)) return 0;
         }
         if (!parse_huffman_block(a)) return 0;
      }
   } while (!final);
   return 1;
}

static int do_zlib(zbuf *a, char *obuf, int olen, int exp, int parse_header)
{
   a->zout_start = obuf;
   a->zout       = obuf;
   a->zout_end   = obuf + olen;
   a->z_expandable = exp;

   return parse_zlib(a, parse_header);
}

STBIDEF char *stbi_zlib_decode_malloc_guesssize(const char *buffer, int len, int initial_size, int *outlen)
{
   zbuf a;
   char *p = (char *) STBI_MALLOC(initial_size);
   if (p == NULL) return NULL;
   a.zbuffer = (stbi_uc *) buffer;
   a.zbuffer_end = (stbi_uc *) buffer + len;
   if (do_zlib(&a, p, initial_size, 1, 1)) {
      if (outlen) *outlen = (int) (a.zout - a.zout_start);
      return a.zout_start;
   } else {
      STBI_FREE(a.zout_start);
      return NULL;
   }
}

STBIDEF char *stbi_zlib_decode_malloc(char const *buffer, int len, int *outlen)
{
   return stbi_zlib_decode_malloc_guesssize(buffer, len, 16384, outlen);
}

STBIDEF char *stbi_zlib_decode_malloc_guesssize_headerflag(const char *buffer, int len, int initial_size, int *outlen, int parse_header)
{
   zbuf a;
   char *p = (char *) STBI_MALLOC(initial_size);
   if (p == NULL) return NULL;
   a.zbuffer = (stbi_uc *) buffer;
   a.zbuffer_end = (stbi_uc *) buffer + len;
   if (do_zlib(&a, p, initial_size, 1, parse_header)) {
      if (outlen) *outlen = (int) (a.zout - a.zout_start);
      return a.zout_start;
   } else {
      STBI_FREE(a.zout_start);
      return NULL;
   }
}

STBIDEF int stbi_zlib_decode_buffer(char *obuffer, int olen, char const *ibuffer, int ilen)
{
   zbuf a;
   a.zbuffer = (stbi_uc *) ibuffer;
   a.zbuffer_end = (stbi_uc *) ibuffer + ilen;
   if (do_zlib(&a, obuffer, olen, 0, 1))
      return (int) (a.zout - a.zout_start);
   else
      return -1;
}

STBIDEF char *stbi_zlib_decode_noheader_malloc(char const *buffer, int len, int *outlen)
{
   zbuf a;
   char *p = (char *) STBI_MALLOC(16384);
   if (p == NULL) return NULL;
   a.zbuffer = (stbi_uc *) buffer;
   a.zbuffer_end = (stbi_uc *) buffer+len;
   if (do_zlib(&a, p, 16384, 1, 0)) {
      if (outlen) *outlen = (int) (a.zout - a.zout_start);
      return a.zout_start;
   } else {
      STBI_FREE(a.zout_start);
      return NULL;
   }
}

STBIDEF int stbi_zlib_decode_noheader_buffer(char *obuffer, int olen, const char *ibuffer, int ilen)
{
   zbuf a;
   a.zbuffer = (stbi_uc *) ibuffer;
   a.zbuffer_end = (stbi_uc *) ibuffer + ilen;
   if (do_zlib(&a, obuffer, olen, 0, 0))
      return (int) (a.zout - a.zout_start);
   else
      return -1;
}

# public domain "baseline" PNG decoder   v0.10  Sean Barrett 2006-11-18
#    simple implementation
#      - only 8-bit samples
#      - no CRC checking
#      - allocates lots of intermediate memory
#        - avoids problem of streaming data between subsystems
#        - avoids explicit window management
#    performance
#      - uses stb_zlib, a PD zlib implementation with fast huffman decoding

typedef struct
{
   uint32 length;
   uint32 type;
} pngchunk;

static pngchunk get_chunk_header(context *s)
{
   pngchunk c;
   c.length = get32be(s);
   c.type   = get32be(s);
   return c;
}

check_png_header ← { # context *s
   png_sig ← @+⟨137,80,78,71,13,10,26,10⟩
   r←∧´(get8 s)⊸=png_sig
   err⍟(¬r)"bad png sig"‿"Not a PNG"
   r
}

typedef struct
{
   context *s;
   stbi_uc *idata, *expanded, *out;
   int depth;
} png;


enum {
   F_none=0,
   F_sub=1,
   F_up=2,
   F_avg=3,
   F_paeth=4,
   # synthetic filters used for first scanline to avoid needing a dummy row of 0s
   F_avg_first,
   F_paeth_first
};

static stbi_uc first_row_filter[5] =
{
   F_none,
   F_sub,
   F_none,
   F_avg_first,
   F_paeth_first
};

static int paeth(int a, int b, int c)
{
   int p = a + b - c;
   int pa = abs(p-a);
   int pb = abs(p-b);
   int pc = abs(p-c);
   if (pa <= pb && pa <= pc) return a;
   if (pb <= pc) return b;
   return c;
}

static const stbi_uc depth_scale_table[9] = { 0, 0xff, 0x55, 0, 0x11, 0,0,0, 0x01 };

# create the png data from post-deflated data
static int create_png_image_raw(png *a, stbi_uc *raw, uint32 raw_len, int out_n, uint32 x, uint32 y, int depth, int color)
{
   int bytes = (depth == 16? 2 : 1);
   context *s = a->s;
   uint32 i,j,stride = x*out_n*bytes;
   uint32 img_len, img_width_bytes;
   int k;
   int img_n = s->img_n; # copy it into a local for later

   int output_bytes = out_n*bytes;
   int filter_bytes = img_n*bytes;
   int width = x;

   STBI_ASSERT(out_n == s->img_n || out_n == s->img_n+1);
   a->out = (stbi_uc *) malloc_mad3(x, y, output_bytes, 0); # extra bytes to write off the end into
   if (!a->out) return err("outofmem", "Out of memory");

   if (!mad3sizes_valid(img_n, x, depth, 7)) return err("too large", "Corrupt PNG");
   img_width_bytes = (((img_n * x * depth) + 7) >> 3);
   img_len = (img_width_bytes + 1) * y;

   # we used to check for exact match between raw_len and img_len on non-interlaced PNGs,
   # but issue #276 reported a PNG in the wild that had extra data at the end (all zeros),
   # so just check for raw_len < img_len always.
   if (raw_len < img_len) return err("not enough pixels","Corrupt PNG");

   for (j=0; j < y; ++j) {
      stbi_uc *cur = a->out + stride*j;
      stbi_uc *prior;
      int filter = *raw++;

      if (filter > 4)
         return err("invalid filter","Corrupt PNG");

      if (depth < 8) {
         if (img_width_bytes > x) return err("invalid width","Corrupt PNG");
         cur += x*out_n - img_width_bytes; # store output to the rightmost img_len bytes, so we can decode in place
         filter_bytes = 1;
         width = img_width_bytes;
      }
      prior = cur - stride; # bugfix: need to compute this after 'cur +=' computation above

      # if first row, use special filter that doesn't sample previous row
      if (j == 0) filter = first_row_filter[filter];

      # handle first byte explicitly
      for (k=0; k < filter_bytes; ++k) {
         switch (filter) {
            case F_none       : cur[k] = raw[k]; break;
            case F_sub        : cur[k] = raw[k]; break;
            case F_up         : cur[k] = BYTECAST(raw[k] + prior[k]); break;
            case F_avg        : cur[k] = BYTECAST(raw[k] + (prior[k]>>1)); break;
            case F_paeth      : cur[k] = BYTECAST(raw[k] + paeth(0,prior[k],0)); break;
            case F_avg_first  : cur[k] = raw[k]; break;
            case F_paeth_first: cur[k] = raw[k]; break;
         }
      }

      if (depth == 8) {
         if (img_n != out_n)
            cur[img_n] = 255; # first pixel
         raw += img_n;
         cur += out_n;
         prior += out_n;
      } else if (depth == 16) {
         if (img_n != out_n) {
            cur[filter_bytes]   = 255; # first pixel top byte
            cur[filter_bytes+1] = 255; # first pixel bottom byte
         }
         raw += filter_bytes;
         cur += output_bytes;
         prior += output_bytes;
      } else {
         raw += 1;
         cur += 1;
         prior += 1;
      }

      # this is a little gross, so that we don't switch per-pixel or per-component
      if (depth < 8 || img_n == out_n) {
         int nk = (width - 1)*filter_bytes;
         #define CASE(f) \
             case f:     \
                for (k=0; k < nk; ++k)
         switch (filter) {
            # "none" filter turns into a memcpy here; make that explicit.
            case F_none:         memcpy(cur, raw, nk); break;
            CASE(F_sub)          { cur[k] = BYTECAST(raw[k] + cur[k-filter_bytes]); } break;
            CASE(F_up)           { cur[k] = BYTECAST(raw[k] + prior[k]); } break;
            CASE(F_avg)          { cur[k] = BYTECAST(raw[k] + ((prior[k] + cur[k-filter_bytes])>>1)); } break;
            CASE(F_paeth)        { cur[k] = BYTECAST(raw[k] + paeth(cur[k-filter_bytes],prior[k],prior[k-filter_bytes])); } break;
            CASE(F_avg_first)    { cur[k] = BYTECAST(raw[k] + (cur[k-filter_bytes] >> 1)); } break;
            CASE(F_paeth_first)  { cur[k] = BYTECAST(raw[k] + paeth(cur[k-filter_bytes],0,0)); } break;
         }
         #undef CASE
         raw += nk;
      } else {
         STBI_ASSERT(img_n+1 == out_n);
         #define CASE(f) \
             case f:     \
                for (i=x-1; i >= 1; --i, cur[filter_bytes]=255,raw+=filter_bytes,cur+=output_bytes,prior+=output_bytes) \
                   for (k=0; k < filter_bytes; ++k)
         switch (filter) {
            CASE(F_none)         { cur[k] = raw[k]; } break;
            CASE(F_sub)          { cur[k] = BYTECAST(raw[k] + cur[k- output_bytes]); } break;
            CASE(F_up)           { cur[k] = BYTECAST(raw[k] + prior[k]); } break;
            CASE(F_avg)          { cur[k] = BYTECAST(raw[k] + ((prior[k] + cur[k- output_bytes])>>1)); } break;
            CASE(F_paeth)        { cur[k] = BYTECAST(raw[k] + paeth(cur[k- output_bytes],prior[k],prior[k- output_bytes])); } break;
            CASE(F_avg_first)    { cur[k] = BYTECAST(raw[k] + (cur[k- output_bytes] >> 1)); } break;
            CASE(F_paeth_first)  { cur[k] = BYTECAST(raw[k] + paeth(cur[k- output_bytes],0,0)); } break;
         }
         #undef CASE

         # the loop above sets the high byte of the pixels' alpha, but for
         # 16 bit png files we also need the low byte set. we'll do that here.
         if (depth == 16) {
            cur = a->out + stride*j; # start at the beginning of the row again
            for (i=0; i < x; ++i,cur+=output_bytes) {
               cur[filter_bytes+1] = 255;
            }
         }
      }
   }

   # we make a separate pass to expand bits to pixels; for performance,
   # this could run two scanlines behind the above code, so it won't
   # intefere with filtering but will still be in the cache.
   if (depth < 8) {
      for (j=0; j < y; ++j) {
         stbi_uc *cur = a->out + stride*j;
         stbi_uc *in  = a->out + stride*j + x*out_n - img_width_bytes;
         # unpack 1/2/4-bit into a 8-bit buffer. allows us to keep the common 8-bit path optimal at minimal cost for 1/2/4-bit
         # png guarante byte alignment, if width is not multiple of 8/4/2 we'll decode dummy trailing data that will be skipped in the later loop
         stbi_uc scale = (color == 0) ? depth_scale_table[depth] : 1; # scale grayscale values to 0..255 range

         # note that the final byte might overshoot and write more data than desired.
         # we can allocate enough data that this never writes out of memory, but it
         # could also overwrite the next scanline. can it overwrite non-empty data
         # on the next scanline? yes, consider 1-pixel-wide scanlines with 1-bit-per-pixel.
         # so we need to explicitly clamp the final ones

         if (depth == 4) {
            for (k=x*img_n; k >= 2; k-=2, ++in) {
               *cur++ = scale * ((*in >> 4)       );
               *cur++ = scale * ((*in     ) & 0x0f);
            }
            if (k > 0) *cur++ = scale * ((*in >> 4)       );
         } else if (depth == 2) {
            for (k=x*img_n; k >= 4; k-=4, ++in) {
               *cur++ = scale * ((*in >> 6)       );
               *cur++ = scale * ((*in >> 4) & 0x03);
               *cur++ = scale * ((*in >> 2) & 0x03);
               *cur++ = scale * ((*in     ) & 0x03);
            }
            if (k > 0) *cur++ = scale * ((*in >> 6)       );
            if (k > 1) *cur++ = scale * ((*in >> 4) & 0x03);
            if (k > 2) *cur++ = scale * ((*in >> 2) & 0x03);
         } else if (depth == 1) {
            for (k=x*img_n; k >= 8; k-=8, ++in) {
               *cur++ = scale * ((*in >> 7)       );
               *cur++ = scale * ((*in >> 6) & 0x01);
               *cur++ = scale * ((*in >> 5) & 0x01);
               *cur++ = scale * ((*in >> 4) & 0x01);
               *cur++ = scale * ((*in >> 3) & 0x01);
               *cur++ = scale * ((*in >> 2) & 0x01);
               *cur++ = scale * ((*in >> 1) & 0x01);
               *cur++ = scale * ((*in     ) & 0x01);
            }
            if (k > 0) *cur++ = scale * ((*in >> 7)       );
            if (k > 1) *cur++ = scale * ((*in >> 6) & 0x01);
            if (k > 2) *cur++ = scale * ((*in >> 5) & 0x01);
            if (k > 3) *cur++ = scale * ((*in >> 4) & 0x01);
            if (k > 4) *cur++ = scale * ((*in >> 3) & 0x01);
            if (k > 5) *cur++ = scale * ((*in >> 2) & 0x01);
            if (k > 6) *cur++ = scale * ((*in >> 1) & 0x01);
         }
         if (img_n != out_n) {
            int q;
            # insert alpha = 255
            cur = a->out + stride*j;
            if (img_n == 1) {
               for (q=x-1; q >= 0; --q) {
                  cur[q*2+1] = 255;
                  cur[q*2+0] = cur[q];
               }
            } else {
               STBI_ASSERT(img_n == 3);
               for (q=x-1; q >= 0; --q) {
                  cur[q*4+3] = 255;
                  cur[q*4+2] = cur[q*3+2];
                  cur[q*4+1] = cur[q*3+1];
                  cur[q*4+0] = cur[q*3+0];
               }
            }
         }
      }
   } else if (depth == 16) {
      # force the image data from big-endian to platform-native.
      # this is done in a separate pass due to the decoding relying
      # on the data being untouched, but could probably be done
      # per-line during decode if care is taken.
      stbi_uc *cur = a->out;
      uint16 *cur16 = (uint16*)cur;

      for(i=0; i < x*y*out_n; ++i,cur16++,cur+=2) {
         *cur16 = (cur[0] << 8) | cur[1];
      }
   }

   return 1;
}

static int create_png_image(png *a, stbi_uc *image_data, uint32 image_data_len, int out_n, int depth, int color, int interlaced)
{
   int bytes = (depth == 16 ? 2 : 1);
   int out_bytes = out_n * bytes;
   stbi_uc *final;
   int p;
   if (!interlaced)
      return create_png_image_raw(a, image_data, image_data_len, out_n, a->s->img_x, a->s->img_y, depth, color);

   # de-interlacing
   final = (stbi_uc *) malloc_mad3(a->s->img_x, a->s->img_y, out_bytes, 0);
   if (!final) return err("outofmem", "Out of memory");
   for (p=0; p < 7; ++p) {
      int xorig[] = { 0,4,0,2,0,1,0 };
      int yorig[] = { 0,0,4,0,2,0,1 };
      int xspc[]  = { 8,8,4,4,2,2,1 };
      int yspc[]  = { 8,8,8,4,4,2,2 };
      int i,j,x,y;
      # pass1_x[4] = 0, pass1_x[5] = 1, pass1_x[12] = 1
      x = (a->s->img_x - xorig[p] + xspc[p]-1) / xspc[p];
      y = (a->s->img_y - yorig[p] + yspc[p]-1) / yspc[p];
      if (x && y) {
         uint32 img_len = ((((a->s->img_n * x * depth) + 7) >> 3) + 1) * y;
         if (!create_png_image_raw(a, image_data, image_data_len, out_n, x, y, depth, color)) {
            STBI_FREE(final);
            return 0;
         }
         for (j=0; j < y; ++j) {
            for (i=0; i < x; ++i) {
               int out_y = j*yspc[p]+yorig[p];
               int out_x = i*xspc[p]+xorig[p];
               memcpy(final + out_y*a->s->img_x*out_bytes + out_x*out_bytes,
                      a->out + (j*x+i)*out_bytes, out_bytes);
            }
         }
         STBI_FREE(a->out);
         image_data += img_len;
         image_data_len -= img_len;
      }
   }
   a->out = final;

   return 1;
}

static int compute_transparency(png *z, stbi_uc tc[3], int out_n)
{
   context *s = z->s;
   uint32 i, pixel_count = s->img_x * s->img_y;
   stbi_uc *p = z->out;

   # compute color-based transparency, assuming we've
   # already got 255 as the alpha value in the output
   STBI_ASSERT(out_n == 2 || out_n == 4);

   if (out_n == 2) {
      for (i=0; i < pixel_count; ++i) {
         p[1] = (p[0] == tc[0] ? 0 : 255);
         p += 2;
      }
   } else {
      for (i=0; i < pixel_count; ++i) {
         if (p[0] == tc[0] && p[1] == tc[1] && p[2] == tc[2])
            p[3] = 0;
         p += 4;
      }
   }
   return 1;
}

static int compute_transparency16(png *z, uint16 tc[3], int out_n)
{
   context *s = z->s;
   uint32 i, pixel_count = s->img_x * s->img_y;
   uint16 *p = (uint16*) z->out;

   # compute color-based transparency, assuming we've
   # already got 65535 as the alpha value in the output
   STBI_ASSERT(out_n == 2 || out_n == 4);

   if (out_n == 2) {
      for (i = 0; i < pixel_count; ++i) {
         p[1] = (p[0] == tc[0] ? 0 : 65535);
         p += 2;
      }
   } else {
      for (i = 0; i < pixel_count; ++i) {
         if (p[0] == tc[0] && p[1] == tc[1] && p[2] == tc[2])
            p[3] = 0;
         p += 4;
      }
   }
   return 1;
}

static int expand_png_palette(png *a, stbi_uc *palette, int len, int pal_img_n)
{
   uint32 i, pixel_count = a->s->img_x * a->s->img_y;
   stbi_uc *p, *temp_out, *orig = a->out;

   p = (stbi_uc *) malloc_mad2(pixel_count, pal_img_n, 0);
   if (p == NULL) return err("outofmem", "Out of memory");

   # between here and free(out) below, exitting would leak
   temp_out = p;

   if (pal_img_n == 3) {
      for (i=0; i < pixel_count; ++i) {
         int n = orig[i]*4;
         p[0] = palette[n  ];
         p[1] = palette[n+1];
         p[2] = palette[n+2];
         p += 3;
      }
   } else {
      for (i=0; i < pixel_count; ++i) {
         int n = orig[i]*4;
         p[0] = palette[n  ];
         p[1] = palette[n+1];
         p[2] = palette[n+2];
         p[3] = palette[n+3];
         p += 4;
      }
   }
   STBI_FREE(a->out);
   a->out = temp_out;

   STBI_NOTUSED(len);

   return 1;
}

static int unpremultiply_on_load_global = 0;
static int de_iphone_flag_global = 0;

STBIDEF void stbi_set_unpremultiply_on_load(int flag_true_if_should_unpremultiply)
{
   unpremultiply_on_load_global = flag_true_if_should_unpremultiply;
}

STBIDEF void stbi_convert_iphone_png_to_rgb(int flag_true_if_should_convert)
{
   de_iphone_flag_global = flag_true_if_should_convert;
}

#define unpremultiply_on_load  unpremultiply_on_load_global
#define de_iphone_flag  de_iphone_flag_global

static void de_iphone(png *z)
{
   context *s = z->s;
   uint32 i, pixel_count = s->img_x * s->img_y;
   stbi_uc *p = z->out;

   if (s->img_out_n == 3) {  # convert bgr to rgb
      for (i=0; i < pixel_count; ++i) {
         stbi_uc t = p[0];
         p[0] = p[2];
         p[2] = t;
         p += 3;
      }
   } else {
      STBI_ASSERT(s->img_out_n == 4);
      if (unpremultiply_on_load) {
         # convert bgr to rgb and unpremultiply
         for (i=0; i < pixel_count; ++i) {
            stbi_uc a = p[3];
            stbi_uc t = p[0];
            if (a) {
               stbi_uc half = a / 2;
               p[0] = (p[2] * 255 + half) / a;
               p[1] = (p[1] * 255 + half) / a;
               p[2] = ( t   * 255 + half) / a;
            } else {
               p[0] = p[2];
               p[2] = t;
            }
            p += 4;
         }
      } else {
         # convert bgr to rgb
         for (i=0; i < pixel_count; ++i) {
            stbi_uc t = p[0];
            p[0] = p[2];
            p[2] = t;
            p += 4;
         }
      }
   }
}

#define PNG_TYPE(a,b,c,d)  (((unsigned) (a) << 24) + ((unsigned) (b) << 16) + ((unsigned) (c) << 8) + (unsigned) (d))

parse_png_file ← { # png‿int‿int ⋄ z‿scan‿req_comp → int
   palette←1024⥊""
   pal_img_n ← @
   has_trans ← @
   tc ← 3⥊""
   tc16 ← 3⥊0
   ioff ← 0
   idata_limit ← 0
   i ← 0
   pal_len ← 0
   first ← 1
   k ← 0
   interlace ← 0
   color ← 0
   is_iphone ← 0
   context *s = z->s

   # fields of z
   expanded ← @
   idata ← @
   out ← @

# {
#    context *s;
#    stbi_uc *idata, *expanded, *out;
#    int depth;
# } png;

   if (¬check_png_header(s)) return 0;

   if (scan = scan_type) return 1;

   for (;;) {
      pngchunk c = get_chunk_header(s);
      switch (c.type) {
         case PNG_TYPE('C','g','B','I'):
            is_iphone = 1;
            skip(s, c.length);
            break;
         case PNG_TYPE('I','H','D','R'): {
            int comp,filter;
            if (!first) return err("multiple IHDR","Corrupt PNG");
            first = 0;
            if (c.length != 13) return err("bad IHDR len","Corrupt PNG");
            s->img_x = get32be(s);
            s->img_y = get32be(s);
            if (s->img_y > STBI_MAX_DIMENSIONS) return err("too large","Very large image (corrupt?)");
            if (s->img_x > STBI_MAX_DIMENSIONS) return err("too large","Very large image (corrupt?)");
            z->depth = get8(s);  if (z->depth != 1 && z->depth != 2 && z->depth != 4 && z->depth != 8 && z->depth != 16)  return err("1/2/4/8/16-bit only","PNG not supported: 1/2/4/8/16-bit only");
            color = get8(s);  if (color > 6)         return err("bad ctype","Corrupt PNG");
            if (color == 3 && z->depth == 16)                  return err("bad ctype","Corrupt PNG");
            if (color == 3) pal_img_n = 3; else if (color & 1) return err("bad ctype","Corrupt PNG");
            comp  = get8(s);  if (comp) return err("bad comp method","Corrupt PNG");
            filter= get8(s);  if (filter) return err("bad filter method","Corrupt PNG");
            interlace = get8(s); if (interlace>1) return err("bad interlace method","Corrupt PNG");
            if (!s->img_x || !s->img_y) return err("0-pixel image","Corrupt PNG");
            if (!pal_img_n) {
               s->img_n = (color & 2 ? 3 : 1) + (color & 4 ? 1 : 0);
               if ((1 << 30) / s->img_x / s->img_n < s->img_y) return err("too large", "Image too large to decode");
            } else {
               # if paletted, then pal_n is our final components, and
               # img_n is # components to decompress/filter.
               s->img_n = 1;
               if ((1 << 30) / s->img_x / 4 < s->img_y) return err("too large","Corrupt PNG");
            }
            # even with SCAN_header, have to scan to see if we have a tRNS
            break;
         }

         case PNG_TYPE('P','L','T','E'):  {
            if (first) return err("first not IHDR", "Corrupt PNG");
            if (c.length > 256*3) return err("invalid PLTE","Corrupt PNG");
            pal_len = c.length / 3;
            if (pal_len * 3 != c.length) return err("invalid PLTE","Corrupt PNG");
            for (i=0; i < pal_len; ++i) {
               palette[i*4+0] = get8(s);
               palette[i*4+1] = get8(s);
               palette[i*4+2] = get8(s);
               palette[i*4+3] = 255;
            }
            break;
         }

         case PNG_TYPE('t','R','N','S'): {
            if (first) return err("first not IHDR", "Corrupt PNG");
            if (z->idata) return err("tRNS after IDAT","Corrupt PNG");
            if (pal_img_n) {
               if (scan == SCAN_header) { s->img_n = 4; return 1; }
               if (pal_len == 0) return err("tRNS before PLTE","Corrupt PNG");
               if (c.length > pal_len) return err("bad tRNS len","Corrupt PNG");
               pal_img_n = 4;
               for (i=0; i < c.length; ++i)
                  palette[i*4+3] = get8(s);
            } else {
               if (!(s->img_n & 1)) return err("tRNS with alpha","Corrupt PNG");
               if (c.length != (uint32) s->img_n*2) return err("bad tRNS len","Corrupt PNG");
               has_trans = 1;
               # non-paletted with tRNS = constant alpha. if header-scanning, we can stop now.
               if (scan == SCAN_header) { ++s->img_n; return 1; }
               if (z->depth == 16) {
                  for (k = 0; k < s->img_n; ++k) tc16[k] = (uint16)get16be(s); # copy the values as-is
               } else {
                  for (k = 0; k < s->img_n; ++k) tc[k] = (stbi_uc)(get16be(s) & 255) * depth_scale_table[z->depth]; # non 8-bit images will be larger
               }
            }
            break;
         }

         case PNG_TYPE('I','D','A','T'): {
            if (first) return err("first not IHDR", "Corrupt PNG");
            if (pal_img_n && !pal_len) return err("no PLTE","Corrupt PNG");
            if (scan == SCAN_header) {
               # header scan definitely stops at first IDAT
               if (pal_img_n)
                  s->img_n = pal_img_n;
               return 1;
            }
            if (c.length > (1u << 30)) return err("IDAT size limit", "IDAT section larger than 2^30 bytes");
            if ((int)(ioff + c.length) < (int)ioff) return 0;
            if (ioff + c.length > idata_limit) {
               uint32 idata_limit_old = idata_limit;
               stbi_uc *p;
               if (idata_limit == 0) idata_limit = c.length > 4096 ? c.length : 4096;
               while (ioff + c.length > idata_limit)
                  idata_limit *= 2;
               STBI_NOTUSED(idata_limit_old);
               p = (stbi_uc *) STBI_REALLOC_SIZED(z->idata, idata_limit_old, idata_limit); if (p == NULL) return err("outofmem", "Out of memory");
               z->idata = p;
            }
            if (!getn(s, z->idata+ioff,c.length)) return err("outofdata","Corrupt PNG");
            ioff += c.length;
            break;
         }

         case PNG_TYPE('I','E','N','D'): {
            uint32 raw_len, bpl;
            if (first) return err("first not IHDR", "Corrupt PNG");
            if (scan != SCAN_load) return 1;
            if (z->idata == NULL) return err("no IDAT","Corrupt PNG");
            # initial guess for decoded data size to avoid unnecessary reallocs
            bpl = (s->img_x * z->depth + 7) / 8; # bytes per line, per component
            raw_len = bpl * s->img_y * s->img_n /* pixels */ + s->img_y /* filter mode per row */;
            z->expanded = (stbi_uc *) stbi_zlib_decode_malloc_guesssize_headerflag((char *) z->idata, ioff, raw_len, (int *) &raw_len, !is_iphone);
            if (z->expanded == NULL) return 0; # zlib should set error
            STBI_FREE(z->idata); z->idata = NULL;
            if ((req_comp == s->img_n+1 && req_comp != 3 && !pal_img_n) || has_trans)
               s->img_out_n = s->img_n+1;
            else
               s->img_out_n = s->img_n;
            if (!create_png_image(z, z->expanded, raw_len, s->img_out_n, z->depth, color, interlace)) return 0;
            if (has_trans) {
               if (z->depth == 16) {
                  if (!compute_transparency16(z, tc16, s->img_out_n)) return 0;
               } else {
                  if (!compute_transparency(z, tc, s->img_out_n)) return 0;
               }
            }
            if (is_iphone && de_iphone_flag && s->img_out_n > 2)
               de_iphone(z);
            if (pal_img_n) {
               # pal_img_n == 3 or 4
               s->img_n = pal_img_n; # record the actual colors we had
               s->img_out_n = pal_img_n;
               if (req_comp >= 3) s->img_out_n = req_comp;
               if (!expand_png_palette(z, palette, pal_len, s->img_out_n))
                  return 0;
            } else if (has_trans) {
               # non-paletted image with tRNS -> source image has (constant) alpha
               ++s->img_n;
            }
            STBI_FREE(z->expanded); z->expanded = NULL;
            # end of PNG chunk, read and skip CRC
            get32be(s);
            return 1;
         }

         default:
            # if critical, fail
            if (first) return err("first not IHDR", "Corrupt PNG");
            if ((c.type & (1 << 29)) == 0) {
               # not threadsafe
               static char invalid_chunk[] = "XXXX PNG chunk not known";
               invalid_chunk[0] = BYTECAST(c.type >> 24);
               invalid_chunk[1] = BYTECAST(c.type >> 16);
               invalid_chunk[2] = BYTECAST(c.type >>  8);
               invalid_chunk[3] = BYTECAST(c.type >>  0);
               return err(invalid_chunk, "PNG not supported: unknown PNG chunk type");
            }
            skip(s, c.length);
            break;
      }
      # end of PNG chunk, read and skip CRC
      get32be(s);
   }
}

static void *do_png(png *p, int *x, int *y, int *n, int req_comp, result_info *ri)
{
   void *result=NULL;
   if (req_comp < 0 || req_comp > 4) return errpuc("bad req_comp", "Internal error");
   if (parse_png_file(p, SCAN_load, req_comp)) {
      if (p->depth <= 8)
         ri->bits_per_channel = 8;
      else if (p->depth == 16)
         ri->bits_per_channel = 16;
      else
         return errpuc("bad bits_per_channel", "PNG not supported: unsupported color depth");
      result = p->out;
      p->out = NULL;
      if (req_comp && req_comp != p->s->img_out_n) {
         if (ri->bits_per_channel == 8)
            result = convert_format((unsigned char *) result, p->s->img_out_n, req_comp, p->s->img_x, p->s->img_y);
         else
            result = convert_format16((uint16 *) result, p->s->img_out_n, req_comp, p->s->img_x, p->s->img_y);
         p->s->img_out_n = req_comp;
         if (result == NULL) return result;
      }
      *x = p->s->img_x;
      *y = p->s->img_y;
      if (n) *n = p->s->img_n;
   }
   STBI_FREE(p->out);      p->out      = NULL;
   STBI_FREE(p->expanded); p->expanded = NULL;
   STBI_FREE(p->idata);    p->idata    = NULL;

   return result;
}

static void *png_load(context *s, int *x, int *y, int *comp, int req_comp, result_info *ri)
{
   png p;
   p.s = s;
   return do_png(&p, x,y,comp,req_comp, ri);
}

static int png_info_raw(png *p, int *x, int *y, int *comp)
{
   if (!parse_png_file(p, SCAN_header, 0)) {
      rewind( p->s );
      return 0;
   }
   if (x) *x = p->s->img_x;
   if (y) *y = p->s->img_y;
   if (comp) *comp = p->s->img_n;
   return 1;
}

static int png_info(context *s, int *x, int *y, int *comp)
{
   png p;
   p.s = s;
   return png_info_raw(&p, x, y, comp);
}

static int png_is16(context *s)
{
   png p;
   p.s = s;
   if (!png_info_raw(&p, NULL, NULL, NULL))
	   return 0;
   if (p.depth != 16) {
      rewind(p.s);
      return 0;
   }
   return 1;
}

# *************************************************************************************************
# GIF loader -- public domain by Jean-Marc Lienher -- simplified/shrunk by stb

typedef struct
{
   int16 prefix;
   stbi_uc first;
   stbi_uc suffix;
} gif_lzw;

typedef struct
{
   int w,h;
   stbi_uc *out;                 # output buffer (always 4 components)
   stbi_uc *background;          # The current "background" as far as a gif is concerned
   stbi_uc *history;
   int flags, bgindex, ratio, transparent, eflags;
   stbi_uc  pal[256][4];
   stbi_uc lpal[256][4];
   gif_lzw codes[8192];
   stbi_uc *color_table;
   int parse, step;
   int lflags;
   int start_x, start_y;
   int max_x, max_y;
   int cur_x, cur_y;
   int line_size;
   int delay;
} gif;

static int gif_test_raw(context *s)
{
   int sz;
   if (get8(s) != 'G' || get8(s) != 'I' || get8(s) != 'F' || get8(s) != '8') return 0;
   sz = get8(s);
   if (sz != '9' && sz != '7') return 0;
   if (get8(s) != 'a') return 0;
   return 1;
}

static int gif_test(context *s)
{
   int r = gif_test_raw(s);
   rewind(s);
   return r;
}

static void gif_parse_colortable(context *s, stbi_uc pal[256][4], int num_entries, int transp)
{
   int i;
   for (i=0; i < num_entries; ++i) {
      pal[i][2] = get8(s);
      pal[i][1] = get8(s);
      pal[i][0] = get8(s);
      pal[i][3] = transp == i ? 0 : 255;
   }
}

static int gif_header(context *s, gif *g, int *comp, int is_info)
{
   stbi_uc version;
   if (get8(s) != 'G' || get8(s) != 'I' || get8(s) != 'F' || get8(s) != '8')
      return err("not GIF", "Corrupt GIF");

   version = get8(s);
   if (version != '7' && version != '9')    return err("not GIF", "Corrupt GIF");
   if (get8(s) != 'a')                return err("not GIF", "Corrupt GIF");

   g_failure_reason = "";
   g->w = get16le(s);
   g->h = get16le(s);
   g->flags = get8(s);
   g->bgindex = get8(s);
   g->ratio = get8(s);
   g->transparent = -1;

   if (g->w > STBI_MAX_DIMENSIONS) return err("too large","Very large image (corrupt?)");
   if (g->h > STBI_MAX_DIMENSIONS) return err("too large","Very large image (corrupt?)");

   if (comp != 0) *comp = 4;  # can't actually tell whether it's 3 or 4 until we parse the comments

   if (is_info) return 1;

   if (g->flags & 0x80)
      gif_parse_colortable(s,g->pal, 2 << (g->flags & 7), -1);

   return 1;
}

static int gif_info_raw(context *s, int *x, int *y, int *comp)
{
   gif* g = (gif*) STBI_MALLOC(sizeof(gif));
   if (!g) return err("outofmem", "Out of memory");
   if (!gif_header(s, g, comp, 1)) {
      STBI_FREE(g);
      rewind( s );
      return 0;
   }
   if (x) *x = g->w;
   if (y) *y = g->h;
   STBI_FREE(g);
   return 1;
}

static void out_gif_code(gif *g, uint16 code)
{
   stbi_uc *p, *c;
   int idx;

   # recurse to decode the prefixes, since the linked-list is backwards,
   # and working backwards through an interleaved image would be nasty
   if (g->codes[code].prefix >= 0)
      out_gif_code(g, g->codes[code].prefix);

   if (g->cur_y >= g->max_y) return;

   idx = g->cur_x + g->cur_y;
   p = &g->out[idx];
   g->history[idx / 4] = 1;

   c = &g->color_table[g->codes[code].suffix * 4];
   if (c[3] > 128) { # don't render transparent pixels;
      p[0] = c[2];
      p[1] = c[1];
      p[2] = c[0];
      p[3] = c[3];
   }
   g->cur_x += 4;

   if (g->cur_x >= g->max_x) {
      g->cur_x = g->start_x;
      g->cur_y += g->step;

      while (g->cur_y >= g->max_y && g->parse > 0) {
         g->step = (1 << g->parse) * g->line_size;
         g->cur_y = g->start_y + (g->step >> 1);
         --g->parse;
      }
   }
}

static stbi_uc *process_gif_raster(context *s, gif *g)
{
   stbi_uc lzw_cs;
   int32 len, init_code;
   uint32 first;
   int32 codesize, codemask, avail, oldcode, bits, valid_bits, clear;
   gif_lzw *p;

   lzw_cs = get8(s);
   if (lzw_cs > 12) return NULL;
   clear = 1 << lzw_cs;
   first = 1;
   codesize = lzw_cs + 1;
   codemask = (1 << codesize) - 1;
   bits = 0;
   valid_bits = 0;
   for (init_code = 0; init_code < clear; init_code++) {
      g->codes[init_code].prefix = -1;
      g->codes[init_code].first = (stbi_uc) init_code;
      g->codes[init_code].suffix = (stbi_uc) init_code;
   }

   # support no starting clear code
   avail = clear+2;
   oldcode = -1;

   len = 0;
   for(;;) {
      if (valid_bits < codesize) {
         if (len == 0) {
            len = get8(s); # start new block
            if (len == 0)
               return g->out;
         }
         --len;
         bits |= (int32) get8(s) << valid_bits;
         valid_bits += 8;
      } else {
         int32 code = bits & codemask;
         bits >>= codesize;
         valid_bits -= codesize;
         # @OPTIMIZE: is there some way we can accelerate the non-clear path?
         if (code == clear) {  # clear code
            codesize = lzw_cs + 1;
            codemask = (1 << codesize) - 1;
            avail = clear + 2;
            oldcode = -1;
            first = 0;
         } else if (code == clear + 1) { # end of stream code
            skip(s, len);
            while ((len = get8(s)) > 0)
               skip(s,len);
            return g->out;
         } else if (code <= avail) {
            if (first) {
               return errpuc("no clear code", "Corrupt GIF");
            }

            if (oldcode >= 0) {
               p = &g->codes[avail++];
               if (avail > 8192) {
                  return errpuc("too many codes", "Corrupt GIF");
               }

               p->prefix = (int16) oldcode;
               p->first = g->codes[oldcode].first;
               p->suffix = (code == avail) ? p->first : g->codes[code].first;
            } else if (code == avail)
               return errpuc("illegal code in raster", "Corrupt GIF");

            out_gif_code(g, (uint16) code);

            if ((avail & codemask) == 0 && avail <= 0x0FFF) {
               codesize++;
               codemask = (1 << codesize) - 1;
            }

            oldcode = code;
         } else {
            return errpuc("illegal code in raster", "Corrupt GIF");
         }
      }
   }
}

# this function is designed to support animated gifs, although stb_image doesn't support it
# two back is the image from two frames ago, used for a very specific disposal format
static stbi_uc *gif_load_next(context *s, gif *g, int *comp, int req_comp, stbi_uc *two_back)
{
   int dispose;
   int first_frame;
   int pi;
   int pcount;
   STBI_NOTUSED(req_comp);

   # on first frame, any non-written pixels get the background colour (non-transparent)
   first_frame = 0;
   if (g->out == 0) {
      if (!gif_header(s, g, comp,0)) return 0; # g_failure_reason set by gif_header
      if (!mad3sizes_valid(4, g->w, g->h, 0))
         return errpuc("too large", "GIF image is too large");
      pcount = g->w * g->h;
      g->out = (stbi_uc *) STBI_MALLOC(4 * pcount);
      g->background = (stbi_uc *) STBI_MALLOC(4 * pcount);
      g->history = (stbi_uc *) STBI_MALLOC(pcount);
      if (!g->out || !g->background || !g->history)
         return errpuc("outofmem", "Out of memory");

      # image is treated as "transparent" at the start - ie, nothing overwrites the current background;
      # background colour is only used for pixels that are not rendered first frame, after that "background"
      # color refers to the color that was there the previous frame.
      memset(g->out, 0x00, 4 * pcount);
      memset(g->background, 0x00, 4 * pcount); # state of the background (starts transparent)
      memset(g->history, 0x00, pcount);        # pixels that were affected previous frame
      first_frame = 1;
   } else {
      # second frame - how do we dispose of the previous one?
      dispose = (g->eflags & 0x1C) >> 2;
      pcount = g->w * g->h;

      if ((dispose == 3) && (two_back == 0)) {
         dispose = 2; # if I don't have an image to revert back to, default to the old background
      }

      if (dispose == 3) { # use previous graphic
         for (pi = 0; pi < pcount; ++pi) {
            if (g->history[pi]) {
               memcpy( &g->out[pi * 4], &two_back[pi * 4], 4 );
            }
         }
      } else if (dispose == 2) {
         # restore what was changed last frame to background before that frame;
         for (pi = 0; pi < pcount; ++pi) {
            if (g->history[pi]) {
               memcpy( &g->out[pi * 4], &g->background[pi * 4], 4 );
            }
         }
      } else {
         # This is a non-disposal case eithe way, so just
         # leave the pixels as is, and they will become the new background
         # 1: do not dispose
         # 0:  not specified.
      }

      # background is what out is after the undoing of the previou frame;
      memcpy( g->background, g->out, 4 * g->w * g->h );
   }

   # clear my history;
   memset( g->history, 0x00, g->w * g->h );        # pixels that were affected previous frame

   for (;;) {
      int tag = get8(s);
      switch (tag) {
         case 0x2C: /* Image Descriptor */
         {
            int32 x, y, w, h;
            stbi_uc *o;

            x = get16le(s);
            y = get16le(s);
            w = get16le(s);
            h = get16le(s);
            if (((x + w) > (g->w)) || ((y + h) > (g->h)))
               return errpuc("bad Image Descriptor", "Corrupt GIF");

            g->line_size = g->w * 4;
            g->start_x = x * 4;
            g->start_y = y * g->line_size;
            g->max_x   = g->start_x + w * 4;
            g->max_y   = g->start_y + h * g->line_size;
            g->cur_x   = g->start_x;
            g->cur_y   = g->start_y;

            # if the width of the specified rectangle is 0, that means
            # we may not see *any* pixels or the image is malformed;
            # to make sure this is caught, move the current y down to
            # max_y (which is what out_gif_code checks).
            if (w == 0)
               g->cur_y = g->max_y;

            g->lflags = get8(s);

            if (g->lflags & 0x40) {
               g->step = 8 * g->line_size; # first interlaced spacing
               g->parse = 3;
            } else {
               g->step = g->line_size;
               g->parse = 0;
            }

            if (g->lflags & 0x80) {
               gif_parse_colortable(s,g->lpal, 2 << (g->lflags & 7), g->eflags & 0x01 ? g->transparent : -1);
               g->color_table = (stbi_uc *) g->lpal;
            } else if (g->flags & 0x80) {
               g->color_table = (stbi_uc *) g->pal;
            } else
               return errpuc("missing color table", "Corrupt GIF");

            o = process_gif_raster(s, g);
            if (!o) return NULL;

            # if this was the first frame,
            pcount = g->w * g->h;
            if (first_frame && (g->bgindex > 0)) {
               # if first frame, any pixel not drawn to gets the background color
               for (pi = 0; pi < pcount; ++pi) {
                  if (g->history[pi] == 0) {
                     g->pal[g->bgindex][3] = 255; # just in case it was made transparent, undo that; It will be reset next frame if need be;
                     memcpy( &g->out[pi * 4], &g->pal[g->bgindex], 4 );
                  }
               }
            }

            return o;
         }

         case 0x21: # Comment Extension.
         {
            int len;
            int ext = get8(s);
            if (ext == 0xF9) { # Graphic Control Extension.
               len = get8(s);
               if (len == 4) {
                  g->eflags = get8(s);
                  g->delay = 10 * get16le(s); # delay - 1/100th of a second, saving as 1/1000ths.

                  # unset old transparent
                  if (g->transparent >= 0) {
                     g->pal[g->transparent][3] = 255;
                  }
                  if (g->eflags & 0x01) {
                     g->transparent = get8(s);
                     if (g->transparent >= 0) {
                        g->pal[g->transparent][3] = 0;
                     }
                  } else {
                     # don't need transparent
                     skip(s, 1);
                     g->transparent = -1;
                  }
               } else {
                  skip(s, len);
                  break;
               }
            }
            while ((len = get8(s)) != 0) {
               skip(s, len);
            }
            break;
         }

         case 0x3B: # gif stream termination code
            return (stbi_uc *) s; # using '1' causes warning on some compilers

         default:
            return errpuc("unknown code", "Corrupt GIF");
      }
   }
}

static void *load_gif_main_outofmem(gif *g, stbi_uc *out, int **delays)
{
   STBI_FREE(g->out);
   STBI_FREE(g->history);
   STBI_FREE(g->background);

   if (out) STBI_FREE(out);
   if (delays && *delays) STBI_FREE(*delays);
   return errpuc("outofmem", "Out of memory");
}

static void *load_gif_main(context *s, int **delays, int *x, int *y, int *z, int *comp, int req_comp)
{
   if (gif_test(s)) {
      int layers = 0;
      stbi_uc *u = 0;
      stbi_uc *out = 0;
      stbi_uc *two_back = 0;
      gif g;
      int stride;
      int out_size = 0;
      int delays_size = 0;

      STBI_NOTUSED(out_size);
      STBI_NOTUSED(delays_size);

      memset(&g, 0, sizeof(g));
      if (delays) {
         *delays = 0;
      }

      do {
         u = gif_load_next(s, &g, comp, req_comp, two_back);
         if (u == (stbi_uc *) s) u = 0;  # end of animated gif marker

         if (u) {
            *x = g.w;
            *y = g.h;
            ++layers;
            stride = g.w * g.h * 4;

            if (out) {
               void *tmp = (stbi_uc*) STBI_REALLOC_SIZED( out, out_size, layers * stride );
               if (!tmp)
                  return load_gif_main_outofmem(&g, out, delays);
               else {
                   out = (stbi_uc*) tmp;
                   out_size = layers * stride;
               }

               if (delays) {
                  int *new_delays = (int*) STBI_REALLOC_SIZED( *delays, delays_size, sizeof(int) * layers );
                  if (!new_delays)
                     return load_gif_main_outofmem(&g, out, delays);
                  *delays = new_delays;
                  delays_size = layers * sizeof(int);
               }
            } else {
               out = (stbi_uc*)STBI_MALLOC( layers * stride );
               if (!out)
                  return load_gif_main_outofmem(&g, out, delays);
               out_size = layers * stride;
               if (delays) {
                  *delays = (int*) STBI_MALLOC( layers * sizeof(int) );
                  if (!*delays)
                     return load_gif_main_outofmem(&g, out, delays);
                  delays_size = layers * sizeof(int);
               }
            }
            memcpy( out + ((layers - 1) * stride), u, stride );
            if (layers >= 2) {
               two_back = out - 2 * stride;
            }

            if (delays) {
               (*delays)[layers - 1U] = g.delay;
            }
         }
      } while (u != 0);

      # free temp buffer;
      STBI_FREE(g.out);
      STBI_FREE(g.history);
      STBI_FREE(g.background);

      # do the final conversion after loading everything;
      if (req_comp && req_comp != 4)
         out = convert_format(out, 4, req_comp, layers * g.w, g.h);

      *z = layers;
      return out;
   } else {
      return errpuc("not GIF", "Image was not as a gif type.");
   }
}

static void *gif_load(context *s, int *x, int *y, int *comp, int req_comp, result_info *ri)
{
   stbi_uc *u = 0;
   gif g;
   memset(&g, 0, sizeof(g));
   STBI_NOTUSED(ri);

   u = gif_load_next(s, &g, comp, req_comp, 0);
   if (u == (stbi_uc *) s) u = 0;  # end of animated gif marker
   if (u) {
      *x = g.w;
      *y = g.h;

      # moved conversion to after successful load so that the same
      # can be done for multiple frames.
      if (req_comp && req_comp != 4)
         u = convert_format(u, 4, req_comp, g.w, g.h);
   } else if (g.out) {
      # if there was an error and we allocated an image buffer, free it!
      STBI_FREE(g.out);
   }

   # free buffers needed for multiple frame loading;
   STBI_FREE(g.history);
   STBI_FREE(g.background);

   return u;
}

static int info_main(context *s, int *x, int *y, int *comp)
{
   if (png_info(s, x, y, comp))  return 1;
   if (gif_info_raw(s, x, y, comp))  return 1;

   return err("unknown image type", "Image not of any known type, or corrupt");
}

STBIDEF int stbi_info_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp)
{
   context s;
   start_mem(&s,buffer,len);
   return info_main(&s,x,y,comp);
}

STBIDEF int stbi_info_from_callbacks(stbi_io_callbacks const *c, void *user, int *x, int *y, int *comp)
{
   context s;
   start_callbacks(&s, (stbi_io_callbacks *) c, user);
   return info_main(&s,x,y,comp);
}

STBIDEF int stbi_is_16_bit_from_memory(stbi_uc const *buffer, int len)
{
   context s;
   start_mem(&s,buffer,len);
   return png_is16(&s);
}

STBIDEF int stbi_is_16_bit_from_callbacks(stbi_io_callbacks const *c, void *user)
{
   context s;
   start_callbacks(&s, (stbi_io_callbacks *) c, user);
   return png_is16(&s);
}













### QOI



# Copyright (c) 2021, Dominic Szablewski - https://phoboslab.org
# SPDX-License-Identifier: MIT
# 
# 
# QOI - The "Quite OK Image" format for fast, lossless image compression
# 
# -- About
# 
# QOI encodes and decodes images in a lossless format. Compared to stb_image and
# stb_image_write QOI offers 20x-50x faster encoding, 3x-4x faster decoding and
# 20% better compression.
# 
# 
# -- Synopsis

# Define `QOI_IMPLEMENTATION` in *one* C/C++ file before including this
# library to create the implementation.

#define QOI_IMPLEMENTATION
#include "qoi.h"

# Encode and store an RGBA buffer to the file system. The qoi_desc describes
# the input pixel data.
#qoi_write("image_new.qoi", rgba_pixels, &(qoi_desc){
#	.width = 1920,
#	.height = 1080,
#	.channels = 4,
#	.colorspace = QOI_SRGB
#});

# -- Documentation
# 
# This library provides the following functions;
# - qoi_decode  -- decode the raw bytes of a QOI image from memory
# - qoi_write   -- encode and write a QOI file
# - qoi_encode  -- encode an rgba buffer into a QOI image in memory
# 
# See the function declaration below for the signature and more information.
# 
# If you don't want/need the qoi_write functions, you can define
# QOI_NO_STDIO before including this library.
# 
# 
# -- Data Format
# 
# A QOI file has a 14 byte header, followed by any number of data "chunks" and an
# 8-byte end marker.

struct qoi_header_t {
	char     magic[4];   # magic bytes "qoif"
	uint32_t width;      # image width in pixels (BE)
	uint32_t height;     # image height in pixels (BE)
	uint8_t  channels;   # 3 = RGB, 4 = RGBA
	uint8_t  colorspace; # 0 = sRGB with linear alpha, 1 = all channels linear
};

# Images are encoded row by row, left to right, top to bottom. The decoder and
# encoder start with {r: 0, g: 0, b: 0, a: 255} as the previous pixel value. An
# image is complete when all pixels specified by width * height have been covered.

# Pixels are encoded as
#  - a run of the previous pixel
#  - an index into an array of previously seen pixels
#  - a difference to the previous pixel value in r,g,b
#  - full r,g,b or r,g,b,a values

# The color channels are assumed to not be premultiplied with the alpha channel
# ("un-premultiplied alpha").

#A running array[64] (zero-initialized) of previously seen pixel values is
#maintained by the encoder and decoder. Each pixel that is seen by the encoder
#and decoder is put into this array at the position formed by a hash function of
#the color value. In the encoder, if the pixel value at the index matches the
#current pixel, this index position is written to the stream as QOI_OP_INDEX.
#The hash function for the index is:
#
#	index_position = (r * 3 + g * 5 + b * 7 + a * 11) % 64
#
#Each chunk starts with a 2- or 8-bit tag, followed by a number of data bits. The
#bit length of chunks is divisible by 8 - i.e. all chunks are byte aligned. All
#values encoded in these data bits have the most significant bit on the left.
#
#The 8-bit tags have precedence over the 2-bit tags. A decoder must check for the
#presence of an 8-bit tag first.
#
#The byte stream's end is marked with 7 0x00 bytes followed a single 0x01 byte.
#
#
#The possible chunks are:
#
#
#.- QOI_OP_INDEX ----------.
#|         Byte[0]         |
#|  7  6  5  4  3  2  1  0 |
#|-------+-----------------|
#|  0  0 |     index       |
#`-------------------------`
#2-bit tag b00
#6-bit index into the color index array: 0..63
#
#A valid encoder must not issue 2 or more consecutive QOI_OP_INDEX chunks to the
#same index. QOI_OP_RUN should be used instead.
#
#
#.- QOI_OP_DIFF -----------.
#|         Byte[0]         |
#|  7  6  5  4  3  2  1  0 |
#|-------+-----+-----+-----|
#|  0  1 |  dr |  dg |  db |
#`-------------------------`
#2-bit tag b01
#2-bit   red channel difference from the previous pixel between -2..1
#2-bit green channel difference from the previous pixel between -2..1
#2-bit  blue channel difference from the previous pixel between -2..1
#
#The difference to the current channel values are using a wraparound operation,
#so "1 - 2" will result in 255, while "255 + 1" will result in 0.
#
#Values are stored as unsigned integers with a bias of 2. E.g. -2 is stored as
#0 (b00). 1 is stored as 3 (b11).
#
#The alpha value remains unchanged from the previous pixel.
#
#
#.- QOI_OP_LUMA -------------------------------------.
#|         Byte[0]         |         Byte[1]         |
#|  7  6  5  4  3  2  1  0 |  7  6  5  4  3  2  1  0 |
#|-------+-----------------+-------------+-----------|
#|  1  0 |  green diff     |   dr - dg   |  db - dg  |
#`---------------------------------------------------`
#2-bit tag b10
#6-bit green channel difference from the previous pixel -32..31
#4-bit   red channel difference minus green channel difference -8..7
#4-bit  blue channel difference minus green channel difference -8..7
#
#The green channel is used to indicate the general direction of change and is
#encoded in 6 bits. The red and blue channels (dr and db) base their diffs off
#of the green channel difference and are encoded in 4 bits. I.e.:
#	dr_dg = (cur_px.r - prev_px.r) - (cur_px.g - prev_px.g)
#	db_dg = (cur_px.b - prev_px.b) - (cur_px.g - prev_px.g)
#
#The difference to the current channel values are using a wraparound operation,
#so "10 - 13" will result in 253, while "250 + 7" will result in 1.
#
#Values are stored as unsigned integers with a bias of 32 for the green channel
#and a bias of 8 for the red and blue channel.
#
#The alpha value remains unchanged from the previous pixel.
#
#
#.- QOI_OP_RUN ------------.
#|         Byte[0]         |
#|  7  6  5  4  3  2  1  0 |
#|-------+-----------------|
#|  1  1 |       run       |
#`-------------------------`
#2-bit tag b11
#6-bit run-length repeating the previous pixel: 1..62
#
#The run-length is stored with a bias of -1. Note that the run-lengths 63 and 64
#(b111110 and b111111) are illegal as they are occupied by the QOI_OP_RGB and
#QOI_OP_RGBA tags.
#
#
#.- QOI_OP_RGB ------------------------------------------.
#|         Byte[0]         | Byte[1] | Byte[2] | Byte[3] |
#|  7  6  5  4  3  2  1  0 | 7 .. 0  | 7 .. 0  | 7 .. 0  |
#|-------------------------+---------+---------+---------|
#|  1  1  1  1  1  1  1  0 |   red   |  green  |  blue   |
#`-------------------------------------------------------`
#8-bit tag b11111110
#8-bit   red channel value
#8-bit green channel value
#8-bit  blue channel value
#
#The alpha value remains unchanged from the previous pixel.
#
#
#.- QOI_OP_RGBA ---------------------------------------------------.
#|         Byte[0]         | Byte[1] | Byte[2] | Byte[3] | Byte[4] |
#|  7  6  5  4  3  2  1  0 | 7 .. 0  | 7 .. 0  | 7 .. 0  | 7 .. 0  |
#|-------------------------+---------+---------+---------+---------|
#|  1  1  1  1  1  1  1  1 |   red   |  green  |  blue   |  alpha  |
#`-----------------------------------------------------------------`
#8-bit tag b11111111
#8-bit   red channel value
#8-bit green channel value
#8-bit  blue channel value
#8-bit alpha channel value


# -----------------------------------------------------------------------------
#Header - Public functions

#ifndef QOI_H
#define QOI_H

# A pointer to a qoi_desc struct has to be supplied to all of qoi's functions.
# It describes either the input format (for qoi_write and qoi_encode), or is
# filled with the description read from the file header (for qoi_read and
# qoi_decode).
# 
# The colorspace in this qoi_desc is an enum where
# 	0 = sRGB, i.e. gamma scaled RGB channels and a linear alpha channel
# 	1 = all channels are linear
# You may use the constants QOI_SRGB or QOI_LINEAR. The colorspace is purely
# informative. It will be saved to the file header, but does not affect
# how chunks are en-/decoded.

qoi_srgb   ← 0
qoi_linear ← 1

typedef struct {
	unsigned int width;
	unsigned int height;
	unsigned char channels;
	unsigned char colorspace;
} qoi_desc;

#ifndef QOI_NO_STDIO

# Encode raw RGB or RGBA pixels into a QOI image and write it to the file
# system. The qoi_desc struct must be filled with the image width, height,
# number of channels (3 = RGB, 4 = RGBA) and the colorspace.
# 
# The function returns 0 on failure (invalid parameters, or fopen or malloc
# failed) or the number of bytes written on success.

int qoi_write(const char *filename, const void *data, const qoi_desc *desc);

#endif /* QOI_NO_STDIO */


# Encode raw RGB or RGBA pixels into a QOI image in memory.
# 
# The function either returns NULL on failure (invalid parameters or malloc
# failed) or a pointer to the encoded data on success. On success the out_len
# is set to the size in bytes of the encoded data.
# 
# The returned qoi data should be free()d after use.

# Decode a QOI image from memory.
# 
# The function either returns NULL on failure (invalid parameters or malloc
# failed) or a pointer to the decoded pixels. On success, the qoi_desc struct
# is filled with the description from the file header.
# 
# The returned pixel data should be free()d after use.

void *qoi_decode(const void *data, int size, qoi_desc *desc, int channels);



# -----------------------------------------------------------------------------
# Implementation

qoi_op_index ← 0    # 00xxxxxx
qoi_op_diff  ← 64   # 01xxxxxx
qoi_op_luma  ← 128  # 10xxxxxx
qoi_op_run   ← 192  # 11xxxxxx
qoi_op_rgb   ← 254  # 11111110
qoi_op_rgba  ← 255  # 11111111

qoi_mask_2 ← 192 # 11000000

qoi_color_hash ← {+´𝕩.rgba×3‿5‿7‿11}
qoi_magic←+´(2⋆8×↕4)×"fioq"-@

qoi_header_size ← 14

# 2GB is the max file size that this implementation can safely handle. We guard
# against anything larger than that, assuming the worst case with 5 bytes per
# pixel, rounded down to a nice clean value. 400 million pixels ought to be
# enough for anybody.

qoi_pixels_max ← 400000000

typedef union {
	struct { unsigned char r, g, b, a; } rgba;
	unsigned int v;
} qoi_rgba_t;

static const unsigned char qoi_padding[8] = {0,0,0,0,0,0,0,1};

static unsigned int qoi_read_32(const unsigned char *bytes, int *p) {
	unsigned int a = bytes[(*p)++];
	unsigned int b = bytes[(*p)++];
	unsigned int c = bytes[(*p)++];
	unsigned int d = bytes[(*p)++];
	return a << 24 | b << 16 | c << 8 | d;
}

Qoi_encode {𝕊data‿desc:
  hight ← desc->height
	channels ← desc->channels
	!¬∨´⟨
		desc->width == 0 ⋄ hight == 0
		∧´channels≠3‿4
		desc->colorspace > 1
		hight ≥ qoi_pixels_max ÷ desc->width
  ⟩

	max_size ← +´⟨
		desc->width × hight × (channels + 1)
		qoi_header_size + ≠qoi_padding
  ⟩
  
  a‿b‿c‿d ← ¯1+2⋆8×1+↕4


  bytes ← ⟨32‿'u'⋄8‿'u'⟩•bit._cast qoi_magic‿desc->width‿hight
  bytes ∾↩ channels‿desc->colorspace

	pixels ← data

	index ← 64⥊0

	run ← 0

	px_len ← desc->width × hight × channels
	px_end ← px_len - channels

	bytes ∾↩ 0‿0‿0‿255{px_prev𝕊px_pos:
		px ← channels↑px_pos↓pixels

		{px.v = px_prev.v?
			run+↩1
			{𝕤
				bytes[p++] = qoi_op_run | (run - 1);
				run = 0;
			}⍟⊢(run = 62) ∨ px_pos = px_end
		;
			{𝕤
				bytes[p++] ← qoi_op_run | (run - 1)
				run = 0
			}⍟⊢run>0

			index_pos ← 64|QOI_COLOR_HASH px

			{index[index_pos].v = px.v?
				bytes[p++] ← qoi_op_index | index_pos
			;
				index[index_pos] ← px

				if (px.rgba.a == px_prev.rgba.a) {
					vr ← px.rgba.r - px_prev.rgba.r
					vg ← px.rgba.g - px_prev.rgba.g
					vb ← px.rgba.b - px_prev.rgba.b

					vg_r ← vr - vg
					vg_b ← vb - vg

					{
            ∧´⟨
              vr > ¯3 ⋄ vr < 2
              vg > ¯3 ⋄ vg < 2
              vb > ¯3 ⋄ vb < 2
            ⟩?
						  bytes[p++] = qoi_op_diff | (vr + 2) << 4 | (vg + 2) << 2 | (vb + 2)
					;
            ∧´⟨
              vg_r >  ¯9 ⋄ vg_r <  8
              vg   > ¯33 ⋄ vg   < 32
              vg_b >  ¯9 ⋄ vg_b <  8
            ⟩?
              bytes[p++] = QOI_OP_LUMA     | (vg   + 32);
              bytes[p++] = (vg_r + 8) << 4 | (vg_b +  8);
					;
						bytes[p++] = QOI_OP_RGB;
						bytes[p++] = px.rgba.r;
						bytes[p++] = px.rgba.g;
						bytes[p++] = px.rgba.b;
					}
				}
				else {
					bytes[p++] = QOI_OP_RGBA;
					bytes[p++] = px.rgba.r;
					bytes[p++] = px.rgba.g;
					bytes[p++] = px.rgba.b;
					bytes[p++] = px.rgba.a;
				}
			}
		}
    px
	}`channels×↕px_len

	for (i = 0; i < (int)sizeof(qoi_padding); i++) {
		bytes[p++] = qoi_padding[i];
	}
	max_size↑bytes
}

void *qoi_decode(const void *data, int size, qoi_desc *desc, int channels) {
	const unsigned char *bytes;
	unsigned int header_magic;
	unsigned char *pixels;
	qoi_rgba_t index[64];
	qoi_rgba_t px;
	int px_len, chunks_len, px_pos;
	int p = 0, run = 0;

	if (
		data == NULL || desc == NULL ||
		(channels != 0 && channels != 3 && channels != 4) ||
		size < QOI_HEADER_SIZE + (int)sizeof(qoi_padding)
	) {
		return NULL;
	}

	bytes = (const unsigned char *)data;

	header_magic = qoi_read_32(bytes, &p);
	desc->width = qoi_read_32(bytes, &p);
	desc->height = qoi_read_32(bytes, &p);
	desc->channels = bytes[p++];
	desc->colorspace = bytes[p++];

	if (
		desc->width == 0 || desc->height == 0 ||
		desc->channels < 3 || desc->channels > 4 ||
		desc->colorspace > 1 ||
		header_magic != QOI_MAGIC ||
		desc->height >= QOI_PIXELS_MAX / desc->width
	) {
		return NULL;
	}

	if (channels == 0) {
		channels = desc->channels;
	}

	px_len = desc->width * desc->height * channels;
	pixels = (unsigned char *) QOI_MALLOC(px_len);
	if (!pixels) {
		return NULL;
	}

	index 0¨↩
	px.rgba.r = 0;
	px.rgba.g = 0;
	px.rgba.b = 0;
	px.rgba.a = 255;

	chunks_len = size - (int)sizeof(qoi_padding);
	for (px_pos = 0; px_pos < px_len; px_pos += channels) {
		if (run > 0) {
			run--;
		}
		else if (p < chunks_len) {
			int b1 = bytes[p++];

			if (b1 == QOI_OP_RGB) {
				px.rgba.r = bytes[p++];
				px.rgba.g = bytes[p++];
				px.rgba.b = bytes[p++];
			}
			else if (b1 == QOI_OP_RGBA) {
				px.rgba.r = bytes[p++];
				px.rgba.g = bytes[p++];
				px.rgba.b = bytes[p++];
				px.rgba.a = bytes[p++];
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_INDEX) {
				px = index[b1];
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_DIFF) {
				px.rgba.r += ((b1 >> 4) & 0x03) - 2;
				px.rgba.g += ((b1 >> 2) & 0x03) - 2;
				px.rgba.b += ( b1       & 0x03) - 2;
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_LUMA) {
				int b2 = bytes[p++];
				int vg = (b1 & 0x3f) - 32;
				px.rgba.r += vg - 8 + ((b2 >> 4) & 0x0f);
				px.rgba.g += vg;
				px.rgba.b += vg - 8 +  (b2       & 0x0f);
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_RUN) {
				run = (b1 & 0x3f);
			}

			index[QOI_COLOR_HASH(px) % 64] = px;
		}

		pixels[px_pos + 0] = px.rgba.r;
		pixels[px_pos + 1] = px.rgba.g;
		pixels[px_pos + 2] = px.rgba.b;
		
		if (channels == 4) {
			pixels[px_pos + 3] = px.rgba.a;
		}
	}

	return pixels;
}

#ifndef QOI_NO_STDIO
#include <stdio.h>

Qoi_write ← {𝕊path‿data‿desc:
	path •FChars Qoi_encode data‿desc
}












# Load image from memory buffer, fileType refers to extension: i.e. ".png"
# WARNING: File extension must be provided in lower-case
Image LoadImageFromMemory(const char *fileType, const unsigned char *fileData, int dataSize)
{
  {∨´fileType⊸≢¨".png"‿".PNG"‿".gif"‿".GIF"?
    # NOTE: Using stb_image to load images (Supports multiple image formats)

    comp = 0
    image.data = stbi_load_from_memory(fileData, dataSize, &image.width, &image.height, &comp, 0)

    image.mipmaps = 1;

    image.format ← {
      comp = 1? pixelformat.uncompressed_grayscale
      comp = 2? pixelformat.uncompressed_gray_alpha
      comp = 3? pixelformat.uncompressed_r8g8b8
      comp = 4? pixelformat.uncompressed_r8g8b8a8
      image.format
    }
  ;∨´fileType⊸≢¨".qoi"‿".QOI"?
    qoi_desc desc = { 0 }
    image.data = qoi_decode(fileData, dataSize, &desc, 4)
    image.width = desc.width
    image.height = desc.height
    image.format = pixelformat.uncompressed_r8g8b8a8
    image.mipmaps = 1
  
  ;∨´fileType⊸≢¨".dds"‿".DDS"?
      image.data = rl_load_dds_from_memory(fileData, dataSize, &image.width, &image.height, &image.format, &image.mipmaps);
  ;
    !"IMAGE: Data format not supported"
  }
  image
}






# Loading DDS from memory image data (compressed or uncompressed)
void *rl_load_dds_from_memory(const unsigned char *file_data, unsigned int file_size, int *width, int *height, int *format, int *mips)
{
    image_data ← ⟨⟩ # Image data pointer
    int image_pixel_size ← 0 # Image pixel size

    unsigned char *file_data_ptr = (unsigned char *)file_data;

    # Required extension:
    # GL_EXT_texture_compression_s3tc

    # Supported tokens (defined by extensions)
    # GL_COMPRESSED_RGB_S3TC_DXT1_EXT      0x83F0
    # GL_COMPRESSED_RGBA_S3TC_DXT1_EXT     0x83F1
    # GL_COMPRESSED_RGBA_S3TC_DXT3_EXT     0x83F2
    # GL_COMPRESSED_RGBA_S3TC_DXT5_EXT     0x83F3

    fourcc_dxt1 ← "DXT1"
    fourcc_dxt3 ← "DXT3"
    fourcc_dxt5 ← "DXT5"
    
    
    
    # DDS Pixel Format
    typedef struct {
        unsigned int size;
        unsigned int flags;
        unsigned int fourcc;
        unsigned int rgb_bit_count;
        unsigned int r_bit_mask;
        unsigned int g_bit_mask;
        unsigned int b_bit_mask;
        unsigned int a_bit_mask;
    } dds_pixel_format;

    # DDS Header (124 bytes)
    typedef struct {
        unsigned int size;
        unsigned int flags;
        unsigned int height;
        unsigned int width;
        unsigned int pitch_or_linear_size;
        unsigned int depth;
        unsigned int mipmap_count;
        unsigned int reserved1[11];
        dds_pixel_format ddspf;
        unsigned int caps;
        unsigned int caps2;
        unsigned int caps3;
        unsigned int caps4;
        unsigned int reserved2;
    } dds_header;

    if (file_data_ptr != NULL)
    {
        # Verify the type of file
        unsigned char *dds_header_id = file_data_ptr;
        file_data_ptr += 4;

        if ((dds_header_id[0] != 'D') || (dds_header_id[1] != 'D') || (dds_header_id[2] != 'S') || (dds_header_id[3] != ' '))
        {
            LOG("WARNING: IMAGE: DDS file data not valid");
        }
        else
        {
            dds_header *header = (dds_header *)file_data_ptr;

            file_data_ptr += sizeof(dds_header);        # Skip header

            *width = header->width;
            *height = header->height;
            image_pixel_size = header->width*header->height;

            if (header->mipmap_count == 0) *mips = 1;   # Parameter not used
            else *mips = header->mipmap_count;

            if (header->ddspf.rgb_bit_count == 16)      # 16bit mode, no compressed
            {
                if (header->ddspf.flags == 0x40)        # No alpha channel
                {
                    int data_size = image_pixel_size*sizeof(unsigned short);
                    image_data = RL_MALLOC(data_size);

                    memcpy(image_data, file_data_ptr, data_size);

                    *format = PIXELFORMAT_UNCOMPRESSED_R5G6B5;
                }
                else if (header->ddspf.flags == 0x41)           # With alpha channel
                {
                    if (header->ddspf.a_bit_mask == 0x8000)     # 1bit alpha
                    {
                        int data_size = image_pixel_size*sizeof(unsigned short);
                        image_data = RL_MALLOC(data_size);

                        memcpy(image_data, file_data_ptr, data_size);

                        unsigned char alpha = 0;

                        # NOTE: Data comes as A1R5G5B5, it must be reordered to R5G5B5A1
                        for (int i = 0; i < image_pixel_size; i++)
                        {
                            alpha = ((unsigned short *)image_data)[i] >> 15;
                            ((unsigned short *)image_data)[i] = ((unsigned short *)image_data)[i] << 1;
                            ((unsigned short *)image_data)[i] += alpha;
                        }

                        *format = PIXELFORMAT_UNCOMPRESSED_R5G5B5A1;
                    }
                    else if (header->ddspf.a_bit_mask == 0xf000)   # 4bit alpha
                    {
                        int data_size = image_pixel_size*sizeof(unsigned short);
                        image_data = RL_MALLOC(data_size);

                        memcpy(image_data, file_data_ptr, data_size);

                        unsigned char alpha = 0;

                        # NOTE: Data comes as A4R4G4B4, it must be reordered R4G4B4A4
                        for (int i = 0; i < image_pixel_size; i++)
                        {
                            alpha = ((unsigned short *)image_data)[i] >> 12;
                            ((unsigned short *)image_data)[i] = ((unsigned short *)image_data)[i] << 4;
                            ((unsigned short *)image_data)[i] += alpha;
                        }

                        *format = PIXELFORMAT_UNCOMPRESSED_R4G4B4A4;
                    }
                }
            }
            else if (header->ddspf.flags == 0x40 && header->ddspf.rgb_bit_count == 24)   # DDS_RGB, no compressed
            {
                int data_size = image_pixel_size*3*sizeof(unsigned char);
                image_data = RL_MALLOC(data_size);

                memcpy(image_data, file_data_ptr, data_size);

                *format = PIXELFORMAT_UNCOMPRESSED_R8G8B8;
            }
            else if (header->ddspf.flags == 0x41 && header->ddspf.rgb_bit_count == 32) # DDS_RGBA, no compressed
            {
                int data_size = image_pixel_size*4*sizeof(unsigned char);
                image_data = RL_MALLOC(data_size);

                memcpy(image_data, file_data_ptr, data_size);

                unsigned char blue = 0;

                # NOTE: Data comes as A8R8G8B8, it must be reordered R8G8B8A8 (view next comment)
                # DirecX understand ARGB as a 32bit DWORD but the actual memory byte alignment is BGRA
                # So, we must realign B8G8R8A8 to R8G8B8A8
                for (int i = 0; i < image_pixel_size*4; i += 4)
                {
                    blue = ((unsigned char *)image_data)[i];
                    ((unsigned char *)image_data)[i] = ((unsigned char *)image_data)[i + 2];
                    ((unsigned char *)image_data)[i + 2] = blue;
                }

                *format = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
            }
            else if (((header->ddspf.flags == 0x04) || (header->ddspf.flags == 0x05)) && (header->ddspf.fourcc > 0)) # Compressed
            {
                # NOTE: This forces only 1 mipmap to be loaded which is not really correct but it works
                int data_size = (header->pitch_or_linear_size < file_size - 0x80) ? header->pitch_or_linear_size : file_size - 0x80;
                *mips = 1;

                image_data = RL_MALLOC(data_size*sizeof(unsigned char));

                memcpy(image_data, file_data_ptr, data_size);

                switch (header->ddspf.fourcc)
                {
                    case FOURCC_DXT1:
                    {
                        if (header->ddspf.flags == 0x04) *format = PIXELFORMAT_COMPRESSED_DXT1_RGB;
                        else *format = PIXELFORMAT_COMPRESSED_DXT1_RGBA;
                    } break;
                    case FOURCC_DXT3: *format = PIXELFORMAT_COMPRESSED_DXT3_RGBA; break;
                    case FOURCC_DXT5: *format = PIXELFORMAT_COMPRESSED_DXT5_RGBA; break;
                    default: break;
                }
            }
        }
    }

    return image_data;
}