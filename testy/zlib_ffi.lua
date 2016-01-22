--zlib_ffi.lua
local ffi = require("ffi")

--#include "zconf.h"
ffi.cdef[[
// Platform specifics
typedef long off_t;
]]

ffi.cdef[[
typedef void * voidpf;

typedef unsigned char  Byte;  /* 8 bits */
typedef Byte Bytef;

typedef unsigned int   uInt;  /* 16 bits or more */

typedef unsigned long  uLong; /* 32 bits or more */
typedef uLong uLongf;

typedef off_t z_off_t;
]]

--[[
-- This binding was originally derived from the
-- 1.2.8 version of the zlib library
static const int ZLIB_VERSION "1.2.8"
static const int ZLIB_VERNUM 0x1280
static const int ZLIB_VER_MAJOR 1
static const int ZLIB_VER_MINOR 2
static const int ZLIB_VER_REVISION 8
static const int ZLIB_VER_SUBREVISION 0
--]]


ffi.cdef[[
typedef voidpf (*alloc_func) (voidpf opaque, uInt items, uInt size);
typedef void   (*free_func)  (voidpf opaque, voidpf address);
]]

ffi.cdef[[
struct internal_state;

typedef struct z_stream_s {
    const Bytef *next_in;     /* next input byte */
    uInt     avail_in;  /* number of bytes available at next_in */
    uLong    total_in;  /* total number of input bytes read so far */

    Bytef    *next_out; /* next output byte should be put there */
    uInt     avail_out; /* remaining free space at next_out */
    uLong    total_out; /* total number of bytes output so far */

    const char *msg;  /* last error message, NULL if no error */
    struct internal_state *state; /* not visible by applications */

    alloc_func zalloc;  /* used to allocate the internal state */
    free_func  zfree;   /* used to free the internal state */
    voidpf     opaque;  /* private data object passed to zalloc and zfree */

    int     data_type;  /* best guess about the data type: binary or text */
    uLong   adler;      /* adler32 value of the uncompressed data */
    uLong   reserved;   /* reserved for future use */
} z_stream;

typedef z_stream *z_streamp;
]]

ffi.cdef[[
typedef struct gz_header_s {
    int     text;       /* true if compressed data believed to be text */
    uLong   time;       /* modification time */
    int     xflags;     /* extra flags (not used when writing a gzip file) */
    int     os;         /* operating system */
    Bytef   *extra;     /* pointer to extra field or Z_NULL if none */
    uInt    extra_len;  /* extra field length (valid if extra != Z_NULL) */
    uInt    extra_max;  /* space at extra (only when reading header) */
    Bytef   *name;      /* pointer to zero-terminated file name or Z_NULL */
    uInt    name_max;   /* space at name (only when reading header) */
    Bytef   *comment;   /* pointer to zero-terminated comment or Z_NULL */
    uInt    comm_max;   /* space at comment (only when reading header) */
    int     hcrc;       /* true if there was or will be a header crc */
    int     done;       /* true when done reading gzip header (not used
                           when writing a gzip file) */
} gz_header;

typedef gz_header *gz_headerp;
]]


ffi.cdef[[
/* constants */

static const int Z_NO_FLUSH      =0;
static const int Z_PARTIAL_FLUSH =1;
static const int Z_SYNC_FLUSH    =2;
static const int Z_FULL_FLUSH    =3;
static const int Z_FINISH        =4;
static const int Z_BLOCK         =5;
static const int Z_TREES         =6;
/* Allowed flush values; see deflate() and inflate() below for details */

static const int Z_OK           = 0;
static const int Z_STREAM_END   = 1;
static const int Z_NEED_DICT    = 2;
static const int Z_ERRNO        =(-1);
static const int Z_STREAM_ERROR =(-2);
static const int Z_DATA_ERROR   =(-3);
static const int Z_MEM_ERROR    =(-4);
static const int Z_BUF_ERROR    =(-5);
static const int Z_VERSION_ERROR =(-6);
]]

ffi.cdef[[
/* Return codes for the compression/decompression functions. Negative values
 * are errors, positive values are used for special but normal events.
 */

static const int Z_NO_COMPRESSION        = 0;
static const int Z_BEST_SPEED            = 1;
static const int Z_BEST_COMPRESSION      = 9;
static const int Z_DEFAULT_COMPRESSION  =(-1);
/* compression levels */

static const int Z_FILTERED            =1;
static const int Z_HUFFMAN_ONLY        =2;
static const int Z_RLE                 =3;
static const int Z_FIXED               =4;
static const int Z_DEFAULT_STRATEGY    =0;
/* compression strategy; see deflateInit2() below for details */

static const int Z_BINARY   =0;
static const int Z_TEXT     =1;
static const int Z_ASCII    =Z_TEXT;   /* for compatibility with 1.2.2 and earlier */
static const int Z_UNKNOWN  =2;
/* Possible values of the data_type field (though see inflate()) */

static const int Z_DEFLATED   =8;
/* The deflate compression method (the only one supported in this version) */

static const int Z_NULL  =0;  /* for initializing zalloc, zfree, opaque */
]]


ffi.cdef[[
/* basic functions */
const char * zlibVersion (void);
int deflate (z_streamp strm, int flush);
int deflateEnd (z_streamp strm);
int inflate (z_streamp strm, int flush);
int inflateEnd (z_streamp strm);
]]

ffi.cdef[[
/* Advanced functions */
int deflateSetDictionary (z_streamp strm,
                                             const Bytef *dictionary,
                                             uInt  dictLength);

int deflateCopy (z_streamp dest,
                                    z_streamp source);

int deflateReset (z_streamp strm);

int deflateParams (z_streamp strm,
                                      int level,
                                      int strategy);

int deflateTune (z_streamp strm,
                                    int good_length,
                                    int max_lazy,
                                    int nice_length,
                                    int max_chain);

uLong deflateBound (z_streamp strm,
                                       uLong sourceLen);

int deflatePending (z_streamp strm,
                                       unsigned *pending,
                                       int *bits);

int deflatePrime (z_streamp strm,
                                     int bits,
                                     int value);

int deflateSetHeader (z_streamp strm,
                                         gz_headerp head);


int inflateSetDictionary (z_streamp strm,
                                             const Bytef *dictionary,
                                             uInt  dictLength);

int inflateGetDictionary (z_streamp strm,
                                             Bytef *dictionary,
                                             uInt  *dictLength);

int inflateSync (z_streamp strm);

int inflateCopy (z_streamp dest,
                                    z_streamp source);

int inflateReset (z_streamp strm);

int inflateReset2 (z_streamp strm,
                                      int windowBits);

int inflatePrime (z_streamp strm,
                                     int bits,
                                     int value);

long inflateMark (z_streamp strm);

int inflateGetHeader (z_streamp strm,
                                         gz_headerp head);


typedef unsigned (*in_func) (void *,
                                const unsigned char * *);
typedef int (*out_func) (void *, unsigned char *, unsigned);

int inflateBack (z_streamp strm,
                                    in_func in, void *in_desc,
                                    out_func out, void *out_desc);

int inflateBackEnd (z_streamp strm);

uLong zlibCompileFlags (void);
]]

--[[
#ifndef Z_SOLO

/* utility functions */
int compress (Bytef *dest,   uLongf *destLen, const Bytef *source, uLong sourceLen);

int compress2 (Bytef *dest,   uLongf *destLen,
                                  const Bytef *source, uLong sourceLen,
                                  int level);

uLong compressBound (uLong sourceLen);

int uncompress (Bytef *dest,   uLongf *destLen,
                                   const Bytef *source, uLong sourceLen);

/* gzip file access functions */
typedef struct gzFile_s *gzFile;    /* semi-opaque gzip file descriptor */


gzFile gzdopen (int fd, const char *mode);

int gzbuffer (gzFile file, unsigned size);

int gzsetparams (gzFile file, int level, int strategy);

int gzread (gzFile file, voidp buf, unsigned len);

int gzwrite (gzFile file,
                                voidpc buf, unsigned len);

int ZEXPORTVA gzprintf Z_ARG((gzFile file, const char *format, ...);

int gzputs (gzFile file, const char *s);

char * gzgets (gzFile file, char *buf, int len);

int gzputc (gzFile file, int c);

int gzgetc (gzFile file);

int gzungetc (int c, gzFile file);

int gzflush (gzFile file, int flush);


int    gzrewind (gzFile file);



int gzeof (gzFile file);

int gzdirect (gzFile file);

int    gzclose (gzFile file);

int gzclose_r (gzFile file);
int gzclose_w (gzFile file);

const char * gzerror (gzFile file, int *errnum);

void gzclearerr (gzFile file);

#endif /* !Z_SOLO */
--]]

ffi.cdef[[
/* checksum functions */
uLong adler32 (uLong adler, const Bytef *buf, uInt len);
uLong crc32   (uLong crc, const Bytef *buf, uInt len);
]]


--[[
                        /* various hacks, don't look :) */

/* deflateInit and inflateInit are macros to allow checking the zlib version
 * and the compiler's view of z_stream:
 */
int deflateInit_ (z_streamp strm, int level,
                                     const char *version, int stream_size);
int inflateInit_ (z_streamp strm,
                                     const char *version, int stream_size);
int deflateInit2_ (z_streamp strm, int  level, int  method,
                                      int windowBits, int memLevel,
                                      int strategy, const char *version,
                                      int stream_size);
int inflateInit2_ (z_streamp strm, int  windowBits,
                                      const char *version, int stream_size);
int inflateBackInit_ (z_streamp strm, int windowBits,
                                         unsigned char *window,
                                         const char *version,
                                         int stream_size);
--]]

--[[
static const int deflateInit(strm, level) \
        deflateInit_((strm), (level), ZLIB_VERSION, (int)sizeof(z_stream))
static const int inflateInit(strm) \
        inflateInit_((strm), ZLIB_VERSION, (int)sizeof(z_stream))
static const int deflateInit2(strm, level, method, windowBits, memLevel, strategy) \
        deflateInit2_((strm),(level),(method),(windowBits),(memLevel),\
                      (strategy), ZLIB_VERSION, (int)sizeof(z_stream))
static const int inflateInit2(strm, windowBits) \
        inflateInit2_((strm), (windowBits), ZLIB_VERSION, \
                      (int)sizeof(z_stream))
static const int inflateBackInit(strm, windowBits, window) \
        inflateBackInit_((strm), (windowBits), (window), \
                      ZLIB_VERSION, (int)sizeof(z_stream))
--]]

--[[
#ifndef Z_SOLO

/* gzgetc() macro and its supporting function and exposed data structure.  Note
 * that the real internal state is much larger than the exposed structure.
 * This abbreviated structure exposes just enough for the gzgetc() macro.  The
 * user should not mess with these exposed elements, since their names or
 * behavior could change in the future, perhaps even capriciously.  They can
 * only be used by the gzgetc() macro.  You have been warned.
 */
struct gzFile_s {
    unsigned have;
    unsigned char *next;
    z_off64_t pos;
};
int gzgetc_ (gzFile file);  /* backward compatibility */
#ifdef Z_PREFIX_SET
#  undef z_gzgetc
#  define z_gzgetc(g) \
          ((g)->have ? ((g)->have--, (g)->pos++, *((g)->next)++) : gzgetc(g))
#else
#  define gzgetc(g) \
          ((g)->have ? ((g)->have--, (g)->pos++, *((g)->next)++) : gzgetc(g))
#endif

/* provide 64-bit offset functions if _LARGEFILE64_SOURCE defined, and/or
 * change the regular functions to 64 bits if _FILE_OFFSET_BITS is 64 (if
 * both are true, the application gets the *64 functions, and the regular
 * functions are changed to 64 bits) -- in case these are set on systems
 * without large file support, _LFS64_LARGEFILE must also be true
 */
#ifdef Z_LARGE64
   gzFile gzopen64 (const char *, const char *);
   z_off64_t gzseek64 (gzFile, z_off64_t, int);
   z_off64_t gztell64 (gzFile);
   z_off64_t gzoffset64 (gzFile);
   uLong adler32_combine64 (uLong, uLong, z_off64_t);
   uLong crc32_combine64 (uLong, uLong, z_off64_t);
#endif

#if !defined(ZLIB_INTERNAL) && defined(Z_WANT64)
#  ifdef Z_PREFIX_SET
#    define z_gzopen z_gzopen64
#    define z_gzseek z_gzseek64
#    define z_gztell z_gztell64
#    define z_gzoffset z_gzoffset64
#    define z_adler32_combine z_adler32_combine64
#    define z_crc32_combine z_crc32_combine64
#  else
#    define gzopen gzopen64
#    define gzseek gzseek64
#    define gztell gztell64
#    define gzoffset gzoffset64
#    define adler32_combine adler32_combine64
#    define crc32_combine crc32_combine64
#  endif
#  ifndef Z_LARGE64
     gzFile gzopen64 (const char *, const char *
     z_off_t gzseek64 (gzFile, z_off_t, int);
     z_off_t gztell64 (gzFile);
     z_off_t gzoffset64 (gzFile);
     uLong adler32_combine64 (uLong, uLong, z_off_t);
     uLong crc32_combine64 (uLong, uLong, z_off_t);
#  endif
#else
   gzFile gzopen (const char *, const char *);
   z_off_t gzseek (gzFile, z_off_t, int);
   z_off_t gztell (gzFile);
   z_off_t gzoffset (gzFile);
   uLong adler32_combine (uLong, uLong, z_off_t);
   uLong crc32_combine (uLong, uLong, z_off_t);
#endif

#else /* Z_SOLO */
--]]
ffi.cdef[[
   uLong adler32_combine (uLong, uLong, z_off_t);
   uLong crc32_combine (uLong, uLong, z_off_t);
]]
--#endif /* !Z_SOLO */

--[[
/* hack for buggy compilers */
#if !defined(ZUTIL_H) && !defined(NO_DUMMY_DECL)
    struct internal_state {int dummy;};
#endif
--]]

--[[
/* undocumented functions */
const char   * zError           (int);
int            inflateSyncPoint (z_streamp);
const z_crc_t * get_crc_table    (void);
int            inflateUndermine (z_streamp, int);
int            inflateResetKeep (z_streamp);
int            deflateResetKeep (z_streamp);
#if defined(_WIN32) && !defined(Z_SOLO)
gzFile         gzopen_w (const wchar_t *path,
                                            const char *mode);
#endif
#if defined(STDC) || defined(Z_HAVE_STDARG_H)
#  ifndef Z_SOLO
int            ZEXPORTVA gzvprintf Z_ARG((gzFile file,
                                                  const char *format,
                                                  va_list va);
#  endif
#endif
--]]



local zlib = ffi.load("z")

return zlib
