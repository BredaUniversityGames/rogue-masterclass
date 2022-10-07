#!/usr/bin/python

image_path = "assets/tiles_dungeon.png"
tile_width = 16
tile_height = 16

import cairo

image = cairo.ImageSurface.create_from_png(image_path)
image_width = image.get_width()
image_height = image.get_height()

w_tiles = image_width / tile_width
h_tiles = image_height / tile_height

#surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, image_width, image_height)
ctx = cairo.Context(image)
ctx.set_line_width(0.04)
ctx.set_font_size(7)
ctx.select_font_face("Mono", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)

glyphs = []
for x in range(0, int (w_tiles)) :
    for y in range(0, int(h_tiles)) :
        ctx.move_to((x + 0.1) * tile_width, (y - .5 + 1) * tile_height )
        ctx.show_text(str(x))
        ctx.move_to((x + 0.1) * tile_width, (y - .15 + 1) * tile_height )
        ctx.show_text(str(y))
        
        #glyphs.append((, x * tile_width, y * tile_height))

image.write_to_png("numbed.png")