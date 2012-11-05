#include "stdafx.h"
#include "internal.h"

static INLINE FLOAT float_min(FLOAT x, FLOAT y)
{
	return x < y ? x : y;
}

static INLINE long round_to_long(FLOAT x)
{
	return ((long)(x + (FLOAT)0.5));
}

// Number of bridge designer grids to use as a margin around the image edge.
#define SKETCH_MARGIN	3

// Number of pixels in a single bridge designer grid.
#define SKETCH_GRID_SIZE	8

#define MAX_NOFORCE_R	192
#define MAX_NOFORCE_G	192
#define MAX_NOFORCE_B	192

#define MAX_TENSION_R	0
#define MAX_TENSION_G	0
#define MAX_TENSION_B	255

static void set_tension_color(FLOAT intensity, RGB_TRIPLE *color)
{
	if (intensity < 0) intensity = 0;
	else if (intensity > 1) intensity = 1;
	color->r = (BYTE)(MAX_TENSION_R * intensity + MAX_NOFORCE_R * (1 - intensity));
	color->g = (BYTE)(MAX_TENSION_G * intensity + MAX_NOFORCE_G * (1 - intensity));
	color->b = (BYTE)(MAX_TENSION_B * intensity + MAX_NOFORCE_B * (1 - intensity));
}

#define MAX_COMPRESSION_R	255
#define MAX_COMPRESSION_G	0
#define MAX_COMPRESSION_B	0

static void set_compression_color(FLOAT intensity, RGB_TRIPLE *color)
{
	if (intensity < 0) intensity = 0;
	else if (intensity > 1) intensity = 1;
	color->r = (BYTE)(MAX_COMPRESSION_R * intensity + MAX_NOFORCE_R * (1 - intensity));
	color->g = (BYTE)(MAX_COMPRESSION_G * intensity + MAX_NOFORCE_G * (1 - intensity));
	color->b = (BYTE)(MAX_COMPRESSION_B * intensity + MAX_NOFORCE_B * (1 - intensity));
}

void do_sketch(TBridge *bridge,
			   TAnalysis *analysis,
			   int width, int height,
			   COMPRESSED_IMAGE *compressed_image)
{
	IMAGE image[1];
	static RGB_TRIPLE white[1] = {{255, 255, 255}};
	static RGB_TRIPLE black[1] = {{0, 0, 0}};
	static RGB_TRIPLE gray[1] = {{192, 192, 192}};
	RGB_TRIPLE color[1];
	UNSIGNED bridge_width_grids;
	UNSIGNED bridge_height_grids;
	UNSIGNED bridge_left_anchorage_margin;
	UNSIGNED bridge_right_anchorage_margin;
	UNSIGNED x_org_pixel;
	UNSIGNED y_org_pixel;
	FLOAT grid_pixels;
	UNSIGNED member_index;
	
	init_image(image);

	// Clear any old image stored in the compressed image data structure.
	clear_compressed_image(compressed_image);

	// Build a blank white image.
	setup_image(image, width, height, white);

	// Draw the bridge into the image.
	bridge_width_grids = bridge->load_scenario.num_length_grids;
	bridge_height_grids = bridge->load_scenario.over_grids + bridge->load_scenario.under_grids;
	bridge_left_anchorage_margin = (bridge->load_scenario.support_type & CABLE_SUPPORT_LEFT) ? CABLE_ANCHORAGE_X_OFFSET : 0;
	bridge_right_anchorage_margin = (bridge->load_scenario.support_type & CABLE_SUPPORT_RIGHT) ? CABLE_ANCHORAGE_X_OFFSET : 0;

	grid_pixels = float_min(width  / (float)(bridge_width_grids + bridge_left_anchorage_margin + bridge_right_anchorage_margin + 2 * SKETCH_MARGIN),
					        height / (float)(bridge_height_grids + 2 * SKETCH_MARGIN));
		
	x_org_pixel = round_to_long( (width  - (bridge_width_grids - bridge_left_anchorage_margin + bridge_right_anchorage_margin) * grid_pixels) / 2.0f );
	y_org_pixel = round_to_long( (height - bridge_height_grids * grid_pixels) / 2.0f );

#define SKETCH_X(Grid)	(x_org_pixel + round_to_long((Grid) * grid_pixels))
#define SKETCH_Y(Grid)	(y_org_pixel + round_to_long(((Grid) +  bridge->load_scenario.under_grids) * grid_pixels))

	draw_rect_raw(image,
				  SKETCH_X(0), SKETCH_Y(-(int)bridge->load_scenario.under_grids),
				  SKETCH_X(bridge->load_scenario.num_length_grids), SKETCH_Y(bridge->load_scenario.over_grids),
				  gray);

	for (member_index = 1; member_index <= bridge->n_members; member_index++) {

		TMember *m = &bridge->members[member_index];
		TJoint *j1 = &bridge->joints[m->start_joint];
		TJoint *j2 = &bridge->joints[m->end_joint];

		if (analysis->member_strength[member_index].compressive_fail_mode == FailModeSlenderness) {
			color->r = color->b = 255;
			color->g = 0;
		}
		else {
			TFloat compressive = analysis->member_strength[member_index].compressive;
			TFloat compression_intensity = compressive > 0 ? analysis->max_forces[member_index].compression / compressive : 0;

			TFloat tensile = analysis->member_strength[member_index].tensile;
			TFloat tension_intensity = tensile > 0 ? analysis->max_forces[member_index].tension / tensile : 0;

			if (compression_intensity > tension_intensity)
				set_compression_color((FLOAT)compression_intensity, color);
			else
				set_tension_color((FLOAT)tension_intensity, color);
		}
		draw_line_raw(image, SKETCH_X(j1->x), SKETCH_Y(j1->y), SKETCH_X(j2->x), SKETCH_Y(j2->y), color);
	}
	// Compress the image.
	compress_image(image, compressed_image);
	clear_image(image);
}

