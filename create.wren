import "xs" for Data, Input, Render
import "xs_math"for Math, Bits, Vec2, Color
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random
import "types" for Type

class Create {

    static init() {
        __random = Random.new()
    }

    static character(x, y, image) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = AnimatedSprite.new(image, 4, 11, 15) // Same image for all
        var tl = Tile.new(x, y)
        s.addAnimation("idle",          [0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,1])
        s.addAnimation("selected",      [4,4,4,4,4,4,4,4,5,6,6,6,6,6,6,6,5])
        s.addAnimation("walk down",     [8,8,8,9,9,9,10,10,10,11,11,11])
        s.addAnimation("walk side",     [12,12,12,13,13,13,14,14,14,15,15,15])
        s.addAnimation("walk up",       [16,16,16,17,17,17,18,18,18,19,19,19])
        s.addAnimation("attack down",   [20,20,20,21,21,21,22,22,22,23,23,23])
        s.addAnimation("attack side",   [24,24,24,25,25,25,26,26,26,27,27,27])
        s.addAnimation("attack up",     [28,28,28,29,29,29,30,30,30,31,31,31])
        s.playAnimation("idle")
        s.randomizeFrame(__random)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        return entity
    }

    static hero(x, y) {
        var entity = character(x, y, "[game]/assets/chara_hero.png")
        var h = Hero.new()
        entity.addComponent(h)
        entity.tag = Type.player
        entity.name = "Hero"
        return entity
    }

    static slime(x, y) {
        var entity = character(x, y, "[game]/assets/chara_slime.png")
        entity.tag = Type.enemy
        entity.name = "Slime"
        return entity
    }

    static spikes() {}

    static stairs() {}

    static crate() {}
    
    static pilar() {}
}

import "gameplay" for Hero, Slime, Tile, Level