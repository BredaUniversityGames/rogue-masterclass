#!/usr/bin/env python

import cairo
import random
import colorsys
import math

def roundrect(context, x, y, width, height, r):
    context.arc(x+r, y+r, r,
                math.pi, 3*math.pi/2)
    context.arc(x+width-r, y+r, r,
                3*math.pi/2, 0)
    context.arc(x+width-r, y+height-r,
                r, 0, math.pi/2)
    context.arc(x+r, y+height-r, r,
                math.pi/2, math.pi)
    context.close_path()


width, height = 512, 200
base = random.random() * 0.3 + 0.4

textSurf = cairo.ImageSurface(cairo.FORMAT_ARGB32, width, height)
textCtx = cairo.Context(textSurf)
textCtx.set_font_size(150)
textCtx.select_font_face("Morro", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
textCtx.set_source_rgb(1.0, 1.0, 1.0)
textCtx.move_to(50, height - 50)
textCtx.show_text("RAN")
textCtx.rel_move_to(8, 0)
textCtx.show_text("D")

stripesSurf = cairo.ImageSurface(cairo.FORMAT_ARGB32, width, height)
stripesCtx = cairo.Context(stripesSurf)

for y in range(0, height):
    t = math.fabs(math.sin(y / width * 3)) * 0.1
    (h, s, v) = (random.random() * 0.2 + t + base + 0.08, 0.8, 0.9)
    (r, g, b) = colorsys.hsv_to_rgb(h, s, v)
    val = random.random() * 0.5 + 0.5
    stripesCtx.set_source_rgb(r, g, b)
    stripesCtx.rectangle(0, y, width, 1)
    stripesCtx.fill()
#stripesSurf.write_to_png("stipes.png")

stripesSurfClipped = cairo.ImageSurface(cairo.FORMAT_ARGB32, width, height)
stripesCtxClipped = cairo.Context(stripesSurfClipped)
stripesCtxClipped.set_source_surface(stripesSurf)    
stripesCtxClipped.mask_surface(textSurf)   
#stripesSurfClipped.write_to_png("stipes_mask.png")

stripesSurf2 = cairo.ImageSurface(cairo.FORMAT_ARGB32, width, height)
stripesCtx2 = cairo.Context(stripesSurf2)
for x in range(0, width):
    t = math.fabs(math.cos(x / width * 3)) * 0.1
    (h, s, v) = (random.random() * 0.2 + t + base - 0.05, 0.8, 0.9)
    (r, g, b) = colorsys.hsv_to_rgb(h, s, v)
    val = random.random() * 0.5 + 0.5
    stripesCtx2.set_source_rgb(r, g, b)
    stripesCtx2.rectangle(x, 0, 1, height)
    stripesCtx2.fill()
#stripesSurf2.write_to_png("stipes2.png")


colorSurf = cairo.ImageSurface(cairo.FORMAT_ARGB32, width, height)
colorCtx = cairo.Context(colorSurf)
colorCtx.set_source_surface(stripesSurf2)
roundrect(colorCtx, 10, 10, width-20, height-20, 40)
colorCtx.fill()
roundrect(colorCtx, 5, 5, width - 10, height - 10, 45)
colorCtx.set_line_width(10)
(h, s, v) = (base + 0.28, 0.6, 0.9)
(r, g, b) = colorsys.hsv_to_rgb(h, s, v)
colorCtx.set_source_rgb(r,g,b)
colorCtx.stroke()
colorCtx.set_source_surface(stripesSurfClipped)
colorCtx.rectangle(0, 0, width, height)
colorCtx.fill()

colorSurf.write_to_png("color.png")

print("Done")
