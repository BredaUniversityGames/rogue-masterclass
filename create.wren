import "xs" for Data, Input, Render
import "xs_math"for Math, Bits, Vec2, Color
import "xs_ec"for Entity, Component
import "xs_components" for Transform, Body, Renderable, Sprite, GridSprite, AnimatedSprite
import "random" for Random
import "types" for Type

class Create {

    static init() {
        __random = Random.new()
        __id = 0
    }

    static character(x, y, image) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = AnimatedSprite.new(image, 4, 11, 30) // Same image for all
        var tl = Tile.new(x, y)
        var f = 0
        s.addAnimation("idle",          [f,f,f,f,f,f,f,f,f+1,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+1,f+1,f+1])
        f = f + 4
        s.addAnimation("selected",      [f,f,f,f,f,f,f,f,f+1,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+2,f+1,f+1,f+1])
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
        s.addAnimation("pain down",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain side",     [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
        f = f + 4
        s.addAnimation("pain up",       [f,f,f,f+1,f+1,f+1,f+2,f+2,f+2,f+3,f+3,f+3])
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
        entity.name = "H%(nextID)"
        return entity
    }

    static slime(x, y) {
        var entity = character(x, y, "[game]/assets/chara_slime.png")
        var s = Slime.new()
        entity.addComponent(s)
        entity.tag = Type.enemy
        entity.name = "S%(nextID)"
        return entity
    }

    static nextID {
        __id = __id + 1
        return __id
    }

    static spikes() {}

    static stairs() {}

    static crate() {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 24)
        s.idx = 368
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        entity.tag = Type.wall
        entity.name = "C%(nextID)"
        return entity
    }
    
    static pillar(x, y, fire) {
        {   // Pillar 
            var entity = Entity.new()
            var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
            var t = Transform.new(pos)
            var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 12)
            if(fire) {
                s.idx = 185
            } else {
                s.idx = 187
            }
            var tl = Tile.new(x, y)
            s.flags = Render.spriteCenter
            entity.addComponent(t)
            entity.addComponent(s)        
            entity.addComponent(tl)
            entity.tag = Type.wall
            entity.name = "P%(nextID)"
        }
        if(fire){
            var entity = Entity.new()
            var pos = Level.calculatePos(x, y) + Vec2.new(0, Level.tileSize / 2)
            var t = Transform.new(pos)
            var s = AnimatedSprite.new("[game]/assets/tiles_dungeon.png", 20, 12, 15)
            s.addAnimation("burn", [180, 181, 182, 183])
            s.playAnimation("burn")
            s.mode = AnimatedSprite.loop
            s.flags = Render.spriteCenter
            entity.addComponent(t)
            entity.addComponent(s)        
            entity.name = "F%(nextID)"
        }
    }

    static something(x, y) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 24)
        var stuff = [240, 354, 358, 357, 358, 396, 356]
        var idx = __random.int(0, stuff.count)
        s.idx = stuff[idx]
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        entity.tag = Type.wall
        entity.name = "F%(nextID)"
        return entity
    }

    static door(x, y, vertical) {
        var entity = Entity.new()
        var t = Transform.new(Level.calculatePos(x, y))
        var s = GridSprite.new("[game]/assets/tiles_dungeon.png", 20, 24)
        s.idx = vertical ? 235 : 234
        var tl = Tile.new(x, y)
        s.flags = Render.spriteCenter
        entity.addComponent(t)
        entity.addComponent(s)        
        entity.addComponent(tl)
        entity.tag = Type.door
        entity.name = "F%(nextID)"
        return entity
    }
}

import "gameplay" for Hero, Slime, Tile, Level