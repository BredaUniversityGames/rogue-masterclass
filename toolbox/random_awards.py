#!/usr/bin/env python

import cairo
import random
import colorsys
import math

WIDTH, HEIGHT = 1024, 256
pi = 3.14

surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, WIDTH, HEIGHT)
cr = cairo.Context(surface)

cr.scale(WIDTH, HEIGHT)  # Normalizing the canvas

utf8 = "cairo"
cr.set_line_width(2/WIDTH)

for x in range(1, WIDTH):
    t = math.fabs(math.sin(x / WIDTH * 3)) * 0.1
    (h, s, v) = (random.random() * 0.2 + t + 0.55, 0.8, 0.9)
    (r, g, b) = colorsys.hsv_to_rgb(h, s, v)
    
    val = random.random() * 0.5 + 0.5
    cr.set_source_rgb(r, g, b)
    cr.move_to(x/WIDTH, 1)
    cr.line_to(x/WIDTH, 0)
    cr.stroke()

surface.write_to_png("example.png")  # Output to PNG
