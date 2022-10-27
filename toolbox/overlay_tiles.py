#!/usr/bin/python

image_path = "assets/tiles_dungeon.png"
out_image_path = "assets/tiles_dungeon_numbed.png"
tile_width = 16
tile_height = 16

import cairo

image = cairo.ImageSurface.create_from_png(image_path)
image_width = image.get_width()
image_height = image.get_height()

w_tiles = image_width / tile_width
h_tiles = image_height / tile_height

ctx = cairo.Context(image)
ctx.set_font_size(7)
ctx.select_font_face("Mono", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)

glyphs = []
for x in range(0, int (w_tiles)) :
    for y in range(0, int(h_tiles)) :
        #ctx.move_to((x + 0.1) * tile_width, (y - .5 + 1) * tile_height )
        #ctx.show_text(str(x))
        #ctx.move_to((x + 0.1) * tile_width, (y - .15 + 1) * tile_height )
        #ctx.show_text(str(y))
        #ctx.show_text("pita")
        ctx.move_to((x + 0.1) * tile_width, (y - .5 + 1) * tile_height )
        ctx.show_text(str(int(y * w_tiles + x)))

image.write_to_png(out_image_path)