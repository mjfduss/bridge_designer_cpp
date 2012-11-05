#ifndef _SKETCH_H
#define _SKETCH_H

/* sketch.h -- Header for sketches that end up as compressed bitmaps. */

#define SET_MULTIPLE_PTR(Ptr,Val,N)	memset(Ptr, Val, N * sizeof *Ptr)
#define SET_PTR(Ptr,Val)			SET_MULTIPLE_PTR(Ptr, Val, 1)
#define SET(X, Val)					SET_PTR(&(X), Val)
#define ZERO_PTR(Ptr)				SET_PTR(Ptr, 0)
#define ZERO(X)						SET(X, 0)
#define N_BITS(X)					(8 * sizeof X)

typedef unsigned char BYTE;
typedef unsigned long UNSIGNED;
typedef float FLOAT;

#ifndef INLINE
#define INLINE __inline
#endif

typedef struct rgb_triple_t {
	BYTE r, g, b;
} RGB_TRIPLE;

typedef struct image_t {
	UNSIGNED width, height;
	UNSIGNED x_left, x_right, y_bottom, y_top;
	RGB_TRIPLE *data;
} IMAGE;

#define INIT_COMPRESSED_IMAGE_SIZE	1024
typedef struct compressed_image_t {
	UNSIGNED size;
	UNSIGNED filled;
	BYTE *data;
} COMPRESSED_IMAGE;

/* sketch.c */
void init_image(IMAGE *image);
void clear_image(IMAGE *image);
void setup_image(IMAGE *image, UNSIGNED width, UNSIGNED height, RGB_TRIPLE *color);
void set_viewport(IMAGE *image, UNSIGNED x_left, UNSIGNED x_right, UNSIGNED y_bottom, UNSIGNED y_top);
void draw_line_raw(IMAGE *image, UNSIGNED x1, UNSIGNED y1, UNSIGNED x2, UNSIGNED y2, RGB_TRIPLE *color);
void draw_rect_raw(IMAGE *image, UNSIGNED x1, UNSIGNED y1, UNSIGNED x2, UNSIGNED y2, RGB_TRIPLE *color);
void clip_segment(FLOAT *x1p, FLOAT *y1p, FLOAT *x2p, FLOAT *y2p, FLOAT x_left, FLOAT x_right, FLOAT y_bottom, FLOAT y_top, int *segment_survives_p);
void draw_line(IMAGE *image, FLOAT x1, FLOAT y1, FLOAT x2, FLOAT y2, RGB_TRIPLE *color);
void init_compressed_image(COMPRESSED_IMAGE *compressed_image);
void clear_compressed_image(COMPRESSED_IMAGE *compressed_image);
int compress_image(IMAGE *image, COMPRESSED_IMAGE *compressed_image);

#endif