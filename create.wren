import "xs" for Data, Input, Render     // These are the parts of the xs we will be using
import "xs_math"for Math, Bits, Vec2, Color
//import "xs_assert" for Assert
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random              // Random is a part of the Wren library
//import "sparse_grid" for SpraseGrid
import "types" for Type

class Create {
    static hero() {
        var coord = Vec2.new(5, 5)
        var player = Entity.new()        
        var t = Transform.new(Roguealot.calculatePos(coord))
        var s = AnimatedSprite.new("[game]/assets/chara_hero.png", 4, 11, 15)
        s.addAnimation("idle",          [0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,1])
        //s.addAnimation("idle side",   [0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,1])
        s.addAnimation("selected",      [4,4,4,4,4,4,4,4,5,6,6,6,6,6,6,6,5])

        s.addAnimation("walk down",     [8,8,8,9,9,9,10,10,10,11,11,11])
        s.addAnimation("walk side",     [12,12,12,13,13,13,14,14,14,15,15,15])
        s.addAnimation("walk up",       [16,16,16,17,17,17,18,18,18,19,19,19])

        s.addAnimation("attack down",   [20,20,20,21,21,21,22,22,22,23,23,23])
        s.addAnimation("attack side",   [24,24,24,25,25,25,26,26,26,27,27,27])
        s.addAnimation("attack up",     [28,28,28,29,29,29,30,30,30,31,31,31])

        s.playAnimation("idle")

        s.flags = Render.spriteCenter
        var h = Hero.new()
        var tl = Tile.new(coord.x, coord.y)
        player.addComponent(t)
        player.addComponent(s)
        player.addComponent(h)
        player.addComponent(tl)
        player.name = "Player"
        return player
    }

    static slime() {
    }

    static spikes() {}

    static stairs() {}

    static crate() {}
    
    static pilar() {}
}

import "gameplay" for Hero, Slime, Tile
import "game" for Roguealot