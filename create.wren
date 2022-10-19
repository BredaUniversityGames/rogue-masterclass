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
        var f = 0
        s.addAnimation("idle",          [f,f,f,f,f,f,f,f,f+1,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+1])
        f = f + 4
        s.addAnimation("selected",      [f,f,f,f,f,f,f,f,f+1,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+1])
        f = f + 4
        s.addAnimation("walk down",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("walk side",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("walk up",       [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("attack down",   [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("attack side",   [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("attack up",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain down",   [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain side",   [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain up",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
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
        var s = Slime.new()
        entity.addComponent(s)
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