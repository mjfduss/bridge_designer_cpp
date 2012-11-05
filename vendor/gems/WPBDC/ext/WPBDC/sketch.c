/*
 *
 * sketch.c -- Routines to draw in a memory buffer and compress 
 *             the image in PNG format.
 */

#include "stdafx.h"
#include "internal.h"
#include "sketch.h"
#include "png.h"


/* ----- Drawing in bitmap ------------------------------------------ */

// initialize an image to null
void init_image(IMAGE *image)
{
	ZERO_PTR(image);
}

// free any storage allocated for image
void clear_image(IMAGE *image)
{
	Safefree(image->data);
	init_image(image);
}

// Allocate storage to give an image the given width and height.
// Initialize it with the given background color.
void setup_image(IMAGE *image, UNSIGNED width, UNSIGNED height, RGB_TRIPLE *color)
{
	UNSIGNED i;

	clear_image(image);
	New(2001, image->data, width * height, RGB_TRIPLE);
	if (!image->data)
		image->width = image->height = 0;
	else {
		image->width = width;
		image->height = height;
	}
	image->x_left = 0;
	image->x_right = width - 1;
	image->y_bottom = 0;
	image->y_top = height - 1;

	if (color->r == color->g && color->g == color->b)
		SET_MULTIPLE_PTR(image->data, color->r, width * height);
	else
		for (i = 0; i < width * height; i++)
			image->data[i] = *color;
}

// Set the clipping viewport within the image.
void set_viewport(IMAGE *image,
				  UNSIGNED x_left, UNSIGNED x_right,
				  UNSIGNED y_bottom, UNSIGNED y_top)
{
	// Turn off clipping for bad viewport coords.
	if (x_left > x_right) {
		x_left = 0;
		x_right = image->width - 1;
	}

	if (y_bottom > y_top) {
		y_bottom = 0;
		y_top = image->height - 1;
	}

	// Chop viewport to image boundary.
	if (x_left >= image->width)
		x_left = image->width - 1;

	if (x_right >= image->width)
		x_right = image->width - 1;

	if (y_bottom >= image->height)
		y_bottom = image->height - 1;

	if (y_top >= image->height)
		y_top = image->height - 1;

	image->x_left = x_left;
	image->x_right = x_right;
	image->y_bottom = y_bottom;
	image->y_top = y_top;
}

// Return a pointer to the RGB triple at the given row and column 
// within the given image.  Row zero is at top of image.
INLINE RGB_TRIPLE *rgb_triple_rc(IMAGE *image, UNSIGNED row, UNSIGNED col)
{
	assert(row < image->height);
	assert(col < image->width);
	return &image->data[row * image->width + col];
}

// Same as above, but use x and y rather than row and column.
INLINE RGB_TRIPLE *rgb_triple_xy(IMAGE *image, UNSIGNED x, UNSIGNED y)
{
	return rgb_triple_rc(image, image->height - 1 - y, x);
}

// Draw a line of width 1 pixel in the image.  If end points are outside
// the window, just truncate them to get them in the window.  Note the
// full implementation of eight bresenham cases makes a starburst fully
// symmetrical.  Algorithms that swap end points won't do this correctly.
void draw_line_raw(IMAGE *image,
				   UNSIGNED x1, UNSIGNED y1,
				   UNSIGNED x2, UNSIGNED y2,
				   RGB_TRIPLE *color)
{
	UNSIGNED w = image->width;
	UNSIGNED h = image->height;
	UNSIGNED i, i2;
	int dx, dy, e;

	// Chop!
	if (x1 >= w) x1 = w - 1;
	if (y1 >= h) y1 = h - 1;
	if (x2 >= w) x2 = w - 1;
	if (y2 >= h) y2 = h - 1;

	i  = (h - 1 - y1) * w + x1;
	i2 = (h - 1 - y2) * w + x2;
	dx = (int)x2 - (int)x1;
	dy = (int)y2 - (int)y1;
	e = 0;

#define bres_loop(Ind_Step, Ind_Update, Step_Comp, Dep_Step, Dep_Update)	\
	for (;;) {										\
		assert(i < w * h);							\
		image->data[i] = *color;					\
		if (i == i2) break;							\
		Ind_Update;									\
		if (Step_Comp) { Dep_Step; Dep_Update; }	\
		Ind_Step;									\
	}
#define incx	i++
#define decx	i--
#define incy	i -= w
#define decy	i += w

	if (dx > 0)
		if (dy > 0)
			if (dx > dy)
				bres_loop(incx, e += dy, e + e >= dx, incy, e -= dx)
			else
				bres_loop(incy, e += dx, e + e >= dy, incx, e -= dy)
		else
			if (dx + dy > 0)
				bres_loop(incx, e -= dy, e + e >= dx, decy, e -= dx)
			else
				bres_loop(decy, e -= dx, e + e <= dy, incx, e -= dy)
	else
		if (dy > 0)
			if (dx + dy < 0)
				bres_loop(decx, e -= dy, e + e <= dx, incy, e -= dx)
			else
				bres_loop(incy, e -= dx, e + e >= dy, decx, e -= dy)
		else
			if (dx < dy)
				bres_loop(decx, e += dy, e + e <= dx, decy, e -= dx)
			else
				bres_loop(decy, e += dx, e + e <= dy, decx, e -= dy)
}

// Draw a rectangle with given corner points.
void draw_rect_raw(IMAGE *image,
				   UNSIGNED x1, UNSIGNED y1,
				   UNSIGNED x2, UNSIGNED y2,
				   RGB_TRIPLE *color)
{
	draw_line_raw(image, x1, y1, x2, y1, color);
	draw_line_raw(image, x2, y1, x2, y2, color);
	draw_line_raw(image, x2, y2, x1, y2, color);
	draw_line_raw(image, x1, y2, x1, y1, color);
}


//  Implementation of Cohen-Sutherland line clipping.
#define LEFT	8
#define TOP		4
#define RIGHT	2
#define BOTTOM	1

INLINE unsigned clip_code(FLOAT x, FLOAT y,
				   FLOAT x_left, FLOAT y_top, FLOAT x_right, FLOAT y_bottom)
{
	unsigned code;

	code = (x < x_left);
	code <<= 1;
	code |= (y > y_top);
	code <<= 1;
	code |= (x > x_right);
	code <<= 1;
	code |= (y < y_bottom);

	return code;
}

void clip_segment(FLOAT *x1p, FLOAT *y1p,
				  FLOAT *x2p, FLOAT *y2p,
				  FLOAT x_left, FLOAT x_right,
				  FLOAT y_bottom, FLOAT y_top,
				  int *segment_survives_p)
{
	FLOAT x1 = *x1p, y1 = *y1p;
	FLOAT x2 = *x2p, y2 = *y2p;
	FLOAT dx = x2 - x1;
	FLOAT dy = y2 - y1;

	UNSIGNED p1_code = clip_code(x1, y1, x_left, y_top, x_right, y_bottom);
	UNSIGNED p2_code = clip_code(x2, y2, x_left, y_top, x_right, y_bottom);

#define chop(Code, X, Y) do {			\
	if (Code & LEFT) {					\
		Y += (x_left - X) * dy / dx;	\
		X = x_left;						\
	}									\
	else if (Code & RIGHT) {			\
		Y += (x_right - X) * dy / dx;	\
		X = x_right;					\
	}									\
	else if (Code & BOTTOM) {			\
		X += (y_bottom - Y) * dx / dy;	\
		Y = y_bottom;					\
	}									\
	else {	/* TOP */					\
		X += (y_top - Y) * dx / dy;		\
		Y = y_top;						\
	}									\
	Code = clip_code(X, Y, x_left, y_top, x_right, y_bottom); } while(0)

	for (;;) {
		if ( (p1_code | p2_code) == 0 ) {
			// Trivial accept.
			*segment_survives_p = 1;
			break;
		}

		if ( (p1_code & p2_code) != 0 ) {
			// Trivial reject.
			*segment_survives_p = 0;
			break;
		}

		// Chop against a boundary and try again.
		if (p1_code != 0)
			chop(p1_code, x1, y1);
		else
			chop(p2_code, x2, y2);
	}
	*x1p = x1; *y1p = y1;
	*x2p = x2; *y2p = y2;
}

// Draw a line properly clipped to the viewport.
void draw_line(IMAGE *image,

			   FLOAT x1, FLOAT y1,
			   FLOAT x2, FLOAT y2,

			   RGB_TRIPLE *color)
{
	int segment_survives_p;

	clip_segment(&x1, &y1, &x2, &y2, 
				 (FLOAT)image->x_left, (FLOAT)image->x_right, (FLOAT)image->y_bottom, (FLOAT)image->y_top, 
				 &segment_survives_p);
	if (segment_survives_p)
		draw_line_raw(image, (UNSIGNED)x1, (UNSIGNED)y1, (UNSIGNED)x2, (UNSIGNED)y2, color);
}

/* ----- PNG image compression -------------------------------------- */

// Initialize a compressed image to null.
void init_compressed_image(COMPRESSED_IMAGE *compressed_image)
{
	ZERO_PTR(compressed_image);
}

// Release any storage allocated for a compressed image.
void clear_compressed_image(COMPRESSED_IMAGE *compressed_image)
{
	Safefree(compressed_image->data);
	init_compressed_image(compressed_image);
}

// Callback for memory allocation.  We call the perl allocator.
static png_voidp png_malloc_callback(png_structp png_reader_or_writer, png_size_t size)
{
	BYTE *ptr;

	New(1010, ptr, size, BYTE);
	return (png_voidp)ptr;
}

// Callback to free memory.  We call the perl deallocator.
static void png_free_callback(png_structp png_reader_or_writer, png_voidp ptr)
{
	Safefree(ptr);
}

// Callback to write a block of compressed data.  We copy to a memory buffer
// in the compressed image.
static void png_write_callback(png_structp png_writer, png_bytep data, png_size_t length)
{
    // We put the compressed_image output buffer on the io_ptr below when
	// we called png_set_write_fn.  Retrieve it now!
    COMPRESSED_IMAGE *compressed_image = png_get_io_ptr(png_writer);
	UNSIGNED new_size;

	if (compressed_image->size - compressed_image->filled < length) {
		if (compressed_image->size == 0) {
			new_size = INIT_COMPRESSED_IMAGE_SIZE;
			New(1020, compressed_image->data, new_size, BYTE);
		}
		else
			new_size = compressed_image->size;
		while (new_size - compressed_image->filled < length)
			new_size *= 2;
		if (new_size > compressed_image->size) {
			Renew(compressed_image->data, new_size, BYTE);
			compressed_image->size = new_size;
		}
	}
	memcpy(&compressed_image->data[compressed_image->filled], data, length);
	compressed_image->filled += length;
}

// Callback to flush data previously written.  A no-op here.
static void png_flush_callback(png_structp png_ptr)
{
	// No need to do anything!
}

// Callback to handle serious errors.  We quietly longjmp to the error exit point.
static void png_error_callback(png_structp png_reader_or_writer, png_const_charp error_msg)
{
   longjmp(png_jmpbuf(png_reader_or_writer), 1);
}

// Callback to handle warnings.  We quietly do nothing.
static void png_warning_callback(png_structp png_reader_or_writer, png_const_charp warning_msg)
{
}

// Compress an image into PNG format in compressed_image.  This follows the example
// provided with libpng fairly closely.
int compress_image(IMAGE *image,
				   COMPRESSED_IMAGE *compressed_image)
{
	png_structp png_writer;
	png_infop png_info;
	png_bytepp row_pointers;
	UNSIGNED row;

	png_writer = png_create_write_struct_2(
		PNG_LIBPNG_VER_STRING, 
		NULL,					/* (png_voidp)user_error_ptr, */
        png_error_callback, 
		png_warning_callback, 
		NULL,					/* (png_voidp)user_mem_ptr  */
		png_malloc_callback, 
		png_free_callback);

    png_info = png_create_info_struct(png_writer);
    if (!png_info) {
       png_destroy_write_struct(&png_writer, NULL);
       return 1;
    }

	if ( setjmp(png_jmpbuf(png_writer)) ) {
       png_destroy_write_struct(&png_writer, &png_info);
       return 2;
    }

	clear_compressed_image(compressed_image);
    png_set_write_fn(png_writer,
					 compressed_image,	// Pass memory buffer on the helpful pointer.
					 png_write_callback,
					 png_flush_callback);

    png_set_IHDR(png_writer, png_info, 
		image->width, image->height,
		N_BITS(image->data[0].r),
        PNG_COLOR_TYPE_RGB, 
		PNG_INTERLACE_NONE,
		PNG_COMPRESSION_TYPE_DEFAULT, 
		PNG_FILTER_TYPE_DEFAULT);

	row_pointers = png_malloc(png_writer, image->height * sizeof(png_bytep));
	if (!row_pointers) {
		png_destroy_write_struct(&png_writer, &png_info);
		return 3;
	}
	for (row = 0; row < image->height; row++)
		row_pointers[row] = (png_bytep)rgb_triple_rc(image, row, 0);

	png_set_rows(png_writer, png_info, row_pointers);

    png_write_png(png_writer, png_info, PNG_TRANSFORM_IDENTITY, NULL);

	// Successful completion.
	png_free(png_writer, row_pointers);
	png_destroy_write_struct(&png_writer, &png_info);
	return 0;
}

#ifdef SKETCH_TEST

void draw_starburst(IMAGE *image)
{
	int x, y, c;
	static RGB_TRIPLE colors[] = {
		{ 0, 0, 0 },
		{ 255, 0, 0 },
		{ 0, 255, 0 },
		{ 0, 0, 255 },
		{ 255, 255, 0 },
		{ 255, 0, 255 },
		{ 0, 255, 255 },
	};

#define L	0
#define R	383
#define B	0
#define T	511
#define I	8

	for (x = y = c = 0	; x <= R; x += I)
		draw_line(image, (FLOAT)R/2, (FLOAT)T/2, (FLOAT)x, (FLOAT)y, &colors[++c % 7]);
	for (x = R		; y < T; y += I)
		draw_line(image, (FLOAT)R/2, (FLOAT)T/2, (FLOAT)x, (FLOAT)y, &colors[++c % 7]);
	for (y = T		; x > 0; x -= I)
		draw_line(image, (FLOAT)R/2, (FLOAT)T/2, (FLOAT)x, (FLOAT)y, &colors[++c % 7]);
	for (x = 0		; y > 0; y -= I)
		draw_line(image, (FLOAT)R/2, (FLOAT)T/2, (FLOAT)x, (FLOAT)y, &colors[++c % 7]);
}

int main(void)
{
	IMAGE image[1];
	COMPRESSED_IMAGE compressed_image[1];
	FILE *f;
	UNSIGNED n;
	RGB_TRIPLE white[1] = {{255, 255, 255}};
	init_image(image);
	init_compressed_image(compressed_image);

	for (n = 0; n < 1; n++) {

		fprintf(stderr, ".");

		setup_image(image, R+1, T+1, white);

#define X1 50
#define X2 R/2-50
#define X3 R/2+50
#define X4 R-50
#define Y1 50
#define Y2 T/2-50
#define Y3 T/2+50
#define Y4 T-50

		set_viewport(image, X1, X2, Y1, Y2);
		draw_starburst(image);
		set_viewport(image, X3, X4, Y1, Y2);
		draw_starburst(image);
		set_viewport(image, X1, X2, Y3, Y4);
		draw_starburst(image);
		set_viewport(image, X3, X4, Y3, Y4);
		draw_starburst(image);
		set_viewport(image, X2, X3, Y2, Y3);
		draw_starburst(image);

		compress_image(image, compressed_image);
		clear_image(image);
	}
	fprintf(stderr, "\n");

	f = fopen("sketch.png", "wb");
	if (!f) {
		fprintf(stderr, "can't open sketch.png for output\n");
		return 1;
	}
	fwrite(compressed_image->data, 1, compressed_image->filled, f);
	clear_compressed_image(compressed_image);
	fclose(f);

	return 0;
}

#endif