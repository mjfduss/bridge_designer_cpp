require 'mkmf'

have_library("png", "png_create_write_struct_2")
have_library("z", "zlibVersion")
create_makefile('WPBDC/WPBDC')